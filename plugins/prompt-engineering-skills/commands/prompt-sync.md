# /prompt-sync - 프롬프트 생성기 통합 업데이트 에이전트

프롬프트 생성기 시스템(GPTs, Gems, Skills, Obsidian, Windows, 배포 GitHub)을 **6경로 동시 동기화**합니다.

> **Version**: 3.1.0 | **Updated**: 2026-05-02
> **부모 Repo**: `treylom/obsidian-ai-vault` (`prompt-engineering-skills/`는 그 하위 폴더)
> **배포 Repo**: `treylom/prompt-engineering-skills` (사용자 설치/동기화용 별도 미러)
> **호환성**: Claude Opus 4.7 / Sonnet 4.6 / GPT-5.5 outcome-first / GPT-5.4 legacy XML 통합

$ARGUMENTS

---

## 🚨 실제 저장소 구조 (CRITICAL)

```
📁 /home/tofu/AI/ (= obsidian-ai-vault Git repo, 권원)
│   git remote: https://github.com/treylom/obsidian-ai-vault.git
│
│   ├── .claude/
│   │   ├── commands/{prompt.md, GPTs-Prompt-Generator.md, prompt-sync.md}
│   │   └── skills/{gpt-5.5-prompt-enhancement.md, claude-4.7-prompt-strategies.md, ...}
│   │
│   ├── prompt-engineering-skills/  ← 원본 (수정 대상, master 권원)
│   │   ├── commands/{prompt.md, prompt-sync.md}
│   │   ├── instructions/{GPTs-Prompt-Generator.md, Gems-Prompt-Generator.md}
│   │   ├── skills/*.md  (9개)
│   │   ├── examples/*.md  (3개)
│   │   ├── README.md, LICENSE
│   │
│   └── AI_Second_Brain/050-Prompt-Engineering/
│       ├── GPTs-Prompt-Generator-Instructions.md  (사본)
│       ├── Gems-Prompt-Generator-Instructions.md  (사본)
│       └── prompt-engineering-skills/  (전체 미러 사본)

📁 별도 배포 repo: https://github.com/treylom/prompt-engineering-skills
   - 사용자가 `git clone https://github.com/treylom/prompt-engineering-skills.git`로 받음
   - 부모 repo 변경 후 별도 clone 위치에 미러 + 자체 master에 push
   - 권한: 부모 repo와 별개의 commit history (단순 미러)
```

---

## 📌 6경로 동시 동기화

**원본**(권원): `/home/tofu/AI/prompt-engineering-skills/`

**사본 6위치** (rsync `--delete`로 미러 + git push):

| # | 위치 | 용도 | 동기화 방식 |
|---|------|------|------------|
| 1 | `/home/tofu/AI/.claude/commands/, .claude/skills/` | Claude Code 로컬 | 개별 파일 cp |
| 2 | `/home/tofu/AI/AI_Second_Brain/050-Prompt-Engineering/prompt-engineering-skills/` | WSL Obsidian vault | 전체 미러 rsync |
| 3 | `/mnt/c/Users/treyl/Documents/Obsidian/Second_Brain/AI_Second_Brain/050-Prompt-Engineering/prompt-engineering-skills/` | Win Obsidian vault — 050 폴더 | 전체 미러 rsync |
| 4 | `/mnt/c/Users/treyl/Documents/Obsidian/Second_Brain/prompt-engineering-skills/` | Win Obsidian vault — root | 전체 미러 rsync |
| 5 | `/mnt/c/Users/treyl/OneDrive/Desktop/AI/prompt-engineering-skills/` | Win OneDrive AI 폴더 | 전체 미러 rsync |
| **6** | `/tmp/pes-deploy/prompt-engineering-skills/` (clone) | **배포 repo** `treylom/prompt-engineering-skills` | rsync 미러 + `git add . && git commit && git push` |

**보조 사본** (Instructions 단독):
- `/home/tofu/AI/AI_Second_Brain/050-Prompt-Engineering/{GPTs,Gems}-Prompt-Generator-Instructions.md`
- `/mnt/c/Users/treyl/Documents/Obsidian/Second_Brain/AI_Second_Brain/050-Prompt-Engineering/{GPTs,Gems}-Prompt-Generator-Instructions.md`
- `/mnt/c/Users/treyl/Documents/Obsidian/Second_Brain/Library/Prompt-Engineering/{GPTs,Gems}-Prompt-Generator-Instructions.md`

---

## 🛠 1-Shot 동기화 명령 (Bash)

**모든 수정이 완료된 후 한 번에 실행하면 6위치 + 보조 사본 모두 갱신:**

```bash
SRC=/home/tofu/AI/prompt-engineering-skills

