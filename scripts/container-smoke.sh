#!/usr/bin/env bash
set -Eeuo pipefail

image="${1:?Usage: container-smoke.sh IMAGE}"
host_port="${SMOKE_PORT:-18080}"
container_id=""

finish() {
  result=$?

  if [[ ${result} -ne 0 && -n ${container_id} ]]; then
    echo "Container runtime diagnostics:" >&2
    docker exec "${container_id}" /bin/bash -lc '
      set +e
      printf "Identity: "
      id
      printf "Working directory: "
      pwd
      printf "CommandBox: "
      command -v box || true
      printf "BoxLang executable: "
      command -v boxlang || true
      box version || true
      box server status || true
      stat -c "%A %U:%G %n" \
        "${APP_DIR}" \
        "${APP_DIR}/lib" \
        "${APP_DIR}/lib/coldbox" \
        "${APP_DIR}/lib/coldbox/system/logging/appenders" \
        "${APP_DIR}/lib/coldbox/system/logging/appenders/ConsoleAppender.cfc" || true
      find "${APP_DIR}/lib/coldbox/system/logging/appenders" \
        -maxdepth 1 \
        -type f \
        -printf "%f\n" \
        -quit || true
      sha256sum "${APP_DIR}/lib/coldbox/system/logging/appenders/ConsoleAppender.cfc" || true
    ' >&2 || true
    docker logs --tail 200 "${container_id}" || true
  fi

  if [[ -n ${container_id} ]]; then
    docker rm --force "${container_id}" >/dev/null 2>&1 || true
  fi

  exit "${result}"
}

trap finish EXIT

container_id="$(
  docker run --detach \
    --publish "127.0.0.1:${host_port}:8080" \
    --env BOXLANG_DEBUG=false \
    --env ENVIRONMENT=production \
    --env MONGODB_DATABASE=jomongo \
    --env MONGODB_DATASOURCE=jomongo \
    --env MONGODB_URI='mongodb://127.0.0.1:27017/?connectTimeoutMS=1000&serverSelectionTimeoutMS=1000' \
    "${image}"
)"

for _ in $(seq 1 60); do
  if response="$(curl --fail --silent --show-error "http://127.0.0.1:${host_port}/healthcheck")"; then
    if [[ ${response} != "Ok!" ]]; then
      echo "Unexpected health body: ${response}" >&2
      exit 1
    fi

    test_status="$(curl --silent --output /dev/null --write-out '%{http_code}' "http://127.0.0.1:${host_port}/tests/runner.bxm")"

    if [[ ${test_status} != "404" ]]; then
      echo "Expected the production TestBox route to return 404, got ${test_status}." >&2
      exit 1
    fi

    missing_body="$(curl --silent --show-error "http://127.0.0.1:${host_port}/not-a-route")"
    missing_status="$(curl --silent --output /dev/null --write-out '%{http_code}' "http://127.0.0.1:${host_port}/not-a-route")"

    if [[ ${missing_status} != "404" || ${missing_body} != *"Page not found."* ]]; then
      echo "Production image did not return the generic 404 response." >&2
      exit 1
    fi

    if [[ ${missing_body} =~ (Stacktrace|EventHandlerNotRegisteredException|/app/handlers) ]]; then
      echo "Production 404 response exposes diagnostic details." >&2
      exit 1
    fi

    home_body="$(curl --silent --show-error "http://127.0.0.1:${host_port}/")"
    home_status="$(curl --silent --output /dev/null --write-out '%{http_code}' "http://127.0.0.1:${host_port}/")"

    if [[ ${home_status} != "200" || ${home_body} != *'<h2 class="panel-title" id="login-title">Sign in</h2>'* ]]; then
      echo "Production image did not render the anonymous sign-in page." >&2
      exit 1
    fi

    home_headers="$(curl --silent --show-error --dump-header - --output /dev/null "http://127.0.0.1:${host_port}/")"

    if ! grep -Eiq '^set-cookie:.*HttpOnly' <<< "${home_headers}" ||
      ! grep -Eiq '^set-cookie:.*SameSite=Lax' <<< "${home_headers}" ||
      ! grep -Eiq '^set-cookie:.*Secure' <<< "${home_headers}"; then
      echo "Production session cookie is missing HttpOnly, SameSite=Lax, or Secure." >&2
      exit 1
    fi

    echo "Container smoke check passed."
    exit 0
  fi

  sleep 2
done

echo "Container did not pass its health check within 120 seconds." >&2
exit 1
