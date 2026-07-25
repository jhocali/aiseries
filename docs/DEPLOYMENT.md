# Jojo Deployment

## Deployment Baseline

Jojo is packaged as one OCI container and published to GitHub Container Registry (GHCR). The production-oriented baseline assumes:

- One Jojo application instance because sessions are stored in process memory.
- TLS terminates at a platform ingress or reverse proxy.
- MongoDB is externally managed, authenticated, backed up, and reachable over a private network.
- The MongoDB URI is mounted as a secret file for Compose or stored as an Azure Container Apps secret.
- The host retains the previous immutable image tag or digest for rollback.

Azure Container Apps Consumption is the selected low-traffic cloud target. The Compose path remains available for a self-managed host. Neither path provisions MongoDB or implements a shared session store.

## Deployment Files

| File | Purpose |
| --- | --- |
| `Dockerfile` | Builds the production OCI image from a pinned CommandBox/BoxLang base image. |
| `.dockerignore` | Excludes source-control metadata, tests, docs, local databases, logs, and secrets from the image context. |
| `server.production.json` | Pins the ColdBox production environment, blocks internal paths, and maps server errors to a generic page. |
| `runtime/boxlang.production.json` | Enables production caches and JSON console logging without test mappings, and registers ColdBox's appender directory for LogBox's unqualified appender lookup. |
| `deploy/compose.production.yml` | Runs one immutable Jojo image with a file-mounted MongoDB URI. |
| `deploy/deploy.ps1` | Validates Compose, pulls the image, starts it, waits for health, and prints diagnostics on failure. |
| `deploy/azure/main.bicep` | Defines the Consumption environment, scale-to-zero Container App, secret, ingress, probes, and one-replica limit. |
| `deploy/azure/deploy.ps1` | Deploys the Bicep definition from an authenticated Azure CLI session and verifies `/healthcheck`. |
| `.github/workflows/build-release.yml` | Tests, validates Bicep, builds and smoke-tests the image, publishes GHCR images, and creates tagged releases. |
| `.github/workflows/deploy-azure.yml` | Manually deploys a published GHCR image to Azure through GitHub OIDC and verifies production health. |

## Initial Host Setup

Prerequisites:

- A Linux/AMD64 Docker host with Docker Engine and the Compose v2 plugin.
- A TLS reverse proxy or platform ingress.
- A MongoDB user limited to the Jojo database.
- Network access from the host to MongoDB and GHCR.

From the repository root:

```powershell
Copy-Item deploy/.env.production.example deploy/.env.production
New-Item -ItemType Directory -Force deploy/secrets
```

Edit `deploy/.env.production` and replace `JOJO_IMAGE` with an immutable release tag or digest. Create `deploy/secrets/mongodb-uri` with only the connection string:

```text
mongodb://jojo_app:REDACTED@mongodb.internal:27017/jomongo?authSource=jomongo&tls=true
```

Restrict that file to the deployment account. Do not commit it or paste it into logs, issues, or chat.

Validate and deploy:

```powershell
docker compose --env-file deploy/.env.production -f deploy/compose.production.yml config --quiet
.\deploy\deploy.ps1
```

The default port mapping is `127.0.0.1:8080`. Keep it on loopback when a same-host reverse proxy handles TLS. If a platform requires `0.0.0.0`, restrict the container port at the firewall or security-group layer so traffic still reaches Jojo only through the approved ingress.

## Build And Release Pipeline

The GitHub workflow runs on pull requests, pushes to `main`, manual dispatches, and tags matching `v*.*.*`.

- Every run installs Java 21 and the official CommandBox CLI directly on the Ubuntu runner, then starts CommandBox explicitly before invoking TestBox. Test execution is intentionally separate from the production container runtime configuration.
- Every run compiles `deploy/azure/main.bicep` before an image can be built.
- CI uses sparse checkouts so committed local MongoDB files are not copied into hosted runners.
- Pull requests build and smoke-test the production image without publishing it.
- Pushes to `main` publish branch and commit-SHA tags to `ghcr.io/<owner>/<repository>`.
- A tag such as `v1.2.3` publishes `1.2.3`, `1.2`, and SHA tags, then creates GitHub release notes.
- The image includes BuildKit provenance and an SBOM.

Repository Actions permissions must allow packages to be written with `GITHUB_TOKEN`. GHCR package visibility is managed separately from repository visibility.

## Azure Container Apps

The Azure definition uses the Consumption workload profile with 0.5 vCPU, 1 GiB memory, `minReplicas: 0`, and `maxReplicas: 1`. Scaling to zero minimizes idle cost but discards in-memory sessions and introduces a cold start. The one-replica limit is required until Jojo has a shared session store.

Prerequisites:

- An Azure subscription with the `Microsoft.App` resource provider available.
- Azure CLI for local deployment, or a Microsoft Entra application configured for GitHub OIDC.
- A published, public GHCR package such as `ghcr.io/jhocali/aiseries:main`.
- An authenticated MongoDB URI. MongoDB Atlas M0 can be used for a small demonstration.

For GitHub deployment, create a GitHub environment named `production`. Configure an Entra federated credential with this subject:

```text
repo:jhocali/aiseries:environment:production
```

