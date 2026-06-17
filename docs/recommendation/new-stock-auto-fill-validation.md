# 새 종목 자동 적재 검증 시나리오

## 목적

사용자가 새 종목을 포트폴리오에 추가했을 때 아래 값이 안정적으로 채워지는지 검증합니다.

- 현재가
- EPS
- 매출 성장률
- 영업이익률
- ROE
- 잉여현금흐름 수익률
- 이익 대비 현금흐름 품질

핵심은 특정 샘플 종목만 되는 것이 아니라, 새로 추가되는 어떤 종목이든 같은 흐름으로 채워져야 한다는 점입니다.

## 현재 보장해야 하는 2단계

### 1. 포트폴리오 저장 직후 즉시 적재

경로:

- `POST /api/portfolio-items`
- `PortfolioService.createOrUpdatePortfolioItem`
- `stockPriceSnapshotBatchService.syncLatestSnapshotForStock(stockId)`

기대 결과:

- 사용자가 종목을 추가하면 바로 당일 `stock_price_snapshots`가 생성되거나 갱신된다.
- 가능하면 이 단계에서 핵심 펀더멘털 값이 함께 채워진다.

### 2. 추천/상세 진입 직전 보강 적재

경로:

- `GET /api/recommendations/{portfolioItemId}`
- `RecommendationService.fetchPriceSnapshot`
- `stockPriceSnapshotBatchService.ensureRecommendationSnapshot(stockId)`

기대 결과:

- 저장 직후 적재가 일부 실패했더라도
- 상세 진입 시 부족한 스냅샷을 한 번 더 보강한다.
- 최소 핵심 펀더멘털 4개 이상이 있으면 추천 계산을 계속할 수 있다.

## 30일 가격 흐름 초기 백필

스냅샷 테이블이 최근 며칠치만 쌓인 상태에서는 `change_rate_30d`가 비어 있을 수 있습니다.
이때는 과거 가격 백필을 한 번 실행해서 최신 행의 7일/30일 수익률을 채웁니다.

실행 API:

- `POST /api/admin/batches/price-snapshots/history-backfill?limit=500&days=45`

동작 방식:

- 우선 `FMP historical-price-eod/light`를 시도
- 현재 키/플랜에서 불가하면 `Yahoo chart`로 fallback
- 과거 가격 행을 채운 뒤
- 마지막에 `syncLatestSnapshotForStock`를 다시 호출해 오늘 스냅샷의 `change_rate_7d`, `change_rate_30d`를 재계산

## 자동 검증 시나리오

### 시나리오 A. 신규 포트폴리오 등록 즉시 적재

검증 포인트:

- 신규 종목 등록 시 `insertPortfolioItem` 호출
- 직후 `syncLatestSnapshotForStock(stockId)` 호출
- 뉴스 워밍업 호출
- 추천 재생성 호출

테스트:

- `backend/src/test/java/com/maemoji/backend/portfolio/service/PortfolioServiceTest.java`
- `createPortfolioItemTriggersImmediateSnapshotWarmup`

### 시나리오 B. 즉시 적재 실패해도 저장 흐름은 유지

검증 포인트:

- `syncLatestSnapshotForStock` 예외 발생 시에도
- 포트폴리오 저장은 실패하지 않음
- 뉴스 워밍업과 추천 재생성은 계속 시도

테스트:

- `backend/src/test/java/com/maemoji/backend/portfolio/service/PortfolioServiceTest.java`
- `createPortfolioItemContinuesEvenWhenImmediateSnapshotWarmupFails`

### 시나리오 C. 실제 외부 API 기반 라이브 적재

검증 포인트:

- 지정 종목에 대해 당일 스냅샷 생성
- `source = FINNHUB_FMP`
- 핵심 펀더멘털 최소 4개 이상 존재

테스트:

- `backend/src/test/java/com/maemoji/backend/stock/service/StockPriceSnapshotLiveValidationTest.java`
- `fillsCoreFundamentalsForNewlyTrackedStocks`

대표 검증군:

- `META`
- `MSFT`
- `JPM`

### 시나리오 C-2. 업종이 다른 신규 종목 다양성 검증

검증 포인트:

- 기술주 몇 개만 되는 것이 아니라
- 소비재, 에너지, 헬스케어, 반도체 같은 다른 업종도
- 같은 즉시 적재 로직으로 당일 핵심 펀더멘털이 채워진다.

테스트:

- `backend/src/test/java/com/maemoji/backend/stock/service/StockPriceSnapshotLiveValidationTest.java`
- `fillsCoreFundamentalsForDiverseNewlyTrackedStocks`

대표 검증군:

- `MCD`
- `COST`
- `NEE`
- `XOM`
- `KO`
- `AMD`
- `UNH`

실행 예시:

```powershell
$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
$env:LIVE_SNAPSHOT_VALIDATION='true'
$env:FINNHUB_API_KEY='...'
$env:FMP_API_KEY='...'
.\gradlew.bat test --tests com.maemoji.backend.stock.service.StockPriceSnapshotLiveValidationTest
```

### 시나리오 D. 샘플셋 백필 확인

검증 포인트:

- 대표 샘플셋 종목이 오늘 기준으로 모두 스냅샷을 갖는다.
- 이후 점수모델 튜닝 리포트 생성이 가능하다.

테스트:

- `StockPriceSnapshotLiveValidationTest.backfillsAdditionalSampleSetStocksForTuning`

## 운영 점검 SQL

```sql
select
    s.symbol,
    p.snapshot_date,
    p.source,
    p.eps_ttm,
    p.revenue_growth_yoy,
    p.operating_margin_ttm,
    p.roe_ttm,
    p.free_cash_flow_yield_ttm,
    p.income_quality_ttm
from stocks s
join stock_price_snapshots p on p.stock_id = s.id
where s.symbol in ('META', 'MSFT', 'JPM', 'PG', 'GS', 'HD', 'DELL', 'CAT', 'AVGO', 'PLTR', 'ARM')
order by s.symbol, p.snapshot_date desc;
```

## 판정 기준

새 종목 자동 적재가 정상이라고 보려면 아래를 만족해야 합니다.

- 포트폴리오 저장 직후 스냅샷 적재가 호출된다.
- 적재 실패 시에도 사용자 저장 흐름이 끊기지 않는다.
- 상세 진입 시 부족한 스냅샷은 자동 보강된다.
- 당일 스냅샷에 핵심 펀더멘털 4개 이상이 채워진다.
- 이 값으로 추천 엔진이 바로 계산 가능하다.
