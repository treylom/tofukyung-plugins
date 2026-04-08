# Qwen3-TTS Claude Code Skill

> **[Qwen3-TTS-12Hz-1.7B-CustomVoice](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice)** 및 **[Qwen3-TTS-12Hz-1.7B-Base](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base)** 모델의 설치와 사용을 돕는 Claude Code 스킬입니다.

[한국어](#한국어) | [English](#english)

---

## 한국어

Alibaba Qwen 팀이 개발한 오픈소스 TTS 모델 [Qwen3-TTS](https://github.com/QwenLM/Qwen3-TTS)를 Claude Code에서 쉽게 설치하고 사용할 수 있도록 도와주는 스킬입니다.

### 이 스킬이 하는 일

- **Qwen3-TTS-12Hz-1.7B-CustomVoice** / **Qwen3-TTS-12Hz-1.7B-Base** 모델 자동 설치
- 시스템 환경 자동 스캔 (GPU, CUDA, Python 버전)
- 환경에 맞는 설치 옵션 제공 (GPU 가속 / CPU 전용)
- WebUI 실행 및 관리

### 주요 기능

- **음성 클론**: 3초 참조 오디오로 어떤 목소리든 복제 (Base 모델)
- **프리셋 음성**: 9개의 프리미엄 음성 프로필 (CustomVoice 모델)
- **10개 언어 지원**: 한국어, 영어, 중국어, 일본어, 독일어, 프랑스어, 러시아어, 포르투갈어, 스페인어, 이탈리아어

### 원본 리소스

| 리소스 | URL |
|--------|-----|
| **HuggingFace (CustomVoice)** | https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice |
| **HuggingFace (Base/Clone)** | https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base |
| **GitHub** | https://github.com/QwenLM/Qwen3-TTS |
| **공식 데모 (Clone)** | https://huggingface.co/spaces/Qwen/Qwen-TTS-Clone-Demo |
| **공식 데모 (TTS)** | https://huggingface.co/spaces/Qwen/Qwen3-TTS-Demo |

### 설치 방법

1. `qwen3-tts.md`를 Claude Code commands 디렉토리에 복사:

```bash
# 다운로드 및 설치
curl -o ~/.claude/commands/qwen3-tts.md \
  https://raw.githubusercontent.com/treylom/qwen3-tts-claude-skill/main/qwen3-tts.md
```

2. Claude Code에서 설치 명령 실행:

```
/qwen3-tts install
```

3. 스킬이 환경을 스캔하고 설치 옵션을 제공합니다:
   - **GPU 가속 설치** (NVIDIA GPU 감지 시 권장)
   - **CPU 전용 설치**
   - **업그레이드** (이미 설치된 경우)

### 사용법

| 명령어 | 설명 |
|--------|------|
| `/qwen3-tts install` | 설치 (환경 스캔 → 옵션 선택) |
| `/qwen3-tts clone` | 음성 클론 WebUI 시작 (Base 모델) |
| `/qwen3-tts custom` | 프리셋 화자 WebUI 시작 (CustomVoice 모델) |
| `/qwen3-tts stop` | WebUI 종료 |
| `/qwen3-tts status` | 상태 확인 |
| `/qwen3-tts log` | 로그 확인 |
| `/qwen3-tts uninstall` | 제거 |

#### 옵션

```bash
/qwen3-tts clone port=7860    # 포트 지정 (기본: 8000)
```

### 요구사항

- Python 3.10+
- NVIDIA GPU 권장 (CUDA 11.8+ / 12.x)
- ~4GB VRAM
- ~8GB 디스크 공간 (모델용)

### 프리셋 화자 (CustomVoice 모델)

| 화자 | 언어 | 설명 |
|------|------|------|
| **Sohee** | 한국어 | 따뜻하고 감정 풍부한 여성음 |
| Vivian | 중국어 | 밝고 젊은 여성음 |
| Serena | 중국어 | 따뜻하고 부드러운 여성음 |
| Ryan | 영어 | 역동적인 남성음 |
| Aiden | 영어 | 밝은 미국 남성음 |
| Ono_Anna | 일본어 | 장난스러운 여성음 |

### 스크린샷

#### 환경 스캔
```
==========================================
  Qwen3-TTS 설치 - 환경 스캔
==========================================

[시스템]
  아키텍처: x86_64
  RAM: 32Gi

[Python]
  버전: 3.12
  경로: /usr/bin/python3

[GPU]
  GPU: NVIDIA GeForce RTX 4090
  VRAM: 24576 MiB
  CUDA: 12.4

환경 스캔 완료. 설치 옵션을 분석합니다...
```

#### 음성 클론 WebUI
```
==========================================
  Qwen3-TTS 음성 클론 WebUI
==========================================

모델: Qwen/Qwen3-TTS-12Hz-1.7B-Base
원본: https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base

기능: 3초 참조 오디오로 음성 클론
포트: 8000

==========================================
  WebUI 준비 완료!
==========================================

접속: http://localhost:8000
```

---

## English

A Claude Code skill that helps you install and use [Qwen3-TTS](https://github.com/QwenLM/Qwen3-TTS) - Alibaba's open-source Text-to-Speech model.

### What This Skill Does

- Auto-install **Qwen3-TTS-12Hz-1.7B-CustomVoice** / **Qwen3-TTS-12Hz-1.7B-Base** models
- Auto-scan system environment (GPU, CUDA, Python version)
- Provide installation options based on your system (GPU accelerated / CPU only)
- Run and manage WebUI

### Features

- **Voice Cloning**: Clone any voice with just 3 seconds of reference audio (Base model)
- **Preset Voices**: 9 premium voice profiles (CustomVoice model)
- **10 Languages**: Korean, English, Chinese, Japanese, German, French, Russian, Portuguese, Spanish, Italian

### Original Resources

| Resource | URL |
|----------|-----|
| **HuggingFace (CustomVoice)** | https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice |
| **HuggingFace (Base/Clone)** | https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base |
| **GitHub** | https://github.com/QwenLM/Qwen3-TTS |
| **Demo (Clone)** | https://huggingface.co/spaces/Qwen/Qwen-TTS-Clone-Demo |
| **Demo (TTS)** | https://huggingface.co/spaces/Qwen/Qwen3-TTS-Demo |

### Installation

1. Copy `qwen3-tts.md` to your Claude Code commands directory:

```bash
# Download and install
curl -o ~/.claude/commands/qwen3-tts.md \
  https://raw.githubusercontent.com/treylom/qwen3-tts-claude-skill/main/qwen3-tts.md
```

2. Run the install command in Claude Code:

```
/qwen3-tts install
```

3. The skill will scan your environment and offer installation options:
   - **GPU Accelerated** (Recommended if NVIDIA GPU detected)
   - **CPU Only**
   - **Upgrade** (if already installed)

### Usage

| Command | Description |
|---------|-------------|
| `/qwen3-tts install` | Install (environment scan → option selection) |
| `/qwen3-tts clone` | Start Voice Clone WebUI (Base model) |
| `/qwen3-tts custom` | Start Preset Voice WebUI (CustomVoice model) |
| `/qwen3-tts stop` | Stop WebUI |
| `/qwen3-tts status` | Check status |
| `/qwen3-tts log` | View logs |
| `/qwen3-tts uninstall` | Uninstall |

#### Options

```bash
/qwen3-tts clone port=7860    # Specify custom port (default: 8000)
```

### Requirements

- Python 3.10+
- NVIDIA GPU recommended (CUDA 11.8+ / 12.x)
- ~4GB VRAM
- ~8GB disk space (for models)

### Preset Voices (CustomVoice Model)

| Voice | Language | Description |
|-------|----------|-------------|
| **Sohee** | Korean | Warm, emotional female voice |
| Vivian | Chinese | Bright, young female voice |
| Serena | Chinese | Warm, soft female voice |
| Ryan | English | Dynamic male voice |
| Aiden | English | Clear American male voice |
| Ono_Anna | Japanese | Playful female voice |

---

## License

This skill is provided under MIT License.
The Qwen3-TTS model itself is subject to [Alibaba's license terms](https://github.com/QwenLM/Qwen3-TTS/blob/main/LICENSE).

## Contributing

Issues and pull requests are welcome!

## Acknowledgments

- [Qwen Team](https://github.com/QwenLM) for the amazing Qwen3-TTS model
- [Anthropic](https://www.anthropic.com/) for Claude Code
