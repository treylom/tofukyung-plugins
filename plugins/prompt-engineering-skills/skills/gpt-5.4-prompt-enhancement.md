# GPT-5.2/5.4 프롬프트 향상 스킬

> **Version**: 1.1.0 | **Updated**: 2026-03-08
> GPT-5.2/5.4 최적화 프롬프트 패턴 적용

## 개요

이 스킬은 사용자가 GPT-5.2/5.4용 프롬프트 생성을 요청할 때 OpenAI의 공식 프롬프팅 가이드에 기반한 최적화 패턴을 자동으로 적용합니다. GPT-5.4 Prompt Guidance의 최신 에이전틱 패턴을 포함합니다.

## 트리거 조건

다음 상황에서 이 스킬을 활성화:
- 사용자가 "GPT-5.2용 프롬프트" 또는 "GPT-5.4용 프롬프트" 생성 요청
- 사용자가 "ChatGPT 프롬프트" 작성 요청 후 GPT-5.2/5.4 확인됨
- 사용자가 프롬프트에 "5.2", "5.4", "GPT-5.2", "GPT-5.4" 언급

## 필수 적용 패턴

### 1. 장황함 제어 (output_verbosity_spec)

모든 GPT-5.2 프롬프트에 포함:

```xml
<output_verbosity_spec>
- 기본: 3-6문장 또는 글머리 5개 이하
- 예/아니오 질문: 2문장 이하
- 복잡한 작업: 개요 1문단 + 글머리 5개
- 긴 서술 문단 금지, 짧은 글머리 선호
- 사용자 요청 재진술 금지
</output_verbosity_spec>
```

### 2. 범위 제약 (design_and_scope_constraints)

코딩/디자인 작업 시 포함:

```xml
<design_and_scope_constraints>
- 요청한 것만 정확히 구현
- 추가 기능/컴포넌트/UX 개선 금지
- 모호하면 가장 단순한 해석 선택
</design_and_scope_constraints>
```

### 3. 불확실성 처리 (uncertainty_and_ambiguity)

정보 검색/분석 작업 시 포함:

```xml
<uncertainty_and_ambiguity>
- 모호하면 명확화 질문 1-3개 또는 2-3개 해석 제시
- 불확실하면 정확한 수치 조작 금지
- "제공된 맥락에 따르면..." 표현 사용
</uncertainty_and_ambiguity>
```

### 4. 도구 사용 규칙 (tool_usage_rules)

에이전트/도구 기반 작업 시 포함:

```xml
<tool_usage_rules>
- 내부 지식보다 도구 우선
- 독립적 읽기 작업은 병렬화
- 쓰기/업데이트 후 변경 사항 재진술
</tool_usage_rules>
```

### 5. 구조화된 추출 (extraction_spec)

데이터 추출 작업 시 포함:

```xml
<extraction_spec>
- 스키마 정확히 따르기 (추가 필드 금지)
- 소스에 없으면 null (추측 금지)
- 반환 전 누락 필드 재스캔
</extraction_spec>
```

### 6. 출력 계약 (output_contract) — GPT-5.4

모든 GPT-5.4 프롬프트에 포맷/길이/구조 계약 포함:

```xml
<output_contract>
- format: [markdown | json | plain_text | xml]
- max_length: [토큰 수 또는 "as_needed"]
- structure: [headings | bullet_list | numbered_steps | table]
- language: [ko | en | match_input]
</output_contract>
```

### 7. 후속 이행 정책 (follow_through_policy) — GPT-5.4

에이전트/도구 기반 작업 시 도구 호출 지속성 규칙:

```xml
<follow_through_policy>
- 도구 호출 실패 시: 1회 재시도 후 사용자에게 알림
- 빈 결과 시: 대안 검색어로 재시도 (최대 2회)
- 부분 결과 시: 있는 결과로 진행, 누락 부분 명시
- 사용자 확인 필요 시: 명확화 질문 1개 (선택지 포함)
</follow_through_policy>
```

### 8. 완전성 계약 (completeness_contract) — GPT-5.4

모든 항목 처리를 보장하는 패턴:

```xml
<completeness_contract>
- 입력 목록의 모든 항목을 처리할 것
- 처리 완료 후 누락 항목 체크리스트 실행
- 누락 발견 시 즉시 보충 (사용자 확인 불필요)
- 최종 출력에 "처리 완료: N/N건" 표시
</completeness_contract>
```

### 9. 에이전틱 패턴 (Agentic Patterns) — GPT-5.4

#### 9.1 도구 지속성 규칙 (Tool Persistence)

```xml
<tool_persistence>
- 도구 호출 실패 시 즉시 포기하지 말 것
- 대안 파라미터로 재시도 (최대 2회)
- 모든 재시도 실패 시에만 사용자에게 보고
- 성공한 부분 결과는 항상 활용
</tool_persistence>
```

