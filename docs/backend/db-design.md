# MaeMoJi DB 설계안

## 목표

MaeMoJi는 단순 시세 조회 앱이 아니라, 사용자의 적립식 투자 종목과 추천 결과 이력을 저장하고 설명해야 하는 서비스입니다.
그래서 DB는 아래 4가지를 안정적으로 담아야 합니다.

1. 사용자 계정과 인증 정보
2. 사용자가 등록한 포트폴리오
3. 종목 기본 정보와 외부 API 연동 키
4. 추천 결과와 추천 근거 이력

## 권장 스택

- DBMS: PostgreSQL
- 백엔드: Spring Boot
- 데이터 접근: MyBatis

MyBatis를 기준으로 설계하는 이유는 추천 조회, 근거 조회, 이력 조회가 점점 복잡해질 가능성이 높기 때문입니다.

## 핵심 테이블 목록

### 1. `users`

서비스 사용자 기본 정보 테이블입니다.

주요 역할:
- 회원가입
- 로그인
- 사용자 식별

주요 컬럼:
- `id`
- `email`
- `password_hash`
- `nickname`
- `status`
- `created_at`
- `updated_at`

### 2. `stocks`

종목 마스터 테이블입니다.

주요 역할:
- 동일 종목 중복 등록 방지
- 외부 API 종목 식별자 저장
- 회사명/티커/거래소/로고 관리

주요 컬럼:
- `id`
- `ticker`
- `exchange_code`
- `finnhub_symbol`
- `name_ko`
- `name_en`
- `logo_url`
- `market_type`
- `is_active`
- `created_at`
- `updated_at`

설명:
- `ticker`만으로는 거래소 중복 가능성이 있으므로 `ticker + exchange_code` 유니크를 권장합니다.
- `name_ko`는 우리 서비스 표시용 이름입니다.
- `name_en`은 Finnhub 원본명을 저장합니다.

### 3. `portfolio_items`

사용자가 실제로 적립 중인 종목을 저장하는 핵심 테이블입니다.

주요 역할:
- 포트폴리오 등록
- 매일모으기 금액 저장
- 보유 수량, 시작일, 메모 저장

주요 컬럼:
- `id`
- `user_id`
- `stock_id`
- `daily_invest_amount`
- `holding_quantity`
- `investment_start_date`
- `memo`
- `is_active`
- `created_at`
- `updated_at`

설명:
- 한 사용자가 같은 종목을 중복 등록하지 않게 `user_id + stock_id` 유니크를 권장합니다.
- 삭제는 물리 삭제보다 `is_active = false` 같은 소프트 삭제가 안전합니다.

### 4. `recommendations`

추천 엔진의 최종 결과를 저장하는 테이블입니다.

주요 역할:
- 종목별 최신 추천 저장
- 추천 이력 추적
- 오늘 추천과 과거 추천 비교

주요 컬럼:
- `id`
- `user_id`
- `portfolio_item_id`
- `recommendation_date`
- `recommendation_status`
- `engine_score`
- `confidence_score`
- `current_amount`
- `recommended_amount`
- `final_note`
- `engine_version`
- `created_at`

설명:
- `recommendation_status`는 `INCREASE`, `MAINTAIN`, `REDUCE`, `STOP` 네 값만 사용합니다.
- 하루에 한 종목당 한 번만 생성하려면 `portfolio_item_id + recommendation_date` 유니크를 고려할 수 있습니다.

### 5. `recommendation_evidence`

추천 근거 세부 항목을 저장하는 테이블입니다.

주요 역할:
- 주가 분석
- 뉴스 분석
- 기관 수급 분석
- 실적 분석
- 밸류에이션 분석
- AI 최종 의견

주요 컬럼:
- `id`
- `recommendation_id`
- `evidence_type`
- `title`
- `body`
- `score_impact`
- `display_order`
- `created_at`

설명:
- 한 추천에 여러 개의 근거가 붙는 1:N 구조입니다.
- 화면 렌더링 순서를 위해 `display_order`를 두는 것이 좋습니다.

### 6. `stock_price_snapshots`

