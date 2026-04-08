# CE Checklist, /prompt Pipeline & Claude Strategies

> Section 7: CE 체크리스트
> Section 7.6: /prompt 내재화 파이프라인
> Section 7.7: Claude 4.5 프롬프트 전략
> Section 7.8: 프롬프트 엔지니어링 핵심 전략
> Section 7.9: 추가 프롬프트 스킬

---

## 7. /prompt CE (Context Engineering) 체크리스트 통합

> 모든 스폰 프롬프트에 CE 원칙을 적용합니다.

### 프롬프트 품질 체크리스트

```
[ ] U-shape 배치: 중요 지시(role, constraints)를 시작과 끝에 배치
[ ] Signal-to-noise: 불필요한 정보 제거, 핵심만 포함
[ ] Progressive disclosure: 필요한 시점에 필요한 정보만 로드
[ ] 긍정형 프레이밍: "~하지 마라" 대신 "~해라" 우선 사용
[ ] 이유(Why) 포함: 각 제약에 이유 명시 (엣지 케이스 대응)
[ ] 테이블/구조화: 산문보다 테이블 선호 (파싱 정확도)
[ ] 토큰 예산: 프롬프트 총 토큰 < 2000 (간결하게)
```

### CE 적용 예시

```xml
<!-- BAD: 산문형, 부정형, 이유 없음 -->
<constraints>
  Don't use Write. Don't modify files. Don't create teams.
</constraints>

<!-- GOOD: 구조화, 긍정형, 이유 포함 -->
<constraints>
  | 규칙 | 이유 |
  |------|------|
  | Read/Glob/Grep만 사용 | 읽기 전용 역할 (Explore) |
  | 결과는 SendMessage로 전달 | 리드가 통합 후 Write 수행 |
  | 파일 수정 없이 텍스트 반환 | Bug-2025-12-12-2056 대응 |
</constraints>
```

---

## 7.6 /prompt 내재화 파이프라인 (6 서브스텝)

> 각 팀원 spawn 프롬프트 생성 시 순서대로 실행합니다.
> `/prompt` 스킬의 핵심 로직을 내재화하되, 모델=Claude 고정, AskUserQuestion/5선택지 생략.

### Step 5-0: Existing Agent Detection (NEW)

> 기존 에이전트/스킬 파일을 감지하여 래퍼 모드로 전환합니다.
> 매칭 시 Steps 5-1 ~ 5-6을 완전히 스킵합니다.

```
Step 5-0: Existing Agent Detection

  # Phase A: registry에 source_agent 명시 확인
  IF role.source_agent exists:
    content = Read(role.source_agent)
    → Wrapper Template (Section 4.5) 적용
    → SKIP Steps 5-1 ~ 5-6
    RETURN

  # Phase B: STEP 1 인벤토리에서 자동 매칭 (STEP 3에서 사용자 확인됨)
  IF role.suggested_source exists (STEP 3에서 사용자 확인됨):
    content = Read(role.suggested_source)
    → Wrapper Template (Section 4.5) 적용
    → SKIP Steps 5-1 ~ 5-6
    RETURN

  # Phase C: 매칭 없음 → 기존 파이프라인 진행
  → Steps 5-1 ~ 5-6 정상 실행
```

**Phase A/B에서 래퍼 적용 시 CE 최소 검증:**
```
[ ] 래퍼 + 원본 합산 토큰이 모델 컨텍스트의 10% 미만?
[ ] SendMessage 프로토콜 포함?
[ ] progress_update_rule 포함?
```

### 파이프라인 개요

| # | 서브스텝 | 입력 | 출력 | 참조 |
|---|---------|------|------|------|
| 5-0 | Existing Agent Detection | role + agent_inventory | wrapper 또는 pass-through | Section 4.5 (worker-templates.md) |
| 5-1 | Purpose Detection | role 키워드 | purpose_category | /prompt 목적 감지 테이블 |
| 5-2 | Expert Priming | role + 매핑 테이블 | expert_name, expert_framework | expert-db.md 섹션 7.5 |
| 5-3 | Task Expansion | role.tasks + purpose | expanded_task_details | /prompt 명시적 요소 확장 |
| 5-4 | CE Checklist | 전체 프롬프트 | CE 최적화된 프롬프트 | 섹션 7 (위) |
| 5-5 | Claude Optimization | subagent_type | CLAUDE_BEHAVIOR_BLOCK | 아래 섹션 7.7 |
| 5-6 | Quick 3-Expert Review | 최종 프롬프트 | 자동 개선 반영 | 내부 자가 점검 |

