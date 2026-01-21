---
name: domain-vision
description: "Use for ML/Vision pipeline questions with dora.
Triggers on: YOLO, detection, object detection, segmentation, tracking, VLM, SAM,
camera, webcam, image processing, bbox, bounding box, rerun, visualization,
视觉, 目标检测, 分割, 跟踪, 摄像头, 图像处理"
globs: ["**/dataflow.yml", "**/*.py"]
source: "https://github.com/dora-rs/dora-hub"
---

# Domain: Vision & ML Pipelines

> Building ML/Vision applications with dora-rs

## Overview

Dora provides excellent support for vision and ML pipelines through:
- Pre-built nodes in dora-hub
- Efficient image transfer via shared memory
- Integration with popular ML frameworks

## Common Vision Nodes

### Camera Capture

```yaml
- id: camera
  build: pip install opencv-video-capture
  path: opencv-video-capture
  inputs:
    tick: dora/timer/millis/33  # ~30 FPS
  outputs:
    - image
  env:
    CAPTURE_PATH: "0"           # Webcam index or video path
    IMAGE_WIDTH: "640"
    IMAGE_HEIGHT: "480"
```

### YOLO Object Detection

```yaml
- id: yolo
  build: pip install dora-yolo
  path: dora-yolo
  inputs:
    image: camera/image
  outputs:
    - bbox
  env:
    MODEL: yolov8n.pt           # or yolov8s, yolov8m, yolov8l
    DEVICE: cuda                # or cpu
```

### Visualization (Rerun)

```yaml
- id: plot
  build: pip install dora-rerun
  path: dora-rerun
  inputs:
    image: camera/image
    boxes2d: yolo/bbox          # 2D bounding boxes
    # Optional:
    # points2d: detector/points
    # points3d: depth/points
```

## Complete Vision Pipeline

```yaml
nodes:
  # Camera input
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

  # Optional: Segmentation
  - id: segmenter
    build: pip install dora-sam2
    path: dora-sam2
    inputs:
      image: camera/image
      bbox: detector/bbox
    outputs:
      - mask

  # Visualization
  - id: plot
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
      boxes2d: detector/bbox
```

## Advanced Vision Features

### Depth Estimation

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

### Point Tracking (CoTracker)

```yaml
- id: tracker
  build: pip install dora-cotracker
  path: dora-cotracker
  inputs:
    image: camera/image
    points: source/points
  outputs:
    - tracked_points
```

### Vision Language Model (VLM)

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

### Pose Estimation

```yaml
- id: pose
  build: pip install dora-mediapipe
  path: dora-mediapipe
  inputs:
    image: camera/image
  outputs:
    - landmarks
    - pose
```

## Custom Vision Node Example

```python
# custom_detector.py
import numpy as np
import pyarrow as pa
from dora import Node
from ultralytics import YOLO

node = Node()
model = YOLO("yolov8n.pt")

for event in node:
    if event["type"] == "INPUT" and event["id"] == "image":
        image = event["value"]  # numpy array (H, W, C)

        # Run detection
        results = model(image, verbose=False)

        # Convert to structured output
        boxes = []
        for r in results:
            for box in r.boxes:
                boxes.append({
                    "xyxy": box.xyxy[0].tolist(),
                    "confidence": float(box.conf[0]),
                    "class_id": int(box.cls[0]),
                    "class_name": model.names[int(box.cls[0])],
                })

        # Send as Arrow array
        node.send_output("bbox", pa.array(boxes))

    elif event["type"] == "STOP":
        break
```

## Image Data Format

Dora uses Apache Arrow for efficient image transfer:

```python
# Image as numpy array
image = np.zeros((480, 640, 3), dtype=np.uint8)  # HWC format, RGB

# Receiving image
image = event["value"]  # numpy array from dora
height, width, channels = image.shape
```

## Bounding Box Format

Standard bbox format used by dora vision nodes:

```python
bbox = {
    "xyxy": [x1, y1, x2, y2],      # Top-left and bottom-right corners
    "confidence": 0.95,             # Detection confidence
    "class_id": 0,                  # Class index
    "class_name": "person",         # Class label (optional)
}
```

## Performance Tips

1. **Use appropriate timer frequency**
   - 30 FPS: `dora/timer/millis/33`
   - 15 FPS: `dora/timer/millis/66`

2. **Use queue_size: 1 for real-time**
   ```yaml
   inputs:
     image:
       source: camera/image
       queue_size: 1  # Drop old frames
   ```

3. **Use CUDA when available**
   ```yaml
   env:
     DEVICE: cuda
   ```

4. **Resize images for faster processing**
   ```yaml
   env:
     IMAGE_WIDTH: "640"
     IMAGE_HEIGHT: "480"
   ```

## Available Hub Nodes

| Node | Package | Purpose |
|------|---------|---------|
| opencv-video-capture | `pip install opencv-video-capture` | Camera/video input |
| dora-yolo | `pip install dora-yolo` | YOLO detection |
| dora-sam2 | `pip install dora-sam2` | SAM2 segmentation |
| dora-rerun | `pip install dora-rerun` | Visualization |
| dora-vggt | `pip install dora-vggt` | Depth estimation |
| dora-cotracker | `pip install dora-cotracker` | Point tracking |
| dora-mediapipe | `pip install dora-mediapipe` | Pose estimation |
| dora-qwen2-5-vl | `pip install dora-qwen2-5-vl` | Vision language |

## Related Skills

- **hub-nodes** - All pre-built nodes
- **dataflow-config** - YAML configuration
- **node-api-python** - Custom Python nodes
