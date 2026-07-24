# Jojo Project Scope

Status: Draft for approval  
Related requirements: `PRODUCT_REQUIREMENTS.md`  
Related design: `ARCHITECTURE.md`

## 1. Scope Statement

Deliver a production-ready internal portal for secure user and contact administration, using the existing BoxLang/ColdBox application and MongoDB as the starting point.

The project is a hardening and modularization effort, not a rewrite. Existing route URLs and server-rendered workflows remain stable unless a requirement explicitly changes them.

## 2. Current Baseline

Already implemented:

- Session-backed sign-in and sign-out.
- Authenticated dashboard with MongoDB record summaries.
- User list/create/edit/update/delete screens.
- Contact list/create/edit/update/delete screens and embedded map previews.
- MongoDB collections and indexes created from application code.
- Request-level TestBox coverage with a mocked Mongo service.
- Development health, Mongo diagnostic, Docker, Vite, and REST scaffold artifacts.

Known baseline gaps:

- Signed-in users have unrestricted access; roles and permissions are not enforced.
- POST routes do not have CSRF protection.
- Password hashing is custom rather than a standard adaptive implementation.
- Mongo ObjectIds are not validated before construction.
- Detailed diagnostics and test/debug surfaces are not production-gated.
- Lists and dashboard aggregates load whole collections.
- Session, audit, rate-limit, logging, backup, and production deployment policies are incomplete.
- UI structure and application responsibilities are duplicated or concentrated in large files.

## 3. In Scope For The Production Baseline

### Product Capability

- Confirm the product purpose, actors, access matrix, record volumes, privacy policy, and operating targets.
- Preserve sign-in, dashboard, user management, contact management, and sign-out workflows.
- Enforce viewer/operator/administrator permissions, or the approved equivalent.
- Add server-side pagination, filtering, and search to user and contact lists.
- Keep map previews only if third-party address sharing is approved; otherwise disable them cleanly.
- Improve validation, controlled not-found behavior, deletion confirmation, empty states, and safe failure messages.

### Security And Privacy

- CSRF protection on all state-changing browser requests.
- Standard adaptive password hashing with a backward-compatible migration path for existing hashes.
- Session rotation, secure cookie configuration, idle/absolute timeout policy, and login throttling.
- Central authentication and authorization enforcement.
- ObjectId, email, field length, role, permission, phone, and address validation.
- Environment-gated diagnostics, tests, debugger settings, and detailed exception views.
- Security headers and a Content Security Policy that accounts for any approved map provider.
- Audit events for authentication and user/contact writes.
- Secret and personal-data redaction in logs.

### Architecture And Maintainability

- Split the all-purpose handler into focused auth, dashboard, user, contact, and diagnostic handlers.
- Extract form mapping/validation, authorization policy, password behavior, repositories, and Mongo client lifecycle.
- Keep a modular monolith and server-rendered views.
- Consolidate shared navigation, form, and CSS assets without introducing a SPA requirement.
- Retain MongoDB and define indexes that support the approved pagination/search patterns.
- Remove or quarantine unused template actions and REST/Vite scaffolds from the deployable artifact.

### Quality And Operations

- Unit tests for validation, policy, password, and mapping behavior.
- Request tests for all roles, CSRF, validation, CRUD, and safe failures.
- Small live-Mongo smoke coverage against a test-only database.
- Browser smoke and accessibility checks for core workflows.
- Reproducible production configuration and versioned build artifact.
- Liveness/readiness endpoints, structured logging, request correlation, and operational runbooks.
- Backup, restore, deployment, rollback, and initial-user bootstrap procedures.

## 4. Out Of Scope For The Production Baseline

- AI chat, generation, model integration, or other “AI” capability until a use case is defined.
- A public or partner REST API; `resources/rest` is treated as unused scaffold code.
- Public self-registration, invitations, or social/enterprise SSO.
- An end-to-end password-recovery flow unless product ownership promotes it into the release.
- Multi-tenancy or organization-level data partitioning.
- Native mobile applications or a single-page application rewrite.
- Bulk import/export, contact deduplication, campaign management, or notifications.
- Persistent geocoding, route planning, or custom mapping infrastructure.
- SQL persistence; the configured MySQL datasource is not part of current application behavior.
- Horizontal scaling until a shared session/rate-limit design is approved.

Out-of-scope items must not be implied by nonfunctional links, scaffold endpoints, environment placeholders, or branding.

## 5. Delivery Workstreams

### Phase 0: Product And Operational Decisions

Outputs:

- Approved product statement and actor/permission matrix.
- Confirmed field requirements and map/privacy decision.
- Record-volume, performance, availability, RPO/RTO, retention, browser, and hosting targets.
- Prioritized requirements with owners and release date.

Exit criteria:

- The open decisions in `PRODUCT_REQUIREMENTS.md` and `ARCHITECTURE.md` have owners and due dates.

### Phase 1: Safety Baseline

Outputs:

