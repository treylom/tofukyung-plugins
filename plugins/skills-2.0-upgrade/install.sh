#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

is_korean() {
  case "${LANG:-}" in
    ko*|ko_KR*) return 0 ;;
    *) return 1 ;;
  esac
}

text() {
  local en="$1"
  local ko="$2"
  if is_korean; then
    printf '%s' "$ko"
  else
    printf '%s' "$en"
  fi
}

info() {
  printf '%s\n' "$1"
}

success() {
  printf '%b%s%b\n' "$GREEN" "$1" "$NC"
}

warn() {
  printf '%b%s%b\n' "$YELLOW" "$1" "$NC"
}

error() {
  printf '%b%s%b\n' "$RED" "$1" "$NC" >&2
}

die() {
  error "$1"
  exit 1
}

detect_os() {
  local uname_s uname_r
  uname_s="$(uname -s)"
  uname_r="$(uname -r | tr '[:upper:]' '[:lower:]')"

  if [[ "$uname_r" == *microsoft* ]]; then
    printf 'WSL'
  elif [ "$uname_s" = 'Darwin' ]; then
    printf 'macOS'
  else
    printf 'Linux'
  fi
}

detect_source_dir() {
  if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" != 'bash' ] && [ -f "${BASH_SOURCE[0]}" ]; then
    CURL_PIPE=false
    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    return 0
  fi

  CURL_PIPE=true
  TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TEMP_DIR"' EXIT
  command -v git >/dev/null 2>&1 || die "$(text 'git is required for curl-pipe installation.' 'curl-pipe 설치에는 git이 필요합니다.')"
  git clone --depth 1 https://github.com/treylom/skills-2.0-upgrade.git "$TEMP_DIR" >/dev/null 2>&1 || die "$(text 'Failed to clone skills-2.0-upgrade repository.' 'skills-2.0-upgrade 저장소를 클론하지 못했습니다.')"
  SOURCE_DIR="$TEMP_DIR"
}

sync_dir() {
  local name="$1"
  local src="$SOURCE_DIR/$name"
  local dst="$CLAUDE_DIR/$name"

  mkdir -p "$dst"
  if [ -d "$src" ]; then
    cp -R "$src"/. "$dst"/
  fi
}

set_script_permissions() {
  local target_scripts="$CLAUDE_DIR/scripts"
  shopt -s nullglob
  local files=("$target_scripts"/*.sh)
  if [ "${#files[@]}" -gt 0 ]; then
    chmod +x "${files[@]}"
  fi
  shopt -u nullglob
}

print_completion() {
  local header usage_label direct_label
  header="$(text 'Skills 2.0 Auto-Upgrade installed successfully!' 'Skills 2.0 Auto-Upgrade가 성공적으로 설치되었습니다!')"
  usage_label="$(text 'Usage:' '사용법:')"
  direct_label="$(text 'Or run directly:' '또는 직접 실행:')"

  success "✅ $header"
  printf '\n%s\n' "$usage_label"
  printf '  /skills-upgrade              # Diagnose your skills\n'
  printf '  /skills-upgrade --dry-run    # Preview changes\n'
  printf '  /skills-upgrade --upgrade    # Auto-fix issues\n'
  printf '\n%s\n' "$direct_label"
  printf '  ~/.claude/scripts/diagnose.sh ~/.claude/skills/\n'
}

main() {
  local os claude_version warning_message

  printf '===========================================\n'
  printf '  Skills 2.0 Auto-Upgrade Installer v1.0.0\n'
  printf '===========================================\n'

  os="$(detect_os)"
  info "$(text "Detected OS: $os" "감지된 운영체제: $os")"

  if claude_version="$(claude --version 2>/dev/null)"; then
    info "$(text "Claude Code CLI detected: $claude_version" "Claude Code CLI 확인됨: $claude_version")"
  else
    warning_message="Claude Code CLI not found. Install from https://docs.anthropic.com/en/docs/claude-code"
    warn "$(text "$warning_message" "Claude Code CLI를 찾을 수 없습니다. https://docs.anthropic.com/en/docs/claude-code 에서 설치하세요")"
  fi

  detect_source_dir
  info "$(text "Source directory: $SOURCE_DIR" "소스 디렉토리: $SOURCE_DIR")"
  if [ "$CURL_PIPE" = true ]; then
    info "$(text 'Running in curl-pipe mode.' 'curl-pipe 모드로 실행 중입니다.')"
  else
    info "$(text 'Running in local mode.' '로컬 모드로 실행 중입니다.')"
  fi

  CLAUDE_DIR="$HOME/.claude"
  mkdir -p "$CLAUDE_DIR"

  sync_dir commands
  sync_dir skills
  sync_dir scripts
  set_script_permissions

  print_completion
}

main "$@"
