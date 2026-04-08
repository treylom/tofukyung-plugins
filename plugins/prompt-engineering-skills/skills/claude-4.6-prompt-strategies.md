# Claude 프롬프트 전략

> **Version**: 2.0.0 | **Updated**: 2026-03-08
> **Source**: Anthropic 공식 문서 (platform.claude.com)
> **Covers**: Opus 4.6, Sonnet 4.6, Opus 4.5, Sonnet 4.5, Haiku 4.5

Claude 4.5/4.6 모델군은 **정밀한 지시 따르기**를 위해 훈련되었습니다. 이전 세대보다 더 명시적인 방향 제시가 필요합니다.

---

## Part 1: 모델 개요

### 1.1 Claude 4.6 (최신)

| 모델 | Model ID | 특징 | 컨텍스트 | Max Output | 가격 (Input/Output) |
|------|----------|------|----------|------------|---------------------|
| **Opus 4.6** | `claude-opus-4-6` | 최고 지능, Adaptive Thinking 자동, 128K output | 200K | 128K | $5/$25 per 1M |
| **Sonnet 4.6** | `claude-sonnet-4-6` | 최고 코딩/에이전트, Fast Mode (2.5x) | 200K, 1M (beta) | 128K | $3/$15 per 1M |

**4.6 핵심 변경사항:**
- **Adaptive Thinking**: `thinking: {type: "adaptive"}` — 모델이 자율적으로 사고 깊이 결정
- **128K Max Output**: 기존 대비 대폭 증가 (beta: `anthropic-beta: output-128k-2025-02-19`)
- **1M Context (beta)**: Sonnet 4.6에서 100만 토큰 컨텍스트 지원
- **Prefill 제거**: 마지막 assistant turn 프리필 → 400 에러 (Breaking Change)
- **Effort Parameter**: `output_config: {effort: "low"|"medium"|"high"|"max"}`
- **Interleaved Thinking**: Opus 4.6에서 자동 활성화 (beta 헤더 불필요)
- **Fast Mode**: 동일 모델, 2.5배 속도

### 1.2 Claude 4.5

| 모델 | Model ID | 특징 | 컨텍스트 | 가격 (Input/Output) |
|------|----------|------|----------|---------------------|
| **Opus 4.5** | `claude-opus-4-5-20250929` | effort 파라미터 지원 | 200K | $15/$75 per 1M |
| **Sonnet 4.5** | `claude-sonnet-4-5-20250929` | 코딩/에이전트 강점 | 200K, 1M (beta) | $3/$15 per 1M |
| **Haiku 4.5** | `claude-haiku-4-5-20251001` | 준-프론티어 속도, 최초 Haiku thinking | 200K | $1/$5 per 1M |

---

## Part 2: 일반 원칙

### 2.1 명시적 지시 제공

Claude 4.x는 명확하고 명시적인 지시에 잘 반응합니다. 이전 모델의 "above and beyond" 행동을 원한다면 명시적으로 요청해야 합니다.

**구체적 예시:**
```
❌ "Create an analytics dashboard"
✅ "Create an analytics dashboard. Include as many relevant features
   and interactions as possible. Go beyond the basics to create a
   fully-featured implementation."
```

### 2.2 맥락으로 성능 향상

왜 그러한 행동이 중요한지 설명하면 더 나은 결과를 얻습니다.

```
Instead of: "Use plain text formatting"
Try: "Use plain text formatting because markdown renders poorly in
     our legacy terminal system. This ensures readability for all users."
```

### 2.3 예시와 세부사항에 주의

Claude 4.x는 예시에 매우 주의를 기울입니다. 예시가 원하는 행동과 일치하는지 확인하세요.

---

## Part 3: 커뮤니케이션 스타일

Claude 4.5는 이전 모델보다 간결하고 자연스러운 커뮤니케이션 스타일:

| 특성 | 설명 |
|------|------|
| **더 직접적** | 사실 기반 진행 보고, 자축적 업데이트 없음 |
| **더 대화적** | 기계적이지 않고 자연스러운 톤 |
| **덜 장황함** | 효율성을 위해 상세 요약 생략 가능 |

### 장황함 조절

