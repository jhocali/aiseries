# Jojo Project Map

## App Shape

- Root: `C:\BoxLang\jojo`
- Runtime: BoxLang app on ColdBox 8, launched through local `..\box.exe`.
- Package/config files:
  - `box.json`: CommandBox package, dependencies, scripts, TestBox runner.
  - `server.json`: CommandBox server config, `boxlang@1`, webroot `public`, rewrites enabled, debugger on port `8889`, `openbrowser` false.
  - `runtime/boxlang.json`: BoxLang runtime mappings, datasource examples, Mongo config.
  - `.env.example`: APP/ENV, BoxLang debug, SQL placeholders, MongoDB settings.
- Public webroot: `public`.
- Do not treat `lib/coldbox`, `lib/testbox`, or `lib/modules` as app source.

## Main Routes

Routes live in `app/config/Router.bx`.

- `GET /healthcheck`: inline `"Ok!"`.
- `/api/echo`: inline JSON echo.
- `/mongo/ping`: `main.mongoPing`.
- `/mongo/login-table`: `main.loginTable`.
- `POST /login`: `Main.login`.
- `POST /logout`: `Main.logout`.
- User CRUD:
  - `GET /users`: `Main.userList`
  - `POST /users`: `Main.createUser`
  - `GET /users/new`: `Main.newUser`
  - `GET /users/:id/edit`: `Main.editUser`
  - `POST /users/:id`: `Main.updateUser`
  - `POST /users/:id/delete`: `Main.deleteUser`
- Contact CRUD:
  - `GET /contacts`: `Main.contactList`
  - `POST /contacts`: `Main.createContact`
  - `GET /contacts/new`: `Main.newContact`
  - `GET /contacts/:id/edit`: `Main.editContact`
  - `POST /contacts/:id`: `Main.updateContact`
  - `POST /contacts/:id/delete`: `Main.deleteContact`
- Conventional fallback: `:handler/:action?`.

Keep `formAction` values in `Main.bx` and action URLs in views synchronized with these routes.

## Handler Responsibilities

`app/handlers/Main.bx` owns:

- Homepage/dashboard rendering.
- Login/logout and `session.authUser`.
- User list/create/edit/update/delete flows.
- Contact list/create/edit/update/delete flows.
- Mongo diagnostic endpoints.
- Form defaults, request extraction, validation, and dashboard aggregate helpers.

Authentication guard:

- `requireSignedIn()` redirects anonymous users to `/`.
- Protected user/contact actions expect `session.authUser`.
- Login accepts username or email, requires active and verified users.

When adding fields:

1. Update `defaultUserForm()` or `defaultContactForm()`.
2. Update `userFormFromRequest()` or `contactFormFromRequest()`.
3. Update validators.
4. Update render views and list views.
5. Update `MongoService.bx` document/form/list mapping.
6. Add or adjust tests.

## Mongo Service

`app/models/MongoService.bx` uses Java MongoDB driver classes directly.

- Defaults:
  - datasource: `MONGODB_DATASOURCE` or `jomongo`
  - URI: `MONGODB_URI` or local `mongodb://127.0.0.1:27017/?connectTimeoutMS=2000&serverSelectionTimeoutMS=2000`
  - database: `MONGODB_DATABASE` or datasource name
- Collections:
  - `users`
  - `contacts`
- `ensureLoginCollection()` creates user indexes and documents the expected user fields.
- `ensureContactsCollection()` creates contact indexes and documents the expected contact fields.
- Passwords use an app-local `sha256-iterated$iterations$salt$digest` format.

Be careful with ObjectId conversion:

- `objectId(id)` constructs `org.bson.types.ObjectId`.
- Invalid IDs can throw before a not-found branch runs; validate or catch if adding user-facing paths that accept arbitrary IDs.

## Views

Server-rendered views live in `app/views/main`.

- `index.bxm`: login/dashboard/homepage.
- `users.bxm`: user list.
- `userForm.bxm`: create/edit user form.
- `contacts.bxm`: contact list.
- `contactForm.bxm`: create/edit contact form.
- `indexHelper.bxm` and `jotest.cfml`: legacy/helper/template artifacts; inspect before using them as current behavior.
- `app/layouts/Main.bxm`: layout shell.

Most current UI is inline CSS inside `.bxm` views. Preserve existing visual language unless the user asks for a redesign.

## Frontend Assets

`resources/vite` is a separate Vite/Vue/Tailwind workspace.

- `npm run dev`: Vite dev server, normally `localhost:5173`.
- `npm run build`: build assets to `public/includes`.
- ColdBox can load Vite assets through helper usage in layouts/views if wired in.

Only use this path for requests that actually involve Vite/Vue/Tailwind assets; most current pages are server-rendered.

## Testing And Validation

- Test runner config: `box.json` has `testbox.runner` set to `/tests/runner.bxm`.
- Integration specs: `tests/specs/integration/MainSpec.bx`.
- The existing integration spec includes scaffold-era expectations; verify and update it when app behavior changes.
- Useful checks:
  - `..\box.exe server status`
  - `Invoke-WebRequest -UseBasicParsing -Uri <server-url>/healthcheck`
  - `Invoke-WebRequest -UseBasicParsing -Uri <server-url>/mongo/ping`
  - `..\box.exe testbox run`

CommandBox may require access to `C:\Users\gmateo\.CommandBox`; use escalation when the sandbox blocks it.
