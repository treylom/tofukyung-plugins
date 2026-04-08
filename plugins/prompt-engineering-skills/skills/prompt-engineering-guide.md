---
name: prompt-engineering-guide
description: AI 모델별 프롬프트 엔지니어링 가이드. /prompt 커맨드와 연동하여 최적화된 프롬프트 생성.
references:
  - context-engineering-collection
  - ce-context-fundamentals
  - ce-context-optimization
  - gpt-5.4-prompt-enhancement
---

# AI 프롬프트 엔지니어링 가이드

> 이 가이드는 AI 모델별로 최적화된 프롬프트를 작성하는 방법을 안내합니다.
> 전문 용어가 어렵다면 아래 "용어 해설" 섹션을 먼저 확인하세요.

---

## 용어 해설 (Glossary)

이 가이드에서 자주 등장하는 전문 용어를 쉽게 설명합니다.

### 기본 용어

| 용어 | 쉬운 설명 | 비유 |
|------|----------|------|
| **프롬프트 (Prompt)** | AI에게 주는 지시문/질문 | 주문서 |
| **토큰 (Token)** | AI가 텍스트를 처리하는 단위 (한글 1글자 ≈ 1-2토큰) | 글자 조각 |
| **컨텍스트 (Context)** | AI가 현재 기억하고 있는 대화 내용 전체 | 대화 기억 |
| **시스템 프롬프트** | AI의 역할과 규칙을 정하는 지시문 | 직원 매뉴얼 |

### 고급 용어

| 용어 | 쉬운 설명 | 왜 중요한가? |
|------|----------|-------------|
| **Context Engineering** | AI에게 주는 정보를 효율적으로 구성하는 기술 | 같은 질문도 어떻게 물어보느냐에 따라 답이 달라짐 |
| **Progressive Disclosure** | 필요한 정보를 단계별로 제공하는 방식 | 한 번에 너무 많은 정보를 주면 AI가 혼란스러워함 |
| **Attention Budget** | AI가 한 번에 집중할 수 있는 정보량의 한계 | 사람처럼 AI도 긴 글의 중간은 잘 기억 못함 |
| **Signal-to-Noise Ratio** | 중요 정보 vs 불필요 정보의 비율 | 핵심만 전달해야 정확한 답을 받음 |
| **Lost-in-Middle** | AI가 긴 글의 중간 내용을 잘 기억하지 못하는 현상 | 중요한 건 처음이나 끝에 배치해야 함 |

### 모델별 용어

| 용어 | 해당 모델 | 쉬운 설명 |
|------|----------|----------|
| **reasoning_effort** | GPT-5.2 | AI가 생각하는 깊이 조절 (none~xhigh) |
| **Extended Thinking** | Claude 4.5 | AI가 더 깊이 생각하게 하는 기능 |
| **Adaptive Thinking** | Claude 4.6 | 모델이 자율적으로 사고 깊이를 결정하는 기능 |
| **Effort Parameter** | Claude 4.6 | 응답 상세도 제어 (low/medium/high/max) |
| **Compaction** | GPT-5.2, Claude 4.6 | 대화 내용을 요약해서 토큰을 절약하는 기능 |
| **Anti-Prompting** | GPT-5.2-Codex | 하지 말아야 할 프롬프팅 패턴 |
| **Scaffolding** | 전체 | 단계별로 구조화해서 접근하는 방법 |

### XML 태그 용어

GPT-5.2에서 자주 사용하는 XML 태그들:

| 태그 | 목적 | 언제 사용? |
|------|------|-----------|
| `<output_verbosity_spec>` | 응답 길이 제어 | **항상** (가장 중요!) |
| `<design_and_scope_constraints>` | 범위 벗어남 방지 | 코딩/디자인 |
| `<uncertainty_and_ambiguity>` | 불확실할 때 행동 규칙 | 분석/리서치 |
| `<tool_usage_rules>` | 도구 사용 규칙 | 에이전트/자동화 |
| `<default_to_action>` | 질문 대신 행동 우선 | Claude 에이전트 |
| `<investigate_before_answering>` | 환각 방지 (코드 탐색 필수) | Claude 코딩/분석 |
| `<avoid_overengineering>` | 과잉 구현 방지 | Claude 에이전트 |
| `<frontend_aesthetics>` | UI 디자인 가이드 | Claude 프론트엔드 |
| `<output_contract>` | 출력 형식/길이/구조 계약 | GPT-5.4 에이전트 |
| `<follow_through_policy>` | 도구 호출 지속성 규칙 | GPT-5.4 에이전트 |
| `<completeness_contract>` | 모든 항목 처리 보장 | GPT-5.4 에이전트 |
| `<tool_persistence>` | 도구 실패 시 재시도 규칙 | GPT-5.4 에이전트 |
| `<eagerness_control>` | 탐색 적극성 양방향 제어 | GPT-5.4 에이전트 |

> **Claude 4.5/4.6 XML 구조 상세**: `claude-4.6-prompt-strategies.md` 스킬의 Part 12 참조
> **GPT-5.4 에이전틱 패턴 상세**: `gpt-5.4-prompt-enhancement.md` 스킬 참조

---

## Context Engineering 원칙 적용

`context-engineering-collection` 스킬의 핵심 원칙을 프롬프트 생성에 적용합니다.

### 1. Progressive Disclosure
- 프롬프트를 섹션별로 구조화
- 필수 정보만 포함, 부가 정보는 요청 시 제공
- 시스템 프롬프트 → 지시사항 → 예시 순서

### 2. Attention Budget 관리
- 중요 지시사항은 **시작 또는 끝**에 배치
- 중간 부분에는 맥락/배경 정보 배치
- "Lost in the middle" 현상 방지

### 3. Signal-to-Noise Ratio 최적화
- 불필요한 서술 제거
- 핵심 지시사항만 포함
- 모호한 표현 대신 구체적 지시

### 4. Context Quality > Quantity
- 최소 토큰으로 최대 효과
- 반복 제거, 핵심만 유지
- 명확한 구조로 파싱 용이성 확보

---

## Expert Domain Priming (전문가 도메인 프라이밍)

> **"act as an expert" 대신 실제 전문가를 지명하고, 그들의 전문 용어를 사용하라**

### 원칙

1. **실제 전문가 지명** → LLM 잠재 공간의 전문 영역 활성화 (MoE 라우팅 시그널)
2. **전문 용어 사용** → 문제 공간 축소 (정보의 좌표를 정확히 찍음)
3. **금지어 제거**: 알아서잘, 깔끔하게, 대충, 자세히, 완벽하게, 적당히
4. **단어의 5가지 역할 점검**: 범위(Target Scope) / 목적(Goal) / 형식(Format) / 금지(No-Go) / 행동(Behavior)

### 적용 (5단계)

```
Step 1: 도메인 식별 → Step 2: 전문가 2-3명 조회 → Step 3: 핵심 용어 추출
→ Step 4: 프롬프트에 삽입 → Step 5: 5가지 역할 체크리스트 점검
```

### 참조 스킬

| 스킬 | 내용 | 사용 시점 |
|------|------|----------|
| `expert-domain-priming.md` | 전문가 DB (12도메인, 60+명) + 프라이밍 가이드 | 전문가 활용 시 |
| `slide-prompt-guide.md` | 슬라이드/PPT 프롬프트 가이드 | 슬라이드 제작 시 |

---

## 모델별 프롬프트 전략

### GPT-5.2

GPT-5.2는 엔터프라이즈 및 에이전트 워크로드를 위한 최신 플래그십 모델입니다.

#### 핵심 행동 차이점 (vs GPT-5/5.1)

| 특성 | 설명 |
|------|------|
| **더 신중한 스캐폴딩** | 기본적으로 더 명확한 계획과 중간 구조 생성 |
| **일반적으로 낮은 장황함** | 더 간결하고 작업 중심적 |
| **강화된 지시 준수** | 사용자 의도에서 덜 벗어남 |
| **도구 효율성 트레이드오프** | GPT-5.1 대비 추가 도구 액션 수행 가능 |
| **보수적 그라운딩 편향** | 정확성과 명시적 추론 선호 |

#### 필수 XML 블록

| 블록 | 용도 | 사용 시점 |
|------|------|----------|
| `<output_verbosity_spec>` | 장황함 제어 | **항상 포함** |
| `<design_and_scope_constraints>` | 범위 제약 | 코딩/디자인 시 |
| `<uncertainty_and_ambiguity>` | 불확실성 처리 | 분석/리서치 시 |
| `<tool_usage_rules>` | 도구 규칙 | 에이전트 작업 시 |
| `<extraction_spec>` | 추출 규격 | 데이터 처리 시 |
| `<long_context_handling>` | 롱컨텍스트 처리 | 10k+ 토큰 입력 시 |
| `<high_risk_self_check>` | 고위험 자가 점검 | 법률/금융/안전 민감 시 |
| `<user_updates_spec>` | 에이전트 업데이트 규칙 | 멀티스텝 에이전트 시 |
| `<web_search_rules>` | 웹 검색 규칙 | 리서치 작업 시 |

