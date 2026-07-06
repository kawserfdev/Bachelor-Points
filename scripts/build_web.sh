#!/usr/bin/env bash
#
# Combined build script for Vercel deployment.
#
# Produces a single `public/` directory containing:
#   - The static-exported Next.js landing page at the root (served at `/`)
#   - The Flutter Web app under `public/app/` (served at `/app/*`)
#
# Vercel's `vercel.json` points `outputDirectory` to `public/` and uses a
# rewrite so that any unmatched `/app/*` path falls back to `/app/index.html`
# (SPA deep-link support).
#
# Usage:
#   bash scripts/build_web.sh          # release build
#   bash scripts/build_web.sh --debug  # debug build (faster, larger)
#
# Requirements: Node.js (npm), Flutter SDK, on PATH.
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LANDING_DIR="${ROOT_DIR}/web-landing_page"
OUTPUT_DIR="${ROOT_DIR}/public"
APP_DIR="${OUTPUT_DIR}/app"
FLUTTER_BASE_HREF="/app/"

# Optional debug flag.
BUILD_MODE="release"
if [[ "${1:-}" == "--debug" ]]; then
  BUILD_MODE="debug"
fi

echo "==> Combined web build (mode=${BUILD_MODE})"
echo "    Root:       ${ROOT_DIR}"
echo "    Landing:    ${LANDING_DIR}"
echo "    Output:     ${OUTPUT_DIR}"
echo "    App path:   ${APP_DIR}"
echo "    Base href:  ${FLUTTER_BASE_HREF}"
echo ""

# ---------------------------------------------------------------------------
# 1. Clean previous output
# ---------------------------------------------------------------------------
echo "==> [1/4] Cleaning previous build output..."
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

# ---------------------------------------------------------------------------
# 2. Build & export the Next.js landing page
# ---------------------------------------------------------------------------
echo "==> [2/4] Building Next.js landing page (static export)..."
cd "${LANDING_DIR}"

# Install dependencies (uses package-lock.json for reproducibility).
if [[ -f package-lock.json ]]; then
  npm ci
else
  npm install
fi

# `next build` with `output: 'export'` writes to `out/`.
npm run build

# Copy the exported landing page into the root of the output directory.
# `out/` contains index.html, _next/, assets, etc.
cp -R out/. "${OUTPUT_DIR}/"

echo "    Landing page exported to ${OUTPUT_DIR}"

# ---------------------------------------------------------------------------
# 3. Build the Flutter Web app
# ---------------------------------------------------------------------------
echo "==> [3/4] Building Flutter Web app..."
cd "${ROOT_DIR}"

# Ensure Flutter dependencies are resolved.
flutter pub get

if [[ "${BUILD_MODE}" == "debug" ]]; then
  flutter build web --debug --base-href "${FLUTTER_BASE_HREF}"
else
  flutter build web --release --base-href "${FLUTTER_BASE_HREF}"
fi

# Flutter writes to `build/web/`. Copy it into `public/app/`.
mkdir -p "${APP_DIR}"
cp -R build/web/. "${APP_DIR}/"

echo "    Flutter app exported to ${APP_DIR}"

# ---------------------------------------------------------------------------
# 4. Verify
# ---------------------------------------------------------------------------
echo "==> [4/4] Verifying output..."
if [[ ! -f "${OUTPUT_DIR}/index.html" ]]; then
  echo "ERROR: Landing page index.html not found at ${OUTPUT_DIR}/index.html" >&2
  exit 1
fi
if [[ ! -f "${APP_DIR}/index.html" ]]; then
  echo "ERROR: Flutter app index.html not found at ${APP_DIR}/index.html" >&2
  exit 1
fi

echo ""
echo "==> Build complete!"
echo "    Landing:  ${OUTPUT_DIR}/index.html  (served at /)"
echo "    App:      ${APP_DIR}/index.html      (served at /app/)"
echo ""
echo "    To preview locally:"
echo "      npx serve ${OUTPUT_DIR}"
