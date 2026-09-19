# MaeMoJi latest_null_30d 분류 리포트

- 생성 시각: 2026-09-19 15:08:09 +09:00
- latest_null_30d 종목 수: 618
- ETF 제외 대상: 470
- 실제 복구/점검 대상(ETF 제외): 148
- latest_null_portfolio 종목 수: 0
- no_snapshot 종목 수: 0

- 최근 상장 30일 대기: 0
- 30일 히스토리 부족: 0
- 소스 미지원/히스토리 공백: 3
- 즉시 백필 재시도 필요: 145
- 수동 점검 필요: 0

## 운영 판정

- ETF는 기업형 추천 모델의 30일 복구 대상이 아니며, 가격 스냅샷 정책으로 별도 관리합니다.
- 즉시 백필 재실행 대상은 ETF를 제외한 `BACKFILL_RETRY_REQUIRED` 종목입니다.
- `SOURCE_UNSUPPORTED_OR_GAPPED` 종목은 limit 상향보다 데이터 소스/히스토리 예외 처리를 먼저 확인해야 합니다.

| 종목 | 회사명 | 포트폴리오 | 상태 | 상태 설명 | 최신 스냅샷 | 최초 스냅샷 | IPO | 소스 | 7일 | 30일 |
|---|---|---|---|---|---|---|---|---|---|---|
| AAA | 에이에이에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAAA | 에이에이에이에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAAC | 에이에이에이씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAAD | 에이에이에이디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAAU | 에이에이에이유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAOG | 에이에이오지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAOX | 에이에이오엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAPR | 에이에이피알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAPW | 에이에이피더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAPX | 에이에이피엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAPY | 에이에이피와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAUA | 에이에이유에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAUC | 얼라이드 골드 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AAUM | 에이에이유엠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ABEQ | 에이비이큐 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ABFL | 에이비에프엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ABLD | 에이비엘디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ABLG | 에이비엘지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ABLS | 에이비엘에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ABNY | 에이비엔와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-07-18 | 2026-06-22 | - | FINNHUB | Y | N |
| ABOT | 에이비오티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ABUF | 에이비유에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ABXB | 에이비엑스비 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACEI | 에이씨이아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACES | 에이씨이에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACGO | 에이씨지오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACGR | 에이씨지알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACII | 에이씨아이아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACIO | 에이씨아이오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACKY | 에이씨케이와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACLC | 에이씨엘씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACLO | TCW AAA CLO | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACP | ABERDEEN INCOME CREDIT STRATEGIES | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACSG | 에이씨에스지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACSI | 에이씨에스아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACSV | 에이씨에스브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACTS | 에이씨티에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACV | VIRTUS DIVERSIFIED INCOME & CONVERTIBLE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACVF | 에이씨브이에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACVT | 에이씨브이티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACVU | 에이씨브이유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACWV | 에이씨더블유브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACYN | 에이씨와이엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ACYS | 에이씨와이에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AD | 어레이 디지털 인프라스트럭처 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ADBU | 에이디비유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ADCT | ADC 테라퓨틱스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ADDS | 에이디디에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ADIV | 에이디아이브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ADME | 에이디엠이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ADPV | 에이디피브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ADVE | 에이디브이이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ADX | ADAMS DIVERSIFIED EQUITY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AEFC | 아혼 펀딩 후순위채권(2049-12-15 5.100%) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AEG | 아혼(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AERO | 그루포 아에로멕시코 스폰서드 ADS | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AESR | 에이이에스알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AETH | 에이이티에이치 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AFB | ALLIANCEBERNSTEIN NATIONAL MUNICIPAL INCOME | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AFGR | 에이에프지알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AFIF | 에이에프아이에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AFIX | 에이에프아이엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AFK | 에이에프케이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AFLG | 에이에프엘지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AFMC | 에이에프엠씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AFRU | 에이에프알유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AFSM | 에이에프에스엠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AGBK | 에이지아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AGD | ABERDEEN GLOBAL DYNAMIC DIVIDEND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AGG | 에이지지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AGGH | 에이지지에이치 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AGGS | 에이지지에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AGGY | 에이지지와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AGI | 알라모스 골드 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AGIQ | 에이지아이큐 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AGOX | 에이지오엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| AREN | 티 에이치 이 에이 알 이 엔 에이 그룹 홀딩스 | N | SOURCE_UNSUPPORTED_OR_GAPPED | 7일 흐름은 있지만 30일 기준점이 비어 있어 소스 공백 또는 장기 히스토리 보강이 필요해요. | 2026-09-19 | 2026-03-20 | - | FINNHUB_FMP | Y | N |
| CIF | MFS INTERMEDIATE HIGH INCOME | N | SOURCE_UNSUPPORTED_OR_GAPPED | 7일 흐름은 있지만 30일 기준점이 비어 있어 소스 공백 또는 장기 히스토리 보강이 필요해요. | 2026-07-18 | 2026-06-18 | - | FINNHUB_FMP | Y | N |
| COIO | 씨오아이오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-07-18 | 2026-06-24 | - | FINNHUB | Y | N |
| CUSD | CROSSINGBRIDGE ULTRA SHORT DURATION | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-08-27 | 2026-03-03 | - | FINNHUB | N | N |
| DISO | 디아이에스오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-07-18 | 2026-06-25 | - | FINNHUB | Y | N |
| FBYDP | FALCONS BEYOND GLOBAL INC CUM CONV PFD STK 11% SER B | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-07-02 | 2026-06-17 | - | FINNHUB_FMP | N | N |
| HNNAZ | 헤네시 어드바이저스 선순위채권(2026-12-31 4.875%) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-08-18 | 2026-03-04 | - | FINNHUB | N | N |
| HVT.A | 에이치 에이 브이 이 알 티 와이 에프 유 알 엔 아이 티 유 알 이 씨 오 엠 피 에이 엔 아이 이 에스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-27 | - | FINNHUB | N | N |
| LC | 렌딩 클럽 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-29 | - | FINNHUB | N | N |
| LEG | 레겟 앤드 플랫 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB_FMP | N | N |
| LEN.B | 엘 이 엔 엔 에이 알 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-29 | - | FINNHUB_FMP | N | N |
| MFICL | 미드캡 파이낸셜 인베스트먼트 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-18 | - | FINNHUB_FMP | N | N |
| MKC.V | 엠 씨 씨 오 알 엠 아이 씨 케이 앤 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-29 | - | FINNHUB | N | N |
| MOG.A | 엠 오 오 지 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-29 | - | FINNHUB | N | N |
| MOG.B | 엠 오 오 지 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-29 | - | FINNHUB | N | N |
| MSDD | GRANITESHARES MSTR DAILY -2X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-07-15 | 2026-06-18 | - | FINNHUB | Y | N |
| NCL | 엔 오 알 티 에이치 에이 엔 엔 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| PTNM | 피타늄 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-03-18 | - | FINNHUB_FMP | N | N |
| RAY | 레이텍 홀딩 | N | SOURCE_UNSUPPORTED_OR_GAPPED | 7일 흐름은 있지만 30일 기준점이 비어 있어 소스 공백 또는 장기 히스토리 보강이 필요해요. | 2026-09-19 | 2026-03-18 | - | FINNHUB_FMP | Y | N |
| REE | 리 오토모티브 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-03-18 | - | FINNHUB | N | N |
| RITM | 리듬 캐피털 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RIV | RIVERNORTH OPPORTUNITIES | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RL | 랄프 로렌 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RLGT | 알 에이 디 아이 에이 엔 티 엘 오 지 아이 에스 티 아이 씨 에스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RLI | RLI | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RM | 리저널 매니지먼트 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RMAX | 리맥스 홀딩스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RMI | RIVERNORTH OPPORTUNISTIC MUNICIPAL INCOME | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RMM | RIVERNORTH MANAGED DURATION MUNICIPAL INCOME | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RMMZ | RIVERNORTH MANAGED DURATION MUNICIPAL INCOME II | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB_FMP | N | N |
| RMT | ROYCE MICRO CAP TRUST | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RNG | 링센트럴 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RNGR | 레인저 에너지 서비시스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RNR | 르네상스리 홀딩스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RNST | 르네산트 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| ROG | 로저스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| ROL | 롤린스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| ROLR | 에이치 아이 지 에이치 알 오 엘 엘 이 알 테크놀로지스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RPC | 리지포스트 캐피털 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RPM | RPM 인터내셔널 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RPT | 리듬 프로퍼티 트러스트 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RRC | 레인지 리소시스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RRX | 리걸 렉스노드 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RS | 릴라이언스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RSF | RIVERNORTH CAPITAL AND INCOME | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB_FMP_EMPTY | N | N |
| RSI | 러시 스트리트 인터랙티브 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RSKD | 리스키파이드 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RTO | 렌토킬 이니셜(ADR) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RVLV | 리볼브 그룹 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RVP | 알 이 티 알 에이 씨 티 에이 비 엘 이 테크놀로지스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RVT | ROYCE VALUE TRUST | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RVTY | 레비티 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RWT | 레드우드 트러스트 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RXO | RXO | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RYAM | 레이어니어 어드밴스드 머티리얼스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RYAN | 라이언 스페셜티 홀딩스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RYDE | 알와이디이 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| RYN | 레이어니어 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| RYZ | RYERSON HOLDING CORP | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| RZC | 리인슈어런스 그룹 오브 아메리카 후순위채권(7.125%) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| S | 센티넬원 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SAC | 세이프가드 애퀴지션 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB_FMP | N | N |
| SAFE | 세이프홀드 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SAGU | SHREYA ACQUISITION GROUP | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-05-22 | - | FINNHUB_FMP_EMPTY | N | N |
| SAH | 소닉 오토모티브 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SAJ | 사라토가 인베스트먼트 일반채권(2027-10-31 8.000%) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SAM | 보스턴 비어 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SAR | 사라토가 인베스트먼트 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SARO | 스탠더드에어로 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SAT | 사라토가 인베스트먼트 일반채권(2027-04-30 6.000%) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SAV | 사라토가 인베스트먼트 7.50% 노트 (2031-06-02 만기) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SAY | 사라토가 인베스트먼트 일반채권(2027-12-31 8.125%) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SAZ | 사라토가 인베스트먼트 일반채권(2028-04-15 8.500%) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SB | 세이프 벌커스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SBEV | 에스 피 엘 에이 에스 에이치 비 이 브이 이 알 에이 지 이 그룹 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SBH | 샐리 뷰티 홀딩스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SBI | WESTERN ASSET INTERMEDIATE MUNICIPAL | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SBR | 사빈 로열티 트러스트 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SBSI | 사우스사이드 뱅크셰어스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SBSW | 시바녜 스틸워터(ADR) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SBXD | 실버박스 4 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB_FMP | N | N |
| SBXE | 실버박스 V | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB_FMP_EMPTY | N | N |
| SCCD | 에스 에이 씨 에이치 이 엠 캐피털 6 00 엔 오 티 이 에스 디 유 이 2026 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SCCE | 에스 에이 씨 에이치 이 엠 캐피털 6 00 엔 오 티 이 에스 디 유 이 2027 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SCCF | 에스 에이 씨 에이치 이 엠 캐피털 7 125 엔 오 티 이 에스 디 유 이 2027 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SCCG | 에스 에이 씨 에이치 이 엠 캐피털 8 00 엔 오 티 이 에스 디 유 이 2027 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SCD | LMP CAPITAL AND INCOME | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SCI | 서비스 코퍼레이션 인터내셔널 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SCL | 스테판 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SCLS | STONEPORT ADVISORS COMMODITY LONG SHORT | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-07-17 | 2026-06-20 | - | FINNHUB | Y | N |
| SCM | 스텔러스 캐피털 인베스트먼트 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SD | 샌드리지 에너지 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SDEV | 에스 티 에이 비 엘 이 씨 오 아이 엔 디 이 브이 이 엘 오 피 엠 이 엔 티 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SDHC | 스미스 더글러스 홈스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SEB | 에스 이 에이 비 오 에이 알 디 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SEG | 시포트 엔터테인먼트 그룹 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SEI | 솔라리스 에너지 인프라스트럭처 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SER | 에스 이 알 아이 엔 에이 테라퓨틱스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SES | SES AI | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SF | 스티펄 파이낸셜 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SFB | 스티펄 파이낸셜 선순위채권 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SFBS | 서비스퍼스트 뱅크셰어스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SFL | SFL 코퍼레이션 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SG | 스위트그린 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SGHC | 슈퍼 그룹 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SGI | 솜니그룹 인터내셔널 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-04-06 | - | FINNHUB | N | N |
| SKLZ | 스킬즈 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-06-30 | - | FINNHUB | N | N |
| STEW | SRH TOTAL RETURN | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB_FMP | N | N |
| STG | 선랜즈 테크놀로지 그룹(ADR) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| STN | 스탠텍 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| STRW | 에스 티 알 에이 더블유 비 이 알 알 와이 에프 아이 이 엘 디 에스 알이아이티 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| STUB | 스텁허브 홀딩스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| STVN | 스테바나토 그룹 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| STXS | 에스 티 이 알 이 오 티 에이 엑스 아이 에스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| STZ | 컨스털레이션 브랜즈 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SUB | 에스유비 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SUI | 선 커뮤니티스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SUIL | 에스유아이엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SUPL | 에스유피엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SUPV | 그루포 수페르비에예(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SURE | 에스유알이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SURI | 에스유알아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SUSA | 에스유에스에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SUZ | 수자노(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SVAL | 에스브이에이엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SVIX | 에스브이아이엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SVM | 에스브이엠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SVOL | 에스브이오엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SVV | 세이버스 밸류 빌리지 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SVXY | 에스브이엑스와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SW | 스머핏 웨스트록 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SWAN | 에스더블유에이엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SWK | 스탠리 블랙 앤 데커 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SWX | 사우스웨스트 가스 홀딩스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SWZ | SWISS HELVETIA | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB_FMP | N | N |
| SXC | 선코크 에너지 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SXI | 스탠덱스 인터내셔널 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SXQG | 에스엑스큐지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SXT | 센시언트 테크놀로지스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SYF | 싱크로니 파이낸셜 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SYFI | 에스와이에프아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SYLD | 에스와이엘디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SYNX | 에스와이엔엑스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB_FMP | N | N |
| SYSB | 에스와이에스비 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| SZK | 에스지케이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TABD | 티에이비디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAC | 트랜스알타 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TACK | 티에이씨케이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TACN | 티에이씨엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TACU | 티에이씨유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAFI | 티에이에프아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAFL | 티에이에프엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAFM | 티에이에프엠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAGG | 티에이지지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAGS | 티에이지에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAIL | 티에이아이엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAJX | 티에이제이엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAL | TAL 에듀케이션 그룹(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TALO | 탈로스 에너지 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TALV | 티에이엘브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAN | 티에이엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAP | 몰슨 쿠어스 베버리지 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAP.A | 엠 오 엘 에스 오 엔 씨 오 오 알 에스 비 이 브이 이 알 에이 지 이 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAPR | 티에이피알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAXF | 티에이엑스에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAXM | 티에이엑스엠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TAXX | 티에이엑스엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBB | AT&T 일반채권(2066-11-01 5.350%) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBBB | BBB 푸즈 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBF | 티비에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBFC | 티비에프씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBFG | 티비에프지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBG | 티비지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBI | 트루블루 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBJL | 티비제이엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBLL | 티비엘엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBLU | TORTOISE GLOBAL WATER | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBN | 탬보란 리소시스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB_FMP | N | N |
| TBT | 티비티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBUX | 티비유엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBX | 티비엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TBXU | 티비엑스유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TCAF | 티씨에이에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TCAI | TORTOISE AI INFRASTRUCTURE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TCAL | 티씨에이엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TCBX | 서드 코스트 뱅크셰어스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TCHP | 티씨에이치피 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TCI | 트랜스컨티넨탈 리얼티 인베스트먼츠 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TCPA | 트랜스캐나다 파이프라인 후순위채권(2085-11-01 6.250%) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB_FMP_EMPTY | N | N |
| TCPB | 티씨피비 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TCV | 티씨브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TDAY | USA 투데이 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TDC | 테라데이타 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TDF | TEMPLETON DRAGON | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB_FMP | N | N |
| TDOC | 텔러닥 헬스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TDW | 타이드워터 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TE | T1 에너지 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB_FMP | N | N |
| TEI | TEMPLETON EMERGING MARKETS INCOME | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TEO | 텔레콤 아르헨티나(ADR) | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TEX | 테렉스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TFIN | 트라이엄프 파이낸셜 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TFX | 텔레플렉스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TG | 트레데가 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TGB | 티 에이 에스 이 케이 오 엠 아이 엔 이 에스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TGE | 더 제너레이션 에센셜스 그룹 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-07-01 | - | FINNHUB_FMP | N | N |
| TLDR | 티엘디알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TLH | 티엘에이치 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TLTD | 티엘티디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TLTE | 티엘티이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TLTI | 티엘티아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TLTP | 티엘티피 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TLTW | 티엘티더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TLTX | 티엘티엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMAR | 티엠에이알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMAT | 티엠에이티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMDV | 티엠디브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMF | 티엠에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMFC | 티엠에프씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMFE | 티엠에프이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMFG | 티엠에프지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMFM | 티엠에프엠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMFS | 티엠에프에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMFX | 티엠에프엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMH | 티엠에이치 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMLP | 티엠엘피 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMSL | 티엠에스엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMV | 티엠브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TMVE | 티엠브이이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TNA | 티엔에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TNGY | TORTOISE ENERGY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TNUK | 티엔유케이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOAK | 티오에이케이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOAO | 티오에이오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOCT | 티오씨티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOGA | 티오지에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOK | 티오케이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOLL | 티오엘엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOLZ | 티오엘지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOPC | 티오피씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOPT | 티오피티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOPW | 티오피더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOS | 티오에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOT | 티오티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOTL | 티오티엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOTR | 티오티알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOUS | 티오유에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOV | 티오브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TOXR | 티오엑스알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPAY | 티피에이와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPFC | 티피에프씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPFG | 티피에프지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPFI | 티피에프아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPHD | 티피에이치디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPIF | 티피아이에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPLC | 티피엘씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPOR | 티피오알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPRY | 티피알와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPSC | 티피에스씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPUT | 티피유티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPYP | TORTOISE NORTH AMERICAN PIPELINE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TPZ | TORTOISE ESSENTIAL ENERGY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-01 | - | FINNHUB | N | N |
| TRFK | 티알에프케이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TRFM | 티알에프엠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TRIO | 티알아이오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TRLV | TRULIEVE CANNABIS CORP | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TRND | 티알엔디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TROT | 티알오티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TRPA | 티알피에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TRSY | 티알에스와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TRTY | 티알티와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSCV | 티에스씨브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSEC | 티에스이씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSEP | 티에스이피 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSES | 티에스이에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSIC | 티에스아이씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSII | 티에스아이아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSLI | 티에스엘아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSLO | 티에스엘오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-07-14 | 2026-07-02 | - | FINNHUB | Y | N |
| TSLP | 티에스엘피 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSLT | 티에스엘티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSLW | 티에스엘더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSLY | 티에스엘와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSLZ | 티에스엘지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSME | 티에스엠이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSMY | 티에스엠와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSNF | 티에스엔에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSOL | 티에스오엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSPA | 티에스피에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSPX | 티에스피엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSRS | 티에스알에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSSD | 티에스에스디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSXD | 티에스엑스디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSXU | 티에스엑스유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TSYW | 티에스와이더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TTAM | 타이탄 아메리카 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TTDU | 티티디유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TTOP | 티티오피 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TTT | 티티티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TTXD | 티티엑스디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TTXU | 티티엑스유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TUA | 티유에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TUSB | 티유에스비 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TUSI | 티유에스아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TUYA | 투야(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TVAL | 티브이에이엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TWM | 티더블유엠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TWOX | 티더블유오엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TX | 테르니움(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TXBC | 티엑스비씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TXNU | 티엑스엔유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TXS | 티엑스에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TXXI | 티엑스엑스아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TYA | 티와이에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TYD | 티와이디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TYLD | 티와이엘디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TYLG | 티와이엘지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TYO | 티와이오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TYYY | 티와이와이와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| TZA | 티지에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UAPR | 유에이피알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UAUG | 유에이유지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UBEW | 유비이더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UBOT | 유비오티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UBR | 유비알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UBT | 유비티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UBXG | U BX 테크놀로지 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-03-19 | - | FINNHUB_FMP | N | N |
| UCC | 유씨씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UCIB | 유씨아이비 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UCO | 유씨오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UCON | 유씨오엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UCOP | 유씨오피 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UDEC | 유디이씨 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UDI | 유디아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UDIV | 유디아이브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UDN | 유디엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UDOW | 유디오더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UE | 어반 에지 프라퍼티스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UFEB | 유에프이비 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UFOD | 유에프오디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UGA | 유지에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UGE | 유지이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UGL | 유지엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UGLD | 유지엘디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UGP | 우우트라파르(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UJAN | 유제이에이엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UJB | 유제이비 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UJUL | 유제이유엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UJUN | 유제이유엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| ULE | 유엘이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| ULST | 유엘에스티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| ULTY | 유엘티와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UMAR | 유엠에이알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UMAY | 유엠에이와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UMDD | 유엠디디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UMI | 유엠아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UNG | 유엔지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UNHU | 유엔에이치유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UNHW | 유엔에이치더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UNL | 유엔엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UNOV | 유엔오브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UNX | 유엔엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UOCT | 유오씨티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UPAL | 유피에이엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UPAR | 유피에이알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UPGD | 유피지디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UPLT | 유피엘티 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UPRO | 유피알오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UPSD | 유피에스디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UPSX | 유피에스엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UPV | 유피브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| UPW | 유피더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| URA | 유알에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| URAA | 유알에이에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| URAN | 유알에이엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| URE | 유알이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| URG | 유알지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| URNM | 유알엔엠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| URSP | 유알에스피 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| URTH | 유알티에이치 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| URTY | 유알티와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USAI | 유에스에이아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USAS | 유에스에이에스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USAX | 유에스에이엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USCA | 유에스씨에이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USCI | 유에스씨아이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USD | 유에스디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USDU | 유에스디유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USE | 유에스이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USEP | 유에스이피 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USEW | 유에스이더블유 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USFE | 유에스에프이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USFR | 유에스에프알 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USG | 유에스지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USHY | 유에스에이치와이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USL | 유에스엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USLN | 유에스엘엔 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USLV | 유에스엘브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USMD | 유에스엠디 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USMF | 유에스엠에프 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USML | 유에스엠엘 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USMV | 유에스엠브이 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USNG | 유에스엔지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USNZ | 유에스엔지 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USO | 유에스오 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| USPX | 유에스피엑스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-07-02 | - | FINNHUB | N | N |
| VALG | LEVERAGE SHARES 2X LONG VALE DAILY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VALN | 발네바(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VAVX | VANECK AVALANCHE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCA | VANGUARD TARGET MATURITY 2027 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCB | VANGUARD TARGET MATURITY 2028 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCC | VANGUARD TARGET MATURITY 2029 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCD | VANGUARD TARGET MATURITY 2030 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCE | VANGUARD TARGET MATURITY 2031 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCF | VANGUARD TARGET MATURITY 2032 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCG | VANGUARD TARGET MATURITY 2033 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCH | VANGUARD TARGET MATURITY 2034 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCI | VANGUARD TARGET MATURITY 2035 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBCJ | VANGUARD TARGET MATURITY 2036 CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBIL | VANGUARD 0-3M TREASURY BILL | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBNB | VANECK BNB | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VBNK | 버사뱅크 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VCIT | VANGUARD INTERMEDIATE TERM CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VCLT | VANGUARD LONG TERM CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VCRB | VANGUARD CORE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VCSH | VANGUARD SHORT TERM CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VEFA | VANECK MSCI EAFE ANALYST SENTIMENT | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VEON | 비언(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VFF | 빌리지 팜스 인터내셔널 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VFLO | VICTORYSHARES FREE CASH FLOW | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VGIT | VANGUARD INTERMEDIATE TERM TREASURY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VGLT | VANGUARD LONG TERM TREASURY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VGSH | VANGUARD SHORT TERM TREASURY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VGSR | VERT GLOBAL SUSTAINABLE REAL ESTATE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VGUS | VANGUARD ULTRA SHORT TREASURY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VIGI | VANGUARD INTERNATIONAL DIVIDEND APPRECIATION | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VINP | 빈치 컴퍼스 인베스트먼츠 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VIOT | 비오미 테크놀로지(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VMAR | 비전 마린 테크놀로지스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VMBS | VANGUARD MORTGAGE BACKED SECURITIES | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VMD | 비메드 헬스케어 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VNET | 브이넷 그룹(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VNQI | VANGUARD GLOBAL EX-US REAL ESTATE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VOLT | TEMA ELECTRIFICATION | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VONE | VANGUARD RUSSELL 1000 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VONG | VANGUARD RUSSELL 1000 GROWTH | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VONV | VANGUARD RUSSELL 1000 VALUE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VOTE | TCW TRANSFORM 500 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VPLS | VANGUARD CORE PLUS BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VRIG | INVESCO VARIABLE RATE INVESTMENT GRADE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VRTL | GRANITESHARES VRT DAILY 2X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VSA | TCTM 키즈 IT 에듀케이션(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VSDA | VICTORYSHARES DIVIDEND ACCELERATOR | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VSMV | VICTORYSHARES US MULTI FACTOR MINIMUM VOLATILITY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VSOL | VANECK SOLANA | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VSTL | DEFIANCE VST DAILY 2X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VTC | VANGUARD TOTAL CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VTHR | VANGUARD RUSSELL 3000 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VTIP | VANGUARD SHORT TERM INFLATION PROTECTED SECURITIES | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VTWG | VANGUARD RUSSELL 2000 GROWTH | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VTWO | VANGUARD RUSSELL 2000 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VTWV | VANGUARD RUSSELL 2000 VALUE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VWOB | VANGUARD EMERGING MARKETS GOVERNMENT BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VXUS | VANGUARD TOTAL INTERNATIONAL STOCK | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VYMI | VANGUARD INTERNATIONAL HIGH DIVIDEND YIELD | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| VYNE | 바인 테라퓨틱스 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-03-19 | - | FINNHUB_FMP | N | N |
| WABF | WESTERN ASSET BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WAFDP | 워싱턴 페더럴 우선주 A(4.875% 상환) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WAI | 탑 킹윈 | N | BACKFILL_RETRY_REQUIRED | 스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요. | 2026-09-19 | 2026-03-19 | - | FINNHUB | N | N |
| WAMA | WISDOMTREE US ADAPTIVE MOVING AVERAGE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WARP | VANECK SPACE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WAVE | 에코 웨이브 파워 글로벌(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WB | 웨이보(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WCBR | WISDOMTREE CYBERSECURITY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WCLD | WISDOMTREE CLOUD COMPUTING | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WDAF | WISDOMTREE ASIA DEFENSE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WDGF | WISDOMTREE GLOBAL DEFENSE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WEEI | WESTWOOD SALIENT ENHANCED ENERGY INCOME | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WGMI | VALKYRIE BITCOIN MINERS | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WHF | 화이트호스 파이낸스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WHLRL | 휠러 리얼 에스테이트 인베스트 선순위채권(2023-12-31 7.000%) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WIMA | WISDOMTREE INTERNATIONAL ADAPTIVE MOVING AVERAGE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WISE | THEMES GENERATIVE ARTIFICIAL INTELLIGENCE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WKEY | 와이즈키 인터내셔널 홀딩(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-21 | - | FINNHUB | N | N |
| WOOD | ISHARES GLOBAL TIMBER & FORESTRY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WPRT | 웨스트포트 퓨얼 시스템스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WRD | 위라이드(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WRND | IQ GLOBAL EQUITY R&D LEADERS | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WRTH | WORTH CHARTING OPTIONS INCOME | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WSGE | WARREN STREET GLOBAL EQUITY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WSML | ISHARES MSCI WORLD SMALL CAP | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WTBN | WISDOMTREE BIANCO FIXED INCOME TR | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WTIP | WISDOMTREE INFLATION PLUS | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WTMU | WISDOMTREE CORE LADDERED MUNICIPAL | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WTMY | WISDOMTREE HIGH INCOME LADDERED MUNICIPAL | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| WYHG | 윙입푸드(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XAIX | XTRACKERS ARTIFICIAL INTELLIGENCE AND BIG DATA | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XBCI | NEOS BOOSTED BITCOIN HIGH INCOME | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XBIL | RBB US TREASURY 6M BILL | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XBTY | GRANITESHARES YIELDBOOST BITCOIN 2X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XCNY | SPDR S&P EMERGING MARKETS EX-CHINA | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XDEF | XTRACKERS EUROPE DEFENSE TECHNOLOGIES | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XENE | 제논 파머슈티컬 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XEY | GRANITESHARES YIELDBOOST ETHER 2X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XHG | 엑스체인지 텍(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XMAG | DEFIANCE LARGE CAP EX-MAGNIFICENT 7 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XNDU | 재너두 퀀텀 테크놀로지스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XNET | 쉰레이(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XOMX | DIREXION XOM DAILY 2X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XOVR | ENTREPRENEUR PRIVATE PUBLIC CROSSOVER | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XPEG | LEVERAGE SHARES XPEV DAILY 2X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XQQI | NEOS BOOSTED NASDAQ 100 HIGH INCOME | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-23 | - | FINNHUB | N | N |
| XRPC | CANARY XRP | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-23 | - | FINNHUB | N | N |
| XRPI | VOLATILITY SHARES XRP | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-23 | - | FINNHUB | N | N |
| XRPT | VOLATILITY SHARES XRP 2X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-23 | - | FINNHUB | N | N |
| XRTX | 졸트엑스 테라퓨틱스 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-23 | - | FINNHUB | N | N |
| XSPI | NEOS BOOSTED S&P 500 HIGH INCOME | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-23 | - | FINNHUB | N | N |
| XT | ISHARES EXPONENTIAL TECHNOLOGIES | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-23 | - | FINNHUB | N | N |
| XTLB | XTL 바이오파머슈티컬스(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XXX | CYBER HORNET S&P 500 AND XRP 75/25 STRATEGY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| XYZG | LEVERAGE SHARES XYZ DAILY 2X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YB | 위안바오(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YBMN | DEFIANCE BMNR OPTION INCOME | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YBST | GRANITESHARES YIELDBOOST SINGLE STOCK UNIVERSE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YBTY | GRANITESHARES YIELDBOOST TOPYIELDERS | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YI | 111(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YJ | 윈지(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YLDE | CLEARBRIDGE DIVIDEND STRATEGY ESG | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YNOT | HORIZON DIGITAL FRONTIER | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YOKE | YOKE CORE | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YOUL | 유라이프 그룹(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YQ | 17 에듀케이션 앤드 테크놀로지 그룹(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YQQQ | YIELDMAX N100 SHORT OPTION INCOME STRATEGY | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YSPY | GRANITESHARES YIELDBOOST SPY 3X | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| YXT | YXT닷컴 그룹 홀딩(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ZAP | GLOBAL X US ELECTRIFICATION | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ZHOG | F/M OPPORTUNISTIC INCOME | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ZLAB | 자이 랩(ADR) | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ZMUN | F/M CALLABLE TAX FREE MUNICIPAL | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ZTEN | F/M 10Y INVESTMENT GRADE CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ZTOP | F/M HIGH YIELD 100 | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ZTRE | F/M 3Y INVESTMENT GRADE CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
| ZTWO | F/M 2Y INVESTMENT GRADE CORPORATE BOND | N | EXCLUDED_ETF | ETF는 기업형 추천 모델과 분리되어 있어요. | 2026-09-19 | 2026-06-22 | - | FINNHUB | N | N |
