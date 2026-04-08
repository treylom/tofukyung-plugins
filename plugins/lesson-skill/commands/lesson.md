---
description: 인터랙티브 강의 진행 — /lesson {과정명} {주차}
allowedTools: Read, Write, Bash, Glob, Grep, AskUserQuestion
---

# /lesson — 인터랙티브 강의 시작

$ARGUMENTS

## 목적

`/lesson`은 수강생과 1:1 인터랙티브 강의를 진행하는 진입점이다.
수강생 프로필 기반 적응형 안내, 교시별 실습 진행, 마무리 저장까지 전 과정을 지원한다.

## 인자 파싱

입력에서 아래 두 가지를 추출한다.

| 인자 | 변수 | 예시 |
|------|------|------|
| 과정명 (첫 번째 토큰) | `COURSE_ID` | `MW4`, `CC101`, `AI-Intro` |
| 주차 (두 번째 토큰) | `WEEK_NUM` | `1`, `2`, `week1` |

파싱 예시:
- `/lesson MW4 1` → COURSE_ID=MW4, WEEK_NUM=1
- `/lesson CC101 week2` → COURSE_ID=CC101, WEEK_NUM=2
- `/lesson AI-Intro 3` → COURSE_ID=AI-Intro, WEEK_NUM=3

## 실행

인자 파싱이 완료되면 메인 스킬을 호출한다.

```
Skill("lesson", args: "COURSE_ID={COURSE_ID} WEEK_NUM={WEEK_NUM}")
```

## 사용 예시

```
/lesson MW4 1          → 성우하이텍 마스터워크샵 4 1주차
/lesson MW5 2          → 마스터워크샵 5 2주차
/lesson CC101 week1    → CC101 1주차
/lesson AI-Intro 1     → AI 입문 과정 1주차
```

## 참고

커리큘럼 파일은 `references/{COURSE_ID}/{WEEK_NUM}.md` 위치에 있어야 한다.
없으면 강사에게 파일 준비를 요청한다.

수강생 프로필은 `.lesson-memory/{이름}-{과정ID}.json`에 저장된다.
첫 수업이면 인터뷰를 통해 프로필을 생성한다.
