#!/bin/bash
set -euo pipefail

REPO_ARCHIVE_URL="https://github.com/project-init/profile-setup/archive/refs/heads/main.zip"
WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required to run this installer."
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "unzip is required to run this installer."
  exit 1
fi

echo "Downloading profile setup..."
curl -fsSL "$REPO_ARCHIVE_URL" -o "$WORK_DIR/profile-setup.zip"

echo "Preparing setup files..."
unzip -q "$WORK_DIR/profile-setup.zip" -d "$WORK_DIR"

cd "$WORK_DIR/profile-setup-main"
chmod +x setup.sh

echo "Starting interactive setup..."
./setup.sh
