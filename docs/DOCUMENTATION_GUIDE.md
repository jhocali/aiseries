# Documentation Guide

## Audience

Write documentation for future maintainers changing an existing brownfield app. Assume they know ColdBox/BoxLang basics, but not this app's route map, Mongo schema, test harness, or development quirks.

## Where Documentation Lives

- `readme.md`: project-facing overview from the template; update only when the broad project workflow changes.
- `TEST_STRATEGY.md`: testing policy and commands.
- `docs/`: brownfield comprehension, refactoring, security, and maintenance docs.
- `.codex/skills/jojo-boxlang-app/`: AI-agent project guidance.
- `.env.example`: documented environment variables only, no secrets.
- Tests: executable documentation for request behavior and edge cases.

## Documentation Update Checklist

Update docs when a change affects:

- Public routes or form actions.
- Authentication/session behavior.
- User or contact field shape.
- MongoDB collection names, indexes, or environment variables.
- Server startup, port discovery, or deployment config.
- Test commands, test helpers, or live-service test policy.
- Security controls or threat assumptions.

## Feature Documentation Template

Use this structure for a new feature doc or README section:

```markdown
## Feature Name

Purpose:

Primary files:

Routes:

Data shape:

Authentication/authorization:

Validation rules:

Failure behavior:

Tests:

Operational notes:
```

Keep examples short and name exact files.

## Route Documentation Rules

For each route, document:

- HTTP method and path.
- Handler action.
- Whether it requires authentication.
- Main request fields.
- Success behavior.
- Main failure behavior.
- Tests that cover it.

Example:

```markdown
- `POST /users`: `Main.createUser`
  - Auth: signed-in user required; future admin authorization recommended.
  - Request fields: username, email, firstName, lastName, roles, permissions, password, isActive, emailVerified.
  - Success: creates a user through `MongoService` and redirects to `/users`.
  - Failure: renders `main/userForm` with status 400 and validation/create error text.
  - Tests: `tests/specs/integration/DashboardCrudSpec.bx`.
```

## Code Comment Guidance

- Prefer clear function names over comments.
- Add comments only for non-obvious business rules, security decisions, or framework quirks.
- Avoid comments that repeat the code.
- If a comment explains a risky decision, include what would need to change to remove that risk.

## Brownfield Notes To Preserve

- CommandBox can choose a dynamic port; use `..\box.exe server status`.
- CommandBox/TestBox may need access to `C:\Users\gmateo\.CommandBox`.
- BoxLang string interpolation uses `#`; literal HTML entities containing `#` need escaping inside BoxLang string literals.
- TestBox request-level checks should use `event.getStatusCode()` for handler-set statuses.
- Inline route closures may not behave exactly like handler actions in request harness rendering; use live server smoke checks for `/healthcheck` if needed.

## Review Checklist For Documentation PRs

- Links point to current files.
- Commands run from `C:\BoxLang\jojo`.
- No secrets or local-only credentials are included.
- Security-sensitive claims are phrased as current-state observations unless verified by tests.
- Test references name exact spec files.
- Docs explain why a maintainer should care, not just what exists.

