# tofukyung-plugins

AI를 업무에 녹이고 싶은 사람들을 위한 Claude Code 플러그인 모음입니다.
혼자 더 빠르게 배우고, 자료를 정리하고, 프롬프트를 다듬고, 글과 워크플로우를 실제 결과물로 바꾸는 흐름을 하나의 저장소에 담았습니다.
각 플러그인은 단독으로도 쓸 수 있지만, 함께 연결하면 조사부터 실행, 기록까지 자연스럽게 이어집니다.
기업용 툴 번들이 아니라 개인 개발자가 실전에서 다듬어 온 작업 습관과 자동화를 바로 가져다 쓰는 데 초점을 맞췄습니다.

## Quick Start

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

## Available Plugins

| Plugin | Description |
| --- | --- |
| [prompt-engineering-skills](https://github.com/treylom/prompt-engineering-skills) | 아이디어를 바로 실행 가능한 프롬프트와 GPTs/Gems 초안으로 바꿔주는 도구 |
| [knowledge-manager](https://github.com/treylom/knowledge-manager) | 웹·PDF·소셜 자료를 모아 Obsidian과 Notion 흐름에 맞게 정리해주는 도구 |
| [tofu-at](https://github.com/treylom/tofu-at) | 복잡한 작업을 에이전트 팀으로 분해하고 실행 흐름을 잡아주는 도구 |
| [skills-2.0-upgrade](https://github.com/treylom/skills-2.0-upgrade) | Claude Code 스킬의 품질을 진단하고 2.0 구조로 업그레이드해주는 도구 |
| [qwen3-tts-claude-skill](https://github.com/treylom/qwen3-tts-claude-skill) | 작성한 텍스트를 한국어·영어 음성 결과물로 바꿔주는 도구 |
| [writing-assistant](https://github.com/treylom/writing-assistant) | 페르소나와 문체를 다듬어 초안을 완성도 있는 글로 발전시켜주는 도구 |
| [lesson-skill](https://github.com/treylom/lesson-skill) | Claude Code를 1:1 적응형 수업처럼 학습하게 도와주는 도구 |

## 시너지 가이드

### 1. 프롬프트 → 지식 → 글쓰기 파이프라인
새 주제를 빠르게 콘텐츠로 만들고 싶을 때 유용한 조합입니다.
[prompt-engineering-skills](https://github.com/treylom/prompt-engineering-skills)로 조사 프롬프트와 질문 구조를 먼저 설계하고, [knowledge-manager](https://github.com/treylom/knowledge-manager)로 필요한 자료를 모아 정리한 뒤, [writing-assistant](https://github.com/treylom/writing-assistant)로 초안을 글의 목적과 문체에 맞게 완성합니다.
아이디어 단계에서 막히지 않고, 자료 수집과 집필이 한 흐름으로 이어집니다.

### 2. 학습 → 스킬 제작 → 팀 운영 성장 경로
Claude Code를 배우는 단계에서 실제 운영 단계까지 올라가고 싶을 때 맞는 조합입니다.
[lesson-skill](https://github.com/treylom/lesson-skill)로 사용 감각을 익히고, [skills-2.0-upgrade](https://github.com/treylom/skills-2.0-upgrade)로 내가 만든 스킬을 점검하고 구조를 정리한 다음, [tofu-at](https://github.com/treylom/tofu-at)로 여러 에이전트를 묶어 실전 워크플로우를 운영합니다.
학습용 실험이 개인 생산성 시스템으로 확장되는 경로를 만들 수 있습니다.

### 3. 멀티미디어 콘텐츠 제작
텍스트를 음성과 아카이브까지 연결하고 싶을 때 추천하는 조합입니다.
[writing-assistant](https://github.com/treylom/writing-assistant)로 글의 메시지와 톤을 먼저 다듬고, [qwen3-tts-claude-skill](https://github.com/treylom/qwen3-tts-claude-skill)로 음성 버전을 만든 뒤, [knowledge-manager](https://github.com/treylom/knowledge-manager)로 원고와 참고 자료를 함께 정리합니다.
콘텐츠 제작과 보관이 분리되지 않아 재사용이 쉬워집니다.

## Requirements

- Claude Code 전용 플러그인 마켓플레이스입니다.
- Windows 환경에서는 WSL2 사용을 권장합니다.

## Contributing

새 플러그인을 추가하거나 기존 설명을 다듬고 싶다면 PR로 제안해 주세요.
저장소 구조와 메타데이터 형식은 [`docs/plugin-standard.md`](docs/plugin-standard.md)를 기준으로 맞추면 됩니다.

## License

MIT