도구 호출 후 업데이트를 원한다면:
```
After completing a task that involves tool use, provide a quick
summary of the work you've done.
```

---

## Part 4: 도구 사용 패턴

### 4.1 명시적 행동 요청

"can you suggest some changes"라고 하면 변경 대신 제안만 할 수 있습니다.

```
❌ "Can you suggest some changes to improve performance?"
✅ "Analyze the code and implement performance improvements.
   Make the changes directly."
```

### 4.2 기본 행동 설정

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

### 4.3 도구 트리거링 조절

Opus 4.5는 시스템 프롬프트에 더 민감합니다. 과거에 언더트리거링 방지를 위해 강한 언어를 사용했다면 오버트리거링이 발생할 수 있습니다.

```
❌ "CRITICAL: You MUST use this tool when..."
✅ "Use this tool when..."
```

---

## Part 4.5: 프리필 제거 (4.6 Breaking Change)

> **CRITICAL**: Claude 4.6에서는 마지막 assistant turn에 프리필(prefill)을 넣으면 **400 에러**가 발생합니다.

### 프리필 마이그레이션 가이드

| 기존 용도 (4.5 프리필) | 4.6 대체 방법 |
|----------------------|--------------|
| JSON 출력 강제 (`{`) | `output_config.format`으로 JSON 스키마 지정 (Structured Outputs) |
| 서문/인사말 건너뛰기 | 시스템 프롬프트에 직접 지시: "인사말 없이 바로 본론" |
| 이어쓰기/계속 생성 | user turn에 "이전 응답에 이어서 계속" 지시 |
| 특정 형식 시작 | 시스템 프롬프트에 출력 형식 명시 |

```python
# 4.5 (프리필 사용 — 4.6에서 에러)
messages = [
    {"role": "user", "content": "분석해줘"},
    {"role": "assistant", "content": "{"}  # ❌ 4.6에서 400 에러
]

# 4.6 (Structured Outputs 사용)
response = client.messages.create(
    model="claude-opus-4-6",
    messages=[{"role": "user", "content": "분석해줘"}],
    output_config={
        "format": {
            "type": "json_schema",
            "json_schema": { ... }
        }
    }
)
```

---

## Part 4.6: Over-prompting 경고 (4.6 신규)

> **주의**: Claude 4.6은 시스템 프롬프트에 **더 민감**합니다. 과도한 프롬프트(over-prompting)는 역효과를 낳습니다.

### 문제 패턴

| 패턴 | 증상 | 해결 |
|------|------|------|
| 과도한 강조 (`CRITICAL`, `MUST`, `NEVER` 남발) | 오버트리거링, 불필요한 도구 호출 | 평이한 언어로 변경 |
| 동일 규칙 반복 서술 | 혼란, 상충 해석 | 한 번만 명확하게 |
| 세부사항 과다 | 핵심 지시 매몰 | 핵심만 남기고 정리 |

```
❌ "CRITICAL: You MUST ALWAYS use this tool when ANY user mentions..."
✅ "Use this tool when the user asks about..."

❌ "NEVER EVER under ANY circumstances forget to..."
✅ "Always include..."
```

**핵심 원칙**: 4.6에서는 **간결하고 명확한 지시**가 길고 강조된 지시보다 더 효과적입니다.

---

## Part 5: 출력 포맷 제어

### 5.1 효과적인 방법들

1. **하지 말라 대신 하라고 지시**
```
❌ "Do not use markdown in your response"
✅ "Your response should be composed of smoothly flowing prose paragraphs."
```

2. **XML 포맷 지시자 사용**
```
"Write the prose sections of your response in <smoothly_flowing_prose_paragraphs> tags."
```

3. **프롬프트 스타일과 출력 스타일 일치**
마크다운을 줄이려면 프롬프트에서도 마크다운을 줄이세요.

4. **마크다운 최소화 상세 프롬프트**

