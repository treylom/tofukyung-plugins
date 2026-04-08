---
name: deep-research-pipeline
description: Use when needing 7-Phase 리서치 엔진 — 서브토픽 분해, 병렬 수집, 교차검증, 합성, QA. /deep-research 커맨드의 핵심 엔진.
---

# Deep Research Pipeline Engine

> `/deep-research` 커맨드의 핵심 파이프라인 스펙.
> 서브토픽 분해 → 병렬 수집 → 교차검증 → 합성 → QA → 출력.

---

## 1. Phase Flow Diagram

```
P0 (Scoping) → P1 (Planning) → P2 (Collection) → P3 (Triangulation) → P4 (Synthesis) → P5 (QA) → P6 (Output)
     │               │              │                    │                   │              │           │
     └─ Lead         └─ Lead        └─ 3 Agents          └─ Cross-Ref        └─ Synth       └─ QA       └─ Lead
                                       (parallel)           Agent              Agent          Agent
```

### Phase 의존성 매트릭스

| Phase | 입력 | 출력 | 선행 Phase | 병렬 가능 |
|-------|------|------|-----------|----------|
| P0 | 사용자 입력 | 스코핑 파라미터 | 없음 | - |
| P1 | 스코핑 파라미터 | 서브토픽 + 쿼리 계획 | P0 | - |
| P2 | 쿼리 계획 | 소스 컬렉션 (sources.jsonl) | P1 | 에이전트 간 병렬 |
| P3 | 소스 컬렉션 | 교차검증 결과 | P2 | - |
| P4 | 교차검증 결과 | 보고서 초안 | P3 | - |
| P5 | 보고서 초안 | 검증 보고서 | P4 | - |
| P6 | 검증 보고서 | 최종 산출물 | P5 | - |

---

## 2. P2 Detailed: Parallel Collection Strategy

3개 에이전트가 서로 다른 검색 전략으로 병렬 수집합니다.

### 에이전트 역할 분담

```
web-searcher-1 (Broad Search):
  - 대상: 일반 웹, 뉴스 사이트, 블로그, 포럼
  - 전략: 넓은 범위의 검색 쿼리, 다양한 관점 수집
  - 도구: WebSearch + WebFetch
  - 목표: 서브토픽당 5-10개 소스
  - 우선 소스: 주요 언론, 기술 블로그 (TechCrunch, Wired, The Verge 등)

web-searcher-2 (Targeted Search):
  - 대상: 특정 도메인, 산업 리포트, 경쟁사 분석
  - 전략: 도메인 한정 검색 ("site:"), 정확한 키워드 매칭
  - 도구: WebSearch + WebFetch
  - 목표: 서브토픽당 3-5개 소스
  - 우선 소스: 공식 블로그, 산업 분석 리포트, 벤치마크 결과

academic-searcher (Scholarly Search):
  - 대상: arxiv, IEEE, ACM, 공식 기술 문서
  - 전략: 학술 키워드, 저자명, DOI 기반 검색
  - 도구: WebSearch + hyperbrowser (MCP)
  - 목표: 서브토픽당 3-5개 소스
  - 우선 소스: 피어리뷰 논문, 공식 문서, 기술 명세서
```

### 수집 프로토콜

```
각 에이전트 공통 프로토콜:

1. 검색 실행
   WebSearch(query) → 결과 목록

2. 소스 접근
   WebFetch(url) → 본문 추출
   실패 시: hyperbrowser fallback (academic-searcher)

3. 품질 평가 (즉시)
   소스 등급 A-E 태깅 (deep-research-source-quality.md 기준)
   E등급 소스는 수집하되 분석에서 제외

4. 메타데이터 기록
   sources.jsonl에 append:
   {
     "url": "...",
     "title": "...",
     "author": "...",
     "date": "...",
     "grade": "B",
     "accessed": "2026-03-03",
     "subtopic": "...",
     "claims": [],
     "searcher": "web-searcher-1",
     "notes": "..."
   }

5. 핵심 주장 추출
   소스에서 핵심 주장 1-5개 추출
   각 주장을 claims[] 배열에 기록

6. 진행 상태 업데이트
   state.json의 subtopics[].sources_count 증가
```

