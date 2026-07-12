# MaeMoJi Phase 2.1 설계안

## 1. 목표

MaeMoJi Phase 2.1의 목표는 매모지를 단순 종목 추천 앱에서
`실계좌 기반 포트폴리오 분석 서비스`로 확장하는 것이다.

이번 단계에서는 커뮤니티 전체를 한 번에 여는 것이 아니라,
아래 4가지를 먼저 안정적으로 완성하는 데 집중한다.

1. 토스증권 Open API 연결 등록
2. 연동 가능한 계좌 선택
3. 보유 종목 동기화
4. 실계좌 인증 배지와 공개 프로필 기반 마련

즉 Phase 2.1은 커뮤니티의 시작점이 아니라,
커뮤니티가 신뢰를 가질 수 있게 만드는 `데이터 인증 기반` 단계다.

---

## 2. 현재 전제

### 2.1 토스 Open API 인증 전제

현재 공식 문서 기준으로 토스증권 Open API는
일반적인 사용자 브라우저 로그인형 OAuth보다
`OAuth 2.0 Client Credentials` 기반에 가깝다.

따라서 Phase 2.1의 실제 연동 플로우는 아래처럼 본다.

1. 사용자가 토스증권에서 발급받은 `client_id`, `client_secret` 준비
2. MaeMoJi 설정 화면에서 연동 정보 등록
3. 서버가 토큰 발급 테스트
4. 계좌 목록 조회
5. 사용자가 연결할 계좌 선택
6. 포트폴리오 동기화

즉 기획 문구의 `OAuth Authentication`은 구현 단계에서는
`토스 Open API 연결 등록 및 검증`으로 해석하는 것이 맞다.

### 2.2 공개 정책 전제

MaeMoJi는 실계좌 인증 여부는 공개할 수 있지만,
민감한 자산 총액은 기본적으로 공개하지 않는다.

Phase 2.1 기본 정책:

- 공개 가능:
  - 종목 심볼
  - 종목명
  - 보유 수량
  - 평균 매수가
  - 현재가
  - 수익률
  - 비중
  - 실계좌 인증 여부
- 기본 비공개:
  - 계좌 총 평가금액
  - 현금 잔고
  - 원금
  - 계좌번호류 식별값

---

## 3. Phase 2.1 범위

### 3.1 이번 단계에 포함

1. 토스 연결 등록/수정/해제
2. 연결 가능한 계좌 목록 조회
3. 대표 연동 계좌 선택
4. 보유 종목 동기화
5. 매모지 포트폴리오와 자동 매핑
6. 실계좌 인증 배지 발급 조건 반영
7. 공개 프로필 최소 스키마 마련
8. 포트폴리오 공개 범위 설정

### 3.2 이번 단계에서 제외

1. 게시글 작성
2. 좋아요/댓글/팔로우
3. 랭킹 시스템
4. 주간 포트폴리오 스냅샷 자동 공개
5. 주문 실행 기능
6. 수익률 랭킹 공개

이번 단계는 `실거래 연동 기반 준비 단계`로 제한한다.

---

## 4. 사용자 흐름

### 4.1 연결 플로우

1. 설정 화면 진입
2. `토스증권 연결` 선택
3. `client_id`, `client_secret` 입력
4. 연결 테스트
5. 토큰 발급 성공 확인
6. 계좌 목록 조회
7. 사용자가 대표 계좌 선택
8. 보유 종목 동기화
9. 매모지 포트폴리오 생성 또는 기존 포트폴리오와 매핑
10. `실계좌 인증 투자자` 배지 활성화

### 4.2 동기화 후 경험

동기화가 성공하면 사용자는 아래를 보게 된다.

- 연동 상태: 연결됨
- 대표 계좌: 선택된 계좌 1개
- 실계좌 인증: 활성
- 연동 종목 수
- 마지막 동기화 시각
- 공개 범위 설정

### 4.3 포트폴리오 매핑 정책

토스에서 불러온 보유 종목을 매모지 내부 `portfolio_items`와 연결하는 방식은
단순 덮어쓰기가 아니라 아래 정책으로 간다.

1. 같은 사용자 + 같은 stock_id가 이미 있으면 기존 포트폴리오 항목에 연결
2. 기존 항목이 없으면 새 포트폴리오 항목 생성
3. 사용자가 수동 등록했던 `daily_invest_amount`, `memo`, `investment_start_date`는 보존
4. 토스에서 온 `quantity`, `avg_price`, `current_price`, `profit_rate`, `weight_percent`는 별도 동기화 데이터로 저장

