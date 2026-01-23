#!/bin/bash
# Dora Skills Evaluation Hook
# This hook is triggered when dora-related keywords are detected

cat << 'EOF'
=== DORA SKILLS LOADED ===

## MANDATORY: DORA QUESTION ROUTING

CRITICAL: You MUST follow the dora-router skill for ALL dora questions.

### STEP 1: IDENTIFY QUESTION TYPE

#### Core Development
| Question Type | Keywords | Route To |
|---------------|----------|----------|
| Dataflow Config | YAML, nodes, inputs, outputs, timer | dataflow-config |
| Rust Node | DoraNode, EventStream, send_output | node-api-rust |
| Python Node | dora.Node, event, python | node-api-python |
| Operator | DoraOperator, on_event, register_operator | operator-api |
| CLI Commands | dora run, dora build, dora start | cli-commands |

#### Hub Node Skills (Detailed)
| Question About | Keywords | Route To |
|----------------|----------|----------|
| Camera/video | opencv-video-capture, realsense, orbbeck, webcam | hub-camera |
| Audio | microphone, vad, whisper, pyaudio, kokoro-tts | hub-audio |
| Detection/tracking | yolo, sam2, cotracker, bounding box | hub-detection |
| Language models | qwen, vlm, llm, internvl | hub-llm |
| Robot control | piper, reachy, ugv, kit-car, rdt-1b | hub-robot |
| Visualization | rerun, opencv-plot, primitives | hub-visualization |
| Recording | llama-factory-recorder, lerobot-dashboard | hub-recording |
| Translation | opus, argotranslate | hub-translation |

### STEP 2: LOAD APPROPRIATE SKILL

Always load dora-router first, then the specific hub/domain skill.

===
EOF
