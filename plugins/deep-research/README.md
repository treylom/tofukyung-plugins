# Deep Research — Claude Code Skill

멀티소스 딥리서치 엔진. 소스 검증 + 교차검증 + 인라인 인용 보고서 자동 생성.

## 핵심 기능

- **7-Phase 파이프라인**: Scoping - Planning - Collection - Triangulation - Synthesis - QA - Output
- **소스 품질 등급**: A-E 등급 시스템, IFCN 원칙 기반
- **교차검증**: 핵심 주장별 2+ 독립 소스 확인
- **Chain-of-Verification**: 할루시네이션 탐지 + 팩트체크
- **세션 관리**: 중단/재개 지원, 진행 상태 추적
- **다중 출력**: 마크다운 보고서, Obsidian 노트, 정적 HTML

## 파일 구조

```
deep-research/
├── commands/
│   └── deep-research.md              # /deep-research 커맨드
├── skills/
│   ├── deep-research-pipeline.md     # 7-Phase 파이프라인 엔진
│   └── deep-research-source-quality.md  # 소스 품질 등급 시스템
├── agents/
│   └── deep-researcher.md            # Agent Teams 워커 에이전트
├── CLAUDE.md
└── README.md
```

## 설치

CLAUDE.md 참조.

## 사용 예시

| 모드 | 명령어 |
|------|--------|
| 인터랙티브 | `/deep-research` |
| 직접 지정 | `/deep-research AI 에이전트 메모리 아키텍처 2026 트렌드` |
| 세션 재개 | `/deep-research resume {session-id}` |
| 상태 확인 | `/deep-research status` |
| 쿼리 빌더 | `/deep-research query` |

## 리서치 깊이별 설정

| 깊이 | 에이전트 수 | 소스 목표 | 교차검증 기준 |
|------|-----------|----------|-------------|
| 빠른개요 | 3 | 5-10 | 50%+ |
| 표준 | 6 | 15-25 | 70%+ |
| 딥다이브 | 9 | 30+ | 80%+ |

## 선택 의존성

단독으로 사용할 수 있지만, 다음 플러그인과 함께 쓰면 더 효과적입니다:

- [knowledge-manager](https://github.com/treylom/knowledge-manager): 콘텐츠 추출 + Obsidian 저장
- [tofu-at](https://github.com/treylom/tofu-at): Agent Teams 병렬 수집
- [prompt-engineering-skills](https://github.com/treylom/prompt-engineering-skills): 워커 프롬프트 최적화

## 라이선스

MIT
