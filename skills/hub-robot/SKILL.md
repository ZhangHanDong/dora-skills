---
name: hub-robot
description: "Use for robot control nodes in dora.
Triggers on: dora-piper, dora-reachy2, dora-ugv, dora-kit-car, dora-rdt-1b,
Piper, Reachy, UGV, robot arm, chassis, VLA, robot control, Agilex,
joint control, kinematics, teleoperation,
机械臂, 底盘, 机器人控制, 遥操作"
globs: ["**/dataflow.yml", "**/dataflow.yaml"]
source: "https://github.com/dora-rs/dora-hub"
---

# Robot Control Nodes

> Robot arms, chassis, and vision-language-action models

## Available Robot Nodes

| Node | Install | Description | Type |
|------|---------|-------------|------|
| dora-piper | `pip install dora-piper` | Agilex Piper arm | Arm |
| dora-reachy2 | `pip install dora-reachy2` | Pollen Reachy 2 humanoid | Humanoid |
| dora-ugv | `pip install dora-ugv` | Agilex UGV chassis | Chassis |
| dora-kit-car | `pip install dora-kit-car` | Open-source chassis | Chassis |
| dora-rdt-1b | `pip install dora-rdt-1b` | Robotic Diffusion Transformer | VLA |

## Robot Arm Nodes

### dora-piper

Agilex Piper robot arm control.

#### Prerequisites

Install Agilex Piper SDK:
```bash
git clone https://github.com/agilexrobotics/piper_sdk
cd piper_sdk
# Follow setup and installation instructions
```

Ensure CAN bus is activated and leader arms are not connected.

#### YAML Configuration

```yaml
- id: piper
  build: pip install dora-piper
  path: dora-piper
  inputs:
    joint_positions: policy/positions  # Float32Array joint targets
  outputs:
    - joint_state  # Current joint positions
```

### dora-reachy2

Pollen Robotics Reachy 2 humanoid robot.

#### YAML Configuration

```yaml
- id: reachy
  build: pip install dora-reachy2
  path: dora-reachy2
  inputs:
    command: control/command
  outputs:
    - image_left   # Left camera image
    - image_right  # Right camera image
    - joint_state  # Joint positions
```

## Chassis Nodes

### dora-ugv

Agilex UGV (Unmanned Ground Vehicle) control.

#### YAML Configuration

```yaml
- id: ugv
  build: pip install dora-ugv
  path: dora-ugv
  inputs:
    velocity: control/velocity  # [linear_x, angular_z]
  outputs:
    - odometry  # Position and velocity feedback
```

### dora-kit-car

Open-source educational chassis.

#### YAML Configuration

```yaml
- id: car
  build: pip install dora-kit-car
  path: dora-kit-car
  inputs:
    command: control/command
```

## Vision-Language-Action (VLA)

### dora-rdt-1b

Robotic Diffusion Transformer for policy inference from images and language.

#### YAML Configuration

```yaml
- id: policy
  build: pip install dora-rdt-1b
  path: dora-rdt-1b
  inputs:
    image: camera/image
    instruction: input/text  # Natural language instruction
  outputs:
    - action  # Joint positions/velocities
```

#### VLA Pipeline with Robot Arm

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

  # Microphone for voice commands
  - id: microphone
    build: pip install dora-microphone
    path: dora-microphone
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - audio

  # Speech to text
  - id: whisper
    build: pip install dora-distil-whisper
    path: dora-distil-whisper
    inputs:
      input: microphone/audio
    outputs:
      - text

  # VLA policy
  - id: policy
    build: pip install dora-rdt-1b
    path: dora-rdt-1b
    inputs:
      image: camera/image
      instruction: whisper/text
    outputs:
      - action

  # Robot arm
  - id: arm
    build: pip install dora-piper
    path: dora-piper
    inputs:
      joint_positions: policy/action
    outputs:
      - joint_state

  # Visualization
  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
      joint_state:
        source: arm/joint_state
        metadata:
          primitive: "jointstate"
```

## Teleoperation Pipeline

```yaml
nodes:
  # Leader arm (human operated)
  - id: leader
    build: pip install dora-piper
    path: dora-piper
    inputs:
      tick: dora/timer/millis/20
    outputs:
      - joint_state
    env:
      MODE: leader
      CAN_INTERFACE: can0

  # Follower arm (robot)
  - id: follower
    build: pip install dora-piper
    path: dora-piper
    inputs:
      joint_positions: leader/joint_state
    outputs:
      - joint_state
    env:
      MODE: follower
      CAN_INTERFACE: can1

  # Camera for recording
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image

  # Recording for imitation learning
  - id: recorder
    build: pip install llama-factory-recorder
    path: llama-factory-recorder
    inputs:
      image_right: camera/image
      ground_truth: leader/joint_state
    outputs:
      - text
```

## Joint State Data Format

### Float32Array for Joint Positions

```python
import pyarrow as pa
import numpy as np

# 7-DOF arm joint positions (radians)
joint_positions = np.array([0.0, -0.5, 0.0, 1.0, 0.0, 0.5, 0.0], dtype=np.float32)

# Send joint command
node.send_output("joint_positions", pa.array(joint_positions), {
    "num_joints": 7,
    "primitive": "jointstate"
})
```

### Receiving Joint State

```python
if event["type"] == "INPUT":
    joint_state = event["value"].to_numpy()
    print(f"Joint positions: {joint_state}")
```

## Pose Data Format (for end-effector)

```python
# 7 values: [x, y, z, qx, qy, qz, qw]
pose = np.array([0.5, 0.0, 0.3, 0.0, 0.0, 0.0, 1.0], dtype=np.float32)
node.send_output("pose", pa.array(pose), {"primitive": "pose"})
```

## Mobile Robot Pipeline

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

  # Object detection
  - id: yolo
    build: pip install dora-yolo
    path: dora-yolo
    inputs:
      image: camera/image
    outputs:
      - bbox

  # Navigation control (custom node)
  - id: navigator
    path: navigator.py
    inputs:
      detections: yolo/bbox
    outputs:
      - velocity

  # Chassis
  - id: ugv
    build: pip install dora-ugv
    path: dora-ugv
    inputs:
      velocity: navigator/velocity
    outputs:
      - odometry

  # Visualization
  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
      detections: yolo/bbox
```

## URDF Visualization with Rerun

```yaml
- id: rerun
  build: pip install dora-rerun
  path: dora-rerun
  inputs:
    jointstate_piper: arm/joint_state
  env:
    piper_urdf: /path/to/piper.urdf
    piper_transform: "0 0.3 0"  # x y z offset
```

**Note:** URDF file paths in the URDF are relative to the dataflow working directory.

## Related Skills

- **hub-camera** - Camera input for robot vision
- **hub-detection** - Object detection for manipulation
- **hub-recording** - Data recording for imitation learning
- **data-pipeline** - LeRobot recording and replay
