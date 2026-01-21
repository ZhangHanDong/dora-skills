---
name: new-dataflow
description: Create a new dora dataflow project with common templates
---

# /new-dataflow Command

Create a new dora dataflow project with pre-configured templates.

## Usage

```
/new-dataflow <name> [--type <template>] [--lang <language>]
```

## Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `<name>` | Project name | required |
| `--type` | Template type | basic |
| `--lang` | Language | python |

## Templates

### basic
Simple camera + visualization:
```yaml
nodes:
  - id: camera
  - id: visualize
```

### vision
Object detection pipeline:
```yaml
nodes:
  - id: camera
  - id: detector
  - id: visualize
```

### audio
Speech-to-speech pipeline:
```yaml
nodes:
  - id: microphone
  - id: vad
  - id: whisper
  - id: llm
  - id: tts
  - id: speaker
```

### robot
Robot teleoperation:
```yaml
nodes:
  - id: leader
  - id: follower
  - id: camera
  - id: recorder
```

### vlm
Vision-language interaction:
```yaml
nodes:
  - id: camera
  - id: vlm
  - id: visualize
```

## Example

```
/new-dataflow my-robot --type vision
```

Creates:
```
my-robot/
├── dataflow.yml
└── README.md
```

## Next Steps

After creating:
```bash
cd my-robot
dora build dataflow.yml --uv
dora run dataflow.yml
```
