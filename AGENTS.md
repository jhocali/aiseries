# AGENTS.md

## Scope

These instructions apply to the entire Jojo application under `C:\BoxLang\jojo`.

Work from `C:\BoxLang\jojo` unless a command explicitly requires another directory. The parent workspace contains the local `box.exe`, Java runtime, MongoDB binaries, and MongoDB runtime data; do not treat those as application source.

## Project Summary

Jojo is a brownfield BoxLang application built on ColdBox 8. It provides server-rendered authentication, a dashboard, user administration, contact administration, and MongoDB diagnostics.

Current runtime shape:

- BoxLang/ColdBox application source: `app/`
- Public webroot: `public/`
- ColdBox routes: `app/config/Router.bx`
- Main request handler: `app/handlers/Main.bx`
- MongoDB integration: `app/models/MongoService.bx`
- Server-rendered views: `app/views/main/`
- Runtime configuration: `runtime/boxlang.json`
- CommandBox server configuration: `server.json`
- TestBox tests: `tests/specs/`
- Java dependencies: `lib/java/`
- Project documentation: `docs/`

Read these documents before non-trivial changes:

- `docs/BROWNFIELD_CODE_COMPREHENSION.md`
- `docs/PRODUCT_REQUIREMENTS.md`
- `docs/PROJECT_SCOPE.md`
- `docs/ARCHITECTURE.md`
- `docs/SECURITY_REVIEW.md`
- `docs/REFACTORING_ROADMAP.md`
- `TEST_STRATEGY.md`

Treat the planning documents as proposed target behavior where they say “Draft,” “Proposed,” “TBD,” or identify an assumption. Do not silently convert an unresolved product decision into implemented behavior.

## Repository Boundaries

- Make application changes inside `C:\BoxLang\jojo`.
- Do not edit `lib/coldbox`, `lib/testbox`, or `lib/modules`; they are managed dependencies.
- Do not edit JARs under `lib/java` directly. Change `pom.xml` and use the documented Maven process for intentional dependency updates.
- Do not modify MongoDB files under `mongodb-runtime/`, `mongo-test-write/`, or `.mongo/` as source code.
- Do not commit `.env`, logs, local databases, generated build output, temporary files, or secrets.
- Preserve unrelated user changes in a dirty worktree.
- Use `apply_patch` for hand-authored file changes.
- Avoid destructive Git or filesystem commands unless the user explicitly requests them.

## Application Conventions

Follow existing ColdBox conventions:

- Routes belong in `app/config/Router.bx`.
- HTTP orchestration belongs in `app/handlers/`.
- Business, validation, policy, and persistence behavior belongs in focused services under `app/models/`.
- Dependency mappings belong in `app/config/WireBox.bx`.
- Views belong in `app/views/`; shared shells belong in `app/layouts/`.
- Public static assets belong under `public/`.
- Tests mirror the relevant source boundary under `tests/specs/unit` or `tests/specs/integration`.

Keep handlers thin. They should read request values, enforce/request policy, invoke a service, and select a status, redirect, or view. Do not add more password, MongoDB document, validation, or authorization logic to a handler when it can live in a focused service.

Keep Java MongoDB driver objects behind a persistence boundary. Do not pass `Document`, `ObjectId`, Mongo collections, or driver results into handlers or views.

## Current Route Contracts

The active route URLs are:

- `GET /`
- `GET /healthcheck`
- `/api/echo`
- `/mongo/ping`
- `/mongo/login-table`
- `POST /login`
- `POST /logout`
- `GET /users`
- `POST /users`
- `GET /users/new`
- `GET /users/:id/edit`
- `POST /users/:id`
- `POST /users/:id/delete`
- `GET /contacts`
- `POST /contacts`
- `GET /contacts/new`
- `GET /contacts/:id/edit`
- `POST /contacts/:id`
- `POST /contacts/:id/delete`

When changing a route:

1. Update `app/config/Router.bx`.
2. Update the handler action and any form actions or navigation links.
3. Add request-level tests for the happy path and primary guard/failure path.
4. Update route documentation if the public contract changes.

Keep existing URLs stable during refactoring unless the user explicitly requests a contract change. The conventional `:handler/:action?` fallback is a current-state risk, not a pattern to expand.

## Authentication And Security

Current authentication uses `session.authUser`; `requireSignedIn()` redirects anonymous users. Roles and permissions are stored but are not currently enforced.

Security-sensitive changes must account for `docs/SECURITY_REVIEW.md` and the target design in `docs/ARCHITECTURE.md`:

- Preserve output encoding in views with the correct HTML, attribute, or URL encoder.
- Never log or render passwords, password hashes, reset tokens, connection strings, or secrets.
- Validate MongoDB ObjectIds before constructing `ObjectId` instances.
- Require server-side authorization for protected operations; hidden UI controls are not sufficient.
- Require CSRF protection for state-changing browser requests when implementing the planned security layer.
- Keep user-facing errors generic while logging safe diagnostic context with a request ID.
- Keep detailed Mongo diagnostics, debugger settings, test aliases, and exception pages out of production.
- Treat contact names, phone numbers, and addresses as sensitive data.
- Treat the Google Maps address embed as a privacy-sensitive external integration.
- Do not introduce a new custom password-hashing scheme. Follow the planned adaptive-hash migration design.

