# MaeMoJi 추천 점수모델 V4 설계 초안

## 1. 목적

MaeMoJi 추천 엔진을 현재의 `가격 + 뉴스` 중심 V3에서,
여러 근거를 함께 반영하는 멀티 팩터 추천 모델로 확장한다.

이번 V4의 목표는 아래 4가지다.

1. 뉴스만으로 추천이 흔들리지 않게 한다.
2. 가격 흐름, 뉴스, 기초 체력, 사용자 상황을 함께 본다.
3. 각 점수에 설명 가능한 근거를 남긴다.
4. 사용자 수가 늘어나도 비용이 종목 수에 가깝게 증가하도록 설계한다.

## 2. V3 한계

현재 V3는 아래 2개 축으로만 계산한다.

- 가격 점수: 최근 30일 수익률
- 뉴스 점수: Gemini 기반 뉴스 감성 점수

이 방식은 단순하고 빠르지만 한계가 있다.

- 좋은 기업인지, 과열된 기업인지 구조적으로 구분하기 어렵다.
- 최근 가격 움직임이 추세인지 과열인지 해석이 단순하다.
- 사용자 보유 상황과 매일 모으기 부담이 약하게 반영된다.
- 추천 근거가 2개 축에 과도하게 몰린다.

## 3. V4 설계 원칙

- 최종 점수는 `0~100` 범위로 유지한다.
- 추천 상태는 `INCREASE / MAINTAIN / REDUCE / STOP` 4단계로 유지한다.
- 각 팩터는 점수, 가중치, 설명 문구를 함께 가진다.
- 없는 데이터는 억지 중립 점수를 주지 않고, 사용 가능한 팩터만 반영한다.
- 강한 악재는 최종 점수를 덮어쓸 수 있는 override 규칙으로 별도 관리한다.
- 사용자별 추천 해석과 종목 자체 평가를 분리한다.

## 4. 팩터 구조

V4는 아래 5개 팩터를 기본 축으로 사용한다.

| 팩터 | 의미 | 점수 범위 | 기본 가중치 | 주요 데이터 소스 |
|---|---|---:|---:|---|
| `PRICE_MOMENTUM` | 최근 7일, 30일 흐름과 과열 여부 | 0~100 | 25 | `stock_price_snapshots` |
| `PRICE_STABILITY` | 변동성, 급락 위험, 하방 스트레스 | 0~100 | 15 | `stock_price_snapshots` |
| `NEWS_SENTIMENT` | 뉴스 감성, 관련성, 영향도, 최신성 | 0~100 | 25 | `news_analysis_cache`, Gemini |
| `FUNDAMENTAL_QUALITY` | 시총, 밸류에이션, 성장성 등 기초 체력 | 0~100 | 20 | 종목 메타, 지표 배치 |
| `USER_FIT` | 사용자의 보유 상황과 투자 부담 적합성 | 0~100 | 15 | `portfolio_items` |

총 가중치 기준값은 100이다.

## 5. 팩터별 점수 초안

### 5.1 PRICE_MOMENTUM

목적:
- 지금이 모으기 좋은 구간인지 본다.
- 단기 급등으로 과열된 구간인지 판별한다.

주요 입력:
- `change_rate_7d`
- `change_rate_30d`
- 30일 기준 최근 최고점 대비 이격도

초안 규칙:
- 7일, 30일 흐름이 모두 완만한 플러스면 가점
- 30일 급등 `+20%` 이상이면 과열 감점
- 30일 급락 `-35%` 이하면 위험 경보
- 7일 급락인데 30일도 약세면 추가 감점

### 5.2 PRICE_STABILITY

목적:
- 수익률 자체보다 변동 위험을 따로 본다.

주요 입력:
- 7일, 30일 변동폭
- 급락 일수
- 연속 하락 여부

초안 규칙:
- 변동성이 낮고 하방이 제한적이면 가점
- 최근 급락 빈도가 높으면 감점
- 급락과 악재 뉴스가 동시에 발생하면 override 후보로 전달

### 5.3 NEWS_SENTIMENT

목적:
- 종목과 직접 관련 있는 최신 뉴스의 방향성을 반영한다.

주요 입력:
- Gemini 기사별 감성 점수
- 관련성 점수
- 영향도
- 최신성 가중치
- 강한 악재 override

활용 구조:
- `news_analysis_cache`
- 기사별 `sentiment_score`, `relevance_score`, `impact_level`
- 종목별 집계 점수

초안 규칙:
- 관련성 0인 뉴스는 제외
- 기사 수가 적으면 신뢰도는 낮춘다
- 긍정과 부정이 혼재하면 중립 쪽으로 수렴시킨다

### 5.4 FUNDAMENTAL_QUALITY

목적:
- 단기 뉴스가 아니라 기업 자체의 체력을 반영한다.

