#!/usr/bin/env bash
# Validate that every *.json.tmpl renders to syntactically valid JSON.
#
# The repo's existing chezmoi-template-check hook only proves a template
# *renders* without error; it does not prove the rendered output is valid
# JSON (a stray trailing comma in a conditional branch would slip through).
# This script renders each template with deterministic, machine-independent
# data and parses the result with python's json module.
#
# settings.json.tmpl additionally has a `{{ if hasKey . "bedrock_base_url" }}`
# branch, so it is rendered twice: once without bedrock data (default branch)
# and once with mock bedrock data (the comma-heavy conditional branch).
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# Empty data config -> deterministic "default" render, independent of the
# machine's real ~/.config/chezmoi/chezmoi.toml and CI's lack thereof.
empty_cfg="$tmpdir/empty.toml"
printf '[data]\n' >"$empty_cfg"

# Mock bedrock data -> exercises the hasKey branch in settings.json.tmpl.
bedrock_cfg="$tmpdir/bedrock.toml"
cat >"$bedrock_cfg" <<'EOF'
[data]
bedrock_base_url = "https://example.invalid/bedrock"
bedrock_token = "test-token"
otel_endpoint = "https://example.invalid/otel"
EOF

# render <config> <template> <label>
render() {
  local cfg="$1" tmpl="$2" label="$3" out
  if ! out="$(chezmoi execute-template --config "$cfg" --source . <"$tmpl" 2>&1)"; then
    echo "  FAIL: $tmpl ($label) — template did not render:" >&2
    printf '%s\n' "$out" >&2
    return 1
  fi
  if ! printf '%s' "$out" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null; then
    echo "  FAIL: $tmpl ($label) — rendered output is not valid JSON:" >&2
    printf '%s\n' "$out" >&2
    return 1
  fi
  echo "  OK: $tmpl ($label)"
}

echo "Validating rendered JSON templates..."
fail=0
while IFS= read -r tmpl; do
  render "$empty_cfg" "$tmpl" "default" || fail=1
  if [ "$(basename "$tmpl")" = "settings.json.tmpl" ]; then
    render "$bedrock_cfg" "$tmpl" "bedrock" || fail=1
  fi
done < <(find . -name '*.json.tmpl' -not -path './.git/*' | sort)

if [ "$fail" -eq 0 ]; then
  echo "All rendered JSON templates valid."
else
  echo "JSON template validation failed." >&2
  exit 1
fi
