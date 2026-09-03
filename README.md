# tofukyung-plugins

![tofukyung-plugins hero](assets/hero.png)

**AI를 업무에 녹이고 싶은 사람들을 위한 Claude Code · Codex 플러그인 모음입니다.**

혼자 더 빠르게 배우고, 자료를 정리하고, 프롬프트를 다듬고, 글과 워크플로우를 실제 결과물로 바꾸는 흐름을 하나의 저장소에 담았습니다.
각 플러그인은 단독으로도 쓸 수 있지만, 함께 연결하면 조사부터 실행, 기록까지 자연스럽게 이어집니다.
기업용 툴 번들이 아니라 개인 개발자가 실전에서 다듬어 온 작업 습관과 자동화를 바로 가져다 쓰는 데 초점을 맞췄습니다.

> **역할 경계**: 이 저장소는 설치 창구(마켓플레이스)입니다 — 각 플러그인의 콘텐츠 정본은 각자의 저장소에 있고, 여기서는 목록·버전 메타데이터만 관리합니다.

## Quick Start

### Claude Code

1. 마켓플레이스를 추가합니다.

```bash
/plugin marketplace add https://github.com/treylom/tofukyung-plugins.git
```

2. 원하는 플러그인을 설치합니다.

```bash
/plugin install {플러그인명}
```

3. 설치한 플러그인을 최신 상태로 업데이트합니다.

```bash
/plugin update
```

플러그인 설치나 업데이트 후에는 Claude Code를 다시 시작하면 가장 안정적으로 반영됩니다.

### ChatGPT (Codex CLI)