즉 `내가 수동으로 만든 투자 계획 데이터`와
`실계좌에서 가져온 현재 보유 데이터`를 분리 저장해야 한다.

---

## 5. 핵심 도메인 설계

Phase 2.1에서는 아래 5개 도메인이 핵심이다.

1. 토스 연결 정보
2. 토스 계좌
3. 토스 보유 종목 스냅샷
4. 매모지 포트폴리오 매핑
5. 인증/공개 프로필

---

## 6. DB 설계 초안

## 6.1 기존 테이블 활용

### `users`

기존 사용자 테이블을 그대로 활용하되, 아래 컬럼 확장을 권장한다.

- `is_verified_investor boolean not null default false`
- `verified_investor_at timestamptz null`
- `default_portfolio_visibility varchar(20) not null default 'PRIVATE'`

### `portfolio_items`

기존 포트폴리오 테이블은 유지한다.
다만 실계좌 동기화 기반 연결 여부를 알기 위해 아래 컬럼 확장을 권장한다.

- `source_type varchar(20) not null default 'MANUAL'`
- `source_connection_id bigint null`
- `linked_broker_position boolean not null default false`

설명:

- `source_type`: `MANUAL`, `TOSS_SYNC`
- `linked_broker_position`: 현재 실계좌 보유 정보와 연결 중인지 여부

---

## 6.2 신규 테이블 1: `toss_connections`

사용자의 토스 Open API 연결 설정을 저장한다.

### 역할

- 사용자별 토스 연동 자격정보 관리
- 연결 상태 추적
- 대표 연결 여부 추적

### 컬럼 초안

- `id`
- `user_id`
- `connection_name`
- `client_id`
- `client_secret_encrypted`
- `client_secret_masked`
- `status`
- `last_token_issued_at`
- `last_sync_at`
- `last_sync_status`
- `last_sync_error_code`
- `last_sync_error_message`
- `is_primary`
- `created_at`
- `updated_at`

### 제약조건

- `user_id not null`
- `client_id not null`
- `status not null`
- `is_primary default false`

### status 값

- `ACTIVE`
- `INVALID_CREDENTIAL`
- `DISCONNECTED`
- `SYNC_FAILED`

### 보안 원칙

- `client_secret` 원문 저장 금지
- DB에는 반드시 암호화 저장
- 화면에는 `client_secret_masked`만 표시

---

## 6.3 신규 테이블 2: `toss_accounts`

토스 계좌 목록과 사용자가 선택한 대표 연동 계좌를 저장한다.

### 역할

- 연결별 계좌 캐시
- 대표 분석 계좌 선택
- 동기화 대상 계좌 식별

### 컬럼 초안

- `id`
- `connection_id`
- `account_seq`
- `account_name`
- `account_type`
- `status`
- `is_selected`
- `is_active`
- `last_synced_at`
- `created_at`
- `updated_at`

### 제약조건

- `connection_id not null`
- `account_seq not null`
- `unique(connection_id, account_seq)`

### 정책

- 사용자에게는 계좌 실번호가 아니라 `계좌 별칭` 수준만 노출
- 기본적으로 한 사용자는 Phase 2.1에서 `대표 계좌 1개`만 선택 가능

---

## 6.4 신규 테이블 3: `toss_portfolio_snapshots`

토스 계좌에서 가져온 보유 종목 현재 상태를 저장한다.

### 역할

- 동기화 시점의 실계좌 보유 데이터 저장
- 향후 주간 스냅샷, 신규 편입/제외 분석 기반

### 컬럼 초안

- `id`
- `connection_id`
- `account_id`
- `sync_batch_id`
- `stock_id`
- `symbol`
- `stock_name`
- `market_country`
- `currency`
- `quantity`
- `average_purchase_price`
- `current_price`
- `profit_rate`
- `weight_percent`
- `is_closed_position`
- `captured_at`
- `created_at`

### 제약조건

- `account_id not null`
- `stock_id null 가능`
- `symbol not null`
- `captured_at not null`

### 설계 포인트

- `stock_id` 매핑 실패 가능성을 고려해 `symbol`, `stock_name` 원문도 저장
- 총 자산 금액 저장은 1차 범위에서 제외 가능
- 단, `weight_percent` 계산 결과는 저장

---

