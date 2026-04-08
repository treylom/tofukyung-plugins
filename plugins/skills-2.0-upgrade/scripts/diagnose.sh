#!/usr/bin/env bash

set -u

SCRIPT_NAME=$(basename "$0")
VERSION="1.1.0"
TARGET=""
OUTPUT_FORMAT="markdown"
VERBOSE=0
NO_COLOR=0
SECURITY_MODE=0
TOTAL_SKILLS=0
OVERALL_SUM=0
CHECK_COUNT=12
EXIT_STATUS=0
NOW_LOCAL=$(date '+%Y-%m-%d %H:%M:%S')
NOW_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

CHECK_KEYS=(
  "frontmatter"
  "name_field"
  "description_field"
  "description_pattern"
  "description_third_person"
  "body_length"
  "directory_structure"
  "model_invocation"
  "orphan_directory"
  "broken_references"
  "progressive_disclosure"
  "imperative_form"
)

CHECK_LABELS=(
  "Frontmatter"
  "Name field"
  "Description field"
  "Description pattern"
  "Description third person"
  "Body length"
  "Directory structure"
  "disable-model-invocation"
  "Orphan directory"
  "Broken references"
  "Progressive disclosure"
  "Imperative form"
)

CHECK_WEIGHTS=(20 8 10 5 3 15 10 8 5 5 5 6)
CHECK_PASS_COUNTS=(0 0 0 0 0 0 0 0 0 0 0 0)
CHECK_FAIL_COUNTS=(0 0 0 0 0 0 0 0 0 0 0 0)
TOP_ISSUE_COUNTS=(0 0 0 0 0 0 0 0 0 0 0 0)

SKILL_NAMES=()
SKILL_PATHS=()
SKILL_SCORES=()
SKILL_ISSUES=()
SKILL_SUGGESTIONS=()
SKILL_BODY_LINES=()
SKILL_CHECKS=()

RED=''
GREEN=''
YELLOW=''
BLUE=''
BOLD=''
RESET=''

usage() {
  cat <<EOF
Usage:
  $SCRIPT_NAME <path-to-skill-or-directory> [--json] [--verbose] [--no-color]
  $SCRIPT_NAME <path-to-any-directory> --security [--json]

Modes:
  (default)    12-item Skills 2.0 compliance check
  --security   Pre-deployment security scan (PII, hardcoded paths, secrets)

Examples:
  $SCRIPT_NAME /path/to/skills/
  $SCRIPT_NAME /path/to/skills/ --json
  $SCRIPT_NAME /path/to/skills/ --verbose
  $SCRIPT_NAME /path/to/project/ --security
  $SCRIPT_NAME /path/to/project/ --security --json
EOF
}

init_colors() {
  if [ "$NO_COLOR" -eq 1 ] || [ ! -t 1 ]; then
    return
  fi
  RED=$(printf '\033[31m')
  GREEN=$(printf '\033[32m')
  YELLOW=$(printf '\033[33m')
  BLUE=$(printf '\033[34m')
  BOLD=$(printf '\033[1m')
  RESET=$(printf '\033[0m')
}

colorize() {
  color=$1
  shift
  printf '%s%s%s' "$color" "$*" "$RESET"
}

trim() {
  printf '%s' "$1" | awk '{ gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print }'
}

lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

join_by() {
  sep=$1
  shift
  result=''
  first=1
  for item in "$@"; do
    if [ "$first" -eq 1 ]; then
      result=$item
      first=0
    else
      result="$result$sep$item"
    fi
  done
  printf '%s' "$result"
}

json_escape() {
  printf '%s' "$1" | awk 'BEGIN { ORS = "" }
    {
      gsub(/\\/, "\\\\")
      gsub(/"/, "\\\"")
      gsub(/\t/, "\\t")
      gsub(/\r/, "\\r")
      if (NR > 1) {
        printf "\\n"
      }
      printf "%s", $0
    }'
}

json_array_from_list() {
  input=$1
  output=''
  old_ifs=$IFS
  IFS=';'
  for item in $input; do
    trimmed=$(trim "$item")
    [ -z "$trimmed" ] && continue
    escaped=$(json_escape "$trimmed")
    if [ -z "$output" ]; then
      output="\"$escaped\""
    else
      output="$output, \"$escaped\""
    fi
  done
  IFS=$old_ifs
  printf '%s' "$output"
}