#### 9.2 의존성 확인 패턴 (Dependency Check)

```xml
<dependency_check>
- 행동 전 전제 조건 확인
- 필요한 정보가 컨텍스트에 있는지 검증
- 부재 시: 도구로 탐색 → 없으면 질문
- 가정(assumption)으로 진행하지 말 것
</dependency_check>
```

#### 9.3 병렬 도구 호출 전략 (Parallel Calling)

```xml
<parallel_calling_strategy>
- 독립적인 정보 수집은 동시에 실행
- 의존 관계가 있는 호출은 순차 실행
- 병렬 결과를 종합하여 단일 응답으로 통합
</parallel_calling_strategy>
```

### 10. 적극성 제어 (Eagerness Control) — GPT-5.4

탐색 과잉/부족을 양방향으로 제어:

```xml
<eagerness_control>
- 탐색 과잉 방지: 요청 범위 내에서만 행동, 추가 기능 제안 자제
- 탐색 부족 방지: 모호한 요청도 가장 유용한 해석으로 진행
- 기본 모드: "moderate" (필요시 "aggressive" 또는 "conservative" 지정)
</eagerness_control>
```

### 11. 빈 결과 복구 + 검증 루프 (Empty Result Recovery) — GPT-5.4

```xml
<empty_result_recovery>
- 빈 결과 시 대안 검색어/접근법으로 자동 재시도
- 최대 2회 재시도 후 "결과 없음" 보고
- 최종 출력 전 검증 루프 실행:
  1. 요청된 모든 항목이 포함되었는가?
  2. 형식이 output_contract와 일치하는가?
  3. 누락/불완전한 부분이 있는가?
</empty_result_recovery>
```

### 12. 누락 컨텍스트 게이팅 (Missing Context Gating) — GPT-5.4

```xml
<missing_context_gating>
- 필수 정보 부재 시: 명확화 질문 (선택지 2-3개 포함)
- 선택적 정보 부재 시: 합리적 기본값으로 진행, 가정 명시
- 질문은 1회로 제한 (연쇄 질문 금지)
</missing_context_gating>
```

---

## 프롬프트 생성 워크플로우

1. **작업 유형 파악**: 코딩, 분석, 리서치, 추출 중 식별
2. **필수 패턴 선택**: 작업 유형에 맞는 XML 블록 선택
3. **프롬프트 구조화**:
   - 역할/페르소나 정의
   - 핵심 지시사항
   - 적용 가능한 XML 제약 블록
   - 출력 형식 지정
4. **검증**: 범위 표류 방지, 장황함 제어 포함 확인

## 예시: 웹 리서치 에이전트 프롬프트

```xml
<web_research_agent>
  <role>전문가 연구 보조자</role>

  <core_mission>
    - 사용자 질문에 완전하고 도움되게 답변
    - 사실 조작 금지, 검증 불가 시 명확히 진술
    - 기본값은 상세하고 유용하게
  </core_mission>

  <output_verbosity_spec>
    - 기본: 3-6문장 또는 글머리 5개 이하
    - 복잡한 질문: 개요 1문단 + 핵심 글머리
  </output_verbosity_spec>

  <uncertainty_and_ambiguity>
    - 불확실하면 웹 검색 선호
    - 모든 웹 정보에 인용 포함
    - 명확화 질문 금지, 모든 의도 포괄
  </uncertainty_and_ambiguity>
</web_research_agent>
```

## 참고 자료

- [[GPT-5.2-Prompting-Complete-Guide]]
- [[GPT-5.2-XML-프롬프트-모음]]
- [OpenAI Cookbook - GPT-5.2 Prompting Guide](https://cookbook.openai.com/examples/gpt-5/gpt-5-2_prompting_guide)

---

## Metadata

- **Version**: 1.1.0
- **Created**: 2025-12-28
- **Updated**: 2026-03-08
- **Changes v1.1.0**:
  - **[HIGH] Output Contract 블록 추가**: format, max_length, structure, language 계약
  - **[HIGH] Follow-Through Policy 블록 추가**: 도구 호출 지속성 규칙
  - **[HIGH] Completeness Contract 블록 추가**: 모든 항목 처리 보장
  - **[HIGH] Agentic Patterns 추가**: Tool Persistence, Dependency Check, Parallel Calling
  - **[MEDIUM] Eagerness Control 추가**: 탐색 과잉/부족 양방향 제어
  - **[MEDIUM] Empty Result Recovery 추가**: 빈 결과 복구 + 검증 루프
  - **[LOW] Missing Context Gating 추가**: 필수 정보 부재 시 질문 vs 추론 결정
- **Source**: OpenAI GPT-5.4 Prompt Guidance (2026-03)
