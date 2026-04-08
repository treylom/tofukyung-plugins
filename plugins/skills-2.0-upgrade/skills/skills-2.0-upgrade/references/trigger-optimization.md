# Trigger Optimization

This guide defines how to optimize a skill description so Skills 2.0 triggers when it should, avoids false positives, and performs well under Claude Search Optimization (CSO).

## 1. Should-Trigger / Should-Not-Trigger Design

Use paired positive and negative queries to tune the description.

### Should-trigger queries
1. 내 스킬을 Skills 2.0으로 업그레이드해줘
2. 스킬 진단 점수가 낮아요
3. frontmatter가 없는 스킬을 수정해줘
4. 500줄 넘는 스킬을 분할해야 해
5. Upgrade my skills to comply with 2.0
6. diagnose skill health
7. missing frontmatter error
8. skills compliance check
9. skill directory has no SKILL.md
10. optimize skill description for CSO

### Should-not-trigger queries
1. Skills 2.0이 뭐야?
2. 새 스킬을 처음부터 만들어줘
3. 파이썬 코드 작성해줘
4. git commit 해줘
5. 프롬프트 만들어줘
6. what is progressive disclosure?
7. explain frontmatter syntax
8. write a React component
9. help me debug this API
10. summarize the Anthropic skills framework

### Interpretation rule
- Trigger only when the request implies diagnosis, upgrade, repair, normalization, or compliance work.
- Do not trigger for simple informational questions unless the user also asks to act.

## 2. Pushy Description Strategy

A "pushy" description is intentionally broad enough to avoid undertriggering, but still scoped to the correct task family.

### Goals
- Prevent missing legitimate upgrade or diagnostic requests.
- Cover Korean and English phrasing.
- Include symptoms, tool terms, and compliance vocabulary.
- Bias toward action requests rather than passive explanation requests.

### Recommended keyword categories
- **Symptoms:** missing frontmatter, low score, long skill, broken references
- **Actions:** upgrade, fix, diagnose, normalize, split, comply
- **Artifacts:** SKILL.md, references/, description, frontmatter, metadata
- **Concepts:** Skills 2.0, CSO, Progressive Disclosure, compliance

### Example pushy description
```yaml
description: Use when upgrading skills, diagnosing compliance scores, fixing missing frontmatter, splitting long skill files, or optimizing skill descriptions for Skills 2.0 and CSO.
```

## 3. CSO + Trigger Integration

Combine writing-skills CSO rules with trigger-oriented retrieval design.

### Required behavior
- Start with `Use when...`
- Mention trigger conditions, not workflow
- Include error symptoms and recovery tasks
- Include both concept names and file artifacts
- Prefer action verbs that imply work, not explanation

### Good pattern
```yaml
description: Use when diagnosing skill compliance, fixing missing metadata, repairing SKILL.md structure, or optimizing descriptions for Skills 2.0 discovery.
```

### Bad pattern
```yaml
description: Use this skill to analyze the repo, score all skills, fix metadata, and prepare a migration plan.
```

Why it is bad:
- Summarizes workflow instead of trigger conditions
- Risks the model following the description instead of reading the skill
- Overloads discovery metadata with execution detail

## 4. Automatic Evaluation Method

Use an eval set to tune the final description before locking it in.

### Eval design
- Generate about 20 queries total
  - 10 should-trigger
  - 10 should-not-trigger
- Split them 60/40 into train and test sets
- Iterate up to 5 times
- Keep the description variant with the best balance of precision and recall
- Target F1 score: 0.85 or higher

### Suggested loop
1. Draft 2-5 candidate descriptions.
2. Run the train set against each candidate.
3. Keep the strongest one.
4. Validate it on the held-out test set.
5. If F1 is under 0.85, revise keywords and retry.

### Practical scoring lens
- **False negatives** mean undertriggering: add missing action or symptom terms.
- **False positives** mean overtriggering: remove generic nouns or purely educational wording.

## 5. Trigger Only on Complex Queries

The skill should activate for work requests, not for simple curiosity.

### Trigger
- Fix X
- Upgrade X
- Diagnose X
- Repair X
- Check compliance for X
- Normalize metadata for X
- Split long skill docs

### Do not trigger
- What is X?
- Explain X
- Summarize X
- Compare X and Y

### Rule of thumb
If the request can be satisfied by a short explanation without touching files, do not trigger the upgrade skill.

## 6. Construction Rules for the Final Description

Build the final description with these constraints:
1. Start with `Use when`
2. Mention the main action family first
3. Add 3-5 high-signal trigger phrases
4. Include 1-2 artifact names if helpful
5. Avoid process summaries
6. Keep it short enough to scan instantly

### Template
```text
Use when [upgrading/diagnosing/fixing] skills, [specific symptoms], or [specific artifact/problem] for Skills 2.0 and CSO.
```

### Strong candidate
```yaml
description: Use when upgrading skills, diagnosing compliance issues, fixing missing frontmatter or SKILL.md structure, splitting long skill files, or optimizing descriptions for Skills 2.0 and CSO.
```

## 7. Common Failure Modes

### Undertriggering
Symptoms:
- Fails to load on "missing frontmatter"
- Fails to load on "skills compliance check"
- Fails to load on Korean phrasing such as "스킬 업그레이드"

Fixes:
- Add missing symptom keywords
- Add missing Korean or English variants
- Replace abstract wording with concrete repo artifacts

### Overtriggering
Symptoms:
- Triggers on general educational questions
- Triggers on unrelated markdown work
- Triggers on generic prompt-writing tasks

Fixes:
- Remove generic words like `documentation` or `improve`
- Prefer compliance-specific terms
- Favor action verbs like `upgrade`, `diagnose`, and `fix`

## 8. Recommended Final Heuristic

A well-optimized Skills 2.0 upgrade description should:
- trigger on upgrade, repair, diagnosis, and compliance work
- ignore pure explanation requests
- include both Korean and English discovery terms when the workspace is bilingual
- mention high-signal artifacts such as `frontmatter`, `SKILL.md`, and `references/`
- stay workflow-free so the main skill body still gets read

## 9. Final Checklist

- Starts with `Use when...`
- Written in third person
- No workflow summary
- Includes high-signal symptoms
- Includes upgrade/diagnose/fix verbs
- Avoids broad educational triggers
- Covers bilingual search terms where needed
- Evaluated against should-trigger and should-not-trigger queries