---
name: hub-nodes
description: "Use for pre-built dora hub node questions.
Triggers on: dora-yolo, dora-rerun, dora-distil-whisper, dora-kokoro-tts, opencv-video-capture,
dora-lerobot, dora-sam2, dora-qwen, hub, pre-built, package,
预构建节点, 节点包, dora hub"
globs: ["**/dataflow.yml"]
source: "https://github.com/dora-rs/dora-hub"
---

# Dora Hub Nodes

> Pre-built nodes for common robotic and AI tasks

## Vision Nodes

### Camera Input

| Package | Command | Description |
|---------|---------|-------------|
| opencv-video-capture | `pip install opencv-video-capture` | Webcam/video capture |
| dora-pyrealsense | `pip install dora-pyrealsense` | Intel RealSense |
| dora-pyorbbecksdk | `pip install dora-pyorbbecksdk` | Orbbeck cameras |

**opencv-video-capture**
```yaml
- id: camera
  build: pip install opencv-video-capture
  path: opencv-video-capture
  inputs:
    tick: dora/timer/millis/33
  outputs:
    - image
  env:
    CAPTURE_PATH: "0"        # 0 for webcam, or path to video
    IMAGE_WIDTH: "640"
    IMAGE_HEIGHT: "480"
```

### Object Detection

| Package | Command | Description |
|---------|---------|-------------|
| dora-yolo | `pip install dora-yolo` | YOLO v8 detection |
| dora-mediapipe | `pip install dora-mediapipe` | MediaPipe detection |

**dora-yolo**
```yaml
- id: yolo
  build: pip install dora-yolo
  path: dora-yolo
  inputs:
    image: camera/image
  outputs:
    - bbox
  env:
    MODEL: yolov8n.pt        # yolov8n/s/m/l/x.pt
    DEVICE: cuda             # cuda or cpu
```

### Segmentation

| Package | Command | Description |
|---------|---------|-------------|
| dora-sam2 | `pip install dora-sam2` | Segment Anything 2 |

**dora-sam2**
```yaml
- id: sam
  build: pip install dora-sam2
  path: dora-sam2
  inputs:
    image: camera/image
    bbox: yolo/bbox          # Optional: guided segmentation
  outputs:
    - mask
```

### Depth & 3D

| Package | Command | Description |
|---------|---------|-------------|
| dora-vggt | `pip install dora-vggt` | Depth estimation |
| dora-cotracker | `pip install dora-cotracker` | Point tracking |

**dora-vggt**
```yaml
- id: depth
  build: pip install dora-vggt
  path: dora-vggt
  inputs:
    image: camera/image
  outputs:
    - depth
    - points3d
```

### Visualization

| Package | Command | Description |
|---------|---------|-------------|
| dora-rerun | `pip install dora-rerun` | Rerun visualization |

**dora-rerun**
```yaml
- id: plot
  build: pip install dora-rerun
  path: dora-rerun
  inputs:
    image: camera/image
    boxes2d: yolo/bbox
    # Optional inputs:
    # depth: depth/depth
    # points3d: depth/points3d
    # mask: sam/mask
```

## Audio Nodes

### Speech-to-Text

| Package | Command | Description |
|---------|---------|-------------|
| dora-distil-whisper | `pip install dora-distil-whisper` | Distil-Whisper STT |
| dora-funasr | `pip install dora-funasr` | FunASR (Chinese STT) |

**dora-distil-whisper**
```yaml
- id: stt
  build: pip install dora-distil-whisper
  path: dora-distil-whisper
  inputs:
    audio: microphone/audio
  outputs:
    - text
  env:
    MODEL: base              # tiny, base, small, medium, large
    LANGUAGE: en
```

### Text-to-Speech

| Package | Command | Description |
|---------|---------|-------------|
| dora-kokoro-tts | `pip install dora-kokoro-tts` | Kokoro TTS |
| dora-outtetts | `pip install dora-outtetts` | OuteTTS |
| dora-parler | `pip install dora-parler` | Parler TTS |

**dora-kokoro-tts**
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

### Voice Activity

| Package | Command | Description |
|---------|---------|-------------|
| dora-vad | `pip install dora-vad` | Voice activity detection |

**dora-vad**
```yaml
- id: vad
  build: pip install dora-vad
  path: dora-vad
  inputs:
    audio: microphone/audio
  outputs:
    - speech_audio
    - is_speaking
```

### Audio I/O

| Package | Command | Description |
|---------|---------|-------------|
| dora-microphone | `pip install dora-microphone` | Microphone input |
| dora-pyaudio | `pip install dora-pyaudio` | Audio playback |

