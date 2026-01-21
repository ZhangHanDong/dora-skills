# Dora Skills Index

> Complete catalog of all dora-skills

## Core Development Skills

| Skill | Description | Keywords |
|-------|-------------|----------|
| **dora-router** | Main router for all dora questions | dora, dataflow, routing |
| **dataflow-config** | YAML configuration | nodes, inputs, outputs, timer, yaml |
| **node-api-rust** | Rust DoraNode API | DoraNode, EventStream, send_output |
| **node-api-python** | Python dora.Node API | dora.Node, python node, event |
| **operator-api** | Operator development | DoraOperator, on_event, runtime |
| **cli-commands** | CLI usage | dora run, dora build, dora start |
| **integration-testing** | Testing nodes | test inputs, JSONL, integration |

## Domain Skills

| Skill | Description | Keywords |
|-------|-------------|----------|
| **domain-vision** | ML/Vision pipelines | YOLO, detection, camera, image |
| **domain-audio** | Audio processing | speech, TTS, STT, Whisper |
| **domain-robot** | Robot control | arm, chassis, servo, kinematics |
| **data-pipeline** | Data recording/replay | lerobot, recording, dataset |
| **hub-nodes** | Pre-built nodes overview | dora-yolo, dora-rerun, packages |

## Hub Node Skills (Detailed)

| Skill | Description | Keywords |
|-------|-------------|----------|
| **hub-camera** | Camera capture nodes | opencv-video-capture, realsense, orbbeck, webcam |
| **hub-audio** | Audio processing nodes | microphone, vad, whisper, pyaudio, kokoro-tts |
| **hub-detection** | Object detection/tracking | yolo, sam2, cotracker, bounding box, mask |
| **hub-llm** | Language models | qwen, vlm, llm, internvl, text generation |
| **hub-robot** | Robot control nodes | piper, reachy, ugv, kit-car, rdt-1b |
| **hub-visualization** | Visualization nodes | rerun, opencv-plot, primitives, display |
| **hub-recording** | Data recording nodes | llama-factory-recorder, lerobot-dashboard |
| **hub-translation** | Translation nodes | opus, argotranslate, multilingual |

## Skill Paths

```
skills/
├── dora-router/SKILL.md           # Main router
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
├── hub-camera/SKILL.md            # Camera nodes
├── hub-audio/SKILL.md             # Audio nodes
├── hub-detection/SKILL.md         # Detection nodes
├── hub-llm/SKILL.md               # Language model nodes
├── hub-robot/SKILL.md             # Robot control nodes
├── hub-visualization/SKILL.md     # Visualization nodes
├── hub-recording/SKILL.md         # Recording nodes
└── hub-translation/SKILL.md       # Translation nodes
```

## Routing Quick Reference

### By Question Type

| Question | Route To |
|----------|----------|
| "How to configure dataflow YAML?" | dataflow-config |
| "How to send output in Rust?" | node-api-rust |
| "How to create Python node?" | node-api-python |
| "How to use dora CLI?" | cli-commands |
| "How to test my node?" | integration-testing |

### By Domain

| Domain | Route To |
|--------|----------|
| Vision, ML, YOLO, camera | domain-vision |
| Speech, audio, TTS, STT | domain-audio |
| Robot, arm, servo, motor | domain-robot |
| Recording, replay, lerobot | data-pipeline |

### By Node Package

| Package Keywords | Route To |
|------------------|----------|
| opencv-video-capture, realsense, orbbeck | hub-camera |
| dora-microphone, dora-vad, dora-whisper, dora-pyaudio, dora-kokoro-tts | hub-audio |
| dora-yolo, dora-sam2, dora-cotracker | hub-detection |
| dora-qwen, dora-qwen2-5-vl, dora-internvl | hub-llm |
| dora-piper, dora-reachy2, dora-ugv, dora-kit-car, dora-rdt-1b | hub-robot |
| dora-rerun, opencv-plot | hub-visualization |
| llama-factory-recorder, lerobot-dashboard | hub-recording |
| dora-opus, dora-argotranslate | hub-translation |

## Trigger Keywords

### Chinese Keywords

| 关键词 | 技能 |
|-------|------|
| 数据流, 节点, 配置 | dataflow-config |
| Rust 节点, 发送输出 | node-api-rust |
| Python 节点 | node-api-python |
| 命令行, 运行 | cli-commands |
| 视觉, 目标检测, 摄像头 | domain-vision, hub-detection |
| 语音, 音频, 麦克风 | domain-audio, hub-audio |
| 机器人, 机械臂 | domain-robot, hub-robot |
| 数据记录, 回放 | data-pipeline, hub-recording |
| 可视化, 显示 | hub-visualization |
| 翻译, 多语言 | hub-translation |
| 大语言模型, VLM | hub-llm |

## Version

- **dora-skills version:** 1.1.0
- **dora-rs version:** 0.4.0
- **Last updated:** 2026-01-20
