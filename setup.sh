#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_directories() {
  cp -r "$SCRIPT_DIR/.aliases" ~/.aliases
  cp -r "$SCRIPT_DIR/.functions" ~/.functions
  cp -r "$SCRIPT_DIR/.init" ~/.init
  cp -r "$SCRIPT_DIR/.path" ~/.path
  cp -r "$SCRIPT_DIR/.scripts" ~/.scripts
  cp -r "$SCRIPT_DIR/.variables" ~/.variables
}

copy_bash_profile() {
  cp "$SCRIPT_DIR/.bash_profile" ~/.bash_profile
}

copy_zshrc() {
  cp "$SCRIPT_DIR/.zshrc" ~/.zshrc
}

install_user_tools() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required to install user tools. Install brew first: https://brew.sh/"
    return 1
  fi

  echo "Installing command line tools..."
  brew install bun gh go mas typescript

  echo "Installing applications..."
  brew install --cask postman
}

ensure_xcode() {
  if ! command -v mas >/dev/null 2>&1; then
    echo "mas is required to install or update Xcode. Run the Homebrew user tools install first, or install it with: brew install mas"
    return 1
  fi

  echo "Checking Xcode..."

  if [ ! -d "/Applications/Xcode.app" ]; then
    echo "Xcode is not installed. Installing Xcode from the Mac App Store..."
    mas install 497799835 || return 1
  else
    echo "Xcode is installed. Checking for App Store updates..."
    mas upgrade 497799835 || return 1
  fi

  if [ ! -d "/Applications/Xcode.app" ]; then
    echo "Xcode was not found after installation. Open the App Store, install Xcode, then rerun ./setup.sh."
    return 1
  fi

  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer || return 1
  sudo xcodebuild -license accept || return 1
  xcodebuild -runFirstLaunch || return 1

  echo "Xcode is installed and configured."
}

setup_git_config() {
  local git_name
  local git_email

  if ! command -v git >/dev/null 2>&1; then
    echo "git is required but was not found."
    return 1
  fi

  echo "Git configuration"
  read -p "Enter your Git user name: " git_name
  read -p "Enter your Git email address: " git_email

  if [ -z "$git_name" ] || [ -z "$git_email" ]; then
    echo "Git user name and email are required."
    return 1
  fi

  git config --global user.name "$git_name" || return 1
  git config --global user.email "$git_email" || return 1
  git config --global init.defaultBranch main || return 1
  git config --global pull.rebase false || return 1
  git config --global url."git@github.com:".insteadOf "https://github.com/" || return 1

  echo "Git config written to $HOME/.gitconfig."
}

verify_github_ssh() {
  local ssh_output

  ssh_output="$(ssh -T git@github.com 2>&1)"
  echo "$ssh_output"

  case "$ssh_output" in
    *"successfully authenticated"*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

setup_github_ssh() {
  local email
  local key_path="$HOME/.ssh/id_ed25519_github"
  local public_key_path="${key_path}.pub"

  if ! command -v ssh-keygen >/dev/null 2>&1; then
    echo "ssh-keygen is required but was not found."
    return 1
  fi

  if ! command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI is required. Run the Homebrew user tools install first, or install it with: brew install gh"
    return 1
  fi

  echo "GitHub SSH setup"
  echo "This will create or reuse an SSH key, add it to GitHub, authenticate GitHub CLI, and verify SSH access."
  read -p "Enter the email address for your GitHub SSH key: " email

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [ ! -f "$key_path" ]; then
    echo "Creating SSH key at ${key_path}..."
    ssh-keygen -t ed25519 -C "$email" -f "$key_path" || return 1
  else
    echo "Using existing SSH key at ${key_path}."
  fi

  if [ ! -f "$public_key_path" ]; then
    echo "Creating missing public key at ${public_key_path}..."
    ssh-keygen -y -f "$key_path" > "$public_key_path" || return 1
  fi

  chmod 600 "$key_path" || return 1
  chmod 644 "$public_key_path" || return 1

  if command -v ssh-add >/dev/null 2>&1; then
    echo "Adding SSH key to the local SSH agent..."
    if ! ssh-add --apple-use-keychain "$key_path" 2>/dev/null && ! ssh-add "$key_path"; then
      echo "Failed to add SSH key to the local SSH agent."
      return 1
    fi
  fi

  echo "Authenticating GitHub CLI. Choose GitHub.com, SSH, and authenticate in the browser when prompted."
  gh auth login --hostname github.com --git-protocol ssh --web || return 1

  echo "Uploading SSH key to GitHub if it is not already present..."
  gh ssh-key add "$public_key_path" --title "$(hostname)-project-init-$(date +%Y%m%d)" || true

  echo "Verifying GitHub SSH access..."
  verify_github_ssh
}

read -p "Copy directories to source? Will overwrite any existing directories. (Yy) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Copying directories..."
  copy_directories
  echo "Directories copied."
fi

read -p "Copy bash profile? Will overwrite the existing one. (Yy) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Copying bash profile..."
  copy_bash_profile
  echo "Bash Profile copied."
fi

read -p "Copy zshrc? Will overwrite the existing one. (Yy) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Copying zshrc..."
  copy_zshrc
  echo "ZSH RC copied."
fi

read -p "Install user tools with Homebrew? Installs bun, gh, go, mas, typescript, and postman. (Yy) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  if install_user_tools; then
    echo "User tools install complete."
  fi
fi

echo "Xcode must be installed, up to date, and configured before cloning repositories."
read -p "Press Enter to check Xcode."
if ! ensure_xcode; then
  echo "Xcode setup did not complete. Install or update Xcode from the App Store, then rerun ./setup.sh."
  exit 1
fi

echo "Git user configuration is required before setting up GitHub and cloning repositories."
read -p "Press Enter to configure Git."
if ! setup_git_config; then
  echo "Git configuration did not complete. Re-run ./setup.sh after fixing the issue."
  exit 1
fi

echo "GitHub SSH setup is required before cloning project-init repositories."
read -p "Press Enter to start GitHub SSH setup."
if setup_github_ssh; then
  echo "GitHub SSH setup complete."
  echo "Cloning all project-init repositories to ~/Desktop/vnext..."
  "$SCRIPT_DIR/scripts/clone_project_init_repos.sh"
else
  echo "GitHub SSH setup did not complete. Re-run ./setup.sh after fixing the issue."
  exit 1
fi