# 1) 5경로 미러 (rsync --delete)
for T in \
  "/home/tofu/AI/AI_Second_Brain/050-Prompt-Engineering/prompt-engineering-skills/" \
  "/mnt/c/Users/treyl/Documents/Obsidian/Second_Brain/AI_Second_Brain/050-Prompt-Engineering/prompt-engineering-skills/" \
  "/mnt/c/Users/treyl/Documents/Obsidian/Second_Brain/prompt-engineering-skills/" \
  "/mnt/c/Users/treyl/OneDrive/Desktop/AI/prompt-engineering-skills/" \
; do
  rsync -a --delete --exclude='.git/' --exclude='.gitmodules' "$SRC/" "$T"
done

# 2) .claude/ 사본 (개별 파일만 — Claude Code가 사용)
cp $SRC/commands/prompt.md /home/tofu/AI/.claude/commands/prompt.md
cp $SRC/commands/prompt-sync.md /home/tofu/AI/.claude/commands/prompt-sync.md
cp $SRC/instructions/GPTs-Prompt-Generator.md /home/tofu/AI/.claude/commands/GPTs-Prompt-Generator.md
cp $SRC/skills/*.md /home/tofu/AI/.claude/skills/

# 3) Instructions 보조 사본 (Obsidian 검색용 + Library)
WIN_OBS=/mnt/c/Users/treyl/Documents/Obsidian/Second_Brain
for I in GPTs Gems; do
  cp $SRC/instructions/${I}-Prompt-Generator.md /home/tofu/AI/AI_Second_Brain/050-Prompt-Engineering/${I}-Prompt-Generator-Instructions.md
  cp $SRC/instructions/${I}-Prompt-Generator.md "$WIN_OBS/AI_Second_Brain/050-Prompt-Engineering/${I}-Prompt-Generator-Instructions.md"
  cp $SRC/instructions/${I}-Prompt-Generator.md "$WIN_OBS/Library/Prompt-Engineering/${I}-Prompt-Generator-Instructions.md"
done
cp $SRC/instructions/Gems-Prompt-Generator.md /home/tofu/AI/AI_Second_Brain/050-Prompt-Engineering/Gems-Prompt-Generator.md

# 4) 배포 repo 미러 + commit + push (6번째 경로)
DEPLOY=/tmp/pes-deploy/prompt-engineering-skills
if [ ! -d "$DEPLOY/.git" ]; then
  mkdir -p /tmp/pes-deploy
  git clone https://github.com/treylom/prompt-engineering-skills.git "$DEPLOY"
fi
( cd "$DEPLOY" && git fetch origin master && git reset --hard origin/master )
rsync -a --delete --exclude='.git/' --exclude='.gitmodules' "$SRC/" "$DEPLOY/"
( cd "$DEPLOY" && git add -A && \
  git -c user.email=treylom@users.noreply.github.com -c user.name=treylom \
    commit -m "sync from obsidian-ai-vault $(git -C /home/tofu/AI rev-parse --short HEAD)" && \
  git push origin master )

# 5) 검증
echo "=== verify identical sizes (6 locations) ==="
for f in skills/gpt-5.5-prompt-enhancement.md skills/claude-4.7-prompt-strategies.md instructions/GPTs-Prompt-Generator.md README.md ; do
  echo "--- $f ---"
  for L in \
    "$SRC" \
    "/home/tofu/AI/AI_Second_Brain/050-Prompt-Engineering/prompt-engineering-skills" \
    "$WIN_OBS/AI_Second_Brain/050-Prompt-Engineering/prompt-engineering-skills" \
    "$WIN_OBS/prompt-engineering-skills" \
    "/mnt/c/Users/treyl/OneDrive/Desktop/AI/prompt-engineering-skills" \
    "$DEPLOY"
  do wc -c "$L/$f" 2>/dev/null ; done
done
```

---

## ⚠️ 필수 완료 체크리스트 (NEVER SKIP)

| # | 단계 | 도구 | 확인 |
|---|------|------|------|
| 1 | **원본 수정** | Edit/Write | `/home/tofu/AI/prompt-engineering-skills/` 내 파일 |
| 2 | **GPTs 8000자 검증** | Node.js | `c.length <= 8000` |
| 3 | **6경로 + .claude 동기화** | 위 1-Shot 명령 | rsync --delete + 배포 repo push |
| 4 | **부모 Git Commit** | `git add . && git commit` | `treylom/obsidian-ai-vault` |
| 5 | **부모 Git Push** | `git push origin master` | `treylom/obsidian-ai-vault` |
| 6 | **배포 repo Push 검증** | gh repo view | `treylom/prompt-engineering-skills` 최신 commit |
| 7 | **결과 보고** | 마크다운 표 | Step 8 형식 |

**⛔ Compact/Context 전환 시에도 이 단계들은 반드시 완료**

---

## 📦 관리 대상 파일 (2026-05-02 기준)

### Instructions (GPTs/Gems 첨부용)
| # | 파일 | 현재 버전 | GPT 8000자 한도 |
|---|------|----------|----------------|
| 1 | `instructions/GPTs-Prompt-Generator.md` | v2.5.1 | ✅ 7993자 |
| 2 | `instructions/Gems-Prompt-Generator.md` | v2.5.1 | (없음) |

### Commands (Claude Code 슬래시 명령)
| # | 파일 | 현재 버전 |
|---|------|----------|
| 3 | `commands/prompt.md` | v2.7.1 |
| 4 | `commands/prompt-sync.md` | **v3.1.0** (이 파일) |

### Skills (GPTs/Gems 첨부 + Claude Code 스킬, 9개 — **10개 한도** 1개 여유)
| # | 파일 | 현재 버전 | 비고 |
|---|------|----------|------|
| 5 | `skills/gpt-5.5-prompt-enhancement.md` | v1.1.0 | outcome-first(상단) + legacy XML(하단) 통합 |
| 6 | `skills/claude-4.7-prompt-strategies.md` | v3.1.0 | Opus 4.7 + Sonnet 4.6 + 4.5/Haiku |
| 7 | `skills/gemini-3.1-prompt-strategies.md` | — | Gemini 3 Pro/Flash + Veo 3.1 + Image |
| 8 | `skills/prompt-engineering-guide.md` | v2.1.1 | 모델별 통합 전략 |
| 9 | `skills/image-prompt-guide.md` | v1.10.0 | 이미지 + 동영상 (비영어 대사 stage direction) |
| 10 | `skills/research-prompt-guide.md` | — | 팩트체크/리서치 IFCN |
| 11 | `skills/expert-domain-priming.md` | v2.1.0 | 12 도메인 60+ 전문가 DB |
| 12 | `skills/slide-prompt-guide.md` | — | 슬라이드/PPT 프롬프트 |
| 13 | `skills/context-engineering-collection.md` | — | CE 원칙 |

### 기타
| # | 파일 | 비고 |
|---|------|------|
| 14 | `README.md` | v2.3.0 (한·영 통합, 클론 URL `treylom/...`) |

---

## 워크플로우

### Step 1: 작업 모드 선택

사용자 입력이 없으면 폼 표시:

```
🔄 작업 모드 선택:

A. 전체 동시 업데이트 - GPTs, Gems, Skills 모두 수정 후 6경로 동기화
B. GPTs만 업데이트
C. Gems만 업데이트
D. Skills만 업데이트 (commands/prompt.md 또는 skills/*.md)
E. 동기화만 - 부모 repo 최신본을 6경로(배포 포함)에 미러
F. 버전 확인 - 현재 모든 파일 버전 표시
G. 6경로 일관성 검증 - 사이즈/체크섬 비교
H. 사용자 모드 - 배포 repo에서 ~/.claude/로 단순 동기화 (Step 9)

💬 입력 예시:
   • "A" → 전체 업데이트 시작
   • "D claude-4.7에 새 섹션 추가" → Skills 수정
   • "E" → 동기화만 실행 (배포 push 포함)
   • "H" → 사용자 동기화만
```

### Step 2: 전체 파일 읽기 (병렬)

수정 전 대상 파일 + 연동 스킬을 병렬 Read로 로드.

### Step 3: 변경 사항 수집 + 버전 확인

⚠️ **버전 번호는 사용자에게 AskUserQuestion으로 확인** (자동 bump 금지).

### Step 4: 원본 수정

`/home/tofu/AI/prompt-engineering-skills/` 내 파일만 직접 수정. 사본은 Step 6에서 일괄 미러.

### Step 4.5: GPTs 8000자 검증 (CRITICAL)

```bash
node -e "const fs = require('fs'); const c = fs.readFileSync('/home/tofu/AI/prompt-engineering-skills/instructions/GPTs-Prompt-Generator.md', 'utf8'); console.log('GPTs 글자수:', c.length, '/ 8000');"
```

| 글자수 | 상태 | 조치 |
|--------|------|------|
| ≤ 7,500 | ✅ 안전 | 진행 |
| 7,501-8,000 | ⚠️ 경고 | 축소 권장 |
| > 8,000 | ❌ 초과 | **반드시 축소 후 진행** |

**축소 우선순위**:
1. 옛 Changelog 항목 제거/통합
2. 예시 코드블록 압축
3. 테이블 컬럼 축소
4. 중복 설명 통합

### Step 5: 모델별 패턴 일관성 검증

새 파일 추가/수정 시 다른 파일과의 정합성 확인:

| 변경 유형 | 영향 받는 파일 |
|----------|----------------|
| GPT 모델 신규/변경 | `commands/prompt.md`, `instructions/{GPTs,Gems}-Prompt-Generator.md`, `skills/gpt-5.5-prompt-enhancement.md`, `skills/prompt-engineering-guide.md`, `README.md` |
| Claude 모델 신규 | `commands/prompt.md`, `instructions/{GPTs,Gems}-Prompt-Generator.md`, `skills/claude-4.7-prompt-strategies.md`, `skills/prompt-engineering-guide.md`, `README.md` |
| Gemini/이미지/동영상 모델 | `skills/gemini-3.1-prompt-strategies.md`, `skills/image-prompt-guide.md`, `commands/prompt.md` 모델 추천 표, `README.md` |
| 워크플로우/CE 원칙 | `commands/prompt.md`, `skills/prompt-engineering-guide.md`, `skills/context-engineering-collection.md` |

### Step 6: 6경로 + .claude 동기화 (위 1-Shot 명령 실행)

배포 repo 미러는 4) 단계에서 자동 처리. clone이 없으면 처음 한 번 clone, 이후엔 `git fetch + reset --hard origin/master + rsync`로 갱신.

### Step 7: 부모 Git Commit & Push

```bash
git add prompt-engineering-skills/ .claude/commands/ .claude/skills/ AI_Second_Brain/050-Prompt-Engineering/
git commit -m "prompt: [변경 요약]"
git push origin master  # treylom/obsidian-ai-vault
```

> ⚠️ Win Obsidian / Win OneDrive 위치는 git tracking 외부라 commit에 포함되지 않음 — rsync로 디스크 사본만 갱신.
> ⚠️ 배포 repo는 별개 Git history. Step 6에서 자체 commit + push 완료된 상태.

### Step 8: 결과 보고

```markdown
## 업데이트 완료 ✅

### 변경된 파일
| 파일 | 이전 → 새 버전 | 상태 |
|------|----------------|------|
| ... | vX.X → vY.Y | ✅ |

### 6경로 동기화 검증
| 위치 | 상태 |
|------|------|
| WSL 원본 | ✅ |
| WSL Obsidian | ✅ |
| Win Obsidian (050) | ✅ |
| Win Obsidian (root) | ✅ |
| Win OneDrive | ✅ |
| 배포 repo (treylom/prompt-engineering-skills) | ✅ |

### Git
- 부모 Commit: [hash] → treylom/obsidian-ai-vault master
- 배포 Commit: [hash] → treylom/prompt-engineering-skills master
```

### Step 9: 사용자 모드 (모드 H — 배포 repo → 로컬)

배포 repo `treylom/prompt-engineering-skills`에서 사용자 ~/.claude/로 단순 동기화. **수정자가 아닌 사용자가 배포본 받을 때만 사용.**

#### macOS / Linux

```bash
git clone --depth 1 https://github.com/treylom/prompt-engineering-skills.git /tmp/pes-sync && \
mkdir -p ~/.claude/skills ~/.claude/commands && \
cp /tmp/pes-sync/skills/*.md ~/.claude/skills/ && \
cp /tmp/pes-sync/commands/*.md ~/.claude/commands/ && \
rm -rf /tmp/pes-sync && \
echo "✅ 동기화 완료!"
```

#### Windows PowerShell

```powershell
git clone --depth 1 https://github.com/treylom/prompt-engineering-skills.git $env:TEMP\pes-sync; `
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills", "$env:USERPROFILE\.claude\commands" | Out-Null; `
Copy-Item "$env:TEMP\pes-sync\skills\*.md" "$env:USERPROFILE\.claude\skills\"; `
Copy-Item "$env:TEMP\pes-sync\commands\*.md" "$env:USERPROFILE\.claude\commands\"; `
Remove-Item -Recurse -Force "$env:TEMP\pes-sync"; `
Write-Host "✅ 동기화 완료!" -ForegroundColor Green
```

---

## 모드별 상세

### 모드 B: GPTs만
- 대상: `instructions/GPTs-Prompt-Generator.md`
- 8000자 검증 필수
- Obsidian 사본 + Library 사본 동기화
- 배포 repo 포함 6경로 미러

### 모드 C: Gems만
- 대상: `instructions/Gems-Prompt-Generator.md`
- 코드블록 → 마크다운 테이블 변환 (Gems 렌더링 이슈)
- Obsidian 사본 + 배포 repo 포함 6경로 미러

### 모드 D: Skills만
- 대상: `skills/*.md` 또는 `commands/prompt.md`
- 6경로 미러 + .claude/skills/ 또는 .claude/commands/ 사본

### 모드 E: 동기화만
- 부모 repo 원본 → 6경로 (배포 repo 포함) rsync
- 변경 없으면 빠른 종료

### 모드 F: 버전 확인
모든 파일 Version 헤더를 grep으로 추출 후 표 출력.

### 모드 G: 6경로 일관성 검증
```bash
for f in skills/gpt-5.5-prompt-enhancement.md skills/claude-4.7-prompt-strategies.md instructions/GPTs-Prompt-Generator.md commands/prompt.md README.md ; do
  for L in 6경로... ; do
    md5sum "$L/$f"
  done | sort -u  # 모두 동일하면 1줄, 다르면 여러 줄 = 불일치 감지
done
```

### 모드 H: 사용자 모드
배포 repo에서 ~/.claude/로 단순 동기화 (Step 9 참조).

---

## 버전 관리 규칙

### ⚠️ 버전은 사용자 확인 후만 변경 (자동 bump 금지)

AskUserQuestion으로 옵션:
- 현재 유지 / patch (0.0.x) / minor (0.x.0) / major (x.0.0) / 직접 입력

### 의미
- **major**: 구조적 변경 / 새 섹션 / 호환성 깨짐
- **minor**: 기능 추가 / 옵션 추가
- **patch**: 버그 / 오타 / 설명 개선

### Changelog 형식
```markdown
**Changes vX.Y.Z** (YYYY-MM-DD):
- **[MAJOR/MEDIUM/LOW] 핵심 변경 내용** — 상세
```

---

## 안티패턴 (회피)

| ❌ | ✅ |
|---|----|
| `cd prompt-engineering-skills && git push` (별도 repo로 잘못 인식) | 부모 repo에서 `git push origin master` (배포 repo는 별도 clone에서 push) |
| `.claude/` 파일만 수정 | 원본(`prompt-engineering-skills/`) 수정 후 미러 |
| Obsidian/Windows에서 직접 수정 | 원본만 수정, 모든 사본은 rsync로 갱신 |
| 6경로 중 일부만 동기화 | 1-Shot 명령으로 전체 미러 (배포 repo 포함) |
| 자동 버전 bump | AskUserQuestion으로 사용자 확인 |
| 부모 repo만 push | 부모 + 배포 repo 양쪽 push 필수 |
| `tofukyung/prompt-engineering-skills` URL 사용 | `treylom/prompt-engineering-skills` (실제 owner) |

---

## 주의사항

1. **Git 필수**: 동기화에 Git이 필요합니다
2. **네트워크 연결**: GitHub 접근이 필요합니다
3. **권한**: `~/.claude/` 디렉토리 쓰기 권한 + 배포 repo push 권한 필요
4. **백업**: 중요한 커스텀 수정 사항은 미리 백업하세요
5. **배포 repo 권한**: `treylom/prompt-engineering-skills` push 권한 (운영자만)

---

## 문제 해결

| 문제 | 해결 방법 |
|------|----------|
| Git 미설치 | [git-scm.com](https://git-scm.com)에서 설치 |
| 권한 오류 | `chmod 755 ~/.claude/` 실행 (Linux/macOS) |
| 네트워크 오류 | 방화벽/프록시 설정 확인 |
| 배포 repo push 실패 | gh auth status로 인증 확인, `gh auth login` |
| 배포 repo 충돌 | `cd /tmp/pes-deploy/prompt-engineering-skills && git fetch && git reset --hard origin/master`, 이후 rsync 재시도 |
| 6경로 사이즈 불일치 | 모드 G로 md5 비교, 불일치 위치만 재미러 |

---

## Metadata

- **Version**: 3.1.0
- **Updated**: 2026-05-02
- **Created**: 2025-12-28
- **Changes v3.1.0** (2026-05-02):
  - **[MAJOR] 별도 배포 repo 정식 통합**: `treylom/prompt-engineering-skills`를 6번째 경로로 추가. v3.0.0의 "별도 repo 표기 틀렸음" 표기 정정 (별도 repo는 사용자 설치/동기화용 미러로 실재함)
  - **[MAJOR] 1-Shot 명령에 배포 push 자동화**: clone 없으면 자동 clone, 있으면 reset --hard + rsync + commit + push
  - **[MAJOR] 모드 H 신설**: 사용자 모드 — 배포 repo → ~/.claude/ 단순 동기화 (Step 9)
  - **[MAJOR] Repo URL 정정**: 본문 내 `tofukyung/prompt-engineering-skills` 표기를 `treylom/prompt-engineering-skills`로 일괄 정정
  - **[MAJOR] claude-4.6 → claude-4.7 표기 통합**: 관리 대상 파일 표 + 영향 매핑 모두 정정
  - **[MEDIUM] README.md 관리 대상 추가**: 14번째 항목으로 등록
  - **[MEDIUM] 안티패턴 표 확장**: 7 항목 (배포 push 누락 / 잘못된 owner URL 추가)
- **Changes v3.0.0** (2026-04-30):
  - **[MAJOR] 5경로 동시 동기화 자동화**: WSL 원본 / WSL Obsidian / Win Obsidian (2 위치) / Win OneDrive 5위치 rsync `--delete` 미러
  - **[MAJOR] GPT-5.4 → 5.5 통합 반영**: gpt-5.5-prompt-enhancement.md 단일 파일에 outcome-first + legacy XML 통합
  - **[MAJOR] Claude 4.6 → 4.7 + Sonnet 4.6 반영**: claude-4.7-prompt-strategies.md v3.1.0
  - **[MEDIUM] 모드 G 신설**: 5경로 일관성 검증 (md5sum 비교)
- **Changes v2.0.0** (2026-02-02):
  - 버전 번호 사용자 확인 규칙 추가
  - 자동 버전 bump 금지 원칙
- **Author**: Claude Code Agent
- **Related**: `/prompt`, `/research`
- **Sub-Skills**: `prompt-sync-gpts.md`, `prompt-sync-gems.md`, `prompt-sync-skills.md`, `prompt-sync-obsidian.md`