## 6.5 신규 테이블 4: `toss_portfolio_mappings`

토스 보유 종목과 매모지 포트폴리오 항목을 연결한다.

### 역할

- 실계좌 종목과 매모지 포트폴리오 간 1:1 연결 유지
- 동기화 시 중복 생성 방지

### 컬럼 초안

- `id`
- `user_id`
- `account_id`
- `stock_id`
- `portfolio_item_id`
- `latest_snapshot_id`
- `sync_status`
- `created_at`
- `updated_at`

### 제약조건

- `unique(user_id, account_id, stock_id)`
- `portfolio_item_id not null`

### sync_status 값

- `LINKED`
- `UNMATCHED`
- `INACTIVE`

---

## 6.6 신규 테이블 5: `portfolio_profile_settings`

커뮤니티 오픈 전 미리 공개 범위 설정을 저장한다.

### 역할

- 공개 프로필 정책 저장
- 실계좌 인증 이후 공개 범위 제어

### 컬럼 초안

- `id`
- `user_id`
- `profile_visibility`
- `show_profit_rate`
- `show_holdings`
- `show_badges`
- `show_weight_percent`
- `created_at`
- `updated_at`

### 기본값

- `profile_visibility = 'PRIVATE'`
- `show_profit_rate = false`
- `show_holdings = true`
- `show_badges = true`
- `show_weight_percent = false`

---

## 6.7 신규 테이블 6: `portfolio_sync_jobs`

동기화 실행 이력을 저장한다.

### 역할

- 수동 동기화/자동 동기화 추적
- 실패 원인 분석
- 운영 모니터링

### 컬럼 초안

- `id`
- `user_id`
- `connection_id`
- `account_id`
- `job_type`
- `job_status`
- `started_at`
- `finished_at`
- `synced_stock_count`
- `created_portfolio_item_count`
- `updated_portfolio_item_count`
- `failed_stock_count`
- `error_code`
- `error_message`
- `created_at`

### job_type 값

- `MANUAL_SYNC`
- `AUTO_SYNC`
- `REPAIR_SYNC`

### job_status 값

- `RUNNING`
- `SUCCESS`
- `PARTIAL_SUCCESS`
- `FAILED`

---

## 7. 추천 엔진과의 연결 원칙

Phase 2.1에서 가장 중요한 점은
토스 포트폴리오를 불러오는 것이 곧 추천 엔진과 끊기지 않아야 한다는 점이다.

### 원칙

1. 추천 계산 기준 종목은 계속 `portfolio_items`
2. 토스 데이터는 `portfolio_items`를 대체하지 않고 보강
3. 실계좌 동기화 후 추천 재생성 이벤트 발생
4. 추천 근거에 `실보유 수량`, `평단 대비 손익`, `보유 비중`을 나중에 추가할 수 있게 구조를 열어둠

### Phase 2.1 연결 수준

- 동기화 성공 후 포트폴리오 종목 추천 재생성 트리거
- 상세 화면에서 `실계좌 연동 종목` 표시는 가능
- 아직 추천 점수에 실현손익/총자산 비중을 강하게 반영하지는 않음

즉 이번 단계는 `데이터 연결`까지,
점수 모델 본격 반영은 Phase 2.2 이후로 넘긴다.

---

## 8. API 명세 초안

모든 API 경로는 현재 매모지 REST 스타일을 따라 `/api/...` 기준으로 제안한다.

## 8.1 토스 연결 등록

### `POST /api/integrations/toss/connections`

### 목적

- 사용자 토스 연결 생성
- 연결 테스트 포함

### 요청 예시

```json
{
  "connectionName": "내 토스증권",
  "clientId": "c_xxx",
  "clientSecret": "s_xxx"
}
```

### 응답 예시

```json
{
  "connectionId": 1,
  "status": "ACTIVE",
  "message": "토스증권 연결이 등록되었습니다."
}
```

### 실패 케이스

- 잘못된 자격정보
- 토큰 발급 실패
- 이미 동일 연결 존재

---

## 8.2 토스 연결 상태 조회

### `GET /api/integrations/toss/connections/me`

### 목적

- 현재 사용자의 연결 목록 조회
- 마지막 동기화 상태 확인

### 응답 필드

- `connectionId`
- `connectionName`
- `status`
- `clientIdMasked`
- `isPrimary`
- `lastSyncAt`
- `lastSyncStatus`

---

## 8.3 토스 연결 수정

### `PUT /api/integrations/toss/connections/{connectionId}`

