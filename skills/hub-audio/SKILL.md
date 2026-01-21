---
name: hub-audio
description: "Use for audio processing nodes in dora.
Triggers on: dora-microphone, dora-vad, dora-distil-whisper, dora-pyaudio, dora-kokoro-tts,
microphone, VAD, voice activity, speech-to-text, STT, text-to-speech, TTS, whisper, kokoro,
audio, speaker, silero, speech recognition,
麦克风, 语音识别, 语音合成, 音频, VAD"
globs: ["**/dataflow.yml", "**/dataflow.yaml"]
source: "https://github.com/dora-rs/dora-hub"
---

# Audio Processing Nodes

> Microphone input, voice activity detection, speech-to-text, and text-to-speech

## Audio Pipeline Overview

```
Microphone → VAD → Whisper STT → LLM → Kokoro TTS → Speaker
```

## Available Audio Nodes

| Node | Install | Description |
|------|---------|-------------|
| dora-microphone | `pip install dora-microphone` | Microphone input with VAD |
| dora-vad | `pip install dora-vad` | Silero voice activity detection |
| dora-distil-whisper | `pip install dora-distil-whisper` | Distil-Whisper STT |
| dora-kokoro-tts | `pip install dora-kokoro-tts` | Kokoro text-to-speech |
| dora-pyaudio | `pip install dora-pyaudio` | Audio playback |

## dora-microphone

Capture audio from microphone with built-in voice activity detection.

### YAML Configuration

```yaml
- id: microphone
  build: pip install dora-microphone
  path: dora-microphone
  inputs:
    tick: dora/timer/millis/100
  outputs:
    - audio  # 16kHz Float32Array
```

### Output Format

```python
# audio: Float32Array at 16kHz sample rate
metadata = {"sample_rate": 16000}
```

## dora-vad

Silero Voice Activity Detection - filters audio to speech-only segments.

### YAML Configuration

```yaml
- id: vad
  build: pip install dora-vad
  path: dora-vad
  inputs:
    audio: microphone/audio  # 8kHz or 16kHz
  outputs:
    - audio  # truncated to speech only
```

### Features
- Detects beginning and ending of voice activity
- Filters out silence and background noise
- Maximum voice duration limit to avoid long waits
- Uses Silero VAD model

## dora-distil-whisper

Speech-to-text using Distil-Whisper for efficient transcription.

### YAML Configuration

```yaml
- id: whisper
  build: pip install dora-distil-whisper
  path: dora-distil-whisper
  inputs:
    input: vad/audio
  outputs:
    - text  # StringArray
  env:
    TARGET_LANGUAGE: english  # or other supported languages
```

### Output Format

```python
# text: StringArray containing transcribed text
text = event["value"][0].as_py()  # Get string
```

## dora-kokoro-tts

Efficient text-to-speech using Kokoro.

### YAML Configuration

```yaml
- id: tts
  build: pip install dora-kokoro-tts
  path: dora-kokoro-tts
  inputs:
    text: llm/text
  outputs:
    - audio  # Float32Array
```

## dora-pyaudio

Audio playback through speakers.

### YAML Configuration

```yaml
- id: speaker
  build: pip install dora-pyaudio
  path: dora-pyaudio
  inputs:
    audio: tts/audio
```

### Prerequisites

**macOS:**
```bash
brew install portaudio
```

**Linux:**
```bash
sudo apt-get install portaudio19-dev python-all-dev
```

## Complete Speech-to-Text Pipeline

```yaml
nodes:
  # Microphone input
  - id: microphone
    build: pip install dora-microphone
    path: dora-microphone
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - audio

  # Voice activity detection
  - id: vad
    build: pip install dora-vad
    path: dora-vad
    inputs:
      audio: microphone/audio
    outputs:
      - audio

  # Speech to text
  - id: whisper
    build: pip install dora-distil-whisper
    path: dora-distil-whisper
    inputs:
      input: vad/audio
    outputs:
      - text
    env:
      TARGET_LANGUAGE: english

  # Visualization
  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      transcription:
        source: whisper/text
        metadata:
          primitive: "text"
```

## Speech-to-Speech Pipeline (Voice Assistant)

```yaml
nodes:
  # Audio input
  - id: microphone
    build: pip install dora-microphone
    path: dora-microphone
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - audio

  # VAD filtering
  - id: vad
    build: pip install dora-vad
    path: dora-vad
    inputs:
      audio: microphone/audio
    outputs:
      - audio

  # Speech to text
  - id: whisper
    build: pip install dora-distil-whisper
    path: dora-distil-whisper
    inputs:
      input: vad/audio
    outputs:
      - text

  # LLM processing
  - id: llm
    build: pip install dora-qwen
    path: dora-qwen
    inputs:
      text: whisper/text
    outputs:
      - text

  # Text to speech
  - id: tts
    build: pip install dora-kokoro-tts
    path: dora-kokoro-tts
    inputs:
      text: llm/text
    outputs:
      - audio

  # Audio output
  - id: speaker
    build: pip install dora-pyaudio
    path: dora-pyaudio
    inputs:
      audio: tts/audio
```

## Audio Data Format

### Float32 Audio Array

```python
import pyarrow as pa
import numpy as np

# Audio at 16kHz
sample_rate = 16000
audio_samples = np.array([...], dtype=np.float32)

# Send audio
audio_data = pa.array(audio_samples)
node.send_output("audio", audio_data, {"sample_rate": sample_rate})
```

### Receiving Audio

```python
audio = event["value"].to_numpy()
sample_rate = event["metadata"].get("sample_rate", 16000)
```

## Troubleshooting

### No audio input
```bash
# List audio devices
python -c "import sounddevice; print(sounddevice.query_devices())"
```

### PortAudio error
```bash
# macOS
brew install portaudio

# Linux
sudo apt-get install portaudio19-dev
```

### Whisper slow on CPU
- Use smaller model (tiny, base)
- Consider dora-funasr for Chinese speech recognition

## Related Skills

- **hub-llm** - Language models for voice assistants
- **hub-visualization** - Rerun text visualization
- **domain-audio** - Audio pipeline patterns
