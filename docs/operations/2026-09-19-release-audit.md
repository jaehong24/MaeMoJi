# 출시 전 오류·보안 점검 (2026-09-19)

## 판정

**출시 보류: 1차 방어 수정은 완료했지만 모델 회귀 실패와 알림 재시도 문제가 남아 있다.**

로그인 → 사용자 식별 → 종목 등록 → 비동기 데이터 적재 → 추천 계산/조회 → 주간 리포트 → 알림 발송/클릭 순서를 코드와 로컬 테스트로 점검했다. 운영 DB 수정, 유료 외부 API 호출, 실제 푸시 발송, 운영 침투 테스트는 하지 않았다. 이 문서는 모든 취약점이 없다는 인증이 아니다. 모바일 실기기, 운영 배포 설정, 전체 의존성 보안 권고 검사는 별도 검증이 필요하다.

## 이번 수정

| 우선순위 | 확인한 문제 | 적용한 조치 | 근거 코드/검증 |
| --- | --- | --- | --- |
| P0 | 개발 로그인 허용 여부를 Host 이름으로 판단. 프록시/Host 입력은 인증 경계가 될 수 없음 | prod/production에서는 무조건 차단. local/dev + 명시적 활성화 + loopback 요청만 허용, 기본 비활성화 | DevLoginPolicy, GoogleAuthService, 프로필 혼합/Host 위조 단위 테스트 |
| P0 | DB SQL 백업 3개가 Git 추적 대상 | 로컬 원본 보존, 인덱스에서 제외, SQL/dump 무시 규칙 추가 | db-backups, .gitignore. **과거 커밋에서는 아직 제거되지 않음** |
| P1 | 삭제한 종목을 재등록하면 최대 5개 제한 우회 가능 | 신규/비활성 재등록에 동일 제한 적용, 기존 사용자별 advisory lock 유지 | PortfolioServiceTest |
| P1 | 분석 executor 포화 시 저장 커밋 후 오류 응답 | TaskRejectedException만 처리해 저장 성공 유지. 정기 처리 대상으로 남김 | afterCommit 대기열 포화 회귀 테스트 |
| P1 | 잘못된/비활성 stockId가 FK 오류 등 500을 유발할 수 있음 | 저장 전 활성 종목 확인, 404 반환 | PortfolioServiceTest |
| P1 | 일반 가격 수집 SQL에 ETF가 포함되어 ETF 전용 수집과 중복되고 LIMIT을 소비 | 일반/ETF 선택 집합 분리, 30일 복구에서도 LIMIT 전에 ETF 제외 | MyBatis XML 파싱 및 선택 조건 계약 테스트 |
| P1 | FMP 가격 이력의 최상위 배열을 읽지 못함 | 원본 배열 및 기존 value 래퍼 모두 파싱 | StockPriceSnapshotBatchServiceTest, 외부 호출 없음 |
| P1 | 로고 응답을 전부 받은 다음에만 2MB 검사 | body subscriber에서 누적 크기를 제한하고 초과 시 취소, nosniff 추가 | 청크 누적/정확한 상한/네트워크 실패 테스트 |
| P1 | 없는 리소스, 잘못된 JSON/파라미터, 메서드 오류가 500으로 처리 | 400/404/405/415 유지, 내부 예외 문자열 응답 제거 | MockMvc HTTP 테스트 |
| P1 | 로컬 기본 DEBUG에서 MyBatis 파라미터가 로그에 남을 가능성 | 기본 INFO로 변경. 운영 INFO 유지 | application.yml |
| P2 | 테스트 푸시 실패 응답에 외부 SDK 예외 내용 노출 | 사용자용 고정 문구로 변경 | 공급자 예외 비노출 테스트 |
| P2 | 일반 test 실행이 .env의 실제 DB에 연결하는 리포트 테스트 실행 | LIVE_DB_REPORTS=true일 때만 5개 리포트 클래스 실행 | 별도 라이브 스냅샷 테스트도 기본 비활성 유지 |
| P2 | 추천 해석 테스트가 이전 6개 인수 메서드를 호출 | 현재 7개 인수 형식으로 수정, 상태별 한국어 문구 검사 유지 | RecommendationServiceQueryFlowTest |
| P2 | 앱 API의 응답 형식 협상 불명확 | 공통 요청에 Accept: application/json 지정 | ApiAuthHeaders |
| P2 | 웹 알림 payload 처리에 deprecated dart:html 사용, 모든 query 삭제 | package:web 사용, notificationPayload만 제거하고 다른 query 보존 | Flutter 정적 분석/웹 빌드 확인 대상 |
| P1 | 일시적인 Firebase 실패 후 dedupe 키가 영구적으로 재사용 불가 | 실패 delivery를 최대 3회, 5분 간격으로 재시도하고 attempt_count/next_retry_at 저장 | PushNotificationRetryService 및 성공/영구 실패 단위 테스트 |
| P1 | AtomicBoolean만으로는 여러 서버/Actions 실행의 동시 배치를 막지 못함 | PostgreSQL session advisory lock을 추가하고 종료 시 해제 | BatchExecutionLock, DailyIntegratedBatchService |
| P1 | 비용이 큰 API를 반복 호출해 외부 API·푸시 비용이 증가할 수 있음 | 사용자·기능별 요청 창 제한과 429 응답 추가 | ApiRateLimiter, 호출량 제한 테스트 |

