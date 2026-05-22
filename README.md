# Profile Setup

Repository used to house useful aliases, scripts, and other files around bash profile setup. The goal of this repo is
that you could copy the folders/bash_profile in to your user directory, and have everything automatically load up as
needed. Then to add anything, simply append to an existing file, or add a new one to keep things sorted reasonably.

## Quick Start

Run the installer without downloading this repository first:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/project-init/profile-setup/main/install.sh)
```

### Setup Flow

1. Install [brew](https://brew.sh/)
2. Start setup with the `curl` command above, or by running `./setup.sh` from a local checkout.
3. When prompted by `setup.sh`, install the required user tools with Homebrew:
   - [Bun](https://bun.sh/)
   - [GitHub CLI](https://cli.github.com/)
   - [mas](https://github.com/mas-cli/mas)
   - [Postman](https://learning.postman.com/docs/getting-started/installation/installation-and-updates/#install-postman-on-mac)
   - [Go](https://go.dev/)
   - [TypeScript](https://www.typescriptlang.org/)
4. Install or update [Xcode](https://apps.apple.com/us/app/xcode/id497799835) from the Mac App Store, select it for command line tools, accept the license, and run first-launch setup.
5. Configure Git with the user's name and email.
6. Complete the interactive GitHub SSH setup.
7. `setup.sh` then runs the repository clone script and clones all `project-init` repositories into `~/Desktop/vnext`.
8. Install [mise](https://mise.jdx.dev/getting-started.html)
9. Install [Docker](https://docs.docker.com/desktop/setup/install/mac-install/)

### Xcode Setup

The setup script uses `mas` to install or update Xcode from the Mac App Store. The user may need to be signed in to the App Store before this step can complete.

After Xcode is installed, the script runs:

- `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
- `sudo xcodebuild -license accept`
- `xcodebuild -runFirstLaunch`

### Git Configuration

The setup script asks for the user's Git name and email, then writes them to `~/.gitconfig` using global Git configuration.

It also configures:

- `init.defaultBranch` as `main`
- `pull.rebase` as `false`
- GitHub HTTPS clone URLs to use SSH through `git@github.com:`

### GitHub SSH and Repository Setup

The setup script walks each user through GitHub access in this order:

1. Enter the email address for the GitHub SSH key.
2. Create or reuse `~/.ssh/id_ed25519_github`.
3. Add the key to the local SSH agent.
4. Authenticate GitHub CLI with SSH using `gh auth login`.
5. Upload the public key to the user's GitHub account.
6. Verify SSH access to GitHub.
7. Run `scripts/clone_project_init_repos.sh` to create `~/Desktop/vnext` and clone every repository returned by GitHub for the `project-init` organization.

You can rerun the repository clone step directly:

```sh
./scripts/clone_project_init_repos.sh
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
