# Refactoring Roadmap

## Refactoring Principles

- Preserve behavior first; improve structure second.
- Keep each refactor small enough to validate with `..\box.exe testbox run`.
- Avoid changing routes, form field names, and rendered text unless the user-facing behavior is intentionally changing.
- Leave `lib/` alone.
- Prefer extraction over rewrite. This app is compact; the safest refactors move behavior into named units while keeping route contracts intact.

## Current Pressure Points

1. `Main.bx` mixes routing actions, auth/session logic, form validation, CRUD orchestration, dashboard aggregation, and diagnostics.
2. `MongoService.bx` mixes database connection management, collection setup, repository operations, password hashing, document conversion, and formatting helpers.
3. Views duplicate a large amount of inline CSS and navigation structure.
4. Security-sensitive behavior is scattered across handler and service helpers.
5. Diagnostic endpoints are easy to use locally but not separated from application-facing routes.

## Safety Baseline

Before each refactor:

```powershell
..\box.exe testbox run
```

The current characterization suite covers authentication, guarded routes, dashboard/list rendering, form validation, create/edit/not-found flows, and Mongo diagnostics with mocked persistence.

For UI refactors, add server smoke checks after TestBox:

```powershell
..\box.exe server status
Invoke-WebRequest -UseBasicParsing -Uri <server-url>/
Invoke-WebRequest -UseBasicParsing -Uri <server-url>/healthcheck
```

## Phase 1: Stabilize Boundaries

Goal: make the existing behavior easier to reason about without changing routes or data shape.

- Add explicit tests before touching any behavior not currently covered.
- Remove unused scaffold actions such as `data()` and `doSomething()` if no route or test depends on them.
- Remove empty lifecycle handlers only if ColdBox configuration is updated at the same time.
- Add small helper functions for repeated session access if it reduces duplication.
- Normalize handler error handling so each catch path has a clear status code and user-facing message.

Done when:

- The integration suite remains green.
- `Main.bx` has fewer unused/template leftovers.
- No route contract changes were introduced.

## Phase 2: Extract Validation And Form Mapping

Goal: move field defaults, request extraction, and validation out of `Main.bx`.

Candidate services:

- `app/models/UserFormService.bx`
- `app/models/ContactFormService.bx`

Move these helpers first:

- `defaultUserForm()`
- `userFormFromRequest()`
- `validateUserForm()`
- `defaultContactForm()`
- `contactFormFromRequest()`
- `validateContactForm()`
- `truthy()`

Keep handler method signatures and views unchanged. Inject services through WireBox mappings in `app/config/WireBox.bx`.

Done when:

- Existing integration tests pass.
- New unit tests cover validation and form mapping without starting MongoDB.

## Phase 3: Split Handler Responsibilities

Goal: reduce `Main.bx` from an all-purpose handler into focused handlers.

Possible split:

- `Auth.bx`: login/logout/session actions.
- `Dashboard.bx`: home/dashboard action.
- `Users.bx`: user CRUD.
- `Contacts.bx`: contact CRUD.
- `Diagnostics.bx`: Mongo diagnostics.

Keep route URLs stable while changing handler targets in `Router.bx`.

Suggested order:

1. Move diagnostics first because it is small.
2. Move contacts next because it is less auth-sensitive than user management.
3. Move users.
4. Move auth/dashboard last.

Done when:

- Route-level tests prove old URLs still work.
- Each handler has a small, clear responsibility.

## Phase 4: Split Persistence And Security Logic

Goal: make `MongoService.bx` less monolithic and easier to secure.

Candidate services:

- `MongoClientFactory.bx`: connection creation and lifecycle.
- `UserRepository.bx`: user collection/index/query/write behavior.
- `ContactRepository.bx`: contact collection/index/query/write behavior.
- `PasswordService.bx`: hashing and verification.
- `MongoDocumentMapper.bx`: Java document/list conversion helpers if duplication grows.

High-value first extraction:

1. `PasswordService.bx`, because it is security-sensitive and easy to test.
2. `UserRepository.bx`, because auth and user CRUD share the same collection.
3. `ContactRepository.bx`, because it is lower risk and validates the repository pattern.

Done when:

- Password behavior has direct unit coverage.
- User/contact repository behavior has mocked or live test coverage.
- `MongoService.bx` is either removed or becomes a thin facade during migration.

## Phase 5: Consolidate UI Structure

Goal: reduce repeated view scaffolding and make UI changes less expensive.

Options:

- Extract shared navigation/header snippets.
- Move common CSS to public assets.
- Use the existing Vite workspace only if the app needs Vue/Tailwind-driven client behavior.

Keep server-rendered `.bxm` pages as the default until there is a clear product need for a richer frontend pipeline.

Done when:

- Page rendering remains visually equivalent.
- View changes are covered by request-level assertions and browser smoke checks.

## Phase 6: Production Hardening

Coordinate this phase with `SECURITY_REVIEW.md`.

Priorities:

1. Add CSRF protection to all state-changing POST routes.
2. Add role/permission authorization for user management.
3. Protect or disable diagnostics and test aliases outside development.
4. Replace custom password hashing with a dedicated password hashing service.
5. Validate ObjectId inputs before Mongo calls.
6. Add rate limiting or lockout behavior for login.
7. Add structured security logging without logging secrets.

Done when:

- Security tests cover key controls.
- Development-only endpoints and server aliases are environment gated.
- Production config is documented.

