#!/usr/bin/env bash
# Unit tests for dot_claude/hooks/settings-merge-patch.jq — the reverse merge
# patch settings-sync.sh uses to fold live settings.json edits back into
# claude-settings-base.json without leaking overlay-managed values.
# Each case asserts: apply(base; diff(rendered; live)) == expected.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILTER=dot_claude/hooks/settings-merge-patch.jq
fail=0

# check <label> <base> <rendered> <live> <expected>
check() {
  local label="$1" base="$2" rendered="$3" live="$4" expected="$5" got want
  got="$(jq -cnS \
    --argjson base_a "[$base]" \
    --argjson rendered "$rendered" \
    --argjson live_a "[$live]" \
    -f "$FILTER")"
  want="$(printf '%s' "$expected" | jq -cS .)"
  if [ "$got" = "$want" ]; then
    echo "  OK: $label"
  else
    echo "  FAIL: $label" >&2
    echo "    expected: $want" >&2
    echo "    got:      $got" >&2
    fail=1
  fi
}

echo "Testing settings merge-patch filter..."

# User changes a scalar, adds an env key, and deletes a base key while the
# overlay contributes env.BEDROCK and hooks — none of which may enter the base.
check "overlay values stay out of base" \
  '{"model":"opus","env":{"AUTO":"1"},"effortLevel":"high"}' \
  '{"model":"opus","env":{"AUTO":"1","BEDROCK":"tok"},"effortLevel":"high","hooks":{"PermissionRequest":[{"cmd":"ccgate"}]}}' \
  '{"model":"sonnet","env":{"AUTO":"1","BEDROCK":"tok","NEW":"y"},"hooks":{"PermissionRequest":[{"cmd":"ccgate"}]}}' \
  '{"model":"sonnet","env":{"AUTO":"1","NEW":"y"}}'

# No overlay (rendered == base): the live file becomes the new base verbatim.
check "personal machine passthrough" \
  '{"a":1,"b":{"c":2}}' \
  '{"a":1,"b":{"c":2}}' \
  '{"a":1,"b":{"c":3},"d":4}' \
  '{"a":1,"b":{"c":3},"d":4}'

# Nested edit only touches the edited leaf, siblings survive.
check "nested edit keeps siblings" \
  '{"permissions":{"allow":["Read"],"deny":["sudo"]}}' \
  '{"permissions":{"allow":["Read"],"deny":["sudo"]}}' \
  '{"permissions":{"allow":["Read","Write"],"deny":["sudo"]}}' \
  '{"permissions":{"allow":["Read","Write"],"deny":["sudo"]}}'

# Arrays replace atomically (no element-wise merge).
check "array replaced atomically" \
  '{"list":[1,2,3]}' \
  '{"list":[1,2,3]}' \
  '{"list":[9]}' \
  '{"list":[9]}'

# Type change object -> scalar replaces the whole subtree.
check "type change object to scalar" \
  '{"x":{"y":1}}' \
  '{"x":{"y":1}}' \
  '{"x":"flat"}' \
  '{"x":"flat"}'

# Deleting an overlay-added key must not disturb the base.
check "delete of overlay key is a no-op on base" \
  '{"env":{"AUTO":"1"}}' \
  '{"env":{"AUTO":"1","BEDROCK":"tok"}}' \
  '{"env":{"AUTO":"1"}}' \
  '{"env":{"AUTO":"1"}}'

if [ "$fail" -eq 0 ]; then
  echo "All merge-patch tests passed."
else
  echo "Merge-patch tests failed." >&2
  exit 1
fi
