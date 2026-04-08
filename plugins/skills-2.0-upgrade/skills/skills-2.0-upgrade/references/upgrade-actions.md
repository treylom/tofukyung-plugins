# Upgrade Actions

This document defines the prioritized remediation sequence for upgrading existing skills to Skills 2.0 compliance.

## Priority Overview

| Priority | Action | Automation | Related Checks |
|---|---|---|---|
| P1 | Add frontmatter | Automatic | #1 |
| P2 | Normalize name field | Automatic | #2 |
| P3 | Generate description | Semi-auto | #3, #4, #5 |
| P4 | Add invocation control | Semi-auto | #8 |
| P5 | Split long files (>500 lines) | Manual (Opus recommended) | #6, #7, #11 |
| P6 | Fix directory structure | Semi-auto | #7, #9 |
| P7 | Handle orphan directories | Semi-auto | #9 |

## Why This Order

Apply fixes in this order because later checks depend on earlier structure.

- P1 creates the container required for metadata.
- P2 and P3 stabilize discovery fields.
- P4 applies only after frontmatter exists and reference-type detection is possible.
- P5 and P6 address structural issues that cannot be safely solved by simple line edits.
- P7 is cleanup work after higher-value content fixes are known.

## P1. Add frontmatter

### Description
Add a minimal YAML frontmatter block when the file has no valid frontmatter.

### Target condition
- File does not start with `---`
- Closing frontmatter delimiter is missing
- File contains body content but no valid metadata block

### Automation level
**Automatic**

### Procedure
1. Insert a three-field shell at the top of the file.
2. Preserve existing body content exactly below the closing delimiter.
3. Leave `name` and `description` blank only if later steps will immediately fill them.

### Before
```markdown
Some skill content here...
```

### After
```markdown
---
name: some-skill
description: Use when [auto-generated from first heading and paragraph]
---

Some skill content here...
```

### Edge cases
- If the file begins with a BOM or stray blank lines, normalize to frontmatter at line 1.
- If the file contains a later YAML-like block, do not treat it as valid frontmatter.
- If the file is obviously not a skill entrypoint, report instead of mutating unrelated docs.

### Related checks
- #1 Frontmatter exists

## P2. Normalize name field

### Description
Ensure the `name` field is present and conforms to Skills 2.0 naming rules.

### Target condition
- `name` missing
- `name` contains spaces, underscores, uppercase-only style, or special characters

### Automation level
**Automatic**

### Procedure
1. Extract filename stem.
2. Lowercase the value.
3. Replace spaces and underscores with hyphens.
4. Remove unsupported punctuation.
5. Collapse duplicate hyphens.
6. Write the normalized result back to frontmatter.

### Before
```yaml
name: Skill Reference (Draft)
```

### After
```yaml
name: skill-reference-draft
```

### Edge cases
- If filename is `SKILL.md`, derive from parent directory name instead.
- If normalization results in an empty string, report and require manual naming.
- If `name` and directory name disagree, prefer deterministic normalization but include a warning.

### Related checks
- #2 `name:` field

## P3. Generate description

### Description
Generate or improve a discovery-focused description that satisfies presence, trigger phrasing, and third-person style.

### Target condition
- Missing description
- Empty description
- Description does not start with `Use when`
- Description uses second-person language

### Automation level
**Semi-auto (user confirms)**

### Procedure
1. Extract topic from the first `#` heading.
2. Extract context from the first paragraph.
3. Convert the result into a `Use when...` trigger sentence.
4. Remove workflow summaries and second-person phrasing.
5. Present the proposed description for confirmation or editing.

### Before
```yaml
description: This skill explains how to upgrade a skill and then validate it.
```

### After
```yaml
description: Use when upgrading skills, diagnosing compliance issues, or fixing missing Skills 2.0 metadata.
```

### Edge cases
- If the opening paragraph is narrative or historical, ignore it and search for trigger phrases later in the file.
- If the skill is very domain-specific, include domain keywords in the trigger sentence.
- If a generated description becomes too long, shorten symptoms before removing core trigger terms.

### Related checks
- #3 `description:` field
- #4 Description "Use when..."
- #5 Description third-person

## P4. Add invocation control

### Description
Add `disable-model-invocation: true` to reference-type skills identified by heuristic.

### Target condition
- Skill is classified as reference-type
- Frontmatter exists
- `disable-model-invocation: true` is missing

### Automation level
**Semi-auto (user confirms)**

