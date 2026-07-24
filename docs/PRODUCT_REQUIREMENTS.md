# Jojo Product Requirements

Status: Draft for product-owner review  
Planning baseline: 2026-07-10  
Target release: Production-ready internal portal (release name and date TBD)

## 1. Product Definition

Jojo is an internal administration portal for authenticated staff to:

- View a summary of user and contact records.
- Manage application user accounts.
- Manage contact records and view their locations.
- Check limited application health information.

This definition is inferred from the working application. No implemented AI workflow, public API consumer, public registration flow, or multi-tenant behavior was found. Those capabilities are not assumed to be product requirements.

## 2. Product Goal

Turn the existing brownfield application into a secure, supportable portal that lets authorized staff manage users and contacts without direct MongoDB access.

The first production release should preserve the recognizable server-rendered experience while closing the security and operational gaps documented in `SECURITY_REVIEW.md`.

## 3. Evidence And Assumptions

Verified current behavior:

- The application runs on BoxLang and ColdBox 8.
- Authentication accepts a username or email and stores the authenticated user in the session.
- Active, email-verified users can sign in.
- Signed-in users can currently perform all user and contact CRUD operations.
- The dashboard summarizes user status and contacts by state.
- MongoDB stores `users` and `contacts`.
- Contact addresses are embedded in Google Maps URLs in the browser.
- Detailed Mongo diagnostic routes are currently public.

Planning assumptions that require confirmation:

- The portal is for internal staff rather than the general public.
- `admin`, `operator`, and `viewer` are sufficient initial access profiles.
- The initial production deployment can run as one application instance.
- English and United States-style contact addresses are sufficient for the first release.
- Existing route URLs should remain stable during hardening and refactoring.

## 4. Actors And Access

| Actor | Intended access |
| --- | --- |
| Anonymous visitor | Sign-in page and minimal liveness response only. |
| Viewer | Dashboard plus read-only user and contact lists. |
| Operator | Viewer access plus contact create, update, and delete. |
| Administrator | Full user and contact management plus private diagnostics. |
| System operator | Deployment, configuration, logs, backup/restore, and readiness checks; no application account implied. |

Role names are a proposal. Enforcement should use permissions so roles can change without rewriting handlers.

Proposed permission vocabulary:

- `dashboard:read`
- `users:read`, `users:write`
- `contacts:read`, `contacts:write`
- `diagnostics:read`

## 5. Priority Definitions

- P0: Required to release safely.
- P1: Required for a usable production baseline.
- P2: Valuable follow-up after the baseline is stable.

## 6. Functional Requirements

### Authentication And Session

| ID | Priority | Requirement | Acceptance summary |
| --- | --- | --- | --- |
| AUTH-01 | P0 | A user can sign in with username or email and password. | Valid active and verified credentials create an authenticated session and redirect to the dashboard. |
| AUTH-02 | P0 | Invalid, inactive, or unverified accounts cannot establish a session. | The response does not reveal a password, hash, or internal exception; authentication attempts are auditable. |
| AUTH-03 | P0 | Protected routes require an authenticated session. | Anonymous HTML requests redirect to sign-in; protected non-HTML requests return an appropriate 401 response. |
| AUTH-04 | P0 | A user can sign out. | The server invalidates the authenticated session and returns the browser to sign-in. |
| AUTH-05 | P0 | Session identity is rotated after successful sign-in. | A pre-login session identifier cannot be reused as the authenticated session identifier. |
| AUTH-06 | P0 | Login attempts are rate limited. | Repeated failures are slowed or rejected without blocking normal use; no plaintext credentials are logged. |
| AUTH-07 | P1 | Session lifetime and cookie behavior are environment-configurable. | Production cookies are Secure, HttpOnly, and SameSite; idle and absolute timeouts are documented. |
| AUTH-08 | P2 | Password recovery may be added after an email-delivery and identity-verification policy is approved. | The current nonfunctional “Forgot password?” link is hidden until an end-to-end flow exists. |

### Authorization

