#!/bin/sh

INSTALL_K8S=0
INSTALL_DOTNET_TOOLS=0

# Backup function
copy_old_zsh () {
  datetime=$(date '+%Y-%m-%d_%H-%M-%S')

  src_file=~/.zshrc
  dest_dir=~/.dotfiles/local/backup

  mkdir -p $dest_dir
  cp "$src_file" "$dest_dir/zshrc-$datetime"
}

set_custom_file_flags ()
{
  flag=$1
  original_value="$flag=$2"
  replacement_value="$flag=$3"

  for file in $(find ~/.oh-my-zsh/custom/ -type f -name "*.zsh"); do
    sed -i "s/$original_value/$replacement_value/g" $file
  done
}

# Install and configure custom scripts/files
custom_files ()
{
  custom_file_dir=~/.dotfiles/custom/general
  custom_theme_dir=~/.dotfiles/custom/theme
  custom_plugin_dir=~/.dotfiles/custom/plugin

  cp -r $custom_file_dir/** ~/.oh-my-zsh/custom/
  cp -r $custom_theme_dir/** ~/.oh-my-zsh/custom/themes/
  cp -r $custom_plugin_dir/** ~/.oh-my-zsh/custom/plugins/

  if [ "$INSTALL_K8S" -eq 1 ]; then
    set_custom_file_flags "USE_LINUXBREW" "0" "1"
    set_custom_file_flags "USE_KUBERNETES" "0" "1"
  fi

  if [ "$INSTALL_DOTNET_TOOLS" -eq 1 ]; then
    set_custom_file_flags "USE_DOTNET" "0" "1"
  fi
}

# Kubernetes stuff
kubernetes ()
{
  brew install kube-ps1
}

# Linuxbrew
linux_brew ()
{
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# ZSH Installation
install_omzsh()
{
  sudo apt install zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 
  
  cp ~/.dotfiles/zshrc ~/.zshrc
}
 
main ()
{
  copy_old_zsh

  install_omzsh

  custom_files

  if [ "$INSTALL_K8S" -eq 1 ]; then
    linux_brew
    kubernetes
  fi
}

while getopts "dk" opt; do
  case $opt in
    k) INSTALL_K8S=1 ;;
    d) INSTALL_DOTNET_TOOLS=1 ;;
    *) exit 1 ;;
  esac
done

shift $((OPTIND - 1))

main

source ~/.zshrc
