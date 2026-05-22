# Profile Setup

Repository used to house useful aliases, scripts, and other files around bash profile setup. The goal of this repo is
that you could copy the folders/bash_profile in to your user directory, and have everything automatically load up as
needed. Then to add anything, simply append to an existing file, or add a new one to keep things sorted reasonably.

## Quick Start

Run the profile setup without downloading this repository first:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/project-init/profile-setup/main/install.sh)
```

### Setup Flow

1. Install [brew](https://brew.sh/).
2. Run the profile setup command above, or run `./setup.sh` from a local checkout.
3. Install the one-time tools listed below as needed.
4. Configure Git and GitHub SSH.
5. Create `~/Desktop/vnext` and clone the `project-init` repositories you need.

### One-Time Installs

Install the common development tools:

```sh
brew install bun gh go typescript
brew install --cask postman
```

Install [mise](https://mise.jdx.dev/getting-started.html) and [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/) if your project needs them.

Install or update [Xcode](https://apps.apple.com/us/app/xcode/id497799835) from the Mac App Store.

After Xcode is installed, configure it:

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -runFirstLaunch
```

### Git Configuration

Configure Git with your name and email:

```sh
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

### GitHub SSH and Repository Setup

Set up SSH access for GitHub:

```sh
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519_github
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
gh auth login --hostname github.com --git-protocol ssh --web
gh ssh-key add ~/.ssh/id_ed25519_github.pub --title "$(hostname)-project-init"
ssh -T git@github.com
```

Create a workspace for repositories:

```sh
mkdir -p ~/Desktop/vnext
cd ~/Desktop/vnext
```

Clone repositories from the [`project-init` organization](https://github.com/orgs/project-init/repositories) as needed:

```sh
gh repo clone project-init/REPO_NAME
```

### Installs for Aliases/Functions/Scripts

1. Install [fzf](https://github.com/junegunn/fzf)

## Directory Holdings

### Aliases

Helpful commands that can be written as a single word since they are used so often.

### Functions

Commands that are re-usable in local scripts that need a variable or 2, so they aren't quite usable as aliases.

### Init

Function calls that are required to initialize settings. Something like Pyenv needs this to setup the pathing correctly.

### Path

This is where you can store any path manipulation you need to do.

### Scripts

When you need something a little bigger than a function to contain any logic you want to call with a single word.

### Variables

This is where you can store your credentials.
