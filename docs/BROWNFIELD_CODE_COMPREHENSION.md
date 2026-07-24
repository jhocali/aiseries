# Brownfield Code Comprehension

## Purpose

Jojo is a BoxLang/ColdBox 8 application with server-rendered pages for authentication, dashboards, users, contacts, and MongoDB diagnostics. The current implementation is compact and practical, but much of the app behavior is concentrated in a single handler and one Mongo service.

Use this document before changing existing behavior. It names the important files, flows, and dependencies so future changes can start from a shared mental model.

## Runtime Shape

- App root: `C:\BoxLang\jojo`
- Runtime launcher: `..\box.exe`
- Web server config: `server.json`
- Public webroot: `public`
- ColdBox config: `app/config/ColdBox.bx`
- Routes: `app/config/Router.bx`
- WireBox mapping: `app/config/WireBox.bx`
- Main app behavior: `app/handlers/Main.bx`
- Mongo persistence: `app/models/MongoService.bx`
- Server-rendered views: `app/views/main/*.bxm`
- Tests: `tests/specs/integration/*.bx`

The app uses CommandBox to launch `boxlang@1`. The server may bind to a dynamic port; use `..\box.exe server status` to find the actual URL.

## Request Flow

1. Incoming requests hit the CommandBox/BoxLang server.
2. ColdBox routing in `app/config/Router.bx` maps URLs to `Main` handler actions.
3. `Main.bx` reads `event` values, session state, and `MongoService`.
4. Handler actions populate `prc` and select views with `event.setView(...)`, or return JSON structs for diagnostic/API endpoints.
5. `.bxm` views render HTML with inline CSS and explicit output encoding.

## Route Map

Public and diagnostic routes:

- `GET /`: `Main.index`
- `GET /healthcheck`: inline route returns `Ok!`
- `/api/echo`: inline route returns a JSON-style struct
- `/mongo/ping`: `Main.mongoPing`
- `/mongo/login-table`: `Main.loginTable`
- `POST /login`: `Main.login`
- `POST /logout`: `Main.logout`

User routes:

- `GET /users`: `Main.userList`
- `POST /users`: `Main.createUser`
- `GET /users/new`: `Main.newUser`
- `GET /users/:id/edit`: `Main.editUser`
- `POST /users/:id`: `Main.updateUser`
- `POST /users/:id/delete`: `Main.deleteUser`

Contact routes:

- `GET /contacts`: `Main.contactList`
- `POST /contacts`: `Main.createContact`
- `GET /contacts/new`: `Main.newContact`
- `GET /contacts/:id/edit`: `Main.editContact`
- `POST /contacts/:id`: `Main.updateContact`
- `POST /contacts/:id/delete`: `Main.deleteContact`

Routing ends with a conventional fallback: `:handler/:action?`.

## Handler Responsibilities

`app/handlers/Main.bx` currently owns several concerns:

- Session-backed authentication.
- Protected-route guard through `requireSignedIn()`.
- Login form validation and authentication error handling.
- User CRUD orchestration.
- Contact CRUD orchestration.
- Dashboard aggregation from user/contact rows.
- Form defaults, request extraction, and validation.
- Mongo diagnostic endpoint responses.
- Empty implicit lifecycle handlers.

This concentration is the main brownfield pressure point. It makes behavior easy to find, but changes tend to touch a large file and private helper surface.

## Persistence Model

`app/models/MongoService.bx` uses the Java MongoDB driver directly.

Current collections:

- `users`
- `contacts`

User fields include `_id`, `email`, `username`, `passwordHash`, `firstName`, `lastName`, `roles`, `permissions`, `isActive`, `emailVerified`, `lastLoginAt`, reset-token fields, `createdAt`, and `updatedAt`.

Contact fields include `_id`, `firstName`, `lastName`, `mobileNumber`, `address`, `city`, `state`, `zip`, `createdAt`, and `updatedAt`.

Indexes are created in `ensureLoginCollection()` and `ensureContactsCollection()`. User list projection removes `passwordHash` and `passwordResetTokenHash`.

## UI Shape

The active pages are server-rendered views under `app/views/main`:

- `index.bxm`: anonymous login page and authenticated dashboard.
- `users.bxm`: user list table.
- `userForm.bxm`: create/edit user form.
- `contacts.bxm`: contact list table.
- `contactForm.bxm`: create/edit contact form.

Most styling is inline per view. `resources/vite` exists, but the current user-facing pages do not depend on a Vite build path for normal rendering.

## Testing Shape

The current TestBox integration suite is request-level and mocks `MongoService` at the WireBox boundary:

- `tests/resources/BaseIntegrationSpec.bx`
- `tests/specs/integration/MainSpec.bx`
- `tests/specs/integration/DashboardCrudSpec.bx`
- `tests/specs/integration/MongoEndpointSpec.bx`

Run:

```powershell
..\box.exe testbox run
```

Use `TEST_STRATEGY.md` for test-layer policy and definition of done.

## Change Patterns

Adding a user field usually requires:

1. `Main.bx`: default form, request extraction, validation.
2. `MongoService.bx`: document creation, edit mapping, list mapping.
3. `app/views/main/userForm.bxm`.
4. `app/views/main/users.bxm` if the field appears in lists.
5. Integration tests and fixtures in `tests/resources/BaseIntegrationSpec.bx`.

Adding a contact field follows the same path through the contact helpers, contact service mapping, and contact views.

Adding a new route should update:

1. `app/config/Router.bx`.
2. The target handler action.
3. Any view links or form actions.
4. Request-level tests.
5. Docs if it changes public behavior.

## Brownfield Cautions

- Do not edit `lib/` unless intentionally changing vendored dependencies.
- Treat `.env` as local runtime state; update `.env.example` for documented configuration.
- Keep `server.json` development conveniences out of production deployments.
- Validate ObjectId inputs before expanding ID-based flows.
- Preserve output encoding in views.
- Prefer mocked Mongo tests for normal regression coverage; use live Mongo tests only for explicit service smoke checks.

