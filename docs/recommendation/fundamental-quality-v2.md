# FUNDAMENTAL_QUALITY V2

## 목적

MaeMoJi의 `FUNDAMENTAL_QUALITY`는 단순한 "좋은 회사 느낌" 점수가 아니라,
실제 재무제표 기반 품질 팩터를 묶어서 기업 체력을 설명하는 점수로 설계한다.

이번 V2에서는 점수를 아래 묶음으로 나눠 계산한다.

1. `수익성`
2. `성장성`
3. `안정성`
4. `현금흐름 품질`
5. `효율성`
6. `체급`
7. `밸류 부담`

좋은 종목이 전부 100점으로 몰리는 문제를 줄이기 위해,
개별 지표 가산점 누적이 아니라 그룹 점수의 가중 평균 방식으로 해석한다.

## 연구 근거

### 1. 품질 팩터

- MSCI Quality Methodology:
  ROE, 부채비율, 이익 안정성을 핵심 품질 축으로 본다.
- AQR Quality Minus Junk:
  품질을 `profitability`, `growth`, `safety`, `payout` 묶음으로 본다.

MaeMoJi는 이 둘을 참고해 `profitability`, `growth`, `safety`, `cash flow` 중심으로 확장했다.

### 2. 재무제표 기반 선별

- Piotroski:
  흑자 여부, 수익성 개선, 레버리지, 유동성, 영업 효율 등을 함께 보면 승자/패자를 더 잘 가를 수 있다고 본다.

MaeMoJi는 Piotroski의 방향을 참고해
`EPS`, `ROA`, `유동비율`, `자산회전율`, `마진`, `부채비율`을 함께 본다.

### 3. 수익성과 투자 팩터

- Fama-French 5 Factor:
  operating profitability 와 investment 패턴이 장기 수익률 설명력에 중요하다고 본다.

MaeMoJi는 이 관점을 반영해
`영업이익률`, `ROIC`, `현금흐름 품질`, `과도한 성장 대비 취약성`을 같이 체크한다.

### 4. 이익의 질 / 조작 위험

- Sloan accrual literature:
  현금흐름보다 accrual 비중이 큰 이익은 지속성이 낮을 수 있다.
- Beneish:
  회계 숫자만 좋아 보여도 조작 가능성은 별도 경고 축으로 봐야 한다.

이번 V2 구현에서는 `incomeQualityTTM`과 `operatingCashFlowRatioTTM`을 먼저 사용하고,
향후 `Beneish`, `accruals` 계열은 별도 위험 경고 팩터로 확장한다.

## V2 현재 반영 지표

### 성장성

- `eps_ttm`
- `revenue_growth_yoy`

### 수익성

- `gross_margin_ttm`
- `net_margin_ttm`
- `operating_margin_ttm`
- `roe_ttm`
- `roa_ttm`
- `roic_ttm`

### 안정성

- `debt_to_equity_ttm`
- `current_ratio_ttm`
- `quick_ratio_ttm`

### 현금흐름 품질

- `free_cash_flow_yield_ttm`
- `operating_cash_flow_ratio_ttm`
- `income_quality_ttm`

### 효율성

- `asset_turnover_ttm`

### 체급 / 밸류 부담

- `market_cap`
- `per_value`

## 점수 해석 원칙

- `수익성`은 가장 높은 비중으로 본다.
- `성장성`은 높더라도 수익성과 현금흐름이 약하면 과대평가하지 않는다.
- `안정성`은 부채비율만이 아니라 유동성도 함께 본다.
- `현금흐름 품질`은 "이익이 실제 현금으로 이어지는가"를 본다.
- `효율성`은 자산을 얼마나 잘 굴리는지 본다.
- `체급`은 안정성 보조 지표일 뿐, 단독으로 고득점을 만들지 않는다.
- `밸류 부담`은 좋은 회사라도 너무 비싸면 점수를 눌러준다.

## V2 다음 확장 우선순위

1. `earnings_variability` 또는 마진 변동성 추가
2. `cash profitability` / `operating profitability`를 분기 기반으로 보강
3. `Beneish M-score` 경고 축 추가
4. `accrual / cash flow persistence` 축 추가
5. 산업별 기준치 보정

## 참고 자료

- MSCI Quality Indexes Methodology:
  https://www.msci.com/eqb/methodology/meth_docs/MSCI_Quality_Indexes_Methodology_May2022.pdf
- Piotroski, Value Investing: The Use of Historical Financial Statement Information to Separate Winners from Losers:
  https://www.chicagobooth.edu/~/media/FE874EE65F624AAEBD0166B1974FD74D.pdf
- Asness, Frazzini, Pedersen, Quality Minus Junk:
  https://www.econ.yale.edu/~shiller/behfin/2013_04-10/asness-frazzini-pedersen.pdf
- Fama-French profitability / investment factors:
  https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2287202
- Sloan accrual literature review:
  https://assets.super.so/e46b77e7-ee08-445e-b43f-4ffd88ae0a0e/files/cb8704e9-a43d-424e-a511-c2c1a6ca2bae.pdf
- Beneish manipulation detection:
  https://www.calctopia.com/papers/beneish1999.pdf