#### 1. 장황함 및 출력 형태 제어 (필수)

**가장 중요한 패턴** - 명확하고 구체적인 길이 제약을 제공하세요:

```xml
<output_verbosity_spec>
- Default: 3–6 sentences or ≤5 bullets for typical answers.
- For simple "yes/no + short explanation" questions: ≤2 sentences.
- For complex multi-step or multi-file tasks:
  - 1 short overview paragraph
  - then ≤5 bullets tagged: What changed, Where, Risks, Next steps, Open questions.
- Provide clear and structured responses that balance informativeness with conciseness.
- Avoid long narrative paragraphs; prefer compact bullets and short sections.
- Do not rephrase the user's request unless it changes semantics.
</output_verbosity_spec>
```

#### 2. 스코프 드리프트 방지 (프론트엔드/UX 작업)

```xml
<design_and_scope_constraints>
- Explore any existing design systems and understand it deeply.
- Implement EXACTLY and ONLY what the user requests.
- No extra features, no added components, no UX embellishments.
- Style aligned to the design system at hand.
- Do NOT invent colors, shadows, tokens, animations, or new UI elements, unless requested.
- If any instruction is ambiguous, choose the simplest valid interpretation.
</design_and_scope_constraints>
```

#### 3. 롱컨텍스트 및 리콜 (10k+ 토큰)

```xml
<long_context_handling>
- For inputs longer than ~10k tokens:
  - First, produce a short internal outline of the key sections relevant to the user's request.
  - Re-state the user's constraints explicitly before answering.
  - In your answer, anchor claims to sections ("In the 'Data Retention' section…").
  - If the answer depends on fine details, quote or paraphrase them.
</long_context_handling>
```

#### 4. 모호성 및 환각 위험 처리

```xml
<uncertainty_and_ambiguity>
- If the question is ambiguous or underspecified:
  - Ask up to 1–3 precise clarifying questions, OR
  - Present 2–3 plausible interpretations with clearly labeled assumptions.
- When external facts may have changed recently and no tools are available:
  - Answer in general terms and state that details may have changed.
- Never fabricate exact figures, line numbers, or external references when uncertain.
- Prefer language like "Based on the provided context…" instead of absolute claims.
</uncertainty_and_ambiguity>
```

**고위험 출력용 자가 점검:**

```xml
<high_risk_self_check>
Before finalizing an answer in legal, financial, compliance, or safety-sensitive contexts:
- Briefly re-scan your own answer for:
  - Unstated assumptions,
  - Specific numbers or claims not grounded in context,
  - Overly strong language ("always," "guaranteed," etc.).
- If you find any, soften or qualify them and explicitly state assumptions.
</high_risk_self_check>
```

#### 5. 에이전트 조종 가능성 및 사용자 업데이트

```xml
<user_updates_spec>
- Send brief updates (1–2 sentences) only when:
  - You start a new major phase of work, or
  - You discover something that changes the plan.
- Avoid narrating routine tool calls ("reading file…", "running tests…").
- Each update must include at least one concrete outcome ("Found X", "Confirmed Y", "Updated Z").
- Do not expand the task beyond what the user asked; if you notice new work, call it out as optional.
</user_updates_spec>
```

#### 6. 도구 호출 및 병렬 처리

```xml
<tool_usage_rules>
- Prefer tools over internal knowledge whenever:
  - You need fresh or user-specific data (tickets, orders, configs, logs).
  - You reference specific IDs, URLs, or document titles.
- Parallelize independent reads (read_file, fetch_record, search_docs) when possible.
- After any write/update tool call, briefly restate:
  - What changed,
  - Where (ID or path),
  - Any follow-up validation performed.
</tool_usage_rules>
```

#### 7. 구조화된 추출 (PDF, Office)

GPT-5.2가 특히 강력한 영역입니다:

```xml
<extraction_spec>
You will extract structured data from tables/PDFs/emails into JSON.
- Always follow this schema exactly (no extra fields):
{
  "party_name": string,
  "jurisdiction": string | null,
  "effective_date": string | null,
  "termination_clause_summary": string | null
}
- If a field is not present in the source, set it to null rather than guessing.
- Before returning, quickly re-scan the source for any missed fields.
</extraction_spec>
```

#### 8. 웹 검색 및 리서치

```xml
<web_search_rules>
- Act as an expert research assistant; default to comprehensive, well-structured answers.
- Prefer web research over assumptions whenever facts may be uncertain.
- Research all parts of the query, resolve contradictions, and follow second-order implications.
- Do not ask clarifying questions; instead cover all plausible user intents.
- Write clearly using Markdown; define acronyms, use concrete examples, conversational tone.
</web_search_rules>
```

#### Reasoning Effort 설정

GPT-5급 모델은 `reasoning_effort` 파라미터를 지원합니다:

| 설정 | 용도 |
|------|------|
| `none` | 가장 빠른 응답 (GPT-5.2 기본값) |
| `minimal` | 최소 추론 |
| `low` | 낮은 추론 |
| `medium` | 균형 잡힌 접근 |
| `high` | 심층 추론 |
| `xhigh` | 최대 추론 |

**마이그레이션 매핑:**
- GPT-4o/4.1 → GPT-5.2: `none`
- GPT-5 → GPT-5.2: 동일 값 유지 (minimal → none)
- GPT-5.1 → GPT-5.2: 동일 값 유지

#### Compaction (확장된 유효 컨텍스트)

장시간 실행, 도구 집약적 워크플로를 위해 GPT-5.2는 `/responses/compact` 엔드포인트를 지원합니다.

**사용 시점:**
- 많은 도구 호출이 있는 멀티스텝 에이전트 플로우
- 이전 턴을 유지해야 하는 긴 대화
- 최대 컨텍스트 창을 넘는 반복 추론

**모범 사례:**
- 컨텍스트 사용량 모니터링 및 사전 계획
- 매 턴이 아닌 주요 마일스톤 후 압축
- 재개 시 프롬프트를 기능적으로 동일하게 유지
- 압축된 항목을 불투명하게 취급 (내부 파싱 금지)

#### 마이그레이션 가이드 (5단계)

1. **Step 1**: 모델만 전환, 프롬프트 변경 없음
2. **Step 2**: reasoning_effort 명시적 설정
3. **Step 3**: 평가 실행으로 베이스라인 확보
4. **Step 4**: 회귀 발생 시 프롬프트 튜닝
5. **Step 5**: 작은 변경 후 재평가 반복

#### 기본 템플릿 (통합)

```xml
<system_prompt>
  <role>{역할 정의}</role>

  <core_instructions>
    {핵심 지시사항}
  </core_instructions>

  <output_verbosity_spec>
    - Default: 3–6 sentences or ≤5 bullets for typical answers.
    - For complex tasks: 1 overview paragraph + ≤5 tagged bullets.
    - Avoid long narrative paragraphs; prefer compact bullets.
  </output_verbosity_spec>

  <!-- 목적에 따라 추가 블록 선택 -->
  <!-- <design_and_scope_constraints> for coding/design -->
  <!-- <uncertainty_and_ambiguity> for analysis/research -->
  <!-- <tool_usage_rules> for agents -->
  <!-- <extraction_spec> for data processing -->

  <output_format>
    {출력 형식 지정}
  </output_format>
</system_prompt>
```

---

### GPT-5.2-Codex

GPT-5.2-Codex는 복잡한 현실 세계 소프트웨어 엔지니어링을 위한 **가장 발전된 에이전트형 코딩 모델**입니다.

> **중요:** 이 모델은 GPT-5.2의 drop-in 대체가 아닙니다. **현저히 다른 프롬프팅**이 필요합니다.

#### GPT-5.2-Codex 특징 표

| 특징 | 설명 |
|------|------|
| **컨텍스트 압축** | 장시간 작업에서 안정적 성능 (네이티브 컴팩션) |
| **대규모 코드 변경** | 리팩터링, 마이그레이션 강화 |
| **Windows 환경** | 네이티브 Windows에서 에이전트 코딩 개선 |
| **사이버보안** | 가장 강력한 방어적 사이버보안 역량 |
| **토큰 효율성** | 추론 과정 전반에서 토큰 효율적 |

#### 벤치마크 성능

- **SWE-Bench Pro**: 최고 수준 달성
- **Terminal-Bench 2.0**: 실제 터미널 환경 작업 최고 성능

