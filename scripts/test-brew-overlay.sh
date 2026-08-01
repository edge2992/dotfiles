#!/usr/bin/env bash
# Unit tests for private_dot_config/homebrew/modify_Brewfile.tmpl — the modify
# script that assembles ~/.config/homebrew/Brewfile from the shared base
# (.chezmoitemplates/Brewfile) plus an optional machine-local overlay.
#
# The overlay is the personal/work split: company packages live in
# $brew_overlay_dir/Brewfile, outside this public repository. These tests pin the
# two behaviours that split depends on — base passthrough when no overlay exists,
# and verbatim append when one does.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

MODIFY=private_dot_config/homebrew/modify_Brewfile.tmpl
fail=0

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Render the modify script once per overlay dir, then run it. chezmoi passes the
# current file contents on stdin; the script ignores them, so /dev/null is fine.
render_and_run() {
  local overlay_dir="$1" out="$2"
  chezmoi execute-template --source . \
    --init --promptString email=ci@example.com,name=CI \
    "{{ \$_ := set . \"brew_overlay_dir\" \"$overlay_dir\" }}$(cat "$MODIFY")" \
    >"$TMP/rendered.sh"
  sh "$TMP/rendered.sh" </dev/null >"$out"
}

check_contains() {
  local label="$1" file="$2" needle="$3"
  if grep -qF -- "$needle" "$file"; then
    echo "  OK: $label"
  else
    echo "  FAIL: $label — expected to find '$needle'" >&2
    fail=1
  fi
}

check_absent() {
  local label="$1" file="$2" needle="$3"
  if grep -qF -- "$needle" "$file"; then
    echo "  FAIL: $label — unexpectedly found '$needle'" >&2
    fail=1
  else
    echo "  OK: $label"
  fi
}

echo "Testing Brewfile overlay assembly..."

# 1. No overlay (personal machine): base passes through unchanged.
mkdir -p "$TMP/empty"
render_and_run "$TMP/empty" "$TMP/base-only.out"
check_contains "base package present without overlay" "$TMP/base-only.out" 'brew "ripgrep"'
check_contains "base cask present without overlay" "$TMP/base-only.out" 'cask "wezterm"'
check_absent "no overlay marker without overlay" "$TMP/base-only.out" '--- overlay:'

# The rendered base must match .chezmoitemplates/Brewfile byte for byte, so the
# heredoc never mangles quotes or dollar signs.
chezmoi execute-template --source . \
  --init --promptString email=ci@example.com,name=CI \
  '{{ includeTemplate "Brewfile" . }}' >"$TMP/expected-base"
if diff -u "$TMP/expected-base" "$TMP/base-only.out" >"$TMP/diff" 2>&1; then
  echo "  OK: base rendered verbatim"
else
  echo "  FAIL: base was altered during assembly" >&2
  cat "$TMP/diff" >&2
  fail=1
fi

# 2. Overlay present (work machine): appended verbatim, base untouched.
mkdir -p "$TMP/overlay"
cat >"$TMP/overlay/Brewfile" <<'EOF'
tap "example/internal"
brew "example-cli"
cask "example-app"
EOF
render_and_run "$TMP/overlay" "$TMP/with-overlay.out"
check_contains "overlay tap appended" "$TMP/with-overlay.out" 'tap "example/internal"'
check_contains "overlay formula appended" "$TMP/with-overlay.out" 'brew "example-cli"'
check_contains "overlay cask appended" "$TMP/with-overlay.out" 'cask "example-app"'
check_contains "base survives alongside overlay" "$TMP/with-overlay.out" 'brew "ripgrep"'
check_contains "overlay marker present" "$TMP/with-overlay.out" '--- overlay:'

# Overlay content must come after the base so later declarations win.
base_line=$(grep -nF 'brew "ripgrep"' "$TMP/with-overlay.out" | head -1 | cut -d: -f1)
ovl_line=$(grep -nF 'brew "example-cli"' "$TMP/with-overlay.out" | head -1 | cut -d: -f1)
if [ "$base_line" -lt "$ovl_line" ]; then
  echo "  OK: overlay appended after base"
else
  echo "  FAIL: overlay did not come after base ($base_line >= $ovl_line)" >&2
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "All Brewfile overlay tests passed."
else
  echo "Brewfile overlay tests failed." >&2
  exit 1
fi
