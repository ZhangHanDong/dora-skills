---
name: data-pipeline
description: "Use for data recording and replay questions with dora.
Triggers on: recording, replay, lerobot, data collection, dataset, rosbag,
record data, play back, training data, HDF5, parquet,
数据记录, 数据回放, 数据收集, 训练数据"
globs: ["**/dataflow.yml", "**/*.py"]
source: "https://github.com/dora-rs/dora-lerobot"
---

# Domain: Data Pipeline

> Recording and replaying robot data with dora-rs

## Overview

Dora supports data pipelines for:
- Recording sensor data for training
- Replaying recorded sessions
- LeRobot integration for imitation learning
- Dataset management

## LeRobot Integration

> **Note:** dora-lerobot is from a separate repository, not PyPI. Install from source:
> ```bash
> git clone https://github.com/dora-rs/dora-lerobot
> cd dora-lerobot
> pip install -e dora_lerobot
> ```

### Recording Data

```yaml
nodes:
  # Camera
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image

  # Robot arm
  - id: arm
    build: pip install dora-rustypot
    path: dora-rustypot
    inputs:
      command: teleop/command
    outputs:
      - state
      - feedback

  # LeRobot recorder (install from dora-lerobot repo first)
  - id: recorder
    path: dora-lerobot-recorder
    inputs:
      image: camera/image
      state: arm/state
      action: teleop/command
    env:
      DATASET_NAME: my_robot_dataset
      EPISODE_INDEX: "0"
```

### Replaying Data

```yaml
nodes:
  # LeRobot replay (install from dora-lerobot repo first)
  - id: replay
    path: dora-lerobot-replay
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image
      - state
      - action
    env:
      DATASET_NAME: my_robot_dataset
      EPISODE_INDEX: "0"

  # Visualization
  - id: plot
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: replay/image
```

## Data Collection Workflow

```bash
# 1. Start recording session
dora run record_dataflow.yml

# 2. Perform teleoperation
# 3. Press Ctrl+C to stop and save

# 4. Repeat for multiple episodes
EPISODE_INDEX=1 dora run record_dataflow.yml
EPISODE_INDEX=2 dora run record_dataflow.yml

# 5. Train policy
python train_policy.py --dataset my_robot_dataset
```

## Available Hub Nodes

| Node | Install | Purpose |
|------|---------|---------|
| dora-lerobot-recorder | From [dora-lerobot](https://github.com/dora-rs/dora-lerobot) repo | Record data |
| dora-lerobot-replay | From [dora-lerobot](https://github.com/dora-rs/dora-lerobot) repo | Replay data |
| llama-factory-recorder | `pip install llama-factory-recorder` | Record for LLM/VLM training |
| lerobot-dashboard | `pip install lerobot-dashboard` | Pygame recording interface |
| dora-rdt-1b | `pip install dora-rdt-1b` | VLA policy inference |

## Training Pipeline

### 1. Collect Demonstrations

```bash
# Run teleoperation dataflow
dora run record_dataflow.yml

# Mark episodes
# Press 'n' for new episode, 'f' for failed
```

### 2. Convert to LeRobot Format

```python
# The recorder automatically saves in LeRobot format
# Dataset saved to: ~/.lerobot/datasets/<dataset_name>
```

### 3. Train Policy

```bash
# Using LeRobot CLI
python lerobot/train.py \
    --dataset my_robot_dataset \
    --policy diffusion \
    --output_dir outputs/my_policy
```

### 4. Deploy Policy

```yaml
nodes:
  - id: camera
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
    path: dora-piper
    inputs:
      joint_positions: policy/action
```

## Related Skills

- **hub-recording** - Detailed recording node documentation
- **hub-robot** - Robot control nodes
- **domain-robot** - Robot control patterns
- **domain-vision** - Visual data processing
- **hub-nodes** - All pre-built nodes
