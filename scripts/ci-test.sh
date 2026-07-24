#!/usr/bin/env bash
set -Eeuo pipefail

finish() {
  result=$?

  if [[ ${result} -ne 0 ]]; then
    box server status || true
    box server log --follow=false 2>/dev/null | tail -n 200 || true
  fi

  box server stop >/dev/null 2>&1 || true
  exit "${result}"
}

trap finish EXIT

test_port="${TEST_SERVER_PORT:-8080}"

box install
box server start port="${test_port}" host=127.0.0.1 openbrowser=false saveSettings=false
box server status
box testbox run