### Step 5-1: Purpose Detection

역할 키워드에서 /prompt 목적 카테고리를 자동 감지합니다.

```
| 역할 패턴 | /prompt 목적 | 비고 |
|----------|-------------|------|
| scraper, crawler, fetch, ingest | 에이전트/자동화 | 도구 중심 |
| analyst, summarize, classify, tag | 분석/리서치 | 데이터 중심 |
| writer, content, draft, blog | 글쓰기/창작 | 출력 중심 |
| coder, developer, build, implement | 코딩/개발 | 구현 중심 |
| designer, UI, UX, layout | 코딩/개발 | 프론트엔드 |
| explorer, search, scan, read-only | 분석/리서치 | 읽기 전용 |
| reviewer, QA, test, verify | 분석/리서치 | 검증 중심 |
| lead, coordinator, orchestrate | 에이전트/자동화 | 조율 중심 |
```

### Step 5-2: Expert Domain Priming

expert-db.md의 `resolve_expert()` 알고리즘을 실행하여 전문가를 선택합니다.
결과를 `{{EXPERT_NAME}}`과 `{{EXPERT_FRAMEWORK}}`에 할당합니다.

### Step 5-3: Task Detail Expansion

`/prompt`의 "명시적 요소 확장 규칙"을 적용하여 태스크 상세를 보충합니다.
role 정의 + 팀 목적에서 자동 추론합니다.

```
| purpose_category | 확장 요소 | 확장 예시 |
|-----------------|---------|---------|
| 에이전트/자동화 | 역할, 도구, 권한, 제약, 출력형식 | "웹 스크래핑" → "URL 목록 순회, HTML→MD 변환, 에러 시 3회 재시도, JSON 출력" |
| 분석/리서치 | 범위, 기간, 비교대상, 평가기준, 출력형식 | "데이터 분석" → "최근 1년, 정량 지표 중심, 표+차트, 핵심 인사이트 5개" |
| 코딩/개발 | 언어, 프레임워크, 아키텍처, 에러처리, 테스트 | "API 개발" → "TypeScript, 함수 단위, try-catch, 유닛테스트 포함" |
| 글쓰기/창작 | 톤, 대상, 길이, 구조, 핵심메시지 | "리포트 작성" → "전문적 톤, 팀 내부용, 서론-본론-결론, 액션아이템 포함" |
```

확장 결과를 `{{EXPANDED_TASK_DETAILS}}`에 할당합니다.

### Step 5-5: Claude Optimization

subagent_type에 따라 Claude 전용 행동 블록을 삽입합니다.

**general-purpose 워커 + 카테고리 리드:**

```xml
<default_to_action>
  변경 제안보다 직접 구현을 기본으로 합니다.
  사용자 의도가 불명확하면 가장 유용한 행동을 추론하여 진행합니다.
</default_to_action>
```

**Explore 워커:**

```xml
<investigate_before_answering>
  결과를 보고하기 전 반드시 관련 파일을 읽고 확인합니다.
  확인하지 않은 정보에 대해 추측하지 않습니다.
</investigate_before_answering>
```

### Step 5-6: Quick 3-Expert Review (비대화형)

내부 자가 점검 3관점 (출력 없이 프롬프트에 자동 반영):

| # | 관점 | 점검 항목 | 조치 |
|---|------|---------|------|
| 1 | CE Expert | 토큰 < 2000, U자형 배치, 신호 대 잡음비 | 중복 제거, 구조 재배치 |
| 2 | Domain Expert | expert_name 관점으로 역할/용어 정확성 | 도메인 용어 삽입, 프레임워크 정확성 |
| 3 | Team Coordinator | 역할 충돌/중복, 도구 할당, 보고 체계 | 역할 경계 명확화, 도구 재할당 |

결과: 프롬프트에 자동 반영. 핵심 개선점 1줄 내부 로그만 생성.

---

## 7.7 Claude 4.5 프롬프트 전략 (내장)

> Claude 에이전트 프롬프트 패턴, XML 구조화 전략, 도구 사용 패턴.
> Source: `claude-4.6-prompt-strategies.md` 전체 내장.

### 모델 개요

| 모델 | 특징 | 컨텍스트 | 가격 (Input/Output) |
|------|------|----------|---------------------|
| **Opus 4.5** | 최고 지능, effort 파라미터 지원 | 200K | $5/$25 per 1M |
| **Sonnet 4.5** | 최고 코딩/에이전트 모델 | 200K, 1M (beta) | $3/$15 per 1M |
| **Haiku 4.5** | 준-프론티어 속도, 최초 Haiku thinking | 200K | $1/$5 per 1M |

