# 프롬프트 엔지니어링 스킬

> **모델 순위**: [LMArena Leaderboard](https://lmarena.ai) 기반 (2026년 3월 기준)

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
| **GPT-5.4 / GPT-5.4-Codex** | XML 패턴, reasoning_effort, Compaction |
| **Claude 4.6 (Opus/Sonnet)** | 명시적 지시, Adaptive Thinking |
| **Gemini 3** | Constraints First, 멀티모달 컨텍스트 |
| **Veo 3.1** | 오디오 포함 동영상 생성 |
| **Gemini Image** | 이미지 생성 |

### 목적별 추천 모델 (LMArena 기준)

> 출처: [LMArena Leaderboard](https://lmarena.ai) - 사용자 투표 기반 순위

| 목적 | 1순위 | 2순위 | 3순위 |
|------|-------|-------|-------|
| **코딩/개발** | Claude Opus 4.6 | GPT-5.4 | Gemini 3.1 Pro |
| **수학/논리** | Claude Opus 4.6 | Gemini 3.1 Pro | GPT-5.4 |
| **글쓰기/창작** | Gemini 3.1 Pro | Gemini 3 Pro | Claude Opus 4.6 |
| **이미지 생성** | NanoBanana2 (Gemini 3.1 Flash Image) | GPT Image 1.5 | gpt-image |
| **동영상 생성** | Kling 3.0 | Grok Imagine Video | Veo 3 |
| **웹 검색/리서치** | Claude Opus 4.6 Search | GPT-5.2 Search | Gemini 3 Pro Grounding |
| **팩트체크** | **GPT-5.4 Thinking** | Gemini 3 Pro Grounding | Perplexity Sonar Pro |

---

## 저장소 구조

```
prompt-engineering-skills/
├── README.md                           # 이 파일
├── LICENSE                             # MIT 라이선스
│
├── skills/                             # 핵심 스킬 파일
│   ├── prompt-engineering-guide.md     # 모델별 프롬프트 전략
│   ├── image-prompt-guide.md           # 이미지 생성 가이드
│   ├── gpt-5.4-prompt-enhancement.md   # GPT-5.4 전용 패턴
│   ├── claude-4.6-prompt-strategies.md # Claude 4.6 전용 전략
│   ├── gemini-3.1-prompt-strategies.md # Gemini/Veo/Nano Banana 전략
│   ├── context-engineering-collection.md  # CE 원칙
│   ├── expert-domain-priming.md        # 전문 도메인 프라이밍
│   ├── research-prompt-guide.md        # 검색/리서치 프롬프트 가이드
│   └── slide-prompt-guide.md           # 슬라이드 프롬프트 가이드
│
├── commands/                           # Claude Code 커맨드
│   ├── prompt.md                       # /prompt 커맨드
│   └── prompt-sync.md                  # /prompt-sync 동기화 커맨드
│
├── instructions/                       # GPTs/Gems 시스템 프롬프트
│   ├── GPTs-Prompt-Generator.md        # ChatGPT GPTs용
│   └── Gems-Prompt-Generator.md        # Gemini Gems용
│
└── examples/                           # 사용 예시
    ├── gpt-5.4-examples.md
    ├── claude-4.5-examples.md
    └── image-generation-examples.md
```

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
# 글로벌 설치 (모든 프로젝트에서 사용)
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
2. `skills/` 폴더의 파일을 **Knowledge**에 업로드
3. `instructions/GPTs-Prompt-Generator.md` 내용을 **Instructions**에 붙여넣기

### Gemini Gems 직접 만들기

1. [Gems 설정](https://gemini.google.com/gems) 접속
2. `skills/` 폴더의 파일을 **지식 파일**에 업로드
3. `instructions/Gems-Prompt-Generator.md` 내용을 **지침**에 붙여넣기

---

## 핵심 스킬

### prompt-engineering-guide.md

메인 스킬 파일:
- 모델별 프롬프트 전략
- 각 모델의 필수 XML 블록
- Context Engineering 원칙
- 목적별 템플릿
- 품질 체크리스트

### image-prompt-guide.md

공냥이(@specal1849)님의 자료를 기반으로 한 종합 이미지 생성 가이드:
- 시그널(Signal)과 신뢰도(Faithful) 개념
- 프롬프트 형식 비교 (JSON/XML/Markdown/자연어)
- 스타일별 템플릿 (제품/푸드/패션/캐릭터 등)
- 조명 및 카메라 기법
- 인포그래픽 제작 가이드

### context-engineering-collection.md

[Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering)을 기반으로 한 Context Engineering 원칙:
- Attention Budget 관리
- 컨텍스트 저하 방지
- 멀티 에이전트 패턴
- 도구 설계 원칙

---

## 지원 모델

### GPT-5.4 / GPT-5.4-Codex

| 기능 | 패턴 |
|------|------|
| 장황함 제어 | `<output_verbosity_spec>` |
| 범위 제약 | `<design_and_scope_constraints>` |
| 불확실성 처리 | `<uncertainty_and_ambiguity>` |
| 도구 사용 | `<tool_usage_rules>` |

**Codex 핵심 원칙**: "Less is More" - 최소한의 프롬프팅이 최적

### Claude 4.6

| 기능 | 패턴 |
|------|------|
| 기본 행동 | `<default_to_action>` |
| 명시적 지시 | 모든 행동에 필수 |
| Extended Thinking | 복잡한 추론 시 활성화 |
| 병렬 도구 호출 | `<use_parallel_tool_calls>` |

### Gemini 3 / Veo 3.1 / Gemini Image

| 기능 | 패턴 |
|------|------|
| Constraints First | 제약 조건을 최상단에 배치 |
| Temperature | 1.0 권장 |
| 멀티모달 | 이미지/오디오 컨텍스트 네이티브 지원 |
| Veo 오디오 | 대화, 음향효과, 배경음 |

---

## 크레딧

### 이미지 프롬프트 가이드

[공냥이 (@specal1849)](https://threads.net/@specal1849)님의 자료 기반:
- [Image Prompt 101 슬라이드](https://docs.google.com/presentation/d/1rPQVnbu1INJyUAqCvMA7dkO2WzJpD4Q9q_UXq9RH2GU/edit)
- [PRO Image Prompt Notion](https://fascinated-alley-b43.notion.site/PRO-2b1861d1faaf80b8bf7ef4093827f59b)

### 컨텍스트 엔지니어링

Muratcan Koylan의 [Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering) 기반

### 모델 문서

OpenAI, Anthropic, Google 공식 문서 참조

---

## 라이선스

MIT License - [LICENSE](./LICENSE) 참조

---

## 기여

기여를 환영합니다! PR 제출 전 기여 가이드라인을 확인해 주세요.

---

## 버전

- **현재**: 2.2.0
- **최종 업데이트**: 2026-03-08
- **변경사항 v2.2.0**:
  - LMArena/Artificial Analysis 2026년 3월 벤치마크 기준 전체 순위 업데이트
  - 텍스트/코드: Claude Opus 4.6 #1, GPT-5.4 반영
  - 이미지: NanoBanana2 (Gemini 3.1 Flash Image) #1, GPT Image 1.5 #2
  - 동영상: Kling 3.0 #1, Grok Imagine Video #2 (Veo 3.1 순위 하락)
  - 검색: Claude Opus 4.6 Search #1, GPT-5.4 Search #2
  - GPTs/Gems Prompt Generator v2.2.0 동기화
- **변경사항 v1.8.0**:
  - 동영상 프롬프트 JSON 구조 통일: 모든 동영상에 스토리보드 형식(scenes 배열) 적용
  - GPTs 기본 모델: Sora 2, Gems 기본 모델: Veo 3.1
  - 스토리보드 필수 요소 체크리스트 추가 (sequence, duration, description, camera, audio)
- **변경사항 v1.7.0**:
  - 동영상 생성 시 스토리보드 단계 필수화 (생략 금지)
  - 스토리보드 JSON 구조 상세화 (lighting, character action, camera motion 등)
- **변경사항 v1.6.0**:
  - 명시적 요소 확장: 사용자 입력에서 암시적 요소를 구체적으로 풀어쓰기
  - Agent 모드 프롬프트 지원 추가
- **변경사항 v1.5.0**:
  - 모든 채널(GPTs, Gems, Skills) 버전 1.5.0으로 통일
  - 동영상 프롬프트 JSON+자연어 형식으로 통일 (이미지와 동일)
  - gpt-image 모델명 통일 (DALL-E/GPT Image 1.5 → gpt-image)
  - `/prompt-sync` 명령어 추가: 자동 업데이트 동기화
  - 원클릭 설치/동기화 스크립트 추가
  - 진행 상황 표시 (🔍→🧠→✅) 추가
  - $ARGUMENTS 처리 규칙 추가
- **변경사항 v1.4.0**:
  - README 버전 정보 동기화
  - GPTs-Prompt-Generator: v5.2.0 (워크플로우 전면 개편, 모든 작업 금지사항 적용)
  - Gems-Prompt-Generator: v4.3.0 (네이티브 이미지 생성 호출 명시)
  - commands/prompt.md: v4.1.0 (금지사항 강화, 개선 옵션 UI)
- **변경사항 v1.3.0**:
  - 검색/리서치 모델 추천 추가 (Search Arena 기준)
  - 팩트체크: GPT-5.2 Thinking 고정 추천
  - research-prompt-guide.md 스킬 파일 추가
- **변경사항 v1.2.0**:
  - 빠른 프리셋 제거 → LMArena 기반 목적별 추천으로 대체
  - 모든 문서에 LMArena 출처 명시

---

---

# Prompt Engineering Skills

> **Model Rankings**: Based on [LMArena Leaderboard](https://lmarena.ai) (March 2026)

A comprehensive collection of AI prompt engineering skills for Claude Code, ChatGPT GPTs, and Gemini Gems.

---

## Use Instantly

Use these links without any setup:

| Platform | Link |
|----------|------|
| **ChatGPT GPTs** | [Tofukyung Comprehensive Prompt Generator](https://chatgpt.com/g/g-694feb6bf18481918acd876e3c3eed37-tofukyung-jonghab-peurompeuteu-saengseonggi) |
| **Gemini Gems** | [Prompt Generator Gem](https://gemini.google.com/gem/1yY760AO5nQsnBs4kGTdxAJXdQRAIDdOD?usp=sharing) |

---

## Overview

This repository provides production-ready prompt engineering resources optimized for:

| Model | Coverage |
|-------|----------|
| **GPT-5.4 / GPT-5.4-Codex** | XML patterns, reasoning_effort, Compaction |
| **Claude 4.6 (Opus/Sonnet)** | Explicit instructions, Extended Thinking |
| **Gemini 3.1 Pro** | Constraints First, multimodal context |
| **Veo 3.1** | Video generation with audio |
| **Gemini Image** | Image generation |

### Recommended Models by Purpose (LMArena)

> Source: [LMArena Leaderboard](https://lmarena.ai) - User voting based rankings

| Purpose | 1st | 2nd | 3rd |
|---------|-----|-----|-----|
| **Coding/Dev** | Claude Opus 4.6 | GPT-5.4 | Gemini 3.1 Pro |
| **Math/Logic** | Claude Opus 4.6 | Gemini 3.1 Pro | GPT-5.4 |
| **Writing/Creative** | Gemini 3.1 Pro | Gemini 3 Pro | Claude Opus 4.6 |
| **Image Generation** | NanoBanana2 (Gemini 3.1 Flash Image) | GPT Image 1.5 | gpt-image |
| **Video Generation** | Kling 3.0 | Grok Imagine Video | Veo 3 |
| **Web Search/Research** | Claude Opus 4.6 Search | GPT-5.4 Search | Gemini 3 Pro Grounding |
| **Fact-Check** | **GPT-5.4 Thinking** | Grok 4.20 Search | Perplexity Sonar Pro |

---

## Repository Structure

```
prompt-engineering-skills/
├── README.md                           # This file
├── LICENSE                             # MIT License
│
├── skills/                             # Core skill files
│   ├── prompt-engineering-guide.md     # Multi-model prompt strategies
│   ├── image-prompt-guide.md           # Image generation guide
│   ├── gpt-5.4-prompt-enhancement.md   # GPT-5.4 specific patterns
│   ├── claude-4.6-prompt-strategies.md # Claude 4.6 specific strategies
│   ├── gemini-3.1-prompt-strategies.md # Gemini/Veo/Nano Banana strategies
│   ├── context-engineering-collection.md  # CE principles
│   ├── expert-domain-priming.md        # Expert domain priming
│   ├── research-prompt-guide.md        # Search/research prompt guide
│   └── slide-prompt-guide.md           # Slide prompt guide
│
├── commands/                           # Claude Code commands
│   ├── prompt.md                       # /prompt command
│   └── prompt-sync.md                  # /prompt-sync sync command
│
├── instructions/                       # GPTs/Gems system prompts
│   ├── GPTs-Prompt-Generator.md        # For ChatGPT GPTs
│   └── Gems-Prompt-Generator.md        # For Gemini Gems
│
└── examples/                           # Usage examples
    ├── gpt-5.4-examples.md
    ├── claude-4.5-examples.md
    └── image-generation-examples.md
```

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
# Global install (use in all projects)
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
2. Upload files from `skills/` to **Knowledge**
3. Paste `instructions/GPTs-Prompt-Generator.md` into **Instructions**

### Create Your Own Gemini Gems

1. Go to [Gems Settings](https://gemini.google.com/gems)
2. Upload files from `skills/` to **Knowledge files**
3. Paste `instructions/Gems-Prompt-Generator.md` into **Instructions**

---

## Core Skills

### prompt-engineering-guide.md

The main skill file covering:
- Model-specific prompt strategies
- Required XML blocks for each model
- Context Engineering principles
- Purpose-specific templates
- Quality checklists

### image-prompt-guide.md

Comprehensive image generation guide based on [@specal1849](https://threads.net/@specal1849)'s work:
- Signal and Faithful concepts
- Prompt format comparison (JSON/XML/Markdown/Natural language)
- Style templates (Product, Food, Fashion, Character, etc.)
- Lighting and camera techniques
- Infographic creation guide

### context-engineering-collection.md

Context Engineering principles based on [Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering):
- Attention budget management
- Context degradation prevention
- Multi-agent patterns
- Tool design principles

---

## Supported Models

### GPT-5.4 / GPT-5.4-Codex

| Feature | Pattern |
|---------|---------|
| Verbosity Control | `<output_verbosity_spec>` |
| Scope Constraints | `<design_and_scope_constraints>` |
| Uncertainty Handling | `<uncertainty_and_ambiguity>` |
| Tool Usage | `<tool_usage_rules>` |

**Codex Key Principle**: "Less is More" - minimal prompting works best

### Claude 4.6

| Feature | Pattern |
|---------|---------|
| Action by Default | `<default_to_action>` |
| Explicit Instructions | Required for all behaviors |
| Extended Thinking | Enable for complex reasoning |
| Parallel Tool Calls | `<use_parallel_tool_calls>` |

### Gemini 3 / Veo 3.1 / Gemini Image

| Feature | Pattern |
|---------|---------|
| Constraints First | Place constraints at the top |
| Temperature | 1.0 recommended |
| Multimodal | Native image/audio context |
| Veo Audio | Dialogue, sound effects, ambient |

---

## Credits

### Image Prompt Guide

Based on materials by [공냥이 (@specal1849)](https://threads.net/@specal1849):
- [Image Prompt 101 Slides](https://docs.google.com/presentation/d/1rPQVnbu1INJyUAqCvMA7dkO2WzJpD4Q9q_UXq9RH2GU/edit)
- [PRO Image Prompt Notion](https://fascinated-alley-b43.notion.site/PRO-2b1861d1faaf80b8bf7ef4093827f59b)

### Context Engineering

Based on [Agent Skills for Context Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering) by Muratcan Koylan.

### Model Documentation

Official docs from OpenAI, Anthropic, Google

---

## License

MIT License - see [LICENSE](./LICENSE)

---

## Contributing

Contributions welcome! Please read the contributing guidelines before submitting PRs.

---

## Version

- **Current**: 2.2.0
- **Last Updated**: 2026-03-08
- **Changes v2.2.0**:
  - Full ranking update based on LMArena/Artificial Analysis March 2026 benchmarks
  - Text/Code: Claude Opus 4.6 #1, GPT-5.4 added
  - Image: NanoBanana2 (Gemini 3.1 Flash Image) #1, GPT Image 1.5 #2
  - Video: Kling 3.0 #1, Grok Imagine Video #2 (Veo 3.1 dropped)
  - Search: Claude Opus 4.6 Search #1, GPT-5.4 Search #2
  - GPTs/Gems Prompt Generator v2.2.0 synchronized
- **Changes v1.8.0**:
  - Unified video prompt JSON structure: storyboard format (scenes array) for all videos
  - GPTs default model: Sora 2, Gems default model: Veo 3.1
  - Added storyboard required elements checklist (sequence, duration, description, camera, audio)
- **Changes v1.7.0**:
  - Storyboard step now mandatory for video generation (cannot skip)
  - Detailed storyboard JSON structure (lighting, character action, camera motion, etc.)
- **Changes v1.6.0**:
  - Explicit element expansion: expand implicit elements from user input
  - Added Agent mode prompt support
- **Changes v1.5.0**:
  - Unified all channels (GPTs, Gems, Skills) to version 1.5.0
  - Video prompts now use JSON+natural language format (same as images)
  - Standardized gpt-image model naming (DALL-E/GPT Image 1.5 → gpt-image)
  - Added `/prompt-sync` command: automatic update synchronization
  - Added one-click install/sync scripts
  - Added progress indicators (🔍→🧠→✅)
  - Added $ARGUMENTS handling rules
- **Changes v1.4.0**:
  - README version info synchronized
  - GPTs-Prompt-Generator: v5.2.0 (workflow overhaul, all-task restrictions applied)
  - Gems-Prompt-Generator: v4.3.0 (native image generation call specified)
  - commands/prompt.md: v4.1.0 (restrictions strengthened, improvement options UI)
- **Changes v1.3.0**:
  - Added search/research model recommendations (Search Arena)
  - Fact-check: GPT-5.2 Thinking fixed recommendation
  - Added research-prompt-guide.md skill file
- **Changes v1.2.0**:
  - Removed fast presets → Replaced with LMArena-based recommendations
  - Added LMArena source attribution to all documentation