add_issue() {
  current=$1
  addition=$2
  if [ -z "$current" ]; then
    printf '%s' "$addition"
  else
    printf '%s; %s' "$current" "$addition"
  fi
}

bool_json() {
  if [ "$1" -eq 1 ]; then
    printf 'true'
  else
    printf 'false'
  fi
}

increment_issue_counter() {
  idx=$1
  value=${TOP_ISSUE_COUNTS[$idx]}
  TOP_ISSUE_COUNTS[$idx]=$((value + 1))
}

update_check_summary() {
  idx=$1
  passed=$2
  if [ "$passed" -eq 1 ]; then
    CHECK_PASS_COUNTS[$idx]=$((CHECK_PASS_COUNTS[$idx] + 1))
  else
    CHECK_FAIL_COUNTS[$idx]=$((CHECK_FAIL_COUNTS[$idx] + 1))
    increment_issue_counter "$idx"
  fi
}

is_reference_skill() {
  haystack=$(lower "$1")
  case "$haystack" in
    *guide*|*reference*|*spec*|*examples*|*templates*|*schema*|*collection*|*strategies*|*checklist*|*encyclopedia*|*glossary*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

extract_frontmatter_line() {
  file=$1
  close_line=$2
  key=$3
  awk -v close_line="$close_line" -v key="$key" '
    NR > 1 && NR < close_line {
      line = $0
      lower_line = tolower(line)
      prefix = tolower(key) ":"
      if (lower_line ~ "^[[:space:]]*" prefix "[[:space:]]*") {
        sub("^[[:space:]]*[^:]+:[[:space:]]*", "", line)
        print line
        exit
      }
    }
  ' "$file"
}

body_to_temp() {
  file=$1
  start_line=$2
  temp_file=$3
  if [ "$start_line" -le 1 ]; then
    cat "$file" > "$temp_file"
  else
    sed -n "${start_line},\$p" "$file" > "$temp_file"
  fi
}

count_word_matches() {
  file=$1
  pattern=$2
  count=$(grep -Eio "$pattern" "$file" 2>/dev/null | wc -l | awk '{print $1}')
  printf '%s' "${count:-0}"
}

scan_paths() {
  target=$1
  if [ -f "$target" ]; then
    case "$target" in
      */references/*)
        return
        ;;
      *.md)
        printf '%s\n' "$target"
        ;;
    esac
    return
  fi

  find "$target" -type f -name '*.md' ! -path '*/references/*' | sort | while IFS= read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    if [ "$base" = "SKILL.md" ]; then
      printf '%s\n' "$file"
    elif [ -f "$dir/SKILL.md" ]; then
      continue
    else
      printf '%s\n' "$file"
    fi
  done

  find "$target" -type d ! -path '*/references*' | sort | while IFS= read -r dir; do
    direct_md_count=$(find "$dir" -maxdepth 1 -type f -name '*.md' ! -path '*/references/*' | wc -l | awk '{print $1}')
    child_dir_count=$(find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name 'references' | wc -l | awk '{print $1}')
    if [ "$direct_md_count" -eq 0 ] && [ "$child_dir_count" -eq 0 ]; then
      printf 'DIR::%s\n' "$dir"
    fi
  done
}

check_references() {
  body_file=$1
  skill_dir=$2
  refs_found=0
  broken=0
  missing=''

  while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    refs_found=1
    if [ ! -e "$skill_dir/$ref" ]; then
      broken=1
      missing=$(add_issue "$missing" "$ref")
    fi
  done <<EOF
$(grep -Eo 'references/[A-Za-z0-9._/-]+' "$body_file" 2>/dev/null | sort -u)
EOF

  if [ "$refs_found" -eq 0 ]; then
    printf '1\t\n'
  elif [ "$broken" -eq 0 ]; then
    printf '1\t\n'
  else
    printf '0\t%s\n' "$missing"
  fi
}

record_orphan_directory() {
  skill_dir=$1
  skill_name=$(basename "$skill_dir")
  relative_path=$skill_dir
  if [ -d "$TARGET" ]; then
    case "$skill_dir" in
      "$TARGET"/*)
        relative_path=${skill_dir#"$TARGET"/}
        ;;
      "$TARGET")
        relative_path=.
        ;;
    esac
  fi

  pass_bits='111111110111'
  issues='Orphan skill directory'
  suggestions='Add SKILL.md or a markdown entry file to the directory'
  score='95.0'

  update_check_summary 8 0
  idx=0
  while [ "$idx" -lt "$CHECK_COUNT" ]; do
    if [ "$idx" -ne 8 ]; then
      update_check_summary "$idx" 1
    fi
    idx=$((idx + 1))
  done

  OVERALL_SUM=$(awk -v current="$OVERALL_SUM" -v add="$score" 'BEGIN { printf "%.1f", current + add }')
  EXIT_STATUS=2

  SKILL_NAMES+=("$skill_name")
  SKILL_PATHS+=("$relative_path")
  SKILL_SCORES+=("$score")
  SKILL_ISSUES+=("$issues")
  SKILL_SUGGESTIONS+=("$suggestions")
  SKILL_BODY_LINES+=("0")
  SKILL_CHECKS+=("$pass_bits")
  TOTAL_SKILLS=$((TOTAL_SKILLS + 1))
}

analyze_skill() {
  skill_file=$1
  if printf '%s' "$skill_file" | grep -q '^DIR::'; then
    record_orphan_directory "${skill_file#DIR::}"
    return
  fi

  skill_dir=$(dirname "$skill_file")
  skill_name=$(basename "$skill_file")
  relative_path=$skill_file
  if [ -d "$TARGET" ]; then
    case "$skill_file" in
      "$TARGET"/*)
        relative_path=${skill_file#"$TARGET"/}
        ;;
    esac
  fi

  first_line=$(sed -n '1p' "$skill_file")
  close_line=''
  has_frontmatter=0
  if [ "$first_line" = "---" ]; then
    close_line=$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "$skill_file")
    if [ -n "$close_line" ]; then
      has_frontmatter=1
    fi
  fi

  if [ "$has_frontmatter" -eq 1 ]; then
    name_value=$(extract_frontmatter_line "$skill_file" "$close_line" "name")
    description_value=$(extract_frontmatter_line "$skill_file" "$close_line" "description")
    disable_value=$(extract_frontmatter_line "$skill_file" "$close_line" "disable-model-invocation")
    body_start=$((close_line + 1))
  else
    name_value=''
    description_value=''
    disable_value=''
    body_start=1
  fi

  if [ -n "$name_value" ]; then
    skill_name=$name_value
  else
    skill_name=$(basename "$skill_file" .md)
  fi

  body_lines=$(awk -v start="$body_start" 'NR >= start { count++ } END { print count + 0 }' "$skill_file")

  body_file=$(mktemp)
  body_to_temp "$skill_file" "$body_start" "$body_file"

  issues=''
  suggestions=''
  total_weight=0
  pass_bits=''

  check_pass=0
  if [ "$has_frontmatter" -eq 1 ]; then
    check_pass=1
  else
    issues=$(add_issue "$issues" "Missing frontmatter")
    suggestions=$(add_issue "$suggestions" "Add YAML frontmatter delimited by ---")
  fi
  update_check_summary 0 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[0])))
  pass_bits="${pass_bits}${check_pass}"

  trimmed_name=$(trim "$name_value")
  check_pass=0
  if [ -n "$trimmed_name" ] && printf '%s' "$trimmed_name" | grep -Eq '^[A-Za-z0-9-]+$'; then
    check_pass=1
  else
    issues=$(add_issue "$issues" "Missing or invalid name field")
    suggestions=$(add_issue "$suggestions" "Add name: in kebab-case or alphanumeric form")
  fi
  update_check_summary 1 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[1])))
  pass_bits="${pass_bits}${check_pass}"

  trimmed_description=$(trim "$description_value")
  check_pass=0
  if [ -n "$trimmed_description" ]; then
    check_pass=1
  else
    issues=$(add_issue "$issues" "Missing description")
    suggestions=$(add_issue "$suggestions" "Add a non-empty description field")
  fi
  update_check_summary 2 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[2])))
  pass_bits="${pass_bits}${check_pass}"

  check_pass=0
  if [ -n "$trimmed_description" ] && printf '%s' "$trimmed_description" | grep -Eiq '^use when'; then
    check_pass=1
  else
    issues=$(add_issue "$issues" "Description should start with Use when")
    suggestions=$(add_issue "$suggestions" "Start description with 'Use when...'")
  fi
  update_check_summary 3 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[3])))
  pass_bits="${pass_bits}${check_pass}"

  check_pass=0
  if [ -n "$trimmed_description" ] && ! printf '%s' "$trimmed_description" | grep -Eiq '(^|[^[:alpha:]])(you|your)([^[:alpha:]]|$)'; then
    check_pass=1
  else
    issues=$(add_issue "$issues" "Description should avoid second-person phrasing")
    suggestions=$(add_issue "$suggestions" "Rewrite description in third person")
  fi
  update_check_summary 4 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[4])))
  pass_bits="${pass_bits}${check_pass}"

  check_pass=0
  if [ "$body_lines" -le 500 ]; then
    check_pass=1
  else
    issues=$(add_issue "$issues" "Body exceeds 500 lines")
    suggestions=$(add_issue "$suggestions" "Split long content into SKILL.md and references/")
  fi
  update_check_summary 5 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[5])))
  pass_bits="${pass_bits}${check_pass}"

  check_pass=0
  if [ "$body_lines" -le 500 ]; then
    check_pass=1
  elif [ "$(basename "$skill_file")" = "SKILL.md" ] && [ -d "$skill_dir/references" ]; then
    check_pass=1
  else
    issues=$(add_issue "$issues" "Long skill is missing SKILL.md plus references/")
    suggestions=$(add_issue "$suggestions" "Use SKILL.md as the entry point and move detail into references/")
  fi
  update_check_summary 6 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[6])))
  pass_bits="${pass_bits}${check_pass}"

  check_pass=1
  if is_reference_skill "$(basename "$skill_file" .md) $(trim "$name_value")"; then
    if printf '%s' "$(trim "$disable_value")" | grep -Eiq '^true$'; then
      check_pass=1
    else
      check_pass=0
      issues=$(add_issue "$issues" "Reference-style skill is missing disable-model-invocation: true")
      suggestions=$(add_issue "$suggestions" "Add disable-model-invocation: true to frontmatter")
    fi
  fi
  update_check_summary 7 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[7])))
  pass_bits="${pass_bits}${check_pass}"

  check_pass=0
  md_count=$(find "$skill_dir" -maxdepth 1 -type f -name '*.md' ! -path '*/references/*' | wc -l | awk '{print $1}')
  if [ "$md_count" -gt 0 ] || [ -f "$skill_dir/SKILL.md" ]; then
    check_pass=1
  else
    issues=$(add_issue "$issues" "Orphan skill directory")
    suggestions=$(add_issue "$suggestions" "Add SKILL.md or a markdown entry file to the directory")
  fi
  update_check_summary 8 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[8])))
  pass_bits="${pass_bits}${check_pass}"

  ref_result=$(check_references "$body_file" "$skill_dir")
  ref_pass=$(printf '%s' "$ref_result" | awk -F '\t' '{print $1}')
  ref_missing=$(printf '%s' "$ref_result" | awk -F '\t' '{print $2}')
  check_pass=$ref_pass
  if [ "$check_pass" -ne 1 ]; then
    issues=$(add_issue "$issues" "Broken references: $ref_missing")
    suggestions=$(add_issue "$suggestions" "Fix references/ links or add the missing files")
  fi
  update_check_summary 9 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[9])))
  pass_bits="${pass_bits}${check_pass}"

  check_pass=1
  if [ -d "$skill_dir/references" ]; then
    if [ "$(basename "$skill_file")" = "SKILL.md" ] || [ ! -f "$skill_dir/SKILL.md" ]; then
      if grep -Eiq 'See[[:space:]]+`?references/' "$body_file"; then
        check_pass=1
      else
        check_pass=0
        issues=$(add_issue "$issues" "No progressive disclosure pattern found")
        suggestions=$(add_issue "$suggestions" "Add a 'See references/...' pointer in the body")
      fi
    fi
  fi
  update_check_summary 10 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[10])))
  pass_bits="${pass_bits}${check_pass}"

  imperative_count=$(count_word_matches "$body_file" '\b(Run|Check|Create|Use|Add|See|Fix|Move|Split|Rewrite|Update)\b')
  guidance_count=$(count_word_matches "$body_file" '\b(you should|you must|you need)\b')
  check_pass=0
  if [ "$imperative_count" -gt "$guidance_count" ]; then
    check_pass=1
  else
    issues=$(add_issue "$issues" "Imperative phrasing is weaker than second-person guidance")
    suggestions=$(add_issue "$suggestions" "Rewrite body instructions as direct commands")
  fi
  update_check_summary 11 "$check_pass"
  total_weight=$((total_weight + (check_pass * CHECK_WEIGHTS[11])))
  pass_bits="${pass_bits}${check_pass}"

  rm -f "$body_file"

  score=$(awk -v total="$total_weight" 'BEGIN { printf "%.1f", total / 100 * 100 }')
  OVERALL_SUM=$(awk -v current="$OVERALL_SUM" -v add="$score" 'BEGIN { printf "%.1f", current + add }')

  if [ "$score" != "100.0" ]; then
    EXIT_STATUS=2
  fi

  SKILL_NAMES+=("$skill_name")
  SKILL_PATHS+=("$relative_path")
  SKILL_SCORES+=("$score")
  SKILL_ISSUES+=("$issues")
  SKILL_SUGGESTIONS+=("$suggestions")
  SKILL_BODY_LINES+=("$body_lines")
  SKILL_CHECKS+=("$pass_bits")
  TOTAL_SKILLS=$((TOTAL_SKILLS + 1))
}

print_markdown_report() {
  if [ "$TOTAL_SKILLS" -eq 0 ]; then
    overall='0.0'
  else
    overall=$(awk -v sum="$OVERALL_SUM" -v total="$TOTAL_SKILLS" 'BEGIN { printf "%.1f", sum / total }')
  fi

  printf 'Skills 2.0 Compliance Report\n'
  printf '=============================\n'
  printf 'Date: %s\n' "$NOW_LOCAL"
  printf 'Path: %s\n' "$TARGET"
  printf 'Skills scanned: %s\n' "$TOTAL_SKILLS"
  printf 'Overall compliance: %s%%\n\n' "$overall"

  printf '| # | Skill | Score | Issues |\n'
  printf '|---|-------|-------|--------|\n'
  idx=0
  while [ "$idx" -lt "$TOTAL_SKILLS" ]; do
    num=$((idx + 1))
    issues=${SKILL_ISSUES[$idx]}
    if [ -z "$issues" ]; then
      issues='-'
    fi
    printf '| %s | %s | %s%% | %s |\n' "$num" "${SKILL_NAMES[$idx]}" "${SKILL_SCORES[$idx]}" "$issues"
    idx=$((idx + 1))
  done

  printf '\nTop Issues:\n'
  top_lines=0
  idx=0
  while [ "$idx" -lt "$CHECK_COUNT" ]; do
    count=${TOP_ISSUE_COUNTS[$idx]}
    if [ "$count" -gt 0 ]; then
      top_lines=$((top_lines + 1))
      printf '%s. %s: %s skills\n' "$top_lines" "${CHECK_LABELS[$idx]}" "$count"
    fi
    idx=$((idx + 1))
  done
  if [ "$top_lines" -eq 0 ]; then
    printf '1. None\n'
  fi

  printf '\nRecommendations:\n'
  printf -- '- Run with --verbose to see per-skill details\n'
  printf -- '- Use /skills-upgrade --upgrade to auto-fix P1-P4 issues\n'
}

print_verbose_report() {
  print_markdown_report
  printf '\nDetailed Results:\n'
  idx=0
  while [ "$idx" -lt "$TOTAL_SKILLS" ]; do
    printf '\n[%s] %s (%s%%)\n' "$((idx + 1))" "${SKILL_PATHS[$idx]}" "${SKILL_SCORES[$idx]}"
    pass_bits=${SKILL_CHECKS[$idx]}
    check_idx=0
    while [ "$check_idx" -lt "$CHECK_COUNT" ]; do
      bit=$(printf '%s' "$pass_bits" | cut -c $((check_idx + 1)))
      label=${CHECK_LABELS[$check_idx]}
      weight=${CHECK_WEIGHTS[$check_idx]}
      if [ "$bit" = "1" ]; then
        status=$(colorize "$GREEN" "PASS")
      else
        status=$(colorize "$RED" "FAIL")
      fi
      if [ "$check_idx" -eq 5 ]; then
        printf '  - %s [%s/%s] lines=%s\n' "$label" "$status" "$weight" "${SKILL_BODY_LINES[$idx]}"
      else
        printf '  - %s [%s/%s]\n' "$label" "$status" "$weight"
      fi
      check_idx=$((check_idx + 1))
    done
    issues=${SKILL_ISSUES[$idx]}
    suggestions=${SKILL_SUGGESTIONS[$idx]}
    if [ -n "$issues" ]; then
      printf '  Issues: %s\n' "$issues"
    fi
    if [ -n "$suggestions" ]; then
      printf '  Suggestions: %s\n' "$suggestions"
    fi
    idx=$((idx + 1))
  done
}

print_json_report() {
  if [ "$TOTAL_SKILLS" -eq 0 ]; then
    overall='0.0'
  else
    overall=$(awk -v sum="$OVERALL_SUM" -v total="$TOTAL_SKILLS" 'BEGIN { printf "%.1f", sum / total }')
  fi

  printf '{\n'
  printf '  "date": "%s",\n' "$NOW_UTC"
  printf '  "path": "%s",\n' "$(json_escape "$TARGET")"
  printf '  "total_skills": %s,\n' "$TOTAL_SKILLS"
  printf '  "overall_compliance": %s,\n' "$overall"
  printf '  "skills": [\n'

  idx=0
  while [ "$idx" -lt "$TOTAL_SKILLS" ]; do
    pass_bits=${SKILL_CHECKS[$idx]}
    issues=${SKILL_ISSUES[$idx]}
    suggestions=${SKILL_SUGGESTIONS[$idx]}
    printf '    {\n'
    printf '      "name": "%s",\n' "$(json_escape "${SKILL_NAMES[$idx]}")"
    printf '      "path": "%s",\n' "$(json_escape "${SKILL_PATHS[$idx]}")"
    printf '      "score": %s,\n' "${SKILL_SCORES[$idx]}"
    printf '      "checks": {\n'

    check_idx=0
    while [ "$check_idx" -lt "$CHECK_COUNT" ]; do
      key=${CHECK_KEYS[$check_idx]}
      weight=${CHECK_WEIGHTS[$check_idx]}
      bit=$(printf '%s' "$pass_bits" | cut -c $((check_idx + 1)))
      printf '        "%s": { "pass": %s, "weight": %s' "$key" "$(bool_json "$bit")" "$weight"
      if [ "$check_idx" -eq 5 ]; then
        printf ', "lines": %s' "${SKILL_BODY_LINES[$idx]}"
      fi
      if [ "$check_idx" -eq 11 ]; then
        printf ' }\n'
      else
        printf ' },\n'
      fi
      check_idx=$((check_idx + 1))
    done

    if [ -n "$issues" ]; then
      issue_json=$(json_array_from_list "$issues")
    else
      issue_json=''
    fi

    if [ -n "$suggestions" ]; then
      suggestion_json=$(json_array_from_list "$suggestions")
    else
      suggestion_json=''
    fi

    printf '      },\n'
    printf '      "issues": [%s],\n' "$issue_json"
    printf '      "suggestions": [%s]\n' "$suggestion_json"

    if [ "$idx" -eq $((TOTAL_SKILLS - 1)) ]; then
      printf '    }\n'
    else
      printf '    },\n'
    fi
    idx=$((idx + 1))
  done

  printf '  ],\n'
  printf '  "summary": {\n'
  printf '    "by_check": {\n'
  idx=0
  while [ "$idx" -lt "$CHECK_COUNT" ]; do
    key=${CHECK_KEYS[$idx]}
    pass=${CHECK_PASS_COUNTS[$idx]}
    fail=${CHECK_FAIL_COUNTS[$idx]}
    total=$((pass + fail))
    if [ "$total" -eq 0 ]; then
      rate='0.0'
    else
      rate=$(awk -v pass="$pass" -v total="$total" 'BEGIN { printf "%.1f", (pass / total) * 100 }')
    fi
    printf '      "%s": { "pass": %s, "fail": %s, "rate": %s }' "$key" "$pass" "$fail" "$rate"
    if [ "$idx" -eq $((CHECK_COUNT - 1)) ]; then
      printf '\n'
    else
      printf ',\n'
    fi
    idx=$((idx + 1))
  done
  printf '    }\n'
  printf '  }\n'
  printf '}\n'
}

parse_args() {
  if [ "$#" -lt 1 ]; then
    usage
    exit 1
  fi

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --json)
        OUTPUT_FORMAT="json"
        ;;
      --markdown)
        OUTPUT_FORMAT="markdown"
        ;;
      --security)
        SECURITY_MODE=1
        ;;
      --verbose)
        VERBOSE=1
        ;;
      --no-color)
        NO_COLOR=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      --version)
        printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
        exit 0
        ;;
      --*)
        printf 'Error: unknown option %s\n' "$1" >&2
        exit 1
        ;;
      *)
        if [ -z "$TARGET" ]; then
          TARGET=$1
        else
          printf 'Error: multiple paths supplied\n' >&2
          exit 1
        fi
        ;;
    esac
    shift
  done

  if [ -z "$TARGET" ]; then
    printf 'Error: target path is required\n' >&2
    exit 1
  fi

  if [ ! -e "$TARGET" ]; then
    printf 'Error: path not found: %s\n' "$TARGET" >&2
    exit 1
  fi

  if [ -f "$TARGET" ] && [ "${TARGET##*.}" != "md" ]; then
    printf 'Error: target file must be a .md skill file\n' >&2
    exit 1
  fi
}

## Security Scan Mode ##

SEC_TOTAL_FILES=0
SEC_TOTAL_FINDINGS=0
SEC_FINDINGS=()

SEC_PATTERNS=(
  '/home/[a-z]'
  '/Users/[A-Z]'
  '/mnt/c/Users'
  'C:\\Users'
  'api[_-]key\s*[:=]'
  'api[_-]secret'
  'password\s*[:=]'
  'ntn_[a-zA-Z0-9]'
  'sk-[a-zA-Z0-9]'
  'ghp_[a-zA-Z0-9]'
  'PRIVATE KEY'
  'Bearer [a-zA-Z0-9]'
  'token\s*[:=]\s*["\x27][a-zA-Z0-9]'
)

SEC_LABELS=(
  "Hardcoded home path"
  "Hardcoded macOS user path"
  "Hardcoded WSL user path"
  "Hardcoded Windows path"
  "API key assignment"
  "API secret"
  "Password assignment"
  "Notion API token"
  "OpenAI API key"
  "GitHub personal token"
  "Private key block"
  "Bearer token"
  "Hardcoded token value"
)

SEC_SEVERITIES=(
  "medium"
  "medium"
  "medium"
  "medium"
  "high"
  "high"
  "high"
  "critical"
  "critical"
  "critical"
  "critical"
  "high"
  "high"
)

security_scan_file() {
  file=$1
  rel_path=$2
  local found=0

  idx=0
  while [ "$idx" -lt "${#SEC_PATTERNS[@]}" ]; do
    pattern=${SEC_PATTERNS[$idx]}
    label=${SEC_LABELS[$idx]}
    severity=${SEC_SEVERITIES[$idx]}

    matches=$(grep -Eon "$pattern" "$file" 2>/dev/null | head -5)
    if [ -n "$matches" ]; then
      found=1
      while IFS= read -r match_line; do
        line_num=$(printf '%s' "$match_line" | cut -d: -f1)
        snippet=$(printf '%s' "$match_line" | cut -d: -f2- | head -c 80)
        SEC_FINDINGS+=("${severity}|${rel_path}|${line_num}|${label}|${snippet}")
        SEC_TOTAL_FINDINGS=$((SEC_TOTAL_FINDINGS + 1))
      done <<MATCHEOF
$matches
MATCHEOF
    fi
    idx=$((idx + 1))
  done

  SEC_TOTAL_FILES=$((SEC_TOTAL_FILES + 1))
  return $found
}

security_scan_dir() {
  target=$1
  local file_list
  file_list=$(find "$target" -type f \( -name '*.md' -o -name '*.sh' -o -name '*.py' -o -name '*.js' -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' -o -name '*.toml' -o -name '*.txt' \) ! -path '*/.git/*' ! -path '*/node_modules/*' | sort)

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    rel=$(printf '%s' "$file" | sed "s|^$target/||")
    security_scan_file "$file" "$rel"
  done <<SCANEOF
$file_list
SCANEOF
}

print_security_markdown() {
  printf 'Security Scan Report\n'
  printf '====================\n'
  printf 'Date: %s\n' "$NOW_LOCAL"
  printf 'Path: %s\n' "$TARGET"
  printf 'Files scanned: %s\n' "$SEC_TOTAL_FILES"
  printf 'Findings: %s\n\n' "$SEC_TOTAL_FINDINGS"

  if [ "$SEC_TOTAL_FINDINGS" -eq 0 ]; then
    printf 'No security issues found.\n'
    return
  fi

  crit=0; high=0; med=0
  for f in "${SEC_FINDINGS[@]}"; do
    sev=$(printf '%s' "$f" | cut -d'|' -f1)
    case "$sev" in
      critical) crit=$((crit + 1)) ;;
      high) high=$((high + 1)) ;;
      medium) med=$((med + 1)) ;;
    esac
  done
  printf 'Summary: %s critical, %s high, %s medium\n\n' "$crit" "$high" "$med"

  printf '| Severity | File | Line | Issue | Snippet |\n'
  printf '|----------|------|------|-------|---------|\n'
  for f in "${SEC_FINDINGS[@]}"; do
    sev=$(printf '%s' "$f" | cut -d'|' -f1)
    file=$(printf '%s' "$f" | cut -d'|' -f2)
    line=$(printf '%s' "$f" | cut -d'|' -f3)
    label=$(printf '%s' "$f" | cut -d'|' -f4)
    snippet=$(printf '%s' "$f" | cut -d'|' -f5 | head -c 40)
    printf '| %s | %s | %s | %s | %s |\n' "$sev" "$file" "$line" "$label" "$snippet"
  done

  printf '\nRecommendations:\n'
  if [ "$crit" -gt 0 ]; then
    printf -- '- CRITICAL: Remove or replace leaked secrets before deployment\n'
  fi
  if [ "$high" -gt 0 ]; then
    printf -- '- HIGH: Replace API keys/tokens with environment variable references\n'
  fi
  if [ "$med" -gt 0 ]; then
    printf -- '- MEDIUM: Replace hardcoded paths with relative paths or variables\n'
  fi
}

print_security_json() {
  printf '{\n'
  printf '  "date": "%s",\n' "$NOW_UTC"
  printf '  "path": "%s",\n' "$(json_escape "$TARGET")"
  printf '  "files_scanned": %s,\n' "$SEC_TOTAL_FILES"
  printf '  "total_findings": %s,\n' "$SEC_TOTAL_FINDINGS"
  printf '  "findings": [\n'

  idx=0
  for f in "${SEC_FINDINGS[@]}"; do
    sev=$(printf '%s' "$f" | cut -d'|' -f1)
    file=$(printf '%s' "$f" | cut -d'|' -f2)
    line=$(printf '%s' "$f" | cut -d'|' -f3)
    label=$(printf '%s' "$f" | cut -d'|' -f4)
    snippet=$(printf '%s' "$f" | cut -d'|' -f5)
    printf '    { "severity": "%s", "file": "%s", "line": %s, "issue": "%s", "snippet": "%s" }' \
      "$sev" "$(json_escape "$file")" "$line" "$(json_escape "$label")" "$(json_escape "$snippet")"
    idx=$((idx + 1))
    if [ "$idx" -lt "$SEC_TOTAL_FINDINGS" ]; then
      printf ',\n'
    else
      printf '\n'
    fi
  done

  printf '  ]\n'
  printf '}\n'
}

run_security_scan() {
  init_colors
  security_scan_dir "$TARGET"
  if [ "$OUTPUT_FORMAT" = "json" ]; then
    print_security_json
  else
    print_security_markdown
  fi
  if [ "$SEC_TOTAL_FINDINGS" -gt 0 ]; then
    exit 2
  fi
  exit 0
}

## Main ##

main() {
  parse_args "$@"

  if [ "$SECURITY_MODE" -eq 1 ]; then
    run_security_scan
  fi

  init_colors

  while IFS= read -r skill_path; do
    [ -z "$skill_path" ] && continue
    analyze_skill "$skill_path"
  done <<EOF
$(scan_paths "$TARGET")
EOF

  if [ "$VERBOSE" -eq 1 ]; then
    print_verbose_report
  elif [ "$OUTPUT_FORMAT" = "json" ]; then
    print_json_report
  else
    print_markdown_report
  fi

  if [ "$TOTAL_SKILLS" -eq 0 ]; then
    EXIT_STATUS=2
  fi

  exit "$EXIT_STATUS"
}

main "$@"