### 일반 원칙

**1. 명시적 지시 제공**: Claude 4.x는 명확하고 명시적인 지시에 잘 반응. "above and beyond" 행동을 원한다면 명시적으로 요청.

```
❌ "Create an analytics dashboard"
✅ "Create an analytics dashboard. Include as many relevant features
   and interactions as possible. Go beyond the basics."
```

**2. 맥락으로 성능 향상**: 왜 그러한 행동이 중요한지 설명하면 더 나은 결과.

**3. 예시에 주의**: Claude 4.x는 예시에 매우 주의를 기울임. 예시가 원하는 행동과 일치하는지 확인.

### 커뮤니케이션 스타일

| 특성 | 설명 |
|------|------|
| **더 직접적** | 사실 기반 진행 보고, 자축적 업데이트 없음 |
| **더 대화적** | 기계적이지 않고 자연스러운 톤 |
| **덜 장황함** | 효율성을 위해 상세 요약 생략 가능 |

### 도구 사용 패턴

**적극적 행동 (기본으로 실행):**
```xml
<default_to_action>
By default, implement changes rather than only suggesting them.
If the user's intent is unclear, infer the most useful likely action
and proceed, using tools to discover any missing details instead of guessing.
</default_to_action>
```

**보수적 행동 (요청 시만 실행):**
```xml
<do_not_act_before_instructions>
Do not jump into implementation unless clearly instructed to make changes.
When the user's intent is ambiguous, default to providing information,
doing research, and providing recommendations rather than taking action.
</do_not_act_before_instructions>
```

**도구 트리거링 조절**: Opus 4.5는 시스템 프롬프트에 더 민감. 강한 언어 사용 시 오버트리거링 주의.

```
❌ "CRITICAL: You MUST use this tool when..."
✅ "Use this tool when..."
```

### 출력 포맷 제어

1. **하지 말라 대신 하라고 지시**: `"Do not use markdown"` → `"Write in flowing prose paragraphs."`
2. **XML 포맷 지시자 사용**: `<smoothly_flowing_prose_paragraphs>` 태그
3. **프롬프트 스타일과 출력 스타일 일치**

```xml
<avoid_excessive_markdown_and_bullet_points>
When writing reports or long-form content, write in clear, flowing prose.
Use paragraph breaks for organization. Reserve markdown for inline code,
code blocks, and simple headings. Avoid **bold**, *italics*, and excessive lists.
</avoid_excessive_markdown_and_bullet_points>
```

### 장기 추론 및 상태 추적

**Context Awareness (토큰 예산 추적):**
```
Your context window will be automatically compacted as it approaches
its limit. Do not stop tasks early due to token budget concerns.
Save current progress and state to memory before the context window refreshes.
Always be as persistent and autonomous as possible.
```

**Multi-Context Window 워크플로:**
1. 첫 컨텍스트 창에서 프레임워크 설정 (테스트 작성, 셋업 스크립트)
2. 구조화된 형식으로 테스트 추적
3. QoL 도구 설정 (`init.sh`)
4. 새 컨텍스트 시작 시: pwd, progress.txt, tests.json, git logs 확인
5. 컨텍스트 전체 활용 독려

### Extended Thinking

- **Sonnet/Haiku 4.5**: extended thinking 활성화 시 코딩/추론 현저히 향상
- **Opus 4.5 주의**: extended thinking 비활성화 시 "think" 단어에 민감 → "consider", "evaluate" 사용
- **Interleaved Thinking**: 도구 사용 후 반성이 필요한 작업에 효과적

### 병렬 도구 호출 최적화

```xml
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies
between the tool calls, make all of the independent tool calls in parallel.
Maximize use of parallel tool calls where possible.
However, if some tool calls depend on previous calls, do NOT call
these tools in parallel. Never use placeholders or guess missing parameters.
</use_parallel_tool_calls>
```

### 에이전트 코딩 패턴

**과잉 엔지니어링 방지:**
```xml
<avoid_overengineering>
Avoid over-engineering. Only make changes that are directly requested
or clearly necessary. Keep solutions simple and focused.
Don't add features, refactor code, or make "improvements" beyond what was asked.
The right amount of complexity is the minimum needed for the current task.
</avoid_overengineering>
```