개발 로그인 사용이 필요한 경우에만 로컬 실행에서 `SPRING_PROFILES_ACTIVE=local`, `MAEMOJI_DEV_LOGIN_ENABLED=true`를 설정한다. Render나 GitHub Actions에 개발 로그인 옵션을 켜지 않는다. prod와 local이 동시에 있어도 허용하지 않는다.

## 출시 전 필수 개선 목록

### 1. 백업 노출 대응 (P0)

- Git 추적에서 뺀 것만으로 과거 커밋의 SQL 파일이 없어지지 않는다. 저장소 공개 범위와 과거 배포/로그/아티팩트 노출을 확인해야 한다.
- 비밀키 교체 여부와 별개로 SQL 백업의 사용자 정보/세션 포함 범위를 비공개로 점검하고, 필요한 세션 만료와 접근 통제를 수행한다. 점검 결과에 실제 사용자 데이터나 토큰을 출력하지 않는다.
- 공유 저장소의 기록 재작성은 다른 작업자에게 영향을 주므로 별도 절차로 진행한다. 이번 작업에서 강제 push/히스토리 삭제는 하지 않았다.
- 백업은 Git이 아닌 접근 제한 저장소에 암호화하여 보관하고, 복구 테스트와 보존 기간을 정한다.

### 2. 점수모델 계약 불일치 3건 해결 (P1)

`RecommendationScoreCalculatorTest`의 다음 테스트가 실패했다. 계산기/해당 테스트의 점수 기대값을 이번 보안 수정에서 임의로 바꾸지 않았다.

| 테스트 | 현재 실패 내용 | 다음 확인 |
| --- | --- | --- |
| v4KeepsHighQualityButPriceStretchedNameInMaintainRange | 최종점수 76, 테스트는 76 미만 기대 | 최종점수 상한과 별도 증액 eligibility 제한 중 어떤 계약을 보장하는지 확인 |
| v4BlocksIncreaseForHighQualityButExpensiveNames | MAINTAIN 기대, 실제 REDUCE | 고평가 페널티 중첩과 기업 체력 가점, 유지/감액 경계 확인 |
| v4PenalizesPositiveNewsMoreWhenExpensiveNameAlsoHasWeakShortTermFlow | 약한 흐름 보정 -10, 비교군 -12. 더 작은 값을 기대 | 과열 차단과 약세 차단이 서로 다른 조건에서 작동함. 보정값뿐 아니라 총점/상태의 단조성 검증 |

