#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    ;;
  *)
    echo "This SWE-Paddle task is Windows-specific and must be verified on Windows." >&2
    exit 2
    ;;
esac

PADDLE_ROOT="${PADDLE_ROOT:-$(pwd)}"
BUILD_DIR="${BUILD_DIR:-${PADDLE_ROOT}/build}"
BUILD_CONFIG="${BUILD_CONFIG:-Release}"
JOBS="${JOBS:-2}"

if [[ ! -d "${BUILD_DIR}" ]]; then
  echo "Build directory not found: ${BUILD_DIR}" >&2
  echo "Please configure Paddle first, or set BUILD_DIR to an existing Paddle build directory." >&2
  exit 2
fi

cmake --build "${BUILD_DIR}" \
  --target inference_api_utf8_path_test \
  --config "${BUILD_CONFIG}" \
  --parallel "${JOBS}"

cd "${BUILD_DIR}"

ctest -C "${BUILD_CONFIG}" \
  -R "^inference_api_utf8_path_test$" \
  --output-on-failure
