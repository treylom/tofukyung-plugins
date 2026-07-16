# Plugin Standard

## 기본 구조

```text
.
├── .claude-plugin/
│   └── marketplace.json
├── .agents/
│   └── plugins/
│       └── marketplace.json
├── docs/
│   └── plugin-standard.md
└── README.md
```

## 디렉터리 역할

- `.claude-plugin/marketplace.json`: 마켓플레이스 메타데이터를 관리합니다 (Claude Code용).
- `.agents/plugins/marketplace.json`: 같은 카탈로그의 Codex CLI용 사본입니다 — 엔트리 추가·변경 시 두 파일을 함께 갱신합니다.
- `README.md`: 저장소 소개, 설치 방법, 플러그인 목록, 추천 조합을 안내합니다.
- `docs/`: 운영 가이드나 작성 규칙처럼 저장소 공통 문서를 둡니다.

## 플러그인 저장소 권장 구성

각 플러그인은 목적에 맞게 다음 요소를 포함하는 것을 권장합니다.

- `skills/`: Claude Code skills
- `commands/`: slash commands
- `agents/`: 전용 에이전트가 있다면 포함
- `README.md`: 플러그인 단독 소개와 사용법
- 선택 문서: 예제, 마이그레이션 메모, 배포 가이드

## marketplace.json 작성 원칙

- `source`는 각 플러그인의 정본 저장소를 가리키는 URL 형식(`{"source": "url", "url": "https://github.com/..."}`)을 사용합니다 — 콘텐츠 정본은 각 플러그인 레포, 이 저장소는 설치 창구(마켓 메타데이터)만 관리합니다.
- `description`은 기능 나열보다 핵심 가치를 보여주는 한 줄로 작성합니다.
- `tags`는 검색에 바로 도움이 되는 2-4개 키워드만 넣습니다.
- `category`는 플러그인의 대표 용도를 가장 잘 설명하는 값 하나만 사용합니다.

## 번들형 플러그인 엔트리 (thiscode · thiscodex 류)

스킬 몇 개짜리 도구가 아니라 **작업 환경 전체를 셋업하는 번들**도 같은 카탈로그에 등재할 수 있습니다. 이때 기준:

- 번들 저장소에도 `.claude-plugin/plugin.json`이 있어야 하고, `name`·`version`이 카탈로그 엔트리와 일치해야 합니다.
- 설치가 환경(설정 파일·데몬·외부 서비스 연동)을 건드리는 번들은 `description` 또는 README 카드에 그 사실이 드러나야 합니다 — 스킬형 플러그인과 같은 얼굴로 위장하지 않습니다.
- README에서는 번들형을 별도 그룹(예: "에이전트 팀 · 작업 환경")으로 묶어 스킬형과 구분합니다.

## 엔트리 교체·은퇴 (deprecation) 규약

기존 설치 사용자가 있는 카탈로그이므로, 엔트리를 빼거나 바꿀 때는 다음을 지킵니다.

- **저장소 삭제·아카이브를 전제하지 않습니다** — 카탈로그에서 빠져도 이미 설치된 플러그인은 계속 동작해야 합니다.
- 후속작으로 교체하는 경우: ① 구 플러그인 저장소 README 상단에 후속작 안내 1줄 ② 이 저장소 README의 해당 카드에 계승 관계 1줄(예: writing-assistant → clone-n-write) ③ 카탈로그 엔트리는 후속작으로 스왑.
- 구성(엔트리 추가/제거/교체)이 바뀌면 marketplace `metadata.version`의 **major**를 올립니다.

## README 작성 원칙

- 첫 문단에서 이 저장소가 누구를 위한 것인지 바로 설명합니다.
- 설치 명령은 복사해서 바로 쓸 수 있게 유지합니다.
- 플러그인 설명은 "~하는 도구" 형식으로 짧고 명확하게 씁니다.
- 여러 플러그인을 함께 쓸 때의 시너지 시나리오를 최소 1개 이상 포함합니다.
