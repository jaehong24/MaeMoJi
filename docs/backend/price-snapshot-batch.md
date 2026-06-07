# MaeMoJi 가격 스냅샷 배치

## 목적

`stock_price_snapshots` 테이블에 종목별 가격 기준 데이터를 일자 단위로 저장합니다.

현재 적재 항목:

- `current_price`
- `change_rate_1d`
- `change_rate_7d`
- `change_rate_30d`
- `market_cap`
- `per_value`
- `source`

Finnhub에서는 `quote`와 `stock/metric`만 호출하며 `stock/candle`은 사용하지 않습니다.

수익률은 우리 DB에 누적된 가격으로 계산합니다.

- 1일 수익률: 직전 저장일 가격과 비교
- 7일 수익률: 7일 전부터 최대 14일 전 사이의 가장 가까운 가격과 비교
- 30일 수익률: 30일 전부터 최대 40일 전 사이의 가장 가까운 가격과 비교

기준 가격이 아직 쌓이지 않은 기간은 `null`로 저장합니다. 추천 엔진은 최신 DB 스냅샷의 30일 수익률만 사용합니다. 스냅샷이 없을 때는 Finnhub `quote`로 현재가만 보완하며 30일 수익률을 임의로 만들지 않습니다.

## 수동 실행

로컬 서버가 `8081`에서 실행 중일 때:

```http
POST http://localhost:8081/api/admin/batches/price-snapshots/sync
```

특정 개수만 실행:

```http
POST http://localhost:8081/api/admin/batches/price-snapshots/sync?limit=100
```

응답 예시:

```json
{
  "success": true,
  "data": {
    "snapshotDate": "2026-06-07",
    "requestedCount": 100,
    "savedCount": 97,
    "failedCount": 3,
    "usedScheduler": false
  },
  "message": "OK"
}
```

## 자동 실행

[application.yml](C:/Users/icand/Documents/MaeMoJi/backend/src/main/resources/application.yml:1)에서 아래 값을 사용합니다.

```yml
maemoji:
  batch:
    price-snapshots:
      enabled: true
      cron: "0 40 6 * * *"
      delay-millis: 2100
      default-limit: 500
```

- `enabled`: `true`로 바꾸면 스케줄러 활성화
- `cron`: 매일 실행 시간
- `delay-millis`: 종목 처리 간 대기 시간. 무료 플랜 호출 제한을 고려한 기본값은 2.1초
- `default-limit`: 수동 실행 시 `limit` 미지정 기본값

기본 크론 `0 40 6 * * *` 는 매일 오전 6시 40분 실행입니다.

## 사용 순서

1. `FINNHUB_API_KEY` 환경변수가 설정되어 있어야 합니다.
2. 백엔드를 재시작합니다.
3. 먼저 수동 실행으로 정상 적재를 확인합니다.
4. 자동 실행이 필요하지 않으면 `enabled: false`로 바꿉니다.

## 확인 SQL

```sql
select
    stock_id,
    snapshot_date,
    current_price,
    change_rate_1d,
    change_rate_7d,
    change_rate_30d,
    market_cap,
    per_value,
    source
from stock_price_snapshots
order by snapshot_date desc, stock_id asc
limit 20;
```
