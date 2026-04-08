# Qwen3-TTS 음성 합성 및 음성 클론

## 원본 링크

| 리소스 | URL |
|--------|-----|
| **HuggingFace (CustomVoice)** | https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice |
| **HuggingFace (Base/Clone)** | https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base |
| **GitHub** | https://github.com/QwenLM/Qwen3-TTS |
| **공식 데모 (Clone)** | https://huggingface.co/spaces/Qwen/Qwen-TTS-Clone-Demo |
| **공식 데모 (TTS)** | https://huggingface.co/spaces/Qwen/Qwen3-TTS-Demo |

---

## 0. 환경 설정

```bash
ARGS="$ARGUMENTS"
COMMAND=$(echo "$ARGS" | awk '{print $1}')
PORT=$(echo "$ARGS" | grep -oP 'port=\K[0-9]+' || echo "8000")
VENV_PATH="$HOME/qwen3-tts-env"
PID_FILE="$HOME/.claude/qwen3-tts.pid"
LOG_FILE="$HOME/.claude/qwen3-tts.log"
ENV_SCAN_FILE="/tmp/qwen3-tts-env-scan.json"
```

---

## 1. 설치 - 환경 스캔 (install)

`install` 명령 시, 먼저 아래 bash 스크립트로 환경을 스캔한 후, **AskUserQuestion 도구**를 사용하여 사용자에게 설치 옵션을 제공하세요.

```bash
if [ "$COMMAND" = "install" ]; then
  echo "=========================================="
  echo "  Qwen3-TTS 설치 - 환경 스캔"
  echo "=========================================="
  echo ""
  echo "원본: https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base"
  echo "GitHub: https://github.com/QwenLM/Qwen3-TTS"
  echo ""
  echo "환경을 스캔하고 있습니다..."
  echo ""

  # 환경 정보 수집
  PYTHON_VERSION=$(python3 --version 2>&1 | grep -oP '\d+\.\d+' || echo "unknown")
  PYTHON_PATH=$(which python3 2>/dev/null || echo "not found")

  # GPU 정보
  if command -v nvidia-smi &> /dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    GPU_MEMORY=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1)
    CUDA_VERSION=$(nvcc --version 2>/dev/null | grep -oP 'release \K[\d.]+' || nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1)
    GPU_AVAILABLE="true"
  else
    GPU_NAME="not detected"
    GPU_MEMORY="N/A"
    CUDA_VERSION="N/A"
    GPU_AVAILABLE="false"
  fi

  # 메모리 정보
  TOTAL_RAM=$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "unknown")

  # 기존 설치 확인
  if [ -d "$VENV_PATH" ]; then
    EXISTING_INSTALL="true"
    EXISTING_VERSION=$(source "$VENV_PATH/bin/activate" 2>/dev/null && pip show qwen-tts 2>/dev/null | grep Version | awk '{print $2}' || echo "unknown")
  else
    EXISTING_INSTALL="false"
    EXISTING_VERSION="N/A"
  fi

  # conda 확인
  if command -v conda &> /dev/null; then
    CONDA_AVAILABLE="true"
  else
    CONDA_AVAILABLE="false"
  fi

  # 아키텍처
  ARCH=$(uname -m)

  # 결과 출력
  echo "=========================================="
  echo "  환경 스캔 결과"
  echo "=========================================="
  echo ""
  echo "[시스템]"
  echo "  아키텍처: $ARCH"
  echo "  RAM: $TOTAL_RAM"
  echo ""
  echo "[Python]"
  echo "  버전: $PYTHON_VERSION"
  echo "  경로: $PYTHON_PATH"
  echo "  Conda: $CONDA_AVAILABLE"
  echo ""
  echo "[GPU]"
  echo "  GPU: $GPU_NAME"
  echo "  VRAM: $GPU_MEMORY"
  echo "  CUDA: $CUDA_VERSION"
  echo ""
  echo "[기존 설치]"
  echo "  설치됨: $EXISTING_INSTALL"
  echo "  버전: $EXISTING_VERSION"
  echo ""

  # JSON으로 저장 (Claude가 읽을 수 있도록)
  cat > "$ENV_SCAN_FILE" << EOF
{
  "python_version": "$PYTHON_VERSION",
  "python_path": "$PYTHON_PATH",
  "gpu_available": $GPU_AVAILABLE,
  "gpu_name": "$GPU_NAME",
  "gpu_memory": "$GPU_MEMORY",
  "cuda_version": "$CUDA_VERSION",
  "total_ram": "$TOTAL_RAM",
  "arch": "$ARCH",
  "conda_available": $CONDA_AVAILABLE,
  "existing_install": $EXISTING_INSTALL,
  "existing_version": "$EXISTING_VERSION",
  "venv_path": "$VENV_PATH"
}
EOF

  echo "환경 스캔 완료. 설치 옵션을 분석합니다..."
  exit 0
fi
```

