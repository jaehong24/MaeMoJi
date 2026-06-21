# 종목 asset_type 점검/보정

## 목적

`stocks.asset_type`가 잘못 저장되면

- ETF인데 일반 주식처럼 추천을 타거나
- 일반 주식인데 ETF 준비중으로 보이거나
- 검색 결과에서 사용자가 혼동하는 문제

가 생길 수 있습니다.

MaeMoJi는 이를 막기 위해 `asset_type` 점검 쿼리와 보정 배치를 함께 둡니다.

## 점검 쿼리

파일:

- [stock-asset-type-audit.sql](C:/Users/icand/Documents/MaeMoJi/docs/backend/stock-asset-type-audit.sql)

찾는 대상:

- `market_type`는 ETF인데 `asset_type`이 `STOCK`
- 이름에 `ETF`, `ETN`, `INDEX FUND`, `TREASURY`, `BOND` 등이 있는데 `asset_type`이 `STOCK`
- 이름이 `COMMON STOCK`, `ORDINARY SHARES`인데 `asset_type`이 `ETF`

## 관리자 API

### 의심 종목 점검

```http
GET /api/admin/stocks/asset-type/audit?limit=100
X-Batch-Secret: BATCH_API_SECRET
```

### 보정 배치 실행

```http
POST /api/admin/stocks/asset-type/normalize
X-Batch-Secret: BATCH_API_SECRET
```

응답:

- `suspiciousCountBefore`
- `updatedCount`
- `suspiciousCountAfter`
- `suspiciousPreview`

## 자동 스케줄

기본값은 꺼져 있습니다.

```text
STOCK_ASSET_TYPE_BATCH_ENABLED=false
STOCK_ASSET_TYPE_BATCH_CRON=0 20 4 * * *
```

켜면 매일 오전 4시 20분에 asset_type 보정 스케줄이 실행됩니다.

## 현재 보정 규칙

`ETF`로 보정:

- `market_type`에 `ETF` 포함
- `name_en`에 `ETF`, `ETN`, `EXCHANGE TRADED`, `INDEX FUND`, `TREASURY`, `BOND` 포함
- `name_en`에 `TRUST`, `FUND`, `SHARES`가 있고 `COMMON STOCK`, `ORDINARY SHARES`, `PREFERRED STOCK`이 없을 때

그 외는 `STOCK`으로 보정합니다.

## 운영 권장

- 종목 마스터 동기화 후 `asset-type/normalize`를 이어서 한 번 실행
- ETF 관련 사용자 제보가 오면 `asset-type/audit`으로 먼저 확인
- ETF 전용 모델이 붙기 전까지는 `asset_type='ETF'` 정확도가 꽤 중요합니다