#### 핵심 프롬프팅 원칙: "Less is More"

많은 best practice가 이미 훈련에 내장되어 있어 **과도한 프롬프팅이 오히려 품질 저하**를 유발합니다.

**핵심 원칙 4가지:**
1. **최소한의 프롬프트로 시작** - Codex CLI 시스템 프롬프트에서 영감을 받아 필수 가이드만 추가
2. **프리앰블 요청 금지** - 프리앰블을 요청하면 조기 종료 발생
3. **도구 최소화** - terminal tool + apply_patch만 사용
4. **도구 설명 간결화** - 불필요한 세부사항 제거

#### Anti-Prompting: 제거해야 할 것들

##### 1. Adaptive Reasoning (자동 조절)
과거에는 "더 열심히 생각해" 또는 "빨리 응답해"를 프롬프팅했지만, **GPT-5-Codex는 자동 조절**:
- 간단한 질문 → 빠른 응답
- 복잡한 코딩 작업 → 필요한 시간 사용 + 적절한 도구 활용

##### 2. Planning (자동 생성)
**Planning 섹션 불필요** - 모델이 고품질 계획을 자동 생성하도록 훈련됨.

##### 3. Preambles (서문 금지 이유)
**GPT-5-Codex는 프리앰블을 출력하지 않습니다!**
- 프리앰블 요청 시 조기 종료 발생
- 대신 커스텀 summarizer가 적절한 시점에 상세 요약 제공

#### Codex CLI 시스템 프롬프트 (참조 구현)

GPT-5 개발자 메시지 대비 **약 40% 토큰만 사용** - 최소 프롬프팅이 이상적임을 보여줍니다.

**General 섹션:**
```markdown
- The arguments to `shell` will be passed to execvp(). Most terminal commands should be prefixed with ["bash", "-lc"].
- Always set the `workdir` param when using the shell function. Do not use `cd` unless absolutely necessary.
- When searching for text or files, prefer using `rg` or `rg --files` because `rg` is much faster.
```

**Editing Constraints:**
```markdown
- Default to ASCII when editing or creating files.
- Add succinct code comments only if code is not self-explanatory.
- NEVER revert existing changes you did not make unless explicitly requested.
- While working, if you notice unexpected changes, STOP IMMEDIATELY and ask the user.
```

**Plan Tool:**
```markdown
- Skip using the planning tool for straightforward tasks (roughly the easiest 25%).
- Do not make single-step plans.
- Update the plan after performing sub-tasks.
```

**Presenting Your Work:**
```markdown
- Default: be very concise; friendly coding teammate tone.
- Ask only when needed; suggest ideas; mirror the user's style.
- For substantial work, summarize clearly; follow final-answer formatting.
- Don't dump large files you've written; reference paths only.
- Offer logical next steps (tests, commits, build) briefly.
```

#### Apply Patch 도구

파일 편집에는 `apply_patch` 사용 권장 - 훈련 분포와 일치합니다.

