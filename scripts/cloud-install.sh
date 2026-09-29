#!/usr/bin/env bash
# Cloud Agent bootstrap: Android Gradle deps optional; Swift for ios/DashCore tests.
set -euo pipefail

echo "[northstar] cloud-install starting"

# Runtime libs Swift needs on Ubuntu 24.04
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    libncurses6 libcurl4 libxml2 binutils libc6-dev curl ca-certificates \
    >/dev/null
fi

# --- Swift (Linux) for DashCore unit tests ---
SWIFT_VERSION="${SWIFT_VERSION:-6.0.3}"
SWIFT_ROOT="${SWIFT_ROOT:-$HOME/.local/swift}"
MARKER="$SWIFT_ROOT/.swift-${SWIFT_VERSION}.ok"
DL_DIR="${SWIFT_DL_DIR:-$HOME/.local/swift-dl}"

if [[ ! -f "$MARKER" ]]; then
  echo "[northstar] installing Swift ${SWIFT_VERSION} → ${SWIFT_ROOT}"
  mkdir -p "$SWIFT_ROOT" "$DL_DIR"
  TAR="swift-${SWIFT_VERSION}-RELEASE-ubuntu24.04.tar.gz"
  URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2404/swift-${SWIFT_VERSION}-RELEASE/${TAR}"
  if [[ ! -f "$DL_DIR/${TAR}" ]]; then
    curl -L --fail --retry 3 -o "$DL_DIR/${TAR}" "$URL"
  fi
  tar -xzf "$DL_DIR/${TAR}" -C "$SWIFT_ROOT" --strip-components=1
  touch "$MARKER"
else
  echo "[northstar] Swift ${SWIFT_VERSION} already installed"
fi

# Put swift on PATH for this and child shells via a small env snippet
mkdir -p "$HOME/.local/bin"
ln -sfn "$SWIFT_ROOT/usr/bin/swift" "$HOME/.local/bin/swift"
ln -sfn "$SWIFT_ROOT/usr/bin/swiftc" "$HOME/.local/bin/swiftc"
ln -sfn "$SWIFT_ROOT/usr/bin/swift-package" "$HOME/.local/bin/swift-package" || true

export PATH="$HOME/.local/bin:$SWIFT_ROOT/usr/bin:$PATH"
if command -v swift >/dev/null 2>&1; then
  swift --version | head -1
else
  echo "[northstar] WARNING: swift not on PATH after install" >&2
fi

# --- DashCore tests (fail soft if toolchain incomplete) ---
if [[ -d ios/DashCore ]]; then
  echo "[northstar] running ios/DashCore tests"
  (cd ios/DashCore && swift test) || echo "[northstar] DashCore tests failed or skipped — check Swift install" >&2
fi

echo "[northstar] cloud-install done"
echo "[northstar] NOTE: Xcode / iOS Simulator / on-device Tripper tests require a Mac. This environment only covers DashCore."