### install 명령 후 Claude 동작 지시

위 스크립트 실행 후, `/tmp/qwen3-tts-env-scan.json` 파일을 읽고 아래 로직에 따라 **AskUserQuestion 도구**로 설치 옵션을 제공하세요:

**옵션 결정 로직:**

1. **GPU 있음 + CUDA 12.x**:
   - 권장: "GPU 가속 설치 (CUDA)"
   - 대안: "CPU 전용 설치"

2. **GPU 있음 + CUDA 11.x**:
   - 권장: "GPU 가속 설치 (CUDA 11.8)"
   - 대안: "CPU 전용 설치"

3. **GPU 없음**:
   - 권장: "CPU 전용 설치"
   - 대안 없음

4. **기존 설치 있음**:
   - 추가 옵션: "기존 설치 업그레이드", "새로 설치 (기존 삭제)"

**AskUserQuestion 예시:**
- header: "설치 옵션"
- question: "Qwen3-TTS 설치 방법을 선택하세요"
- options: 환경에 맞는 옵션들 (권장 옵션에 "(권장)" 표시)

사용자 선택 후 해당 설치를 진행하세요.

---

## 2. 설치 실행 (install-run)

사용자가 옵션을 선택한 후 실행할 설치 스크립트입니다. Claude가 선택에 따라 적절한 옵션으로 실행하세요.