### Procedure
1. Evaluate filename and `name` against the reference heuristic.
2. If matched, prepare a frontmatter patch.
3. Ask for confirmation before applying.
4. Record that the change is heuristic-driven, not absolute.

### Before
```yaml
---
name: api-reference
description: Use when checking API syntax and request formats.
---
```

### After
```yaml
---
name: api-reference
description: Use when checking API syntax and request formats.
disable-model-invocation: true
---
```

### Edge cases
- If the skill mixes procedural guidance with heavy reference, flag for manual review.
- If frontmatter is malformed, fix P1-P3 first.
- If the repo explicitly chooses not to use invocation control, report policy conflict instead of silently applying.

### Related checks
- #8 `disable-model-invocation`

## P5. Split long files (>500 lines)

### Description
When a skill body exceeds 500 lines, prepare a split plan rather than performing automatic restructuring.

### Target condition
- Body line count is greater than 500

### Automation level
**Manual (Opus recommended)**

### Procedure
1. Report the measured body line count.
2. Identify H2 sections suitable for extraction.
3. Propose a `references/` layout based on topic clusters.
4. Recommend leaving a concise overview in `SKILL.md`.
5. Add a note to include `See references/...` links after the split.

### Example split plan
- `SKILL.md` keeps overview, triggers, and short execution steps.
- `references/diagnostic-rules.md` stores detailed rule definitions.
- `references/examples.md` stores large examples.
- `references/troubleshooting.md` stores edge cases.

### Edge cases
- If the file is long because of one giant example, consider moving only that example first.
- If headers are inconsistent, propose a manual outline before extraction.
- If the file is under 550 lines but naturally cohesive, still report rather than auto-splitting.

### Related checks
- #6 Body ≤500 lines
- #7 Directory structure
- #11 Progressive Disclosure

## P6. Fix directory structure

### Description
Normalize split skills so they use `SKILL.md` as the entrypoint and `references/` for deferred material.

### Target condition
- Split skill exists without `SKILL.md`
- `references/` exists but is not linked from the main file
- Long-form content is spread across arbitrary filenames without a stable entrypoint

### Automation level
**Semi-auto**

### Procedure
1. Detect the intended entrypoint file.
2. Propose or create `SKILL.md` as the canonical main document.
3. Move heavy reference content into `references/` where appropriate.
4. Update body text to include explicit `See references/...` hints.

### Before
```text
my-skill/
  overview.md
  examples.md
  notes.md
```

### After
```text
my-skill/
  SKILL.md
  references/
    examples.md
    notes.md
```

### Edge cases
- If multiple markdown files are all short and intentionally standalone, confirm before consolidating.
- If a directory contains scripts or assets only, it may be a support directory rather than a skill.
- If renaming would break external links, report migration risk first.

### Related checks
- #7 Directory structure
- #9 No orphan directories

## P7. Handle orphan directories

### Description
Detect and resolve skill directories that lack a usable markdown entrypoint.

### Target condition
- Directory contains no `SKILL.md`
- Directory contains no `.md` files
- Directory contains only empty nested folders or leftover assets

### Automation level
**Semi-auto**

### Procedure
1. List each orphan directory with evidence.
2. Classify it as one of:
   - empty shell
   - partially migrated skill
   - support folder accidentally placed in skills namespace
3. Recommend one of:
   - create `SKILL.md`
   - move contents under a valid parent skill
   - delete or archive after confirmation

### Before
```text
skills/example-skill/
  references/
```

### After
```text
skills/example-skill/
  SKILL.md
  references/
```

### Edge cases
- A directory with only `.png` or `.sh` support files may still be valid if another markdown entrypoint exists elsewhere; verify namespace boundaries first.
- Nested skills should be flattened unless the project intentionally deviates.
- Never delete orphan content automatically.

### Related checks
- #9 No orphan directories

## Suggested Upgrade Workflow

Run the upgrade plan in this sequence:
1. P1 Add frontmatter
2. P2 Normalize `name`
3. P3 Generate or improve `description`
4. P4 Add invocation control when heuristic applies
5. Re-run diagnostics
6. If body still fails line-count or structure checks, execute P5-P7 as needed

## Safe Defaults
- Prefer deterministic metadata fixes before structural changes.
- Never auto-split long files.
- Never auto-delete orphan directories.
- Require confirmation for heuristic or semantic rewrites.
- Re-run diagnostics after every batch of fixes.