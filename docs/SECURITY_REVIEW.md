# Security Review

Review date: 2026-07-10

## Scope

Reviewed local application code and configuration for:

- Authentication and session behavior.
- User/contact CRUD routes.
- MongoDB access patterns.
- Diagnostic endpoints.
- Server/test configuration.
- View output encoding.

This is a brownfield code review, not a penetration test.

## Assets

- User credentials and password hashes.
- Session-backed authenticated user identity.
- User records, roles, permissions, and email addresses.
- Contact records, including phone numbers and addresses.
- MongoDB URI and database contents.
- Test and diagnostic endpoints.

## Trust Boundaries

- Browser to ColdBox routes.
- ColdBox handler to `MongoService`.
- BoxLang app to MongoDB Java driver.
- Development server config to local runtime.
- Test runner routes exposed through server aliases.

## Existing Positive Controls

- Views use explicit encoding such as `encodeForHTML()` and `encodeForHTMLAttribute()`.
- Mongo queries are built with driver `Document` objects rather than string-concatenated query text.
- `listUsers()` excludes `passwordHash` and `passwordResetTokenHash`.
- User emails are normalized to lowercase in persistence/auth paths.
- Login failure messages are generic for bad credentials.
- Unique indexes exist for user email and username.
- The current TestBox suite characterizes authentication, guard, validation, CRUD, and diagnostic behavior.

## Key Risks

### High: No CSRF Protection On POST Routes

State-changing routes use plain POST forms:

- `/login`
- `/logout`
- `/users`
- `/users/:id`
- `/users/:id/delete`
- `/contacts`
- `/contacts/:id`
- `/contacts/:id/delete`

Risk: another site may be able to trigger state-changing actions from an authenticated browser.

Recommended fix:

- Add CSRF token generation and validation through ColdBox/security middleware or a small app service.
- Include tokens in all forms.
- Add tests for missing/invalid token rejection.

### High: Authorization Is Only Signed-In Versus Anonymous

`requireSignedIn()` protects user and contact routes, but there is no role or permission check.

Risk: any signed-in user can manage users and contacts, including deleting their own or other accounts.

Recommended fix:

- Define role/permission policy.
- Add `requirePermission()` or route-level authorization interceptor.
- Start with user-management actions requiring an admin role.

### High: Custom Password Hashing

Passwords use an app-local `sha256-iterated$iterations$salt$digest` format.

Risk: custom password hashing is easier to misconfigure than a well-reviewed adaptive password hashing primitive.

Recommended fix:

- Extract `PasswordService.bx`.
- Migrate to a standard adaptive hashing strategy supported by the runtime/platform.
- Keep backward verification during migration if existing hashes must remain valid.
- Add unit tests for verify, reject malformed hash, and upgrade-on-login behavior.

### High: Public Diagnostic Endpoints

`/mongo/ping` and `/mongo/login-table` are routable without `requireSignedIn()`.

Risk: unauthenticated users can discover datasource/database names, connection status, and schema metadata.

Recommended fix:

- Gate diagnostics behind development environment checks or admin authorization.
- Return minimal health status publicly, and keep detailed diagnostics private.

### High: Development Server Settings Exposed In Config

`server.json` includes debugger args and aliases `/tests` to the test runner.

Risk: if used outside local development, debugger/test surfaces may expose sensitive code or behavior.

Recommended fix:

- Maintain a separate production server config.
- Disable debugger args, test aliases, and development exception pages outside development.
- Document which config is safe for local-only use.

### Medium: ObjectId Input Is Not Validated

ID-based routes pass URL IDs into `org.bson.types.ObjectId`.

Risk: malformed IDs can throw exceptions before friendly not-found handling runs.

Recommended fix:

- Add an ObjectId validation helper before calling repository methods.
- Return 404 or 400 consistently for invalid IDs.
- Add tests for malformed IDs on edit/update/delete routes.

### Medium: Login Has No Rate Limiting Or Lockout

Login checks credentials directly with no throttling or audit trail.

Risk: credential stuffing or brute-force attempts can be attempted at application speed.

Recommended fix:

- Add rate limiting by IP and identifier.
- Add optional account lockout or stepped-up verification.
- Log failed login attempts without logging passwords.

### Medium: Session Hardening Is Not Explicit

Authentication stores `session.authUser`, but session fixation, cookie flags, timeout, and rotation behavior are not documented in app code.

Risk: secure session behavior depends on runtime defaults and deployment config.

Recommended fix:

- Document session cookie settings for each environment.
- Rotate or refresh session identity on successful login if supported by the platform.
- Keep session payload minimal.

### Medium: Broad Catch Blocks Hide Operational Signals

Many handler paths catch `any e` and return generic messages.

Risk: user-facing errors are safe, but operators may lack enough logged context to diagnose incidents.

Recommended fix:

- Add structured logging with request IDs.
- Log exception type and operation, not secrets or passwords.
- Keep user-facing messages generic.

### Medium: Security Headers Are Not Evident

No app-level security header policy is visible in the reviewed files.

Risk: missing headers may weaken browser protections.

Recommended fix:

- Add Content-Security-Policy, X-Content-Type-Options, Referrer-Policy, frame protection, and cookie flags at server or app level.
- Test at least smoke-level header presence.

### Low: `.env.example` Contains Development Defaults

`.env.example` uses local database defaults and `BOXLANG_DEBUG=true`.

Risk: safe for onboarding, but risky if copied unchanged into shared environments.

Recommended fix:

- Mark development-only defaults clearly.
- Provide production config notes in docs without committing secrets.

## Security Backlog

1. Protect diagnostics and `/tests` from non-development use.
2. Add CSRF tokens to POST forms.
3. Add authorization policy for user/contact management.
4. Extract and replace password hashing.
5. Validate ObjectId inputs.
6. Add login rate limiting.
7. Add security headers.
8. Add structured security logging.
9. Document production server config and environment requirements.
10. Add security-focused tests for the controls above.

## Security Test Ideas

- Anonymous users cannot access `/users`, `/contacts`, or form pages.
- Non-admin signed-in users cannot create/update/delete users.
- Missing CSRF token rejects every state-changing route.
- Invalid ObjectId returns a controlled status instead of throwing.
- `/mongo/ping`, `/mongo/login-table`, and `/tests` are unavailable outside development.
- Password hashes are never rendered or returned in user list payloads.