### 목적

- 자격정보 갱신
- 연결명 수정

### 정책

- 수정 시 즉시 연결 테스트 수행
- 성공해야 `ACTIVE` 전환

---

## 8.4 토스 연결 해제

### `DELETE /api/integrations/toss/connections/{connectionId}`

### 목적

- 토스 연결 비활성화

### 정책

- 물리 삭제 대신 `DISCONNECTED`
- 기존 포트폴리오는 유지
- 실계좌 인증 배지는 비활성화 가능

---

## 8.5 계좌 목록 조회

### `GET /api/integrations/toss/connections/{connectionId}/accounts`

### 목적

- 토스 계좌 목록 조회 후 사용자에게 선택 제공

### 응답 예시

```json
[
  {
    "accountId": 11,
    "accountSeq": 1,
    "accountName": "종합매매",
    "status": "ACTIVE",
    "isSelected": true
  }
]
```

---

## 8.6 대표 계좌 선택

### `POST /api/integrations/toss/accounts/{accountId}/select`

### 목적

- 대표 분석 계좌 지정

### 정책

- 사용자당 1개만 `isSelected = true`

---

## 8.7 보유 종목 미리보기

### `GET /api/integrations/toss/accounts/{accountId}/holdings/preview`

### 목적

- 동기화 전 사용자가 어떤 종목이 들어오는지 확인

### 응답 필드

- `symbol`
- `stockName`
- `quantity`
- `averagePurchasePrice`
- `currentPrice`
- `profitRate`
- `weightPercent`
- `matchedStockId`
- `matchedPortfolioItemId`
- `willCreatePortfolioItem`

### 의미

- 실제 저장 전에 `무엇이 새로 생성되고 무엇이 연결되는지` 보여준다

---

## 8.8 보유 종목 동기화 실행

### `POST /api/integrations/toss/accounts/{accountId}/sync`

### 목적

- 토스 보유 종목을 매모지 포트폴리오로 반영

### 요청 예시

```json
{
  "syncMode": "MERGE",
  "createMissingPortfolioItems": true
}
```

### syncMode 초안

- `MERGE`: 기존 포트폴리오 유지 + 신규 종목 추가
- `REFRESH`: 연결된 항목 기준 최신화

### 응답 예시

```json
{
  "jobId": 101,
  "status": "SUCCESS",
  "syncedStockCount": 12,
  "createdPortfolioItemCount": 4,
  "updatedPortfolioItemCount": 8,
  "verifiedInvestor": true
}
```

---

## 8.9 동기화 결과 조회

### `GET /api/integrations/toss/sync-jobs/{jobId}`

### 목적

- 동기화 완료 결과 및 실패 항목 확인

### 응답 필드

- `jobId`
- `status`
- `startedAt`
- `finishedAt`
- `syncedStockCount`
- `createdPortfolioItemCount`
- `updatedPortfolioItemCount`
- `failedStockCount`
- `errorCode`
- `errorMessage`

---

## 8.10 실계좌 인증 상태 조회

### `GET /api/profile/verification`

### 목적

- 실계좌 인증 배지 노출용 상태 조회

### 응답 예시

```json
{
  "verifiedInvestor": true,
  "verifiedAt": "2026-07-05T10:15:00+09:00",
  "provider": "TOSS_SECURITIES"
}
```

---

## 8.11 공개 프로필 설정 조회/수정

### `GET /api/profile/portfolio-settings`

### `PUT /api/profile/portfolio-settings`

### 목적

- 공개 범위 설정 저장

### 요청 예시

```json
{
  "profileVisibility": "PUBLIC",
  "showProfitRate": true,
  "showHoldings": true,
  "showBadges": true,
  "showWeightPercent": false
}
```

---

## 8.12 공개 포트폴리오 프로필 조회

### `GET /api/community/profiles/{userId}`

### 목적

- 향후 커뮤니티에서 사용할 공개 프로필 기본 조회

### Phase 2.1 응답 범위

- `nickname`
- `verifiedInvestor`
- `badges`
- `recentProfitRate` 표시 여부 반영
- `topHoldings`

---

## 9. 서비스 로직 초안

## 9.1 연결 등록 로직

1. 사용자 인증 확인
2. `client_id`, `client_secret` 입력 검증
3. 토스 토큰 발급 API 호출
4. 성공 시 암호화 저장
5. 계좌 목록 1회 조회 후 캐시 저장