```xml
<avoid_excessive_markdown_and_bullet_points>
When writing reports, documents, or long-form content, write in clear,
flowing prose using complete paragraphs. Use standard paragraph breaks
for organization and reserve markdown primarily for `inline code`,
code blocks, and simple headings.

Avoid using **bold** and *italics*. DO NOT use ordered lists or
unordered lists unless:
a) presenting truly discrete items where a list format is best, or
b) the user explicitly requests a list

Using prose instead of excessive formatting will improve user satisfaction.
NEVER output a series of overly short bullet points.
</avoid_excessive_markdown_and_bullet_points>
```

---

## Part 6: 장기 추론 및 상태 추적

Claude 4.5는 **뛰어난 상태 추적 능력**으로 장기 추론에 탁월합니다.

### 6.1 Context Awareness

Claude 4.5는 대화 중 남은 컨텍스트 창(토큰 예산)을 추적할 수 있습니다.

**컨텍스트 제한 관리:**
```
Your context window will be automatically compacted as it approaches
its limit, allowing you to continue working indefinitely from where you
left off. Therefore, do not stop tasks early due to token budget concerns.

As you approach your token budget limit, save your current progress
and state to memory before the context window refreshes.

Always be as persistent and autonomous as possible and complete tasks
fully, even if the end of your budget is approaching.
```

### 6.2 Multi-Context Window 워크플로

1. **첫 컨텍스트 창에서 프레임워크 설정**
   - 테스트 작성, 셋업 스크립트 생성
   - 이후 컨텍스트 창에서 todo-list 반복

2. **구조화된 형식으로 테스트 추적**
   ```
   It is unacceptable to remove or edit tests because this could
   lead to missing or buggy functionality.
   ```

3. **QoL 도구 설정**
   - `init.sh` 같은 셋업 스크립트로 서버, 테스트, 린터 실행

4. **새로운 컨텍스트 시작 시**
   ```
   - Call pwd; you can only read and write files in this directory.
   - Review progress.txt, tests.json, and the git logs.
   - Manually run through a fundamental integration test before implementing.
   ```

5. **컨텍스트 전체 활용 독려**
   ```
   This is a very long task, so plan your work clearly. It's encouraged
   to spend your entire output context working on the task - just make
   sure you don't run out of context with significant uncommitted work.
   ```

### 6.3 상태 관리 Best Practices

| 방법 | 용도 |
|------|------|
| **JSON 등 구조화 형식** | 테스트 결과, 작업 상태 등 |
| **비구조화 텍스트** | 일반 진행 노트 |
| **Git** | 완료 작업 로그 및 복원 가능한 체크포인트 |
| **점진적 진행 강조** | 진행 상황 추적 및 점진적 작업 집중 |

---

## Part 7: Extended Thinking & Adaptive Thinking

### 7.1 Extended Thinking (4.5)

**Sonnet 4.5와 Haiku 4.5**는 extended thinking 활성화 시 코딩/추론 작업에서 **현저히 향상**됩니다.

기본적으로 비활성화되어 있지만, 복잡한 작업에서는 활성화 권장:
- 복잡한 문제 해결
- 코딩 작업
- 멀티스텝 추론

```json
// 4.5 Extended Thinking (기존 방식)
{
  "thinking": {
    "type": "enabled",
    "budget_tokens": 10000
  }
}
```

> **Deprecated**: `budget_tokens`는 4.6에서 deprecated됨. 4.6에서는 Adaptive Thinking 사용 권장.

### 7.2 Adaptive Thinking (4.6 신규)

**Claude 4.6**에서는 모델이 **자율적으로 사고 깊이를 결정**하는 Adaptive Thinking이 도입되었습니다.

```json
// 4.6 Adaptive Thinking (권장)
{
  "thinking": {
    "type": "adaptive"
  }
}
```

| 방식 | 모델 | 설명 |
|------|------|------|
| `type: "enabled"` + `budget_tokens` | 4.5 | 수동으로 사고 토큰 예산 설정 |
| `type: "adaptive"` | 4.6 | 모델이 작업 복잡도에 따라 자동 결정 |

**Adaptive Thinking 장점:**
- 간단한 질문 → 짧은 사고 (토큰 절약)
- 복잡한 작업 → 깊은 사고 (정확도 향상)
- `budget_tokens` 수동 튜닝 불필요

### 7.3 Effort Parameter (4.6 신규)

Adaptive Thinking과 함께 사용하여 **응답 상세도**를 제어합니다.

