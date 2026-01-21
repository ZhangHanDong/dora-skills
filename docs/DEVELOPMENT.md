# Dora Skills - Claude Instructions

## Overview

This plugin provides comprehensive skills for developing robotic applications with dora-rs, a dataflow-oriented architecture framework.

## Priority Routing

For ANY dora-rs related question, ALWAYS:

1. **Load dora-router first** - `skills/dora-router/SKILL.md`
2. **Then load the specific domain skill** based on the question type

## Skill Routing Table

### Core Development

| Question Type | Keywords | Load Skill |
|---------------|----------|------------|
| Dataflow configuration | YAML, nodes, inputs, outputs, timer | `dataflow-config` |
| Rust node development | DoraNode, EventStream, send_output | `node-api-rust` |
| Python node development | dora.Node, python, event | `node-api-python` |
| Operator development | DoraOperator, on_event | `operator-api` |
| CLI commands | dora run, dora build, dora start | `cli-commands` |
| Node testing | integration testing, JSONL | `integration-testing` |

### Domain Skills

| Question Type | Keywords | Load Skill |
|---------------|----------|------------|
| Vision/ML pipelines | YOLO, detection, camera, image | `domain-vision` |
| Audio processing | speech, TTS, STT, Whisper | `domain-audio` |
| Robot control | arm, chassis, servo, motor | `domain-robot` |
| Data recording | lerobot, recording, dataset | `data-pipeline` |
| Pre-built nodes overview | hub, packages | `hub-nodes` |

### Hub Node Skills (Detailed)

| Question About | Keywords | Load Skill |
|----------------|----------|------------|
| Camera/video capture | opencv-video-capture, realsense, orbbeck | `hub-camera` |
| Audio processing | microphone, vad, whisper, pyaudio, kokoro-tts | `hub-audio` |
| Object detection/tracking | yolo, sam2, cotracker, bbox | `hub-detection` |
| Language models | qwen, vlm, llm, internvl | `hub-llm` |
| Robot control nodes | piper, reachy, ugv, kit-car, rdt-1b | `hub-robot` |
| Visualization | rerun, opencv-plot, primitives | `hub-visualization` |
| Data recording nodes | llama-factory-recorder, lerobot-dashboard | `hub-recording` |
| Translation | opus, argotranslate | `hub-translation` |

## Default Project Settings

When creating new dora dataflows or nodes:

```yaml
# Use latest dora-rs conventions
# Timer format: dora/timer/millis/<ms> or dora/timer/secs/<s>
# Input format: source_node/output_name
# Use pip install with --uv for faster installs
```

For Rust nodes:
```toml
[package]
edition = "2024"

[dependencies]
dora-node-api = "0.4"
eyre = "0.6"

[lints.clippy]
all = "warn"
```

## Response Format

When answering dora questions:

1. **Identify the question type** from the routing table
2. **Load the appropriate skill**
3. **Provide code examples** from the skill
4. **Suggest hub nodes** when applicable
5. **Include YAML and code** for complete solutions

## Example Routing

```
User: "How do I create a YOLO detection pipeline?"

1. Load: dora-router (main router)
2. Identify: Vision domain question
3. Load: domain-vision (detailed vision skill)
4. Load: hub-nodes (for dora-yolo package info)
5. Provide: Complete YAML + explanation
```

## Common Patterns

### Vision Pipeline

```yaml
nodes:
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image

  - id: detector
    build: pip install dora-yolo
    path: dora-yolo
    inputs:
      image: camera/image
    outputs:
      - bbox

  - id: plot
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
      boxes2d: detector/bbox
```

### Voice Assistant

```yaml
nodes:
  - id: microphone
    build: pip install dora-microphone
    path: dora-microphone
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - audio

  - id: stt
    build: pip install dora-whisper
    path: dora-whisper
    inputs:
      audio: microphone/audio
    outputs:
      - text

  - id: llm
    build: pip install dora-qwen
    path: dora-qwen
    inputs:
      text: stt/text
    outputs:
      - response

  - id: tts
    build: pip install dora-kokoro-tts
    path: dora-kokoro-tts
    inputs:
      text: llm/response
    outputs:
      - audio

  - id: speaker
    build: pip install dora-pyaudio
    path: dora-pyaudio
    inputs:
      audio: tts/audio
```

## Resources

- **Documentation**: https://dora-rs.ai
- **GitHub**: https://github.com/dora-rs/dora
- **Hub Nodes**: https://github.com/dora-rs/dora-hub
- **Discord**: https://discord.gg/6eMGGutkfE

## Skill Files Location

```
skills/
├── dora-router/SKILL.md           # Main router (LOAD FIRST)
├── dataflow-config/SKILL.md       # YAML configuration
├── node-api-rust/SKILL.md         # Rust API
├── node-api-python/SKILL.md       # Python API
├── operator-api/SKILL.md          # Operators
├── cli-commands/SKILL.md          # CLI
├── integration-testing/SKILL.md   # Testing
├── domain-vision/SKILL.md         # Vision/ML
├── domain-audio/SKILL.md          # Audio
├── domain-robot/SKILL.md          # Robot control
├── data-pipeline/SKILL.md         # Data pipelines
├── hub-nodes/SKILL.md             # Pre-built nodes overview
├── hub-camera/SKILL.md            # Camera nodes (detailed)
├── hub-audio/SKILL.md             # Audio nodes (detailed)
├── hub-detection/SKILL.md         # Detection nodes (detailed)
├── hub-llm/SKILL.md               # Language model nodes (detailed)
├── hub-robot/SKILL.md             # Robot control nodes (detailed)
├── hub-visualization/SKILL.md     # Visualization nodes (detailed)
├── hub-recording/SKILL.md         # Recording nodes (detailed)
└── hub-translation/SKILL.md       # Translation nodes (detailed)
```
