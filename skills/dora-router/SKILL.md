---
name: dora-router
description: "CRITICAL: Use for ALL dora-rs questions including dataflow config, node development, and robotic applications.
Triggers on: dora, dora-rs, dataflow, DoraNode, EventStream, dora run, dora build,
dataflow.yml, nodes:, inputs:, outputs:, dora/timer, shared memory, arrow,
机器人, robotics, 数据流, 节点, node api, operator, python node, rust node,
camera, yolo, detection, vision, audio, speech, arm control, lerobot"
globs: ["**/dataflow.yml", "**/dataflow.yaml", "**/*.py", "**/*.rs"]
source: "https://dora-rs.ai"
---

# Dora Question Router

> **Version:** 1.0.0 | **Last Updated:** 2026-01-20
>
> Intelligent routing for dora-rs dataflow development questions

## Overview

dora-rs is a Dataflow-Oriented Robotic Architecture framework. This router helps navigate to the correct skill based on the question type.

## Question Type Routing

### Core Development

| Question Pattern | Keywords | Route To |
|------------------|----------|----------|
| Dataflow YAML configuration | nodes, inputs, outputs, timer, yaml | **dataflow-config** |
| Rust node development | DoraNode, EventStream, send_output, init_from_env | **node-api-rust** |
| Python node development | dora.Node, event, python node | **node-api-python** |
| Operator development | DoraOperator, on_event, register_operator | **operator-api** |
| CLI commands | dora run, dora build, dora start, dora stop | **cli-commands** |
| Testing nodes | integration testing, test inputs, JSONL | **integration-testing** |

### Domain Applications

| Domain Keywords | Route To |
|-----------------|----------|
| YOLO, detection, segmentation, VLM, camera, image | **domain-vision** |
| speech, TTS, STT, voice, audio, Whisper, Kokoro | **domain-audio** |
| arm control, chassis, actuator, robot, servo | **domain-robot** |
| recording, replay, lerobot, data collection | **data-pipeline** |
| dora-yolo, dora-rerun, opencv-video-capture | **hub-nodes** |

### Hub Node Skills (Detailed)

| Question About | Keywords | Route To |
|----------------|----------|----------|
| Camera/video capture | opencv-video-capture, realsense, orbbeck, webcam | **hub-camera** |
| Audio processing | microphone, vad, whisper, pyaudio, kokoro-tts | **hub-audio** |
| Object detection/tracking | yolo, sam2, cotracker, bounding box, mask | **hub-detection** |
| Language models | qwen, vlm, llm, internvl, text generation | **hub-llm** |
| Robot control | piper, reachy, ugv, kit-car, rdt-1b, arm | **hub-robot** |
| Visualization | rerun, opencv-plot, display, primitives | **hub-visualization** |
| Data recording | llama-factory-recorder, lerobot-dashboard | **hub-recording** |
| Translation | opus, argotranslate, translate | **hub-translation** |

## Routing Examples

```
User: "How do I create a dataflow YAML?"
Route: dataflow-config

User: "How to send output from a Rust node?"
Route: node-api-rust

User: "I want to add YOLO detection to my pipeline"
Route: domain-vision + hub-nodes

User: "How to control a robot arm with dora?"
Route: domain-robot

User: "How to record data for training?"
Route: data-pipeline
```

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                  Dataflow YAML                   │
│  (nodes, inputs, outputs, connections)          │
└─────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│  Python Node  │ │   Rust Node   │ │   Operator    │
│  (dora.Node)  │ │  (DoraNode)   │ │(DoraOperator) │
└───────────────┘ └───────────────┘ └───────────────┘
        │               │               │
        └───────────────┼───────────────┘
                        ▼
┌─────────────────────────────────────────────────┐
│           Shared Memory / Arrow Data            │
│         (Zero-copy data transfer)               │
└─────────────────────────────────────────────────┘
```

## Quick Reference

### CLI Commands

| Command | Description |
|---------|-------------|
| `dora new` | Create new dataflow/node/operator |
| `dora build` | Build nodes in a dataflow |
| `dora run` | Run dataflow (standalone) |
| `dora up` | Start coordinator and daemon |
| `dora start` | Start dataflow on daemon |
| `dora stop` | Stop running dataflow |
| `dora list` / `dora ps` | List running dataflows |
| `dora logs` | View node logs |
| `dora destroy` | Stop coordinator and daemon |

### Timer Input Format

```yaml
inputs:
  tick: dora/timer/millis/100  # Every 100ms
  tick: dora/timer/secs/5      # Every 5 seconds
```

### Input Connection Format

```yaml
inputs:
  input_name: source_node/output_name
```

## Skill Files

### Core Skills
```
skills/dataflow-config/SKILL.md     # YAML configuration
skills/node-api-rust/SKILL.md       # Rust DoraNode API
skills/node-api-python/SKILL.md     # Python dora.Node API
skills/operator-api/SKILL.md        # Operator development
skills/cli-commands/SKILL.md        # CLI usage
skills/integration-testing/SKILL.md # Testing nodes
```

### Domain Skills
```
skills/domain-vision/SKILL.md       # ML/Vision pipelines
skills/domain-audio/SKILL.md        # Audio processing
skills/domain-robot/SKILL.md        # Robot control
skills/data-pipeline/SKILL.md       # Data collection
skills/hub-nodes/SKILL.md           # Pre-built nodes overview
```

### Hub Node Skills (Detailed)
```
skills/hub-camera/SKILL.md          # Camera capture nodes
skills/hub-audio/SKILL.md           # Audio processing nodes
skills/hub-detection/SKILL.md       # Object detection/tracking
skills/hub-llm/SKILL.md             # Language models
skills/hub-robot/SKILL.md           # Robot control nodes
skills/hub-visualization/SKILL.md   # Rerun and OpenCV plot
skills/hub-recording/SKILL.md       # Data recording nodes
skills/hub-translation/SKILL.md     # Translation nodes
```

## Instructions for Claude

### When handling dora-rs questions:

1. **Identify Question Type** - Match keywords to routing table
2. **Load Appropriate Skill** - Read the skill file for context
3. **Provide Examples** - Include code examples from skills
4. **Reference Hub Nodes** - Suggest pre-built nodes when applicable

### Default Project Settings

When creating dora projects:
- Use latest dora-rs version (0.4.0)
- Use `edition = "2024"` for Rust nodes
- Use Apache Arrow for data format
- Configure appropriate timer frequencies

### Priority Order

1. Check if question is about dataflow configuration
2. Check if question is about specific API (Rust/Python/Operator)
3. Check if question is domain-specific (vision/audio/robot)
4. Suggest relevant hub nodes for common tasks