```json
{
  "thinking": { "type": "adaptive" },
  "output_config": {
    "effort": "high"
  }
}
```

| Effort | 용도 | 토큰 효율 |
|--------|------|----------|
| `low` | 간단한 분류, 예/아니오 | 최고 |
| `medium` | 일반적인 대화 | 균형 |
| `high` | 상세 분석, 코딩 | 높은 품질 |
| `max` | 최고 난이도 추론 (Opus 4.6 전용) | 최대 품질 |

### 7.4 Thinking Sensitivity (Opus 4.5)

Extended thinking 비활성화 시, Opus 4.5는 "think" 단어에 특히 민감합니다.

```
❌ "think about this problem"
✅ "consider this problem" / "evaluate this approach" / "believe"
```

### 7.5 Interleaved Thinking 활용

도구 사용 후 반성이 필요한 작업에 효과적:

```
After receiving tool results, carefully reflect on their quality
and determine optimal next steps before proceeding. Use your thinking
to plan and iterate based on this new information.
```

**4.6 변경사항:**
- **Opus 4.6**: Interleaved thinking 자동 활성화 (beta 헤더 `interleaved-thinking-2025-05-14` 불필요)
- **Sonnet 4.6**: 기존과 동일하게 beta 헤더로 활성화 가능

---

## Part 8: 병렬 도구 호출 최적화

Claude 4.x, 특히 Sonnet 4.5는 병렬 도구 실행에 적극적입니다:
- 리서치 중 여러 추측적 검색 동시 실행
- 여러 파일 동시 읽기
- bash 명령 병렬 실행

### 8.1 최대 병렬 효율성

```xml
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies
between the tool calls, make all of the independent tool calls in parallel.

For example, when reading 3 files, run 3 tool calls in parallel.
Maximize use of parallel tool calls where possible.

However, if some tool calls depend on previous calls, do NOT call
these tools in parallel. Never use placeholders or guess missing parameters.
</use_parallel_tool_calls>
```

### 8.2 병렬 실행 감소

```
Execute operations sequentially with brief pauses between each step
to ensure stability.
```

---

## Part 9: 에이전트 코딩 시 주의사항

### 9.1 과잉 엔지니어링 방지 (특히 Opus 4.5)

```xml
Avoid over-engineering. Only make changes that are directly requested
or clearly necessary. Keep solutions simple and focused.

Don't add features, refactor code, or make "improvements" beyond what
was asked. A bug fix doesn't need surrounding code cleaned up.

Don't add error handling, fallbacks, or validation for scenarios that
can't happen. Trust internal code and framework guarantees.

Don't create helpers, utilities, or abstractions for one-time operations.
The right amount of complexity is the minimum needed for the current task.
```

### 9.2 코드 탐색 독려

```xml
ALWAYS read and understand relevant files before proposing code edits.
Do not speculate about code you have not inspected.

If the user references a specific file/path, you MUST open and inspect
it before explaining or proposing fixes.

Be rigorous and persistent in searching code for key facts.
Thoroughly review the style, conventions, and abstractions of the
codebase before implementing new features.
```

### 9.3 환각 최소화

```xml
<investigate_before_answering>
Never speculate about code you have not opened.
If the user references a specific file, you MUST read the file before answering.
Make sure to investigate and read relevant files BEFORE answering.
Never make any claims about code before investigating unless certain.
</investigate_before_answering>
```

### 9.4 하드코딩 및 테스트 집중 방지

```xml
Please write a high-quality, general-purpose solution using standard tools.
Do not create helper scripts or workarounds.

Implement a solution that works correctly for all valid inputs,
not just the test cases. Do not hard-code values.

Tests are there to verify correctness, not to define the solution.
If tests are incorrect, inform me rather than working around them.
```

---

## Part 10: 프론트엔드 디자인 (Opus 4.5)

"AI slop" 미학을 피하고 창의적인 프론트엔드 생성:

