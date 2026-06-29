# 30일 가격 흐름 커버리지 분석

## 관찰 결과

- `v4-sample-set-current-report.md`에서 다수 종목이 `30일 가격 흐름 축적 중인 데이터 부족 유지`로 남아 있습니다.
- 대표 예시:
  - `T`
  - `CMCSA`
  - `PGR`
  - `CI`
  - `GILD`
- 이 종목들은 공통적으로:
  - 최신 스냅샷 날짜가 `2026-06-15` 근처에 멈춰 있음
  - `priceMomentumScore`가 `null`
  - `priceStabilityScore`는 존재
  - 펀더멘털 값은 일부 존재

즉, 현재 문제는 “재무 데이터 전체 부재”보다 “최신 30일 가격 흐름 미적재” 쪽이 더 큽니다.

## 코드 기준 원인 정리

### 1. 즉시 적재 로직 자체는 존재

- 포트폴리오 저장 후:
  - `PortfolioWarmupService -> ensureRecommendationSnapshot(stockId)`
- 상세 진입 전:
  - `RecommendationService -> ensureRecommendationSnapshot(stockId)`

이 경로에서는 단일 종목 기준으로:

1. 오늘 최신 스냅샷 동기화
2. 45일 과거 가격 백필
3. 필요 시 120일 재백필

까지 시도합니다.

따라서 “내가 방금 담은 종목”은 구조상 보강될 수 있습니다.

### 2. 운영 샘플셋의 대량 공백은 배치 커버리지 우선순위 문제

일반 종목은 배치에서 `defaultLimit = 500`으로 잘라 처리합니다.

기존 쿼리는:

- `최신 snapshot_date`가 오래된 종목 우선

만 보고 있었습니다.

이 방식의 문제:

- 오늘 스냅샷이 한 번 찍혔지만 `change_rate_30d`가 여전히 `null`인 종목은
- “최신 날짜는 최근”으로 간주되어 우선순위가 뒤로 밀릴 수 있습니다.

그러면:

- 30일 흐름이 비어 있는 종목이 계속 일반 배치 상단으로 못 올라오고
- 결과적으로 샘플셋/비포트폴리오 종목에서 `priceMomentumScore = null`이 길게 남게 됩니다.

## 이번 보완

배치 대상 선택 쿼리를 조정했습니다.

대상 파일:

- `backend/src/main/resources/mapper/stock/StockPriceSnapshotMapper.xml`

변경 내용:

- `findActivePortfolioStocksForSnapshot`
- `findActiveNonPortfolioStocksForSnapshot`

두 쿼리 모두 `order by` 앞부분에 아래 우선순위를 추가했습니다.

1. 최신 스냅샷의 `change_rate_30d is null` 종목 우선
2. 그 다음 최신 `snapshot_date`가 오래된 종목 우선
3. 마지막으로 `id asc`

즉 이제는 단순히 “오래 안 돌린 종목”보다,
`30일 가격 흐름이 아직 완성되지 않은 종목`이 먼저 배치에 들어옵니다.

## 운영 기준 판정

### 즉시 백필 강화

- 이미 `ensureRecommendationSnapshot`에서 구현되어 있음
- 신규 포트폴리오 종목에는 충분히 유효

판정:

- 추가 구현보다 현재 경로 유지

### 신규 종목 적재 재시도

- 이미 45일 + 120일 재시도 로직 존재
- 단일 종목 보강에는 적절

판정:

- 구조는 충분
- 실패 로그/실행 타이밍 모니터링만 추가 고려

### 배치 커버리지 확장

- 현재 가장 필요한 영역
- 이유:
  - 일반 종목 500개 제한
  - 기존 우선순위가 `30일 흐름 null`을 충분히 밀어올리지 못했음

판정:

- 가장 먼저 손봐야 할 핵심 원인
- 이번 패치로 우선순위 개선 완료

## 현재 결론

운영 기준으로는 아래처럼 정리할 수 있습니다.

- 신규 저장 직후 종목:
  - `즉시 백필 강화`로 대응
- 상세 진입 시:
  - `재시도`로 대응
- 샘플셋/일반 종목 대량 공백:
  - `배치 커버리지 우선순위 개선`이 핵심

즉 이번 이슈의 1순위 해법은
`즉시 백필`도 `재시도`도 아니라,
`배치가 30일 흐름 null 종목을 먼저 집도록 만드는 것`
입니다.

## 다음 권장 작업

1. 운영 DB에서 하루 배치 1회 실행 후 `change_rate_30d null` 종목 수 재확인
2. `PortfolioSnapshotCoverageReportTest` 또는 별도 운영 SQL로 null 감소 추적
3. 필요 시 `defaultLimit` 자체를 500 -> 700 이상으로 상향 검토

## 운영 확인 SQL

```sql
select
    s.symbol,
    latest.snapshot_date,
    latest.change_rate_30d,
    latest.current_price,
    latest.source
from stocks s
join lateral (
    select
        sps.snapshot_date,
        sps.change_rate_30d,
        sps.current_price,
        sps.source
    from stock_price_snapshots sps
    where sps.stock_id = s.id
    order by sps.snapshot_date desc, sps.id desc
    limit 1
) latest on true
where s.is_active = true
  and latest.change_rate_30d is null
order by latest.snapshot_date asc, s.symbol asc;
```
