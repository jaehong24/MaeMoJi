# MaeMoJi Neon PostgreSQL Migration

## 1. Overview

MaeMoJi backend already accepts hosted Postgres URLs through environment variables.
For Neon, the simplest path is to replace the current `DATABASE_URL` with the Neon connection string.

Supported variables:

- `DATABASE_URL`
- `NEON_DATABASE_URL`
- `SPRING_DATASOURCE_URL`

The backend converts `postgresql://...` style URLs into JDBC automatically.

## 2. Recommended Neon Connection

Use the pooled connection string from Neon when possible.

Example:

```text
postgresql://USER:PASSWORD@HOST/maemoji?sslmode=require
```

Notes:

- If the host is a Neon host and `sslmode` is missing, the backend appends `sslmode=require`.
- Existing username and password parsing still works when they are embedded in the URL.

## 3. Local Backend Test

PowerShell example:

```powershell
$env:DATABASE_URL="postgresql://USER:PASSWORD@HOST/maemoji?sslmode=require"
powershell -ExecutionPolicy Bypass -File .\backend\run-backend.ps1 -BuildFirst
```

Health check:

```text
http://localhost:8081/api/health
```

## 4. Render Backend Change

In Render, replace the current database-related environment variable with the Neon URL.

Recommended:

- `DATABASE_URL`

Optional direct JDBC style:

- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

## 5. GitHub Actions Batch Change

The daily batch workflow reads:

- `DATABASE_URL`
- `FINNHUB_API_KEY`
- `GEMINI_API_KEY`

So if you move from Render Postgres to Neon, update only the `DATABASE_URL` secret in GitHub Actions.

## 6. Data Migration

Recommended migration flow:

1. Export the current database with `pg_dump`.
2. Create the target database in Neon.
3. Import with `psql` or restore with `pg_restore`.
4. Point Render backend and GitHub Actions to the Neon URL.
5. Run health check and one manual daily batch.

Example:

```powershell
pg_dump "postgresql://OLD_USER:OLD_PASSWORD@OLD_HOST/maemoji" -Fc -f maemoji.dump
pg_restore --no-owner --no-privileges -d "postgresql://NEW_USER:NEW_PASSWORD@NEW_HOST/maemoji?sslmode=require" maemoji.dump
```

## 7. Post-migration Checklist

- `api/health` returns `UP`
- stock search works
- portfolio list works
- manual price snapshot batch works
- daily GitHub Actions batch completes
