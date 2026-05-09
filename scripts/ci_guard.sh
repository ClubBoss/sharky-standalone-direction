#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

offenders=()

monoci=".github/workflows/monoci.yml"

if [[ ! -f "$monoci" ]]; then
  echo "INFO: optional legacy workflow not present: $monoci" >&2
fi

if [[ -f "$monoci" ]]; then
  if grep -Eq '^\s*if:\s' "$monoci"; then
    offenders+=("$monoci")
  fi
fi

for file in .github/workflows/*.{yml,yaml}; do
  [[ -e "$file" ]] || continue
  [[ "$file" == "$monoci" ]] && continue
  if awk '/^on:/ {in_on=1; next} /^[^[:space:]]/ {in_on=0} in_on && /pull_request(_target)?:/ {found=1} END{exit !found}' "$file"; then
    offenders+=("$file")
  fi
done

if ((${#offenders[@]})); then
  printf '%s\n' "${offenders[@]}" | sort >&2
  exit 1
fi
