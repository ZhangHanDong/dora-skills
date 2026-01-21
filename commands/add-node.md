---
name: add-node
description: Add a node to an existing dataflow configuration
---

# /add-node Command

Add a new node to an existing dataflow.yml file.

## Usage

```
/add-node <node-type> [--input <source>] [--output <name>]
```

## Node Types

| Type | Package | Description |
|------|---------|-------------|
| camera | opencv-video-capture | Camera input |
| yolo | dora-yolo | Object detection |
| sam | dora-sam2 | Segmentation |
| whisper | dora-distil-whisper | Speech-to-text |
| tts | dora-kokoro-tts | Text-to-speech |
| llm | dora-qwen | Language model |
| vlm | dora-qwen2-5-vl | Vision-language |
| rerun | dora-rerun | Visualization |
| recorder | From dora-lerobot repo | Data recording |

## Example

```
/add-node yolo --input camera/image
```

Adds:
```yaml
- id: yolo
  build: pip install dora-yolo
  path: dora-yolo
  inputs:
    image: camera/image
  outputs:
    - bbox
  env:
    MODEL: yolov8n.pt
```

## Workflow

1. Read existing dataflow.yml
2. Parse and validate
3. Add new node with proper configuration
4. Update connections if needed
5. Write back to file
