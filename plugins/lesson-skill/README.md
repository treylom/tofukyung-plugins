# lesson-skill

범용 인터랙티브 강의 엔진 — Claude Code 스킬

## 개요

`/lesson {과정명} {주차}` 하나로 수강생 1:1 강의를 진행하는 Claude Code 스킬이다.
수강생 프로필 기반 적응형 안내, 교시별 실습, "감자재배법" 페다고지를 내장한다.

## 빠른 시작

```bash
# 스킬 설치
cp -r skills/lesson ~/.claude/skills/lesson
cp commands/lesson.md ~/.claude/commands/lesson.md

# 사용
/lesson MW4 1
/lesson CC101 week1
```

## 디렉토리 구조

```
lesson-skill/
├── .claude-plugin/
│   └── plugin.json             # 플러그인 메타데이터
├── skills/lesson/
│   ├── SKILL.md                # 엔트리포인트 (500줄 이하)
│   └── references/
│       ├── lesson-engine.md    # 3-Phase 진행 엔진
│       ├── memory-schema.md    # 수강생 메모리 스키마
│       └── pedagogy.md         # 감자재배법 원칙
├── commands/
│   └── lesson.md               # /lesson 슬래시 커맨드
└── README.md
```

## 커리큘럼 파일 준비

각 과정의 주차별 커리큘럼 파일을 아래 위치에 준비해야 한다.

```
references/{COURSE_ID}/{WEEK_NUM}.md
```

예시:
```
references/MW4/1.md    → MW4 1주차 커리큘럼
references/CC101/2.md  → CC101 2주차 커리큘럼
```

### 커리큘럼 파일 형식 (권장)

```markdown
# {과정명} {주차} — {주제}

## 학습 목표
- 목표 1
- 목표 2

## 교시 구성
### 1교시: {교시 제목} (소요: N분)
...

### 2교시: {교시 제목} (소요: N분)
...

## 실습 목록
1. 실습 1: {설명}
2. 실습 2: {설명}

## 과제 (선택)
...
```

## 수강생 메모리

수강생 프로필은 `.lesson-memory/` 폴더에 자동 저장된다.

```
.lesson-memory/
├── 홍길동-MW4.json
└── 김영희-CC101.json
```

첫 수업에서 자동 인터뷰 후 생성된다.

## 감자재배법 원칙

1. **가이드-but-대신해주지않기**: 명령어 제시, 실행은 수강생이
2. **숙련도 적응**: beginner / intermediate / advanced 자동 조정
3. **4단계 자립**: 쓰기(MW4) → 규칙(MW5) → 도구(MW6) → 통합(MW7)

## 권장 모델

Sonnet 4.6, medium effort (수강생 비용 최적화)