| ID | Priority | Requirement | Acceptance summary |
| --- | --- | --- | --- |
| AUTHZ-01 | P0 | Every protected action enforces a named permission on the server. | Hiding a UI control is not the only enforcement; unauthorized requests return 403. |
| AUTHZ-02 | P0 | Only administrators can create, change, or delete user accounts. | Viewer and operator attempts fail without changing data. |
| AUTHZ-03 | P0 | Operators and administrators can manage contacts; viewers are read-only. | Each route is covered by allowed and denied request tests. |
| AUTHZ-04 | P0 | The system prevents removal or deactivation of the last active administrator. | A guarded operation returns a clear error and leaves the account unchanged. |
| AUTHZ-05 | P1 | Navigation and actions reflect the current user's permissions. | Users do not see controls they cannot use, while server-side checks remain authoritative. |

### Dashboard

| ID | Priority | Requirement | Acceptance summary |
| --- | --- | --- | --- |
| DASH-01 | P1 | Authorized users can view user, contact, and total-record counts. | Counts reflect persisted records and links lead to permitted lists. |
| DASH-02 | P1 | The dashboard shows active/verified user status and contacts grouped by state. | Empty datasets render a valid empty state without division or rendering errors. |
| DASH-03 | P1 | A persistence failure produces a safe, actionable page state. | The page does not expose connection strings, stack traces, or MongoDB details. |

### User Administration

| ID | Priority | Requirement | Acceptance summary |
| --- | --- | --- | --- |
| USER-01 | P1 | Authorized users can list accounts without password or reset-token fields. | Results contain identity, profile, role, status, and activity fields only. |
| USER-02 | P1 | Administrators can create a user. | Username, valid normalized email, role, and a policy-compliant password are required; username and email are unique. |
| USER-03 | P1 | Administrators can edit a user. | Profile, roles, permissions, active state, and verified state can change; a blank password preserves the current hash. |
| USER-04 | P1 | Administrators can delete a user subject to administrator-safety rules. | Existing records delete successfully; missing/invalid IDs return a controlled 404 or 400. |
| USER-05 | P1 | User lists support server-side pagination and search. | Page size is bounded; search covers username, email, and name without loading all users into memory. |
| USER-06 | P1 | User writes are audited. | Actor, action, target, outcome, timestamp, and request ID are recorded without sensitive field values. |

### Contact Administration

| ID | Priority | Requirement | Acceptance summary |
| --- | --- | --- | --- |
| CONTACT-01 | P1 | Authorized users can list contacts. | Results are sorted predictably and support a valid empty state. |
| CONTACT-02 | P1 | Operators and administrators can create a contact. | Required contact fields are validated and normalized before persistence. |
| CONTACT-03 | P1 | Operators and administrators can edit a contact. | Valid changes persist; missing/invalid IDs return a controlled 404 or 400. |
| CONTACT-04 | P1 | Operators and administrators can delete a contact. | The action requires CSRF protection and records an audit event. |
| CONTACT-05 | P1 | Contact lists support server-side pagination and search. | Page size is bounded; search covers name, mobile number, city, state, and ZIP. |
| CONTACT-06 | P1 | Map previews comply with the approved privacy policy. | The feature can be disabled by configuration and does not send an address to a third party until the policy permits it. |

### Operations And Diagnostics

| ID | Priority | Requirement | Acceptance summary |
| --- | --- | --- | --- |
| OPS-01 | P0 | The service exposes a minimal liveness endpoint. | It reports only whether the application process can answer and reveals no database metadata. |
| OPS-02 | P0 | The service exposes a readiness check for deployment tooling. | MongoDB failure makes the instance unready; detailed output is not public. |
| OPS-03 | P0 | Detailed diagnostics are development-only or require `diagnostics:read`. | Anonymous production requests cannot read datasource, database, schema, or exception details. |
| OPS-04 | P0 | Production configuration excludes debugger and test-runner exposure. | `/tests`, debug arguments, and development exception pages are absent in production. |
| OPS-05 | P1 | Operators can correlate requests, errors, authentication events, and data changes. | Logs and audit events share a request ID and redact secrets and contact details. |

