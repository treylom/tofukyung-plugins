# Deep Research

## 설치

```bash
# 1. 스킬/커맨드/에이전트 복사
cp -r skills/ ~/.claude/skills/
cp -r commands/ ~/.claude/commands/
cp -r agents/ ~/.claude/agents/
```

## 사용법

```
/deep-research                                          # 인터랙티브 (주제 질문부터)
/deep-research AI 에이전트 메모리 아키텍처 2026 트렌드    # 주제 직접 지정
/deep-research resume {session-id}                       # 이전 세션 재개
/deep-research status                                    # 진행 중 리서치 확인
/deep-research query                                     # 구조화 쿼리 빌더
```

## 리서치 깊이

| 깊이 | 소스 수 | 보고서 길이 | 소요 시간 |
|------|--------|-----------|----------|
| 빠른개요 | 5-10 | 1-2페이지 | ~10분 |
| 표준 | 15-25 | 3-5페이지 | ~30분 |
| 딥다이브 | 30+ | 10+페이지 | ~60분 |

## 선택 의존성

다음 플러그인이 설치되어 있으면 자동으로 연동됩니다:
- **knowledge-manager**: 콘텐츠 추출, 이미지 파이프라인 활용
- **tofu-at**: Agent Teams로 병렬 수집 (표준/딥다이브)
- **prompt-engineering-skills**: 워커 프롬프트 최적화