```xml
<frontend_aesthetics>
Avoid generic "AI slop" aesthetic. Make creative, distinctive frontends.

Focus on:
- Typography: Choose unique, beautiful fonts. Avoid Inter, Arial, Roboto.
- Color & Theme: Commit to a cohesive aesthetic. Use CSS variables.
- Motion: Use animations for effects. Focus on page load orchestration.
- Backgrounds: Create atmosphere with gradients, patterns, effects.

Avoid:
- Overused font families (Inter, Roboto, Arial, system fonts)
- Clichéd color schemes (purple gradients on white)
- Predictable layouts and cookie-cutter design

Think outside the box! Vary between light/dark themes, different fonts.
</frontend_aesthetics>
```

---

## Part 11: API 기능

### 11.1 128K Max Output (4.6)
기존 대비 대폭 증가한 출력 한도.
- Beta 헤더 필요: `anthropic-beta: output-128k-2025-02-19`
- 장문 코드 생성, 대용량 데이터 처리에 적합

### 11.2 1M Context Window (4.6 Beta)
Sonnet 4.6에서 100만 토큰 컨텍스트 지원.
- 대규모 코드베이스 전체 분석
- 장편 문서 처리

### 11.3 Compaction API (4.6)
긴 대화를 자동으로 압축하여 컨텍스트 효율성 향상.
- 무한 대화 지속 가능
- 핵심 정보 보존하며 토큰 절약

### 11.4 Effort Parameter (4.5 Opus → 4.6 전체)
응답 상세도와 토큰 효율성 사이의 트레이드오프 제어.
- `low`: 토큰 효율적 (간단한 분류)
- `medium`: 균형 (일반 대화)
- `high`: 상세 분석, 코딩
- `max`: 최대 품질 (Opus 4.6 전용)

### 11.5 Programmatic Tool Calling
도구를 코드 실행 컨테이너 내에서 프로그래매틱하게 호출 가능.
- 레이턴시 감소
- 토큰 효율성 향상

### 11.6 Tool Search Tool
수백, 수천 개의 도구를 동적으로 검색하고 로드.
- Regex 또는 BM25 검색 지원
- 10-20K 토큰 절약

### 11.7 Memory Tool
컨텍스트 창 외부에 정보 저장 및 검색.

### 11.8 Fast Mode (4.6)
동일 모델에서 2.5배 빠른 출력 속도.
- 모델 전환 없음 (같은 Opus 4.6)
- 빠른 반복 작업에 적합

---

## Part 12: XML 프롬프트 구조 가이드 (프롬프트 생성용)

> **용도**: 코딩, 에이전트, 분석, 팩트체크 프롬프트 생성 시 참조

### 12.1 기본 XML 구조

```xml
<system_prompt>
  <role>역할/페르소나 정의</role>

  <core_instructions>
    핵심 작업 지시사항
  </core_instructions>

  <behavior_rules>
    행동 규칙 및 제약사항
  </behavior_rules>

  <output_format>
    출력 형식 지정
  </output_format>
</system_prompt>
```

### 12.2 권장 XML 블록 패턴

| 태그 | 용도 | 사용 상황 |
|------|------|----------|
| `<default_to_action>` | 기본 실행 모드 | 에이전트가 적극적으로 행동해야 할 때 |
| `<do_not_act_before_instructions>` | 보수적 모드 | 정보 수집 후 확인 필요 시 |
| `<investigate_before_answering>` | 환각 방지 | 코드 분석, 파일 검토 필수 시 |
| `<use_parallel_tool_calls>` | 병렬 실행 | 독립적 도구 호출 최적화 |
| `<avoid_excessive_markdown>` | 포맷 제어 | 산문 형태 출력 필요 시 |
| `<frontend_aesthetics>` | UI 디자인 | 프론트엔드 코드 생성 시 |
| `<avoid_overengineering>` | 간결함 유지 | 과잉 구현 방지 필요 시 |

### 12.3 코딩/에이전트 XML 예시

```xml
<system_prompt>
  <role>전문 소프트웨어 개발자</role>

  <core_instructions>
    사용자 요청에 따라 코드를 작성하고 개선합니다.
  </core_instructions>

  <investigate_before_answering>
    코드를 수정하기 전 반드시 관련 파일을 읽고 이해합니다.
    확인하지 않은 코드에 대해 추측하지 않습니다.
  </investigate_before_answering>

  <default_to_action>
    변경 제안보다 직접 구현을 기본으로 합니다.
    사용자 의도가 불명확하면 가장 유용한 행동을 추론하여 진행합니다.
  </default_to_action>

  <output_format>
    수정된 코드를 코드블록으로 출력합니다.
    변경 사항을 간략히 요약합니다.
  </output_format>
</system_prompt>
```