```bash
if [ "$COMMAND" = "install-gpu" ]; then
  echo "=========================================="
  echo "  Qwen3-TTS GPU 가속 설치"
  echo "=========================================="

  # 기존 환경 처리
  if [ -d "$VENV_PATH" ]; then
    echo "기존 설치 제거 중..."
    rm -rf "$VENV_PATH"
  fi

  # 가상환경 생성
  echo ""
  echo "[1/4] 가상환경 생성..."
  python3 -m venv "$VENV_PATH"
  source "$VENV_PATH/bin/activate"
  pip install --upgrade pip -q
  echo "  완료: $VENV_PATH"

  # qwen-tts 설치
  echo ""
  echo "[2/4] qwen-tts 패키지 설치..."
  pip install -U qwen-tts 2>&1 | grep -E "(Successfully|Requirement)"

  # PyTorch CUDA 버전 설치
  echo ""
  echo "[3/4] PyTorch CUDA 버전 설치..."

  # CUDA 버전에 따라 적절한 PyTorch 설치
  CUDA_VER=$(nvcc --version 2>/dev/null | grep -oP 'release \K\d+' || echo "12")

  if [ "$CUDA_VER" -ge "12" ]; then
    pip install --force-reinstall torch torchvision torchaudio \
      --index-url https://download.pytorch.org/whl/cu128 2>&1 | tail -3
  else
    pip install --force-reinstall torch torchvision torchaudio \
      --index-url https://download.pytorch.org/whl/cu118 2>&1 | tail -3
  fi

  # 설치 검증
  echo ""
  echo "[4/4] 설치 검증..."
  python3 -c "
from qwen_tts import Qwen3TTSModel
import torch
print('  qwen_tts: OK')
print(f'  PyTorch: {torch.__version__}')
print(f'  CUDA: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'  GPU: {torch.cuda.get_device_name(0)}')
" 2>&1 | grep -v "UserWarning"

  echo ""
  echo "=========================================="
  echo "  GPU 가속 설치 완료!"
  echo "=========================================="
  echo ""
  echo "사용법:"
  echo "  /qwen3-tts clone    # 음성 클론 WebUI"
  echo "  /qwen3-tts custom   # 프리셋 화자 WebUI"
  exit 0
fi

if [ "$COMMAND" = "install-cpu" ]; then
  echo "=========================================="
  echo "  Qwen3-TTS CPU 전용 설치"
  echo "=========================================="

  if [ -d "$VENV_PATH" ]; then
    echo "기존 설치 제거 중..."
    rm -rf "$VENV_PATH"
  fi

  echo ""
  echo "[1/3] 가상환경 생성..."
  python3 -m venv "$VENV_PATH"
  source "$VENV_PATH/bin/activate"
  pip install --upgrade pip -q
  echo "  완료: $VENV_PATH"

  echo ""
  echo "[2/3] qwen-tts 패키지 설치..."
  pip install -U qwen-tts 2>&1 | grep -E "(Successfully|Requirement)"

  echo ""
  echo "[3/3] 설치 검증..."
  python3 -c "
from qwen_tts import Qwen3TTSModel
import torch
print('  qwen_tts: OK')
print(f'  PyTorch: {torch.__version__}')
print('  모드: CPU')
" 2>&1 | grep -v "Warning"

  echo ""
  echo "=========================================="
  echo "  CPU 전용 설치 완료!"
  echo "=========================================="
  echo ""
  echo "참고: CPU 모드는 GPU보다 느립니다."
  echo ""
  echo "사용법:"
  echo "  /qwen3-tts clone    # 음성 클론 WebUI"
  echo "  /qwen3-tts custom   # 프리셋 화자 WebUI"
  exit 0
fi

if [ "$COMMAND" = "install-upgrade" ]; then
  echo "=========================================="
  echo "  Qwen3-TTS 업그레이드"
  echo "=========================================="

  if [ ! -d "$VENV_PATH" ]; then
    echo "오류: 기존 설치가 없습니다."
    echo "새로 설치하세요: /qwen3-tts install"
    exit 1
  fi

  source "$VENV_PATH/bin/activate"

  echo ""
  echo "qwen-tts 업그레이드 중..."
  pip install -U qwen-tts 2>&1 | grep -E "(Successfully|Requirement|already)"

  echo ""
  echo "업그레이드 완료!"
  NEW_VER=$(pip show qwen-tts 2>/dev/null | grep Version | awk '{print $2}')
  echo "현재 버전: $NEW_VER"
  exit 0
fi
```

---

## 3. 음성 클론 WebUI (clone / start)

```bash
if [ "$COMMAND" = "clone" ] || [ "$COMMAND" = "start" ]; then
  if [ ! -d "$VENV_PATH" ]; then
    echo "오류: qwen3-tts가 설치되지 않았습니다."
    echo ""
    echo "설치 명령: /qwen3-tts install"
    exit 1
  fi

  # 기존 프로세스 종료
  if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    kill $OLD_PID 2>/dev/null && echo "기존 프로세스 종료: $OLD_PID"
    rm -f "$PID_FILE"
    sleep 2
  fi
  pkill -f "qwen-tts-demo" 2>/dev/null
  sleep 1

  echo "=========================================="
  echo "  Qwen3-TTS 음성 클론 WebUI"
  echo "=========================================="
  echo ""
  echo "모델: Qwen/Qwen3-TTS-12Hz-1.7B-Base"
  echo "원본: https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base"
  echo ""
  echo "기능: 3초 참조 오디오로 음성 클론"
  echo "포트: $PORT"
  echo ""

  source "$VENV_PATH/bin/activate"
  nohup qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-Base \
    --ip 0.0.0.0 --port $PORT --no-flash-attn \
    > "$LOG_FILE" 2>&1 &

  echo $! > "$PID_FILE"

  echo "로딩 중... (첫 실행 시 모델 다운로드 필요)"
  for i in {1..30}; do
    sleep 5
    if curl -s http://localhost:$PORT > /dev/null 2>&1; then
      echo ""
      echo "=========================================="
      echo "  WebUI 준비 완료!"
      echo "=========================================="
      echo ""
      echo "접속: http://localhost:$PORT"
      echo ""
      echo "사용법:"
      echo "  1. Voice Clone 탭 선택"
      echo "  2. 참조 음성 업로드 (5-15초, 깨끗한 음질)"
      echo "  3. 참조 음성의 발화 내용 입력 (정확히)"
      echo "  4. 생성할 텍스트 입력"
      echo "  5. 언어 선택 후 Generate"
      echo ""
      echo "지원 언어: 한국어, 영어, 중국어, 일본어 외 6개"
      echo ""
      echo "종료: /qwen3-tts stop"
      exit 0
    fi
    echo "  로딩 중... ($((i*5))초)"
  done

  echo ""
  echo "타임아웃 - 백그라운드에서 계속 로딩 중"
  echo "로그 확인: /qwen3-tts log"
  exit 0
fi
```