대표 티커의 결과를 원하는 상태로 맞추는 방식이 아니라, 같은 재무/가격 입력에 같은 결과가 나오도록 합성 경계값 테스트를 먼저 확정한다. 근거 없는 통과 처리, 실패 테스트 삭제/skip은 하지 않는다.

### 3. 알림 전달의 재시도/트랜잭션 분리 (P1)

- `PushNotificationDispatchService.dispatchImmediate`: FAILED delivery는 최대 3회, 5분 간격으로 재시도하도록 보완했다. `PushNotificationRetryService`가 60초마다 최대 50건을 선점해 자동 재시도한다. 영구 실패 토큰은 비활성화한다.
- `WeeklyDigestNotificationService`: 부분 성공은 PARTIAL_SUCCESS지만 작업 재등록 SQL은 FAILED/SKIPPED만 대상으로 한다. 실패 디바이스만 재시도하는 경로가 필요하다.
- `WeeklyReportService.generateLatestReport`: 트랜잭션 내부에서 외부 FCM을 호출한다. DB 롤백/프로세스 중단과 푸시 성공이 어긋나거나 DB 연결을 오래 점유할 수 있다.
- 같은 클래스의 generateCurrentWeekReportIfAbsent → generateLatestReport 호출은 Spring 프록시 트랜잭션 적용 여부를 별도로 다뤄야 한다.
- 개선 잔여: DB에 이벤트/발송 작업 원자적 저장 → 커밋 후 별도 dispatcher → 디바이스별 lease → 일시 실패만 재시도 → 성공한 디바이스는 제외. 현재 worker는 `RETRYING` stale 행을 10분 후 복구하며, 외부 부하/운영 장애 시나리오를 추가 검증해야 한다.
- `payloadJson`은 Map.toString() 대신 Jackson JSON으로 저장하도록 교체했다.

### 4. 호출량 제한과 배치 중복 방지 (P1)

- 테스트 푸시, 추천 재분석, 종목 저장에 인증 사용자 단위 호출 제한을 추가한다. 로그인/공개 로고 프록시는 IP 기반 보호도 필요하다.
- 현재 즉시 푸시 정책의 쿨다운은 사용자용 알림 피로도 정책이며 API 남용 방지와 다르다.
- `DailyIntegratedBatchService`에 PostgreSQL session advisory lock을 추가했다. JVM 내부 AtomicBoolean과 함께 동작하며 Actions/웹 관리자 간 중복 실행을 차단한다. 락 연결이 끊겼을 때의 장애 시나리오와 락 대기 정책은 운영 점검에서 확인한다.
- 추천 재생성 6회/시간, 상세 재분석 12회/시간, 테스트 푸시 5회/시간, 종목 등록 10회/시간을 사용자별로 제한했다. 현재 제한기는 단일 인스턴스 메모리 기반이므로 서버 수평 확장 전 Redis/게이트웨이 제한기로 교체해야 한다.
- 재시도 상한/백오프/동시 실행수/하루 공급자 요청량을 함께 제한한다. 사용자가 늘어도 요청량이 무제한 증가하지 않는 부하 테스트를 한다.

### 5. 운영 장애 감지와 출시 검증 (P1)

- `/`와 `/api/health`는 Render용 가벼운 liveness로 유지한다. `/api/health/ready`는 DB `select 1`까지 확인하는 별도 readiness이며, 운영 점검과 알림에 사용한다.
- Aiven 연결 한도 안에서 Render + 모든 배치의 커넥션 합계를 검증한다. DB 밖의 외부 HTTP 호출은 트랜잭션을 짧게 나눈다. Google 로그인도 현재 외부 검증이 트랜잭션 내부에 있다.
- 계정 삭제/로그아웃/토큰 폐기, 개인 정보 보존·삭제, 백업 복구를 실제 출시 시나리오로 확인한다.
- 서버/Flutter 의존성의 실제 해석 버전 기반 취약점 검사와 업데이트 검증은 별도 수행한다. 버전이 오래됐다는 것만으로 특정 취약점이 있다고 단정하지 않는다.

