---
name: hub-visualization
description: "Use for visualization nodes in dora.
Triggers on: dora-rerun, opencv-plot, rerun, visualization, plot, display,
image display, bounding box visualization, 3D visualization, depth visualization,
可视化, 显示, 绘图"
globs: ["**/dataflow.yml", "**/dataflow.yaml"]
source: "https://github.com/dora-rs/dora-hub"
---

# Visualization Nodes

> Rerun and OpenCV visualization for images, 3D data, and telemetry

## Available Visualization Nodes

| Node | Install | Description |
|------|---------|-------------|
| dora-rerun | `pip install dora-rerun` | Comprehensive visualization with Rerun |
| opencv-plot | `pip install opencv-plot` | Simple OpenCV image + bbox display |

## dora-rerun

Powerful visualization using Rerun with 12 supported primitives.

### Installation

```bash
pip install dora-rerun
```

### YAML Configuration

```yaml
- id: rerun
  build: pip install dora-rerun
  path: dora-rerun
  inputs:
    camera_feed: camera/image
    detections: yolo/bbox
    depth_sensor: realsense/depth
  env:
    IMAGE_WIDTH: 640
    IMAGE_HEIGHT: 480
    RERUN_MEMORY_LIMIT: 25%
    README: |
      # My Visualization
      Description shown in Rerun
```

### Primitive-Based Visualization (v0.24.0+)

All inputs require a `primitive` metadata field to specify visualization type.

#### Method 1: Explicit Metadata in YAML

```yaml
inputs:
  front_camera:
    source: camera/image
    metadata:
      primitive: "image"
  depth_sensor:
    source: realsense/depth
    metadata:
      primitive: "depth"
      focal: [600, 600]
      camera_position: [0, 0, 0]
```

#### Method 2: Sender Includes Primitive

```python
# Sender node includes primitive in metadata
node.send_output("image", image_data, {
    "width": 640,
    "height": 480,
    "encoding": "bgr8",
    "primitive": "image"
})
```

### Supported Primitives

| Primitive | Data Type | Required Metadata |
|-----------|-----------|-------------------|
| image | UInt8Array | width, height, encoding |
| depth | Float32Array | width, height |
| text | StringArray | - |
| boxes2d | StructArray/Float32Array | format: "xyxy" or "xywh" |
| boxes3d | Float32Array | format, solid, color |
| masks | UInt8Array | width, height |
| jointstate | Float32Array | (requires URDF config) |
| pose | Float32Array [x,y,z,qx,qy,qz,qw] | - |
| series | Float32Array | - |
| points3d | Float32Array | color, radii |
| points2d | Float32Array | - |
| lines3d | Float32Array | color, radius |

### Primitive Details

#### image
```python
metadata = {
    "primitive": "image",
    "width": 640,
    "height": 480,
    "encoding": "bgr8"  # bgr8, rgb8, jpeg, png, avif
}
```

#### depth (with 3D reconstruction)
```python
metadata = {
    "primitive": "depth",
    "width": 640,
    "height": 480,
    "camera_position": [0, 0, 0],        # [x, y, z]
    "camera_orientation": [0, 0, 0, 1],  # [qx, qy, qz, qw]
    "focal": [600, 600],                 # [fx, fy]
    "principal_point": [320, 240]        # [cx, cy] optional
}
```

#### boxes2d
```python
bbox = {
    "bbox": np.array([x1,y1,x2,y2,...]).flatten(),
    "conf": np.array([0.95,...]),
    "labels": np.array(["person",...])
}
metadata = {"primitive": "boxes2d", "format": "xyxy"}
```

#### boxes3d
```python
# center_half_size format (default)
boxes = np.array([cx,cy,cz, hx,hy,hz, ...])
metadata = {
    "primitive": "boxes3d",
    "format": "center_half_size",  # or "center_size", "min_max"
    "solid": False,  # wireframe (default) or solid
    "color": [255, 0, 0]  # RGB
}
```

#### points3d
```python
points = np.array([x1,y1,z1, x2,y2,z2, ...], dtype=np.float32)
metadata = {
    "primitive": "points3d",
    "color": [0, 255, 0],
    "radii": [0.01, 0.01, ...]
}
```

#### lines3d
```python
# Line segments: pairs of xyz points
lines = np.array([x1,y1,z1, x2,y2,z2, ...], dtype=np.float32)
metadata = {
    "primitive": "lines3d",
    "color": [0, 0, 255],
    "radius": 0.005
}
```

#### pose
```python
# 7 values: position + quaternion
pose = np.array([x, y, z, qx, qy, qz, qw], dtype=np.float32)
metadata = {"primitive": "pose"}
```

#### jointstate (with URDF)
```yaml
- id: rerun
  path: dora-rerun
  inputs:
    jointstate_robot: arm/joint_state
  env:
    robot_urdf: /path/to/robot.urdf
    robot_transform: "0 0.3 0"  # x y z offset
```

### Complete Visualization Example

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

  - id: vlm
    build: pip install dora-qwen2-5-vl
    path: dora-qwen2-5-vl
    inputs:
      image:
        source: camera/image
        queue_size: 1
    outputs:
      - text
    env:
      DEFAULT_QUESTION: "Describe the scene."

  - id: rerun
    build: pip install dora-rerun
    path: dora-rerun
    inputs:
      camera:
        source: camera/image
        metadata:
          primitive: "image"
      detections:
        source: yolo/bbox
        metadata:
          primitive: "boxes2d"
      description:
        source: vlm/text
        metadata:
          primitive: "text"
    env:
      IMAGE_WIDTH: 640
      IMAGE_HEIGHT: 480
      RERUN_MEMORY_LIMIT: 25%
```

## opencv-plot

Simple OpenCV visualization with image, bounding boxes, and text overlay.

### YAML Configuration

```yaml
- id: plot
  build: pip install opencv-plot
  path: opencv-plot
  inputs:
    image: camera/image
    bbox: yolo/bbox
    text: vlm/text
  env:
    PLOT_WIDTH: 640   # Optional, defaults to image width
    PLOT_HEIGHT: 480  # Optional, defaults to image height
```

### Input Formats

**image:** UInt8Array
```python
metadata = {"width": 640, "height": 480, "encoding": "bgr8"}
```

**bbox:** StructArray
```python
bbox = {
    "bbox": np.array([x1,y1,x2,y2,...]),
    "conf": np.array([0.95,...]),
    "labels": np.array(["person",...])
}
metadata = {"format": "xyxy"}
```

**text:** StringArray
```python
text = pa.array(["Detection: person 95%"])
```

### Simple Camera + Detection Visualization

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

  - id: plot
    build: pip install opencv-plot
    path: opencv-plot
    inputs:
      image: camera/image
      bbox: yolo/bbox
```

## Migration to dora-rerun v0.24.0

### Old Way (still works with auto-detection)
```yaml
inputs:
  image: camera/image  # Primitive inferred from "image" in name
```

### New Way (recommended)
```yaml
inputs:
  front_camera:
    source: camera/image
    metadata:
      primitive: "image"
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| IMAGE_WIDTH | Default image width |
| IMAGE_HEIGHT | Default image height |
| RERUN_MEMORY_LIMIT | Memory limit (e.g., "25%", "1GB") |
| README | Markdown text shown in Rerun |
| *_urdf | Path to URDF file for joint visualization |
| *_transform | Position offset "x y z" for URDF |

## Related Skills

- **hub-camera** - Camera input nodes
- **hub-detection** - Detection output visualization
- **hub-robot** - Joint state visualization