**코드 탐색 필수:**
```xml
<investigate_before_answering>
Never speculate about code you have not opened.
If the user references a specific file, you MUST read the file before answering.
Make sure to investigate and read relevant files BEFORE answering.
Never make any claims about code before investigating unless certain.
</investigate_before_answering>
```

**하드코딩 방지:**
```xml
Write a high-quality, general-purpose solution using standard tools.
Do not create helper scripts or workarounds.
Implement a solution that works correctly for all valid inputs.
Tests verify correctness, not define the solution.
```

### 프론트엔드 미학

```xml
<frontend_aesthetics>
Avoid generic "AI slop" aesthetic. Make creative, distinctive frontends.
Focus on: Typography, Color & Theme, Motion, Backgrounds.
Avoid: Overused fonts (Inter, Roboto), clichéd color schemes, predictable layouts.
</frontend_aesthetics>
```

### XML 프롬프트 구조 가이드

**기본 XML 구조:**
```xml
<system_prompt>
  <role>역할/페르소나 정의</role>
  <core_instructions>핵심 작업 지시사항</core_instructions>
  <behavior_rules>행동 규칙 및 제약사항</behavior_rules>
  <output_format>출력 형식 지정</output_format>
</system_prompt>
```

**권장 XML 블록 패턴:**

| 태그 | 용도 | 사용 상황 |
|------|------|----------|
| `<default_to_action>` | 기본 실행 모드 | 에이전트가 적극적으로 행동해야 할 때 |
| `<do_not_act_before_instructions>` | 보수적 모드 | 정보 수집 후 확인 필요 시 |
| `<investigate_before_answering>` | 환각 방지 | 코드 분석, 파일 검토 필수 시 |
| `<use_parallel_tool_calls>` | 병렬 실행 | 독립적 도구 호출 최적화 |
| `<avoid_excessive_markdown>` | 포맷 제어 | 산문 형태 출력 필요 시 |
| `<frontend_aesthetics>` | UI 디자인 | 프론트엔드 코드 생성 시 |
| `<avoid_overengineering>` | 간결함 유지 | 과잉 구현 방지 필요 시 |

### 새로운 API 기능 (Beta)

| 기능 | 설명 |
|------|------|
| Programmatic Tool Calling | 도구를 코드 실행 컨테이너 내에서 프로그래매틱하게 호출 |
| Tool Search Tool | 수백, 수천 개의 도구를 동적으로 검색하고 로드 |
| Effort Parameter (Opus 전용) | low/medium/high로 응답 상세도 제어 |
| Memory Tool | 컨텍스트 창 외부에 정보 저장 및 검색 |
| Context Editing | 자동 도구 호출 정리로 지능적 컨텍스트 관리 |

---

## 7.8 프롬프트 엔지니어링 핵심 전략 (내장)

> `prompt-engineering-guide.md` 핵심 섹션 추출. 모델별 전략 요약 + 출력 형식 + 목적별 블록.

### Context Engineering 원칙 (프롬프트 적용)

| 원칙 | 적용 방법 |
|------|----------|
| **Progressive Disclosure** | 프롬프트를 섹션별로 구조화. 필수 정보만 포함 |
| **Attention Budget** | 중요 지시사항은 시작 또는 끝에 배치 (U자형) |
| **Signal-to-Noise** | 불필요한 서술 제거. 핵심 지시사항만 포함 |
| **Quality > Quantity** | 최소 토큰으로 최대 효과. 반복 제거 |

### 모델별 필수 XML 블록 요약

| 모델 | 필수 블록 | 비고 |
|------|----------|------|
| **GPT-5.2** | `<output_verbosity_spec>` 항상 포함 | 장황함 제어 최우선 |
| **GPT-5.2-Codex** | 최소 프롬프트, 서문 금지 | "Less is More" 원칙 |
| **Claude 4.5** | 명시적 지시, `<default_to_action>` | 명확한 방향 제시 |
| **Gemini 3** | Constraints First 배치 | 제약 조건 상단 배치 |

### GPT-5.2 핵심 XML 블록

**장황함 제어 (필수):**
```xml
<output_verbosity_spec>
- Default: 3–6 sentences or ≤5 bullets for typical answers.
- For complex tasks: 1 overview paragraph + ≤5 tagged bullets.
- Avoid long narrative paragraphs; prefer compact bullets.
</output_verbosity_spec>
```

