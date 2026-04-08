# Skills 2.0 Auto-Upgrade

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)]()

> Zero-token diagnostic engine + Claude Code skill for automatically upgrading skills to Skills 2.0 compliance.

**[한국어 버전은 아래를 참고하세요 / Korean version below](#skills-20-자동-업그레이드)**

## What is Skills 2.0?

Skills 2.0 is Anthropic's 2026 skill framework for making reusable agent instructions easier to discover, load, and maintain.
It formalizes **Progressive Disclosure** as a 3-tier structure: frontmatter for triggering, `SKILL.md` for the working guide, and `references/` for heavy material loaded on demand.
The ecosystem has grown to **351K+ published skills**, which makes search quality, token efficiency, and structural consistency much more important than in early single-file skill setups.
This project helps migrate existing Claude Code skills to that structure with a zero-token bash diagnosis pass and guided upgrade workflow.

## Quick Start

### Install (primary)

```bash
curl -fsSL https://raw.githubusercontent.com/treylom/skills-2.0-upgrade/main/install.sh | bash
```

### Install from local clone (alternative)

```bash
bash install.sh
```

### Basic usage

```bash
/skills-upgrade                        # Interactive — asks what to upgrade
/skills-upgrade my-skill               # Single skill
/skills-upgrade skill-a skill-b        # Multiple skills
/skills-upgrade --all                  # All skills
/skills-upgrade --diagnose             # Diagnose only (read-only)
/skills-upgrade --dry-run              # Preview changes
```

## Features

- **Zero-token diagnosis**: Pure bash, no LLM calls needed
- **12-item weighted checklist**: Comprehensive compliance scoring
- **Auto-fix P1-P4**: Automatic frontmatter, name, description fixes
- **Backup before upgrade**: Automatic tar.gz backup
- **Cross-platform**: WSL, macOS, Linux
- **JSON output**: Machine-parseable for CI/CD integration
- **Slash command**: `/skills-upgrade` with 3 modes
- **Security scan**: Pre-deployment PII, secrets, and hardcoded path detection

## Usage

### Diagnose (default)

```bash
/skills-upgrade
```

Example output:

```text
Skills 2.0 Compliance Report
=============================
Date: 2026-03-15 14:30:22
Path: /home/user/.claude/skills/
Skills scanned: 94
Overall compliance: 78.2%

Top Issues:
1. Missing frontmatter: 12 skills
2. Over 500 lines: 8 skills
3. Missing description: 15 skills
```

### Dry Run

```bash
/skills-upgrade --dry-run
```

Example output:

```text
Planned changes
- P1 Add frontmatter: 12 files
- P2 Normalize name field: 7 files
- P3 Generate description: 15 files
- P4 Add invocation control: 4 files
No files were modified.
```

### Interactive Upgrade

```bash
/skills-upgrade my-skill
```

Walks you through target selection → diagnosis → phase selection → preview → apply → before/after comparison. No flags needed — the default mode is interactive.

### Direct Script Usage

```bash
~/.claude/scripts/diagnose.sh ~/.claude/skills/
~/.claude/scripts/diagnose.sh ~/.claude/skills/ --json
~/.claude/scripts/diagnose.sh ~/.claude/skills/ --verbose
~/.claude/scripts/diagnose.sh ~/.claude/skills/my-skill.md
```

### Security Scan (pre-deployment)

```bash
~/.claude/scripts/diagnose.sh /path/to/project --security
~/.claude/scripts/diagnose.sh /path/to/project --security --json
```

Detects 13 patterns across 3 severity levels:

| Severity | Detects |
|----------|---------|
| Critical | API keys (`sk-`, `ntn_`, `ghp_`), private key blocks |
| High | Bearer tokens, API key/secret assignments, passwords |
| Medium | Hardcoded user paths (`/home/`, `/mnt/c/Users`, `C:\Users`) |

Run before every `git push` or GitHub deployment to prevent accidental leaks.

## 12-Item Diagnostic Checklist

| # | Check | Weight | Pass Condition |
|---|-------|--------|---------------|
| 1 | Frontmatter exists | 20% | First line is `---` and a closing `---` exists |
| 2 | `name:` field | 8% | Frontmatter contains `name:` and the value uses only hyphens and alphanumeric characters |
| 3 | `description:` field | 10% | Frontmatter contains a non-empty `description:` value |
| 4 | Description `Use when...` pattern | 5% | Description starts with `Use when` (case-insensitive) |
| 5 | Description third-person | 3% | Description does not contain `you` or `your` |
| 6 | Body ≤500 lines | 15% | Body after frontmatter is 500 lines or fewer |
| 7 | Directory structure | 10% | Long skills use `SKILL.md` + `references/`; short skills pass automatically |
| 8 | `disable-model-invocation` | 8% | Reference-type skills include `disable-model-invocation: true`; others pass automatically |
| 9 | No orphan directories | 5% | Skill directories contain `SKILL.md` or at least one `.md` file |
| 10 | No broken references | 5% | `references/` links resolve to existing files |
| 11 | Progressive Disclosure | 5% | Skills with `references/` explicitly point readers to `references/` in the body |
| 12 | Imperative form | 6% | Imperative instructions appear more often than second-person advisory phrasing |

## Model Guidance

| Task | Model | Effort | Why |
|------|-------|--------|-----|
| Diagnosis only | Any (bash) | N/A | No LLM needed |
| P1-P2 auto-fix | Sonnet | medium | Simple patterns |
| P3 file splitting | Opus | high | Content understanding |
| Full upgrade | Opus | high | Includes splitting |

## Cross-Platform Compatibility

| Platform | Support | Notes |
|----------|---------|-------|
| Claude Code | Full | All features |
| Codex CLI | Partial | JSON output mode |
| Antigravity | Partial | Skill read + bash |
| Cursor/Windsurf | Minimal | .md read only |

## How It Works

4-Phase pipeline:
1. **Scan**: Parse arguments, run diagnose.sh
2. **Report**: Generate compliance summary
3. **Plan**: Show proposed changes (dry-run/upgrade)
4. **Execute**: Backup → auto-fix → re-diagnose (upgrade only)

## Case Study

Real-world migration of 151 skills:

| Phase | Compliance | What changed |
|-------|-----------|--------------|
| Baseline | 62% | No Skills 2.0 structure |
| After P1-P2 | 78% | Frontmatter + name normalization |
| After P1-P3 | **94.3%** | + description "Use when..." pattern |

Remaining gap to 100%: body >500 lines (13 skills, needs Opus splitting), broken references (13), imperative form (some)

### Self-Improvement

This tool was used to diagnose and upgrade itself through 4 iterations:

| Iteration | What happened | Result |
|-----------|--------------|--------|
| 1 | Initial 6-agent team build | 100% compliance on first build |
| 2 | Real-world validation on 151 skills | 62% → 94.3% (batch P1-P3 script created) |
| 3 | UX redesign + false positive fix | Phase-by-phase guide, 100% maintained |
| 4 | Security scan + self-scan | `--security` mode added, clean pass |

See the full [Self-Improvement Report](SELF-IMPROVEMENT-REPORT.md) for details.

## Project Structure

```text
skills-2.0-upgrade/
├── commands/
│   └── skills-upgrade.md
├── scripts/
│   ├── backup.sh
│   └── diagnose.sh
├── skills/
│   └── skills-2.0-upgrade/
│       ├── SKILL.md
│       └── references/
│           ├── diagnostic-criteria.md
│           ├── skills-2.0-spec.md
│           ├── trigger-optimization.md
│           └── upgrade-actions.md
├── CHANGELOG.md
├── install.sh
├── LICENSE
├── README.md
└── SELF-IMPROVEMENT-REPORT.md
```

## Acknowledgments

This project's 12-item diagnostic checklist merges two complementary approaches: obra's superpowers skill framework (8 items) and fivetaku's community validation patterns (4 items).

### From [superpowers:writing-skills](https://github.com/obra/superpowers) (obra)

obra's superpowers project defines a practical skill authoring methodology for Claude Code. We adopted three core ideas:

**1. Progressive Disclosure 3-Tier Model** — The key architectural insight: don't dump everything into one file. Instead, split into three layers that load progressively:

| Tier | What | Budget | Loaded when |
|------|------|--------|-------------|
| Frontmatter | `name` + `description` | <100 tokens | Always (during discovery) |
| SKILL.md body | Core guide | <2000 tokens | When skill is selected |
| references/ | Heavy detail | Unlimited | On demand only |

This directly shaped our checks #1 (frontmatter), #6 (body ≤500 lines), #7 (directory structure), and #11 (progressive disclosure pointers).

**2. Claude Search Optimization (CSO)** — Skills need to be *findable* by AI agents, not just readable by humans. The `description` field is the primary search surface — it should answer "Should this skill trigger now?" rather than summarize what the skill does. This led to check #4 ("Use when..." pattern) and our trigger optimization reference.

**3. TDD for Skills (RED → GREEN → REFACTOR)** — Write a failing diagnostic first, then build the skill to pass it, then refine. We used this cycle ourselves: diagnose.sh was the "test", SKILL.md was the "implementation", and the self-improvement iterations were the "refactor". This validated our own tool against its own criteria.

**4. Frontmatter Spec** — Only two required fields: `name` (kebab-case identifier) and `description` (max 1024 chars, starts with "Use when...", third-person, no workflow summary). Reference-only files should add `disable-model-invocation: true`. This directly maps to checks #1-#5 and #8.

### From [fivetaku/skillers-suda](https://github.com/fivetaku/skillers-suda) (MIT)

fivetaku's community project adds practical validation patterns that catch issues Anthropic's spec doesn't explicitly check:

**1. Third-Person Description (check #5)** — Descriptions should avoid "you" and "your" because the audience is the AI agent's routing system, not a human reader. "Use when analyzing code" works better than "Use when you need to analyze code" for machine matching. Weight: 3%.

**2. Progressive Disclosure Verification (check #11)** — Having a `references/` directory isn't enough — the SKILL.md body must explicitly say "See references/..." so the agent knows the material exists and when to load it. Without this pointer, reference files become invisible. Weight: 5%.

**3. Imperative Form (check #12)** — Skill bodies should use direct commands ("Run diagnose.sh", "Check the frontmatter") rather than advisory phrasing ("you should run", "you must check"). Imperative instructions are clearer for agents and consume fewer tokens. Weight: 6%.

**4. Should-Trigger / Should-Not-Trigger Testing** — Design descriptions by writing 10 queries that should trigger the skill and 10 that should not. This "pushy description" strategy prevents both under-triggering (missing legitimate requests) and over-triggering (false positives). We adopted this as our trigger optimization reference.

**5. Auto Eval Methodology** — Compare outcomes `with_skill` vs `without_skill` (A/B testing for skills). This influenced our before/after reporting: after every upgrade, re-diagnose and show the delta so users can see the concrete impact.

### How They Combine

| Check | Source | What it catches |
|-------|--------|----------------|
| #1 Frontmatter | Skills 2.0 | Can the skill be discovered? |
| #2 Name field | Skills 2.0 | Can the skill be stably referenced? |
| #3 Description field | Skills 2.0 | Does the skill have a search surface? |
| #4 "Use when..." | Skills 2.0 + CSO | Is the description trigger-focused? |
| #5 Third-person | skillers-suda | Is the description agent-optimized? |
| #6 Body ≤500 lines | Skills 2.0 | Is the skill token-efficient? |
| #7 Directory structure | Skills 2.0 | Does a long skill use SKILL.md + references/? |
| #8 Invocation control | Skills 2.0 | Are reference files marked as non-executable? |
| #9 No orphan dirs | Skills 2.0 | Does every skill folder have an entry point? |
| #10 No broken refs | Skills 2.0 | Do reference links resolve? |
| #11 Progressive disclosure | skillers-suda | Does the body point to its references? |
| #12 Imperative form | skillers-suda | Are instructions direct commands? |

## License

MIT — see [LICENSE](LICENSE) for details.

---

# Skills 2.0 자동 업그레이드

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)]()

> Zero-token diagnostic engine + Claude Code skill for automatically upgrading skills to Skills 2.0 compliance.

## Skills 2.0이란?

Skills 2.0은 Anthropic이 2026년에 정리한 스킬 프레임워크로, 재사용 가능한 에이전트 지침을 더 잘 찾고, 더 적은 토큰으로 불러오고, 더 쉽게 유지보수하도록 설계되었습니다.
핵심은 **Progressive Disclosure** 3-Tier 구조입니다. frontmatter는 트리거링용, `SKILL.md`는 실행 가이드용, `references/`는 필요할 때만 불러오는 대용량 참고자료용입니다.
현재 생태계는 **351K+ published skills** 규모까지 커졌기 때문에, 초기의 단일 파일 방식보다 검색 품질, 토큰 효율, 구조 일관성이 훨씬 중요해졌습니다.
이 프로젝트는 zero-token bash 진단과 가이드형 업그레이드 워크플로우로 기존 Claude Code 스킬을 그 구조로 이전할 수 있게 돕습니다.

## 빠른 시작

### 설치 (primary)

```bash
curl -fsSL https://raw.githubusercontent.com/treylom/skills-2.0-upgrade/main/install.sh | bash
```

### 로컬 클론에서 설치 (alternative)

```bash
bash install.sh
```

### 기본 사용법

```bash
/skills-upgrade                        # 인터랙티브 — 업그레이드 대상 선택
/skills-upgrade my-skill               # 개별 스킬
/skills-upgrade skill-a skill-b        # 복수 스킬
/skills-upgrade --all                  # 전체 스킬
/skills-upgrade --diagnose             # 진단만 (읽기 전용)
/skills-upgrade --dry-run              # 변경 미리보기
```

## 주요 기능

- **Zero-token 진단**: 순수 bash, LLM 호출 불필요
- **12항목 가중 체크리스트**: 종합 준수율 점수
- **P1-P4 자동 수정**: frontmatter, name, description 자동 수정
- **업그레이드 전 백업**: tar.gz 자동 백업
- **크로스 플랫폼**: WSL, macOS, Linux
- **JSON 출력**: CI/CD 통합용 머신 파싱 가능
- **슬래시 커맨드**: `/skills-upgrade` 3가지 모드
- **보안 스캔**: 배포 전 개인정보, 시크릿, 하드코딩 경로 탐지

## 사용법

### 진단 (기본)

```bash
/skills-upgrade
```

예시 출력:

```text
Skills 2.0 Compliance Report
=============================
Date: 2026-03-15 14:30:22
Path: /home/user/.claude/skills/
Skills scanned: 94
Overall compliance: 78.2%

Top Issues:
1. Missing frontmatter: 12 skills
2. Over 500 lines: 8 skills
3. Missing description: 15 skills
```

### 드라이 런

```bash
/skills-upgrade --dry-run
```

예시 출력:

```text
Planned changes
- P1 Add frontmatter: 12 files
- P2 Normalize name field: 7 files
- P3 Generate description: 15 files
- P4 Add invocation control: 4 files
No files were modified.
```

### 인터랙티브 업그레이드

```bash
/skills-upgrade my-skill
```

대상 선택 → 진단 → Phase 선택 → 미리보기 → 적용 → 전후 비교까지 단계별로 안내합니다. 기본 모드가 인터랙티브이므로 별도 플래그 없이 실행하면 됩니다.

### 스크립트 직접 실행

```bash
~/.claude/scripts/diagnose.sh ~/.claude/skills/
~/.claude/scripts/diagnose.sh ~/.claude/skills/ --json
~/.claude/scripts/diagnose.sh ~/.claude/skills/ --verbose
~/.claude/scripts/diagnose.sh ~/.claude/skills/my-skill.md
```

### 보안 스캔 (배포 전)

```bash
~/.claude/scripts/diagnose.sh /path/to/project --security
~/.claude/scripts/diagnose.sh /path/to/project --security --json
```

3단계 심각도로 13개 패턴을 탐지합니다:

| 심각도 | 탐지 대상 |
|--------|----------|
| Critical | API 키 (`sk-`, `ntn_`, `ghp_`), 개인키 블록 |
| High | Bearer 토큰, API 키/시크릿 할당, 비밀번호 |
| Medium | 하드코딩된 사용자 경로 (`/home/`, `/mnt/c/Users`, `C:\Users`) |

`git push` 또는 GitHub 배포 전 반드시 실행하여 우발적 유출을 방지하세요.

## 12항목 진단 체크리스트

| # | 항목 | 가중치 | 통과 조건 |
|---|------|--------|----------|
| 1 | Frontmatter 존재 | 20% | 첫 줄이 `---`이고 닫는 `---`가 존재 |
| 2 | `name:` 필드 | 8% | frontmatter에 `name:`이 있고 하이픈+영숫자만 사용 |
| 3 | `description:` 필드 | 10% | frontmatter에 비어있지 않은 `description:` 값 존재 |
| 4 | Description `Use when...` 패턴 | 5% | description이 `Use when`으로 시작 (대소문자 무관) |
| 5 | Description 3인칭 | 3% | description에 `you` 또는 `your` 미포함 |
| 6 | 본문 ≤500줄 | 15% | frontmatter 제외 본문이 500줄 이하 |
| 7 | 디렉토리 구조 | 10% | 긴 스킬은 `SKILL.md` + `references/` 사용; 짧은 스킬은 자동 통과 |
| 8 | `disable-model-invocation` | 8% | 레퍼런스형 스킬에 `disable-model-invocation: true` 포함; 그 외 자동 통과 |
| 9 | 고아 디렉토리 없음 | 5% | 스킬 디렉토리에 `SKILL.md` 또는 최소 1개 `.md` 파일 존재 |
| 10 | 깨진 참조 없음 | 5% | `references/` 링크가 실제 파일로 연결됨 |
| 11 | Progressive Disclosure | 5% | `references/`가 있는 스킬은 본문에서 `references/`를 명시적으로 안내 |
| 12 | 명령형 지시문 | 6% | 명령형 지시문이 2인칭 조언 표현보다 많음 |

## 모델 가이드

| 작업 | 모델 | Effort | 이유 |
|------|------|--------|------|
| 진단만 | 아무 모델 (bash) | N/A | LLM 불필요 |
| P1-P2 자동 수정 | Sonnet | medium | 단순 패턴 매칭 |
| P3 파일 분할 | Opus | high | 콘텐츠 이해 필요 |
| 전체 업그레이드 | Opus | high | 분할 포함 |

## 크로스 플랫폼 호환

| 플랫폼 | 지원 수준 | 비고 |
|--------|----------|------|
| Claude Code | Full | 모든 기능 |
| Codex CLI | Partial | JSON 출력 모드 |
| Antigravity | Partial | 스킬 읽기 + bash |
| Cursor/Windsurf | Minimal | .md 읽기만 |

## 작동 원리

4-Phase 파이프라인:
1. **Scan**: 인자 파싱, diagnose.sh 실행
2. **Report**: 준수율 요약 생성
3. **Plan**: 변경 계획 표시 (dry-run/upgrade)
4. **Execute**: 백업 → 자동 수정 → 재진단 (upgrade만)

## 실제 사례

151개 스킬 마이그레이션 실측 결과:

| Phase | 준수율 | 변화 |
|-------|--------|------|
| Baseline | 62% | Skills 2.0 구조 없음 |
| P1-P2 후 | 78% | frontmatter + name 정규화 |
| P1-P3 후 | **94.3%** | + description "Use when..." 패턴 |

잔여 이슈: 500줄 초과 (13개, Opus 분할 필요), 깨진 참조 (13개), 명령형 문체 (일부)

### 자가 개선

이 도구는 자체 진단 도구로 스스로를 4회 반복 개선했습니다:

| 반복 | 내용 | 결과 |
|------|------|------|
| 1 | 6-agent 팀 초기 빌드 | 100% 준수율 초기 달성 |
| 2 | 151개 실제 스킬 검증 | 62% → 94.3% (배치 스크립트 작성) |
| 3 | UX 개선 + false positive 수정 | Phase별 가이드 추가, 100% 유지 |
| 4 | 보안 스캔 + 자체 적용 | `--security` 모드 추가, clean 통과 |

전체 리포트: [Self-Improvement Report](SELF-IMPROVEMENT-REPORT.md)

## 프로젝트 구조

```text
skills-2.0-upgrade/
├── commands/
│   └── skills-upgrade.md
├── scripts/
│   ├── backup.sh
│   └── diagnose.sh
├── skills/
│   └── skills-2.0-upgrade/
│       ├── SKILL.md
│       └── references/
│           ├── diagnostic-criteria.md
│           ├── skills-2.0-spec.md
│           ├── trigger-optimization.md
│           └── upgrade-actions.md
├── CHANGELOG.md
├── install.sh
├── LICENSE
└── README.md
```

## Acknowledgments

이 프로젝트의 12항목 진단 체크리스트는 obra의 superpowers 스킬 프레임워크(8항목)와 fivetaku의 커뮤니티 검증 패턴(4항목)을 결합한 것입니다.

### [superpowers:writing-skills](https://github.com/obra/superpowers) (obra)에서 가져온 것

obra의 superpowers 프로젝트는 Claude Code용 실전적 스킬 작성 방법론을 정의합니다. 세 가지 핵심 아이디어를 채택했습니다:

**1. Progressive Disclosure 3-Tier 모델** — 핵심 설계 원칙: 하나의 파일에 모든 걸 넣지 말고, 단계적으로 로드되는 3개 계층으로 분리합니다.

| 계층 | 내용 | 토큰 예산 | 로드 시점 |
|------|------|----------|----------|
| Frontmatter | `name` + `description` | <100 토큰 | 항상 (검색/발견 시) |
| SKILL.md 본문 | 핵심 가이드 | <2000 토큰 | 스킬 선택 시 |
| references/ | 상세 자료 | 제한 없음 | 필요할 때만 |

쉽게 말하면: 스킬의 "표지"(frontmatter)는 항상 보이고, "목차"(SKILL.md)는 열었을 때, "부록"(references/)은 필요할 때만 읽는 구조입니다. 이 원칙이 체크 #1(frontmatter), #6(본문 500줄), #7(디렉토리 구조), #11(progressive disclosure 포인터)의 근거입니다.

**2. Claude Search Optimization (CSO)** — 스킬은 사람이 아니라 AI 에이전트가 찾을 수 있어야 합니다. `description` 필드는 "이 스킬을 지금 실행해야 하나?"라는 질문에 답하는 검색 표면입니다. 워크플로우 요약이 아니라 트리거 조건을 써야 합니다. 이것이 체크 #4("Use when..." 패턴)와 트리거 최적화 레퍼런스의 근거입니다.

**3. 스킬용 TDD (RED → GREEN → REFACTOR)** — 먼저 실패하는 진단을 만들고, 그 진단을 통과하는 스킬을 만들고, 개선합니다. 이 프로젝트 자체가 이 방법론을 따랐습니다: diagnose.sh가 "테스트", SKILL.md가 "구현", 자가 개선 4회 반복이 "리팩토링"이었습니다.

**4. Frontmatter 명세** — 필수 필드 2개만: `name`(kebab-case)과 `description`(최대 1024자, "Use when..."으로 시작, 3인칭, 워크플로우 요약 금지). 레퍼런스 전용 파일은 `disable-model-invocation: true`를 추가합니다. 체크 #1-#5, #8에 직접 대응합니다.

### [fivetaku/skillers-suda](https://github.com/fivetaku/skillers-suda) (MIT)에서 가져온 것

fivetaku의 커뮤니티 프로젝트로, Anthropic 명세가 명시적으로 체크하지 않는 실전적 검증 패턴을 추가합니다:

**1. 3인칭 description (체크 #5)** — description에서 "you", "your"를 피합니다. 왜냐하면 description의 독자는 사람이 아니라 AI 에이전트의 라우팅 시스템이기 때문입니다. "Use when analyzing code"가 "Use when you need to analyze code"보다 기계 매칭에 효과적입니다. 가중치: 3%.

**2. Progressive Disclosure 검증 (체크 #11)** — `references/` 폴더가 있는 것만으로는 부족합니다. SKILL.md 본문에 "See references/..."라고 명시적으로 안내해야 에이전트가 그 자료의 존재와 로드 시점을 알 수 있습니다. 이 포인터가 없으면 레퍼런스 파일이 사실상 보이지 않게 됩니다. 가중치: 5%.

**3. 명령형 지시문 (체크 #12)** — 스킬 본문은 "you should check"(조언형)이 아니라 "Check the frontmatter"(명령형)으로 작성해야 합니다. 명령형이 에이전트에게 더 명확하고, 토큰도 적게 사용합니다. 가중치: 6%.

**4. Should-Trigger / Should-Not-Trigger 테스트** — description을 설계할 때 "이 스킬이 실행되어야 하는 질문 10개"와 "실행되면 안 되는 질문 10개"를 작성합니다. 이 "pushy description" 전략은 과소 트리거(정당한 요청을 놓침)와 과다 트리거(오발동)를 모두 방지합니다.

**5. Auto Eval 방법론** — `with_skill` vs `without_skill` 비교(스킬의 A/B 테스트). 이것이 우리의 전후 비교 리포팅에 영향을 주었습니다: 업그레이드 후 항상 재진단하여 구체적인 개선 수치를 보여줍니다.

### 어떻게 결합되는가

| 체크 | 출처 | 무엇을 잡아내는가 |
|------|------|-----------------|
| #1 Frontmatter | Skills 2.0 | 스킬이 발견될 수 있는가? |
| #2 Name 필드 | Skills 2.0 | 스킬이 안정적으로 참조될 수 있는가? |
| #3 Description 필드 | Skills 2.0 | 스킬에 검색 표면이 있는가? |
| #4 "Use when..." | Skills 2.0 + CSO | description이 트리거 중심인가? |
| #5 3인칭 | skillers-suda | description이 에이전트에 최적화되어 있는가? |
| #6 본문 ≤500줄 | Skills 2.0 | 스킬이 토큰 효율적인가? |
| #7 디렉토리 구조 | Skills 2.0 | 긴 스킬이 SKILL.md + references/를 사용하는가? |
| #8 Invocation 제어 | Skills 2.0 | 레퍼런스 파일이 비실행으로 표시되어 있는가? |
| #9 고아 디렉토리 없음 | Skills 2.0 | 모든 스킬 폴더에 진입점이 있는가? |
| #10 깨진 참조 없음 | Skills 2.0 | 레퍼런스 링크가 실제 파일로 연결되는가? |
| #11 Progressive Disclosure | skillers-suda | 본문이 레퍼런스를 안내하는가? |
| #12 명령형 지시문 | skillers-suda | 지시사항이 직접 명령인가? |

## License

MIT — 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
