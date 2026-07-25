log() { echo "[install] $*"; }

# CI runs skip provisioning by default; container smoke tests opt back in
# with CHEZMOI_FORCE_SCRIPTS=1.
if [ -n "${CI:-}" ] && [ -z "${CHEZMOI_FORCE_SCRIPTS:-}" ]; then
  log "CI environment detected. Skipping."
  exit 0
fi

# Containers and root shells have no sudo; run privileged commands directly.
# shellcheck disable=SC2034  # SUDO is used by scripts including this template
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi
