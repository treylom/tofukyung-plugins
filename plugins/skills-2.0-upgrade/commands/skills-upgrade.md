---
description: "Skills 2.0 auto-diagnosis and guided upgrade. /skills-upgrade [skill-name...] [--all] [--diagnose] [--dry-run] [--path <dir>]"
allowedTools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# /skills-upgrade

Diagnose and upgrade skills to Skills 2.0 compliance through a guided, interactive workflow. Supports single skill, multiple skills, or full directory.

## Usage

```bash
/skills-upgrade                        # Interactive — asks what to upgrade
/skills-upgrade my-skill               # Single skill by name
/skills-upgrade skill-a skill-b        # Multiple skills by name
/skills-upgrade --all                  # All skills in default directory
/skills-upgrade --diagnose             # Diagnose only (read-only, no changes)
/skills-upgrade --dry-run              # Preview changes without applying
/skills-upgrade --path /custom/skills/ # Custom target directory
```

Default path: `$HOME/.claude/skills/`

## Execution Flow

All runs follow the same flow. `--diagnose` and `--dry-run` exit early at the indicated points.

```
Step 0 (Target) → Phase 1 (Scan) → Phase 2 (Report)
                                       ↓
                              --diagnose stops here
                                       ↓
                                 Phase 3 (Plan)
                                       ↓
                               --dry-run stops here
                                       ↓
                                 Phase 4 (Execute)
```

### Step 0 — Target Selection

Before anything, determine what to upgrade.

#### Case A: Skill names provided

`/skills-upgrade my-skill skill-b` — resolve each name:

1. `$SKILLS_DIR/{name}.md` (flat file)
2. `$SKILLS_DIR/{name}/SKILL.md` (directory skill)
3. Exact path if absolute path given

If not found, list available skills and ask the user to pick.

#### Case B: `--all` or `--path`

Scan the entire directory.

#### Case C: No arguments (interactive)

Run a full scan to show what's available, then ask:

```
AskUserQuestion:
  "What would you like to upgrade?"
  Options:
    - "Specific skill(s)" — I'll show the list to pick from
    - "All skills" — Scan and upgrade the entire directory
```

If "Specific skill(s)", show a scored list:

```markdown
## Your Skills (sorted by compliance score)

| # | Skill | Score | Top Issue |
|---|-------|-------|-----------|
| 1 | my-broken-skill | 48% | Missing frontmatter |
| 2 | old-helper | 62% | Body >500 lines |
| 3 | api-guide | 75% | No "Use when..." |
| ... | ... | ... | ... |

Skills below 100%: M of N
```

```
AskUserQuestion:
  "Which skills? Enter names or numbers (comma-separated), or 'all'."
  (free text input)
```

#### Result

Set `TARGET_SKILLS` — a list of file paths or `"all"`. All subsequent steps respect this scope.

### Phase 1 — Scan

```bash
# Specific skills
scripts/diagnose.sh "$skill_path" --json   # per skill

# All skills
scripts/diagnose.sh "$TARGET_PATH" --json
```

Parse JSON: compliance score, skill count, issues by P1-P7.

### Phase 2 — Report

#### For specific skill(s):

```markdown
## Compliance Report: {skill-name}

Score: X% (N of 12 checks passed)

| # | Check | Weight | Status | Note |
|---|-------|--------|--------|------|
| 1 | Frontmatter | 20% | PASS/FAIL | ... |
| ... | ... | ... | ... | ... |

Issues: [list]
Suggestions: [list]
```

#### For all skills:

```markdown
## Your Skills 2.0 Compliance Report

| Metric | Value |
|--------|-------|
| Skills scanned | N |
| Overall compliance | X% |

### Issue Breakdown

| Priority | Count | What it means | Impact if fixed |
|----------|-------|---------------|-----------------|
| P1 | N | No frontmatter — can't be discovered | High |
| P2 | N | Invalid name — breaks identification | Medium |
| P3 | N | No "Use when..." — low discoverability | High aggregate |
| P4 | N | Missing invocation control | Low per skill |
| P5 | N | Body >500 lines | Medium |
| P6-P7 | N | Structure/orphan issues | Low |
```

#### Always show upgrade path:

```markdown
### Recommended Upgrade Path

| Phase | Fixes | Expected gain | Automation |
|-------|-------|--------------|------------|
| P1-P2 | Frontmatter + name | +10-16%p | Fully automatic |
| P3 | Description "Use when..." | +8-16%p | Semi-auto (preview) |
| P4 | Invocation control | +1-3%p | Semi-auto (confirm) |
| P5+ | File splitting + structure | +2-6%p | Manual (Opus) |

Biggest bang-for-buck: P1-P3 typically takes 62% → 94%.
```

**`--diagnose` stops here.**

### Phase 3 — Plan

Show proposed changes for the selected scope:

```markdown
## Planned Changes

- **P1**: N files will receive frontmatter
- **P2**: N names will be normalized
- **P3**: N descriptions will get "Use when..." pattern
- **P4**: N reference files will get invocation control
- **P5+**: N files need manual follow-up (>500 lines, broken refs)

Backup will be created before any changes.
```

**`--dry-run` stops here.**

### Phase 4 — Execute (interactive default)

#### Step 4.0 — Ask upgrade depth

```
AskUserQuestion:
  "How far would you like to upgrade?"
  Options:
    - "P1-P2 only (automatic, safe)"
    - "P1-P3 (recommended)"
    - "P1-P4 (thorough)"
    - "P1-P4 + P5 guidance (full)"
```

#### Step 4.1 — Backup

```bash
scripts/backup.sh "$TARGET_PATH"
```

Stop if backup fails.

#### Step 4.2 — P1-P2 (Automatic)

For specific skills: Read + Edit each file inline.
For all skills: run batch script.

```bash
python3 scripts/batch-p1p2p3.py "$TARGET_PATH" --dry-run  # preview
python3 scripts/batch-p1p2p3.py "$TARGET_PATH"             # apply
```

Report: "P1-P2 complete: N frontmatter added, M names normalized."

#### Step 4.3 — P3 (Preview + confirm)

Show transformations:

```markdown
| Skill | Before | After |
|-------|--------|-------|
| {name} | "Analyzes code quality" | "Use when analyzing code quality" |
```

Wait for confirmation. Skip if declined.

#### Step 4.4 — P4 (Confirm each)

Identify reference-type files, present candidates, ask for approval.

#### Step 4.5 — Re-diagnose + Before/After

```markdown
## Upgrade Complete!

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Compliance | X% | Y% | +Z%p |
| P1 | N | 0 | -N |
| P2 | N | 0 | -N |
| P3 | N | M | -K |
| P4 | N | M | -K |
| P5+ | N | N | (manual) |
```

#### Step 4.6 — Beyond P4

```markdown
### What's Left?

**1. Body >500 lines (P5)** — N skills
Split into SKILL.md + references/. Opus recommended.
Longest: [top 3]

**2. Broken references** — N skills
Create missing files or remove broken links.

**3. Imperative form** — N skills
Rewrite "you should" → "Run", "Check".

Would you like help with any of these?
```

## Auto-fix Rules

- **P1**: insert YAML frontmatter with auto-derived `name` and `description`
- **P2**: normalize name to kebab-case from filename
- **P3**: transform description to "Use when..." pattern, preserve Korean/proper nouns
- **P4**: apply reference heuristics, confirm with user before applying

## Guardrails

- `--diagnose` and `--dry-run` never modify files
- Always backup before any changes
- P3 and P4 always show preview and wait for confirmation
- Always re-diagnose after fixes, show before/after
- Respect target scope — never touch files outside selection
- Show expected impact at every decision point