**범위 제약 (코딩/디자인):**
```xml
<design_and_scope_constraints>
- Implement EXACTLY and ONLY what the user requests.
- No extra features, no added components, no UX embellishments.
- If any instruction is ambiguous, choose the simplest valid interpretation.
</design_and_scope_constraints>
```

**불확실성 처리 (분석/리서치):**
```xml
<uncertainty_and_ambiguity>
- If ambiguous: ask 1–3 clarifying questions, OR present 2–3 interpretations.
- Never fabricate exact figures or references when uncertain.
- Prefer "Based on the provided context…" instead of absolute claims.
</uncertainty_and_ambiguity>
```

**도구 규칙 (에이전트):**
```xml
<tool_usage_rules>
- Prefer tools over internal knowledge for fresh/user-specific data.
- Parallelize independent reads when possible.
- After write/update, restate: What changed, Where, Follow-up validation.
</tool_usage_rules>
```

**구조화된 추출 (데이터):**
```xml
<extraction_spec>
- Follow schema exactly (no extra fields).
- If a field is not present, set to null rather than guessing.
- Re-scan source for missed fields before returning.
</extraction_spec>
```

### 목적별 추가 블록 (공통)

**코딩/개발:**
```xml
<coding_standards>
  - Follow existing project patterns
  - Include type annotations where applicable
  - Write testable, modular code
  - Handle errors appropriately
</coding_standards>
```

**글쓰기/창작:**
```xml
<writing_style>
  - Tone: {formal/casual/technical/conversational}
  - Voice: {active/passive}
  - Target audience: {audience description}
  - Length: {word count or paragraph count}
</writing_style>
```

**분석/리서치:**
```xml
<analysis_requirements>
  - Cite sources when available
  - Distinguish facts from interpretations
  - Acknowledge limitations and uncertainties
  - Provide actionable insights
</analysis_requirements>
```

**에이전트/자동화:**
```xml
<agent_behavior>
  - Take action by default
  - Ask only when genuinely blocked
  - Complete tasks fully before stopping
  - Use tools efficiently
</agent_behavior>
```

### 상세도별 출력 지침

| 레벨 | 분량 | 적용 |
|------|------|------|
| 간결 (minimal) | 3-5문장, 글머리 기호 | 단순 질답 |
| 보통 (moderate) | 1-2 문단 | 일반 작업 |
| 상세 (detailed) | 구조화된 헤더 + 예시 | 복잡한 분석 |
| 가변 (adaptive) | 복잡도에 비례 | 기본 설정 |

### 컨텍스트 저하 방지

| 현상 | 대응책 |
|------|--------|
| **Lost-in-Middle** | 중요 정보를 시작/끝에 배치 |
| **Context Poisoning** | 도구 출력 검증, 명시적 정정 |
| **Context Distraction** | 관련성 필터링, 불필요한 정보 제외 |

**모델별 저하 임계값:**

| 모델 | 저하 시작 | 심각한 저하 |
|------|----------|-------------|
| GPT-5.2 | ~64K | ~200K |
| Claude 4.5 Opus | ~100K | ~180K |
| Claude 4.5 Sonnet | ~80K | ~150K |
| Gemini 3 Pro | ~500K | ~800K |

### 품질 체크리스트

```
□ 역할/페르소나가 명확히 정의됨
□ 핵심 지시사항이 포함됨
□ 출력 형식이 명시됨
□ 불필요한 서술이 제거됨
□ 중요 정보가 시작/끝에 배치됨
□ 모델별 필수 블록이 포함됨
□ 금지어 6개가 제거됨
```

---

## 7.9 추가 프롬프트 스킬 (선택적 외부 설치)

> **고급 프롬프트 스킬**: 이미지 생성, 리서치/팩트체크, Gemini 3, GPT-5.2 상세 전략이 필요한 경우:
>
> ```
> npx skills find "prompt engineering"
> ```
>
> 또는 https://skills.sh
>
> **포함 스킬:**
>
> | 스킬 | 내용 |
> |------|------|
> | `image-prompt-guide.md` | 이미지 생성 프롬프트 (gpt-image, Nano Banana) |
> | `research-prompt-guide.md` | 팩트체크/리서치 프롬프트 (IFCN 원칙) |
> | `gpt-5.4-prompt-enhancement.md` | GPT-5.2 전용 XML 패턴 상세 |
> | `slide-prompt-guide.md` | 슬라이드/PPT 프롬프트 가이드 |
>
> 위 스킬은 `/prompt` 커맨드에서 사용되며, `/tofu-at`는 §7.5-7.8의 내장 콘텐츠만으로 작동합니다.
