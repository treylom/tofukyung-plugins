---
name: deep-research
description: "7-Phase 멀티소스 딥리서치 — 소스 검증 + 교차검증 + 인라인 인용"
allowedTools: Agent, AskUserQuestion, Read, Write, Glob, Grep, WebSearch, WebFetch, Bash, TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, SendMessage, ToolSearch, Skill
---

# /deep-research — 멀티소스 딥리서치 엔진

> **Version**: 2.1.0
> 멀티소스 리서치 → 교차검증 → 구조화 보고서를 자동 생성합니다.
> 참조 스킬: `deep-research-pipeline.md`, `deep-research-source-quality.md`, `km-content-extraction.md`, `km-image-pipeline.md`, `research-prompt-guide.md`
> 참조 에이전트: `deep-researcher.md`
> 참조 커맨드: `tofu-at.md`, `tofu-at-codex.md`, `prompt.md`

$ARGUMENTS

<mindset priority="HIGHEST">
천천히, 최선을 다해 작업하세요.

핵심 역할: **멀티소스 리서치 → 교차검증 → 구조화 보고서**
1. 모든 주장에 인라인 인용 필수
2. 소스 등급 B 이상 80% 유지
3. 핵심 주장은 2+ 독립 소스로 교차검증
4. 미확인 주장은 명시적 [unverified] 태깅
</mindset>

---

## Subcommand Routing

| Pattern | Mode | Description |
|---------|------|-------------|
| (empty) | interactive | AskUserQuestion으로 주제 수집 |
| `{topic}` | direct | 주제 직접 시작 |
| `resume {session-id}` | resume | 이전 세션 재개 |
| `status` | status | 진행 중 리서치 상태 확인 |
| `query` | query | 구조화 쿼리 빌더 |

### 라우팅 알고리즘
```
IF $ARGUMENTS == empty:
  → interactive 모드 (P0 Scoping 전체 실행)
ELIF $ARGUMENTS starts with "resume":
  → session-id 추출 → state.json 로드 → 중단된 Phase부터 재개
ELIF $ARGUMENTS == "status":
  → Library/Research/deep-research/ 폴더 스캔 → 진행 중 세션 목록 출력
ELIF $ARGUMENTS == "query":
  → 구조화 쿼리 빌더 (서브토픽 + 소스유형 + 필터 직접 지정)
ELSE:
  → direct 모드 (P0의 주제 질문 스킵, 나머지 스코핑 질문만 수행)
```
---

## P0: Scoping (Lead)

사용자로부터 리서치 범위를 확정합니다.

AskUserQuestion (최대 3개 질문):

```
1. 리서치 깊이:
   - 빠른개요 (5-10 소스, 1-2페이지 보고서)
   - 표준 (15-25 소스, 3-5페이지 보고서)
   - 딥다이브 (30+ 소스, 10+ 페이지 보고서)

2. 소스 유형 선호:
   - 웹 (뉴스, 블로그, 포럼)
   - 학술 (논문, 기술 문서)
   - 기술문서 (공식 문서, API 레퍼런스)
   - 전체 (모든 유형 포함)

3. 출력 형식:
   - 마크다운보고서 (Library/Research/deep-research/ 폴더에 저장)
   - Obsidian노트 (vault에 Zettelkasten 형식으로 저장)
   - 웹사이트 (정적 HTML 보고서)

4. 언어:
   - 한국어 (기본)
   - 영어
   - 혼합 (소스는 원문, 분석은 한국어)
```
---

## P0.5: Environment Detection & Execution Mode (Lead)

P0 완료 후 자동으로 실행 환경을 감지하고 실행 모드를 결정합니다.

### 환경 감지 (자동)
```bash
# 각 명령어를 Bash로 실행하여 가용 여부 확인
which tmux          # Agent Teams 가능 여부
which codex         # tofu-at-codex 가능 여부
curl -s --max-time 3 http://127.0.0.1:8317/health  # Codex 프록시 정상 여부
python3 -c "import scrapling" 2>/dev/null           # KM 크롤러 가용 여부
which playwright    # Playwright CLI 가용 여부
```

### 실행 모드 결정 로직
```
depth = P0에서 사용자가 선택한 깊이

IF depth == "빠른개요":
  → mode = "single" (Agent 도구만, 팀 구성 없음)

ELIF depth == "표준":
  IF tmux_available:
    → mode = "tofu-at" (Agent Teams, Sonnet 워커)
  ELSE:
    → mode = "parallel-agents" (Agent 도구 병렬)

ELIF depth == "딥다이브":
  IF codex_available AND proxy_healthy:
    → mode = "tofu-at-codex" (Opus + GPT-5.4 하이브리드)
  ELIF tmux_available:
    → mode = "tofu-at" (Agent Teams 폴백)
  ELSE:
    → mode = "parallel-agents" (Agent 도구 폴백)

IF mode 결정 불가 OR 경계 케이스:
  → AskUserQuestion으로 사용자에게 선택 요청
```