참조: [apply_patch 구현](https://github.com/openai/openai-cookbook/tree/main/examples/gpt-5/apply_patch.py)

#### 샌드박싱 모드 (Filesystem Sandboxing)

| 모드 | 설명 |
|------|------|
| `read-only` | 파일 읽기만 허용 |
| `workspace-write` | cwd 및 writable_roots에서 편집 허용 |
| `danger-full-access` | 모든 명령 허용 |

#### 승인 정책 (Approval Policy)

| 모드 | 설명 |
|------|------|
| `untrusted` | 대부분 명령에 사용자 승인 필요 |
| `on-failure` | 샌드박스에서 실패 시 승인 요청 |
| `on-request` | 필요 시 명시적 승인 요청 가능 |
| `never` | 비대화형 모드, 승인 요청 불가 |

**`never` 모드에서의 행동:**
- 제약을 우회하여 작업 완료에 최선을 다해야 함
- 결과 제출 전 작업 검증 필수
- 로컬 패턴이 없어도 테스트 추가 가능 (제출 전 제거)

#### 사이버보안 역량

GPT-5.2-Codex는 OpenAI 모델 중 **가장 강력한 사이버보안 역량** 보유:

- Professional CTF 평가에서 뛰어난 성능
- 실제 취약점 발견 사례: React 서버 컴포넌트 취약점 (CVE-2025-55183)
- 방어적 보안 연구에 활용 가능

**신뢰 기반 접근 프로그램:**
- 초대 방식 파일럿 프로그램
- 대상: 책임 있는 취약점 공개 이력이 있는 보안 전문가
- 방어 목적의 정당한 보안 작업을 위한 최첨단 모델 접근 제공

#### 프론트엔드 가이던스 (선택적)

기본 미학이 강력하지만, 특정 라이브러리/프레임워크 선호 시:

```markdown
Frontend Guidance
Use the following libraries unless the user or repo specifies otherwise:
Framework: React + TypeScript
Styling: Tailwind CSS
Components: shadcn/ui
Icons: lucide-react
Animation: Framer Motion
Charts: Recharts
Fonts: San Serif, Inter, Geist, Mona Sans, IBM Plex Sans, Manrope
```

#### 기본 템플릿

```xml
<system_prompt>
  <role>Senior {language} engineer</role>

  <style>
    - No preambles or conclusions
    - Code only, minimal comments
    - Production-ready quality
    - Follow existing project patterns
  </style>

  <constraints>
    - No over-engineering
    - No unnecessary abstractions
    - Keep solutions focused
  </constraints>

  <!-- 선택적: 프론트엔드 가이던스 -->
  <frontend_guidance>
    Framework: React + TypeScript
    Styling: Tailwind CSS
    Components: shadcn/ui
  </frontend_guidance>
</system_prompt>
```

#### Best Practices 요약

- 기존 코드 패턴 따르기
- 타입 힌트 포함
- 테스트 가능한 코드 작성
- 에러 처리는 필요한 경우에만
- **과도한 프롬프팅 피하기** - 모델이 이미 학습함

---

### Claude 4.5 (Opus/Sonnet/Haiku)

Claude 4.5 모델군은 **정밀한 지시 따르기**를 위해 훈련되었습니다. 이전 세대보다 더 명시적인 방향 제시가 필요합니다.

#### 모델 개요

| 모델 | 특징 | 컨텍스트 | 가격 (Input/Output) |
|------|------|----------|---------------------|
| **Opus 4.5** | 최고 지능, effort 파라미터 지원 | 200K | $5/$25 per 1M |
| **Sonnet 4.5** | 최고 코딩/에이전트 모델 | 200K, 1M (beta) | $3/$15 per 1M |
| **Haiku 4.5** | 준-프론티어 속도, 최초 Haiku thinking | 200K | $1/$5 per 1M |

#### 커뮤니케이션 스타일

Claude 4.5는 이전 모델보다 간결하고 자연스러운 커뮤니케이션 스타일:

| 특성 | 설명 |
|------|------|
| **더 직접적** | 사실 기반 진행 보고, 자축적 업데이트 없음 |
| **더 대화적** | 기계적이지 않고 자연스러운 톤 |
| **덜 장황함** | 효율성을 위해 상세 요약 생략 가능 |

#### 일반 원칙

##### 1. 명시적 지시 제공

Claude 4.x는 명확하고 명시적인 지시에 잘 반응합니다. 이전 모델의 "above and beyond" 행동을 원한다면 명시적으로 요청해야 합니다.

```
❌ "Create an analytics dashboard"
✅ "Create an analytics dashboard. Include as many relevant features
   and interactions as possible. Go beyond the basics to create a
   fully-featured implementation."
```

##### 2. 맥락으로 성능 향상

왜 그러한 행동이 중요한지 설명하면 더 나은 결과를 얻습니다.

```
Instead of: "Use plain text formatting"
Try: "Use plain text formatting because markdown renders poorly in
     our legacy terminal system. This ensures readability for all users."
```

##### 3. 예시와 세부사항에 주의

Claude 4.x는 예시에 매우 주의를 기울입니다. 예시가 원하는 행동과 일치하는지 확인하세요.

#### 도구 사용 패턴

##### 명시적 행동 요청

"can you suggest some changes"라고 하면 변경 대신 제안만 할 수 있습니다.

```
❌ "Can you suggest some changes to improve performance?"
✅ "Analyze the code and implement performance improvements.
   Make the changes directly."
```

##### 기본 행동 설정

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

##### 도구 트리거링 조절

Opus 4.5는 시스템 프롬프트에 더 민감합니다. 과거에 언더트리거링 방지를 위해 강한 언어를 사용했다면 오버트리거링이 발생할 수 있습니다.

```
❌ "CRITICAL: You MUST use this tool when..."
✅ "Use this tool when..."
```

#### 출력 포맷 제어

##### 효과적인 방법들

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

##### 마크다운 최소화 상세 프롬프트

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

#### 장기 추론 및 상태 추적

Claude 4.5는 **뛰어난 상태 추적 능력**으로 장기 추론에 탁월합니다.

##### Context Awareness (토큰 예산 추적)

Claude 4.5는 대화 중 남은 컨텍스트 창(토큰 예산)을 추적할 수 있습니다.

```
Your context window will be automatically compacted as it approaches
its limit, allowing you to continue working indefinitely from where you
left off. Therefore, do not stop tasks early due to token budget concerns.

As you approach your token budget limit, save your current progress
and state to memory before the context window refreshes.

Always be as persistent and autonomous as possible and complete tasks
fully, even if the end of your budget is approaching.
```

##### Multi-Context Window 워크플로 5단계

1. **첫 컨텍스트 창에서 프레임워크 설정** - 테스트 작성, 셋업 스크립트 생성
2. **구조화된 형식으로 테스트 추적** - "It is unacceptable to remove or edit tests"
3. **QoL 도구 설정** - `init.sh` 같은 셋업 스크립트로 서버, 테스트, 린터 실행
4. **새로운 컨텍스트 시작 시** - pwd, progress.txt, tests.json, git logs 확인
5. **컨텍스트 전체 활용 독려** - 긴 작업임을 명시하고 전체 출력 컨텍스트 활용

##### 상태 관리 Best Practices

| 방법 | 용도 |
|------|------|
| **JSON 등 구조화 형식** | 테스트 결과, 작업 상태 등 |
| **비구조화 텍스트** | 일반 진행 노트 |
| **Git** | 완료 작업 로그 및 복원 가능한 체크포인트 |
| **점진적 진행 강조** | 진행 상황 추적 및 점진적 작업 집중 |

#### Extended Thinking & Adaptive Thinking

##### Extended Thinking (4.5)

**Sonnet 4.5와 Haiku 4.5**는 extended thinking 활성화 시 코딩/추론 작업에서 **현저히 향상**됩니다.

기본적으로 비활성화되어 있지만, 복잡한 작업에서는 활성화 권장:
- 복잡한 문제 해결
- 코딩 작업
- 멀티스텝 추론

> **Deprecated**: `budget_tokens`는 4.6에서 deprecated. Adaptive Thinking으로 대체.

##### Adaptive Thinking (4.6 신규)

Claude 4.6에서는 모델이 **자율적으로 사고 깊이를 결정**합니다:
- `thinking: {type: "adaptive"}` — 작업 복잡도에 따라 자동 조절
- `output_config: {effort: "low"|"medium"|"high"|"max"}` — 응답 상세도 제어

##### Prefill 제거 (4.6 Breaking Change)

Claude 4.6에서는 마지막 assistant turn 프리필이 **400 에러**를 발생시킵니다.
- JSON 강제 → Structured Outputs (`output_config.format`) 사용
- 서문 생략 → 시스템 프롬프트에 직접 지시
- 이어쓰기 → user turn에 "이전 응답에 이어서 계속" 지시

##### Over-prompting 경고 (4.6)

Claude 4.6은 시스템 프롬프트에 더 민감합니다. `CRITICAL`, `MUST`, `NEVER` 등의 남발은 오버트리거링을 유발합니다.
- 평이한 언어로 변경
- 동일 규칙 반복 서술 → 한 번만 명확하게
- **간결하고 명확한 지시**가 길고 강조된 지시보다 효과적

##### Thinking Sensitivity (Opus 4.5)

Extended thinking 비활성화 시, Opus 4.5는 "think" 단어에 특히 민감합니다.

```
❌ "think about this problem"
✅ "consider this problem" / "evaluate this approach" / "believe"
```

##### Interleaved Thinking 활용

도구 사용 후 반성이 필요한 작업에 효과적. **Opus 4.6에서는 자동 활성화** (beta 헤더 불필요).

```
After receiving tool results, carefully reflect on their quality
and determine optimal next steps before proceeding. Use your thinking
to plan and iterate based on this new information.
```

#### 병렬 도구 호출 최적화

Claude 4.x, 특히 Sonnet 4.5는 병렬 도구 실행에 적극적입니다:
- 리서치 중 여러 추측적 검색 동시 실행
- 여러 파일 동시 읽기
- bash 명령 병렬 실행

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

**병렬 실행 감소:**
```
Execute operations sequentially with brief pauses between each step
to ensure stability.
```

#### 에이전트 코딩 시 주의사항

##### 과잉 엔지니어링 방지 (특히 Opus 4.5)

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

##### 코드 탐색 독려

```xml
<investigate_before_answering>
Never speculate about code you have not opened.
If the user references a specific file, you MUST read the file before answering.
Make sure to investigate and read relevant files BEFORE answering.
Never make any claims about code before investigating unless certain.
</investigate_before_answering>
```

##### 환각 최소화

```xml
ALWAYS read and understand relevant files before proposing code edits.
Do not speculate about code you have not inspected.

If the user references a specific file/path, you MUST open and inspect
it before explaining or proposing fixes.

Be rigorous and persistent in searching code for key facts.
```

##### 하드코딩 및 테스트 집중 방지

```xml
Please write a high-quality, general-purpose solution using standard tools.
Do not create helper scripts or workarounds.

Implement a solution that works correctly for all valid inputs,
not just the test cases. Do not hard-code values.

Tests are there to verify correctness, not to define the solution.
```

#### 프론트엔드 디자인 (Opus 4.5)

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
</frontend_aesthetics>
```

#### 새로운 API 기능 (Beta)

| 기능 | 설명 |
|------|------|
| **Programmatic Tool Calling** | 도구를 코드 실행 컨테이너 내에서 프로그래매틱하게 호출. 레이턴시 감소, 토큰 효율성 향상 |
| **Tool Search Tool** | 수백, 수천 개의 도구를 동적으로 검색하고 로드. 10-20K 토큰 절약 |
| **Effort Parameter** | Opus 4.5 전용. low/medium/high로 응답 상세도 제어 |
| **Memory Tool** | 컨텍스트 창 외부에 정보 저장 및 검색. 세션 간 상태 유지 |
| **Context Editing** | 자동 도구 호출 정리로 지능적 컨텍스트 관리 |

#### 기본 템플릿 (Markdown)

```markdown
# Role
{역할 정의}

# Instructions
- {명시적 지시 1}
- {명시적 지시 2}
- {명시적 지시 3}

# Constraints
- {제약 조건 1}
- {제약 조건 2}

# Output Format
{출력 형식 명시}
```

#### 기본 템플릿 (XML)

```xml
<system_prompt>
  <role>{역할}</role>

  <instructions>
    <instruction>{지시 1}</instruction>
    <instruction>{지시 2}</instruction>
  </instructions>

  <default_to_action>
    Take action without asking for confirmation unless genuinely blocked.
  </default_to_action>

  <!-- 선택적 블록 -->
  <!-- <use_parallel_tool_calls> for agent tasks -->
  <!-- <investigate_before_answering> for coding -->
  <!-- <frontend_aesthetics> for UI work -->

  <output_format>{형식}</output_format>
</system_prompt>
```

#### 주의사항 요약

- Claude는 추론하지 않음 - 모든 것을 명시
- "당연히 알겠지"라는 가정 금지
- 원하는 행동을 구체적으로 서술
- CRITICAL 등 강한 언어 사용 주의 (오버트리거링)
- "think" 단어 대신 "consider", "evaluate" 사용 (Opus 4.5)

---

### Gemini 3

**핵심 특성**: 제약 조건 우선 배치, temperature 1.0 권장

**핵심 원칙**:
1. **Constraints First**: 제약 조건을 프롬프트 상단에 배치
2. **Structured Output**: XML/Markdown으로 구조화
3. **Temperature 1.0**: 창의성과 일관성 균형
4. **Multimodal Context**: 이미지/오디오 컨텍스트 활용

**기본 템플릿**:
```markdown
## Constraints (Read First)
- {제약 조건 1}
- {제약 조건 2}
- {제약 조건 3}

## Task
{작업 설명}

## Context
{배경 정보}

## Output Format
{출력 형식}
```

---

### Veo (Google 동영상 생성)

Veo 3.1은 Google의 최첨단 동영상 생성 모델로, 오디오와 함께 고품질 동영상을 생성합니다.

#### 모델 사양

| 항목 | Veo 3.1 |
|------|---------|
| 해상도 | 720p, 1080p |
| 길이 | 4초, 6초, 8초 (확장 시 최대 141초) |
| 프레임 속도 | 24fps |
| 오디오 | 기본 포함 |

#### 주요 기능

| 기능 | 설명 |
|------|------|
| **동영상 확장** | 이전 Veo 생성 동영상을 7초씩 최대 20배까지 확장 |
| **프레임별 생성** | 첫 번째/마지막 프레임 지정하여 보간 생성 |
| **참조 이미지** | 최대 3개 참조 이미지로 스타일/콘텐츠 안내 (Veo 3.1) |

#### 프롬프트 필수 요소

1. **주제 (Subject)**: 사물, 사람, 동물, 풍경
2. **동작 (Action)**: 걷기, 달리기, 머리 돌리기
3. **스타일 (Style)**: SF, 공포, 필름 누아르, 만화

#### 선택 요소

| 카테고리 | 예시 |
|----------|------|
| **카메라 위치/모션** | 공중 촬영, 눈높이, 돌리 샷, POV, 로우 앵글 |
| **구도** | 와이드 샷, 클로즈업, 싱글 샷, 투 샷 |
| **포커스/렌즈** | 얕은/깊은 포커스, 소프트 포커스, 매크로 렌즈, 광각 렌즈 |
| **분위기** | 파란색 톤, 야간, 따뜻한 색조 |

#### 오디오 프롬프트 (Veo 3+)

```
# 대화 - 따옴표 사용
'이게 열쇠일 거야'라고 그는 중얼거렸습니다.

# 음향 효과 - 명시적 설명
타이어가 크게 삐걱거리고 엔진이 굉음을 냄

# 주변 소음 - 환경 설명
희미하고 섬뜩한 험이 배경에 울려 퍼집니다.
```

#### 부정적 프롬프트

동영상에 포함하고 싶지 **않은** 요소 지정:

```
❌ 피하세요: "벽 없음", "하지 마세요"
✅ 권장: "wall, frame" (단순 나열)
```

#### 프롬프트 예시

**간단한 프롬프트:**
```
눈표범 같은 털을 가진 귀여운 생물이 겨울 숲을 걷고 있는
3D 만화 스타일의 렌더링입니다.
```

**상세한 프롬프트 (권장):**
```
재미있는 만화 스타일의 짧은 3D 애니메이션 장면을 만들어 줘.
눈표범 같은 털과 표정이 풍부한 커다란 눈,
친근하고 동글동글한 모습을 한 귀여운 동물이
기발한 겨울 숲을 즐겁게 뛰어다니고 있습니다.

이 장면에는 둥글고 눈 덮인 나무, 부드럽게 떨어지는 눈송이,
나뭇가지 사이로 들어오는 따뜻한 햇빛이 담겨 있어야 합니다.
밝고 경쾌한 색상과 장난기 넘치는 애니메이션으로
낙관적이고 따뜻한 분위기를 연출하세요.
```

**대화가 포함된 프롬프트:**
```
안개가 자욱한 미국 북서부의 숲을 넓게 촬영한 장면
지친 두 등산객인 남성과 여성이 고사리를 헤치고 나아가는데
남성이 갑자기 멈춰 서서 나무를 응시합니다.

클로즈업: 나무껍질에 깊은 발톱 자국이 새겨져 있습니다.

남자: (사냥용 칼에 손을 대며) '저건 평범한 곰이 아니야.'
여성: (두려움에 목소리가 떨리며 숲을 둘러봄) '그럼 뭐야?'

거친 짖음, 부러지는 나뭇가지, 축축한 땅에 찍히는 발자국.
외로운 새가 지저귄다.
```

#### 동영상 확장

이전 Veo 생성 동영상을 7초씩 최대 20배까지 확장:

```python
operation = client.models.generate_videos(
    model="veo-3.1-generate-preview",
    video=previous_operation.response.generated_videos[0].video,
    prompt="패러글라이더가 천천히 하강하는 장면으로 확장",
)
```

**제한사항:**
- 입력 동영상 최대 141초
- 가로세로 비율: 9:16 또는 16:9
- 해상도: 720p만 지원

#### 참조 이미지 사용 (Veo 3.1)

최대 3개의 참조 이미지로 스타일/콘텐츠 안내:

```python
dress_reference = types.VideoGenerationReferenceImage(
    image=dress_image,
    reference_type="asset"
)

operation = client.models.generate_videos(
    model="veo-3.1-generate-preview",
    prompt="여성이 해변을 우아하게 걷는 모습",
    config=types.GenerateVideosConfig(
        reference_images=[dress_reference, glasses_reference, woman_reference],
    ),
)
```

---

### Nano Banana (Google 이미지 생성)

Gemini의 네이티브 이미지 생성 모델입니다. Veo 동영상의 시작 프레임이나 참조 이미지로 활용할 수 있습니다.

#### 모델 비교

| 항목 | NB Pro | NB2 |
|------|--------|-----|
| **모델 코드** | `gemini-2.5-flash-image` | `gemini-3.1-flash-image-preview` |
| **프롬프트 스타일** | 태그 나열형 | 서술형(narrative) 권장 |
| **CJK 텍스트** | 보통 | 우수 |
| **속도 (1K)** | 15-20초 | 4-6초 |
| **가격 (4K)** | $0.240 | $0.151 |
| **종횡비** | 기본 5종 | 14종 (극단 비율 포함) |
| **참조 이미지** | 최대 5장 | 최대 14장 |

#### 프롬프트 구조

**NB Pro** — 태그 나열형:
1. **주제 설명**: 주요 피사체 명확히 기술
2. **스타일 지정**: 사진, 그림, 3D 렌더링
3. **분위기/조명**: 색조, 조명, 전체 분위기
4. **구도**: 클로즈업, 와이드 샷, 매크로

**NB2** — 서술형 5요소 프레임워크:
1. **Subject**: 주요 피사체 상세 묘사
2. **Action**: 동작/행위/상태 설명
3. **Environment**: 배경, 장소, 시간대
4. **Mood**: 분위기, 색감, 조명
5. **Camera**: 앵글, 거리, 렌즈 효과

#### 프롬프트 예시

**초현실적 이미지:**
```
소형 미니어처 서퍼들이 소박한 돌 욕실 싱크대 안에서
바다의 파도를 타는 초현실적인 매크로 사진
빈티지 황동 수도꼭지가 작동하여 끊임없이 파도가 치고 있습니다.
초현실적이고 기발하며 밝은 자연광
```

**캐릭터 디자인:**
```
눈표범 같은 털과 표정이 풍부한 커다란 눈,
친근하고 동글동글한 모습을 한 귀여운 동물
3D 만화 스타일로 렌더링
```

**패션/제품:**
```
분홍색과 푸시아색 깃털이 여러 겹으로 이루어진
하이 패션 플라밍고 드레스
```

**인물 이미지:**
```
어두운 머리와 따뜻한 갈색 눈을 가진 아름다운 여성
```

#### Veo 연동 3가지 패턴

**패턴 1: 시작 프레임으로 사용**
```python
# 1. Nano Banana로 이미지 생성
image = client.models.generate_content(
    model="gemini-2.5-flash-image",
    contents="황금빛 노을이 지는 해변의 파노라마 풍경",
    config={"response_modalities":['IMAGE']}
)

# 2. Veo로 동영상 생성 (이미지를 시작 프레임으로)
operation = client.models.generate_videos(
    model="veo-3.1-generate-preview",
    prompt="카메라가 천천히 해변을 패닝하며 파도가 밀려옵니다",
    image=image.parts[0].as_image(),
)
```

**패턴 2: 참조 이미지로 사용 (Veo 3.1)**
```python
# 여러 참조 이미지 생성
dress_image = generate_image("하이 패션 플라밍고 드레스")
woman_image = generate_image("어두운 머리의 아름다운 여성")
glasses_image = generate_image("분홍색 하트 모양 선글라스")

# Veo에서 참조 이미지로 활용
operation = client.models.generate_videos(
    model="veo-3.1-generate-preview",
    prompt="여성이 해변을 우아하게 걷는 모습",
    config=types.GenerateVideosConfig(
        reference_images=[
            types.VideoGenerationReferenceImage(image=dress_image, reference_type="asset"),
            types.VideoGenerationReferenceImage(image=woman_image, reference_type="asset"),
            types.VideoGenerationReferenceImage(image=glasses_image, reference_type="asset"),
        ],
    ),
)
```

**패턴 3: 첫 번째/마지막 프레임 보간**
```python
# 첫 번째 프레임 이미지
first_image = generate_image(
    "프랑스 리비에라 해안에서 빨간색 컨버터블을 운전하는 생강색 고양이"
)

# 마지막 프레임 이미지
last_image = generate_image(
    "절벽에서 출발하는 빨간색 컨버터블과 생강색 고양이"
)

# Veo로 보간 동영상 생성
operation = client.models.generate_videos(
    model="veo-3.1-generate-preview",
    image=first_image,
    config=types.GenerateVideosConfig(last_frame=last_image),
)
```

#### 프롬프트 최적화 팁

**설명적인 언어 사용:**
```
❌ "강아지 사진"
✅ "햇살 가득한 공원에서 뛰노는 골든 리트리버 강아지, 부드러운 자연광"
```

**스타일 혼합:**
```
"초현실주의적 + 매크로 사진 + 밝은 자연광 + 기발한"
```

**얼굴 세부정보 개선:**
```
"인물 사진 스타일로, 얼굴에 초점을 맞춘 클로즈업"
```

#### 용도별 템플릿

**제품 이미지:**
```
[제품명]이 [배경]에 있습니다.
제품 촬영 스타일, 깨끗한 배경, 전문적인 조명
```

**캐릭터 디자인:**
```
[캐릭터 특징]을 가진 [캐릭터 유형]
[스타일] 스타일로 렌더링, [표정/포즈] 표현
```

**풍경 이미지:**
```
[장소]의 [시간대] 풍경
[분위기] 느낌의 [색조] 색상, [구도] 샷으로 촬영
```

---

## 목적별 추가 블록

### 코딩/개발
```xml
<coding_standards>
  - Follow existing project patterns
  - Include type annotations where applicable
  - Write testable, modular code
  - Handle errors appropriately
</coding_standards>
```

### 글쓰기/창작
```xml
<writing_style>
  - Tone: {formal/casual/technical/conversational}
  - Voice: {active/passive}
  - Target audience: {audience description}
  - Length: {word count or paragraph count}
</writing_style>
```

### 분석/리서치
```xml
<analysis_requirements>
  - Cite sources when available
  - Distinguish facts from interpretations
  - Acknowledge limitations and uncertainties
  - Provide actionable insights
</analysis_requirements>
```

### 에이전트/자동화
```xml
<agent_behavior>
  - Take action by default
  - Ask only when genuinely blocked
  - Complete tasks fully before stopping
  - Use tools efficiently
</agent_behavior>
```

### 데이터 처리
```xml
<extraction_spec>
  - Input format: {format}
  - Output format: {format}
  - Fields to extract: {field list}
  - Validation rules: {rules}
</extraction_spec>
```

---

## 상세도별 출력 지침

### I. 간결 (3-5문장)
```xml
<verbosity level="minimal">
  - 3-5 sentences maximum
  - Bullet points preferred
  - No elaboration
</verbosity>
```

### II. 보통 (1-2 문단)
```xml
<verbosity level="moderate">
  - 1-2 paragraphs
  - Key points with brief explanation
  - Examples only if essential
</verbosity>
```

### III. 상세 (구조화된 긴 응답)
```xml
<verbosity level="detailed">
  - Structured with headers
  - Comprehensive coverage
  - Examples and explanations included
</verbosity>
```

### IV. 가변 (상황에 따라)
```xml
<verbosity level="adaptive">
  - Scale response to task complexity
  - Simple tasks: brief
  - Complex tasks: detailed
</verbosity>
```

---

## Context Engineering 심층 통합

각 모델에 적용해야 할 Context Engineering 원칙을 정리합니다.

### Attention Budget 관리

중요 정보는 프롬프트 **시작 또는 끝**에 배치 (U자형 주의력 곡선):

```
[CRITICAL INSTRUCTIONS]     ← 시작에 배치 (높은 주의력)
[Background/Context]        ← 중간에 배치 (낮은 주의력)
[Detailed Examples]         ← 중간에 배치
[KEY CONSTRAINTS]           ← 끝에 배치 (높은 주의력)
```

### 컨텍스트 저하 방지

| 현상 | 설명 | 대응책 |
|------|------|--------|
| **Lost-in-Middle** | 중간 배치 정보 10-40% 낮은 회수율 | 중요 정보를 시작/끝에 배치 |
| **Context Poisoning** | 오류가 컨텍스트에 누적 | 도구 출력 검증, 명시적 정정 |
| **Context Distraction** | 무관한 정보가 주의력 빼앗음 | 관련성 필터링, 불필요한 정보 제외 |

### 모델별 저하 임계값

| 모델 | 저하 시작 | 심각한 저하 | 대응 |
|------|----------|-------------|------|
| **GPT-5.2** | ~64K 토큰 | ~200K 토큰 | Compaction 엔드포인트 활용 |
| **Claude 4.5 Opus** | ~100K 토큰 | ~180K 토큰 | Memory Tool/Context Editing 활용 |
| **Claude 4.5 Sonnet** | ~80K 토큰 | ~150K 토큰 | Sub-agent 분할 고려 |
| **Gemini 3 Pro** | ~500K 토큰 | ~800K 토큰 | 1M 컨텍스트지만 주의 필요 |

### 도구 설계 원칙

프롬프트에서 도구를 정의할 때:

1. **통합 원칙**: 여러 좁은 도구보다 포괄적인 단일 도구 선호
2. **명확한 설명**: what (무엇), when (언제), what returns (반환값) 명시
3. **MCP 네이밍**: 항상 `ServerName:tool_name` 형식 사용
4. **복구 가능한 에러**: 에러 메시지에 복구 방법 포함

### Context Engineering 적용 템플릿

각 모델 섹션에 다음 패턴을 적용:

```markdown
#### Context Engineering 적용

**Attention Budget**
- 중요 지시사항은 프롬프트 시작 또는 끝에 배치
- 배경 정보/예시는 중간에 배치

**Degradation Prevention**
- 컨텍스트 {임계값}K 토큰 초과 시 압축 고려
- 도구 출력이 누적되면 Observation Masking 적용

**Tool Design**
- 도구 설명에 what, when, what returns 포함
- 에러 메시지에 복구 방법 포함
```

---

## 프롬프트 개선 워크플로우

### Step 1: 초안 작성 (필수)

기본 템플릿에 역할과 핵심 지시 채우기:

```markdown
✅ 이 단계를 건너뛰지 마세요

1. 모델 선택 (GPT-5.2, Claude 4.5, Veo 등)
2. 기본 역할/페르소나 정의
3. 핵심 지시사항 3-5개 작성
```

### Step 2: 필수 블록 추가 (필수)

모델별 필수 XML/섹션 확인:

| 모델 | 필수 블록 |
|------|----------|
| **GPT-5.2** | `<output_verbosity_spec>` 항상 포함 |
| **GPT-5.2-Codex** | 최소 프롬프트, 서문 금지 명시 |
| **Claude 4.5** | 명시적 지시, `<default_to_action>` |
| **Veo** | 주제/동작/스타일 필수 |
| **Nano Banana** | 주제 설명/스타일/분위기 |

### Step 3: 목적별 블록 추가 (필수)

| 목적 | 추가할 블록 |
|------|------------|
| **코딩** | `<coding_standards>`, 테스트 규칙 |
| **분석** | `<uncertainty_and_ambiguity>`, 출처 인용 |
| **에이전트** | `<tool_usage_rules>`, 병렬 실행 규칙 |
| **추출** | `<extraction_spec>`, JSON 스키마 |
| **이미지** | 스타일/분위기/구도 명시 |
| **동영상** | 카메라/오디오/부정적 프롬프트 |
| **팩트체크** | IFCN 원칙, 4단계 워크플로우, 판정 등급 |
| **리서치** | 출처 투명성, 최신성 원칙, 구조화된 출력 |

### Step 4: Context Engineering 적용 (필수)

1. **중요 정보 배치 확인**: 시작 또는 끝에 있는가?
2. **불필요한 정보 제거**: 신호 대 잡음 비율 최적화
3. **토큰 효율성 검토**: 반복 제거, 핵심만 유지

### Step 5: 테스트 및 반복 (필수)

```markdown
1. 실제 입력으로 테스트
2. 문제점 발견 시 해당 블록 조정
3. 출력 길이/형식이 기대와 일치하는지 확인
```

### Step 6: 최종 검증 (필수)

체크리스트로 품질 확인:

```markdown
□ 역할이 명확한가?
□ 모델별 필수 블록이 있는가?
□ 중요 정보가 시작/끝에 있는가?
□ 불필요한 서술이 제거되었는가?
□ 출력 형식이 명시되었는가?
```

### Step 7: 전문가 3인 퇴고 (선택)

**트리거**: "퇴고해줘", "전문가 검토", "상세 퇴고" 요청 시 적용

#### 7.1 전문가 페르소나

| 역할 | 전문 분야 | 검토 초점 |
|------|----------|----------|
| **프롬프트 아키텍트** | Context Engineering, 토큰 최적화 | 구조, 효율성, 모델 특성 적합성 |
| **도메인 전문가** | 작업 유형별 전문 지식 | 내용 정확성, 완전성, 누락 요소 |
| **사용자 경험 디자이너** | UX Writing, 명확성 | 이해도, 모호성 제거, 실행 가능성 |

#### 7.2 퇴고 프로세스

```
1. 초안 생성 (Step 1-6 완료)
   ↓
2. 프롬프트 아키텍트 검토
   - CE 원칙 적용 여부
   - 모델별 필수 블록 확인
   - 토큰 효율성 검토
   ↓
3. 도메인 전문가 검토
   - 내용 정확성
   - 누락된 요소
   - 도메인 특화 개선점
   ↓
4. UX 디자이너 검토
   - 명확성/가독성
   - 모호한 표현 제거
   - 실행 가능성 확인
   ↓
5. 합의 도출 → 최종 프롬프트 출력
```

#### 7.3 퇴고 출력 형식

```markdown
## 전문가 퇴고 결과

### 프롬프트 아키텍트 의견
- ✅ [확인된 항목]
- ⚠️ 제안: [개선 사항]

### 도메인 전문가 의견
- ✅ [확인된 항목]
- ⚠️ 제안: [개선 사항]

### UX 디자이너 의견
- ✅ [확인된 항목]
- ⚠️ 제안: [개선 사항]

### 합의된 최종 프롬프트
[최종 프롬프트 코드블록]
```

#### 7.4 간략 vs 상세 퇴고

| 모드 | 트리거 | 출력 |
|------|--------|------|
| **간략 퇴고** | "퇴고해줘" | 3인 의견 요약 + 최종 프롬프트 |
| **상세 퇴고** | "상세 퇴고" | 체크리스트별 상세 검토 + 근거 + 최종 프롬프트 |

### Step 후 개선 제안

**Step 1 후:**
- GPT-5.2 선택 시: "reasoning_effort 레벨도 지정하시겠어요?"
- Claude 4.5 선택 시: "Extended Thinking 활성화가 필요한가요?"
- Veo 선택 시: "오디오 포함 여부를 확인해주세요"

**Step 3 후:**
- 코딩: "테스트 코드 포함 여부, 기존 패턴 따르기 등 명시할까요?"
- 분석: "출처 인용 스타일, 불확실성 표현 방식 정할까요?"
- 에이전트: "도구 사용 규칙, 병렬 실행 허용 여부 정할까요?"

**Step 6 후:**
- "출력 길이 제한을 더 명확히 할까요?"
- "예시를 추가하면 품질이 올라갈 수 있어요"
- "제약 조건을 더 구체화할까요?"

---

## 품질 체크리스트

### 공통 체크리스트
- [ ] 역할/페르소나가 명확히 정의됨
- [ ] 핵심 지시사항이 포함됨
- [ ] 출력 형식이 명시됨
- [ ] 불필요한 서술이 제거됨
- [ ] 중요 정보가 시작/끝에 배치됨

### 모델별 체크리스트

**GPT-5.2**:
- [ ] `<output_verbosity_spec>` 포함됨
- [ ] 목적에 맞는 XML 블록 추가됨
- [ ] reasoning_effort 고려됨

**GPT-5.2-Codex**:
- [ ] "Less is more" 원칙 적용됨
- [ ] 서문/맺음말 금지 명시됨
- [ ] 코드 스타일 가이드 포함됨

**Claude 4.5**:
- [ ] 모든 지시가 명시적임
- [ ] 암묵적 기대 없음
- [ ] 액션 기본값 설정됨

**Gemini 3**:
- [ ] 제약 조건이 먼저 배치됨
- [ ] 구조화된 출력 형식 사용됨

**Veo**:
- [ ] 주제/동작/스타일 필수 요소 포함됨
- [ ] 카메라 위치/구도/분위기 선택 요소 고려됨
- [ ] 오디오 프롬프트 적절히 사용됨 (Veo 3+)
- [ ] 부정적 프롬프트는 단순 나열로 작성됨

**Nano Banana (NB Pro / NB2)**:
- [ ] 주제가 명확히 기술됨
- [ ] 스타일/분위기/구도 포함됨
- [ ] NB2: 서술형 프롬프트 사용 (5요소 프레임워크)
- [ ] Veo 연동 시 이미지 형식 확인됨

---

## 프롬프트 생성 워크플로우

1. **모델 확인**: 타겟 모델의 특성 파악
2. **포맷 선택**: XML/Markdown/자연어/혼합
3. **구조 설계**: Context Engineering 원칙 적용
4. **블록 조합**: 목적별 필수 블록 추가
5. **상세도 조정**: 출력 길이 지침 추가
6. **검증**: 체크리스트로 품질 확인

---

## 에이전틱 워크플로우 패턴 (Agentic Workflow Patterns)

에이전트/도구 기반 프롬프트에서 사용할 수 있는 핵심 패턴입니다. GPT-5.4 Prompt Guidance 기반.

### 도구 지속성 (Tool Persistence)

도구 호출 실패 시 행동 규칙:

| 상황 | 행동 | 최대 재시도 |
|------|------|------------|
| 도구 호출 실패 | 대안 파라미터로 재시도 | 2회 |
| 빈 결과 | 대안 검색어로 재시도 | 2회 |
| 부분 결과 | 있는 결과로 진행, 누락 명시 | — |
| 모든 재시도 실패 | 사용자에게 보고 | — |

### 의존성 확인 (Dependency Check)

행동 전 전제 조건을 확인하는 패턴:
1. 필요한 정보가 컨텍스트에 있는지 검증
2. 부재 시: 도구로 탐색 → 없으면 질문
3. 가정(assumption)으로 진행 금지

### 완전성 계약 (Completeness Contract)

모든 항목 처리를 보장:
- 입력 목록의 모든 항목을 처리
- 처리 후 누락 항목 체크리스트 실행
- 누락 발견 시 즉시 보충
- 최종 출력에 "처리 완료: N/N건" 표시

### 적극성 제어 (Eagerness Control)

| 모드 | 설명 |
|------|------|
| `conservative` | 요청 범위 내에서만 행동, 추가 제안 자제 |
| `moderate` (기본) | 요청 + 명백히 유용한 추가 작업 |
| `aggressive` | 적극적으로 관련 작업 탐색 및 제안 |

### 빈 결과 복구 + 검증 루프 (Empty Result Recovery)

1. 빈 결과 시 대안 접근법으로 자동 재시도 (최대 2회)
2. 최종 출력 전 검증:
   - 요청된 모든 항목이 포함되었는가?
   - 형식이 출력 계약과 일치하는가?
   - 누락/불완전한 부분이 있는가?

---

## 참조 스킬

| 스킬 | 용도 |
|------|------|
| `context-engineering-collection` | 컨텍스트 엔지니어링 원칙 |
| `ce-context-fundamentals` | 기본 원칙 (시스템 프롬프트 구조화) |
| `ce-context-optimization` | 최적화 기법 (토큰 효율성) |
| `gpt-5.4-prompt-enhancement` | GPT-5.2/5.4 XML 패턴 상세 (에이전틱 패턴 포함) |
| `claude-4.6-prompt-strategies` | Claude 4.5/4.6 프롬프트 전략 가이드 |
| `gemini-3.1-prompt-strategies` | Gemini 3 프롬프트 전략 (NB2 포함) |
| `image-prompt-guide` | 이미지 생성 프롬프트 가이드 (공냥이 @specal1849 자료 기반) |
| `research-prompt-guide` | 팩트체크/리서치 프롬프트 가이드 (IFCN 원칙 기반) |

---

## 참고 문서 출처 (Reference Sources)

이 가이드 작성에 참고한 공식 문서 및 자료 목록입니다.

### OpenAI 공식 문서

| 문서 | URL | 주요 내용 |
|------|-----|----------|
| GPT-5.2 Prompting Guide | https://cookbook.openai.com/examples/gpt-5-2_prompting_guide | reasoning_effort, XML 구조, 장황함 제어 |
| GPT-5.4 Prompt Guidance | — | Output Contract, Agentic Patterns, Eagerness Control |
| GPT-5.2-Codex Prompting Guide | https://cookbook.openai.com/examples/gpt-5-codex_prompting_guide | 코딩 에이전트 전용 최적화, Anti-Prompting |
| Introducing GPT-5.2-Codex | https://openai.com/index/introducing-gpt-5-2-codex/ | Codex 모델 소개 및 특성 |

### Anthropic 공식 문서

| 문서 | URL | 주요 내용 |
|------|-----|----------|
| Claude 4.5 What's New | https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-5 | Claude 4.5 모델 변경사항, Extended Thinking |
| Claude 4.6 Prompt Guide | — | Adaptive Thinking, Effort Parameter, Prefill 제거, Over-prompting |
| Claude 4 Best Practices | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices | 명시적 지시, 병렬 도구 호출, 프론트엔드 가이드라인 |

### Google 공식 문서

| 문서 | URL | 주요 내용 |
|------|-----|----------|
| Veo API Documentation | https://ai.google.dev/gemini-api/docs/video?hl=ko | 동영상 생성 API, 확장, 참조 이미지 |
| Image Generation (Nano Banana) | https://ai.google.dev/gemini-api/docs/image-generation?hl=ko | 이미지 생성 API, 프롬프트 구조 |
| NanoBanana2 (NB2) Guide | — | NB2 서술형 프롬프트, 5요소 프레임워크, 14종 비율 |

### 내부 참조 자료

| 자료 | 위치 | 내용 |
|------|------|------|
| Threads 크롤링 결과 | `AI_Second_Brain/Threads/` | @choi.openai 게시물 기반 전략 |
| GPT-5.2 프롬프트 전략 | `AI_Second_Brain/Threads/GPT-5.2-프롬프트-전략.md` | 상세 프롬프트 패턴 |
| Claude 4.5 프롬프트 전략 | `AI_Second_Brain/Threads/Claude-4.5-프롬프트-전략.md` | Claude 전용 최적화 |

---

## 중간 구조화 워크플로우 (Step 1.7)

프롬프트 생성 전, 목적에 따라 **중간 구조화 단계**를 수행하여 품질을 높입니다.

> ⚠️ **CRITICAL: 동영상 생성 시 스토리보드 단계 생략 절대 금지**
> - 동영상 요청 시 **반드시** 스토리보드를 먼저 생성
> - 사용자가 스토리보드 확인 후 프롬프트 생성 진행
> - 이 단계를 건너뛰면 품질이 크게 저하됨

### 적용 조건

| 목적 | 구조화 유형 | 출력 형식 | 다음 단계 |
|------|------------|----------|----------|
| **동영상생성** | 스토리보드 | 시간순 장면 테이블 + JSON | 시간초별 프롬프트 생성 |
| **글쓰기/창작** | 개요 | 섹션별 목록 | 섹션별 프롬프트 생성 |
| **분석/리서치** | 개요 | 섹션별 목록 | 섹션별 프롬프트 생성 |

### 동영상: 스토리보드 생성 (MANDATORY)

**자동 수행 (생략 금지):**
1. 사용자 요청을 분석하여 스토리보드 생성
2. 시간순으로 장면 구성 (오프닝 → 전개 → 클라이막스)
3. 각 장면별: 설명, 캐릭터 행동, 조명/빛, 카메라 워크, 오디오 정의

**스토리보드 필수 요소 체크리스트:**

| 요소 | 설명 | 예시 |
|------|------|------|
| **sequence** | 장면 순서 | 1, 2, 3... |
| **duration** | 장면 길이 | "3s", "2.5s" |
| **description** | 장면 + 캐릭터 행동 + 조명/빛 | "Santa waves with rosy cheeks, golden glow from moon" |
| **camera** | 카메라 위치 + 모션 | "Wide establishing shot, slow pan following sleigh" |
| **audio** | 대사 + 효과음 + 배경음 | "Jingle bells, Santa's laugh: 'Ho ho ho!'" |

**스토리보드 출력 형식 (반드시 준수):**

```markdown
## 📋 스토리보드

### 장면 구성

| # | 시간 | 장면 설명 | 조명 | 카메라 | 오디오 |
|---|------|----------|------|--------|--------|
| 1 | 0-3초 | [장면 + 캐릭터 행동] | [조명/빛] | [카메라 워크] | [대사/효과음/배경음] |
| 2 | 3-6초 | [장면 + 캐릭터 행동] | [조명/빛] | [카메라 워크] | [대사/효과음/배경음] |
| 3 | 6-8초 | [장면 + 캐릭터 행동] | [조명/빛] | [카메라 워크] | [대사/효과음/배경음] |

### 프롬프트 JSON (상세)

---
✅ 이 스토리보드로 프롬프트를 생성할까요? (Y/수정 요청)
```

**스토리보드 기반 동영상 프롬프트 JSON (상세 예시):**

```json
{
  "model": "Veo 3.1",
  "shared_style": {
    "visual_style": "Cute and whimsical 2D storybook illustration, soft textures, vibrant festive colors (red, green, gold)",
    "color_grade": "Warm golden glow from the moon against a deep indigo starry night",
    "aspect_ratio": "16:9"
  },
  "scenes": [
    {
      "sequence": 1,
      "duration": "3s",
      "description": "Santa's sleigh pulled by reindeer enters from the left, flying over a cozy, snow-covered village with glowing windows. Stardust falls from the runners.",
      "camera": "Wide establishing shot, slow pan following the sleigh's path.",
      "audio": "Ambient quiet night, distant wind, and light jingle bells."
    },
    {
      "sequence": 2,
      "duration": "3s",
      "description": "Close-up on Santa Claus, rosy cheeks and a big smile. He waves his hand and tosses a brightly wrapped gift box toward a village chimney.",
      "camera": "Medium close-up on Santa, moving at the same speed as the sleigh.",
      "audio": "Santa's hearty laugh: 'Ho ho ho! Merry Christmas!'"
    },
    {
      "sequence": 3,
      "duration": "2s",
      "description": "The sleigh accelerates toward a large, bright full moon, becoming a silhouette while golden sparkles fill the screen.",
      "camera": "Zoom out showing the entire landscape as the sleigh disappears into the distance.",
      "audio": "Upbeat festive orchestral music reaching a gentle climax, then fading."
    }
  ],
  "negative": "realistic photography, 3D render, dark or scary atmosphere, distorted faces, wall, frame",
  "details": "High-quality digital illustration, clean outlines, cozy and joyful mood, magical glittering effects."
}
```

### 글쓰기/리서치: 개요 생성

**자동 수행:**
1. 사용자 요청을 분석하여 개요(아웃라인) 생성
2. 논리적 구조로 섹션 구성
3. 각 섹션별: 목표, 핵심 포인트 정의

**개요 출력 형식:**

```markdown
## 📋 개요

### 글 구조

1. **서론** - [핵심 메시지]
   - 도입부 훅
   - 배경 설명

2. **본론 1** - [첫 번째 논점]
   - 주요 내용
   - 예시/근거

3. **본론 2** - [두 번째 논점]
   - 주요 내용
   - 예시/근거

4. **결론** - [정리 및 Call-to-Action]
   - 요약
   - 다음 단계 제안

---
✅ 이 개요로 프롬프트를 생성할까요? (Y/수정 요청)
```

### 중간 구조화의 이점

1. **명확한 방향성**: 프롬프트 생성 전 구조 확정
2. **품질 향상**: 단계별 검토로 누락 방지
3. **사용자 참여**: 중간 확인으로 의도 반영
4. **일관성 유지**: 전체 흐름의 논리적 연결

---

## Skill Metadata

**Created**: 2025-12-27
**Last Updated**: 2026-03-08
**Author**: Claude Code
**Version**: 2.0.0

**Changes v2.0.0**:
- **[CRITICAL] Claude 4.6 모델 추가**: Adaptive Thinking, Effort Parameter, Prefill 제거 주의사항
- **[CRITICAL] Over-prompting 경고 추가**: 과도한 프롬프트의 역효과 섹션
- **[HIGH] 에이전틱 워크플로우 패턴 섹션 추가**: Tool Persistence, Dependency Check, Completeness Contract, Eagerness Control, Empty Result Recovery
- **[HIGH] GPT-5.4 XML 태그 추가**: output_contract, follow_through_policy, completeness_contract, eagerness_control, empty_result_recovery
- **[HIGH] NB2 이미지 모델 추가**: NB Pro vs NB2 비교 테이블, 5요소 프레임워크
- **[MEDIUM] 참조 스킬 테이블 업데이트**: gemini-3.1-prompt-strategies 추가, 기존 참조 설명 업데이트

**Changes v1.4.0**:
- **[MAJOR] 중간 구조화 워크플로우 (Step 1.7) 추가**: 동영상 스토리보드, 글쓰기/리서치 개요 생성
- 스토리보드 기반 동영상 JSON 구조 추가 (time_range, camera 필드)
- 개요 기반 글쓰기 프롬프트 구조 추가

**Changes v1.3.0**:
- 명시적 요소 확장 규칙 (Explicit Element Expansion) 섹션 추가
- 에이전트 모드 워크플로우 섹션 추가
- 목적별 확장 체크리스트 및 상세 예시 추가

**Changes v1.2.0**:
- 전문가 3인 퇴고 시스템 추가 (Step 7)
- 목적별 블록에 팩트체크/리서치 추가
- research-prompt-guide.md 스킬 참조 추가