## 7. Business Rules And Validation

- Email is trimmed and stored lowercase; it must pass email-format validation.
- Username is trimmed, compared according to an explicitly documented case policy, and unique.
- New passwords must follow an approved length/strength policy and use a standard adaptive password hash.
- An inactive user cannot sign in.
- An unverified user cannot sign in unless product policy removes the verification requirement.
- Roles and permissions are stored as normalized arrays, not unchecked comma-separated values.
- Contact first name, last name, mobile number, address, city, state, and ZIP are currently required. Internationalization may change this rule later.
- IDs must be validated as MongoDB ObjectIds before repository calls.
- Every state-changing browser request requires a valid CSRF token.
- Delete actions require explicit confirmation in the UI.

## 8. Nonfunctional Requirements

The numeric values below are planning targets and should be confirmed before implementation.

| ID | Category | Target |
| --- | --- | --- |
| NFR-SEC-01 | Security | Follow OWASP-aligned controls: adaptive password hashing, CSRF defense, server-side authorization, output encoding, security headers, rate limiting, secure cookies, and secret redaction. |
| NFR-SEC-02 | Privacy | Treat user identity and contact/address data as sensitive; do not place it in logs, URLs other than an approved map integration, or analytics. |
| NFR-PERF-01 | Response time | For up to 10,000 users and 50,000 contacts, p95 server response time is under 500 ms for paged lists and under 1 second for dashboard aggregation, excluding cold start and third-party maps. |
| NFR-PERF-02 | Capacity | List endpoints fetch no more than 100 rows per request; default page size is 25. |
| NFR-REL-01 | Availability | Initial monthly service objective is 99.5%, excluding announced maintenance. |
| NFR-REL-02 | Recovery | Proposed targets are RPO <= 24 hours and RTO <= 4 hours, proven by a restore exercise before release. |
| NFR-ACC-01 | Accessibility | Core sign-in, dashboard, list, create, edit, and delete flows meet WCAG 2.1 AA keyboard, label, focus, contrast, and error-identification expectations. |
| NFR-COMP-01 | Compatibility | Support the latest two stable versions of Chrome, Edge, Firefox, and Safari at release time; final browser policy is TBD. |
| NFR-OBS-01 | Observability | Structured logs contain timestamp, level, environment, request ID, route, status, duration, and safe error code. |
| NFR-MAINT-01 | Maintainability | Handlers orchestrate HTTP behavior; validation, policy, password, and repository behavior have focused services and unit tests. |
| NFR-TEST-01 | Quality | Every route has happy-path and primary guard/failure coverage; security controls have explicit negative tests. |
| NFR-DEP-01 | Deployability | A versioned, reproducible artifact is promoted between environments; runtime, driver, and container versions are pinned. |

## 9. Release Acceptance

The production baseline is acceptable when:

- All P0 and P1 requirements are implemented or explicitly waived by the product owner.
- Anonymous, viewer, operator, and administrator access tests pass.
- CSRF, password hashing, ID validation, rate limiting, session rotation, and security headers are verified.
- Public endpoints disclose no MongoDB metadata, stack traces, test runners, or debugger interfaces.
- User and contact CRUD, pagination, search, dashboard, empty states, and failure states pass request-level tests.
- Backup and restore, deployment rollback, liveness, readiness, and log correlation are demonstrated in a non-production environment.
- Accessibility smoke testing covers all core workflows.
- `SECURITY_REVIEW.md`, `TEST_STRATEGY.md`, runbooks, and environment documentation reflect the shipped behavior.

## 10. Product Decisions Needed

1. Is the inferred internal administration portal the intended product, and what does “Jojo AI” mean for the roadmap?
2. Which people need viewer, operator, and administrator access?
3. Is email verification a real business process or only a stored status flag?
4. Should self-deletion ever be allowed?
5. Is Google Maps an approved processor for contact addresses?
6. What record volumes, availability target, backup target, and data-retention rules are expected?
7. Is a password-recovery flow required for the first release?
8. Which production hosting environment and identity/email services are available?