### 수집 중단 조건

```
서브토픽별 중단 판정:

IF sources_count >= target AND grade_B_plus_ratio >= 0.8:
  → 수집 완료 (충분한 고품질 소스 확보)

ELIF search_queries_exhausted:
  → 대체 쿼리 생성 (최대 2회 추가 시도)

ELIF access_failures >= 5 consecutive:
  → 에이전트 경로 변경 (WebFetch → hyperbrowser)

ELIF total_time > timeout (깊이별 상이):
  → 현재까지 수집된 소스로 진행 (경고 표시)
```

---

## 3. P3 Detailed: Triangulation Algorithm

수집된 소스를 교차검증하여 주장의 신뢰도를 판정합니다.

### 교차검증 절차

```
Step 1: 주장 통합
  - 3개 에이전트의 claims[] 배열 병합
  - 중복 주장 통합 (의미적 유사도 기반)
  - 고유 주장 목록 생성

Step 2: 주장별 소스 매핑
  FOR each claim IN unique_claims:
    sources = find_all_sources_supporting(claim)
    domains = extract_unique_domains(sources)

Step 3: 독립성 판정
  FOR each source_pair IN sources:
    IF same_domain(source_pair):
      → 종속 소스 (같은 도메인 = 독립성 불인정)
    ELIF one_cites_other(source_pair):
      → 종속 소스 (인용 관계)
    ELSE:
      → 독립 소스

Step 4: 신뢰도 판정
  FOR each claim:
    independent_sources = count_independent(sources)
    IF independent_sources >= 2:
      → claim.status = "verified"
      → claim.confidence = "high"
    ELIF independent_sources == 1:
      → claim.status = "single_source"
      → claim.confidence = "medium"
    ELIF sources_contradict:
      → claim.status = "disputed"
      → claim.confidence = "low"
      → claim.dispute_detail = {side_a: [...], side_b: [...]}
    ELSE:
      → claim.status = "unverified"
      → claim.confidence = "none"

Step 5: 모순 분석
  FOR each disputed_claim:
    1. 양측 주장 나란히 기록
    2. 각 측 소스의 등급/신뢰도 비교
    3. 제3 소스 탐색 (WebSearch 추가 1회)
    4. 판정 불가 시 "disputed" 유지 + 양측 제시
```

### 교차검증 출력 형식 (triangulation.md)

```markdown
# 교차검증 결과

## 검증 통계
- 총 주장: {N}개
- Verified: {N}개 ({%})
- Single Source: {N}개 ({%})
- Disputed: {N}개 ({%})
- Unverified: {N}개 ({%})

## 주장별 상세

### [Verified] {주장 내용}
- 소스 1: [Title](URL) (Grade: A)
- 소스 2: [Title](URL) (Grade: B)
- 독립성: 확인됨 (도메인 상이, 인용 관계 없음)

### [Disputed] {주장 내용}
- 측 A: "{주장 A}" — [Source](URL) (Grade: B)
- 측 B: "{주장 B}" — [Source](URL) (Grade: B)
- 판정: 제3 소스 미발견, 양측 제시
```

---

## 4. P5 Detailed: Chain-of-Verification

보고서 내 핵심 주장을 독립적으로 재검증합니다.

### 검증 절차

```
Step 1: 핵심 주장 선별
  - 보고서에서 가장 중요한 주장 5-10개 선별
  - 선별 기준: Executive Summary 포함 주장, 결론에 영향 주는 주장

Step 2: 검증 질문 생성
  FOR each core_claim:
    verification_question = generate_question(claim)
    예시:
      주장: "GPT-5.2는 멀티모달 벤치마크에서 1위"
      질문: "GPT-5.2의 멀티모달 벤치마크 순위에 대한 독립적 증거는?"

Step 3: 독립 증거 검색
  FOR each verification_question:
    WebSearch(question) → 새로운 소스에서 답변 탐색
    기존 소스 풀과 겹치지 않는 소스 우선

Step 4: 원본 소스 대조
  FOR each claim:
    IF new_evidence == consistent_with(original_source):
      → claim.verified = true
    ELIF new_evidence contradicts original_source:
      → claim.flagged = "potential_hallucination"
      → 원본 소스 재확인 + 보고서 수정 권고
    ELIF no_new_evidence_found:
      → claim.verified = "unable_to_verify"
      → 보고서에 한계점 명시

Step 5: 결과 기록
  quality_report.md에 검증 결과 기록:
    | 주장 | 원본 소스 | 검증 결과 | 비고 |
    |------|----------|----------|------|
```