### 크롤러 가용성 → 폴백 체인 결정
```
IF scrapling_available:
  → crawler_chain = "scrapling → playwright-cli → Playwright MCP → WebFetch"
ELIF playwright_available:
  → crawler_chain = "playwright-cli → Playwright MCP → WebFetch"
ELSE:
  → crawler_chain = "WebFetch" (최소 폴백)
```

### 상태 출력
```
🔍 환경 감지 완료:
  - 실행 모드: {mode}
  - 크롤러: {crawler_chain}
  - 팀 구성: {team_description}
```
---

## P1: Retrieval Planning (Lead)

주제를 서브토픽으로 분해하고 검색 전략을 수립합니다.

```
1. 주제를 3-5 서브토픽으로 분해
   - 각 서브토픽에 1줄 정의 + 핵심 질문 1-2개

2. 각 서브토픽에 검색 쿼리 3-5개 생성
   - 영어 쿼리 (최신 결과 확보)
   - 한국어 쿼리 (국내 관점)
   - 학술 쿼리 ("site:arxiv.org", "site:ieee.org" 등)

3. 서브토픽 간 의존성 매핑
   - 독립 서브토픽 → 병렬 수집 가능
   - 의존 서브토픽 → 순차 수집 (선행 결과 필요)

4. 에이전트 할당 계획
   - web-searcher-1: 서브토픽 A, B (broad)
   - web-searcher-2: 서브토픽 C, D (targeted)
   - academic-searcher: 전체 서브토픽 (scholarly)
```
---

## P1.5: Worker Prompt Generation (Lead)

P1에서 생성된 서브토픽과 쿼리를 기반으로, 실행 모드에 맞는 구조화 워커 프롬프트를 생성합니다.

### 모드별 프롬프트 생성
```
IF mode == "tofu-at" (워커 = Sonnet):
  → Skill("prompt", "--batch Claude 상세 {서브토픽별 리서치 수집 지시}")
  → Claude 최적화: <default_to_action>, <use_parallel_tool_calls> 자동 포함

IF mode == "tofu-at-codex" (워커 = GPT-5.4):
  → Skill("prompt", "--batch GPT-5.2 상세 {서브토픽별 리서치 수집 지시}")
  → GPT 최적화: <output_verbosity_spec>, <web_search_rules>, <uncertainty_and_ambiguity> 자동 포함

IF mode == "single" 또는 "parallel-agents":
  → Skill("prompt", "--batch Claude 상세 {서브토픽별 리서치 수집 지시}")
  → Claude 최적화 + research-prompt-guide.md StructuredResearch_v1.0 구조 병합
```

### 워커 프롬프트 구조
```xml
<worker_prompt name="{role}" model="{target_model}">
  <role>멀티소스 웹 리서치 수집 에이전트</role>

  <assigned_subtopics>
    <subtopic id="{N}" name="{서브토픽명}">
      <core_question>{핵심 질문}</core_question>
      <search_queries>
        <query lang="en">{영어 쿼리}</query>
        <query lang="ko">{한국어 쿼리}</query>
      </search_queries>
    </subtopic>
  </assigned_subtopics>

  <collection_rules>
    <rule>서브토픽당 소스 {N}개 수집</rule>
    <rule>소스 등급 B 이상 80% 유지</rule>
    <rule>각 소스에서 핵심 주장 1-5개 추출</rule>
    <rule>모든 소스에 품질 등급(A-E) 태깅</rule>
  </collection_rules>

  <tool_priority>
    <step>1. WebSearch(query) → 결과 URL 목록 확보</step>
    <step>2. 소스 유형 판정 → KM 크롤러 자동 분기 (P2 참조)</step>
    <step>3. 콘텐츠 추출 + 이미지 auto 모드</step>
    <step>4. sources.jsonl 형식으로 메타데이터 기록</step>
  </tool_priority>

  <model_specific_block/>

  <output_format>
    {
      "subtopic": "...",
      "sources": [sources.jsonl 엔트리 배열],
      "claims": [추출된 주장 배열],
      "images": [수집된 이미지 경로 배열],
      "status": "completed|partial",
      "notes": "특이사항"
    }
  </output_format>
</worker_prompt>
```

