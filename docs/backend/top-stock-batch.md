# MaeMoJi 종목 마스터 배치 가이드

## 목적

MaeMoJi 종목 검색은 외부 API를 직접 치지 않고 `stocks` 테이블에서 바로 검색합니다.

- 검색 API: `stocks` 조회
- 외부 API: 종목 마스터 초기 적재와 보강 배치에서만 사용

## bootstrap

`bootstrap`은 검색용 종목 마스터를 처음 채우는 배치입니다.

동작 순서:

1. `Stock Analysis`의 공개 시총 랭킹 페이지를 조회
2. 페이지에 포함된 시총 상위 500개 종목 행을 파싱
3. 워런트, 권리주, 유닛, 테스트 종목 같은 검색 노이즈 종목 제외
4. 각 종목을 `Finnhub profile2`로 보강
5. `stocks` 테이블에 upsert

엔드포인트:

- `POST /api/admin/batches/top-stocks/bootstrap`
- `POST /api/admin/batches/top-stocks/bootstrap?limit=100`

필수 환경변수:

- `FINNHUB_API_KEY`

비고:

- 시총 상위 랭킹은 공개 페이지에서 가져오고, 로고와 회사명 보강은 Finnhub를 사용합니다.
- 기본적으로 상위 500개를 기준으로 채우도록 설계되어 있습니다.

## sync

`sync`는 이미 들어있는 종목 마스터를 최신 정보로 갱신하는 배치입니다.

동작 순서:

1. `stocks`의 활성 종목 조회
2. `finnhub_symbol` 기준으로 Finnhub `profile2` 조회
3. 영문명, 거래소 코드, 로고 URL 갱신

엔드포인트:

- `POST /api/admin/batches/top-stocks/sync`
- `POST /api/admin/batches/top-stocks/sync?limit=100`

필수 환경변수:

- `FINNHUB_API_KEY`

## 운영 권장 순서

1. `bootstrap`으로 초기 종목 마스터 적재
2. 앱 검색은 항상 `stocks`만 조회
3. 이후에는 `sync` 배치로 로고와 회사명 같은 메타데이터 보강
