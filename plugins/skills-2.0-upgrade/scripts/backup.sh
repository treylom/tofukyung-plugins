#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
  cat <<'EOF'
Usage:
  ./backup.sh /path/to/skills/              # Create backup
  ./backup.sh /path/to/skills/ --list       # List backups
  ./backup.sh --restore <backup-file>       # Restore backup
EOF
}

success() {
  printf '%b%s%b\n' "$GREEN" "$1" "$NC"
}

error() {
  printf '%b%s%b\n' "$RED" "$1" "$NC" >&2
}

warn() {
  printf '%b%s%b\n' "$YELLOW" "$1" "$NC"
}

die() {
  error "$1"
  exit 1
}

normalize_dir() {
  local dir="${1%/}"
  [ -d "$dir" ] || die "Skills directory not found: $1"
  (
    cd "$dir" >/dev/null 2>&1 || exit 1
    pwd -P
  )
}

archive_size() {
  du -h "$1" | cut -f1
}

format_timestamp() {
  local raw="$1"
  if [[ "$raw" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2})$ ]]; then
    printf '%s-%s-%s %s:%s:%s' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" "${BASH_REMATCH[5]}" "${BASH_REMATCH[6]}"
  else
    printf '%s' "$raw"
  fi
}

create_backup() {
  local skills_dir backup_dir parent_dir timestamp backup_file size
  skills_dir="$(normalize_dir "$1")"
  parent_dir="$(dirname "$skills_dir")"
  backup_dir="$parent_dir/.claude"
  timestamp="$(date +%Y%m%d-%H%M%S)"
  backup_file="$backup_dir/skills-backup-${timestamp}.tar.gz"

  mkdir -p "$backup_dir" || die "Failed to create backup directory: $backup_dir"
  tar -czf "$backup_file" -C "$parent_dir" "$(basename "$skills_dir")" || die "Failed to create backup archive"

  size="$(archive_size "$backup_file")"
  success "Backup created: $backup_file ($size)"
}

list_backups() {
  local skills_dir backup_dir found=false
  skills_dir="$(normalize_dir "$1")"
  backup_dir="$(dirname "$skills_dir")/.claude"

  printf '%-21s %-8s %s\n' 'Date' 'Size' 'File'
  printf '%-21s %-8s %s\n' '-------------------' '------' '----'

  for file in "$backup_dir"/skills-backup-*.tar.gz; do
    [ -e "$file" ] || continue
    found=true
    local base timestamp size
    base="$(basename "$file")"
    timestamp="${base#skills-backup-}"
    timestamp="${timestamp%.tar.gz}"
    size="$(archive_size "$file")"
    printf '%-21s %-8s %s\n' "$(format_timestamp "$timestamp")" "$size" "$base"
  done

  if [ "$found" = false ]; then
    warn "No backups found in $backup_dir"
  fi
}

restore_backup() {
  local backup_file backup_dir restore_root size reply
  backup_file="$1"
  [ -f "$backup_file" ] || die "Backup file not found: $backup_file"

  backup_dir="$(cd "$(dirname "$backup_file")" >/dev/null 2>&1 && pwd -P)"
  restore_root="$(dirname "$backup_dir")"
  size="$(archive_size "$backup_file")"

  printf 'Restore backup %s (%s) to %s? [y/N] ' "$backup_file" "$size" "$restore_root"
  read -r reply

  case "$reply" in
    y|Y|yes|YES)
      tar -xzf "$backup_file" -C "$restore_root" || die "Failed to restore backup"
      success "Backup restored: $backup_file"
      ;;
    *)
      die "Restore cancelled"
      ;;
  esac
}

main() {
  if [ "$#" -eq 0 ]; then
    usage
    exit 1
  fi

  case "$1" in
    --restore)
      [ "$#" -eq 2 ] || {
        usage
        exit 1
      }
      restore_backup "$2"
      ;;
    *)
      if [ "$#" -eq 1 ]; then
        create_backup "$1"
      elif [ "$#" -eq 2 ] && [ "$2" = '--list' ]; then
        list_backups "$1"
      else
        usage
        exit 1
      fi
      ;;
  esac
}

main "$@"