### P3/P5 워커 프롬프트도 동일 방식 생성
```
cross-reference 워커:
  → /prompt --batch {모델} 상세 "소스 교차검증 및 모순 분석"
  → research-prompt-guide.md § 1.1 LoopFactChecker 구조 기반

qa-reviewer 워커:
  → /prompt --batch {모델} 상세 "Chain-of-Verification 핵심 주장 검증"
  → research-prompt-guide.md § 1.2 QuickFactCheck 구조 기반
```
---

## P2: Iterative Querying (Parallel Agents)

3개 에이전트가 병렬로 소스를 수집합니다.

### 에이전트 스폰
```
Agent spawn:
  - web-searcher-1: WebSearch + WebFetch (뉴스, 트렌드, 시장 데이터)
  - web-searcher-2: WebSearch + WebFetch (특정 도메인, 경쟁사, 심층 분석)
  - academic-searcher: WebSearch + hyperbrowser (논문, 기술 문서, 공식 문서)
```

### 에이전트별 수집 전략

| 에이전트 | 검색 범위 | 소스 수 목표 | 주요 도구 |
|---------|----------|------------|----------|
| web-searcher-1 | 일반 웹, 뉴스, 블로그 | 서브토픽당 5-10개 | WebSearch, WebFetch |
| web-searcher-2 | 특정 도메인, 산업 리포트 | 서브토픽당 3-5개 | WebSearch, WebFetch |
| academic-searcher | arxiv, IEEE, 공식 문서 | 서브토픽당 3-5개 | WebSearch, hyperbrowser |

### 소스 품질 태깅

각 수집 소스에 품질 등급(A-E)을 태깅합니다.
상세 기준: `deep-research-source-quality.md` 참조.

```
수집 소스 → 품질 평가 → sources.jsonl에 기록:
  {"url": "...", "title": "...", "grade": "A", "accessed": "2026-03-03", "claims": ["claim1"], "notes": "..."}
```
---

## P3: Source Triangulation (Cross-Reference Agent)

핵심 주장별 독립 소스 교차 확인을 수행합니다.

### 교차검증 알고리즘
```
FOR each claim IN synthesized_claims:
  sources = find_supporting_sources(claim)
  IF len(sources) >= 2 AND sources_are_independent:
    → claim.status = "verified"
  ELIF len(sources) == 1:
    → claim.status = "single_source" (포함하되 한계 명시)
  ELIF sources_contradict:
    → claim.status = "disputed" (양측 입장 모두 제시)
  ELSE:
    → claim.status = "unverified" (명시적 태깅)
```

### 모순 처리 규칙
```
소스 간 모순 발견 시:
  1. 양측 주장을 나란히 제시
  2. 각 소스의 신뢰도(등급) 명시
  3. 가능하면 제3 소스로 판정
  4. 불가능하면 "disputed" 상태로 보고서에 포함
```

---

## P4: Synthesis (Synthesizer Agent)

교차검증 결과를 구조화된 보고서로 합성합니다.

### 인라인 인용 형식

```
학술 소스: [Author, Year]
웹 소스: [Source Title](URL)
복합 참조: [Author, Year; Source Title](URL)
```

### 보고서 논리 구조

```
1. Executive Summary (핵심 발견 3-5줄)
2. 서브토픽별 분석
   - 각 서브토픽: 배경 → 현황 → 분석 → 시사점
   - 모든 주장에 인라인 인용 첨부
3. 비교표 (해당 시)
   - 솔루션/제품/접근법 비교 매트릭스
4. 타임라인 (해당 시)
   - 주요 이벤트 시간순 정리
5. 결론 및 제언
   - 핵심 인사이트 요약
   - 후속 리서치 제안
```

### 시각화 포함

```
- ASCII 테이블: 비교 데이터
- Mermaid 다이어그램: 관계/흐름 시각화 (Obsidian 호환)
- 인라인 통계: 핵심 수치 강조
```

---

## P5: QA & Fact-Check (QA Agent)

Chain-of-Verification으로 핵심 주장을 검증합니다.

### Chain-of-Verification 절차

```
FOR each core_claim (상위 5-10개 핵심 주장):
  1. 검증 질문 생성
     "이 주장이 사실이라면 어떤 증거가 있어야 하는가?"
  2. 독립 증거 검색
     WebSearch로 검증 질문에 대한 답변 탐색
  3. 원본 소스 대조
     검증 결과와 원본 소스 진술 비교
  4. 불일치 플래그
     IF mismatch → 잠재적 할루시네이션으로 플래그
  5. 결과 기록
     quality_report.md에 검증 결과 로깅
```

### 품질 검증 체크리스트