### 할루시네이션 탐지 패턴

```
다음 패턴 발견 시 할루시네이션 경고:

1. 구체적 수치인데 소스에 해당 수치 없음
2. 인용한 논문/저자가 실제 존재하지 않음
3. 날짜/이벤트가 소스의 내용과 불일치
4. "According to..." 패턴인데 해당 소스에 관련 내용 없음
```

---

## 5. Source Collection Format

### sources.jsonl 스키마

```json
{
  "id": "src_001",
  "url": "https://example.com/article",
  "title": "Article Title",
  "author": "Author Name",
  "date": "2026-02-15",
  "grade": "A",
  "grade_rationale": "피어리뷰 학술지, 저자 전문성 확인",
  "accessed": "2026-03-03",
  "subtopic": "AI Agent Memory",
  "claims": [
    "에이전트 메모리는 3가지 유형으로 분류된다",
    "장기 메모리가 에이전트 성능에 가장 큰 영향을 미친다"
  ],
  "searcher": "academic-searcher",
  "content_hash": "sha256:...",
  "notes": "2026년 1월 발행, 최신 벤치마크 포함"
}
```

### 중복 소스 탐지

```
수집 시 중복 판정:
  IF url already in sources.jsonl:
    → 스킵 (동일 URL)
  IF content_hash matches existing:
    → 스킵 (동일 콘텐츠, 다른 URL)
  IF title + author matches existing:
    → 경고 후 수집 (미러/재게시 가능성)
```

---

## 6. Output Quality Metrics

### 목표 지표

| Metric | 빠른개요 | 표준 | 딥다이브 | Measurement |
|--------|---------|------|---------|-------------|
| Source Grade Distribution | >=70% B+ | >=80% B+ | >=80% B+ & >=60% A | count(A+B) / total |
| Citation Coverage | 90%+ | 100% | 100% | claims_with_source / total_claims |
| Cross-Verification | >=50% core | >=70% core | >=80% core | verified / core_claims |
| Source Diversity | >=2 domains | >=3 domains | >=5 domains | unique_domains count |
| Freshness | any | >=50% <1yr | >=70% <1yr | recent_sources / total |

### quality_report.md 출력 형식

```markdown
# 소스 품질 평가 보고서

## 리서치 메타데이터
- 주제: {topic}
- 깊이: {depth}
- 수집 기간: {start} ~ {end}
- 총 소스: {N}개

## 등급 분포
| 등급 | 개수 | 비율 | 목표 |
|------|------|------|------|
| A (최고 신뢰) | {N} | {%} | - |
| B (높은 신뢰) | {N} | {%} | - |
| C (보통 신뢰) | {N} | {%} | - |
| D (낮은 신뢰) | {N} | {%} | - |
| E (미신뢰) | {N} | {%} | 분석 제외 |
| **B+ 합계** | **{N}** | **{%}** | **>=80%** |

## 품질 게이트 결과
| 지표 | 결과 | 목표 | 통과 |
|------|------|------|------|
| 소스 등급 B+ | {%} | >=80% | PASS/FAIL |
| 인용 커버리지 | {%} | 100% | PASS/FAIL |
| 교차검증 | {%} | >=70% | PASS/FAIL |
| 소스 다양성 | {N} domains | >=3 | PASS/FAIL |

## Chain-of-Verification 결과
| # | 핵심 주장 | 원본 소스 | 독립 검증 | 결과 |
|---|----------|----------|----------|------|
```

---

## 7. Error Recovery & Resilience

### Phase별 실패 대응

