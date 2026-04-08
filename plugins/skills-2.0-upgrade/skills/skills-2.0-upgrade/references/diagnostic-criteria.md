# Diagnostic Criteria

This document defines the 12-item diagnostic checklist for Skills 2.0 compliance, including weights, pass conditions, implementation notes, and automation guidance.

## Scoring Model

Use a weighted average across the 12 checks.

```text
skill_score = Σ(check_passed[i] × weight[i]) / 100
overall = average(all_skill_scores) × 100
```

### Scoring Rules
- Treat each check as binary at scoring time: pass = full weight, fail = 0.
- Preserve richer diagnostics separately: reason, evidence, auto-fix eligibility, and confidence.
- Compute `skill_score` as a 0.00-1.00 fraction.
- Compute `overall` as a percentage across all diagnosed skills.
- If a repository has zero skills, return `overall = 0` and report `no_skills_found` instead of dividing by zero.

## Automation Levels

| Level | Meaning |
|---|---|
| Yes | Script can apply the fix automatically without user confirmation |
| Semi | Script can prepare a safe patch or recommendation, but user confirmation is required |
| Partial | Script can generate a draft or infer likely content, but manual review is strongly recommended |
| No / Report | Script only reports the issue and related evidence |

## Reference-Type Skill Heuristic

A skill is treated as reference-oriented when either the filename or the frontmatter `name` contains one of the following case-insensitive keywords:

- `guide`
- `reference`
- `spec`
- `examples`
- `templates`
- `schema`
- `collection`
- `strategies`
- `checklist`
- `encyclopedia`
- `glossary`

### Heuristic Behavior
- Check filename stem first, then `name:` if frontmatter exists.
- Match whole tokens or obvious hyphen-separated compounds.
- This heuristic is used only for check #8 (`disable-model-invocation`) and should not block other checks.
- If both filename and `name` are missing or ambiguous, classify as non-reference by default and emit a low-confidence note.

## 12-Item Checklist

