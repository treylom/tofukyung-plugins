---
description: 글쓰기 도우미 — 에세이/칼럼/기사/블로그/뉴스레터/보고서. "글 써줘", "에세이 써줘" 등에 사용.
allowedTools: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch, Agent, Skill
---

# /write — 글쓰기 도우미

$ARGUMENTS

## 목적

`/write`는 사용자의 요청을 장르·모드·파일 경로 중심으로 정리한 뒤 `Skill("writing-assistant")`로 넘기는 진입점이다.

## 인자 파싱

입력 문자열에서 아래 3가지를 우선 추출한다.

### 1. 장르

다음 키워드를 장르로 매핑한다.

| 입력 키워드 | genre |
|---|---|
| 에세이, essay | essay |
| 칼럼, column | column |
| 기사, article | article |
| 블로그, blog | blog |
| 뉴스레터, newsletter | newsletter |
| 보고서, report | report |

장르가 없으면 비워 두고, 메인 스킬이 첫 질문으로 받게 둔다.

### 2. 모드

다음 키워드를 모드로 매핑한다.

| 입력 키워드 | mode |
|---|---|
| 주제, 방향, 아이디어, ideation | ideation |
| 개요, outline | outline |
| 초안, draft | draft |
| 퇴고, 수정, revise | revise |
| 재구성, 구조, restructure | restructure |
| 문체, style, style-match | style_match |
| 페르소나, 스타일카드, style-card, persona | persona_carve |
| 리서치, research | research |
| 팩트체크, 검증, factcheck | factcheck |
| 변환, 플랫폼, adapt, format | adapt_format |

모드가 없으면 메인 스킬이 현재 단계에 맞게 라우팅한다.

### 3. 파일 경로

아래 패턴을 파일 경로 후보로 본다.
- 따옴표로 감싼 경로
- `.md`, `.txt`, `.docx`, `.pdf`로 끝나는 토큰
- 상대/절대 경로처럼 보이는 토큰

파일 경로가 있으면 `source_path=`로 넘긴다.

## 정규화 규칙

인자 파싱 후 아래 형식으로 정리한다.

```text
genre=<genre>|mode=<mode>|source_path=<path>|request=<freeform request>
```

비어 있는 값은 생략한다.

예시:
- `에세이 개요 기후불안에 대한 개인 경험 글`
  → `genre=essay|mode=outline|request=기후불안에 대한 개인 경험 글`
- `퇴고 "/tmp/draft.md" 문장을 더 짧게`
  → `mode=revise|source_path=/tmp/draft.md|request=문장을 더 짧게`
- `스타일카드 만들어줘 내 글 샘플은 posts/a.md`
  → `mode=persona_carve|source_path=posts/a.md|request=스타일카드 만들어줘 내 글 샘플은`

## 실행

정규화가 끝나면 메인 스킬을 호출한다.

```text
Skill("writing-assistant", args: "<normalized arguments>")
```

## 실행 규칙

- 사용자가 파일을 줬다면 메인 스킬이 먼저 읽고 판단한다.
- 장르가 없으면 메인 스킬의 첫 질문 규칙을 따른다.
- 사용자가 "바로 써줘"라고 해도 승인 게이트를 무시하지 않는다. 다만 메인 스킬이 최소 질문 후 빠르게 진행한다.
- 문체 요청이 있으면 `.style-card.md` 자동 감지를 메인 스킬에 맡긴다.

## 사용 예시

```text
/write 에세이 주제 잡아줘
/write 칼럼 개요 AI 에이전트 협업의 한계와 가능성
/write 초안 "/home/tofu/draft.md" 논리만 다듬어줘
/write 스타일카드 만들어줘 "/home/tofu/samples/post1.md"
/write 보고서 팩트체크 "/home/tofu/report.md"
/write 블로그 플랫폼 변환 뉴스레터 초안을 블로그 글로 바꿔줘
```
