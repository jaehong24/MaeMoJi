# Fake-device validation, 2026-09-20

## Executed

Dedicated PostgreSQL 18 on 127.0.0.1:55439; random disposable schemas.
Two test user rows and fake ANDROID/WEB tokens registered through PushNotificationSettingsService.
Real MyBatis mapper, JDBC transactions, schema initializer and outbox worker; Firebase gateway mocked.
No real Google identities were created and no production notifications were sent.

Seven integration scenarios passed:

1. User-scoped device lookup/deactivation and repeated worker execution without resending SENT deliveries.
2. Transaction rollback removes queued delivery; commit does not call Firebase inline; scheduled worker sends afterward.
3. Temporary failure respects retry time and retries only the failed device.
4. Device reassignment to another account excludes the previous owner's queued delivery.
5. Expired token is deactivated and not retried.
6. Weekly job moves from PENDING to SUCCESS after device retry succeeds.
7. Concurrent SQL claims on the same delivery produce exactly one winner.

Full backend test run: 200 total, 188 passed, 12 skipped, 0 failures/errors.
Test schemas were dropped and the local PostgreSQL instance stopped afterward.

## Corrections

- Removed synchronous event-triggered dispatch during afterCommit; scheduled polling now performs delivery outside that callback. Poll delay defaults to 60 seconds, plus backlog processing time.
- Enforced delivery/device user ownership in pending/retry selection and claim SQL.

## Limits

This is not an end-to-end signup or mobile browser test. Google OAuth, production deployment, physical push reception, notification taps and Flutter navigation require separate verification. Existing backend tests ran, but no live market-data batch or live recommendation regeneration was triggered.
Provider acceptance followed by a process crash before recording SENT can still result in a duplicate; this does not establish exactly-once delivery.

## Reproduce

Start a dedicated PostgreSQL instance on loopback port 55439 with database postgres and testadmin user, then run backend Gradle tests with LOCAL_OUTBOX_TEST=true. Never point this test at production: it uses a fixed loopback URL and creates/drops only its own random schemas.
