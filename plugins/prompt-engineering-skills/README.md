# 프롬프트 엔지니어링 스킬

> **모델 순위**: [LMArena Leaderboard](https://lmarena.ai) 기반 (2026년 4월 기준)

Claude Code, ChatGPT GPTs, Gemini Gems를 위한 종합 AI 프롬프트 엔지니어링 스킬 모음입니다.

---

## 바로 사용하기

설정 없이 바로 사용할 수 있는 링크입니다:

| 플랫폼 | 링크 |
|--------|------|
| **ChatGPT GPTs** | [두부경 종합 프롬프트 생성기](https://chatgpt.com/g/g-694feb6bf18481918acd876e3c3eed37-tofukyung-jonghab-peurompeuteu-saengseonggi) |
| **Gemini Gems** | [프롬프트 생성기 Gem](https://gemini.google.com/gem/1ZV9S3vNOwExi4_yLHRJKFtpNpATPDI5d?usp=sharing) |

---

## 개요

이 저장소는 다음 모델에 최적화된 프롬프트 엔지니어링 자료를 제공합니다:

| 모델 | 커버리지 |
|------|----------|
| **GPT-5.5 / GPT-5.5-Codex** | Outcome-first 마크다운 6섹션 (Role/Personality/Goal/Success Criteria/Constraints/Output/Stop Rules) |
| **GPT-5.4 / GPT-5.2** (legacy) | XML 12블록 stack, reasoning_effort, Compaction |
| **Claude Opus 4.7 / Sonnet 4.6** | Adaptive Thinking + effort=xhigh, prefill 금지, literal instruction following |
| **Claude 4.5/4.6** (명시 시) | XML + Extended Thinking, budget_tokens·temperature·prefill OK |
| **Gemini 3.1 Pro / Flash** | Constraints First, 멀티모달 컨텍스트 |
| **Veo 3.1 / Seedance / Kling 3.0** | 동영상 생성 (오디오 포함, 다국어 대사 stage direction) |
| **Nano Banana 2 (Gemini 3.1 Flash Image) / gpt-image-2** | 이미지 생성 |

### 목적별 추천 모델 (LMArena 기준)

> 출처: [LMArena Leaderboard](https://lmarena.ai) — 사용자 투표 기반 (2026년 4월)

| 목적 | 1순위 | 2순위 | 3순위 |
|------|-------|-------|-------|
| **코딩/개발** | Claude Opus 4.7 (`xhigh`+adaptive) | Claude Opus 4.6 (안정성) | GPT-5.5 Codex |
| **수학/논리** | Claude Opus 4.7 | Gemini 3.1 Pro | GPT-5.5 |
| **글쓰기/창작** | Gemini 3.1 Pro | Claude Opus 4.7 | Gemini 3 Pro |
| **이미지 생성** | gpt-image-2 | NanoBanana2 (Gemini 3.1 Flash Image) | Gemini 3 Pro Image |
| **동영상 생성** | Veo 3.1 | Kling 3.0 | Seedance |
| **웹 검색/리서치** | Claude Opus 4.7 Search | GPT-5.5 Search | Gemini 3 Pro Grounding |
| **팩트체크** | GPT-5.5 Thinking | Gemini 3 Pro Grounding | Perplexity Sonar Pro |

---

## 저장소 구조

```
prompt-engineering-skills/
├── README.md                            # 이 파일
├── LICENSE                              # MIT 라이선스
│
├── skills/                              # 핵심 스킬 파일 (9개)
│   ├── prompt-engineering-guide.md      # 모델별 프롬프트 전략 (메인)
│   ├── claude-4.7-prompt-strategies.md  # Claude 4.x 전략 (Opus 4.5/4.6/4.7 + Sonnet 4.5/4.6 + Haiku 4.5)
│   ├── gpt-5.5-prompt-enhancement.md    # GPT-5.5 outcome-first + GPT-5.4/5.2 legacy XML stack
│   ├── gemini-3.1-prompt-strategies.md  # Gemini / Veo 3.1 / Nano Banana 전략
│   ├── image-prompt-guide.md            # 이미지 + 동영상 프롬프트 가이드 (공냥이 @specal1849)
│   ├── research-prompt-guide.md         # 리서치/팩트체크 IFCN 프롬프트 (두부 @tofukyung)
│   ├── expert-domain-priming.md         # 전문가 도메인 프라이밍 DB (12 도메인 60+명)
│   ├── slide-prompt-guide.md            # 슬라이드/PPT 프롬프트 (27 비주얼 스타일)
│   └── context-engineering-collection.md # Context Engineering 원칙
│
├── commands/                            # Claude Code 슬래시 커맨드
│   ├── prompt.md                        # /prompt — 프롬프트 생성기
│   └── prompt-sync.md                   # /prompt-sync — 통합 동기화 에이전트
│
├── instructions/                        # GPTs/Gems 시스템 프롬프트
│   ├── GPTs-Prompt-Generator.md         # ChatGPT GPTs용 (8000자 한도)
│   └── Gems-Prompt-Generator.md         # Gemini Gems용
│
└── examples/                            # 사용 예시
    ├── gpt-5.4-examples.md
    ├── claude-4.5-examples.md
    └── image-generation-examples.md
```

> ⚠️ **GPTs/Gems 첨부파일 10개 한도** — 현재 9개. 모델 추가 시 통합/축소 검토 필요.

---

## 직접 설정하기

### Claude Code 사용자

#### ⚡ 원클릭 글로벌 설치 (모든 프로젝트에서 사용)

**macOS / Linux:**
```bash
git clone https://github.com/treylom/prompt-engineering-skills.git /tmp/pes && \
mkdir -p ~/.claude/skills ~/.claude/commands && \
cp /tmp/pes/skills/*.md ~/.claude/skills/ && \
cp /tmp/pes/commands/*.md ~/.claude/commands/ && \
rm -rf /tmp/pes && \
echo "✅ 설치 완료! 이제 모든 프로젝트에서 /prompt 사용 가능"
```

**Windows PowerShell:**
```powershell
git clone https://github.com/treylom/prompt-engineering-skills.git $env:TEMP\pes; `
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills", "$env:USERPROFILE\.claude\commands" | Out-Null; `
Copy-Item "$env:TEMP\pes\skills\*.md" "$env:USERPROFILE\.claude\skills\"; `
Copy-Item "$env:TEMP\pes\commands\*.md" "$env:USERPROFILE\.claude\commands\"; `
Remove-Item -Recurse -Force "$env:TEMP\pes"; `
Write-Host "✅ 설치 완료! 이제 모든 프로젝트에서 /prompt 사용 가능" -ForegroundColor Green
```

#### 📁 프로젝트별 설치 vs 글로벌 설치

| 설치 위치 | 적용 범위 | 사용 시점 |
|-----------|-----------|-----------|
| `~/.claude/` (글로벌) | **모든 프로젝트**에서 사용 가능 | 개인용 도구로 항상 사용 |
| `.claude/` (프로젝트 폴더) | **해당 프로젝트**에서만 사용 | 팀 공유, 프로젝트 특화 설정 |

**주의**: repo를 포크/클론하면 해당 프로젝트에만 설치됩니다.
모든 프로젝트에서 사용하려면 위의 **글로벌 설치** 명령어를 실행하세요.

#### 수동 설치 (글로벌)

```bash
cp skills/*.md ~/.claude/skills/
cp commands/*.md ~/.claude/commands/
```

그 후 Claude Code에서 `/prompt` 커맨드 사용.

#### 🔄 업데이트 동기화

설치 후 최신 버전으로 업데이트하려면:

```
/prompt-sync
```

또는 원클릭 동기화:

**macOS / Linux:**
```bash
git clone --depth 1 https://github.com/treylom/prompt-engineering-skills.git /tmp/pes-sync && \
cp /tmp/pes-sync/skills/*.md ~/.claude/skills/ && \
cp /tmp/pes-sync/commands/*.md ~/.claude/commands/ && \
rm -rf /tmp/pes-sync && echo "✅ 동기화 완료!"
```

**Windows PowerShell:**
```powershell
git clone --depth 1 https://github.com/treylom/prompt-engineering-skills.git $env:TEMP\pes-sync; `
Copy-Item "$env:TEMP\pes-sync\skills\*.md" "$env:USERPROFILE\.claude\skills\"; `
Copy-Item "$env:TEMP\pes-sync\commands\*.md" "$env:USERPROFILE\.claude\commands\"; `
Remove-Item -Recurse -Force "$env:TEMP\pes-sync"; `
Write-Host "✅ 동기화 완료!" -ForegroundColor Green
```

### ChatGPT GPTs 직접 만들기

1. [GPT Editor](https://chat.openai.com/gpts/editor) 접속
2. `skills/` 폴더의 9개 파일을 **Knowledge**에 업로드 (10개 한도)
3. `instructions/GPTs-Prompt-Generator.md` 내용을 **Instructions**에 붙여넣기 (8000자 한도)

### Gemini Gems 직접 만들기

1. [Gems 설정](https://gemini.google.com/gems) 접속
2. `skills/` 폴더의 9개 파일을 **지식 파일**에 업로드 (10개 한도)
3. `instructions/Gems-Prompt-Generator.md` 내용을 **지침**에 붙여넣기

---

## 핵심 스킬

### prompt-engineering-guide.md

메인 스킬 파일:
- 모델별 프롬프트 전략 (GPT-5.5 outcome-first / Claude 4.x XML / Gemini Constraints First)
- 각 모델의 필수 블록과 권장 패턴
- Context Engineering 원칙
- 목적별 템플릿
- 품질 체크리스트

### image-prompt-guide.md

공냥이(@specal1849)님의 자료를 기반으로 한 종합 이미지/동영상 가이드:
- 시그널(Signal)과 신뢰도(Faithful) 개념
- 프롬프트 형식 비교 (JSON/XML/Markdown/자연어)
- 스타일별 템플릿 (제품/푸드/패션/캐릭터/만화 등)
- 조명·카메라 기법
- 동영상 JSON 구조 (Veo / Sora / Seedance / Kling 공통)
- 비영어 대사 + 영어 감정 메타 지시 패턴 (다국어 stage direction)
- 슬라이드 이미지 + NanoBanana2 (Gemini 3.1 Flash Image)

### claude-4.7-prompt-strategies.md

Claude 4.x 통합 전략:
- Opus 4.7: adaptive thinking + effort=xhigh, budget_tokens 제거, prefill 금지
- Opus 4.6: budget_tokens·temperature·prefill OK (명시 시 fallback)
- Sonnet 4.5/4.6, Haiku 4.5 패턴
- 4.6→4.7 전환 회귀 매트릭스 (Part 0.5)

### gpt-5.5-prompt-enhancement.md

GPT-5.5 공식 outcome-first 가이드 + GPT-5.4/5.2 legacy XML stack 통합:
- 마크다운 6섹션 (Role / Personality / Goal / Success Criteria / Constraints / Output / Stop Rules)
- Migration 매핑 (5.4 12블록 → 5.5 6섹션)
- Reasoning Effort 권장값 (low/medium 우선)
- Anti-patterns

### expert-domain-priming.md

12 도메인 60+ 전문가 DB:
- "act as an expert" 대신 실존 전문가 직접 지명
- 잠재 공간(Latent Space) 활성화 / MoE 라우팅 시그널
- 5가지 역할 점검 (범위/목적/형식/금지/행동) + 금지어 6개

### research-prompt-guide.md

리서치 / 팩트체크 IFCN 가이드 (두부 @tofukyung):
- 출처 검증 / 교차검증 / 인라인 인용
- Universal-FactCheck 프롬프트

### slide-prompt-guide.md

슬라이드 / PPT 프롬프트:
- 27 비주얼 스타일 + 7 내러티브 모드
- shared_style + session_id 일관성

### gemini-3.1-prompt-strategies.md

Gemini 3 Pro / Flash + Veo 3.1 + Nano Banana / NB2 전략.

### context-engineering-collection.md

[Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering) 기반 CE 원칙:
- Attention Budget 관리
- 컨텍스트 저하 방지
- 멀티 에이전트 패턴
- 도구 설계 원칙

---

## 지원 모델

### GPT-5.5 / GPT-5.5-Codex

| 기능 | 패턴 |
|------|------|
| 구조 | Markdown 6섹션 (outcome-first) |
| 핵심 블록 | Role / Personality / Goal / Success Criteria / Constraints / Output / Stop Rules |
| Reasoning Effort | low / medium 우선, 부족 시 escalate |
| Codex 원칙 | "Less is More" — preamble 요구 금지 |

### GPT-5.4 / GPT-5.2 (legacy XML)

| 기능 | 패턴 |
|------|------|
| 장황함 제어 | `<output_verbosity_spec>` |
| 범위 제약 | `<design_and_scope_constraints>` |
| 불확실성 처리 | `<uncertainty_and_ambiguity>` |
| 도구 사용 | `<tool_usage_rules>` |

### Claude Opus 4.7 (디폴트)

| 기능 | 패턴 |
|------|------|
| Thinking | `thinking={"type":"adaptive"}` + `effort="xhigh"` |
| 금지 | `budget_tokens` / `temperature` / `top_p` / prefill 사용 금지 (400 에러) |
| Instruction following | Literal — 모호한 표현 금지 |
| 병렬 도구 호출 | `<use_parallel_tool_calls>` + `<investigate_before_answering>` |

### Claude Opus 4.6 / Sonnet 4.6 (명시 시 fallback)

| 기능 | 패턴 |
|------|------|
| Thinking | `thinking={"type":"enabled","budget_tokens":N}` 또는 `"adaptive"` |
| 허용 | `budget_tokens` / `temperature` / prefill OK |
| 기본 행동 | `<default_to_action>` |
| Extended Thinking | 복잡한 추론 시 활성화 |

### Gemini 3.1 / Veo 3.1 / Gemini Image

| 기능 | 패턴 |
|------|------|
| Constraints First | 제약 조건을 최상단에 배치 |
| Temperature | 1.0 권장 |
| 멀티모달 | 이미지/오디오 컨텍스트 네이티브 지원 |
| Veo 오디오 | 대화, 음향효과, 배경음 (네이티브) |
| 다국어 대사 | `(English emotion descriptor in {Language}) "대사"` 패턴 |

---

## 크레딧

### 이미지 프롬프트 가이드

[공냥이 (@specal1849)](https://threads.net/@specal1849)님의 자료 기반:
- [Image Prompt 101 슬라이드](https://docs.google.com/presentation/d/1rPQVnbu1INJyUAqCvMA7dkO2WzJpD4Q9q_UXq9RH2GU/edit)
- [PRO Image Prompt Notion](https://fascinated-alley-b43.notion.site/PRO-2b1861d1faaf80b8bf7ef4093827f59b)

### 비영어 대사 동영상 패턴

[@itsyun_ai](https://www.threads.com/@itsyun_ai/post/DXyxUwXghcR) Threads 포스트 기반 (Seedance 한국어 대사 검증, 2026-05-01) → Veo / Sora / Kling 일반화.

### 전문가 도메인 프라이밍

- 최승준 소장님, 노정석 — "Master Class - 원리를 생각하는 프롬프팅"
- [erucipe Notion A-Z](https://erucipe.notion.site/A-Z-2e3d5c9e7e5980c4a593f1994582f1ab)
- 공냥이(@specal1849) — "프롬프트 쿠튀르: 전문가의 AI 활용법"

### 컨텍스트 엔지니어링

Muratcan Koylan의 [Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering) 기반.

### 모델 문서

OpenAI, Anthropic, Google 공식 문서 참조.

---

## 라이선스

MIT License - [LICENSE](./LICENSE) 참조

---

## 기여

기여를 환영합니다! PR 제출 전 기여 가이드라인을 확인해 주세요.

---

## 버전

- **현재**: 2.3.0
- **최종 업데이트**: 2026-05-02
- **변경사항 v2.3.0** (2026-05-02):
  - **[MAJOR] Repo URL 정정**: `tofukyung/prompt-engineering-skills` → `treylom/prompt-engineering-skills` (모든 clone 명령)
  - **[MAJOR] 모델 라인업 갱신**: GPT-5.5 outcome-first 디폴트 추가 (5.4/5.2 legacy 분리), Claude Opus 4.7 디폴트 + 4.6 명시 시 fallback, Gemini 3.1 Pro
  - **[MAJOR] 추천 모델 표 갱신**: 코딩 1순위 Opus 4.7(`xhigh`+adaptive), 동영상 Veo 3.1 / Kling 3.0 / Seedance, 이미지 gpt-image-2 / NB2
  - **[MAJOR] Skills 9개 정확 표기**: claude-4.7 / gpt-5.5 / gemini-3.1 / image / research / expert-domain-priming / slide / context-engineering / prompt-engineering-guide
  - **[MEDIUM] 비영어 대사 동영상 패턴 안내**: Veo / Sora / Seedance / Kling 공통 stage direction 컨벤션 (image-prompt-guide v1.10.0)
  - **[MEDIUM] 지원 모델 섹션 신설**: GPT-5.5 outcome-first / GPT-5.4 legacy / Claude 4.7 / 4.6 / Gemini 3.1 4 카테고리
- **변경사항 v2.2.0** (2026-03-08):
  - LMArena/Artificial Analysis 2026년 3월 벤치마크 기준 전체 순위 업데이트
  - 텍스트/코드, 이미지, 동영상, 검색 카테고리 갱신
  - GPTs/Gems Prompt Generator v2.2.0 동기화

---

---

# Prompt Engineering Skills

> **Model Rankings**: Based on [LMArena Leaderboard](https://lmarena.ai) (April 2026)

A comprehensive collection of AI prompt engineering skills for Claude Code, ChatGPT GPTs, and Gemini Gems.

---

## Use Instantly

Use these links without any setup:

| Platform | Link |
|----------|------|
| **ChatGPT GPTs** | [Tofukyung Comprehensive Prompt Generator](https://chatgpt.com/g/g-694feb6bf18481918acd876e3c3eed37-tofukyung-jonghab-peurompeuteu-saengseonggi) |
| **Gemini Gems** | [Prompt Generator Gem](https://gemini.google.com/gem/1ZV9S3vNOwExi4_yLHRJKFtpNpATPDI5d?usp=sharing) |

---

## Overview

This repository provides production-ready prompt engineering resources optimized for:

| Model | Coverage |
|-------|----------|
| **GPT-5.5 / GPT-5.5-Codex** | Outcome-first markdown 6 sections (Role/Personality/Goal/Success Criteria/Constraints/Output/Stop Rules) |
| **GPT-5.4 / GPT-5.2** (legacy) | XML 12-block stack, reasoning_effort, Compaction |
| **Claude Opus 4.7 / Sonnet 4.6** | Adaptive Thinking + effort=xhigh, no prefill, literal instruction following |
| **Claude 4.5/4.6** (when specified) | XML + Extended Thinking, budget_tokens·temperature·prefill OK |
| **Gemini 3.1 Pro / Flash** | Constraints First, multimodal context |
| **Veo 3.1 / Seedance / Kling 3.0** | Video generation (audio-native, multilingual dialogue stage direction) |
| **Nano Banana 2 (Gemini 3.1 Flash Image) / gpt-image-2** | Image generation |

### Recommended Models by Purpose (LMArena)

> Source: [LMArena Leaderboard](https://lmarena.ai) — User voting based (April 2026)

| Purpose | 1st | 2nd | 3rd |
|---------|-----|-----|-----|
| **Coding/Dev** | Claude Opus 4.7 (`xhigh`+adaptive) | Claude Opus 4.6 (stability) | GPT-5.5 Codex |
| **Math/Logic** | Claude Opus 4.7 | Gemini 3.1 Pro | GPT-5.5 |
| **Writing/Creative** | Gemini 3.1 Pro | Claude Opus 4.7 | Gemini 3 Pro |
| **Image Generation** | gpt-image-2 | NanoBanana2 (Gemini 3.1 Flash Image) | Gemini 3 Pro Image |
| **Video Generation** | Veo 3.1 | Kling 3.0 | Seedance |
| **Web Search/Research** | Claude Opus 4.7 Search | GPT-5.5 Search | Gemini 3 Pro Grounding |
| **Fact-Check** | GPT-5.5 Thinking | Gemini 3 Pro Grounding | Perplexity Sonar Pro |

---

## Repository Structure

```
prompt-engineering-skills/
├── README.md                             # This file
├── LICENSE                               # MIT License
│
├── skills/                               # Core skill files (9 files)
│   ├── prompt-engineering-guide.md       # Multi-model prompt strategies (main)
│   ├── claude-4.7-prompt-strategies.md   # Claude 4.x strategies (Opus 4.5/4.6/4.7 + Sonnet 4.5/4.6 + Haiku 4.5)
│   ├── gpt-5.5-prompt-enhancement.md     # GPT-5.5 outcome-first + GPT-5.4/5.2 legacy XML stack
│   ├── gemini-3.1-prompt-strategies.md   # Gemini / Veo 3.1 / Nano Banana strategies
│   ├── image-prompt-guide.md             # Image + video prompt guide (@specal1849)
│   ├── research-prompt-guide.md          # Research/fact-check IFCN prompts (@tofukyung)
│   ├── expert-domain-priming.md          # Expert domain priming DB (12 domains, 60+ experts)
│   ├── slide-prompt-guide.md             # Slide/PPT prompts (27 visual styles)
│   └── context-engineering-collection.md # Context Engineering principles
│
├── commands/                             # Claude Code slash commands
│   ├── prompt.md                         # /prompt — prompt generator
│   └── prompt-sync.md                    # /prompt-sync — unified sync agent
│
├── instructions/                         # GPTs/Gems system prompts
│   ├── GPTs-Prompt-Generator.md          # For ChatGPT GPTs (8000-char limit)
│   └── Gems-Prompt-Generator.md          # For Gemini Gems
│
└── examples/                             # Usage examples
    ├── gpt-5.4-examples.md
    ├── claude-4.5-examples.md
    └── image-generation-examples.md
```

> ⚠️ **GPTs/Gems attachment 10-file limit** — currently 9. Review consolidation when adding new models.

---

## Setup Your Own

### For Claude Code Users

#### ⚡ One-Click Global Install (Use in All Projects)

**macOS / Linux:**
```bash
git clone https://github.com/treylom/prompt-engineering-skills.git /tmp/pes && \
mkdir -p ~/.claude/skills ~/.claude/commands && \
cp /tmp/pes/skills/*.md ~/.claude/skills/ && \
cp /tmp/pes/commands/*.md ~/.claude/commands/ && \
rm -rf /tmp/pes && \
echo "✅ Done! Now you can use /prompt in any project"
```

**Windows PowerShell:**
```powershell
git clone https://github.com/treylom/prompt-engineering-skills.git $env:TEMP\pes; `
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills", "$env:USERPROFILE\.claude\commands" | Out-Null; `
Copy-Item "$env:TEMP\pes\skills\*.md" "$env:USERPROFILE\.claude\skills\"; `
Copy-Item "$env:TEMP\pes\commands\*.md" "$env:USERPROFILE\.claude\commands\"; `
Remove-Item -Recurse -Force "$env:TEMP\pes"; `
Write-Host "✅ Done! Now you can use /prompt in any project" -ForegroundColor Green
```

#### 📁 Project vs Global Install

| Install Location | Scope | When to Use |
|------------------|-------|-------------|
| `~/.claude/` (global) | **All projects** | Personal tools, always available |
| `.claude/` (project folder) | **This project only** | Team sharing, project-specific |

**Note**: Forking/cloning the repo only installs to that project.
Run the **global install** command above to use in all projects.

#### Manual Install (Global)

```bash
cp skills/*.md ~/.claude/skills/
cp commands/*.md ~/.claude/commands/
```

Then use the `/prompt` command in Claude Code.

#### 🔄 Sync Updates

To update to the latest version after installation:

```
/prompt-sync
```

Or one-click sync:

**macOS / Linux:**
```bash
git clone --depth 1 https://github.com/treylom/prompt-engineering-skills.git /tmp/pes-sync && \
cp /tmp/pes-sync/skills/*.md ~/.claude/skills/ && \
cp /tmp/pes-sync/commands/*.md ~/.claude/commands/ && \
rm -rf /tmp/pes-sync && echo "✅ Sync complete!"
```

**Windows PowerShell:**
```powershell
git clone --depth 1 https://github.com/treylom/prompt-engineering-skills.git $env:TEMP\pes-sync; `
Copy-Item "$env:TEMP\pes-sync\skills\*.md" "$env:USERPROFILE\.claude\skills\"; `
Copy-Item "$env:TEMP\pes-sync\commands\*.md" "$env:USERPROFILE\.claude\commands\"; `
Remove-Item -Recurse -Force "$env:TEMP\pes-sync"; `
Write-Host "✅ Sync complete!" -ForegroundColor Green
```

### Create Your Own ChatGPT GPTs

1. Go to [GPT Editor](https://chat.openai.com/gpts/editor)
2. Upload the 9 files from `skills/` to **Knowledge** (10-file limit)
3. Paste `instructions/GPTs-Prompt-Generator.md` into **Instructions** (8000-char limit)

### Create Your Own Gemini Gems

1. Go to [Gems Settings](https://gemini.google.com/gems)
2. Upload the 9 files from `skills/` to **Knowledge files** (10-file limit)
3. Paste `instructions/Gems-Prompt-Generator.md` into **Instructions**

---

## Core Skills

See the Korean section above for full skill descriptions. Quick summary:

- **prompt-engineering-guide.md** — main multi-model strategy file
- **image-prompt-guide.md** — image + video prompts (Veo/Sora/Seedance/Kling video, multilingual stage direction)
- **claude-4.7-prompt-strategies.md** — Opus 4.7 adaptive + 4.6 fallback patterns
- **gpt-5.5-prompt-enhancement.md** — GPT-5.5 outcome-first + 5.4/5.2 legacy XML
- **expert-domain-priming.md** — 12 domains, 60+ named experts, latent-space activation
- **research-prompt-guide.md** — IFCN-aligned research/fact-check
- **slide-prompt-guide.md** — 27 visual styles + 7 narrative modes
- **gemini-3.1-prompt-strategies.md** — Gemini 3 Pro/Flash + Veo + Nano Banana
- **context-engineering-collection.md** — Context Engineering principles

---

## Supported Models

### GPT-5.5 / GPT-5.5-Codex

| Feature | Pattern |
|---------|---------|
| Structure | Markdown 6 sections (outcome-first) |
| Core blocks | Role / Personality / Goal / Success Criteria / Constraints / Output / Stop Rules |
| Reasoning Effort | low / medium first, escalate when needed |
| Codex principle | "Less is More" — no preamble required |

### GPT-5.4 / GPT-5.2 (legacy XML)

| Feature | Pattern |
|---------|---------|
| Verbosity Control | `<output_verbosity_spec>` |
| Scope Constraints | `<design_and_scope_constraints>` |
| Uncertainty Handling | `<uncertainty_and_ambiguity>` |
| Tool Usage | `<tool_usage_rules>` |

### Claude Opus 4.7 (default)

| Feature | Pattern |
|---------|---------|
| Thinking | `thinking={"type":"adaptive"}` + `effort="xhigh"` |
| Forbidden | `budget_tokens` / `temperature` / `top_p` / prefill (400 error) |
| Instruction following | Literal — no ambiguous wording |
| Parallel tool calls | `<use_parallel_tool_calls>` + `<investigate_before_answering>` |

### Claude Opus 4.6 / Sonnet 4.6 (when specified)

| Feature | Pattern |
|---------|---------|
| Thinking | `thinking={"type":"enabled","budget_tokens":N}` or `"adaptive"` |
| Allowed | `budget_tokens` / `temperature` / prefill OK |
| Action by Default | `<default_to_action>` |
| Extended Thinking | Enable for complex reasoning |

### Gemini 3.1 / Veo 3.1 / Gemini Image

| Feature | Pattern |
|---------|---------|
| Constraints First | Place constraints at the top |
| Temperature | 1.0 recommended |
| Multimodal | Native image/audio context |
| Veo Audio | Dialogue, sound effects, ambient (native) |
| Multilingual dialogue | `(English emotion descriptor in {Language}) "대사"` pattern |

---

## Credits

### Image Prompt Guide

Based on materials by [공냥이 (@specal1849)](https://threads.net/@specal1849):
- [Image Prompt 101 Slides](https://docs.google.com/presentation/d/1rPQVnbu1INJyUAqCvMA7dkO2WzJpD4Q9q_UXq9RH2GU/edit)
- [PRO Image Prompt Notion](https://fascinated-alley-b43.notion.site/PRO-2b1861d1faaf80b8bf7ef4093827f59b)

### Multilingual Video Dialogue Pattern

Based on [@itsyun_ai](https://www.threads.com/@itsyun_ai/post/DXyxUwXghcR) (Seedance Korean dialogue verified 2026-05-01) → generalized to Veo / Sora / Kling.

### Expert Domain Priming

- 최승준, 노정석 — "Master Class - 원리를 생각하는 프롬프팅"
- [erucipe Notion A-Z](https://erucipe.notion.site/A-Z-2e3d5c9e7e5980c4a593f1994582f1ab)
- 공냥이(@specal1849) — "Prompt Couture: Expert Use of AI"

### Context Engineering

Based on [Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering) by Muratcan Koylan.

### Model Documentation

Official docs from OpenAI, Anthropic, Google.

---

## License

MIT License - see [LICENSE](./LICENSE)

---

## Contributing

Contributions welcome! Please read the contributing guidelines before submitting PRs.

---

## Version

- **Current**: 2.3.0
- **Last Updated**: 2026-05-02
- **Changes v2.3.0** (2026-05-02):
  - **[MAJOR] Repo URL fixed**: `tofukyung/prompt-engineering-skills` → `treylom/prompt-engineering-skills` (all clone commands)
  - **[MAJOR] Model lineup updated**: GPT-5.5 outcome-first default added (5.4/5.2 legacy split), Claude Opus 4.7 default + 4.6 fallback, Gemini 3.1 Pro
  - **[MAJOR] Recommended models table refreshed**: Coding 1st = Opus 4.7 (`xhigh`+adaptive), Video = Veo 3.1 / Kling 3.0 / Seedance, Image = gpt-image-2 / NB2
  - **[MAJOR] 9 skills correctly listed**: claude-4.7 / gpt-5.5 / gemini-3.1 / image / research / expert-domain-priming / slide / context-engineering / prompt-engineering-guide
  - **[MEDIUM] Multilingual video dialogue note**: Veo / Sora / Seedance / Kling shared stage-direction convention (image-prompt-guide v1.10.0)
  - **[MEDIUM] New Supported Models section**: 4 categories — GPT-5.5 outcome-first / GPT-5.4 legacy / Claude 4.7 / 4.6 / Gemini 3.1
- **Changes v2.2.0** (2026-03-08):
  - Full ranking update based on LMArena/Artificial Analysis March 2026 benchmarks
  - Text/Code, Image, Video, Search categories refreshed
  - GPTs/Gems Prompt Generator v2.2.0 synchronized