Do not describe a planned control as currently implemented unless code and tests prove it.

## Data Changes

MongoDB currently uses `users` and `contacts` collections.

For a user-field change, inspect and update as applicable:

1. Handler/form defaults, request mapping, and validation.
2. User form and list views.
3. `MongoService.bx` or the extracted user repository mappings.
4. Collection/index/schema documentation.
5. Test fixtures, mocks, and request/service tests.

For a contact-field change, follow the same path through contact defaults, mapping, validation, views, persistence, indexes, and tests.

Rules:

- Normalize email consistently and never return password/reset fields in list or view models.
- Keep `createdAt` and `updatedAt` behavior consistent.
- Add indexes only for documented query patterns.
- Use a test-only database for live persistence tests.
- Do not rely on personal or production data.
- Prefer explicit idempotent migration/setup behavior over schema changes hidden inside normal list requests.

## UI Changes

The active UI is server-rendered `.bxm`; the Vite/Vue files under `resources/vite` are scaffold resources, not the current application frontend.

- Edit the server-rendered views unless the user explicitly requests Vite/Vue work.
- Preserve the existing visual language unless a redesign is requested.
- Prefer shared layouts, navigation, and styles when removing duplication.
- Preserve labels, keyboard access, visible focus, error association, and responsive behavior.
- Test encoded output and avoid injecting untrusted strings into inline styles, scripts, or third-party URLs.

## Local Services

Run commands from `C:\BoxLang\jojo`.

Start or inspect the application server:

```powershell
..\box.exe server start
..\box.exe server status
```

CommandBox may choose a dynamic port. Always use `server status` to discover the actual URL instead of assuming port 8080.

The local MongoDB binary is currently available at:

```text
C:\BoxLang\mongodb-extract\MongoDB\Server\8.3\bin\mongod.exe
```

The existing development data and log paths are:

```text
C:\BoxLang\jojo\mongodb-runtime\data
C:\BoxLang\jojo\mongodb-runtime\log\mongod.log
```

Before starting MongoDB, check for an existing `mongod` process or listener on `127.0.0.1:27017`. Start background processes with a hidden window. Bind local development MongoDB to `127.0.0.1`; do not expose the unauthenticated local instance to other interfaces.

Useful smoke endpoints after startup:

- `/healthcheck`
- `/`
- `/mongo/ping` for explicit local MongoDB verification

CommandBox may need access to the user's `.CommandBox` runtime directory. If sandboxed execution fails with an access error, rerun the same necessary command through the normal approval mechanism.

## Testing

Canonical command:

```powershell
..\box.exe testbox run
```

Current project suites:

- `tests/specs/integration/MainSpec.bx`
- `tests/specs/integration/DashboardCrudSpec.bx`
- `tests/specs/integration/MongoEndpointSpec.bx`

Shared integration helpers and Mongo mocks live in `tests/resources/BaseIntegrationSpec.bx`.

Testing policy:

- Run the narrowest relevant check first, then the full TestBox suite for route, handler, model, session, or persistence-boundary changes.
- Use unit tests for pure validation, mapping, authorization, password, and business-rule services.
- Use request-level integration tests for routes, status codes, redirects, rendered content, session behavior, and service coordination.
- Mock MongoDB for ordinary request regression tests.
- Keep live-Mongo tests small, explicit, and pointed at a dedicated test database.
- Add browser/server smoke checks after user-facing rendering, routing, asset, session, or deployment changes.
- Test unauthorized, invalid, not-found, conflict, empty, and dependency-unavailable paths as appropriate.
- If only documentation changes, validate links/structure and state that application tests were not run.

Do not use the scaffold URL in `tests/test.xml` as the canonical runner without updating it for the current environment.

## Validation By Change Type

| Change | Minimum validation |
| --- | --- |
| Documentation only | Check referenced paths, Markdown structure, and secret leakage. |
| Pure model/service logic | Focused unit tests plus related integration tests. |
| Route or handler | Related request tests plus full TestBox suite. |
| View or layout | Request rendering assertions plus browser/server smoke. |
| MongoDB mapping/index | Unit/request coverage plus explicit test-database integration where feasible. |
| Auth/security | Positive and negative request tests, full suite, and manual header/cookie/exposure checks. |
| Runtime/deployment config | Artifact/config inspection plus startup, health, readiness, and rollback smoke checks. |

## Documentation

Update documentation when a change affects:

- Product behavior or scope.
- Public routes, form actions, or authorization.
- User/contact fields, collection names, or indexes.
- Authentication, sessions, CSRF, password behavior, or diagnostics.
- Environment variables, server startup, deployment, backup, or restore.
- Test commands, helpers, suites, or definition of done.
- An architectural decision or previously documented risk.

Use `docs/DOCUMENTATION_GUIDE.md` for repository documentation conventions. Update `.env.example` for new nonsecret configuration variables, never `.env` as documentation.

## Completion Checklist

Before handing off a change:

- Confirm the implementation matches the user's requested scope.
- Check route, handler, view, service, persistence, and test contracts together.
- Run validation proportional to risk and report the exact result.
- Review changed output for secrets and personal data.
- Update relevant documentation and configuration examples.
- Report assumptions, unresolved decisions, operational steps, and any tests not run.