- Characterization tests for uncovered current behavior.
- Production route/config separation.
- ObjectId validation, safe error handling, security logging, security headers, and protected diagnostics.
- CSRF, session hardening, rate limiting, and authorization foundations.
- Password service and legacy-hash migration strategy.

Exit criteria:

- P0 security requirements pass automated negative tests.
- Existing business workflows remain functional.

### Phase 2: Modularization

Outputs:

- Focused handlers and authorization interceptor/policy.
- User/contact form services and repositories.
- Dedicated password and Mongo client lifecycle services.
- Shared layout/navigation/styles.
- Unit tests around extracted boundaries.

Exit criteria:

- Route contracts remain stable.
- `Main.bx` and `MongoService.bx` no longer own unrelated concerns.
- The full regression suite is green.

### Phase 3: Production Usability And Scale

Outputs:

- Server-side pagination, search, and supporting MongoDB indexes.
- Optimized dashboard aggregation.
- Permission-aware UI, confirmation flows, accessible errors/focus, and approved map behavior.
- Auditing for writes and authentication events.

Exit criteria:

- P1 functional and nonfunctional acceptance criteria pass at the agreed data volume.

### Phase 4: Release Readiness

Outputs:

- Pinned production image/artifact and environment configuration.
- CI checks, deployment/rollback, liveness/readiness, dashboards/alerts, and incident runbook.
- Backup/restore evidence and an initial-administrator bootstrap procedure.
- Security, accessibility, and product-owner acceptance reports.

Exit criteria:

- The release acceptance checklist in `PRODUCT_REQUIREMENTS.md` is complete or has recorded waivers.

## 6. Required Deliverables

| Deliverable | Owner | Approval |
| --- | --- | --- |
| Product requirements and access matrix | Product owner | Product and security |
| Architecture and architecture decisions | Technical lead | Engineering and operations |
| Threat model and remediation evidence | Security/engineering | Security |
| Tested application artifact | Engineering | QA/product |
| Production configuration and secret inventory | Operations | Operations/security |
| Migration/bootstrap/backup/restore procedures | Engineering/operations | Operations |
| Test, accessibility, and release reports | QA/engineering | Product |
| Deployment, rollback, monitoring, and incident runbooks | Operations | Operations |

Named people and dates are intentionally TBD.

## 7. Dependencies And Constraints

- The codebase uses BoxLang 1.x, ColdBox 8, Java 21, CommandBox, TestBox, and the MongoDB Java sync driver 5.8.0.
- Local runtime artifacts use MongoDB 8.x while Docker scaffolding references MongoDB 7; production and test versions must be deliberately selected and pinned.
- The MongoDB Java driver JARs are vendored under `lib/java`; their build/update process must remain reproducible.
- Current sessions are stored in application memory. Restarts sign users out, and multiple instances would not share session state.
- Current pages use server-rendered `.bxm` templates with substantial inline CSS.
- CommandBox can select a dynamic local port; development validation should query `server status`.
- `.env` is local state and must never become a production secret store or deployable artifact.
- The project should avoid changing `lib/` except through an intentional dependency update.

## 8. Risks And Responses

| Risk | Impact | Planned response |
| --- | --- | --- |
| Product purpose or role policy remains ambiguous. | Rework or unsafe access rules. | Complete Phase 0 before final authorization implementation. |
| Existing custom hashes cannot be migrated in bulk. | Users cannot sign in after a hash change. | Verify the legacy hash, then rehash with the approved algorithm after a successful login. |
| Whole-collection reads grow beyond memory/latency targets. | Slow pages and service instability. | Add bounded queries, indexes, and Mongo aggregation before production volume grows. |
| Refactoring changes existing routes or form behavior. | User disruption and regression. | Characterization tests first; extract in small route-preserving increments. |
| Address map embeds disclose personal data to a third party. | Privacy/compliance incident. | Obtain approval, feature-flag the integration, and provide a no-map mode. |
| In-memory sessions conflict with high availability. | Sign-outs or inconsistent authorization. | Start with one instance or approve a shared session store before scaling. |
| Runtime/dependency versions drift. | Non-reproducible failures or vulnerabilities. | Pin artifacts and automate dependency/security review. |
| Production config inherits development aliases/debugging. | Information disclosure. | Use separate production config and automated exposure checks. |

## 9. Change Control

A proposed feature enters the production-baseline scope only when it has:

- A requirement ID and priority.
- An owner and acceptance criteria.
- Security/privacy and data-shape impact review.
- Architecture and operational impact review.
- Test impact and delivery estimate.
- Product-owner approval, including what existing work moves out if schedule is fixed.

## 10. Definition Of Done

A scoped item is done only when:

- Implementation and permission enforcement match its acceptance criteria.
- Unit/request/integration/browser checks appropriate to the risk pass.
- Error, empty, unauthorized, and unavailable states are covered.
- Logs and audit events are useful and contain no secrets or unnecessary personal data.
- Documentation, configuration examples, and runbooks are updated.
- The change is demonstrated in a production-like environment and can be rolled back.

