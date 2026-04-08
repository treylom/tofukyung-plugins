# 수강생 메모리 스키마

수강생 프로필의 JSON 구조와 저장 규칙을 정의한다.

---

## 저장 위치

```
.lesson-memory/{이름}-{과정ID}.json
```

예시:
- `.lesson-memory/홍길동-MW4.json`
- `.lesson-memory/김영희-CC101.json`

---

## JSON 스키마

```json
{
  "name": "홍길동",
  "company": "성우하이텍",
  "department": "R&D",
  "role": "CAE 엔지니어",
  "ai_level": "beginner",
  "course_id": "MW4",
  "created_at": "2026-03-29",
  "updated_at": "2026-03-29",
  "completed_lessons": [],
  "struggles": [],
  "strengths": [],
  "preferences": {
    "pace": "normal",
    "examples": "general"
  },
  "notes": ""
}
```

---

## 필드 정의

### 기본 정보

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `name` | string | ✅ | 수강생 이름 |
| `company` | string | 선택 | 소속 회사 |
| `department` | string | 선택 | 부서명 |
| `role` | string | 선택 | 담당 업무/직책 |
| `course_id` | string | ✅ | 수강 중인 과정 ID (예: MW4, CC101) |
| `created_at` | string | ✅ | 프로필 생성일 (YYYY-MM-DD) |
| `updated_at` | string | ✅ | 마지막 업데이트일 (YYYY-MM-DD) |

### 학습 수준

`ai_level` 값:

| 값 | 의미 | 안내 방식 |
|----|------|----------|
| `beginner` | AI/코딩 처음 | 모든 것을 단계별로 상세 설명 |
| `intermediate` | 조금 써본 적 있음 | 핵심만 설명, 배경 포함 |
| `advanced` | 자주 사용함 | 목표만 제시, 방법은 자율 |

인터뷰 매핑:
- "처음이에요" → `beginner`
- "가끔 써봤어요" / "조금 써봤어요" → `intermediate`
- "자주 써요" / "잘 알아요" → `advanced`

### 학습 이력

| 필드 | 타입 | 설명 | 예시 |
|------|------|------|------|
| `completed_lessons` | array | 완료한 교시 목록 | `["MW4-1교시", "MW4-2교시"]` |
| `struggles` | array | 어려웠던 개념/명령어 | `["git push", "터미널 명령어"]` |
| `strengths` | array | 잘 이해한 부분 | `["개념 이해", "질문 잘 함"]` |

### 학습 선호도

`preferences` 객체:

| 키 | 값 예시 | 의미 |
|----|---------|------|
| `pace` | `slow` / `normal` / `fast` | 진행 속도 선호 |
| `examples` | `general` / `manufacturing` / `engineering` | 예시 도메인 |

### 기타

| 필드 | 설명 |
|------|------|
| `notes` | 강사/TA 메모 (특이사항, 배려 필요 사항 등) |

---

## 기본값 (인터뷰 정보 없을 때)

```json
{
  "name": "수강생",
  "company": "",
  "department": "",
  "role": "",
  "ai_level": "beginner",
  "course_id": "{COURSE_ID}",
  "created_at": "{오늘 날짜}",
  "updated_at": "{오늘 날짜}",
  "completed_lessons": [],
  "struggles": [],
  "strengths": [],
  "preferences": {
    "pace": "normal",
    "examples": "general"
  },
  "notes": ""
}
```

---

## 업데이트 규칙

1. **매 교시 완료 시**: `completed_lessons`에 추가, `updated_at` 갱신
2. **트러블슈팅 발생 시**: `struggles`에 해당 항목 추가
3. **칭찬 포인트 발생 시**: `strengths`에 해당 항목 추가
4. **세션 종료 시**: 전체 프로필 저장

---

## 파일 예시

`.lesson-memory/홍길동-MW4.json`:

```json
{
  "name": "홍길동",
  "company": "성우하이텍",
  "department": "R&D",
  "role": "CAE 엔지니어",
  "ai_level": "beginner",
  "course_id": "MW4",
  "created_at": "2026-03-29",
  "updated_at": "2026-03-29",
  "completed_lessons": ["MW4-1교시", "MW4-2교시"],
  "struggles": ["git push 명령어"],
  "strengths": ["Claude 프롬프트 이해 빠름"],
  "preferences": {
    "pace": "slow",
    "examples": "manufacturing"
  },
  "notes": "CAE 전문가 — 시뮬레이션 예시로 설명하면 이해 빠름"
}
```
