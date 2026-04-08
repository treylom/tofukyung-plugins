---
name: tofu-at-workflow
description: Use when needing 워크플로우 분석 + 리소스 동적 탐색 + Agent Teams 분해 로직. /tofu-at 커맨드의 핵심 엔진.
---

# Tofu-AT Workflow Engine

> `/tofu-at` 커맨드의 핵심 분석 엔진.
> 리소스 탐색 → 워크플로우 분석 → 에이전트 유닛 분해 → 팀 구성안 생성.

---

## 엔진 개요 (4단계 흐름)

```
STEP 1: 리소스 스캔 (Phase A-D)
  → Skills/Agents/Commands + MCP 서버 + CLI 도구 + 최적 경로 결정

STEP 2: 워크플로우 분석
  → 대상 파일 읽기 → Phase 의존성 그래프 → 리소스 매칭

STEP 3: 에이전트 유닛 분해
  → 각 Phase → subagent_type + 모델 결정

STEP 4: 팀 구성안 생성
  → Lead/Worker 배정 + ASCII 흐름도 + Phase Coverage 검증
```

> 리소스 스캔 알고리즘 상세 (Phase A-D): `references/resource-scanning.md`

---

## 2. 워크플로우 분석 알고리즘 (핵심)

### Step 2-1: 파일 읽기 + 구조 추출

```
Read(대상 파일) → 전문 읽기

추출 대상:
  A. frontmatter → name, description, allowedTools, model
  B. H2/H3 헤더 → Phase/Step 단위 (각각이 에이전트 유닛 후보)
  C. 도구 참조 패턴:
     - "mcp__서버명__도구명" → MCP 도구 의존성
     - "Bash(", "Read(", "Write(" → 내장 도구
     - "Task(" → 서브에이전트 패턴
     - "TeamCreate(", "SendMessage(" → Agent Teams 패턴
     - "AskUserQuestion(" → 사용자 인터랙션 포인트
  D. 입출력 패턴: "inputs:", "outputs:", "→", "handoff:"
  E. 의존성 패턴: "blockedBy", "병렬", "동시에"
```

### Step 2-1.5: 관련 문서 컨텍스트 로딩 (스코프 한정)

```
탐색 범위 (3단계, 순차):
  1. {target_dir}/CHANGELOG.md → 최근 5개 ## 엔트리
  2. {target_dir}/BUGS.md → "미해결"/"Open" 섹션
  3. Bug_Reports/Bug-*-{component_name}*.md → 최대 3개 (status/open만)

금지:
  ❌ Glob("**/*.md")        — 전체 스캔
  ❌ Glob("Bug_Reports/*.md") — 전체 버그 목록

총 예산: ~800 토큰
```

> 컨텍스트 로딩 상세 (출력 형식, 팀 구성 반영): `references/phase-details.md` §2-1.5

### Step 2-2: Phase 의존성 그래프

```
각 Phase를 노드로, 데이터 흐름을 엣지로:
  병렬화 판정:
  - 서로 다른 입력 → 병렬 가능
  - 같은 파일/리소스 수정 → 순차 필수
  - 독립적 검색/분석 → 병렬 가능
  - 결과 통합 필요 → 이전 완료 후
```

### Step 2-3: 리소스 매칭

```
워크플로우 필요 도구 ↔ Phase D 인벤토리 매칭
→ 최적 경로 할당 (Phase D 매트릭스)
→ 부족 리소스 식별 → 설치 제안
```

---

## 3. 에이전트 유닛 분해 규칙

### 분해 기준

| 기준 | 판정 | 결과 |
|------|------|------|
| Phase가 독립적인 입출력을 가짐 | O | 독립 에이전트 유닛 |
| Phase가 읽기만 수행 | O | Explore subagent_type |
| Phase가 쓰기(Write/Edit/MCP write) 수행 | O | general-purpose, 리드/Main 전용 |
| Phase가 사용자 인터랙션 포함 (AskUserQuestion) | O | Main 전용 (위임 불가) |
| Phase가 외부 API/MCP 호출 포함 | O | 해당 MCP 접근 필요 |
| Phase가 다른 Phase 결과에 의존 | O | 순차 실행 (blockedBy) |

### subagent_type 결정

