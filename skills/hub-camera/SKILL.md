---
name: hub-camera
description: "Use for camera and video capture nodes in dora.
Triggers on: opencv-video-capture, dora-pyrealsense, dora-pyorbbecksdk, realsense, orbbeck,
camera, webcam, video capture, RGB, depth camera, image capture,
摄像头, 视频捕获, 深度相机, 图像采集"
globs: ["**/dataflow.yml", "**/dataflow.yaml"]
source: "https://github.com/dora-rs/dora-hub"
---

# Camera & Video Capture Nodes

> Capture video frames from cameras and depth sensors

## Available Camera Nodes

| Node | Install | Description | Platform |
|------|---------|-------------|----------|
| opencv-video-capture | `pip install opencv-video-capture` | OpenCV camera/video | All |
| dora-pyrealsense | `pip install dora-pyrealsense` | Intel RealSense depth | Linux |
| dora-pyorbbecksdk | `pip install dora-pyorbbecksdk` | Orbbeck depth camera | All |

## opencv-video-capture

OpenCV-based video capture from webcam or video file.

### YAML Configuration

```yaml
- id: camera
  build: pip install opencv-video-capture
  path: opencv-video-capture
  inputs:
    tick: dora/timer/millis/16  # ~60fps
  outputs:
    - image
  env:
    PATH: "0"           # Camera index (0, 1, ...) or video file path
    IMAGE_WIDTH: 640    # Optional: output width
    IMAGE_HEIGHT: 480   # Optional: output height
```

### Outputs

**image** - UInt8Array with metadata:
```python
metadata = {
    "width": 640,
    "height": 480,
    "encoding": "bgr8",  # or "rgb8"
    "primitive": "image"  # for dora-rerun
}
```

### Decoding Output

```python
storage = event["value"]
metadata = event["metadata"]
width = metadata["width"]
height = metadata["height"]
encoding = metadata["encoding"]

channels = 3
frame = storage.to_numpy().astype(np.uint8).reshape((height, width, channels))

# Convert BGR to RGB if needed
if encoding == "bgr8":
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
```

## dora-pyrealsense

Intel RealSense camera with RGB and depth streams.

### YAML Configuration

```yaml
- id: realsense
  build: pip install dora-pyrealsense
  path: dora-pyrealsense
  inputs:
    tick: dora/timer/millis/33  # ~30fps
  outputs:
    - image  # RGB image
    - depth  # Depth image
  env:
    IMAGE_WIDTH: 640
    IMAGE_HEIGHT: 480
```

### Outputs

**image** - RGB UInt8Array
```python
metadata = {"width": 640, "height": 480, "encoding": "rgb8"}
```

**depth** - Float32Array depth values (meters)
```python
metadata = {"width": 640, "height": 480}
```

## dora-pyorbbecksdk

Orbbeck depth camera support.

### YAML Configuration

```yaml
- id: orbbeck
  build: pip install dora-pyorbbecksdk
  path: dora-pyorbbecksdk
  inputs:
    tick: dora/timer/millis/33
  outputs:
    - image
    - depth
```

## Image Data Format

All camera nodes output images in Apache Arrow format:

```python
import pyarrow as pa
import numpy as np

# Encoding image
image_data = pa.array(frame.ravel())  # UInt8Array

# Sending
node.send_output("image", image_data, {
    "width": 640,
    "height": 480,
    "encoding": "bgr8",
    "primitive": "image"  # for dora-rerun visualization
})
```

## Common Patterns

### Camera with Detection Pipeline

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

  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      image: camera/image
      detections: yolo/bbox
```

### Dual Camera Setup

```yaml
nodes:
  - id: camera_left
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image
    env:
      PATH: "0"

  - id: camera_right
    build: pip install opencv-video-capture
    path: opencv-video-capture
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image
    env:
      PATH: "1"
```

### Depth Camera with 3D Visualization

```yaml
nodes:
  - id: realsense
    build: pip install dora-pyrealsense
    path: dora-pyrealsense
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image
      - depth

  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      rgb_camera:
        source: realsense/image
        metadata:
          primitive: "image"
      depth_sensor:
        source: realsense/depth
        metadata:
          primitive: "depth"
          focal: [600, 600]
          camera_position: [0, 0, 0]
```

## Troubleshooting

### Camera not found
```bash
# List available cameras
v4l2-ctl --list-devices  # Linux
```

### Permission denied
```bash
# Add user to video group (Linux)
sudo usermod -a -G video $USER
```

### Frame rate issues
- Reduce resolution in env vars
- Increase timer interval (e.g., millis/50 for 20fps)

## Related Skills

- **hub-detection** - Object detection with YOLO, SAM2
- **hub-visualization** - Rerun visualization
- **domain-vision** - Vision pipeline patterns
