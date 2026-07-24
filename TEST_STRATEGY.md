# Test Strategy

## Goals

- Protect the login, dashboard, user CRUD, contact CRUD, Mongo diagnostic, and routing behavior that make up the current Jojo app.
- Keep most tests deterministic by mocking MongoDB at the handler boundary.
- Keep live MongoDB checks explicit and small so local failures point to environment/setup rather than app regressions.
- Replace scaffold-template assertions as app behavior changes.

## Test Layers

### Unit

- Cover pure helpers and data-shaping logic when it can be isolated without starting ColdBox or MongoDB.
- Add unit specs under `tests/specs/unit`.
- Prefer extracting reusable validation or mapping logic into models/services when it needs direct unit coverage.

### Handler And Route Integration

- Use `coldbox.system.testing.BaseTestCase` for request-level behavior.
- Cover public routes, guarded routes, form validation failures, session redirects, and JSON handler results.
- Mock `MongoService` with TestBox stubs for routes that need data access.
- Add specs under `tests/specs/integration`.

### Service Integration

- Use live MongoDB only for intentionally tagged smoke tests.
- Validate `/mongo/ping`, collection creation, indexes, and a minimal create/list/update/delete path against a test database.
- Keep destructive service tests pointed at a test-only database from `.env` or explicit environment variables.

### Browser Smoke

- After user-facing UI changes, start the CommandBox server and verify at least:
  - `/healthcheck`
  - `/`
  - `/users` anonymous redirect behavior
  - Authenticated dashboard/list pages when seeded test data exists

## Data Policy

- Do not rely on production or personal MongoDB data.
- Use mocked `MongoService` responses for normal CI/local test runs.
- Use a dedicated test database for live Mongo checks, ideally `jomongo_test`.
- Tests that mutate data must create unique records and clean them up.

## Commands

Run from `C:\BoxLang\jojo`.

```powershell
..\box.exe testbox run
```

If CommandBox cannot access `C:\Users\gmateo\.CommandBox` from the sandbox, rerun the same command with approval/escalation.

For server smoke checks:

```powershell
..\box.exe server start
..\box.exe server status
Invoke-WebRequest -UseBasicParsing -Uri <server-url>/healthcheck
```

## Definition Of Done

- New routes have at least one request-level test for the happy path and the primary failure/guard path.
- Form changes update validation tests and rendered-form assertions.
- Mongo field changes update service mapping, list/form rendering, and test fixtures together.
- Failing tests describe user-facing behavior rather than framework internals whenever possible.
