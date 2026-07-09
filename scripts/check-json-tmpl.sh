#!/usr/bin/env bash
# Validate that every *.json.tmpl renders to syntactically valid JSON.
#
# The repo's existing chezmoi-template-check hook only proves a template
# *renders* without error; it does not prove the rendered output is valid
# JSON (a stray trailing comma in a conditional branch would slip through).
# This script renders each template with deterministic, machine-independent
# data and parses the result with python's json module.
#
# modify_settings.json.tmpl is a chezmoi modify script (shell script template);
# it is rendered then executed, and the output is verified as valid JSON.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# Empty data config -> deterministic "default" render, independent of the
# machine's real ~/.config/chezmoi/chezmoi.toml and CI's lack thereof.
empty_cfg="$tmpdir/empty.toml"
printf '[data]\n' >"$empty_cfg"

# Mock bedrock data -> exercises the hasKey branch in the modify script.
bedrock_cfg="$tmpdir/bedrock.toml"
cat >"$bedrock_cfg" <<'EOF'
[data]
bedrock_base_url = "https://example.invalid/bedrock"
bedrock_token = "test-token"
otel_endpoint = "https://example.invalid/otel"
EOF

# Mock work/extra-marketplace data -> exercises the extra_marketplace_url branch.
work_cfg="$tmpdir/work.toml"
cat >"$work_cfg" <<'EOF'
[data]
extra_plugins = ["plugin-a@test-marketplace", "plugin-b@test-marketplace"]
extra_marketplace_name = "test-marketplace"
extra_marketplace_url = "https://example.invalid/marketplace.git"
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

# render_modify <config> <template> <label>
# Renders the modify script template, executes the resulting shell script,
# and validates the output is valid JSON.
render_modify() {
  local cfg="$1" tmpl="$2" label="$3" out script_out
  # 1. テンプレートをシェルスクリプトにレンダリング
  if ! out="$(chezmoi execute-template --config "$cfg" --source . <"$tmpl" 2>&1)"; then
    echo "  FAIL: $tmpl ($label) — template did not render:" >&2
    printf '%s\n' "$out" >&2
    return 1
  fi
  # 2. レンダリングされたシェルスクリプトを実行
  if ! script_out="$(printf '%s' "$out" | sh 2>&1)"; then
    echo "  FAIL: $tmpl ($label) — script execution failed:" >&2
    printf '%s\n' "$script_out" >&2
    return 1
  fi
  # 3. valid JSON か確認
  if ! printf '%s' "$script_out" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null; then
    echo "  FAIL: $tmpl ($label) — output is not valid JSON:" >&2
    printf '%s\n' "$script_out" >&2
    return 1
  fi
  echo "  OK: $tmpl ($label)"
}

echo "Validating rendered JSON templates..."
fail=0
while IFS= read -r tmpl; do
  render "$empty_cfg" "$tmpl" "default" || fail=1
done < <(find . -name '*.json.tmpl' -not -path './.git/*' -not -name '*modify_*.json.tmpl' | sort)

# Validate modify scripts separately: render template -> execute shell -> check JSON output
while IFS= read -r tmpl; do
  render_modify "$empty_cfg" "$tmpl" "default" || fail=1
  render_modify "$bedrock_cfg" "$tmpl" "bedrock" || fail=1
  render_modify "$work_cfg" "$tmpl" "work" || fail=1
done < <(find . -name '*modify_*.json.tmpl' -not -path './.git/*' | sort)

if [ "$fail" -eq 0 ]; then
  echo "All rendered JSON templates valid."
else
  echo "JSON template validation failed." >&2
  exit 1
fi