1차 입력 우선순위:
1. 시총
2. PER
3. EPS
4. 매출 성장률
5. 영업이익률
6. 업종 평균 대비 밸류에이션

초안 규칙:
- 대형 우량주에 기본 안정 가점
- 적정 밸류에이션이면 가점
- 과도한 고평가 구간은 감점
- 적자 지속, 구조적 둔화는 감점

비고:
- V4 1차 구현은 `market_cap`, `per_value` 중심으로 시작한다.
- EPS, 성장률, 수익성 지표는 V4 구조가 안정된 뒤 확장한다.

### 5.5 USER_FIT

목적:
- 같은 종목이어도 사용자 상황에 따라 추천을 다르게 만든다.

주요 입력:
- `daily_invest_amount`
- `holding_quantity`
- `investment_start_date`
- `memo`

초안 규칙:
- 이미 높은 금액을 모으는 중이면 `INCREASE`를 쉽게 주지 않는다
- 투자 시작 직후면 보수적으로 본다
- 메모에 리스크 키워드가 있으면 감점 가능
- 장기 보유 중이고 과도한 부담이 없으면 소폭 가점

## 6. 최종 계산식 초안

```text
rawScore =
  sum(factorScore * appliedWeight)
  / sum(appliedWeight)
```

```text
finalScore =
  rawScore
  + crossFactorAdjustment
  + userAdjustment
```

설명:
- `appliedWeight`는 실제 데이터가 있는 팩터만 반영한다.
- `crossFactorAdjustment`는 팩터 간 조합에 따른 보정값이다.
- `userAdjustment`는 사용자 부담도, 이미 높은 투자금 등 사용자 맥락 보정이다.

## 7. 상태 구간 초안

| 최종 점수 | 상태 |
|---|---|
| `85+` | `INCREASE` |
| `60~84` | `MAINTAIN` |
| `35~59` | `REDUCE` |
| `<35` | `STOP` |

보조 규칙:
- `INCREASE`는 점수만 높다고 주지 않는다.
- 최소 2개 이상 핵심 팩터가 양호해야 한다.
- 강한 악재가 있으면 `INCREASE`를 차단한다.

## 8. 신뢰도 초안

신뢰도는 추천 점수와 분리한다.

기본 시작값:
- `45`

가점 예시:

| 조건 | 가점 |
|---|---:|
| 현재가 있음 | +5 |
| 30일 가격 데이터 있음 | +10 |
| 관련 뉴스 2건 이상 | +8 |
| 평균 관련성 80 이상 | +8 |
| 기초체력 데이터 있음 | +10 |
| 투자 시작일 있음 | +4 |
| 메모 있음 | +3 |

제한:
- 최대 `95`
- 기사 수가 1건뿐이면 상한을 `75`로 제한 가능

## 9. 강한 악재 override 규칙

아래 케이스는 일반 가중치 계산보다 우선한다.

- 회계 부정
- 상장폐지 위험
- 파산
- SEC 조사
- 가이던스 대폭 하향
- 30일 급락 + 강한 부정 뉴스 동시 발생

초안 규칙:
- `hardStopRisk`면 최종 점수 상한 `30`
- `hardNegativeNews`면 최종 점수 상한 `45`

## 10. 교차 팩터 보정 초안

단일 팩터만 좋다고 추천이 과도하게 올라가지 않도록 교차 보정을 둔다.

예시:

- 가격은 강하지만 뉴스와 기초 체력이 약하면 `-5 ~ -12`
- 뉴스는 강하지만 가격이 과열이면 `-4 ~ -10`
- 가격 안정 + 뉴스 양호 + 기초 체력 양호면 `+4 ~ +8`
- 사용자 투자 부담이 이미 높으면 `-3 ~ -8`

## 11. 투자성향 레이어 확장 계획

### 11.1 왜 별도 레이어로 두는가

투자성향은 종목 자체 점수와 분리해야 한다.

같은 종목이라도
- 안정형 사용자에게는 `REDUCE`
- 성장형 사용자에게는 `MAINTAIN`
- 위험형 사용자에게는 `INCREASE`

처럼 해석이 달라질 수 있기 때문이다.

즉 V4 본체는 먼저 "종목과 사용자 상황을 반영한 기본 추천 점수"를 만들고,
그 다음 투자성향 레이어가 상태 기준과 가중치를 최종 보정하는 방식이 가장 안전하다.

### 11.2 권장 구조

1. V4 기본 점수 계산
2. `USER_FIT` 반영
3. 투자성향 레이어 적용
4. 최종 상태 결정

회원가입 직후 온보딩 설문에서 투자성향을 받는 것을 기본 전제로 둔다.
즉 `risk_profile`은 추천 계산 중간에 추정하는 값이 아니라,
사용자가 처음 직접 선택한 성향을 저장하고 이후 수정 가능하게 두는 방식이 가장 안정적이다.

