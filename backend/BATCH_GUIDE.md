# MaeMoJi Daily Batch

## Overview

The daily integrated batch runs in this order:

1. Fetch up to 500 active stocks from Finnhub using `quote + metric`
2. Save daily price snapshots and 1d / 7d / 30d returns from our DB
3. Refresh portfolio news and Gemini analysis
4. Save the latest recommendation scores, confidence, and action results

GitHub Actions runs this batch every day at `21:47 UTC`, which is
`06:47 KST` on the next calendar day.

## GitHub Actions setup

Workflow file:

- [daily-batch.yml](/C:/Users/icand/Documents/MaeMoJi/.github/workflows/daily-batch.yml)

Required GitHub repository secrets:

- `DATABASE_URL`
- `FINNHUB_API_KEY`
- `GEMINI_API_KEY`

If you move to Neon, use the Neon pooled connection string for `DATABASE_URL`
in GitHub Actions because the batch runs on a long-lived backend process and
benefits from PgBouncer-based pooling.

The workflow uses Java 17, starts Spring Boot in non-web mode, runs the
integrated batch once, and then exits with code `0` on success and `1` on
failure.

## Manual run

You can run the batch manually from GitHub:

1. Open the repository on GitHub
2. Go to `Actions`
3. Select `maeemoji-daily-batch`
4. Click `Run workflow`
5. Optionally change `price_limit`

## Logs

Check these log messages in the Actions run:

- `일일 통합 배치를 시작합니다`
- `가격 스냅샷 배치를 시작합니다`
- `일일 통합 배치를 완료했습니다`
- `일일 배치 단발 실행을 종료합니다`

If some price snapshots fail but the batch still completes recommendation
generation, the result is recorded as `PARTIAL_SUCCESS`.

## Notes

Web-service `@Scheduled` jobs remain disabled in production so that GitHub
Actions is the single source of truth for the daily batch schedule.

Protected admin APIs can still be used separately if you want to trigger
price sync or stock master sync by hand.

For data migration tools such as `pg_dump` and `pg_restore`, use a direct
Neon connection instead of the `-pooler` host.
