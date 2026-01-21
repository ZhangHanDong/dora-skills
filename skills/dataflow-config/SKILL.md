---
name: dataflow-config
description: "Use for dora-rs dataflow YAML configuration questions.
Triggers on: dataflow.yml, dataflow.yaml, nodes:, inputs:, outputs:, timer,
dora/timer, queue_size, env:, build:, path:, git:, branch:, tag:,
restart_policy, send_stdout_as, operator:, operators:,
YAML配置, 数据流配置, 节点配置, 输入输出, 定时器"
globs: ["**/dataflow.yml", "**/dataflow.yaml"]
source: "https://dora-rs.ai/docs/api/dataflow-config/"
---

# Dataflow Configuration

> Complete guide to dora-rs dataflow YAML specification

## Basic Structure

```yaml
nodes:
  - id: node_id          # Required: unique identifier (no "/" characters)
    name: "Human Name"   # Optional: descriptive name
    description: "..."   # Optional: node description
    path: executable     # Path to executable/script
    args: "-v --flag"    # Optional: command-line arguments
    env:                 # Optional: environment variables
      DEBUG: true
      PORT: 8080
    inputs:              # Input connections
      input_id: source_node/output_id
    outputs:             # Output identifiers
      - output_1
      - output_2
```

## Node Configuration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (no `/` characters) |
| `name` | No | Human-readable name |
| `description` | No | Node description |
| `path` | Yes* | Path to executable or package name |
| `args` | No | Command-line arguments |
| `env` | No | Environment variables |
| `inputs` | No | Input connections |
| `outputs` | No | Output identifiers |
| `build` | No | Build command |
| `git` | No | Git repository URL |
| `branch`/`tag`/`rev` | No | Git checkout target |
| `restart_policy` | No | `never`, `on-failure`, `always` |
| `send_stdout_as` | No | Forward stdout as output |
| `operator` | No* | Single operator definition |
| `operators` | No* | Multiple operators |

*One of `path`, `operator`, or `operators` is required.

## Input Connections

### From Another Node

```yaml
inputs:
  input_name: source_node/output_name
```

### Timer Inputs

```yaml
inputs:
  # Trigger every N milliseconds
  tick: dora/timer/millis/100    # 10 Hz
  tick: dora/timer/millis/33     # ~30 Hz
  tick: dora/timer/millis/1000   # 1 Hz

  # Trigger every N seconds
  tick: dora/timer/secs/5        # Every 5 seconds
```

### With Queue Size

```yaml
inputs:
  image:
    source: camera/image
    queue_size: 1  # Only keep latest (drop old frames)
```

## Environment Variables

```yaml
env:
  # Model configuration
  MODEL_PATH: /path/to/model.pt
  DEVICE: cuda

  # Camera settings
  CAPTURE_PATH: "0"
  IMAGE_WIDTH: "640"
  IMAGE_HEIGHT: "480"

  # Serial ports
  SERIAL_PORT: /dev/ttyUSB0
  BAUD_RATE: "115200"
```

## Node Source Options

### Python Package (pip)

```yaml
- id: yolo
  build: pip install dora-yolo
  path: dora-yolo
```

### Local Python File

```yaml
- id: custom
  path: ./my_node.py
```

### Rust Executable

```yaml
- id: rust-node
  build: cargo build --release
  path: ./target/release/my_node
```

### Git Repository

```yaml
- id: remote-node
  git: https://github.com/org/repo.git
  branch: main           # Or: tag: v1.0.0 / rev: abc123
  build: cargo build --release
  path: target/release/node
```

### Dynamic Nodes

```yaml
- id: dynamic-node
  path: dynamic          # Special keyword
  inputs:
    tick: dora/timer/millis/100
  outputs:
    - output
```

## Operators

### Single Operator

```yaml
- id: processor
  operator:
    python: script.py
    inputs:
      data: source/output
    outputs:
      - processed
```

### Multiple Operators (Runtime Node)

```yaml
- id: runtime-node
  operators:
    - id: op1
      python: op1.py
      inputs:
        data: source/output
      outputs:
        - result1
    - id: op2
      python: op2.py
      inputs:
        input: op1/result1
      outputs:
        - result2
```

### Operator with Conda

```yaml
- id: ml-node
  operator:
    python:
      source: inference.py
      conda_env: ml_env
    inputs:
      image: camera/image
    outputs:
      - prediction
```

## Restart Policy

```yaml
- id: resilient-node
  path: ./node
  restart_policy: on-failure  # never (default), on-failure, always
```

## Stdout Forwarding

```yaml
- id: producer
  path: ./node
  send_stdout_as: logs  # Forward stdout as output
  outputs:
    - logs
```

## Complete Example: Vision Pipeline

```yaml
nodes:
  # Camera capture
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image
    env:
      CAPTURE_PATH: "0"
      IMAGE_WIDTH: "640"
      IMAGE_HEIGHT: "480"

  # Object detection
  - id: detector
    build: pip install dora-yolo
    path: dora-yolo
    inputs:
      image: camera/image
    outputs:
      - bbox
    env:
      MODEL: yolov8n.pt

  # Visualization
  - id: plot
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
      boxes2d: detector/bbox
```

## Best Practices

1. **Use descriptive node IDs**: `camera`, `object-detector`, `arm-controller`
2. **Set appropriate timer frequencies**: Match your processing rate
3. **Configure queue sizes**: Use `queue_size: 1` for real-time applications
4. **Use environment variables**: Keep configuration separate from code
5. **Use `--uv` flag**: For faster Python package installation

## Related Skills

- **node-api-rust** - Rust node development
- **node-api-python** - Python node development
- **cli-commands** - Running dataflows
- **hub-nodes** - Pre-built nodes