추천 당시 참고한 가격/등락률 데이터를 저장하는 스냅샷 테이블입니다.

주요 역할:
- 추천 생성 시 사용한 가격 근거 보존
- 과거 추천 재현 가능성 확보

주요 컬럼:
- `id`
- `stock_id`
- `snapshot_date`
- `current_price`
- `change_rate_1d`
- `change_rate_30d`
- `market_cap`
- `per_value`
- `source`
- `created_at`

설명:
- 추천 화면에서 “최근 30일 +35% 상승” 같은 문구의 원본 근거로 사용 가능합니다.

### 7. `news_analysis_cache`

뉴스 원문을 매번 다시 해석하지 않도록 저장하는 캐시/이력 테이블입니다.

주요 역할:
- Finnhub 뉴스 수집 결과 저장
- Gemini 분석 결과 캐시
- 긍정/부정/중립 점수 보관

주요 컬럼:
- `id`
- `stock_id`
- `news_published_at`
- `headline`
- `summary`
- `source_name`
- `news_url`
- `sentiment_label`
- `sentiment_score`
- `llm_model`
- `created_at`

설명:
- MVP에서는 단순 캐시로 시작하고, 이후 추천 엔진 입력 데이터로 확장하면 됩니다.

## 테이블 관계

```text
users 1 --- N portfolio_items
stocks 1 --- N portfolio_items
portfolio_items 1 --- N recommendations
recommendations 1 --- N recommendation_evidence
stocks 1 --- N stock_price_snapshots
stocks 1 --- N news_analysis_cache
```

## 추천 상태 코드 제안

`recommendations.recommendation_status`

- `INCREASE`
- `MAINTAIN`
- `REDUCE`
- `STOP`

## 추천 근거 타입 제안

`recommendation_evidence.evidence_type`

- `PRICE`
- `NEWS`
- `INSTITUTION`
- `EARNINGS`
- `VALUATION`
- `MARKET`
- `AI_NOTE`

## 인덱스 권장안

### `users`
- `uk_users_email (email)`

### `stocks`
- `uk_stocks_ticker_exchange (ticker, exchange_code)`
- `idx_stocks_name_ko (name_ko)`
- `idx_stocks_name_en (name_en)`

### `portfolio_items`
- `uk_portfolio_items_user_stock (user_id, stock_id)`
- `idx_portfolio_items_user_id (user_id)`

### `recommendations`
- `idx_recommendations_portfolio_item_id (portfolio_item_id)`
- `idx_recommendations_user_id_date (user_id, recommendation_date desc)`

### `recommendation_evidence`
- `idx_recommendation_evidence_recommendation_id (recommendation_id)`

### `stock_price_snapshots`
- `idx_stock_price_snapshots_stock_date (stock_id, snapshot_date desc)`

### `news_analysis_cache`
- `idx_news_analysis_cache_stock_published_at (stock_id, news_published_at desc)`

## 초기 API와의 대응

### 종목 검색

- 검색어 입력
- Finnhub `/search`
- 종목 없으면 `stocks`에 upsert
- 포트폴리오 등록 시 `portfolio_items` 생성

### 포트폴리오 등록

- 사용자 선택 종목
- 적립 금액, 보유 수량, 시작일, 메모 저장

### 추천 생성

- `portfolio_items` 조회
- 외부 데이터 수집
- 추천 엔진 계산
- `recommendations` 저장
- `recommendation_evidence` 저장

### 추천 화면 조회

- 최신 `recommendations`
- 상태/점수/추천금액
- `recommendation_evidence` 조합 조회

## MVP에서 우선 만들 테이블

1. `users`
2. `stocks`
3. `portfolio_items`
4. `recommendations`
5. `recommendation_evidence`

아래는 2차 확장으로 두어도 됩니다.

- `stock_price_snapshots`
- `news_analysis_cache`

## 추천 결론

DB는 먼저 아래 순서로 진행하는 것이 좋습니다.

1. 핵심 5개 테이블 생성
2. MyBatis 기준 Mapper 구조 설계
3. 포트폴리오 등록 API
4. 추천 조회 API
5. 추천 생성 배치/서비스
