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
