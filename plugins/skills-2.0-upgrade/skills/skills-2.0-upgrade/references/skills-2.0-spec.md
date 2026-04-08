# Skills 2.0 Specification

## Skills 2.0 Overview

Skills 2.0 is the 2026 skill framework centered on discoverability, bounded entrypoint size, and progressive loading.

### Ecosystem Snapshot
- Anthropic-aligned 2026 skill framework
- Community ecosystem measured at 351K+ skills through agentskills.io
- Three core principles:
  1. Progressive Disclosure
  2. Token Efficiency
  3. CSO (Claude Search Optimization)

## Core Design Goals

### 1. Progressive Disclosure
Load only the minimum material needed at each stage.
- Keep discovery metadata tiny.
- Keep the main skill document focused.
- Move heavy reference material behind on-demand links.

### 2. Token Efficiency
Skills should be cheap to discover and cheap to load.
- Put triggers in frontmatter.
- Keep body content concise and skimmable.
- Move long examples, schemas, and encyclopedic material into `references/`.

### 3. CSO (Claude Search Optimization)
Optimize skills for retrieval by future agents.
- Use precise trigger conditions.
- Include problem symptoms and task wording.
- Avoid vague summaries.
- Make the description answer: "Should this skill trigger now?"

## 1.0 vs 2.0 Comparison

| Aspect | Skills 1.0 | Skills 2.0 |
|---|---|---|
| Structure | Single `.md` file | `SKILL.md` + `references/` |
| Frontmatter | Optional | Required (`name` + `description`) |
| Length limit | None | Body ≤500 lines |
| Discovery | Filename-based | CSO (`keywords` + `description`) |
| Model control | None | `disable-model-invocation` |
| Validation | None | 12-item automated diagnosis |
| Organization | Flat | Progressive Disclosure 3-Tier |

## Progressive Disclosure 3-Tier Model

### Tier 1: Frontmatter
Always loaded by Claude during discovery.
- Required fields: `name`, `description`
- Budget target: under 100 tokens
- Purpose: trigger matching only
- Rule: do not summarize workflow here

### Tier 2: `SKILL.md` body
Loaded when the skill is selected.
- Budget target: under 2000 tokens
- Purpose: overview, decision rules, core patterns, short examples
- Rule: stay focused on how to apply the skill

### Tier 3: `references/`
Loaded only on demand.
- Budget target: effectively unlimited
- Purpose: large examples, APIs, schemas, checklists, deep reference
- Rule: body should point to these files explicitly when needed

## Frontmatter Specification

### Required fields
Only the following fields are mandatory in the base spec:
- `name`
- `description`

### Size limit
- Frontmatter should remain within 1024 characters total.

### `name` rules
- Letters, numbers, and hyphens only
- No spaces
- No parentheses or special punctuation
- Prefer stable, searchable names

### `description` rules
- Starts with `Use when...`
- Describes only trigger conditions, symptoms, or situations
- Does not summarize workflow or implementation steps
- Uses third-person style
- Stays concise and keyword-rich

### Example
```yaml
---
name: skills-2-upgrade
description: Use when upgrading existing skills, diagnosing compliance issues, or fixing missing Skills 2.0 metadata.
---
```

## CSO (Claude Search Optimization)

### Purpose
Descriptions determine whether a skill is loaded. A weak description causes undertriggering or mis-triggering.

### Good CSO patterns
- Include the task request language users actually type.
- Include symptoms such as missing frontmatter, low compliance, or long skill files.
- Prefer trigger phrases over workflow descriptions.
- Use mixed Korean and English keywords when the user base is bilingual.

### Avoid
- `This skill helps with...`
- `Use this skill to...`
- Long summaries of what the document teaches
- Process details that let the model skip reading the body

## Validation Model

Skills 2.0 expects automated diagnosis rather than manual spot checking.

### Validation coverage
- Frontmatter presence and correctness
- Description quality
- File length and structure
- Progressive Disclosure signals
- Broken `references/` links
- Reference-only invocation controls

### Expected output
A diagnostic run should produce:
- per-skill score
- per-check pass/fail evidence
- upgrade recommendations by priority
- repository-wide compliance percentage

## Case Study: Real-World Migration

A representative migration benchmark:
- 94 skills diagnosed
- Starting compliance: 62%
- After Phase 1 fixes: 78% compliance
- Top issues:
  - missing frontmatter: 12 skills
  - body >500 lines: 8 skills
  - missing description: 15 skills
- Time required: about 2 hours with Opus

### Lessons from the migration
- Metadata fixes produce the fastest early gains.
- File splitting is the slowest but most structural improvement.
- Description quality matters as much as syntax because discovery is behavioral.
- Progressive Disclosure reduces token waste immediately after migration.

## Recommended Body Structure

A compliant `SKILL.md` usually contains:
1. H1 title
2. Short overview
3. When-to-use guidance
4. Core pattern or quick reference
5. Minimal implementation notes
6. Common mistakes or edge cases
7. Explicit links such as `See references/...` for heavy detail

## Reference Material Placement

Put the following in `references/` instead of the body when they become large:
- API references
- schemas
- templates
- encyclopedic examples
- migration checklists
- large troubleshooting matrices

## Migration Guidance

Upgrade old skills in this order:
1. Add required frontmatter
2. Normalize `name`
3. Rewrite `description` for CSO
4. Add `disable-model-invocation` where needed
5. Split bodies over 500 lines
6. Add `references/` hints to the main body
7. Re-run automated diagnosis

## Summary Rules

- Every skill has discoverable frontmatter.
- Every description starts with `Use when...`.
- Every body stays within the 500-line limit.
- Every large skill uses `SKILL.md` plus `references/`.
- Every reference-heavy skill considers `disable-model-invocation`.
- Every migration is confirmed with automated diagnosis, not guesswork.