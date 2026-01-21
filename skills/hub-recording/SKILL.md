---
name: hub-recording
description: "Use for data recording nodes in dora.
Triggers on: llama-factory-recorder, lerobot-dashboard, lerobot, recording, data collection,
imitation learning, demonstration, training data, dataset,
数据记录, 模仿学习, 演示数据, 训练数据"
globs: ["**/dataflow.yml", "**/dataflow.yaml"]
source: "https://github.com/dora-rs/dora-hub"
---

# Data Recording Nodes

> Record demonstrations for imitation learning and model fine-tuning

## Available Recording Nodes

| Node | Install | Description |
|------|---------|-------------|
| llama-factory-recorder | `pip install llama-factory-recorder` | Record for LLM/VLM fine-tuning |
| lerobot-dashboard | `pip install lerobot-dashboard` | LeRobot recording interface |
| dora-lerobot-recorder | From [dora-lerobot](https://github.com/dora-rs/dora-lerobot) repo | LeRobot data recording |
| dora-rdt-1b | `pip install dora-rdt-1b` | VLA policy inference |

## dora-lerobot Installation

dora-lerobot is from a separate repository, not PyPI:

```bash
git clone https://github.com/dora-rs/dora-lerobot
cd dora-lerobot
pip install -e dora_lerobot
```

## llama-factory-recorder

Record data for fine-tuning language and vision-language models with LLaMA Factory.

### Prerequisites

```bash
git clone https://github.com/hiyouga/LLaMA-Factory --depth 1 $HOME/LLaMA-Factory
```

### YAML Configuration

```yaml
- id: recorder
  build: pip install llama-factory-recorder
  path: llama-factory-recorder
  inputs:
    image_right: camera/image
    ground_truth: human/text  # Human-provided labels/responses
  outputs:
    - text
  env:
    DEFAULT_QUESTION: "Respond to people."
    LLAMA_FACTORY_ROOT_PATH: $HOME/LLaMA-Factory
```

### Recording Pipeline

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

  # Keyboard input for labels
  - id: keyboard
    build: pip install terminal-input
    path: terminal-input
    outputs:
      - text

  # Recorder
  - id: recorder
    build: pip install llama-factory-recorder
    path: llama-factory-recorder
    inputs:
      image_right: camera/image
      ground_truth: keyboard/text
    outputs:
      - text
    env:
      DEFAULT_QUESTION: "What action should the robot take?"
      LLAMA_FACTORY_ROOT_PATH: $HOME/LLaMA-Factory

  # Visualization
  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
```

### Training with Recorded Data

1. Run your dataflow to collect data
2. Data is saved to LLaMA Factory folder
3. Modify training config:

```yaml
# llama-factory/examples/train_lora/qwen2vl_lora_sft.yaml
dataset: dora_demo_1,identity  # Your recorded dataset
model_name_or_path: Qwen/Qwen2.5-VL-3B-Instruct  # or 7B
```

4. Train:
```bash
llamafactory-cli train examples/train_lora/qwen2vl_lora_sft.yaml
```

## lerobot-dashboard

Pygame-based interface for LeRobot data collection with dual camera display.

### YAML Configuration

```yaml
- id: dashboard
  build: pip install lerobot-dashboard
  path: lerobot-dashboard
  inputs:
    tick: dora/timer/millis/16  # 60fps update
    image_left: camera_left/image
    image_right: camera_right/image
  outputs:
    - text      # User text input
    - episode   # Episode number (-1 marks end)
    - failed    # Failed episode number
    - end       # End signal for dataflow
  env:
    WINDOW_WIDTH: 1280
    WINDOW_HEIGHT: 1080
```

### Outputs

| Output | Description |
|--------|-------------|
| text | StringArray - user text input |
| episode | Int - current episode number (-1 = episode end) |
| failed | Int - marks episode as failed |
| end | Empty array - signals recording end |

### LeRobot Recording Pipeline

```yaml
nodes:
  # Left camera
  - id: camera_left
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image
    env:
      PATH: "0"

  # Right camera
  - id: camera_right
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image
    env:
      PATH: "1"

  # Leader arm (teleoperation)
  - id: leader
    build: pip install dora-piper
    path: dora-piper
    inputs:
      tick: dora/timer/millis/20
    outputs:
      - joint_state
    env:
      MODE: leader

  # Follower arm
  - id: follower
    build: pip install dora-piper
    path: dora-piper
    inputs:
      joint_positions: leader/joint_state
    outputs:
      - joint_state
    env:
      MODE: follower

  # Dashboard
  - id: dashboard
    build: pip install lerobot-dashboard
    path: lerobot-dashboard
    inputs:
      tick: dora/timer/millis/16
      image_left: camera_left/image
      image_right: camera_right/image
    outputs:
      - text
      - episode
      - failed
      - end
    env:
      WINDOW_WIDTH: 1280
      WINDOW_HEIGHT: 720

  # LeRobot recorder (install from dora-lerobot repo first)
  - id: lerobot
    path: dora-lerobot-recorder
    inputs:
      image_left: camera_left/image
      image_right: camera_right/image
      state: follower/joint_state
      action: leader/joint_state
      episode: dashboard/episode
      end: dashboard/end
    env:
      DATASET_NAME: my_robot_dataset
```

## Complete Imitation Learning Pipeline

### 1. Data Collection

```yaml
# dataflow_record.yml
nodes:
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image

  - id: leader
    build: pip install dora-piper
    path: dora-piper
    inputs:
      tick: dora/timer/millis/20
    outputs:
      - joint_state
    env:
      MODE: leader

  - id: follower
    build: pip install dora-piper
    path: dora-piper
    inputs:
      joint_positions: leader/joint_state
    outputs:
      - joint_state
    env:
      MODE: follower

  - id: dashboard
    build: pip install lerobot-dashboard
    path: lerobot-dashboard
    inputs:
      tick: dora/timer/millis/16
      image_left: camera/image
    outputs:
      - episode
      - end

  # LeRobot recorder (install from dora-lerobot repo first)
  - id: recorder
    path: dora-lerobot-recorder
    inputs:
      image: camera/image
      state: follower/joint_state
      action: leader/joint_state
      episode: dashboard/episode
    env:
      DATASET_NAME: pick_and_place
```

### 2. Policy Training (offline)

```bash
# Train with LeRobot
python lerobot/train.py \
    --dataset pick_and_place \
    --policy diffusion
```

### 3. Policy Deployment

```yaml
# dataflow_deploy.yml
nodes:
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image

  - id: policy
    build: pip install dora-rdt-1b
    path: dora-rdt-1b
    inputs:
      image: camera/image
    outputs:
      - action

  - id: robot
    build: pip install dora-piper
    path: dora-piper
    inputs:
      joint_positions: policy/action
    outputs:
      - joint_state
```

## Data Formats

### Episode Markers

```python
# Start new episode
node.send_output("episode", pa.array([episode_number]))

# End episode
node.send_output("episode", pa.array([-1]))

# Mark episode as failed
node.send_output("failed", pa.array([episode_number]))
```

### Recording State/Action Pairs

```python
# State: current robot joint positions
state = pa.array(current_joints)

# Action: commanded joint positions (from leader/policy)
action = pa.array(target_joints)
```

## Related Skills

- **hub-robot** - Robot control for teleoperation
- **hub-camera** - Camera input for recording
- **data-pipeline** - LeRobot data tools
