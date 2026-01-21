---
name: domain-audio
description: "Use for audio processing pipeline questions with dora.
Triggers on: speech, TTS, STT, voice, audio, Whisper, Kokoro, text-to-speech,
speech-to-text, voice activity, VAD, microphone,
语音, 音频, 文本转语音, 语音转文本, 语音识别"
globs: ["**/dataflow.yml", "**/*.py"]
source: "https://github.com/dora-rs/dora-hub"
---

# Domain: Audio Processing

> Building audio and speech applications with dora-rs

## Overview

Dora supports audio processing pipelines including:
- Speech-to-Text (STT)
- Text-to-Speech (TTS)
- Voice Activity Detection (VAD)
- Real-time audio streaming

## Common Audio Nodes

### Speech-to-Text (Whisper)

```yaml
- id: stt
  build: pip install dora-distil-whisper
  path: dora-distil-whisper
  inputs:
    audio: microphone/audio
  outputs:
    - text
  env:
    MODEL: base                 # tiny, base, small, medium, large
    LANGUAGE: en
```

### Text-to-Speech (Kokoro)

```yaml
- id: tts
  build: pip install dora-kokoro-tts
  path: dora-kokoro-tts
  inputs:
    text: llm/response
  outputs:
    - audio
  env:
    VOICE: af_bella
```

### Voice Activity Detection

```yaml
- id: vad
  build: pip install dora-vad
  path: dora-vad
  inputs:
    audio: microphone/audio
  outputs:
    - speech_segments
    - is_speaking
```

## Complete Voice Assistant Pipeline

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
    env:
      SAMPLE_RATE: "16000"
      CHANNELS: "1"

  # Voice activity detection
  - id: vad
    build: pip install dora-vad
    path: dora-vad
    inputs:
      audio: microphone/audio
    outputs:
      - speech_audio
      - is_speaking

  # Speech to text
  - id: stt
    build: pip install dora-distil-whisper
    path: dora-distil-whisper
    inputs:
      audio: vad/speech_audio
    outputs:
      - text
    env:
      MODEL: base

  # Language model
  - id: llm
    build: pip install dora-qwen
    path: dora-qwen
    inputs:
      text: stt/text
    outputs:
      - response

  # Text to speech
  - id: tts
    build: pip install dora-kokoro-tts
    path: dora-kokoro-tts
    inputs:
      text: llm/response
    outputs:
      - audio

  # Audio playback
  - id: speaker
    build: pip install dora-pyaudio
    path: dora-pyaudio
    inputs:
      audio: tts/audio
```

## Custom Audio Node Example

### Microphone Capture

```python
# microphone_node.py
import numpy as np
import sounddevice as sd
from dora import Node

node = Node()

# Audio parameters
SAMPLE_RATE = 16000
CHANNELS = 1
CHUNK_SIZE = 1024

def audio_callback(indata, frames, time, status):
    if status:
        print(status)
    # Store audio data
    audio_buffer.append(indata.copy())

audio_buffer = []

with sd.InputStream(
    samplerate=SAMPLE_RATE,
    channels=CHANNELS,
    callback=audio_callback,
    blocksize=CHUNK_SIZE
):
    for event in node:
        if event["type"] == "INPUT" and event["id"] == "tick":
            if audio_buffer:
                # Combine and send audio chunks
                audio = np.concatenate(audio_buffer, axis=0)
                audio_buffer.clear()
                node.send_output("audio", audio.flatten())

        elif event["type"] == "STOP":
            break
```

### Speech Recognition

```python
# stt_node.py
import numpy as np
import whisper
from dora import Node

node = Node()
model = whisper.load_model("base")

for event in node:
    if event["type"] == "INPUT" and event["id"] == "audio":
        audio = event["value"].astype(np.float32) / 32768.0

        # Transcribe
        result = model.transcribe(audio, fp16=False)
        text = result["text"].strip()

        if text:
            node.send_output("text", [text])

    elif event["type"] == "STOP":
        break
```

### Text-to-Speech

```python
# tts_node.py
import numpy as np
from dora import Node
from TTS.api import TTS

node = Node()
tts = TTS(model_name="tts_models/en/ljspeech/tacotron2-DDC")

for event in node:
    if event["type"] == "INPUT" and event["id"] == "text":
        text = event["value"][0] if isinstance(event["value"], list) else str(event["value"])

        # Generate speech
        wav = tts.tts(text)
        audio = np.array(wav, dtype=np.float32)

        node.send_output("audio", audio)

    elif event["type"] == "STOP":
        break
```

## Audio Data Format

```python
# Audio as numpy array
# - Shape: (samples,) or (samples, channels)
# - dtype: np.float32 or np.int16
# - Sample rate: typically 16000 or 44100

# 16-bit integer audio
audio_int16 = np.array([...], dtype=np.int16)

# Float32 audio (normalized to [-1, 1])
audio_float32 = audio_int16.astype(np.float32) / 32768.0
```

## Performance Tips

1. **Use appropriate chunk sizes**
   - Small chunks (512-1024): Lower latency
   - Larger chunks (2048-4096): Better efficiency

2. **Use VAD to reduce processing**
   - Only process when speech detected
   - Saves compute resources

3. **Choose appropriate model sizes**
   - Whisper tiny/base: Fast, lower accuracy
   - Whisper medium/large: Slower, higher accuracy

4. **Buffer audio for batch processing**
   ```yaml
   inputs:
     audio:
       source: microphone/audio
       queue_size: 10  # Buffer multiple chunks
   ```

## Available Hub Nodes

| Node | Package | Purpose |
|------|---------|---------|
| dora-microphone | `pip install dora-microphone` | Audio input |
| dora-pyaudio | `pip install dora-pyaudio` | Audio output |
| dora-distil-whisper | `pip install dora-distil-whisper` | Speech-to-text |
| dora-kokoro-tts | `pip install dora-kokoro-tts` | Text-to-speech |
| dora-vad | `pip install dora-vad` | Voice activity |
| dora-outtetts | `pip install dora-outtetts` | TTS alternative |

## Related Skills

- **hub-nodes** - All pre-built nodes
- **dataflow-config** - YAML configuration
- **domain-vision** - Vision pipelines