---

## 4. 프리셋 화자 WebUI (custom / voice)

```bash
if [ "$COMMAND" = "custom" ] || [ "$COMMAND" = "voice" ]; then
  if [ ! -d "$VENV_PATH" ]; then
    echo "오류: qwen3-tts가 설치되지 않았습니다."
    echo "설치 명령: /qwen3-tts install"
    exit 1
  fi

  if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    kill $OLD_PID 2>/dev/null && echo "기존 프로세스 종료"
    rm -f "$PID_FILE"
    sleep 2
  fi
  pkill -f "qwen-tts-demo" 2>/dev/null
  sleep 1

  echo "=========================================="
  echo "  Qwen3-TTS 프리셋 화자 WebUI"
  echo "=========================================="
  echo ""
  echo "모델: Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice"
  echo "원본: https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice"
  echo ""
  echo "포트: $PORT"
  echo ""

  source "$VENV_PATH/bin/activate"
  nohup qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice \
    --ip 0.0.0.0 --port $PORT --no-flash-attn \
    > "$LOG_FILE" 2>&1 &

  echo $! > "$PID_FILE"

  echo "로딩 중..."
  for i in {1..30}; do
    sleep 5
    if curl -s http://localhost:$PORT > /dev/null 2>&1; then
      echo ""
      echo "=========================================="
      echo "  WebUI 준비 완료!"
      echo "=========================================="
      echo ""
      echo "접속: http://localhost:$PORT"
      echo ""
      echo "프리셋 화자:"
      echo "  - Sohee    : 한국어, 감정 풍부한 따뜻한 여성음"
      echo "  - Vivian   : 중국어, 밝고 젊은 여성음"
      echo "  - Serena   : 중국어, 따뜻하고 부드러운 여성음"
      echo "  - Ryan     : 영어, 역동적 남성음"
      echo "  - Aiden    : 영어, 밝은 미국 남성음"
      echo "  - Ono_Anna : 일본어, 장난스러운 여성음"
      echo ""
      echo "종료: /qwen3-tts stop"
      exit 0
    fi
    echo "  로딩 중... ($((i*5))초)"
  done
  exit 0
fi
```

---

## 5. 종료 (stop)

```bash
if [ "$COMMAND" = "stop" ]; then
  echo "=== Qwen3-TTS 종료 ==="

  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    kill $PID 2>/dev/null && echo "프로세스 종료: $PID"
    rm -f "$PID_FILE"
  fi

  pkill -f "qwen-tts-demo" 2>/dev/null
  echo "완료"
  exit 0
fi
```

---

## 6. 상태 확인 (status)

```bash
if [ "$COMMAND" = "status" ]; then
  echo "=========================================="
  echo "  Qwen3-TTS 상태"
  echo "=========================================="
  echo ""

  echo "[설치]"
  if [ -d "$VENV_PATH" ]; then
    echo "  상태: 설치됨"
    echo "  경로: $VENV_PATH"
    source "$VENV_PATH/bin/activate" 2>/dev/null
    QWEN_VER=$(pip show qwen-tts 2>/dev/null | grep Version | awk '{print $2}')
    [ -n "$QWEN_VER" ] && echo "  버전: $QWEN_VER"
  else
    echo "  상태: 미설치"
    echo "  설치: /qwen3-tts install"
  fi

  echo ""
  echo "[WebUI]"
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
      echo "  상태: 실행 중"
      echo "  PID: $PID"
      ACTIVE_PORT=$(ss -tlnp 2>/dev/null | grep "pid=$PID" | grep -oP ':\K[0-9]+' | head -1)
      [ -n "$ACTIVE_PORT" ] && echo "  접속: http://localhost:$ACTIVE_PORT"
    else
      echo "  상태: 중지됨"
      rm -f "$PID_FILE"
    fi
  else
    RUNNING_PID=$(pgrep -f "qwen-tts-demo" 2>/dev/null)
    if [ -n "$RUNNING_PID" ]; then
      echo "  상태: 실행 중 (PID: $RUNNING_PID)"
    else
      echo "  상태: 중지됨"
    fi
  fi

  echo ""
  echo "[원본 링크]"
  echo "  GitHub: https://github.com/QwenLM/Qwen3-TTS"
  echo "  HuggingFace: https://huggingface.co/Qwen"
  echo "  데모: https://huggingface.co/spaces/Qwen/Qwen-TTS-Clone-Demo"
  exit 0
fi
```

