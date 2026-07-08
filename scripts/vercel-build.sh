#!/bin/bash
set -euo pipefail

FLUTTER_VERSION="3.41.6"
FLUTTER_TARBALL="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TARBALL}"
FLUTTER_DIR="/tmp/flutter-sdk"

if [ ! -d "${FLUTTER_DIR}/bin" ]; then
  echo ">>> Downloading Flutter ${FLUTTER_VERSION} (stable)..."
  curl -fsSL "${FLUTTER_URL}" -o "/tmp/${FLUTTER_TARBALL}"
  echo ">>> Extracting Flutter SDK to ${FLUTTER_DIR}..."
  mkdir -p "${FLUTTER_DIR}"
  tar -xf "/tmp/${FLUTTER_TARBALL}" -C "${FLUTTER_DIR}" --strip-components=1
  rm -f "/tmp/${FLUTTER_TARBALL}"
else
  echo ">>> Using cached Flutter SDK at ${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

git config --global --add safe.directory "${FLUTTER_DIR}" || true
git config --global --add safe.directory "${PWD}" || true

echo ">>> Flutter version:"
flutter --version

echo ">>> Enabling web support..."
flutter config --enable-web

echo ">>> Executing combined build script..."
bash scripts/build_web.sh
