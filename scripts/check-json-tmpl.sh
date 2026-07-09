#!/usr/bin/env bash
# Validate that every *.json.tmpl renders to syntactically valid JSON.
#
# The repo's existing chezmoi-template-check hook only proves a template
# *renders* without error; it does not prove the rendered output is valid
# JSON (a stray trailing comma in a conditional branch would slip through).
# This script renders each template with deterministic, machine-independent
# data and parses the result with python's json module.
#
# modify_*.json.tmpl files are chezmoi modify scripts — they render to shell
# scripts that are executed to produce JSON. These are validated separately
# with render_modify() under two data profiles:
#   default — no overlay present: output must equal the base JSON verbatim
#   overlay — a fixture overlay.jsonnet is present: output must contain the
#             jsonnet-merged result, including a shell-hostile secret passed
#             through the heredoc path (requires jsonnet; SKIPped when not
#             installed locally, FAILs in CI)
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# Empty data config -> deterministic "default" render, independent of the
# machine's real ~/.config/chezmoi/chezmoi.toml and CI's lack thereof.
empty_cfg="$tmpdir/empty.toml"
printf '[data]\n' >"$empty_cfg"

# Modify-script profiles. claude_overlay_dir must be pinned in every profile
# so a real ~/.config/claude-overlay on the developer's machine can never
# leak into the check.
mkdir -p "$tmpdir/no-overlay" "$tmpdir/overlay"
cp scripts/fixtures/test-overlay.jsonnet "$tmpdir/overlay/overlay.jsonnet"

default_cfg="$tmpdir/default.toml"
cat >"$default_cfg" <<EOF
[data]
claude_overlay_dir = "$tmpdir/no-overlay"
EOF

# test_secret deliberately contains shell-hostile characters to prove the
# heredoc escaping in the modify script end-to-end.
overlay_cfg="$tmpdir/overlay.toml"
cat >"$overlay_cfg" <<EOF
[data]
claude_overlay_dir = "$tmpdir/overlay"
test_secret = "s3cr3t'with\"quotes and \$vars"
EOF
# shellcheck disable=SC2016  # the literal $vars is the point of the test
expected_secret='s3cr3t'\''with"quotes and $vars'

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
# For modify scripts: render the template to a shell script, execute it,
# then validate the output is valid JSON. On success the produced JSON is
# left in RENDER_MODIFY_OUT for profile-specific assertions.
RENDER_MODIFY_OUT=""
render_modify() {
  local cfg="$1" tmpl="$2" label="$3" out script_out
  RENDER_MODIFY_OUT=""
  if ! out="$(chezmoi execute-template --config "$cfg" --source . <"$tmpl" 2>&1)"; then
    echo "  FAIL: $tmpl ($label) — template did not render:" >&2
    printf '%s\n' "$out" >&2
    return 1
  fi
  if ! script_out="$(printf '%s' "$out" | sh 2>&1)"; then
    echo "  FAIL: $tmpl ($label) — script execution failed:" >&2
    printf '%s\n' "$script_out" >&2
    return 1
  fi
  if ! printf '%s' "$script_out" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null; then
    echo "  FAIL: $tmpl ($label) — output is not valid JSON:" >&2
    printf '%s\n' "$script_out" >&2
    return 1
  fi
  RENDER_MODIFY_OUT="$script_out"
  echo "  OK: $tmpl ($label)"
}

echo "Validating rendered JSON templates..."
fail=0

# Validate regular *.json.tmpl files (rendered output must be valid JSON directly)
while IFS= read -r tmpl; do
  render "$empty_cfg" "$tmpl" "default" || fail=1
done < <(find . -name '*.json.tmpl' -not -name 'modify_*' -not -path './.git/*' -not -path './.claude/worktrees/*' | sort)

# Validate modify scripts (rendered output is a shell script; execute it, then validate JSON)
settings_tmpl="./dot_claude/modify_settings.json.tmpl"
while IFS= read -r tmpl; do
  # default profile: no overlay -> the base must pass through untouched
  if render_modify "$default_cfg" "$tmpl" "default"; then
    if [ "$tmpl" = "$settings_tmpl" ]; then
      if diff <(printf '%s' "$RENDER_MODIFY_OUT" | jq -S .) \
              <(jq -S . .chezmoitemplates/claude-settings-base.json) >/dev/null; then
        echo "  OK: $tmpl (default output == base)"
      else
        echo "  FAIL: $tmpl (default) — output differs from claude-settings-base.json" >&2
        fail=1
      fi
    fi
  else
    fail=1
  fi

  # overlay profile: fixture overlay present -> jsonnet merge must apply
  if ! command -v jsonnet >/dev/null 2>&1; then
    if [ "${CI:-}" = "true" ]; then
      echo "  FAIL: $tmpl (overlay) — jsonnet is not installed in CI" >&2
      fail=1
    else
      echo "  SKIP: $tmpl (overlay) — jsonnet not installed"
    fi
    continue
  fi
  if render_modify "$overlay_cfg" "$tmpl" "overlay"; then
    if [ "$tmpl" = "$settings_tmpl" ]; then
      got_secret="$(printf '%s' "$RENDER_MODIFY_OUT" | jq -r '.env.TEST_OVERLAY')"
      if [ "$got_secret" = "$expected_secret" ]; then
        echo "  OK: $tmpl (overlay merge + escaping)"
      else
        echo "  FAIL: $tmpl (overlay) — env.TEST_OVERLAY mismatch: got '$got_secret'" >&2
        fail=1
      fi
    fi
  else
    fail=1
  fi
done < <(find . -name 'modify_*.json.tmpl' -not -path './.git/*' -not -path './.claude/worktrees/*' | sort)

if [ "$fail" -eq 0 ]; then
  echo "All rendered JSON templates valid."
else
  echo "JSON template validation failed." >&2
  exit 1
fi