## Language Models

### LLMs

| Package | Command | Description |
|---------|---------|-------------|
| dora-qwen | `pip install dora-qwen` | Qwen text models |
| dora-llama-cpp-python | `pip install dora-llama-cpp-python` | Llama.cpp models |
| dora-mistral-rs | `pip install dora-mistral-rs` | Mistral models |

**dora-qwen**
```yaml
- id: llm
  build: pip install dora-qwen
  path: dora-qwen
  inputs:
    text: stt/text
  outputs:
    - response
  env:
    MODEL: Qwen/Qwen2.5-7B
```

### Vision-Language Models

| Package | Command | Description |
|---------|---------|-------------|
| dora-qwen2-5-vl | `pip install dora-qwen2-5-vl` | Qwen2.5-VL |
| dora-internvl | `pip install dora-internvl` | InternVL |

**dora-qwen2-5-vl**
```yaml
- id: vlm
  build: pip install dora-qwen2-5-vl
  path: dora-qwen2-5-vl
  inputs:
    image: camera/image
    prompt: user/question
  outputs:
    - response
  env:
    MODEL: Qwen/Qwen2.5-VL-7B
```

## Robot Control

### Servo/Motor Control

| Package | Command | Description |
|---------|---------|-------------|
| dora-rustypot | `pip install dora-rustypot` | Dynamixel servos |

**dora-rustypot**
```yaml
- id: arm
  build: pip install dora-rustypot
  path: dora-rustypot
  inputs:
    command: planner/joints
  outputs:
    - state
  env:
    SERIAL_PORT: /dev/ttyUSB0
    BAUD_RATE: "1000000"
```

### Kinematics

| Package | Command | Description |
|---------|---------|-------------|
| dora-pytorch-kinematics | `pip install dora-pytorch-kinematics` | FK/IK |

**dora-pytorch-kinematics**
```yaml
- id: kinematics
  build: pip install dora-pytorch-kinematics
  path: dora-pytorch-kinematics
  inputs:
    target_pose: planner/target
  outputs:
    - joint_targets
  env:
    URDF_PATH: robot.urdf
```

### ROS2 Bridge

| Package | Install | Description |
|---------|---------|-------------|
| dora-ros2-bridge | Rust crate (build from [dora](https://github.com/dora-rs/dora) repo) | ROS2 integration |

> **Note:** dora-ros2-bridge is a Rust library in the main dora repository, not a pip package.
> See the [ROS2 bridge examples](https://github.com/dora-rs/dora/tree/main/examples/ros2-bridge).

## Data Pipeline

### LeRobot

| Package | Install | Description |
|---------|---------|-------------|
| dora-lerobot | From [dora-lerobot](https://github.com/dora-rs/dora-lerobot) repo | LeRobot dataset tools |

> **Note:** dora-lerobot is from a separate repository:
> ```bash
> git clone https://github.com/dora-rs/dora-lerobot
> cd dora-lerobot && pip install -e dora_lerobot
> ```

**Recording**
```yaml
# Install from dora-lerobot repo first
- id: recorder
  path: dora-lerobot-recorder
  inputs:
    image: camera/image
    state: arm/state
    action: teleop/command
  env:
    DATASET_NAME: my_dataset
```

**Replay**
```yaml
# Install from dora-lerobot repo first
- id: replay
  path: dora-lerobot-replay
  inputs:
    tick: dora/timer/millis/33
  outputs:
    - image
    - state
    - action
  env:
    DATASET_NAME: my_dataset
```

## Complete Example: Vision + LLM + Audio

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

  # VLM for image understanding
  - id: vlm
    build: pip install dora-qwen2-5-vl
    path: dora-qwen2-5-vl
    inputs:
      image: camera/image
      prompt: stt/text
    outputs:
      - response

  # Microphone
  - id: microphone
    build: pip install dora-microphone
    path: dora-microphone
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - audio

  # Speech to text
  - id: stt
    build: pip install dora-distil-whisper
    path: dora-distil-whisper
    inputs:
      audio: microphone/audio
    outputs:
      - text

  # Text to speech
  - id: tts
    build: pip install dora-kokoro-tts
    path: dora-kokoro-tts
    inputs:
      text: vlm/response
    outputs:
      - audio

  # Speaker
  - id: speaker
    build: pip install dora-pyaudio
    path: dora-pyaudio
    inputs:
      audio: tts/audio

  # Visualization
  - id: plot
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
```

## Related Skills

- **domain-vision** - Vision pipelines
- **domain-audio** - Audio pipelines
- **domain-robot** - Robot control
- **data-pipeline** - Data recording
