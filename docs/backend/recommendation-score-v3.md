# MaeMoJi 추천 점수 V3

## 원칙

- 실제 수집된 데이터만 점수 계산에 사용한다.
- 수집되지 않은 재무, 밸류에이션, 기관 데이터에는 임의의 중립 점수를 부여하지 않는다.
- 점수와 추천 상태를 분리한다. 강한 악재와 데이터 신뢰도는 추천 상태를 제한할 수 있다.
- 모든 계산 입력과 조정 결과를 `recommendations`에 저장한다.

## 계산식

```text
rawScore =
    sum(componentScore * componentWeight)
    / sum(availableComponentWeight)
```

현재 구성 요소는 다음과 같다.

- 가격 점수: 30일 수익률 기반, 기본 가중치 55
- 뉴스 점수: Gemini 종합 감성 `-100~100`을 `0~100`으로 정규화, 기본 가중치 45

데이터가 없는 구성 요소의 가중치는 0으로 처리한다. 가격과 뉴스가 모두 없으면 점수는 50, 추천 상태는 `MAINTAIN`으로 처리한다.

## 가격 점수

| 30일 수익률 | 점수 |
|---|---:|
| `-35%` 이하 | 10 |
| `-35%` 초과 ~ `-20%` 이하 | 25 |
| `-20%` 초과 ~ `-10%` 미만 | 45 |
| `-10%` 이상 ~ `10%` 이하 | 70 |
| `10%` 초과 ~ `20%` 이하 | 60 |
| `20%` 초과 ~ `30%` 이하 | 45 |
| `30%` 초과 | 25 |

## 추천 상태

- 80점 이상: `INCREASE`
- 60점 이상: `MAINTAIN`
- 40점 이상: `REDUCE`
- 40점 미만: `STOP`

`INCREASE`는 가격과 뉴스 데이터가 모두 있고 신뢰도가 70 이상일 때만 허용한다. 조건을 충족하지 못하면 `MAINTAIN`으로 제한한다.

강한 위험 신호는 다음과 같이 우선 적용한다.

- 30일 수익률 `-35%` 이하 또는 명시적 위험 신호: 최종 점수 최대 30, `STOP`
- Gemini 강한 악재 판정: 최종 점수 최대 45, 최소 `REDUCE`

## API

추천 조회와 생성 응답의 `calculation` 필드에서 계산 과정을 제공한다.

```json
{
  "formulaVersion": "SCORE_V3_PRICE_NEWS",
  "rawScore": 67,
  "finalScore": 45,
  "riskAdjustment": -22,
  "priceScore": 70,
  "newsScore": 63,
  "priceWeight": 55,
  "newsWeight": 45,
  "thirtyDayReturn": 4.3,
  "newsSentimentScore": 26,
  "increaseEligible": false
}
```