| # | Check | Weight | Pass Condition | Auto-fix | Source |
|---|---|---:|---|---|---|
| 1 | Frontmatter exists | 20% | First line is `---` and a closing `---` exists | Yes | Skills 2.0 |
| 2 | `name:` field | 8% | `name` exists in frontmatter and uses hyphens + alphanumeric only | Yes | writing-skills |
| 3 | `description:` field | 10% | `description` exists in frontmatter and is non-empty | Partial | Both |
| 4 | Description "Use when..." | 5% | Description starts with `Use when` (case-insensitive) | Semi | writing-skills |
| 5 | Description third-person | 3% | Description does not include `you` or `your` | Semi | skillers-suda |
| 6 | Body ≤500 lines | 15% | Content after closing `---` is 500 lines or fewer | No | Skills 2.0 |
| 7 | Directory structure | 10% | If content is split, `SKILL.md` and `references/` both exist and are used properly | No | Skills 2.0 |
| 8 | `disable-model-invocation` | 8% | Reference-type skills include `disable-model-invocation: true` in frontmatter | Semi | Skills 2.0 |
| 9 | No orphan directories | 5% | Every skill directory contains `SKILL.md` or `.md` files | Report | Skills 2.0 |
| 10 | No broken references | 5% | Every `references/` link resolves to a real file | Report | Both |
| 11 | Progressive Disclosure | 5% | When `references/` exists, body mentions `See references/` or ``See `references/`` | Report | skillers-suda |
| 12 | Imperative form | 6% | Imperative wording dominates over second-person instructional phrasing | Report | skillers-suda |

## Detailed Check Guidance

### 1. Frontmatter exists
- **Weight:** 20%
- **Why it matters:** Skills 2.0 discovery depends on structured frontmatter.
- **Pass condition:**
  - File begins on line 1 with `---`
  - A matching closing `---` exists
  - Frontmatter appears before body content
- **Fail examples:**
  - Body text starts immediately
  - Opening delimiter exists but no closing delimiter
  - Frontmatter appears later in the file
- **Automatic behavior:** Insert a minimal frontmatter block:

```yaml
---
name:
description:
---
```

- **Implementation details:**
  - Scan the first line only for opening `---`
  - Search forward for the first valid closing `---`
  - Ignore fenced code blocks because frontmatter must be at the top of the file

### 2. `name:` field
- **Weight:** 8%
- **Pass condition:** `name` is present and contains only letters, numbers, and hyphens.
- **Automatic behavior:** Derive from filename stem when missing or invalid.
- **Normalization rules:**
  - Lowercase all letters
  - Replace spaces and underscores with hyphens
  - Collapse repeated hyphens
  - Strip leading or trailing hyphens
  - Remove non-alphanumeric characters other than hyphens
- **Implementation details:**
  - Read only frontmatter, not body headings
  - Prefer filename over inferred title because it is deterministic

### 3. `description:` field
- **Weight:** 10%
- **Pass condition:** Non-empty value exists in frontmatter.
- **Automatic behavior:** Draft generation is allowed, but requires review.
- **Recommended generation inputs:**
  1. First H1 heading
  2. First paragraph
  3. Nearby trigger phrases or problem statements
- **Implementation details:**
  - Empty string, placeholder, or whitespace-only value fails
  - Keep generated output short and trigger-focused

### 4. Description starts with "Use when..."
- **Weight:** 5%
- **Pass condition:** Description begins with `Use when`, case-insensitive.
- **Automatic behavior:** Suggest a rewrite pattern rather than silently replacing nuanced descriptions.
- **Implementation details:**
  - Trim surrounding quotes and whitespace before checking
  - Accept `Use when` and `use when`
  - Reject descriptions that start with workflow summaries like `Helps with`, `This skill`, or `Use to`

### 5. Description is third-person
- **Weight:** 3%
- **Pass condition:** Description avoids `you` and `your`.
- **Automatic behavior:** Suggest alternatives such as symptom-focused phrasing.
- **Implementation details:**
  - Use case-insensitive whole-word matching for `you` and `your`
  - False positives inside code or URLs are unlikely because the field is short, but they may be ignored if quoted literally
  - Preferred replacement strategy: rewrite around conditions and symptoms instead of pronouns

### 6. Body is 500 lines or fewer
- **Weight:** 15%
- **Pass condition:** All content after the closing frontmatter delimiter is 500 lines or fewer.
- **Automatic behavior:** None. Only report and prepare a split recommendation.
- **Implementation details:**
  - Count body lines only, not frontmatter lines
  - Preserve blank lines in the count
  - If no valid frontmatter exists, treat the full file as body for counting
  - A file with exactly 500 body lines passes

### 7. Directory structure supports split skills
- **Weight:** 10%
- **Pass condition:** When a skill is split, `SKILL.md` remains the entry point and `references/` exists for deferred material.
- **Automatic behavior:** Report structural issues or prepare a safe migration suggestion.
- **Implementation details:**
  - Pass if a single-file skill is short enough and not split
  - Pass if a split skill uses `SKILL.md` plus `references/`
  - Fail if a directory has `references/` but no `SKILL.md`
  - Fail if a long skill is split into arbitrary filenames without a stable `SKILL.md`

### 8. `disable-model-invocation: true` for reference-type skills
- **Weight:** 8%
- **Pass condition:** Reference-type skills identified by heuristic include `disable-model-invocation: true` in frontmatter.
- **Automatic behavior:** Suggest or stage the line for user confirmation.
- **Implementation details:**
  - Apply the heuristic before evaluating this check
  - Non-reference skills are marked `not_applicable` and do not fail this check
  - If frontmatter is missing, this check fails only when the file is classified as reference-type

### 9. No orphan directories
- **Weight:** 5%
- **Pass condition:** Every skill directory contains either `SKILL.md` or at least one `.md` file.
- **Automatic behavior:** Report orphan directories for cleanup.
- **Implementation details:**
  - Orphan directory examples:
    - empty directory
    - directory containing only nested folders and no markdown entrypoint
  - Ignore utility subdirectories under an otherwise valid skill directory

### 10. No broken references
- **Weight:** 5%
- **Pass condition:** Every `references/` link in the body resolves to an existing file.
- **Automatic behavior:** Report each broken path.
- **Implementation details:**
  - Parse markdown links and inline code mentions that clearly reference `references/`
  - Resolve relative to the current skill directory
  - Ignore external URLs
  - Distinguish between missing file and wrong casing where filesystem behavior matters

### 11. Progressive Disclosure hint exists
- **Weight:** 5%
- **Pass condition:** If `references/` exists, body contains `See references/` or ``See `references/``.
- **Automatic behavior:** Report missing hint and recommend adding one near the relevant section.
- **Implementation details:**
  - Only evaluate when a `references/` directory exists for that skill
  - Look for a literal mention that clearly signals on-demand reference loading
  - This is a documentation clarity check, not a link integrity check

### 12. Imperative form dominates
- **Weight:** 6%
- **Pass condition:** Imperative phrasing such as `Run`, `Check`, `Use`, `Add` appears more often than second-person instructional phrasing such as `you should`.
- **Automatic behavior:** Report style drift; do not auto-rewrite.
- **Implementation details:**
  - Use a heuristic count rather than deep grammar analysis
  - Count imperative starters at line or bullet starts
  - Count second-person guidance patterns such as `you should`, `you can`, `your task`
  - Mark borderline cases as warning-level failures with evidence

## Recommended Diagnostic Output Shape

Use a structured result per skill:

```json
{
  "path": "skills/example/SKILL.md",
  "score": 0.84,
  "checks": [
    {
      "id": 1,
      "name": "Frontmatter exists",
      "passed": true,
      "weight": 20,
      "autofix": "Yes",
      "evidence": "Opening and closing delimiters found"
    }
  ]
}
```

## Suggested Evaluation Order

Run checks in this order for stable diagnostics:
1. Frontmatter exists
2. Name field
3. Description field
4. Description prefix
5. Third-person description
6. Body line count
7. Directory structure
8. Reference-type invocation control
9. Orphan directories
10. Broken references
11. Progressive Disclosure hint
12. Imperative form heuristic

This ordering reduces cascading errors and makes auto-fix suggestions easier to explain.