## 9.2 동기화 로직

1. 대표 계좌 확인
2. 토스 `holdings` 조회
3. 종목별 `stocks` 매핑
4. 기존 `portfolio_items` 매핑
5. 누락 종목은 신규 생성
6. `toss_portfolio_snapshots` 저장
7. `toss_portfolio_mappings` 갱신
8. `portfolio_sync_jobs` 결과 기록
9. 추천 재생성 이벤트 발행
10. 실계좌 인증 상태 갱신

## 9.3 인증 배지 발급 조건

아래 두 조건을 만족하면 `verified investor`를 true 처리한다.

1. 유효한 토스 연결 존재
2. 최근 동기화 성공 이력 존재

권장 조건:

- 최근 30일 이내 성공 동기화 1회 이상

---

## 10. 백엔드 패키지 구조 제안

현재 매모지 구조에 맞춰 아래 패키지를 권장한다.

### `backend/src/main/java/com/maemoji/backend/toss`

하위 패키지:

- `controller`
- `service`
- `dto`
- `mapper`
- `domain`
- `client`
- `config`

### 주요 클래스 초안

- `TossConnectionController`
- `TossPortfolioSyncController`
- `TossProfileController`
- `TossAuthClient`
- `TossAccountClient`
- `TossHoldingsClient`
- `TossIntegrationService`
- `TossPortfolioSyncService`
- `TossVerificationService`

---

## 11. 보안 설계

## 11.1 저장 금지 데이터

아래 값은 저장하지 않거나 최소화한다.

- 계좌 총 평가금액
- 현금 잔고
- 원금
- 토스 응답 전문 원문

## 11.2 암호화 대상

- `client_secret`

## 11.3 로그 정책

로그에 아래 값은 남기지 않는다.

- `client_secret`
- access token
- 계좌 식별 전체값

## 11.4 토큰 정책

- 토큰은 매 요청 시 재발급하거나 짧은 캐시로 사용
- 장기 저장하지 않음
- 발급 실패 시 연결 상태 갱신

---

## 12. 운영 정책

## 12.1 자동 동기화

Phase 2.1에서는 기본적으로 수동 동기화를 우선한다.

이유:

- 사용자가 언제 갱신했는지 인지하기 쉽다
- 초기 API 비용과 실패 케이스를 통제하기 쉽다
- 계좌 연동 오류 대응이 간단하다

권장:

- 사용자가 설정에서 `지금 동기화` 실행
- 추후 하루 1회 자동 동기화 옵션 추가

## 12.2 실패 처리

동기화 실패 시:

- 포트폴리오 원본 유지
- 기존 추천 데이터 유지
- 연결 상태만 `SYNC_FAILED`로 반영
- 사용자에게 마지막 성공 시각 표시

---

## 13. Phase 2.1 구현 우선순위

## 13.1 1차 구현

1. DB 스키마 추가
2. 토스 연결 등록 API
3. 계좌 목록 조회 API
4. 대표 계좌 선택 API
5. 보유 종목 미리보기 API
6. 동기화 실행 API

## 13.2 2차 구현

1. 실계좌 인증 배지 상태 API
2. 공개 범위 설정 API
3. 추천 재생성 연결
4. 포트폴리오 화면 연동 상태 표시

## 13.3 3차 구현

1. 공개 프로필 조회 API
2. 주간 포트폴리오 스냅샷 기반 마련
3. 커뮤니티 피드 연결 준비

---

## 14. 화면 연계 메모

프론트에서 최소한 아래 화면이 필요하다.

1. 설정 > 토스증권 연결
2. 연결 정보 입력
3. 계좌 선택
4. 동기화 미리보기
5. 동기화 결과
6. 공개 범위 설정

중요:

- 연결 실패 이유는 사용자용 한글 문구로 보여줘야 한다
- 민감 정보 비공개 정책은 화면에서 명확히 안내해야 한다
- 실계좌 인증 배지는 `동기화 성공 후`에만 보여야 한다

---

## 15. 한 줄 결론

Phase 2.1의 핵심은 `토스 실계좌 연결 -> 보유 종목 동기화 -> 매모지 포트폴리오 연결 -> 실계좌 인증 배지`다.

이 단계를 잘 만들면,
이후의 커뮤니티, 공개 포트폴리오, 투자자 배지, AI 포트폴리오 분석은
신뢰 가능한 실데이터 위에서 자연스럽게 확장할 수 있다.
