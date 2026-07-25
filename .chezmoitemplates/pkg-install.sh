# Cross-distro package installation helpers.
# Requires install-prelude.sh (log, SUDO) to be included first.

if command -v apt-get >/dev/null 2>&1; then
  PKG_MANAGER="apt"
elif command -v dnf >/dev/null 2>&1; then
  PKG_MANAGER="dnf"
elif command -v yum >/dev/null 2>&1; then
  PKG_MANAGER="yum"
elif command -v pacman >/dev/null 2>&1; then
  PKG_MANAGER="pacman"
elif command -v zypper >/dev/null 2>&1; then
  PKG_MANAGER="zypper"
else
  PKG_MANAGER="unknown"
fi

PKG_CACHE_UPDATED=0

pkg_update_once() {
  if [ "$PKG_CACHE_UPDATED" -eq 1 ]; then
    return 0
  fi
  case "$PKG_MANAGER" in
    apt) $SUDO apt-get update ;;
    pacman) $SUDO pacman -Sy --noconfirm ;;
  esac
  PKG_CACHE_UPDATED=1
}

pkg_install_raw() {
  case "$PKG_MANAGER" in
    apt) $SUDO apt-get install -y "$1" ;;
    dnf) $SUDO dnf install -y "$1" ;;
    yum) $SUDO yum install -y "$1" ;;
    pacman) $SUDO pacman -S --noconfirm --needed "$1" ;;
    zypper) $SUDO zypper install -y "$1" ;;
  esac
}

# pkg_install <required|optional> <package> [<non-apt package name>]
# "optional" warns and continues when the package manager or package is
# unavailable (e.g. desktop tools on headless server distros).
pkg_install() {
  local mode="$1" pkg="$2" alt name
  alt="${3:-$2}"
  case "$PKG_MANAGER" in
    apt) name="$pkg" ;;
    *) name="$alt" ;;
  esac

  if [ "$PKG_MANAGER" = "unknown" ]; then
    if [ "$mode" = "required" ]; then
      log "ERROR: no supported package manager found; install $pkg manually"
      return 1
    fi
    log "WARNING: no supported package manager found; skipping $pkg"
    return 0
  fi

  pkg_update_once
  if pkg_install_raw "$name"; then
    return 0
  fi
  if [ "$mode" = "required" ]; then
    log "ERROR: failed to install required package: $name"
    return 1
  fi
  log "WARNING: optional package unavailable, continuing without it: $name"
  return 0
}
