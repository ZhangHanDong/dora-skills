---
name: hub-translation
description: "Use for translation nodes in dora.
Triggers on: dora-opus, dora-argotranslate, translation, translate, opus, argos,
language translation, multilingual,
翻译, 多语言"
globs: ["**/dataflow.yml", "**/dataflow.yaml"]
source: "https://github.com/dora-rs/dora-hub"
---

# Translation Nodes

> Translate text between languages using neural machine translation

## Available Translation Methods

> **Note:** Dedicated translation nodes are not yet in node-hub. Use LLM-based translation with dora-qwen or dora-qwen2-5-vl.

| Method | Install | Description |
|--------|---------|-------------|
| dora-qwen | `pip install dora-qwen` | LLM-based translation |
| dora-transformers | `pip install dora-transformers` | Huggingface models |

## LLM-Based Translation with dora-qwen

Use Qwen LLM for translation tasks.

### YAML Configuration

```yaml
- id: translate
  build: pip install dora-qwen
  path: dora-qwen
  inputs:
    text: whisper/text
  outputs:
    - text
  env:
    SYSTEM_PROMPT: "You are a translator. Translate the following text from English to Chinese. Output only the translation."
```

### Supported Languages

Qwen supports translation between most major language pairs including:
- English, Chinese, Japanese, Korean
- German, French, Spanish, Portuguese
- And many more

## dora-transformers (Custom Model)

Use Huggingface translation models via dora-transformers.

### YAML Configuration

```yaml
- id: translate
  build: pip install dora-transformers
  path: dora-transformers
  inputs:
    text: input/text
  outputs:
    - text
  env:
    MODEL: Helsinki-NLP/opus-mt-en-zh
    TASK: translation
```

### Features
- Use any Huggingface translation model
- Support for Opus-MT, M2M100, NLLB models
- Offline inference supported

## Real-Time Translation Pipeline

```yaml
nodes:
  # Microphone
  - id: microphone
    build: pip install dora-microphone
    path: dora-microphone
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - audio

  # VAD
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

  # Translation (using LLM)
  - id: translate
    build: pip install dora-qwen
    path: dora-qwen
    inputs:
      text: whisper/text
    outputs:
      - text
    env:
      SYSTEM_PROMPT: "Translate to Chinese:"

  # TTS for translated text
  - id: tts
    build: pip install dora-kokoro-tts
    path: dora-kokoro-tts
    inputs:
      text: translate/text
    outputs:
      - audio

  # Speaker
  - id: speaker
    build: pip install dora-pyaudio
    path: dora-pyaudio
    inputs:
      audio: tts/audio

  # Visualization
  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      original:
        source: whisper/text
        metadata:
          primitive: "text"
      translated:
        source: translate/text
        metadata:
          primitive: "text"
```

## Multi-Language Translation

Use multiple dora-qwen instances with different translation prompts:

```yaml
nodes:
  - id: input
    build: pip install terminal-input
    path: terminal-input
    outputs:
      - text

  # English to Chinese
  - id: en_to_zh
    build: pip install dora-qwen
    path: dora-qwen
    inputs:
      text: input/text
    outputs:
      - text
    env:
      SYSTEM_PROMPT: "Translate the following text to Chinese. Output only the translation."

  # English to Japanese
  - id: en_to_ja
    build: pip install dora-qwen
    path: dora-qwen
    inputs:
      text: input/text
    outputs:
      - text
    env:
      SYSTEM_PROMPT: "Translate the following text to Japanese. Output only the translation."

  # English to Spanish
  - id: en_to_es
    build: pip install dora-qwen
    path: dora-qwen
    inputs:
      text: input/text
    outputs:
      - text
    env:
      SYSTEM_PROMPT: "Translate the following text to Spanish. Output only the translation."

  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      original: input/text
      chinese: en_to_zh/text
      japanese: en_to_ja/text
      spanish: en_to_es/text
```

## Text Data Format

### Input/Output

```python
import pyarrow as pa

# Send text for translation
text = "Hello, how are you?"
node.send_output("text", pa.array([text]))

# Receive translated text
translated = event["value"][0].as_py()
```

## Related Skills

- **hub-audio** - Speech-to-text for voice translation
- **hub-llm** - Language models
- **hub-visualization** - Display original and translated text
