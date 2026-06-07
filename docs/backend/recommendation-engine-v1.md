# MaeMoJi Recommendation Engine V1

## 결론

현재 자료와 구현 상태를 기준으로 보면, **완전한 추천 엔진**은 아직 불가능하고 **보수적인 1차 규칙형 엔진**은 가능합니다.

이번 V1의 방향은 다음과 같습니다.

- 추천 결과는 `recommendations` / `recommendation_evidence`에 실제 저장
- 홈/추천 화면은 저장된 추천 결과를 조회
- 외부 데이터가 없는 축은 억지 추정 대신 **중립 점수 + 명시적 근거**로 처리
- 과신하지 않도록 `INCREASE`는 사실상 잘 나오지 않는 보수적 구조 유지

## 현재 가능한 부분

### 1. 추천 상태 저장

- `recommendations`
- `recommendation_evidence`

두 테이블은 이미 준비되어 있어 저장/조회 연동이 가능합니다.

### 2. 현재 포트폴리오 기반 추천 생성

현재 확보된 입력 데이터:

- `portfolio_items.daily_invest_amount`
- `portfolio_items.holding_quantity`
- `portfolio_items.investment_start_date`
- `portfolio_items.memo`
- `stocks` 기본 종목 정보
- Finnhub `quote`
- Finnhub `stock/candle` 기반 30일 수익률

이 범위 안에서는 최소한 아래가 가능합니다.

- 현재 적립 금액 확인
- 추천 금액 계산
- 30일 가격 과열도 판단
- 메모 기반 하드 리스크 키워드 감지
- 추천 근거 문구 생성

## 아직 부족하거나 불가능한 부분

### 1. 사업 건전성 점수의 정식 계산

스펙상 필요 데이터:

- 매출 성장률
- EPS 성장률
- 순이익 성장률
- 부채 안정성

현재는 FMP 재무 데이터가 연결되지 않아 **정식 계산 불가**합니다.

따라서 V1에서는:

- `Business Health = 중립 기본값`
- evidence에 `FMP 미연동 상태` 명시

### 2. 밸류에이션 점수의 정식 계산

스펙상 필요 데이터:

- 회사 PER
- 업종 평균 PER

현재는 산업 평균 비교 데이터가 없어 **정식 계산 불가**합니다.

따라서 V1에서는:

- `Valuation = 중립 기본값`
- evidence에 `업종 비교 데이터 미연동` 명시

### 3. 뉴스 감성 점수

스펙상 필요 구조:

- Finnhub 뉴스 수집
- Gemini 감성/요약

현재는 Gemini가 아직 붙지 않아 **설명 가능한 감성 점수 산정이 불완전**합니다.

따라서 V1에서는:

- `News Sentiment = 중립 기본값`
- evidence에 `뉴스 감성 분석 미연동` 명시

### 4. 기관 신뢰도 점수

스펙상 필요 데이터:

- SEC EDGAR 13F
- 기관 보유 변화

현재는 EDGAR/WhaleWisdom 계층이 없어 **정식 계산 불가**합니다.

따라서 V1에서는:

- `Institutional Confidence = 중립 기본값`
- evidence에 `기관 데이터 미연동` 명시

## V1 점수 모델

### 실제 계산

- `Price Overheating`
  - Finnhub 30일 수익률 사용
  - 과열 / 안정 / 급락 구간별 점수 계산

### 중립 기본값

- `Business Health = 24/35`
- `Valuation = 13/20`
- `News Sentiment = 9/15`
- `Institutional Confidence = 10/15`

이렇게 두는 이유:

- 데이터가 없다고 0점 처리하면 모든 종목이 과도하게 `REDUCE` 쪽으로 쏠림
- 반대로 높은 점수를 주면 근거 없는 `INCREASE`가 발생
- 따라서 `유지~축소` 사이의 보수적 중립값이 가장 현실적

## V1 하드 룰

아래는 즉시 `STOP` 또는 강한 보수 판단으로 연결합니다.

- 메모 내 고위험 키워드
  - `fraud`, `delist`, `bankruptcy`, `lawsuit`, `investigation`
  - `분식`, `상장폐지`, `파산`, `소송`, `회계부정`, `조사`
- 30일 급락이 매우 큰 경우
  - 예: `-35% 이하`

## V1 한계

이 버전은 **진짜 투자 판단 엔진의 완성형이 아닙니다.**

정확히는:

- `추천 테이블 구조를 실제로 쓰기 시작하는 버전`
- `설명 가능한 규칙형 골격을 만드는 버전`
- `외부 데이터가 붙었을 때 자연스럽게 확장 가능한 버전`

따라서 V1의 추천은 다음 원칙을 가집니다.

- 과감한 `INCREASE`는 거의 하지 않음
- `MAINTAIN` / `REDUCE` / `STOP` 위주
- 근거가 부족한 축은 숨기지 않고 그대로 드러냄

## 다음 확장 순서

1. Finnhub 뉴스 수집
2. Gemini 뉴스 감성/요약
3. FMP 재무/밸류 데이터
4. SEC EDGAR 기관 데이터
5. 카테고리별 점수 정밀화
6. confidence 계산 고도화

