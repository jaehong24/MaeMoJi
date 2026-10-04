# Release completion plan

## 1. Account deletion

- Implemented: authenticated DELETE /api/users/me; no caller-supplied user ID.
- Implemented: settings confirmation dialog and local session removal after success.
- Delete account, consent fields, risk profile, portfolio, recommendations, evidence,
  performance evaluations, weekly reports, alerts, device tokens and broker connections.
- Shared stock master, price history and news cache are retained.
- All deletes run in one transaction. Unknown dependencies fail closed and roll back.
- Local PostgreSQL tests verify owner isolation and rollback.
- No production account was deleted for this test.
- Already submitted device notifications cannot be recalled by deleting database rows.
- Database backups are not rewritten by this endpoint. Before release, document backup
  retention and ensure restored backups reapply account deletion requests.

## 2. Android signing

- Release no longer uses debug signing.
- Use android/key.properties.example as the configuration reference.
- Existing Play application: reuse its upload key or complete Play key recovery.
- New application: create and securely back up an upload key before building.
- Owner confirmed this is a new app with no existing upload key.
- Created upload key and certificate in the user's .maemoji/signing directory,
  outside Git; android/key.properties is ignored. A local copy of the signing
  configuration is stored beside the key. This is not an off-device backup.
- Signed AAB build and jarsigner verification passed (CN=MaeMoJi Upload).
- Pending: Firebase registration of the correct signing certificate fingerprints.
  Play App Signing uses a separate certificate;
  register its fingerprints too after Play enrollment.
- An unsigned AAB is only a compilation check, not a release-ready artifact.

## 3. Device acceptance

- Pending: real Google signup, nickname, survey, stock registration and recommendation.
- Pending: Android and mobile browser push delivery, deep links, logout/account switch.
- Pending: deletion with a disposable account, old-session rejection and fresh signup.
- Unit tests and simulated devices do not establish these results.

## Release gate

Freeze score changes during this work. Release only after signed-build verification,
device acceptance and the published contact/privacy/deletion instructions are complete.
Do not repeatedly rerun production batches to verify UI changes.

## Verification on 2026-10-04

- Flutter analyze: no issues; existing Flutter tests: 10 passed.
- Backend suite passed with LOCAL_OUTBOX_TEST=true, including local PostgreSQL tests.
- Account deletion integration: ownership isolation and full rollback passed.
- Account deletion HTTP test: unauthenticated rejection and user-ID tampering passed.
- Deployment and production account deletion were not performed.

Upload certificate SHA-1: 81:50:B7:04:56:3D:63:E9:E2:26:64:FC:7E:96:F9:28:DC:B5:52:46

Upload certificate SHA-256: AB:C4:41:81:95:DE:C2:7C:D7:E7:BA:71:8C:92:F4:18:6C:79:AB:02:BB:A5:25:45:11:76:B1:1C:CB:36:C7:8E
