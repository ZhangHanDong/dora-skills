---
name: domain-robot
description: "Use for robot control pipeline questions with dora.
Triggers on: robot, arm, chassis, actuator, servo, motor, gripper, kinematics,
FK, IK, URDF, joint, position control, velocity control, serial port,
机器人, 机械臂, 底盘, 执行器, 舵机, 电机, 运动学"
globs: ["**/dataflow.yml", "**/*.py"]
source: "https://github.com/dora-rs/dora-hub"
---

# Domain: Robot Control

> Building robot control applications with dora-rs

## Overview

Dora supports robot control through:
- Serial communication with actuators
- Kinematics (FK/IK) computation
- ROS2 bridge for existing robot stacks
- Real-time control loops

## Common Robot Nodes

### Serial Port Communication

```yaml
- id: serial
  build: pip install dora-rustypot
  path: dora-rustypot
  inputs:
    command: controller/command
  outputs:
    - feedback
  env:
    SERIAL_PORT: /dev/ttyUSB0
    BAUD_RATE: "115200"
```

### Kinematics (FK/IK)

```yaml
- id: kinematics
  build: pip install dora-pytorch-kinematics
  path: dora-pytorch-kinematics
  inputs:
    joint_positions: arm/positions
    target_pose: planner/target
  outputs:
    - end_effector_pose   # FK output
    - joint_targets       # IK output
  env:
    URDF_PATH: robot.urdf
```

### ROS2 Bridge

> **Note:** dora-ros2-bridge is a Rust library in the main [dora](https://github.com/dora-rs/dora) repository.
> It requires building from source. See [ROS2 bridge examples](https://github.com/dora-rs/dora/tree/main/examples/ros2-bridge).

```yaml
# ROS2 bridge example (requires Rust build from dora repo)
- id: ros2-bridge
  path: dora-ros2-bridge
  inputs:
    cmd_vel: controller/velocity
  outputs:
    - odom
    - joint_states
  env:
    ROS_TOPICS_IN: /odom,/joint_states
    ROS_TOPICS_OUT: /cmd_vel
```

## Complete Robot Arm Pipeline

```yaml
nodes:
  # Camera for visual feedback
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image
    env:
      CAPTURE_PATH: "0"

  # Object detection
  - id: detector
    build: pip install dora-yolo
    path: dora-yolo
    inputs:
      image: camera/image
    outputs:
      - bbox

  # Motion planner
  - id: planner
    path: ./planner.py
    inputs:
      bbox: detector/bbox
      arm_state: arm/state
    outputs:
      - target_pose

  # Kinematics
  - id: kinematics
    build: pip install dora-pytorch-kinematics
    path: dora-pytorch-kinematics
    inputs:
      target_pose: planner/target_pose
    outputs:
      - joint_targets
    env:
      URDF_PATH: robot.urdf

  # Arm controller
  - id: arm
    build: pip install dora-rustypot
    path: dora-rustypot
    inputs:
      command: kinematics/joint_targets
    outputs:
      - state
    env:
      SERIAL_PORT: /dev/ttyUSB0
      BAUD_RATE: "1000000"

  # Visualization
  - id: plot
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
      boxes2d: detector/bbox
```

## Mobile Robot Pipeline

```yaml
nodes:
  # Lidar sensor
  - id: lidar
    path: lidar_driver.py
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - scan

  # Localization
  - id: localization
    path: localization.py
    inputs:
      scan: lidar/scan
      odom: chassis/odom
    outputs:
      - pose

  # Path planner
  - id: planner
    path: path_planner.py
    inputs:
      pose: localization/pose
      goal: user/goal
    outputs:
      - path

  # Motion controller
  - id: controller
    path: motion_controller.py
    inputs:
      path: planner/path
      pose: localization/pose
    outputs:
      - cmd_vel

  # Chassis
  - id: chassis
    path: chassis_driver.py
    inputs:
      cmd_vel: controller/cmd_vel
    outputs:
      - odom
    env:
      SERIAL_PORT: /dev/ttyUSB0
```

## Custom Robot Node Examples

### Arm Controller

```python
# arm_controller.py
import numpy as np
from dora import Node
import serial

node = Node()

# Serial connection to servo controller
ser = serial.Serial(
    port='/dev/ttyUSB0',
    baudrate=115200,
    timeout=0.1
)

def send_joint_command(joints):
    """Send joint positions to servo controller"""
    # Convert to servo protocol
    command = build_command(joints)
    ser.write(command)
    return ser.read(100)  # Read feedback

for event in node:
    if event["type"] == "INPUT" and event["id"] == "command":
        joints = event["value"]  # [j1, j2, j3, j4, j5, j6]

        # Send to hardware
        feedback = send_joint_command(joints)

        # Parse and send feedback
        state = parse_feedback(feedback)
        node.send_output("state", state)

    elif event["type"] == "STOP":
        # Safe shutdown - move to home position
        send_joint_command([0, 0, 0, 0, 0, 0])
        break

ser.close()
```

### Motion Planner

```python
# planner.py
import numpy as np
import pyarrow as pa
from dora import Node

node = Node()

current_state = None
target_bbox = None

for event in node:
    if event["type"] == "INPUT":
        if event["id"] == "arm_state":
            current_state = event["value"]

        elif event["id"] == "bbox":
            # Get detection results
            detections = event["value"].to_pylist()

            if detections:
                # Find target object
                target = find_target(detections)

                if target and current_state is not None:
                    # Compute target pose from bbox
                    target_pose = bbox_to_pose(target)

                    # Send to kinematics
                    node.send_output("target_pose", pa.array([target_pose]))

    elif event["type"] == "STOP":
        break
```

### Kinematics Helper

```python
# kinematics_helper.py
import numpy as np
from pytorch_kinematics import chain

def load_robot(urdf_path):
    """Load robot from URDF"""
    return chain.build_chain_from_urdf(urdf_path)

def forward_kinematics(robot, joint_positions):
    """Compute end-effector pose from joint positions"""
    ret = robot.forward_kinematics(joint_positions)
    return ret['end_effector'].get_matrix()

def inverse_kinematics(robot, target_pose, current_joints):
    """Compute joint positions for target pose"""
    from pytorch_kinematics.ik import jacobian_ik

    return jacobian_ik(
        robot,
        target_pose,
        current_joints,
        max_iterations=100
    )
```

## Control Loop Timing

For real-time control, use appropriate timer frequencies:

```yaml
# Position control (slow)
tick: dora/timer/millis/50    # 20 Hz

# Velocity control (medium)
tick: dora/timer/millis/20    # 50 Hz

# Torque control (fast)
tick: dora/timer/millis/5     # 200 Hz
```

## Safety Considerations

1. **Emergency stop** - Implement hardware E-stop
2. **Joint limits** - Check before sending commands
3. **Velocity limits** - Limit maximum speed
4. **Collision detection** - Monitor force/torque
5. **Watchdog timers** - Stop if control loop fails

## Available Hub Nodes

| Node | Install | Purpose |
|------|---------|---------|
| dora-rustypot | `pip install dora-rustypot` | Serial servo control |
| dora-pytorch-kinematics | `pip install dora-pytorch-kinematics` | FK/IK |
| dora-ros2-bridge | Build from [dora](https://github.com/dora-rs/dora) repo (Rust) | ROS2 integration |
| robot_descriptions_py | `pip install robot_descriptions` | URDF models |

## Related Skills

- **data-pipeline** - Recording robot data
- **domain-vision** - Visual feedback
- **hub-nodes** - All pre-built nodes