### 11.3 성향 유형 초안

| 성향 | 특징 | 기대 동작 |
|---|---|---|
| `CONSERVATIVE` | 안정형 | `REDUCE`, `STOP`가 더 빨리 나오도록 조정 |
| `BALANCED` | 균형형 | 기본 V4 기준 유지 |
| `AGGRESSIVE` | 성장형/위험형 | `MAINTAIN`, `INCREASE`가 조금 더 쉽게 나오도록 조정 |

### 11.4 적용 방식 초안

#### 방식 A. 상태 구간 이동

- 안정형:
  - `INCREASE` 최소 기준을 85 -> 90
  - `REDUCE` 기준을 35 -> 45
- 위험형:
  - `INCREASE` 최소 기준을 85 -> 80
  - `REDUCE` 기준을 35 -> 30

#### 방식 B. 팩터 가중치 이동

- 안정형:
  - `PRICE_STABILITY`, `FUNDAMENTAL_QUALITY` 비중 확대
  - `PRICE_MOMENTUM` 비중 축소
- 위험형:
  - `PRICE_MOMENTUM`, `NEWS_SENTIMENT` 비중 확대
  - `PRICE_STABILITY` 비중 축소

### 11.5 권장 결론

처음에는 방식 A로 시작하는 것이 좋다.

이유:
- 구현이 단순하다
- 설명이 쉽다
- 사용자에게 납득 가능한 변화다

이후 데이터가 쌓이면 방식 B까지 확장한다.

### 11.6 설문 데이터 초안

초기 설문 예시:

- 손실이 나도 장기 보유 가능한가
- 단기 변동성을 감수할 수 있는가
- 투자 목표가 안정 수익인가 성장 수익인가
- 현재 투자 여유자금이 충분한가

저장 예시:

- `risk_profile`
- `risk_profile_confidence`
- `risk_profile_updated_at`
- `risk_profile_source` (`ONBOARDING_SURVEY`, `MANUAL_UPDATE`)

## 12. FUNDAMENTAL_QUALITY 확장 로드맵

### 12.1 왜 지금 바로 크게 붙이지 않는가

EPS, 성장률, 수익성 지표는 중요하지만,
붙는 순간 아래가 함께 필요해진다.

- 데이터 공급원 확정
- 배치 수집
- 결측 처리
- 미국/한국 종목 간 차이 처리
- 최신성 기준 정리

그래서 V4 구조가 안정되기 전에 크게 붙이면
모델보다 데이터 파이프라인 이슈가 더 커질 수 있다.

### 12.2 권장 확장 순서

#### 1단계

- `market_cap`
- `per_value`

목표:
- 대형주/중소형주 구분
- 과도한 고평가 구간 감지

#### 2단계

- `eps`
- `eps_growth_yoy`
- `revenue_growth_yoy`

목표:
- 수익성과 성장성을 함께 보기 시작

#### 3단계

- `operating_margin`
- `gross_margin`
- `roe`
- `debt_to_equity`

목표:
- 수익 구조와 재무 건전성 반영

#### 4단계

- sector median PER
- sector median PS
- peer-relative valuation

목표:
- 업종 특성을 반영한 상대 가치 평가

### 12.3 실무 권장 결론

지금 당장은 `market_cap + per_value`만 유지하고,
V4의 저장 구조와 해석 UI가 안정된 뒤
`FUNDAMENTAL_QUALITY V2`로 EPS와 성장률을 붙이는 것이 가장 좋다.

단, 지금 단계에서도 `market_cap`, `per_value` 각각의 세부 판단 근거와
조합 보정값은 `factor_raw_json`에 남겨두는 것이 좋다.
그래야 이후 EPS, 성장률, 수익성 지표가 들어와도 같은 구조 안에서 자연스럽게 확장된다.

## 13. DB 확장 초안

현재 `recommendations` 테이블에 V4용 상세 컬럼을 추가하는 방안을 권장한다.

추가 후보:

- `price_momentum_score`
- `price_stability_score`
- `news_sentiment_score_v2`
- `fundamental_quality_score`
- `user_fit_score`
- `cross_factor_adjustment`
- `user_adjustment`
- `confidence_breakdown_json`
- `risk_profile_applied`

또는 별도 상세 테이블:

### `recommendation_factor_details`

| 컬럼 | 설명 |
|---|---|
| `recommendation_id` | 추천 ID |
| `factor_code` | 팩터 코드 |
| `factor_score` | 팩터 점수 |
| `factor_weight` | 적용 가중치 |
| `factor_summary` | 사용자용 한 줄 설명 |
| `factor_raw_json` | 계산 근거 원본 |

