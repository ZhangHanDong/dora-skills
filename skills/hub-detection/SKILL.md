---
name: hub-detection
description: "Use for object detection and tracking nodes in dora.
Triggers on: dora-yolo, dora-sam2, dora-cotracker, YOLO, YOLOv8, SAM, SAM2, CoTracker,
object detection, segmentation, tracking, bounding box, mask, point tracking,
目标检测, 分割, 跟踪, 边界框"
globs: ["**/dataflow.yml", "**/dataflow.yaml"]
source: "https://github.com/dora-rs/dora-hub"
---

# Object Detection & Tracking Nodes

> YOLO detection, SAM2 segmentation, and CoTracker point tracking

## Available Detection Nodes

| Node | Install | Description | GPU Required |
|------|---------|-------------|--------------|
| dora-yolo | `pip install dora-yolo` | YOLOv8 object detection | Recommended |
| dora-sam2 | `pip install dora-sam2` | Segment Anything 2 | Required (CUDA) |
| dora-cotracker | `pip install dora-cotracker` | Point tracking | Recommended |

## dora-yolo

YOLOv8 object detection with bounding boxes, confidence scores, and labels.

### YAML Configuration

```yaml
- id: yolo
  build: pip install dora-yolo
  path: dora-yolo
  inputs:
    image: camera/image
  outputs:
    - bbox
  env:
    MODEL: yolov8n.pt  # yolov5n, yolov8n/s/m/l/x
```

### Input Format

```python
# image: UInt8Array
metadata = {
    "width": 640,
    "height": 480,
    "encoding": "bgr8"  # or "rgb8"
}
```

### Output Format (bbox)

```python
# StructArray with bounding boxes
bbox = {
    "bbox": np.array([x1,y1,x2,y2, ...]).flatten(),  # xyxy format
    "conf": np.array([0.95, 0.87, ...]),             # confidence scores
    "labels": np.array(["person", "car", ...])       # class names
}
metadata = {"format": "xyxy", "primitive": "boxes2d"}
```

### Decoding Bounding Boxes

```python
bbox_data = event["value"][0]
bbox = {
    "bbox": bbox_data["bbox"].values.to_numpy().reshape(-1, 4),
    "conf": bbox_data["conf"].values.to_numpy(),
    "labels": bbox_data["labels"].values.to_numpy(zero_copy_only=False)
}

# Draw boxes
for i, box in enumerate(bbox["bbox"]):
    x1, y1, x2, y2 = box.astype(int)
    label = bbox["labels"][i]
    conf = bbox["conf"][i]
    cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
    cv2.putText(frame, f"{label} {conf:.2f}", (x1, y1-10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
```

## dora-sam2

Segment Anything Model 2 for object segmentation.

### Requirements
- NVIDIA GPU with CUDA support

### YAML Configuration

```yaml
- id: sam2
  build: pip install dora-sam2
  path: dora-sam2
  inputs:
    image: camera/image
    bbox: yolo/bbox    # Optional: use YOLO boxes as prompts
  outputs:
    - masks  # UInt8Array segmentation masks
```

### Output Format

```python
# masks: UInt8Array
metadata = {
    "width": 640,
    "height": 480,
    "primitive": "masks"
}
```

### YOLO + SAM2 Pipeline

```yaml
nodes:
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image

  - id: yolo
    build: pip install dora-yolo
    path: dora-yolo
    inputs:
      image: camera/image
    outputs:
      - bbox

  - id: sam2
    build: pip install dora-sam2
    path: dora-sam2
    inputs:
      image: camera/image
      bbox: yolo/bbox
    outputs:
      - masks

  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
      detections: yolo/bbox
      segmentation: sam2/masks
```

## dora-cotracker

Real-time point tracking using Facebook's CoTracker model.

### YAML Configuration

```yaml
- id: tracker
  build: pip install dora-cotracker
  path: dora-cotracker
  inputs:
    image: camera/image
    points_to_track: detector/points  # Optional programmatic input
  outputs:
    - tracked_image   # Visualization with tracked points
    - tracked_points  # Current point positions
```

### Interactive Usage

- Left-click in "Raw Feed" window to add tracking points
- Points assigned unique IDs (C0, C1 for clicks, I0, I1 for inputs)

### Programmatic Point Input

```python
import numpy as np
import pyarrow as pa

# Send points to track
points = np.array([
    [320, 240],  # Center
    [160, 120],  # Top-left
    [480, 360]   # Bottom-right
], dtype=np.float32)

node.send_output("points_to_track", pa.array(points.ravel()), {
    "num_points": len(points),
    "dtype": "float32",
    "shape": (len(points), 2)
})
```

### Output Format

```python
# tracked_points: Float32Array
# Same format as input points
metadata = {
    "num_points": N,
    "dtype": "float32",
    "shape": (N, 2)
}
```

### YOLO Detection to CoTracker Pipeline

```yaml
nodes:
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/100
    outputs:
      - image
    env:
      ENCODING: "rgb8"
      IMAGE_WIDTH: 640
      IMAGE_HEIGHT: 480

  - id: yolo
    build: pip install dora-yolo
    path: dora-yolo
    inputs:
      image: camera/image
    outputs:
      - bbox
      - centroids  # Custom output: detection centers

  - id: tracker
    build: pip install dora-cotracker
    path: dora-cotracker
    inputs:
      image: camera/image
      points_to_track: yolo/centroids
    outputs:
      - tracked_image
      - tracked_points

  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      raw_image: camera/image
      tracking_viz: tracker/tracked_image
```

## Bounding Box Data Format

### Sending Bounding Boxes

```python
import pyarrow as pa
import numpy as np

# Create bbox structure
bbox_dict = {
    "bbox": np.array([x1, y1, x2, y2, ...], dtype=np.float32),
    "conf": np.array([0.95, ...], dtype=np.float32),
    "labels": np.array(["person", ...])
}

# Encode as Arrow
encoded = pa.array([bbox_dict])
node.send_output("bbox", encoded, {
    "format": "xyxy",
    "primitive": "boxes2d"
})
```

### Box Format Conversion

```python
# xyxy to xywh
def xyxy_to_xywh(box):
    x1, y1, x2, y2 = box
    return [x1, y1, x2 - x1, y2 - y1]

# xywh to xyxy
def xywh_to_xyxy(box):
    x, y, w, h = box
    return [x, y, x + w, y + h]
```

## Complete Detection Pipeline

```yaml
nodes:
  - id: camera
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image
    env:
      IMAGE_WIDTH: 640
      IMAGE_HEIGHT: 480

  - id: yolo
    build: pip install dora-yolo
    path: dora-yolo
    inputs:
      image: camera/image
    outputs:
      - bbox
    env:
      MODEL: yolov8n.pt

  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      camera_feed:
        source: camera/image
        metadata:
          primitive: "image"
      detections:
        source: yolo/bbox
        metadata:
          primitive: "boxes2d"
    env:
      IMAGE_WIDTH: 640
      IMAGE_HEIGHT: 480
```

## Related Skills

- **hub-camera** - Camera input nodes
- **hub-visualization** - Rerun visualization
- **domain-vision** - Vision pipeline patterns
