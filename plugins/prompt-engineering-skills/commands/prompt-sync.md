# /prompt-sync - 프롬프트 생성기 통합 업데이트 에이전트

> **Version**: 2.0.0 | **Updated**: 2026-02-02
> **Source**: [prompt-engineering-skills](https://github.com/tofukyung/prompt-engineering-skills)

GitHub 레포에서 최신 스킬 및 명령어를 가져와 로컬 Claude 환경에 자동 동기화합니다.

$ARGUMENTS

---

## 기능 개요

- **자동 업데이트**: GitHub 레포의 최신 버전을 가져와 로컬에 적용
- **선택적 동기화**: 전체 또는 특정 파일만 동기화 가능
- **버전 확인**: 현재 설치된 버전과 최신 버전 비교
- **백업 지원**: 동기화 전 기존 파일 백업 옵션

---

## 워크플로우

### Step 1: 현재 상태 확인

먼저 사용자 환경을 확인합니다:

```bash
# 전역 설치 확인
ls ~/.claude/skills/ 2>/dev/null && echo "✅ 전역 스킬 설치됨" || echo "❌ 전역 스킬 없음"
ls ~/.claude/commands/ 2>/dev/null && echo "✅ 전역 명령어 설치됨" || echo "❌ 전역 명령어 없음"
```

**출력 형식:**
```
📊 현재 설치 상태:
├── 전역 스킬: [✅ 설치됨 / ❌ 없음] (X개 파일)
├── 전역 명령어: [✅ 설치됨 / ❌ 없음] (X개 파일)
└── 설치된 버전: [버전 또는 "확인 불가"]
```

---

### Step 2: 동기화 옵션 선택

```
🔄 동기화 옵션을 선택하세요:

1️⃣ **전체 동기화** (권장)
   - skills/*.md → ~/.claude/skills/
   - commands/*.md → ~/.claude/commands/

2️⃣ **스킬만 동기화**
   - skills/*.md → ~/.claude/skills/

3️⃣ **명령어만 동기화**
   - commands/*.md → ~/.claude/commands/

4️⃣ **버전 확인만**
   - 최신 버전 정보만 표시

(숫자 또는 "전체", "스킬", "명령어", "버전"으로 선택)
```

---

### Step 3: 동기화 실행

**$ARGUMENTS가 있으면** 자동으로 해당 옵션 실행:
- `$ARGUMENTS` = "전체" 또는 빈값 → 전체 동기화
- `$ARGUMENTS` = "스킬" → 스킬만 동기화
- `$ARGUMENTS` = "명령어" → 명령어만 동기화
- `$ARGUMENTS` = "버전" → 버전 확인만

#### 동기화 스크립트 (macOS/Linux)

```bash
#!/bin/bash
REPO_URL="https://github.com/tofukyung/prompt-engineering-skills.git"
TEMP_DIR="/tmp/prompt-engineering-skills-sync"

echo "🔄 최신 버전 다운로드 중..."
rm -rf "$TEMP_DIR"
git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ 다운로드 실패. 네트워크 연결을 확인하세요."
    exit 1
fi

# 디렉토리 생성
mkdir -p ~/.claude/skills ~/.claude/commands

# 백업 (선택적)
if [ -d ~/.claude/skills ] && [ "$(ls -A ~/.claude/skills 2>/dev/null)" ]; then
    BACKUP_DIR=~/.claude/backup/$(date +%Y%m%d_%H%M%S)
    mkdir -p "$BACKUP_DIR"
    cp -r ~/.claude/skills "$BACKUP_DIR/"
    cp -r ~/.claude/commands "$BACKUP_DIR/" 2>/dev/null
    echo "📦 기존 파일 백업: $BACKUP_DIR"
fi

# 동기화
echo "📥 스킬 동기화 중..."
cp "$TEMP_DIR"/skills/*.md ~/.claude/skills/ 2>/dev/null
SKILLS_COUNT=$(ls ~/.claude/skills/*.md 2>/dev/null | wc -l)

echo "📥 명령어 동기화 중..."
cp "$TEMP_DIR"/commands/*.md ~/.claude/commands/ 2>/dev/null
COMMANDS_COUNT=$(ls ~/.claude/commands/*.md 2>/dev/null | wc -l)

# 정리
rm -rf "$TEMP_DIR"

echo ""
echo "✅ 동기화 완료!"
echo "├── 스킬: ${SKILLS_COUNT}개 파일"
echo "├── 명령어: ${COMMANDS_COUNT}개 파일"
echo "└── 위치: ~/.claude/"
```

#### 동기화 스크립트 (Windows PowerShell)

```powershell
$RepoUrl = "https://github.com/tofukyung/prompt-engineering-skills.git"
$TempDir = "$env:TEMP\prompt-engineering-skills-sync"

Write-Host "🔄 최신 버전 다운로드 중..." -ForegroundColor Cyan
Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
git clone --depth 1 $RepoUrl $TempDir 2>$null

if (-not $?) {
    Write-Host "❌ 다운로드 실패. 네트워크 연결을 확인하세요." -ForegroundColor Red
    exit 1
}

# 디렉토리 생성
$SkillsDir = "$env:USERPROFILE\.claude\skills"
$CommandsDir = "$env:USERPROFILE\.claude\commands"
New-Item -ItemType Directory -Force -Path $SkillsDir, $CommandsDir | Out-Null

# 백업 (선택적)
if (Test-Path "$SkillsDir\*.md") {
    $BackupDir = "$env:USERPROFILE\.claude\backup\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    Copy-Item -Recurse "$SkillsDir" "$BackupDir\"
    Copy-Item -Recurse "$CommandsDir" "$BackupDir\" -ErrorAction SilentlyContinue
    Write-Host "📦 기존 파일 백업: $BackupDir" -ForegroundColor Yellow
}

# 동기화
Write-Host "📥 스킬 동기화 중..." -ForegroundColor Cyan
Copy-Item "$TempDir\skills\*.md" $SkillsDir -ErrorAction SilentlyContinue
$SkillsCount = (Get-ChildItem "$SkillsDir\*.md" -ErrorAction SilentlyContinue).Count

Write-Host "📥 명령어 동기화 중..." -ForegroundColor Cyan
Copy-Item "$TempDir\commands\*.md" $CommandsDir -ErrorAction SilentlyContinue
$CommandsCount = (Get-ChildItem "$CommandsDir\*.md" -ErrorAction SilentlyContinue).Count

# 정리
Remove-Item -Recurse -Force $TempDir

Write-Host ""
Write-Host "✅ 동기화 완료!" -ForegroundColor Green
Write-Host "├── 스킬: ${SkillsCount}개 파일"
Write-Host "├── 명령어: ${CommandsCount}개 파일"
Write-Host "└── 위치: $env:USERPROFILE\.claude\"
```

---

### Step 4: 결과 보고

동기화 완료 후 다음 정보를 표시합니다:

```
✅ 동기화 완료!

📊 업데이트 요약:
├── 스킬 파일: X개 동기화됨
│   └── image-prompt-guide.md, ...
├── 명령어 파일: X개 동기화됨
│   └── prompt.md, prompt-sync.md, ...
├── 백업 위치: ~/.claude/backup/YYYYMMDD_HHMMSS/
└── 버전: 1.5.0

💡 팁:
- 새 터미널/Claude Code 세션에서 변경사항 적용
- /prompt 명령어로 프롬프트 생성 시작
- 문제 발생 시: 백업에서 복원 가능
```

---

## 빠른 동기화 (원-라이너)

### macOS/Linux
```bash
git clone --depth 1 https://github.com/tofukyung/prompt-engineering-skills.git /tmp/pes-sync && \
mkdir -p ~/.claude/skills ~/.claude/commands && \
cp /tmp/pes-sync/skills/*.md ~/.claude/skills/ && \
cp /tmp/pes-sync/commands/*.md ~/.claude/commands/ && \
rm -rf /tmp/pes-sync && \
echo "✅ 동기화 완료!"
```

### Windows PowerShell
```powershell
git clone --depth 1 https://github.com/tofukyung/prompt-engineering-skills.git $env:TEMP\pes-sync; `
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills", "$env:USERPROFILE\.claude\commands" | Out-Null; `
Copy-Item "$env:TEMP\pes-sync\skills\*.md" "$env:USERPROFILE\.claude\skills\"; `
Copy-Item "$env:TEMP\pes-sync\commands\*.md" "$env:USERPROFILE\.claude\commands\"; `
Remove-Item -Recurse -Force "$env:TEMP\pes-sync"; `
Write-Host "✅ 동기화 완료!" -ForegroundColor Green
```

---

## 주의사항

1. **Git 필수**: 동기화에 Git이 필요합니다
2. **네트워크 연결**: GitHub 접근이 필요합니다
3. **권한**: `~/.claude/` 디렉토리 쓰기 권한 필요
4. **백업**: 중요한 커스텀 수정 사항은 미리 백업하세요

---

## 문제 해결

| 문제 | 해결 방법 |
|------|----------|
| Git 미설치 | [git-scm.com](https://git-scm.com)에서 설치 |
| 권한 오류 | `chmod 755 ~/.claude/` 실행 (Linux/macOS) |
| 네트워크 오류 | 방화벽/프록시 설정 확인 |
| 파일 없음 오류 | `mkdir -p ~/.claude/skills ~/.claude/commands` 먼저 실행 |

---

## 관련 명령어

- `/prompt` - AI 프롬프트 생성기 (메인 기능)

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 2.0.0 | 2026-02-02 | 버전 번호 사용자 확인 규칙 추가 |
| 1.0.0 | 2026-01-01 | 초기 릴리즈: 자동 동기화, 백업, 크로스 플랫폼 지원 |