```
IF 유닛이 읽기 전용 (검색, 분석, 탐색):
  subagent_type = "Explore"
  tools = [Read, Glob, Grep]

ELIF 유닛이 쓰기 필요:
  subagent_type = "general-purpose"
  tools = [Read, Write, Edit, Bash, Glob, Grep] + 필요 MCP 도구

ELIF 유닛이 계획/설계:
  subagent_type = "Plan"
  tools = [Read, Glob, Grep] (읽기 전용)
```

### 모델 할당 (routing_policy)

| 역할 | 기본 모델 | Task 파라미터 | 비고 |
|------|---------|-------------|------|
| 최종 리드 (Lead) | opus 1M | (CC 시작 시 자동) | 항상 고정 |
| 카테고리 리드 | opus 1M | model: "opus[1m]" | 핵심 조율 + 1M 컨텍스트 |
| 워커 (읽기 전용) | haiku | model: "haiku" | 검색/분류 |
| 워커 (구현/분석) | sonnet 1M | model: "sonnet[1m]" | 코드/분석 + 1M 컨텍스트 |
| 워커 (고위험) | opus 1M | model: "opus[1m]" | 드물게 사용 |

---

## 4. 카테고리 매핑 테이블

| 키워드/패턴 | 카테고리 | team_id 접두사 | 대표 팀 예시 |
|------------|---------|---------------|------------|
| crawl, scrape, extract, fetch, url, web, pdf, social | **Ingest** | `km.ingest.*` | km.ingest.web.standard |
| analyze, summarize, tag, classify, zettelkasten, atomize | **Analyze** | `km.analyze.*` | km.analyze.zettelkasten |
| graph, link, wikilink, index, pagerank, expand, rank | **Graph** | `km.graph.*` | km.graph.build-index |
| save, export, obsidian, notion, local, store, vault | **Storage** | `km.store.*` | km.store.obsidian |
| dashboard, monitor, event, log, collect, sse, websocket | **Ops** | `ops.dashboard.*` | ops.dashboard.collector |
| test, verify, lint, quality, hook, gate, ownership | **QA** | `qa.*` | qa.hooks.quality-gates |
| design, layout, component, UI, frontend, react, css | **Frontend** | `frontend.*` | frontend.dashboard.ui |
| prompt, generate, template, tofu-at, clone, catalog | **Foundation** | `wf.tofu-at.*` | wf.tofu-at.classify-and-catalog |

**카테고리 매칭 알고리즘:**
```
1. 대상 파일 텍스트에서 키워드 빈도 계산
2. 각 카테고리별 키워드 매칭 점수 합산
3. 최고 점수 카테고리 = 주 카테고리
4. 2개 이상 점수가 높으면 → 다중 카테고리
5. 매칭 없으면 → "custom" 카테고리
```

---

## 5. 팀 구성안 출력 포맷 (핵심)

```markdown
## 워크플로우 분석 결과: {스킬명}

### 식별된 에이전트 유닛 ({N}개)
| # | 유닛명 | 카테고리 | 모델 | subagent_type | 필요 도구 | 병렬 | 쓰기 |

### 제안 팀 구성
| 역할 | 에이전트명 | 모델 | subagent_type | 담당 유닛 |

### 워크플로우 흐름 (ASCII 다이어그램)
Phase 1: {병렬}    Phase 2: {병렬}    Phase 3: {순차}
┌─────────────┐   ┌──────────────┐   ┌──────────────┐
│ {agent_1}   │─┐ │ {agent_3}    │─┐ │ DA           │
│ {agent_2}   │─┤>│ {agent_4}    │─┤>│              │
└─────────────┘   └──────────────┘   └──────────────┘
```

> 팀 구성안 생성 상세 + Phase Coverage 검증 + /prompt 파이프라인 통합:
> `references/phase-details.md`

---

## 참조 파일 인덱스 (References)

| 파일 | 내용 | 섹션 |
|------|------|------|
| `references/resource-scanning.md` | Phase A-D 리소스 스캔 알고리즘 + 대시보드 통합 + 텍스트 인벤토리 | Section 1 |
| `references/phase-details.md` | 워크플로우 분석 상세 + 팀 구성 + 공유 메모리 설계 + Ralph 루프 + DEAD_ENDS | Section 2, 5, 5.1, 5.5, 6, 7, 7.2, 8 |
| `references/error-handling.md` | Split Pane 안정성 이슈 + Dynamic Gate 검증 + Self-Check List | Section 7(플랫폼), 8, 9 |