---

## 7. 로그 확인 (log / logs)

```bash
if [ "$COMMAND" = "log" ] || [ "$COMMAND" = "logs" ]; then
  if [ -f "$LOG_FILE" ]; then
    echo "=== Qwen3-TTS 로그 (최근 50줄) ==="
    echo ""
    tail -50 "$LOG_FILE"
  else
    echo "로그 파일이 없습니다: $LOG_FILE"
  fi
  exit 0
fi
```

---

## 8. 제거 (uninstall)

```bash
if [ "$COMMAND" = "uninstall" ]; then
  echo "=== Qwen3-TTS 제거 ==="
  echo ""

  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    kill $PID 2>/dev/null
    rm -f "$PID_FILE"
  fi
  pkill -f "qwen-tts-demo" 2>/dev/null

  if [ -d "$VENV_PATH" ]; then
    echo "가상환경 제거: $VENV_PATH"
    rm -rf "$VENV_PATH"
  fi

  rm -f "$LOG_FILE"
  rm -f "$ENV_SCAN_FILE"

  echo ""
  echo "제거 완료"
  echo ""
  echo "모델 캐시 제거 (선택):"
  echo "  rm -rf ~/.cache/huggingface/hub/models--Qwen--Qwen3-TTS*"
  exit 0
fi
```

---

## 9. 도움말 (기본)

```bash
echo "=========================================="
echo "  Qwen3-TTS - 음성 합성 및 음성 클론"
echo "=========================================="
echo ""
echo "Alibaba Qwen 팀의 오픈소스 TTS 모델"
echo ""
echo "[원본 링크]"
echo "  GitHub: https://github.com/QwenLM/Qwen3-TTS"
echo "  HuggingFace: https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base"
echo "  데모: https://huggingface.co/spaces/Qwen/Qwen-TTS-Clone-Demo"
echo ""
echo "[사용법] /qwen3-tts <명령> [옵션]"
echo ""
echo "명령어:"
echo "  install         설치 (환경 스캔 → 옵션 선택)"
echo "  clone, start    음성 클론 WebUI (Base 모델)"
echo "  custom, voice   프리셋 화자 WebUI (CustomVoice 모델)"
echo "  stop            WebUI 종료"
echo "  status          상태 확인"
echo "  log             로그 확인"
echo "  uninstall       제거"
echo ""
echo "옵션:"
echo "  port=<번호>     WebUI 포트 (기본: 8000)"
echo ""
echo "예시:"
echo "  /qwen3-tts install           # 환경 스캔 후 설치 옵션 선택"
echo "  /qwen3-tts clone             # 음성 클론 WebUI"
echo "  /qwen3-tts clone port=7860   # 포트 지정"
echo "  /qwen3-tts custom            # 프리셋 화자 WebUI"
echo "  /qwen3-tts stop              # 종료"
echo ""
echo "기능:"
echo "  - 음성 클론: 3초 참조 오디오로 목소리 복제"
echo "  - 프리셋 화자: Sohee(한), Ryan(영), Vivian(중) 등"
echo "  - 10개 언어 지원"
echo ""
echo "요구사항:"
echo "  - Python 3.10+"
echo "  - NVIDIA GPU 권장 (CUDA 11.8+ / 12.x)"
echo "  - 약 4GB VRAM"
```

$ARGUMENTS