Give its service principal `Contributor` access only to the Jojo resource group. Add these GitHub environment variables:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_RESOURCE_GROUP` (optional; defaults to `jojo-production`)
- `AZURE_LOCATION` (optional; defaults to `centralus`)
- `AZURE_CONTAINER_APP_NAME` (optional; defaults to `jojo`)
- `AZURE_CONTAINER_ENVIRONMENT_NAME` (optional; defaults to `jojo-environment`)

Add `MONGODB_URI` as an environment secret, not a variable. Then run the `Deploy Azure` workflow manually and select a tag already published by the `Build and release` workflow. The deployment fails if required identity values or the MongoDB secret are absent, and it must receive HTTP 200 with body `Ok!` from `/healthcheck` before succeeding.

For a local deployment from an already authenticated Azure CLI:

```powershell
$env:MONGODB_URI = "<set this only in the current shell>"
.\deploy\azure\deploy.ps1 -Image "ghcr.io/jhocali/aiseries:main"
Remove-Item Env:MONGODB_URI
```

The Bicep deployment stores the URI as a Container Apps secret and references it from the `MONGODB_URI` environment variable. It does not provision Azure Container Registry, Log Analytics, or a database, avoiding those additional baseline costs.

## Upgrade And Rollback

Upgrade:

1. Select a tested immutable image tag or digest.
2. Change only `JOJO_IMAGE` in `deploy/.env.production`.
3. Run `.\deploy\deploy.ps1`.
4. Verify `/healthcheck`, sign-in, and a read-only dashboard request.

Rollback:

1. Restore the previous `JOJO_IMAGE` tag or digest.
2. Run `.\deploy\deploy.ps1`.
3. Confirm health and the affected user workflow.

Application restarts invalidate current sessions because session storage is in memory. Database migrations are not yet separated from normal collection access, so schema/index changes require an explicit compatibility review before release.

## Troubleshooting

| Symptom | Check | Resolution |
| --- | --- | --- |
| TestBox reports `connection refused` | `..\box.exe server status` | Start the server with `..\box.exe server start`, then rerun `..\box.exe testbox run`. |
| CommandBox reports access denied under `.CommandBox` | Run the command in a shell that can access the user profile | Do not relocate or delete the shared CommandBox runtime as a workaround. |
| Compose validation fails | `docker compose ... config --quiet` | Confirm `JOJO_IMAGE`, `MONGODB_URI_SECRET_FILE`, and the secret file path. |
| Container exits during startup | `docker compose ... ps` and `docker compose ... logs --tail 200 jojo` | Check runtime module downloads, Java memory, file permissions, and production JSON syntax. |
| Health check times out | `docker inspect <container>` and request `/healthcheck` locally | Confirm port `8080`, ingress mapping, and that the server reached the “ready to serve requests” log message. |
| Azure workflow reports missing configuration | GitHub `production` environment variables and secrets | Configure the three OIDC identity variables and `MONGODB_URI`; do not put the URI in a normal variable. |
| Azure cannot pull the GHCR image | GHCR package visibility and selected tag | Make the package public and deploy a tag published by the build workflow. |
| Azure revision repeatedly restarts | Container Apps system/console logs and revision state | Confirm the image is the tested Linux/AMD64 artifact and that 1 GiB memory is sufficient. |
| First Azure request is slow or a user is signed out | Container App replica count | Scale-to-zero causes cold starts and loses in-memory sessions; use `minReplicas: 1` only with an accepted cost or implement shared sessions. |
| Production displays a detailed exception | Check `server.production.json` and the running image environment | Use the production server definition, which pins `ENVIRONMENT=production`; do not deploy with the development `server.json`. |
| Dashboard returns a database error | Test MongoDB connectivity from the private host network | Verify DNS, TLS, authentication database, credentials, and MongoDB allowlists without printing the URI. |
| GHCR push is denied | Inspect workflow permissions and package settings | Allow `packages: write` for Actions and confirm the package is linked to the repository. |
| Release exists but deployment is unhealthy | Use the previous image digest | Roll back first, then use the failed container logs and image digest for diagnosis. |

`deploy/deploy.ps1` automatically prints Compose status and the last 200 application log lines when startup or HTTP health verification fails. Review logs for personal data before sharing them.

## Security And Operational Gaps

- `/healthcheck` is liveness only; dependency readiness is not implemented.
- `/mongo/ping` and `/mongo/login-table` remain application routes and must not be exposed to untrusted traffic until the planned application-level diagnostic authorization is implemented.
- CSRF, permission enforcement, rate limiting, and password migration remain open items in `SECURITY_REVIEW.md`.
- Azure deployment automation proves artifact startup and liveness; it does not waive these application-security gaps or make the portal safe for untrusted public use.
- Local MongoDB data and installer logs were committed in the initial repository history. Adding ignore rules does not remove them from existing commits. Assess the data, rotate any exposed credentials, and use an approved history-rewrite procedure before treating the repository as safe.
- MongoDB backup, restore, monitoring, and alerting belong to the selected database platform and must be demonstrated before production release.
- `resources/docker/` is retained only as legacy template scaffolding; it is not part of the release image or supported deployment path.
