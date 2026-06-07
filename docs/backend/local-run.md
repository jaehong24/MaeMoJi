# MaeMoJi 로컬 DB / WAS 실행 가이드

## 1. DB 서버 실행

프로젝트 루트에서 아래 명령으로 PostgreSQL과 Adminer를 실행합니다.

```powershell
docker compose up -d
```

접속 정보는 아래와 같습니다.

- PostgreSQL
  - Host: `localhost`
  - Port: `5432`
  - Database: `maemoji`
  - Username: `maemoji`
  - Password: `.env`에 설정한 값
- Adminer
  - URL: [http://localhost:18080](http://localhost:18080)
  - System: `PostgreSQL`
  - Server: `maemoji-postgres`
  - Username: `maemoji`
  - Password: `.env`에 설정한 값
  - Database: `maemoji`

## 2. 초기 스키마와 샘플 종목

DB를 처음 실행하면 아래 스키마가 자동 적용됩니다.

- [001_schema.sql](C:/Users/icand/Documents/MaeMoJi/infra/postgres/init/001_schema.sql:1)

샘플 종목 시드는 아래 파일을 사용합니다.

- [001_stocks_seed.sql](C:/Users/icand/Documents/MaeMoJi/infra/postgres/seed/001_stocks_seed.sql:1)
- [002_dev_user_seed.sql](C:/Users/icand/Documents/MaeMoJi/infra/postgres/seed/002_dev_user_seed.sql:1)
- [002_stock_search_master_columns.sql](C:/Users/icand/Documents/MaeMoJi/infra/postgres/manual/002_stock_search_master_columns.sql:1)

참고:
- 검색 마스터 컬럼은 이제 백엔드 시작 시 자동 보정됩니다.
- 위 수동 SQL은 기존 DB를 직접 맞추고 싶을 때만 사용하면 됩니다.
- `finnhub_symbol` 중복이 있어도 자동 초기화가 중복 항목을 정리한 뒤 인덱스를 생성합니다.

Windows PowerShell에서 한글 SQL을 직접 흘려보내면 인코딩이 깨질 수 있어서, 아래 방식으로 컨테이너 내부에서 실행하는 것을 권장합니다.

```powershell
docker cp infra/postgres/seed/001_stocks_seed.sql maemoji-postgres:/tmp/001_stocks_seed.sql
docker exec maemoji-postgres psql -U maemoji -d maemoji -f /tmp/001_stocks_seed.sql
docker cp infra/postgres/seed/002_dev_user_seed.sql maemoji-postgres:/tmp/002_dev_user_seed.sql
docker exec maemoji-postgres psql -U maemoji -d maemoji -f /tmp/002_dev_user_seed.sql
docker cp infra/postgres/manual/002_stock_search_master_columns.sql maemoji-postgres:/tmp/002_stock_search_master_columns.sql
docker exec maemoji-postgres psql -U maemoji -d maemoji -f /tmp/002_stock_search_master_columns.sql
```

## 3. 백엔드 프로젝트 위치

Spring Boot + MyBatis 백엔드는 아래 경로에 있습니다.

- [backend](C:/Users/icand/Documents/MaeMoJi/backend)

핵심 파일:

- [build.gradle](C:/Users/icand/Documents/MaeMoJi/backend/build.gradle:1)
- [application.yml](C:/Users/icand/Documents/MaeMoJi/backend/src/main/resources/application.yml:1)
- [HealthController.java](C:/Users/icand/Documents/MaeMoJi/backend/src/main/java/com/maemoji/backend/health/HealthController.java:1)
- [StockController.java](C:/Users/icand/Documents/MaeMoJi/backend/src/main/java/com/maemoji/backend/stock/controller/StockController.java:1)
- [run-backend.ps1](C:/Users/icand/Documents/MaeMoJi/backend/run-backend.ps1:1)
- [top-stock-batch.md](C:/Users/icand/Documents/MaeMoJi/docs/backend/top-stock-batch.md:1)

## 4. WAS 실행

가장 간단한 방법은 아래 스크립트를 사용하는 것입니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\backend\run-backend.ps1 -BuildFirst
```

이미 빌드된 JAR가 있으면 아래처럼 실행만 해도 됩니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\backend\run-backend.ps1
```

백엔드 기본 포트는 `8081`입니다.

확인용 API:

- 헬스 체크: [http://localhost:8081/api/health](http://localhost:8081/api/health)
- 종목 검색: [http://localhost:8081/api/stocks/search?keyword=AAPL](http://localhost:8081/api/stocks/search?keyword=AAPL)
- 포트폴리오 조회: [http://localhost:8081/api/portfolio-items](http://localhost:8081/api/portfolio-items)
- 상위 종목 배치 수동 실행: [http://localhost:8081/api/admin/batches/top-stocks/sync](http://localhost:8081/api/admin/batches/top-stocks/sync)

## 5. 현재 준비된 상태

현재 로컬 개발 기준으로 아래까지 준비되어 있습니다.

- PostgreSQL Docker 구성
- Adminer 로컬 관리 화면
- 초기 스키마
- 샘플 종목 시드
- Spring Boot + MyBatis 백엔드 골격
- 종목 검색 API 초안
- Gradle Wrapper
- JAR 기반 실행 스크립트