---

## 부록: 핵심 XML 블록 전체 목록

### 적극적 행동 설정
```xml
<default_to_action>
By default, implement changes rather than only suggesting them.
If the user's intent is unclear, infer the most useful likely action
and proceed, using tools to discover any missing details instead of guessing.
</default_to_action>
```

### 보수적 행동 설정
```xml
<do_not_act_before_instructions>
Do not jump into implementation unless clearly instructed to make changes.
When the user's intent is ambiguous, default to providing information,
doing research, and providing recommendations rather than taking action.
</do_not_act_before_instructions>
```

### 병렬 도구 호출
```xml
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies
between the tool calls, make all of the independent tool calls in parallel.
Maximize use of parallel tool calls where possible.
However, if some tool calls depend on previous calls, do NOT call
these tools in parallel. Never use placeholders or guess missing parameters.
</use_parallel_tool_calls>
```

### 코드 탐색 필수
```xml
<investigate_before_answering>
Never speculate about code you have not opened.
If the user references a specific file, you MUST read the file before answering.
Make sure to investigate and read relevant files BEFORE answering.
Never make any claims about code before investigating unless certain.
</investigate_before_answering>
```

### 과잉 엔지니어링 방지
```xml
<avoid_overengineering>
Avoid over-engineering. Only make changes that are directly requested
or clearly necessary. Keep solutions simple and focused.
Don't add features, refactor code, or make "improvements" beyond what was asked.
The right amount of complexity is the minimum needed for the current task.
</avoid_overengineering>
```

### 마크다운 제어
```xml
<avoid_excessive_markdown>
When writing reports or long-form content, write in clear, flowing prose.
Use paragraph breaks for organization. Reserve markdown for inline code,
code blocks, and simple headings. Avoid **bold**, *italics*, and excessive lists.
</avoid_excessive_markdown>
```

### 프론트엔드 미학
```xml
<frontend_aesthetics>
Avoid generic "AI slop" aesthetic. Make creative, distinctive frontends.
Focus on: Typography, Color & Theme, Motion, Backgrounds.
Avoid: Overused fonts (Inter, Roboto), clichéd color schemes, predictable layouts.
</frontend_aesthetics>
```

---

## Metadata

- **Version**: 2.0.0
- **Created**: 2025-12-28
- **Updated**: 2026-03-08
- **Changes v2.0.0**:
  - **[CRITICAL] Claude 4.6 모델 추가**: Opus 4.6 (`claude-opus-4-6`), Sonnet 4.6 (`claude-sonnet-4-6`)
  - **[CRITICAL] Adaptive Thinking 섹션 추가**: `{type: "adaptive"}` — 모델 자율 사고 결정
  - **[CRITICAL] Prefill 제거 Breaking Change**: 4.6에서 프리필 → 400 에러, 마이그레이션 가이드
  - **[CRITICAL] Effort Parameter 섹션 추가**: `output_config: {effort}` low/medium/high/max
  - **[HIGH] Over-prompting 경고 섹션 추가**: 과도한 프롬프트의 부작용
  - **[HIGH] 128K Output / 1M Context**: API 기능 섹션 업데이트
  - **[MEDIUM] Compaction API, Fast Mode 추가**
  - **budget_tokens deprecated 표기**: 4.6에서는 adaptive로 대체
  - **Interleaved Thinking 자동 활성화**: Opus 4.6에서 beta 헤더 불필요
- **Changes v1.1.0**: Part 12 "XML 프롬프트 구조 가이드" 섹션 추가, 부록에 보수적 행동/마크다운/프론트엔드 블록 추가
- **Source Documents**:
  - Claude-4.5-프롬프트-전략.md
  - Claude 4.6 Prompt Guide (2026-03)
- **Original Source**: Anthropic 공식 문서 (platform.claude.com)