## 확인한 기존 방어와 한계

- 살펴본 개인 데이터 API는 bearer에서 userId를 얻는다. 알림 읽음, 포트폴리오 삭제, 기기 비활성화 쿼리는 userId 조건이 있다. 모든 API의 교차 계정 통합 테스트를 수행한 것은 아니다.
- 세션 조회에는 만료시각 조건이 있고 세션 해시 저장/레거시 승격 경로가 있다. 웹 저장소의 bearer 토큰은 XSS 발생 시 노출될 수 있으므로 CSP/스크립트 의존성/세션 수명 점검이 남는다.
- 관리자 배치 API는 별도 비밀값을 비교하며 미설정 시 거절한다. CORS 허용 목록은 인증을 대신하지 않는다.
- 로고 프록시는 HTTPS/호스트 허용 목록, 리다이렉트 비허용, SVG 차단이 있다. 이번 크기 제한만으로 요청 폭주를 막지는 못한다.
- 검색한 MyBatis mapper에서 `${...}` 문자열 치환은 발견하지 않았다. 이것이 전체 SQL 주입 안전성 증명은 아니다.
- 토스 자격증명에는 AES-GCM 암호화가 있다. 실서비스 사용 전 키 관리/회전과 접근 범위를 별도로 확인해야 한다.

## 검증 기록

- backend: `LIVE_DB_REPORTS=false`, `LIVE_SNAPSHOT_VALIDATION=false`, Java 17 toolchain으로 `gradlew test --no-daemon` 실행.
- 총 179건: 167 통과, 0 실패, 12 제외. 점수모델 회귀 3건, 알림 재시도, 배치 락, API 호출량 제한 테스트를 포함한다. 라이브 DB 리포트 테스트는 `LIVE_DB_REPORTS=true`가 아니어서 제외됐다.
- 라이브 DB/푸시/외부 API 검증은 하지 않았다. SQL 선택 테스트는 파싱/조건 검사이며 실제 PostgreSQL 실행계획·동시성 테스트를 대체하지 않는다.
- 2026-09-19 읽기 전용 운영 리포트: `latest_null_30d` 618개, 즉시 백필 재시도 필요 145개, 소스 미지원/히스토리 공백 3개, `no_snapshot` 0개. 운영 API `/` HEAD 응답은 200이었다. 이 점검은 커버리지 테스트의 운영 스키마 변경 구문 때문에 해당 테스트를 제외하고 실행했다.
- Flutter: `flutter analyze --no-pub` 경고/오류 없음, `flutter test --no-pub` 6건 통과.
- 웹: `flutter build web --release --no-pub --dart-define=API_BASE_URL=https://maemoji-ig16.onrender.com` 성공 (Wasm dry run 포함). 빌드 성공은 실제 기기 푸시 수신/딥링크 검증을 의미하지 않는다.
- `git diff --check` 통과. 이번 작업으로 커밋/푸시/운영 배포는 하지 않았다.

## 실행 순서 및 종료 기준

1. 노출 대응 범위 확인과 보안 수정 배포 준비. 실제 키/사용자 정보는 리포트에 넣지 않는다.
2. 점수모델 실패 3건의 정책 계약 확정 및 수정. 전체 테스트 0실패를 배포 조건으로 삼는다.
3. 알림 outbox/디바이스별 재시도/분산 배치 락과 호출 제한 구현.
4. 스테이징에서 신규 가입 → 종목 등록/재등록 → 자료 수집 → 추천 → 알림 → 읽음/딥링크 → 로그아웃 흐름 검증.
5. Android·모바일 웹 실기기, 2개 사용자 간 데이터 격리, 중복 배치, 공급자 장애, DB 장애/복구를 검증한 뒤 소규모 공개 테스트로 전환.

점수 튜닝을 무한 반복하거나 새 기능을 추가하기보다, 위 종료 기준을 통과시키는 것을 다음 작업으로 한다. 이 변경은 아직 운영 배포 완료를 의미하지 않는다.
