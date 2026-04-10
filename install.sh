#!/bin/bash

set -e

PAGES_DIR="/usr/lib/code-server/src/browser/pages"
SEARCH_NAME="gui.zip"

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: this script must be run as root."
  echo "Try: sudo bash install.sh"
  exit 1
fi

echo "Searching for ${SEARCH_NAME} in current directory..."

ZIP_PATH="$(find "$(pwd)" -maxdepth 2 -iname "${SEARCH_NAME}" | head -n 1)"

if [ -z "${ZIP_PATH}" ]; then
  echo "Error: ${SEARCH_NAME} not found in $(pwd) or its subdirectories."
  exit 1
fi

echo "Found: ${ZIP_PATH}"

if [ ! -d "${PAGES_DIR}" ]; then
  echo "Error: target directory not found: ${PAGES_DIR}"
  echo "Make sure code-server is installed at /usr/lib/code-server"
  exit 1
fi

echo "Target directory: ${PAGES_DIR}"

BACKUP_DIR="${PAGES_DIR}/backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup at: ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"
cp "${PAGES_DIR}"/*.html "${PAGES_DIR}"/*.css "${BACKUP_DIR}/" 2>/dev/null || true
echo "Backup done."

TMP_DIR="$(mktemp -d)"
echo "Extracting ${ZIP_PATH} to temp dir..."
unzip -o "${ZIP_PATH}" -d "${TMP_DIR}" > /dev/null

EXTRACT_ROOT="${TMP_DIR}"
SUBDIR="$(find "${TMP_DIR}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
if [ -n "${SUBDIR}" ]; then
  if ls "${SUBDIR}"/*.html "${SUBDIR}"/*.css &>/dev/null; then
    EXTRACT_ROOT="${SUBDIR}"
  fi
fi

echo "Copying files to ${PAGES_DIR}..."

COPIED=0
for f in "${EXTRACT_ROOT}"/*.html "${EXTRACT_ROOT}"/*.css; do
  [ -f "${f}" ] || continue
  cp "${f}" "${PAGES_DIR}/"
  echo "  copied: $(basename ${f})"
  COPIED=$((COPIED + 1))
done

if [ "${COPIED}" -eq 0 ]; then
  echo "Error: no .html or .css files found inside the zip."
  rm -rf "${TMP_DIR}"
  exit 1
fi

chown root:root "${PAGES_DIR}"/*.html "${PAGES_DIR}"/*.css 2>/dev/null || true
chmod 644 "${PAGES_DIR}"/*.html "${PAGES_DIR}"/*.css 2>/dev/null || true

rm -rf "${TMP_DIR}"

echo ""
echo "Verifying with zip listing:"
cd "${PAGES_DIR}"
zip -r gui_verify.zip *.html *.css 2>&1 | grep "adding:" | sed 's/^/  /'
rm -f gui_verify.zip

echo ""
echo "Done.Reload wed to apply changes:"
