---
name: deep-research-source-quality
description: Use when needing a-E 소스 품질 등급 시스템 + IFCN 원칙 통합. /deep-research의 소스 신뢰도 평가 엔진.
---

# Deep Research Source Quality

> 소스 품질 등급 시스템 — IFCN(International Fact-Checking Network) 원칙 통합.
> /deep-research 파이프라인의 P2(수집), P3(교차검증), P5(QA)에서 사용.

---

## 1. 소스 품질 등급 (A-E)

| 등급 | 기준 | 신뢰도 | 예시 | 사용 규칙 |
|------|------|--------|------|----------|
| **A** | 1차 출처, 피어리뷰, 공식 통계 | 최고 | Nature, Science, IEEE, WHO 보고서, 국가 통계청 | 핵심 주장의 근거로 우선 사용 |
| **B** | 권위있는 2차 출처, 공식 문서 | 높음 | W3C, FDA, Gartner 보고서, 공식 API 문서, RFC | A와 함께 주요 근거로 사용 |
| **C** | 전문 미디어, 평판 좋은 블로그 | 보통 | TechCrunch, InfoQ, The Verge, 유명 개발자 블로그 | 트렌드/의견 인용 시 사용, 사실 주장에는 교차검증 필요 |
| **D** | 프리프린트, 화이트페이퍼, 기업 블로그 | 낮음 | arXiv 프리프린트, 기업 기술 블로그, 마케팅 자료 | 참고용만, 단독 근거 사용 금지, [preprint] 또는 [unreviewed] 태깅 |
| **E** | 미확인, 소셜미디어, 포럼 | 최저 | Reddit, X(Twitter), 커뮤니티 포럼, 위키 | **보고서에 사용 금지** — 조사 방향 참고만 |

---

## 2. 등급 판정 알고리즘

```
FUNCTION grade_source(source):
  # Step 1: 도메인 기반 초기 등급
  domain = extract_domain(source.url)

  IF domain IN tier_a_domains:
    grade = "A"
  ELIF domain IN tier_b_domains:
    grade = "B"
  ELIF domain IN tier_c_domains:
    grade = "C"
  ELIF domain IN tier_d_domains:
    grade = "D"
  ELSE:
    grade = "D"  # 미분류 도메인 기본값

  # Step 2: 콘텐츠 기반 조정
  IF source.has_peer_review:
    grade = min(grade, "A")
  IF source.has_citations AND source.citation_count >= 10:
    grade = upgrade(grade, 1)  # 한 단계 승격
  IF source.is_preprint:
    grade = max(grade, "D")  # D 이하로 강제
  IF source.is_social_media OR source.is_forum:
    grade = "E"  # E로 강제

  # Step 3: 날짜 기반 감점
  IF source.published_date < 2_years_ago:
    grade = downgrade(grade, 1)  # 한 단계 강등 (빠르게 변하는 분야)

  RETURN grade
```

### Tier A 도메인 (예시)

```
nature.com, science.org, ieee.org, acm.org,
who.int, cdc.gov, nih.gov, fda.gov,
worldbank.org, imf.org, oecd.org,
kostat.go.kr (통계청), kosis.kr
```

### Tier B 도메인 (예시)

```
w3c.org, ietf.org, rfc-editor.org,
docs.anthropic.com, platform.openai.com,
cloud.google.com/docs, docs.aws.amazon.com,
gartner.com, forrester.com, mckinsey.com
```

### Tier C 도메인 (예시)

```
techcrunch.com, theverge.com, arstechnica.com,
infoq.com, zdnet.com, wired.com,
blog.google, openai.com/blog, anthropic.com/research
```

### Tier D 도메인 (예시)

```
arxiv.org, ssrn.com, biorxiv.org,
medium.com, dev.to, hashnode.com,
corporate blog domains (일반)
```

---

## 3. IFCN 원칙 통합

> International Fact-Checking Network 5대 원칙을 리서치 프로세스에 적용.

| IFCN 원칙 | 리서치 적용 | 검증 방법 |
|-----------|-----------|----------|
| **비당파성** (Non-partisanship) | 찬반 양측 소스 균형 수집 | P3에서 opposing_sources >= 1 확인 |
| **소스 투명성** (Transparency of Sources) | 모든 소스 URL + 접근일 기록 | sources.jsonl에 메타데이터 필수 |
| **재정 투명성** (Transparency of Funding) | 기업 후원 연구 표시 | [sponsored] 태그 자동 부여 |
| **방법론 투명성** (Transparency of Methodology) | 검색 쿼리 + 필터 기록 | state.json에 query_log 저장 |
| **공개 수정** (Open & Honest Corrections) | 업데이트 시 변경 이력 유지 | output/에 revision_log.md |

---

## 4. 품질 보고서 (quality_report.md) 형식

```markdown
# 소스 품질 보고서

## 등급 분포
| 등급 | 개수 | 비율 |
|------|------|------|
| A | {n} | {%} |
| B | {n} | {%} |
| C | {n} | {%} |
| D | {n} | {%} |
| E | {n} | 사용안함 |

**B+ 비율**: {(A+B)/total}% (목표: ≥80%)

## 교차검증 결과
| 핵심 주장 | 소스 수 | 상태 | 비고 |
|----------|--------|------|------|
| {claim_1} | {n} | verified/single_source/disputed | {notes} |

## 잠재적 편향
- {bias_1}: {설명}
- {bias_2}: {설명}

## 미확인 주장
- {unverified_1}: 추가 조사 권장
```

---

## 5. 수집 소스 메타데이터 (sources.jsonl)

각 소스를 JSON Lines 형식으로 기록:

```json
{
  "id": "src-001",
  "url": "https://nature.com/articles/...",
  "title": "Article Title",
  "domain": "nature.com",
  "grade": "A",
  "grade_reason": "peer-reviewed journal",
  "accessed": "2026-03-03T12:00:00Z",
  "published": "2026-02-15",
  "author": "Author Name",
  "claims_supported": ["claim-1", "claim-3"],
  "subtopic": "subtopic-2",
  "collector": "academic-searcher",
  "notes": "Key finding on page 5"
}
```

---

## 6. 워커 프롬프트 주입

P2 수집 에이전트에게 주입하는 품질 기준:

```xml
<source_quality_protocol>
  소스 수집 시 반드시 품질 등급을 태깅하세요.

  등급 기준:
  - A: 피어리뷰, 공식 통계 → 핵심 근거로 우선 사용
  - B: 공식 문서, 권위있는 보고서 → 주요 근거
  - C: 전문 미디어, 유명 블로그 → 트렌드/의견 인용
  - D: 프리프린트, 기업 블로그 → 참고만, [preprint] 태깅
  - E: 소셜미디어, 포럼 → 보고서에 사용 금지

  목표: 수집 소스의 80% 이상이 B등급 이상
  규칙: E등급 소스는 조사 방향 참고만 가능, 인용 불가
  형식: sources.jsonl에 기록 (위 스키마 참조)
</source_quality_protocol>
```

---

## 7. /prompt 기존 research-prompt-guide 통합

기존 `.claude/skills/research-prompt-guide.md`의 IFCN 원칙과 통합:
- research-prompt-guide의 "검증 가능성" 원칙 → P3 교차검증에 반영
- "다중 소스 의무" 원칙 → 핵심 주장당 2+ 소스 규칙으로 구체화
- "편향 인식" 원칙 → quality_report.md의 "잠재적 편향" 섹션으로 구조화
