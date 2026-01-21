---
name: hub-llm
description: "Use for language model nodes in dora.
Triggers on: dora-qwen, dora-qwen2-5-vl, dora-internvl, Qwen, VLM, LLM,
vision language model, large language model, text generation, image understanding,
InternVL, Qwen2.5, multimodal,
大语言模型, 视觉语言模型, 文本生成"
globs: ["**/dataflow.yml", "**/dataflow.yaml"]
source: "https://github.com/dora-rs/dora-hub"
---

# Language Model Nodes

> LLMs and Vision-Language Models for text generation and image understanding

## Available LLM Nodes

| Node | Install | Description | Type |
|------|---------|-------------|------|
| dora-qwen | `pip install dora-qwen` | Qwen2.5 text LLM | LLM |
| dora-qwen2-5-vl | `pip install dora-qwen2-5-vl` | Qwen2.5-VL multimodal | VLM |
| dora-internvl | `pip install dora-internvl` | InternVL multimodal | VLM |

## dora-qwen

Qwen2.5 large language model for text generation.

### YAML Configuration

```yaml
- id: llm
  build: pip install dora-qwen
  path: dora-qwen
  inputs:
    text: input/text
  outputs:
    - text
```

### Input/Output

**Input:** StringArray with prompt text
**Output:** StringArray with generated response

```python
# Sending prompt
node.send_output("text", pa.array(["What is the capital of France?"]))

# Receiving response
response = event["value"][0].as_py()
```

## dora-qwen2-5-vl

Qwen2.5-VL vision-language model for image understanding.

### YAML Configuration

```yaml
- id: vlm
  build: pip install dora-qwen2-5-vl
  path: dora-qwen2-5-vl
  inputs:
    image:
      source: camera/image
      queue_size: 1        # Process latest image only
    text: whisper/text     # Question/prompt
  outputs:
    - text                 # Response
  env:
    DEFAULT_QUESTION: "Describe the image in a very short sentence."
```

### Input Format

**image:** UInt8Array with metadata
```python
metadata = {"width": 640, "height": 480, "encoding": "bgr8"}
```

**text:** StringArray with question (optional)
- If no text input, uses DEFAULT_QUESTION from env

### Output Format

```python
# text: StringArray
response = event["value"][0].as_py()
metadata = {"primitive": "text"}  # for dora-rerun
```

## dora-internvl

InternVL vision-language model.

### YAML Configuration

```yaml
- id: internvl
  build: pip install dora-internvl
  path: dora-internvl
  inputs:
    image: camera/image
    text: input/text
  outputs:
    - text
```

## VLM + Voice Assistant Pipeline

```yaml
nodes:
  # Camera
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - image
    env:
      IMAGE_WIDTH: 640
      IMAGE_HEIGHT: 480

  # Microphone
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

  # Vision Language Model
  - id: vlm
    build: pip install dora-qwen2-5-vl
    path: dora-qwen2-5-vl
    inputs:
      image:
        source: camera/image
        queue_size: 1
      text: whisper/text
    outputs:
      - text
    env:
      DEFAULT_QUESTION: "What do you see in this image?"

  # Text to speech
  - id: tts
    build: pip install dora-kokoro-tts
    path: dora-kokoro-tts
    inputs:
      text: vlm/text
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
      image: camera/image
      vlm_response:
        source: vlm/text
        metadata:
          primitive: "text"
```

## Text-Only LLM Pipeline

```yaml
nodes:
  # Terminal input
  - id: terminal
    build: pip install terminal-input
    path: terminal-input
    outputs:
      - text

  # LLM
  - id: llm
    build: pip install dora-qwen
    path: dora-qwen
    inputs:
      text: terminal/text
    outputs:
      - text

  # Visualization
  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      user_input:
        source: terminal/text
        metadata:
          primitive: "text"
      llm_response:
        source: llm/text
        metadata:
          primitive: "text"
```

## VLM + Object Detection Pipeline

```yaml
nodes:
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - image

  - id: yolo
    build: pip install dora-yolo
    path: dora-yolo
    inputs:
      image: camera/image
    outputs:
      - bbox

  - id: vlm
    build: pip install dora-qwen2-5-vl
    path: dora-qwen2-5-vl
    inputs:
      image:
        source: camera/image
        queue_size: 1
    outputs:
      - text
    env:
      DEFAULT_QUESTION: "Describe what you see and any notable objects."

  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
      detections: yolo/bbox
      description: vlm/text
```

## Text Data Format

### Sending Text

```python
import pyarrow as pa

# Send text prompt
text = "What is in this image?"
node.send_output("text", pa.array([text]), {"primitive": "text"})
```

### Receiving Text

```python
if event["type"] == "INPUT":
    text = event["value"][0].as_py()
    print(f"Received: {text}")
```

## Queue Size Configuration

For VLMs processing images, use `queue_size: 1` to process only the latest frame:

```yaml
inputs:
  image:
    source: camera/image
    queue_size: 1  # Drop old frames, process latest only
```

This prevents processing backlogs when inference is slower than frame rate.

## Related Skills

- **hub-audio** - Speech-to-text for voice interaction
- **hub-detection** - Object detection with YOLO
- **hub-visualization** - Text and image visualization
