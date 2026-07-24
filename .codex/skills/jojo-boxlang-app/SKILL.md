---
name: jojo-boxlang-app
description: 'Project-specific guidance for working on the Jojo BoxLang/ColdBox application in C:\BoxLang\jojo. Use when changing, reviewing, testing, or troubleshooting this app''s routes, handlers, views, MongoDB service, CommandBox server, Vite assets, TestBox specs, or environment configuration.'
---

# Jojo BoxLang App

## Start Here

- Work from `C:\BoxLang\jojo`.
- Read `references/project-map.md` before making non-trivial app changes, especially changes involving routes, MongoDB, login/session behavior, users, contacts, tests, or local server startup.
- Prefer the existing ColdBox conventions: handlers in `app/handlers`, views in `app/views`, models in `app/models`, routes in `app/config/Router.bx`, and public assets under `public`.
- Keep edits out of `lib/` unless the user explicitly asks to modify vendored dependencies.

## Local Server

- Start the app with `..\box.exe server start` from `C:\BoxLang\jojo`.
- Get the actual bound URL with `..\box.exe server status`; this server may choose a dynamic port instead of `8080`.
- If CommandBox reports access problems under the user profile, rerun the same CommandBox command with approval/escalation so it can use its runtime files.
- Verify health with `/healthcheck` and app rendering with the URL reported by `server status`.

## Development Workflow

- Inspect `app/handlers/Main.bx`, `app/models/MongoService.bx`, `app/config/Router.bx`, and the relevant `app/views/main/*.bxm` files before changing behavior.
- Update routes and handler methods together; keep route names and form actions aligned.
- For data changes, update `MongoService.bx` collection/index/schema helpers plus any form defaults, validators, list renderers, and tests that depend on the shape.
- For UI-only changes, prefer editing the server-rendered `.bxm` views unless the request specifically targets Vite/Vue assets in `resources/vite`.
- Validate with the narrowest useful check first, then broaden to TestBox or browser/server checks when behavior or routing changes.

## Testing

- Use TestBox specs under `tests/specs`.
- Run CommandBox/TestBox commands from `C:\BoxLang\jojo`; they may need the same profile access as `server start`.
- Re-check scaffold-generated assertions against current behavior before relying on them, because the app has evolved beyond the original ColdBox template.
