#!/bin/bash
set -u

ORG="project-init"
TARGET_DIR="$HOME/Desktop/vnext"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required. Install it with: brew install gh"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required but was not found."
  exit 1
fi

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login --hostname github.com --git-protocol ssh --web"
  exit 1
fi

echo "Verifying SSH access to GitHub..."
ssh_output="$(ssh -T git@github.com 2>&1)"
echo "$ssh_output"

case "$ssh_output" in
  *"successfully authenticated"*)
    ;;
  *)
    echo "GitHub SSH access failed. Complete SSH setup before cloning repositories."
    exit 1
    ;;
esac

mkdir -p "$TARGET_DIR"

echo "Loading repositories from https://github.com/orgs/${ORG}/repositories ..."
if ! repos="$(gh repo list "$ORG" --limit 10000 --json name,sshUrl --jq '.[] | [.name, .sshUrl] | @tsv')"; then
  echo "Failed to load repositories for ${ORG}."
  exit 1
fi

if [ -z "$repos" ]; then
  echo "No repositories were returned for ${ORG}. Check your GitHub access."
  exit 1
fi

failures=0

while IFS=$'\t' read -r name ssh_url; do
  repo_dir="$TARGET_DIR/$name"

  if [ -z "$name" ] || [ -z "$ssh_url" ]; then
    echo "Skipping invalid repository entry."
    failures=$((failures + 1))
    continue
  fi

  if [ -d "$repo_dir/.git" ]; then
    echo "Updating ${name}..."
    if ! git -C "$repo_dir" pull --ff-only; then
      echo "Failed to update ${name}."
      failures=$((failures + 1))
    fi
  elif [ -e "$repo_dir" ]; then
    echo "Cannot clone ${name}: ${repo_dir} already exists and is not a git repository."
    failures=$((failures + 1))
  else
    echo "Cloning ${name}..."
    if ! git clone "$ssh_url" "$repo_dir"; then
      echo "Failed to clone ${name}."
      failures=$((failures + 1))
    fi
  fi
done <<< "$repos"

if [ "$failures" -ne 0 ]; then
  echo "Completed with ${failures} repository failure(s)."
  exit 1
fi

echo "All ${ORG} repositories are available in ${TARGET_DIR}."