```
□ 인용 커버리지: 모든 주장에 소스가 있는가?
□ 소스 등급 분포: B등급 이상 80% 이상인가?
□ 교차검증 비율: 핵심 주장의 70% 이상 verified인가?
□ 소스 다양성: 3개 이상 고유 도메인에서 수집했는가?
□ 할루시네이션 체크: 소스와 진술이 일치하는가?
□ 날짜 유효성: 인용 소스의 접근 날짜가 기록되어 있는가?
```

---

## P6: Output (Lead)

최종 산출물을 생성하고 저장합니다.

### 출력 디렉토리 구조

```
Library/Research/deep-research/{topic}_{timestamp}/
├── state.json            # Phase 진행 상태 (재개 가능)
├── report.md             # 최종 보고서
├── sources/
│   └── sources.jsonl     # 수집 소스 메타데이터
├── analysis/
│   ├── triangulation.md  # 교차검증 중간 결과
│   └── subtopics/        # 서브토픽별 분석 원문
├── output/
│   ├── bibliography.md   # 참고문헌
│   └── quality_report.md # 소스 품질 평가 결과
└── README.md             # 세션 요약 (주제, 깊이, 소스 수, 품질 점수)
```

### state.json 스키마

```json
{
  "session_id": "topic_20260303_1430",
  "topic": "...",
  "depth": "standard",
  "current_phase": "P3",
  "subtopics": [
    {"name": "...", "status": "completed", "sources_count": 12},
    {"name": "...", "status": "in_progress", "sources_count": 5}
  ],
  "total_sources": 17,
  "quality_score": null,
  "created_at": "2026-03-03T14:30:00Z",
  "updated_at": "2026-03-03T15:10:00Z"
}
```

### 출력 형식별 후처리

```
마크다운보고서:
  → Library/Research/deep-research/{topic}_{timestamp}/ 에 저장 (기본, Obsidian Sync 친화)

Obsidian노트:
  → vault의 Library/Research/ 폴더에 MOC + 원자 노트 생성
  → Zettelkasten 형식 (wikilink, 태그, frontmatter)
  → 기존 노트와 자동 연결 (Grep으로 관련 노트 탐색)

웹사이트:
  → 정적 HTML 보고서 생성 (단일 파일)
  → 인라인 CSS + 반응형 레이아웃
```

---

## Session Management

### 세션 재개

```
/deep-research resume {session-id}

1. state.json 로드
2. 현재 Phase 확인
3. 이미 수집된 소스 로드 (sources.jsonl)
4. 중단된 Phase부터 재개
5. 완료된 서브토픽은 스킵
```

### 세션 상태 확인

```
/deep-research status

→ Library/Research/deep-research/ 폴더 스캔
→ 각 세션의 state.json 읽기
→ 진행 상태 테이블 출력:

| Session ID | 주제 | Phase | 소스 수 | 최종 업데이트 |
|-----------|------|-------|--------|-------------|
```

---

## /tofu-at 통합

registry.yaml 팀 템플릿:

```yaml
- team_id: research.deep-research.quick
  roles: [web-searcher-1, synthesizer, qa-reviewer]
  models: { lead: opus, workers: sonnet }
  quality_gates: { source_quality: "B 이상 80%", citation_coverage: "100%" }
  depth: quick

- team_id: research.deep-research.standard
  roles: [web-searcher-1, web-searcher-2, academic-searcher, cross-reference, synthesizer, qa-reviewer]
  models: { lead: opus, workers: sonnet }
  quality_gates: { source_quality: "B 이상 80%", citation_coverage: "100%" }
  depth: standard

- team_id: research.deep-research.deep
  roles: [web-searcher-1, web-searcher-2, web-searcher-3, academic-searcher-1, academic-searcher-2, cross-reference, synthesizer, qa-reviewer, fact-checker]
  models: { lead: opus, workers: sonnet }
  quality_gates: { source_quality: "A 이상 60%", citation_coverage: "100%", cross_verification: "80%" }
  depth: deep
```
---

## 사용 예시

| 모드 | 명령어 |
|------|--------|
| Interactive | `/deep-research` |
| Direct | `/deep-research AI 에이전트 메모리 아키텍처 2026 트렌드` |
| Resume | `/deep-research resume {session-id}` |
| Status | `/deep-research status` |
| Query | `/deep-research query` |

## 금지 행동 (Anti-patterns)

- ❌ 소스 등급 미태깅 상태로 보고서 합성
- ❌ 단일 소스만으로 핵심 주장 verified 처리
- ❌ 교차검증 없이 P4 합성 단계 진입
- ❌ WebSearch 결과를 검증 없이 그대로 인용
- ❌ state.json 미저장 상태로 Phase 전환
