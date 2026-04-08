# Writing Assistant — Claude Code Skill

글쓰기 코치 스킬. 페르소나 깎기 루프 + 6장르 가이드 + autoresearch 피드백.

## 핵심 기능

- **6장르 지원**: 에세이, 칼럼, 기사, 블로그, 뉴스레터, 보고서
- **10차원 문체 분석**: Style Card 생성 → 피드백 → 자동 개선
- **7단계 글쓰기 루프**: 구체화 → 개요 → 승인 → 초안 → 퇴고 → 검토 → 최종
- **autoresearch 피드백**: 사용자 피드백을 keep/discard 판정 → Style Card 자동 업데이트
- **GPTs 호환**: 동일 Style Card 형식으로 GPTs와 Claude Code 간 양방향 사용

## 파일 구조

```
writing-assistant/
├── commands/
│   └── write.md              # /write 커맨드
├── skills/
│   ├── writing-assistant.md  # 메인 스킬
│   └── references/
│       ├── genre-playbooks.md    # 6장르 가이드
│       ├── style-system.md       # Style Card + 페르소나 깎기 루프
│       ├── review-lenses.md      # 4렌즈 검토
│       └── prompt-templates.md   # 사용자용 템플릿
├── gpts-output/              # GPTs 최적화 파일 (별도 업로드용)
│   ├── 00_instructions_v2.md
│   ├── 04_style_reference_ingestion_v2.md
│   └── 06_outline_draft_revise_loop_v2.md
├── CLAUDE.md
└── README.md
```

## 설치

CLAUDE.md 참조.

## 전문가 기반

- William Zinsser: 명료성, 간결함
- Ann Handley: 실용성, 리듬, 독자 참여
- Donald Schon: 반성적 개선 루프

## 라이선스

MIT