| Phase | 실패 유형 | 대응 |
|-------|----------|------|
| P2 | WebSearch rate limit | 에이전트 간 쿼리 재분배, 대기 후 재시도 |
| P2 | WebFetch 접근 차단 | hyperbrowser 폴백, 캐시된 버전 검색 |
| P2 | 소스 부족 (<50% 목표) | 쿼리 확장, 동의어/관련어 추가 검색 |
| P3 | 교차검증 불가 (독립 소스 부족) | "single_source" 태깅 후 진행, 한계 명시 |
| P4 | 합성 중 모순 발견 | P3로 회귀하여 추가 교차검증 |
| P5 | 할루시네이션 탐지 | 해당 주장 제거 또는 수정 후 재합성 |

### 세션 재개 안전성

```
state.json은 각 Phase 완료 시 업데이트.
Phase 중간 실패 시:
  - 완료된 Phase 결과는 보존
  - 실패한 Phase부터 재시작
  - sources.jsonl은 append-only이므로 중복 수집 방지
```

---

## 8. Depth-Specific Configuration

### 빠른개요 (Quick)

```yaml
depth: quick
agents: [web-searcher-1, synthesizer, qa-reviewer]
sources_per_subtopic: 3-5
subtopics: 2-3
timeout_minutes: 10
ralph_loop: disabled
output: 1-2 페이지 요약
```

### 표준 (Standard)

```yaml
depth: standard
agents: [web-searcher-1, web-searcher-2, academic-searcher, cross-reference, synthesizer, qa-reviewer]
sources_per_subtopic: 5-10
subtopics: 3-5
timeout_minutes: 30
ralph_loop: optional (1 iteration)
output: 3-5 페이지 보고서
```

### 딥다이브 (Deep Dive)

```yaml
depth: deep
agents: [web-searcher-1, web-searcher-2, web-searcher-3, academic-searcher-1, academic-searcher-2, cross-reference, synthesizer, qa-reviewer, fact-checker]
sources_per_subtopic: 10-15
subtopics: 5-7
timeout_minutes: 60
ralph_loop: enabled (max 3 iterations)
output: 10+ 페이지 보고서 + 부록
```

---

## 9. /tofu-at 워크플로우 엔진 통합

### 에이전트 유닛 분해

이 파이프라인을 tofu-at-workflow.md 기준으로 분해하면:

```
| 유닛 | 카테고리 | subagent_type | 모델 | 도구 |
|------|---------|---------------|------|------|
| Lead (오케스트레이터) | Foundation | general-purpose | opus | 전체 |
| web-searcher-1 | Ingest | Explore | sonnet | WebSearch, WebFetch |
| web-searcher-2 | Ingest | Explore | sonnet | WebSearch, WebFetch |
| academic-searcher | Ingest | Explore | sonnet | WebSearch, hyperbrowser |
| cross-reference | Analyze | Explore | sonnet | Read, Grep |
| synthesizer | Analyze | general-purpose | sonnet | Read, Write |
| qa-reviewer | QA | Explore | sonnet | WebSearch, Read |
```

### 카테고리 매핑 (tofu-at-workflow.md 섹션 4 참조)

```
- Lead: Foundation (오케스트레이션)
- web-searcher-*: Ingest (crawl, scrape, extract, fetch, web)
- academic-searcher: Ingest (fetch, extract)
- cross-reference: Analyze (analyze, classify)
- synthesizer: Analyze (summarize, tag)
- qa-reviewer: QA (verify, quality)
```

### Ralph 루프 적용 기준 (tofu-at-workflow.md 섹션 8 참조)

```
리서치 워크플로우 → Ralph 권장 (분석/리서치 = 검증 중요)

설정:
  ralph_loop:
    enabled: true (standard/deep), false (quick)
    max_iterations: 1 (standard), 3 (deep)
    review_criteria:
      citation_coverage: { weight: 1.5, target: "100%" }
      source_quality: { weight: 1.0, target: "B+ >= 80%" }
      cross_verification: { weight: 1.0, target: ">= 70%" }
      completeness: { weight: 1.0, target: "모든 서브토픽 커버" }
```
