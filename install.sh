#!/usr/bin/env bash

# ==================
# ==================
# ==================
#     UNTESTED!
# ==================
# ==================
# ==================

set -euo pipefail

BIN_DIR="$HOME/.local/bin"
NVM_VERSION="v0.40.3"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
TPM_DIR="$HOME/.tmux/plugins/tpm"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
skip() { printf '\033[1;33m ->\033[0m %s (already installed)\n' "$1"; }
fail() { printf '\033[1;31mx %s\033[0m\n' "$*" >&2; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

arch_id() {
  case "$(uname -m)" in
    x86_64) echo "amd64" ;;
    aarch64 | arm64) echo "arm64" ;;
    *) fail "unsupported architecture: $(uname -m)" ;;
  esac
}

github_latest_tag() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" |
    grep -oP '"tag_name":\s*"\K[^"]+'
}

install_system_packages() {
  log "Installing system packages"
  if command_exists apt-get; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git zsh tmux neovim curl xclip ripgrep build-essential file
  elif command_exists dnf; then
    sudo dnf install -y git zsh tmux neovim curl xclip ripgrep gcc gcc-c++ make file
  elif command_exists pacman; then
    sudo pacman -S --needed --noconfirm git zsh tmux neovim curl xclip ripgrep base-devel file
  else
    fail "no supported package manager found (apt/dnf/pacman)"
  fi
}

install_oh_my_zsh() {
  if [ -d "$OH_MY_ZSH_DIR" ]; then
    skip "oh-my-zsh"
    return
  fi
  log "Installing oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"
  if [ "$SHELL" = "$zsh_path" ]; then
    skip "zsh as default shell"
    return
  fi
  log "Setting zsh as default shell (may prompt for password)"
  chsh -s "$zsh_path"
}

install_tpm() {
  if [ -d "$TPM_DIR" ]; then
    skip "tmux plugin manager (tpm)"
    return
  fi
  log "Installing tpm"
  git clone --quiet https://github.com/tmux-plugins/tpm "$TPM_DIR"
}

install_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    skip "nvm"
    return
  fi
  log "Installing nvm $NVM_VERSION"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
}

fetch_tarball_binary() {
  local repo="$1" asset_prefix="$2" binary="$3"
  if command_exists "$binary"; then
    skip "$binary"
    return
  fi
  local tag arch url tmp_dir
  tag="$(github_latest_tag "$repo")"
  arch="$(arch_id)"

  case "$repo" in
    jesseduffield/lazygit)
      url="https://github.com/jesseduffield/lazygit/releases/download/${tag}/lazygit_${tag#v}_Linux_x86_64.tar.gz"
      [ "$arch" = "arm64" ] && url="${url/x86_64/arm64}"
      ;;
    jesseduffield/lazydocker)
      url="https://github.com/jesseduffield/lazydocker/releases/download/${tag}/lazydocker_${tag#v}_Linux_x86_64.tar.gz"
      [ "$arch" = "arm64" ] && url="${url/x86_64/arm64}"
      ;;
    derailed/k9s)
      url="https://github.com/derailed/k9s/releases/download/${tag}/k9s_Linux_${arch}.tar.gz"
      ;;
    *) fail "unknown repo $repo" ;;
  esac

  log "Installing $binary $tag"
  tmp_dir="$(mktemp -d)"
  if curl -fsSL "$url" -o "$tmp_dir/binary.tar.gz" &&
    tar -xzf "$tmp_dir/binary.tar.gz" -C "$tmp_dir" "$binary"; then
    install -m 0755 "$tmp_dir/$binary" "$BIN_DIR/$binary"
  else
    rm -rf "$tmp_dir"
    fail "failed to download $binary from $url"
  fi
  rm -rf "$tmp_dir"
}

main() {
  mkdir -p "$BIN_DIR"

  install_system_packages
  install_oh_my_zsh
  set_default_shell
  install_tpm
  install_nvm

  fetch_tarball_binary "jesseduffield/lazygit" "lazygit" "lazygit"
  fetch_tarball_binary "jesseduffield/lazydocker" "lazydocker" "lazydocker"
  fetch_tarball_binary "derailed/k9s" "k9s" "k9s"

  log "Done. Make sure $BIN_DIR is on your PATH:"
  echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  echo "Remaining manual steps:"
  echo "  1. Start tmux and press prefix + I (Ctrl-a I) to install tmux plugins"
  echo "  2. Open nvim so lazy.nvim installs plugins on first run"
}

main "$@"
