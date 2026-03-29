# Plugin Standard

## 기본 구조

```text
.
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── {plugin-name}/
├── docs/
│   └── plugin-standard.md
└── README.md
```

## 디렉터리 역할

- `.claude-plugin/marketplace.json`: 마켓플레이스 메타데이터를 관리합니다.
- `plugins/{plugin-name}/`: 각 플러그인 저장소 또는 서브모듈이 위치합니다.
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

- `source`는 반드시 `./plugins/{name}` 형식을 사용합니다.
- `description`은 기능 나열보다 핵심 가치를 보여주는 한 줄로 작성합니다.
- `tags`는 검색에 바로 도움이 되는 2-4개 키워드만 넣습니다.
- `category`는 플러그인의 대표 용도를 가장 잘 설명하는 값 하나만 사용합니다.

## README 작성 원칙

- 첫 문단에서 이 저장소가 누구를 위한 것인지 바로 설명합니다.
- 설치 명령은 복사해서 바로 쓸 수 있게 유지합니다.
- 플러그인 설명은 "~하는 도구" 형식으로 짧고 명확하게 씁니다.
- 여러 플러그인을 함께 쓸 때의 시너지 시나리오를 최소 1개 이상 포함합니다.
