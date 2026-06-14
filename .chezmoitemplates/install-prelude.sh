log() { echo "[install] $*"; }

if [ -n "${CI:-}" ]; then
  log "CI environment detected. Skipping."
  exit 0
fi
