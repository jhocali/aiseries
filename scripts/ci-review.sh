#!/usr/bin/env bash
set -Eeuo pipefail

mapfile -t shell_files < <(git ls-files '*.sh')

if [[ ${#shell_files[@]} -eq 0 ]]; then
  echo "No tracked shell scripts were found." >&2
  exit 1
fi

bash -n "${shell_files[@]}"

blocked_files=()

while IFS= read -r path; do
  case "${path}" in
    .env|*/.env|.env.*|*/.env.*)
      if [[ "${path}" != *.example ]]; then
        blocked_files+=("${path}")
      fi
      ;;
    .mongo/*|*/.mongo/*|mongo-test-write/*|*/mongo-test-write/*|mongodb-runtime/*|*/mongodb-runtime/*)
      blocked_files+=("${path}")
      ;;
    deploy/secrets/*|*/deploy/secrets/*|*.log)
      blocked_files+=("${path}")
      ;;
  esac
done < <(git ls-files)

if [[ ${#blocked_files[@]} -ne 0 ]]; then
  echo "CI review found tracked local data, logs, or secrets:" >&2
  printf '  - %s\n' "${blocked_files[@]}" >&2
  exit 1
fi

if git grep --line-number --extended-regexp '^(<<<<<<<|=======|>>>>>>>)' -- \
  ':!scripts/ci-review.sh'; then
  echo "CI review found unresolved merge-conflict markers." >&2
  exit 1
fi

boxlang_files=()

if [[ -n ${CI_REVIEW_BASE_SHA:-} ]] &&
  git cat-file -e "${CI_REVIEW_BASE_SHA}^{commit}" 2>/dev/null; then
  mapfile -t boxlang_files < <(
    git diff \
      --name-only \
      --diff-filter=ACMRT \
      "${CI_REVIEW_BASE_SHA}...HEAD" \
      -- '*.bx' '*.bxs' '*.bxm' '*.cfm' '*.cfc' '*.cfs'
  )
else
  mapfile -t boxlang_files < <(
    {
      git diff \
        --name-only \
        --diff-filter=ACMRT \
        HEAD \
        -- '*.bx' '*.bxs' '*.bxm' '*.cfm' '*.cfc' '*.cfs'
      git ls-files \
        --others \
        --exclude-standard \
        -- '*.bx' '*.bxs' '*.bxm' '*.cfm' '*.cfc' '*.cfs'
    } | sort -u
  )
fi

if [[ ${#boxlang_files[@]} -eq 0 ]]; then
  echo "No changed BoxLang/CFML files require a format check."
else
  source_list="$(IFS=,; echo "${boxlang_files[*]}")"
  box boxlang cli format --check --source "${source_list}"
fi

echo "CI review checks passed."
