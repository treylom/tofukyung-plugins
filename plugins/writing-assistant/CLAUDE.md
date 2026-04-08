# Writing Assistant

## 설치

```bash
# 1. 스킬 복사
cp -r skills/ ~/.claude/skills/
cp -r commands/ ~/.claude/commands/

# 2. (선택) /resume으로 스킬 로드
```

## 사용법

```
/write 에세이 — AI가 바꾼 글쓰기 습관
/write 블로그 — 검색 의도: "AI 글쓰기 도구 추천"
/write 칼럼 — 핵심 주장: "AI는 사고력을 외주화한다"
/write 보고서 — 파일 참고: report-data.xlsx
/write persona — 내 문체 분석 (Style Card 생성)
```

## Style Card

`.style-card.md` 파일이 프로젝트 루트에 있으면 자동 로드됩니다.
없으면 글 샘플 2-5개를 요청하여 생성합니다.

GPTs에서 내보낸 Style Card도 그대로 사용 가능합니다 (동일 형식).
