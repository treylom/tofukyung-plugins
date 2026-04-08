---
name: skills-2-0-upgrade
description: Use when upgrading Claude Code skills to Skills 2.0 compliance, when diagnosing skill health scores, when frontmatter is missing or malformed, when skills exceed 500-line limit, when skill directories lack SKILL.md structure, or when compliance score needs improvement
---

# Skills 2.0 Upgrade

## Overview

Skills 2.0 is Anthropic's 2026 skill framework built on Progressive Disclosure:
1. **Frontmatter** — fast routing and discovery
2. **SKILL.md** — working guide (<500 lines)
3. **references/** — heavy detail loaded on demand

With 351K+ published skills, clean structure directly impacts discoverability, token efficiency, and cross-tool portability.

## When to Use

Trigger on any of these symptoms:
- `missing frontmatter`, `malformed frontmatter`
- `skill too long` (body >500 lines)
- `orphan directory` (skill folder without `SKILL.md`)
- `broken reference` (invalid `references/` links)
- description missing `Use when...` pattern
- low or declining compliance score

Do not use for normal feature work inside a skill.

## Upgrade Workflow — Phase-by-Phase Guide

Start by selecting which skills to upgrade, then diagnose and proceed phase by phase.

### Step 0: Select target (always start here)

Ask the user what to upgrade before scanning anything:

```
What would you like to upgrade?
  1. A specific skill — enter the skill name
  2. Multiple skills — enter comma-separated names
  3. All skills — scan the entire directory
```

Resolve skill names to file paths:
- `my-skill` → `$SKILLS_DIR/my-skill.md` or `$SKILLS_DIR/my-skill/SKILL.md`
- If not found, list available skills and ask the user to pick

All subsequent steps operate only on the selected scope.

### Step 1: Diagnose

```bash
scripts/diagnose.sh <skill-or-directory> [--json|--verbose]
```

Present the user with:
- per-skill score and failed checks (if specific skills selected)
- overall compliance score and issue breakdown (if all skills)
- top impactful issues

Then explain the upgrade path:

```
Your skills score X%. Here's what each upgrade phase would improve:

| Phase | Fixes | Expected Impact | Automation |
|-------|-------|-----------------|------------|
| P1-P2 | Frontmatter + name | +10-16%p | Fully automatic |
| P3    | Description "Use when..." | +8-16%p | Semi-auto (batch) |
| P4    | Invocation control | +1-3%p | Semi-auto (confirm) |
| P5+   | File splitting + structure | +2-6%p | Manual (Opus) |

Which phase would you like to run? (P1-P2 / P1-P3 / P1-P4 / all)
```

### Step 2: Execute chosen phases

Run `scripts/backup.sh <skills-path>` before any changes.

**P1-P2 (Automatic):**
Run `scripts/batch-p1p2p3.py <path> --dry-run` to preview, then apply.
- P1 adds missing frontmatter with auto-generated name and description
- P2 normalizes name fields to kebab-case
- No user confirmation needed — deterministic pattern matching

**P3 (Semi-automatic):**
Run `scripts/batch-p1p2p3.py <path>` which also handles P3.
- Transforms existing descriptions to "Use when..." pattern
- Preserves Korean text, proper nouns, and acronyms
- Show the user a sample of changes before applying

**P4 (Confirm with user):**
Identify reference-type skills using heuristics (name contains guide/reference/spec/examples/templates/schema/collection/strategies/checklist).
- Present candidate list to user
- Add `disable-model-invocation: true` to confirmed files

### Step 3: Re-diagnose and report

Run diagnosis again and show before/after comparison:

```
Compliance improved: X% → Y% (+Z%p)

| Priority | Before | After | Fixed |
|----------|--------|-------|-------|
| P1       | N      | 0     | N     |
| P2       | N      | 0     | N     |
| P3       | N      | M     | N-M   |
| P4       | N      | M     | N-M   |
| P5+      | N      | N     | (manual) |
```

### Step 4: Guide beyond P4 (final optimization)

After P1-P4, explain remaining issues and how to resolve them:

```
Remaining issues for 100% compliance:

1. Body >500 lines (P5) — N skills
   → Requires content understanding to split into SKILL.md + references/
   → Recommended: Opus model with high effort
   → Run: /skills-upgrade --split <skill-path> (interactive, one at a time)

2. Broken references — N skills
   → Referenced files in references/ don't exist
   → Fix: create the missing files or remove the broken links

3. Imperative form — N skills
   → Body uses "you should" instead of direct commands ("Run", "Check")
   → Fix: rewrite advisory phrasing to imperative

4. Orphan directories — N skills
   → Skill folders without SKILL.md entry point
   → Fix: add SKILL.md or restructure into parent skill

Would you like to start P5 splitting for the longest skills?
```

For P5 splitting, guide the user through each skill:
1. Read the full content
2. Identify logical sections that can become reference files
3. Propose a split plan (what stays in SKILL.md, what moves to references/)
4. Add progressive disclosure pointers linking to the new reference files
5. Execute after user approval

## Quick Reference

| # | Check | Weight |
|---|-------|--------|
| 1 | Frontmatter exists | 20% |
| 2 | `name:` field valid | 8% |
| 3 | `description:` field exists | 10% |
| 4 | Description "Use when..." | 5% |
| 5 | Description third-person | 3% |
| 6 | Body ≤500 lines | 15% |
| 7 | Directory structure | 10% |
| 8 | `disable-model-invocation` | 8% |
| 9 | No orphan directories | 5% |
| 10 | No broken references | 5% |
| 11 | Progressive Disclosure | 5% |
| 12 | Imperative form | 6% |

See `references/diagnostic-criteria.md` for scoring details.

## Model Guide

| Task | Model | Effort |
|------|-------|--------|
| Diagnosis | Any (bash) | N/A |
| P1-P3 batch fix | Sonnet | medium |
| P4 invocation control | Sonnet | medium |
| P5 file splitting | Opus | high |
| Full upgrade | Opus | high |

## Real-World Impact

151 skills, measured results:

| Phase | Compliance | Gain |
|-------|-----------|------|
| Baseline | 62% | — |
| After P1-P2 | 78% | +16%p |
| After P1-P3 | 94.3% | +16.3%p |
| After P1-P4 (est.) | ~97% | +2.7%p |
| After P5+ (est.) | ~100% | +3%p |

## Pre-Deployment Security Scan

Before publishing skills or pushing to GitHub, run the security scanner:

```bash
scripts/diagnose.sh <project-path> --security
scripts/diagnose.sh <project-path> --security --json
```

Detects 13 patterns across 3 severity levels:

| Severity | What it catches |
|----------|----------------|
| Critical | API keys (`sk-`, `ntn_`, `ghp_`), private key blocks |
| High | Bearer tokens, API key/secret assignments, password assignments |
| Medium | Hardcoded user paths (`/home/user`, `/mnt/c/Users`, `C:\Users`) |

False positives can occur when scanning code that contains detection patterns as string literals (e.g. the scanner's own source code). Review each finding before acting.

## Common Mistakes

- Editing without running diagnosis first
- Skipping backup before upgrade
- Putting workflow summary in `description` instead of triggers
- Skipping P3 even though it has the highest aggregate impact
- Running P5 with Sonnet instead of Opus (content understanding needed)
- Forgetting to re-diagnose after fixes
- Deploying without running `--security` scan first

See `references/upgrade-actions.md` for detailed P1-P7 procedures.
See `references/trigger-optimization.md` for description optimization strategy.