이 구조를 두면 상세 화면의 추천 근거를 더 정교하게 보여줄 수 있다.

## 14. API 응답 확장 초안

`calculation` 영역에 아래 필드를 추가하는 방향을 권장한다.

```json
{
  "formulaVersion": "SCORE_V4_MULTI_FACTOR",
  "rawScore": 68,
  "finalScore": 61,
  "riskAdjustment": -7,
  "priceMomentumScore": 72,
  "priceStabilityScore": 58,
  "newsScore": 64,
  "fundamentalQualityScore": 70,
  "userFitScore": 54,
  "crossFactorAdjustment": -3,
  "userAdjustment": 2,
  "riskProfileApplied": "BALANCED",
  "increaseEligible": false
}
```

## 15. 1차 가중치 초안

| 팩터 | 기본 가중치 | 비고 |
|---|---:|---|
| `PRICE_MOMENTUM` | 25 | 가격 추세와 과열 판단 중심 |
| `PRICE_STABILITY` | 15 | 급락, 하방 리스크 별도 관리 |
| `NEWS_SENTIMENT` | 25 | 최신 이슈와 방향성 반영 |
| `FUNDAMENTAL_QUALITY` | 20 | 기업 체력과 밸류 보정 |
| `USER_FIT` | 15 | 투자 부담과 사용자 맥락 반영 |

해석:
- 뉴스 비중은 유지하되 단독 지배를 막는다.
- 가격을 `추세`와 `안정성`으로 분리해 해석력을 높인다.
- 기초체력과 사용자 맥락을 넣어 서비스다운 추천으로 발전시킨다.

## 16. V4 다음 우선순위

### 지금 가장 먼저 해야 할 일

1. V4 팩터별 점수 저장 구조 확정
2. 상세 화면 추천 근거를 V4 팩터 기준으로 정렬
3. 홈/상세 API 응답에 팩터 메타데이터 연결

이 3개가 먼저다.

이유:
- 지금은 엔진보다 저장 구조와 설명 구조를 먼저 안정화해야 한다.
- 그래야 이후 EPS, 투자성향이 들어와도 덜 흔들린다.

### 그 다음 해야 할 일

4. `FUNDAMENTAL_QUALITY` 1차 고도화
5. 투자성향 설문 및 `risk_profile` 저장 구조 추가
6. 투자성향 레이어 적용

### 왜 투자성향이 지금 1순위는 아닌가

투자성향은 매우 중요하지만,
지금 바로 붙이면 "엔진 본체"와 "사용자별 해석"이 동시에 바뀌어서
튜닝과 디버깅이 어려워진다.

따라서 지금은 설계 섹션에 포함하고,
실제 구현은 V4 저장/응답 구조가 안정된 다음이 맞다.

### 왜 EPS도 지금 즉시 붙이지 않는가

EPS 자체는 중요하지만
지금은 모델의 틀을 잡는 단계다.

EPS를 먼저 붙이면
- 데이터 수집 문제
- 결측 처리 문제
- 국가별 차이
- 배치 최신성 이슈

가 동시에 들어오므로,
V4 1차 안정화 이후 `FUNDAMENTAL_QUALITY V2`로 들어가는 것이 가장 현실적이다.

## 17. 구현 순서 제안

### 1단계

- V4 설계 문서 확정
- `RecommendationScoreCalculator` V4 인터페이스 정리

### 2단계

- `recommendations` 저장 구조 확장 또는 `recommendation_factor_details` 추가
- V4 팩터별 점수 저장

### 3단계

- 상세 화면 추천 근거를 V4 팩터 기준으로 재구성
- 홈 응답도 V4 점수 메타데이터 반영

### 4단계

- `FUNDAMENTAL_QUALITY` 1차 안정화
- `market_cap`, `per_value` 튜닝

### 5단계

- 투자성향 설문 설계
- `risk_profile` 저장
- 성향별 상태 구간 보정 적용

### 6단계

- EPS, 성장률, 수익성 지표 도입
- `FUNDAMENTAL_QUALITY V2` 확장

## 18. 운영 관점 결론

V4는 단순히 점수를 더 복잡하게 만드는 작업이 아니다.
MaeMoJi를 "뉴스 감성 앱"이 아니라
"여러 근거를 설명하는 투자 메모형 추천 앱"으로 바꾸는 핵심 단계다.

특히 멀티유저 운영 기준에서 중요한 방향은 아래와 같다.

- 뉴스 분석은 종목 공용 캐시를 재사용한다.
- 추천 계산은 사용자별로 하되, 비싼 외부 호출은 종목 단위로 줄인다.
- 최종 비용 증가가 사용자 수보다 활성 종목 수에 가깝게 움직이도록 설계한다.
- 투자성향은 종목 점수 위에 얹는 해석 레이어로 둔다.
