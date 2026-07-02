#!/bin/bash
# Vercel build environment setup for Flutter web.
# Vercel's default build image (Amazon Linux 2) does NOT include Flutter,
# so we download a pinned Flutter SDK, add it to PATH, and run the web build.
#
# Pinned to a stable channel revision that matches the local dev SDK (3.41.x).
set -euo pipefail

FLUTTER_VERSION="3.41.6"
FLUTTER_TARBALL="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TARBALL}"

# Reuse a cached Flutter SDK if a previous build left one in /tmp
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

# Vercel builds run as root, which triggers Git's "dubious ownership"
# safety check on the Flutter SDK repo. Add a safe.directory exception so
# Flutter's internal git commands (version check, upgrade) don't fail.
git config --global --add safe.directory "${FLUTTER_DIR}" || true
git config --global --add safe.directory "${PWD}" || true

echo ">>> Flutter version:"
flutter --version

echo ">>> Enabling web support..."
flutter config --enable-web

echo ">>> Resolving dependencies..."
flutter pub get

echo ">>> Generating .env from Vercel environment variables..."
# .env is gitignored, so it must be reconstructed at build time from the
# Vercel project's environment variables. Only keys that the app reads via
# flutter_dotenv need to be present here.
printf 'VERCEL_API_URL=%s\nVERCEL_API_SECRET=%s\n' \
  "${VERCEL_API_URL:-}" "${VERCEL_API_SECRET:-}" > .env

echo ">>> Building Flutter web app (release)..."
flutter build web --release

echo ">>> Flutter web build complete."

# SPA fallback: copy index.html to 404.html so Vercel serves the Flutter
# app for any unmatched path (e.g. /login, /dashboard). The client-side
# go_router then handles the actual route.
cp build/web/index.html build/web/404.html
echo ">>> Created 404.html SPA fallback."
