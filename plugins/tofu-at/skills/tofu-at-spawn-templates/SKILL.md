---
name: tofu-at-spawn-templates
description: Use when needing Agent Teams 역할별 스폰 프롬프트 템플릿 + 도구 할당 + /prompt CE 통합. /tofu-at가 팀원 스폰 시 참조.
disable-model-invocation: true
---

# Tofu-AT Spawn Prompt Templates

> `/tofu-at`가 팀원을 스폰할 때 사용하는 프롬프트 템플릿.
> 변수(`{{VAR}}`)를 실제 값으로 치환하여 사용.

---

## 빠른 참조 — 어떤 템플릿을 쓸까?

| 역할 | 참조 파일 | 섹션 |
|------|-----------|------|
| 최종 리드 (Lead) | `references/lead-templates.md` | Section 2 |
| 카테고리 리드 | `references/lead-templates.md` | Section 3 |
| 워커 (General-Purpose) | `references/worker-templates.md` | Section 4 |
| 기존 에이전트/스킬 래퍼 | `references/worker-templates.md` | Section 4.5 |
| 워커 (Explore 읽기전용) | `references/worker-templates.md` | Section 5 |
| codex-exec-worker Bridge | `references/worker-templates.md` | Section 9 |

---

## 1. 핵심 변수 (Key Variables)

| 변수 | 설명 | 소스 |
|------|------|------|
| `{{TEAM_ID}}` | 팀 ID | registry.yaml team_id |
| `{{TEAM_NAME}}` | TeamCreate에 전달할 팀 이름 | team_id에서 `.`을 `-`로 치환 |
| `{{PURPOSE}}` | 팀 목적 | registry.yaml purpose |
| `{{ROLE_NAME}}` | 에이전트 이름 | registry.yaml roles[].name |
| `{{ROLE_TYPE}}` | 역할 유형 | category_lead / worker |
| `{{MODEL}}` | 할당 모델 | registry.yaml roles[].model |
| `{{TOOLS}}` | 할당 도구 목록 | registry.yaml roles[].tools |
| `{{MCP_SERVERS}}` | 활성 MCP 서버 | .mcp.json + ToolSearch 결과 |
| `{{TASKS}}` | 할당된 태스크 | TaskCreate 결과 |
| `{{EXPERT_NAME}}` | 실존 전문가 이름 | Step 5-2 resolve_expert 결과 |
| `{{EXPERT_FRAMEWORK}}` | 핵심 프레임워크/저서 | Step 5-2 resolve_expert 결과 |
| `{{DOMAIN_VOCABULARY}}` | 전문가 핵심 용어 목록 (쉼표 구분) | Step 5-2 resolve_expert 결과 |
| `{{CLAUDE_BEHAVIOR_BLOCK}}` | Claude 최적화 XML 블록 | Step 5-5 결과 |

> 전체 변수 목록 (22개): `references/worker-templates.md` Section 1

---

## 2.5. 모델 배정 검증 (스폰 직전 — MANDATORY)

**모든 워커 스폰 전에 반드시 실행합니다. Opus 워커 배정을 자동 차단합니다.**

```
FOR each role IN spawn_queue:
  IF role.type == "worker" AND role.model == "opus":
    → user_explicitly_approved_opus_workers?
      → NO: role.model = "sonnet" (강제 다운그레이드)
             로그: "⚠️ {role.name}: opus → sonnet 다운그레이드 (사용자 미승인)"
      → YES: 진행 (STEP 2 응답 기록에 근거 명시)
```

**금지 패턴:**
- worker에 opus 배정 시 사용자 미승인이면 자동 차단
- "작업이 복잡해서 opus가 필요" 등 자의적 판단으로 업그레이드 금지
- STEP 2 응답에 명시적 기록 없으면 기본값(sonnet) 적용

> 비용 추정 표시 형식: `references/worker-templates.md` Section 2.5

---

## 6. 도구 할당 핵심 규칙

### MCP 정규화 이름 규칙
```
mcp__{서버명}__{도구명}
예: mcp__obsidian__create_note, mcp__playwright__browser_navigate
```

### CLI 우선 규칙
```
IF tool_paths[기능].method == "cli" → CLI 우선 (토큰 절약)
ELIF tool_paths[기능].method == "mcp" → MCP 사용
```

### Skill 도구 호출 규칙 (CRITICAL)

| 패턴 | 워커 행동 |
|------|----------|
| "/prompt 스킬로 리서치" | `Skill("prompt")` 직접 호출 |
| "km-workflow 스킬 적용" | `Skill("km-workflow")` 직접 호출 |
| "Skill('xxx')로 처리" | `Skill("xxx")` 직접 호출 |

**금지**: 스킬 파일을 `Read()`로 읽고 방법론만 따르는 "내재화"

> MCP 정규화 이름 전체 매핑 테이블: `references/worker-templates.md` Section 6

---

## 7. CE 체크리스트 (핵심)

```
[ ] U-shape 배치: 중요 지시(role, constraints)를 시작과 끝에 배치
[ ] Signal-to-noise: 불필요한 정보 제거, 핵심만 포함
[ ] 긍정형 프레이밍: "~하지 마라" 대신 "~해라" 우선 사용
[ ] 이유(Why) 포함: 각 제약에 이유 명시
[ ] 토큰 예산: 프롬프트 총 토큰 < 2000
```

> CE 상세 + /prompt 파이프라인 + Claude 전략: `references/ce-checklist.md`

---

## 8. 스폰 실행 패턴

```
# 병렬 스폰 (하나의 메시지에서) — 기본 1M
Task(name: "worker-1", model: "sonnet[1m]", team_name: "{{TEAM_NAME}}", run_in_background: true, prompt: "...")
Task(name: "worker-2", model: "haiku",      team_name: "{{TEAM_NAME}}", run_in_background: true, prompt: "...")

# 셧다운 시퀀스
SendMessage({ type: "shutdown_request", recipient: "{{ROLE_NAME}}", content: "작업 완료" })
TeamDelete()
```

> 스폰 결과 수신 처리: `references/worker-templates.md` Section 8

---

## 참조 파일 인덱스 (References)

| 파일 | 내용 | 섹션 |
|------|------|------|
| `references/lead-templates.md` | Lead/Category Lead 스폰 프롬프트 XML | 2, 3 |
| `references/worker-templates.md` | 전체 변수 목록 + Worker/Explore/Wrapper/Codex 프롬프트 + 도구 매핑 | 1, 4, 4.5, 5, 6, 8, 9 |
| `references/expert-db.md` | 27도메인 137명 전문가 DB + resolve_expert() 알고리즘 | 7.5 |
| `references/ce-checklist.md` | CE 체크리스트 + /prompt 파이프라인 + Claude 전략 + 프롬프트 엔지니어링 | 7, 7.6, 7.7, 7.8, 7.9 |
