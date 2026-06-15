# 미국 종목 마스터 동기화

## 구조

종목 검색은 외부 API를 직접 호출하지 않고 `stocks` 테이블만 조회합니다.

동기화 Provider 우선순위:

1. FMP `stock-list`, `etf-list`
2. Nasdaq Symbol Directory `nasdaqlisted.txt`, `otherlisted.txt`

FMP 키가 없거나 FMP가 오류를 반환하면 Nasdaq Provider로 자동 전환합니다.

## 환경변수

```text
FMP_API_KEY=발급받은_FMP_API_KEY
BATCH_API_SECRET=관리자_배치_호출용_비밀값
STOCK_MASTER_SYNC_ENABLED=false
```

GitHub Actions를 사용하면 Repository Secret에 `FMP_API_KEY`를 등록합니다.
FMP 키가 없어도 Nasdaq Provider로 동기화할 수 있습니다.

## 수동 실행

```http
POST /api/admin/stocks/sync
X-Batch-Secret: BATCH_API_SECRET 값
```

## 자동 실행

`.github/workflows/stock-master-sync.yml`이 매일 한국시간 오전 4시에
단발 배치를 실행합니다.

Render 서버 내부 스케줄을 사용할 경우에만
`STOCK_MASTER_SYNC_ENABLED=true`로 설정합니다. GitHub Actions와 서버 내부
스케줄 중 하나만 사용하는 것을 권장합니다.

## 검색

신규 형식:

```http
GET /api/stocks/search?query=애플
```

기존 Flutter 호환 형식:

```http
GET /api/stocks/search?keyword=애플
```

두 요청 모두 외부 API를 호출하지 않고 활성 종목을 DB에서 최대 20개 조회합니다.

## 기업 로고 캐시

- 기존 `logo_url`이 있으면 그대로 사용합니다.
- 로고가 없는 검색 결과는 FMP 정적 이미지 URL을 즉시 응답하고 백그라운드에서 한 번 확인합니다.
- 정상 이미지면 `logo_url`, `logo_status`, `logo_checked_at`을 DB에 저장합니다.
- 404 종목은 `MISSING`으로 기록해 30일 동안 다시 요청하지 않습니다.
- 네트워크 장애나 일시적인 FMP 오류는 `MISSING`으로 저장하지 않습니다.