같은 저장소가 Codex 플러그인 마켓플레이스도 겸합니다 — 스킬 규격이 [Agent Skills 오픈 표준](https://agentskills.io)으로 동일하기 때문입니다.

1. 마켓플레이스를 추가합니다.

```bash
codex plugin marketplace add treylom/tofukyung-plugins
```

2. 원하는 플러그인을 설치합니다.

```bash
codex plugin add {플러그인명}@tofukyung-plugins
```

설치 후 Codex를 다시 시작하면 반영됩니다. Codex 지원 매니페스트(`.codex-plugin/plugin.json`)는 각 플러그인 저장소에 순차 추가 중이며, 준비된 플러그인부터 설치할 수 있습니다.

### ChatGPT Work

ChatGPT Work에서는 이 카탈로그 저장소를 **통째로 등록**할 수 있습니다 (2026-07 실기기 검증).
등록 화면의 출처에 `https://github.com/treylom/tofukyung-plugins`를 넣고, **Git ref에 `master`를 직접 입력**하세요 — 폼 기본값이 `main`이라 그대로 두면 등록에 실패합니다. 등록되면 12개 플러그인이 모두 노출되고 개별 설치할 수 있습니다.
쓰려는 플러그인 저장소 하나만 직접 등록하는 방식도 그대로 동작합니다(`.claude-plugin/`의 marketplace.json + plugin.json 쌍이 준비된 저장소부터 순차 지원). 단, 같은 플러그인을 카탈로그와 개별 저장소 양쪽에서 설치하면 스킬 목록에 같은 이름이 두 개 보이니 **한쪽 경로만** 쓰는 것을 권합니다.

## Plugins

### 프롬프트 · 리서치

#### [prompt-engineering-skills](https://github.com/treylom/prompt-engineering-skills) — v2.10.0
아이디어를 바로 실행 가능한 프롬프트와 GPTs/Gems 초안으로 바꿔주는 도구.
모델별(Claude·GPT·Gemini·이미지·영상) 최적화 템플릿과 자동 개선 루프를 담았습니다.

#### [searchflow](https://github.com/treylom/deep-research) — v3.0.3 (구 이름 deep-research · 저장소 이름은 그대로)
여러 소스를 모아 교차검증하고 인용이 달린 리서치 보고서를 만들어주는 도구.
조사 결과에 근거와 신뢰도가 함께 남습니다.

### 지식 정리 · 기록

#### [knowledge-manager](https://github.com/treylom/knowledge-manager) — v1.0.0
웹·PDF·소셜 자료를 모아 Obsidian과 Notion 흐름에 맞게 정리해주는 도구.
수집한 자료가 검색 가능한 지식 자산으로 남습니다.

### 글쓰기 · 콘텐츠

#### [clone-n-write](https://github.com/treylom/clone-n-write) — v2.2.0
실제 저자의 글쓰기 과정과 문체를 복제하고, 결과를 코드 게이트로 검증해 "나다운 글"을 쓰게 해주는 도구.
감으로 다듬는 대신 코퍼스 통계와 계량 채점으로 문체를 지킵니다.

> **writing-assistant를 쓰고 계셨다면**: clone-n-write가 후속작입니다. 기존 설치는 계속 동작하며, 새로 설치한다면 clone-n-write를 권합니다.

#### [qwen3-tts-claude-skill](https://github.com/treylom/qwen3-tts-claude-skill) — v1.0.0
작성한 텍스트를 한국어·영어 음성 결과물로 바꿔주는 도구.

### 학습

#### [lesson-skill](https://github.com/treylom/lesson-skill) — v1.0.0
Claude Code를 1:1 적응형 수업처럼 학습하게 도와주는 도구.

#### [cc-codex-lessons](https://github.com/treylom/lesson-cc-codex) — v0.2.0
Claude Code + Codex 실습을 1:1로 진행하는 인터랙티브 실습 스킬.
비개발자 실무자 눈높이로 한 단계씩 진행합니다.

### 스킬 제작 · 워크플로우

#### [skills-2.0-upgrade](https://github.com/treylom/skills-2.0-upgrade) — v1.0.0
Claude Code 스킬의 품질을 진단하고 2.0 구조로 업그레이드해주는 도구.
Codex CLI 설치명은 `skills-2-0-upgrade`입니다(플러그인 이름에 점을 쓸 수 없어 다릅니다).

#### [tofable-kit](https://github.com/treylom/tofable) — v0.1.0
일 잘하는 방식(분해 → 프롬프트 정제 → 증거 실행 → 정직한 마감)을 스킬로 장착해주는 도구.
prompt-engineering-skills와 함께 쓰면 연동되고, 없으면 기본 프롬프팅으로 동작합니다.

### 에이전트 팀 · 작업 환경

#### [tofu-at](https://github.com/treylom/tofu-at) — v2.0.0
복잡한 작업을 에이전트 팀으로 분해하고 실행 흐름을 잡아주는 도구.

#### [thiscode](https://github.com/treylom/ThisCode) — v1.0.0
Claude Code 작업 환경(Discord 봇·tmux·훅·운영 규칙)을 한 번에 셋업해주는 번들.
"에이전트 팀을 어떻게 차리지?"의 시작점을 통째로 제공합니다.

#### [thiscodex](https://github.com/treylom/ThisCodex) — v1.0.0
Codex CLI 에이전트를 Claude Code 봇처럼 운영하게 해주는 번들 — 페르소나·vault 규율·멀티에이전트 컨벤션 포함.
thiscode와 짝을 이뤄 Claude·Codex 혼성 팀을 만듭니다.

## 시너지 가이드

### 1. 프롬프트 → 지식 → 글쓰기 파이프라인
새 주제를 빠르게 콘텐츠로 만들고 싶을 때 유용한 조합입니다.
[prompt-engineering-skills](https://github.com/treylom/prompt-engineering-skills)로 조사 프롬프트와 질문 구조를 먼저 설계하고, [knowledge-manager](https://github.com/treylom/knowledge-manager)로 필요한 자료를 모아 정리한 뒤, [clone-n-write](https://github.com/treylom/clone-n-write)로 초안을 내 문체에 맞게 완성합니다.
아이디어 단계에서 막히지 않고, 자료 수집과 집필이 한 흐름으로 이어집니다.

### 2. 학습 → 스킬 제작 → 팀 운영 성장 경로
Claude Code를 배우는 단계에서 실제 운영 단계까지 올라가고 싶을 때 맞는 조합입니다.
[lesson-skill](https://github.com/treylom/lesson-skill)로 사용 감각을 익히고, [skills-2.0-upgrade](https://github.com/treylom/skills-2.0-upgrade)로 내가 만든 스킬을 점검하고 구조를 정리한 다음, [tofu-at](https://github.com/treylom/tofu-at)로 여러 에이전트를 묶어 실전 워크플로우를 운영합니다.
학습용 실험이 개인 생산성 시스템으로 확장되는 경로를 만들 수 있습니다.

### 3. 멀티미디어 콘텐츠 제작
텍스트를 음성과 아카이브까지 연결하고 싶을 때 추천하는 조합입니다.
[clone-n-write](https://github.com/treylom/clone-n-write)로 글의 메시지와 문체를 먼저 다듬고, [qwen3-tts-claude-skill](https://github.com/treylom/qwen3-tts-claude-skill)로 음성 버전을 만든 뒤, [knowledge-manager](https://github.com/treylom/knowledge-manager)로 원고와 참고 자료를 함께 정리합니다.
콘텐츠 제작과 보관이 분리되지 않아 재사용이 쉬워집니다.

### 4. 리서치 → 지식 정리 파이프라인
깊이 있는 조사 결과를 체계적으로 정리하고 싶을 때 맞는 조합입니다.
[searchflow](https://github.com/treylom/deep-research)로 주제를 교차검증된 보고서로 만들고, [knowledge-manager](https://github.com/treylom/knowledge-manager)로 수집된 소스와 분석을 Obsidian에 정리한 뒤, [clone-n-write](https://github.com/treylom/clone-n-write)로 리서치 결과를 독자 맞춤형 글로 발전시킵니다.
조사와 정리가 분리되지 않아 리서치 자산이 재활용 가능한 형태로 남습니다.

### 5. 작업 환경 → 에이전트 팀 운영
개인 세팅을 넘어 여러 에이전트가 함께 일하는 환경을 만들고 싶을 때 맞는 조합입니다.
[thiscode](https://github.com/treylom/ThisCode)로 Claude Code 운영 환경을 통째로 셋업하고, [thiscodex](https://github.com/treylom/ThisCodex)로 Codex 에이전트를 같은 규율 아래 합류시킨 뒤, [tofu-at](https://github.com/treylom/tofu-at)로 팀 단위 작업 분해와 실행을 돌립니다.
혼자 쓰던 도구 모음이 역할이 나뉜 에이전트 팀으로 확장됩니다.

## Requirements

- Claude Code, ChatGPT (Codex CLI), ChatGPT Work 세 곳 모두에서 이 저장소를 마켓플레이스로 등록해 설치할 수 있습니다.
- Windows 환경에서는 WSL2 사용을 권장합니다.

## Contributing

새 플러그인을 추가하거나 기존 설명을 다듬고 싶다면 PR로 제안해 주세요.
저장소 구조와 메타데이터 형식은 [`docs/plugin-standard.md`](docs/plugin-standard.md)를 기준으로 맞추면 됩니다.

## License

MIT
