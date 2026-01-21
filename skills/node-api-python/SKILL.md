---
name: node-api-python
description: "Use for Python dora node development questions.
Triggers on: dora.Node, python node, dora-rs python, event type, INPUT, STOP,
send_output, for event in node, python dataflow,
Python节点, Python API, dora python"
globs: ["**/*.py"]
source: "https://dora-rs.ai/docs/guides/getting-started/conversation_py/"
---

# Python Node API

> Complete guide to building dora nodes in Python

## Installation

```bash
pip install dora-rs
```

## Basic Usage

```python
from dora import Node

node = Node()

for event in node:
    if event["type"] == "INPUT":
        input_id = event["id"]
        data = event["value"]  # numpy array or pyarrow array
        metadata = event["metadata"]

        # Process data...

        # Send output
        node.send_output("output_id", data)

    elif event["type"] == "STOP":
        break
```

## Event Types

```python
event = {
    "type": "INPUT" | "STOP" | "INPUT_CLOSED" | "ERROR",
    "id": "input_name",           # For INPUT events
    "value": data,                # numpy/pyarrow array
    "metadata": {...},            # Timestamp, type info
    "error": "message",           # For ERROR events
}
```

### Handling Events

```python
from dora import Node

node = Node()

for event in node:
    match event["type"]:
        case "INPUT":
            handle_input(event["id"], event["value"])
        case "INPUT_CLOSED":
            print(f"Input {event['id']} closed")
        case "STOP":
            print("Stopping...")
            break
        case "ERROR":
            print(f"Error: {event['error']}")
```

## Sending Outputs

### NumPy Arrays

```python
import numpy as np

# Integer array
data = np.array([1, 2, 3], dtype=np.int32)
node.send_output("numbers", data)

# Float array
data = np.array([1.0, 2.5, 3.14], dtype=np.float64)
node.send_output("floats", data)

# Image (HWC format)
image = np.zeros((480, 640, 3), dtype=np.uint8)
node.send_output("image", image)
```

### PyArrow Arrays

```python
import pyarrow as pa

# String array
data = pa.array(["hello", "world"])
node.send_output("text", data)

# Struct array (for complex data)
data = pa.array([{
    "x": 1.0,
    "y": 2.0,
    "label": "point"
}])
node.send_output("point", data)
```

### With Metadata

```python
metadata = {
    "watermark": 1000,
    "deadline": 5000,
}
node.send_output("data", array, metadata)
```

## Complete Examples

### Camera Node

```python
# camera_node.py
import cv2
import numpy as np
from dora import Node

node = Node()
cap = cv2.VideoCapture(0)

for event in node:
    if event["type"] == "INPUT" and event["id"] == "tick":
        ret, frame = cap.read()
        if ret:
            # Convert BGR to RGB
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            node.send_output("image", frame_rgb)

    elif event["type"] == "STOP":
        break

cap.release()
```

### Processing Node

```python
# processor_node.py
import numpy as np
from dora import Node

node = Node()

for event in node:
    if event["type"] == "INPUT":
        if event["id"] == "image":
            image = event["value"]

            # Process image
            gray = np.mean(image, axis=2).astype(np.uint8)

            node.send_output("processed", gray)

    elif event["type"] == "STOP":
        break
```

### Detection Node

```python
# detector_node.py
import numpy as np
import pyarrow as pa
from dora import Node
from ultralytics import YOLO

node = Node()
model = YOLO("yolov8n.pt")

for event in node:
    if event["type"] == "INPUT" and event["id"] == "image":
        image = event["value"]

        # Run detection
        results = model(image)

        # Convert to bounding boxes
        boxes = []
        for r in results:
            for box in r.boxes:
                boxes.append({
                    "x1": float(box.xyxy[0][0]),
                    "y1": float(box.xyxy[0][1]),
                    "x2": float(box.xyxy[0][2]),
                    "y2": float(box.xyxy[0][3]),
                    "confidence": float(box.conf[0]),
                    "class": int(box.cls[0]),
                })

        node.send_output("bbox", pa.array(boxes))

    elif event["type"] == "STOP":
        break
```

## Dataflow Configuration

```yaml
nodes:
  - id: camera
    path: camera_node.py
    inputs:
      tick: dora/timer/millis/33
    outputs:
      - image

  - id: processor
    path: processor_node.py
    inputs:
      image: camera/image
    outputs:
      - processed

  - id: detector
    path: detector_node.py
    inputs:
      image: camera/image
    outputs:
      - bbox
```

## Async Python (Experimental)

```python
import asyncio
from dora import Node

async def main():
    node = Node()

    async for event in node:
        if event["type"] == "INPUT":
            # Async processing
            result = await process_async(event["value"])
            node.send_output("result", result)

        elif event["type"] == "STOP":
            break

asyncio.run(main())
```

## Environment Variables

Access environment variables from dataflow config:

```python
import os

model_path = os.environ.get("MODEL_PATH", "default.pt")
device = os.environ.get("DEVICE", "cpu")
```

## Best Practices

1. **Use NumPy for numerical data** - Native support, zero-copy when possible
2. **Use PyArrow for structured data** - Complex types, nested structures
3. **Handle STOP events** - Clean up resources properly
4. **Check input IDs** - Multiple inputs may arrive
5. **Use environment variables** - Keep config in YAML

## Debugging

### Interactive Mode

Run node directly for testing:

```bash
python my_node.py
```

Without `DORA_NODE_CONFIG` set, the node enters interactive mode where you can manually provide inputs.

### Logging

```python
import logging

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

for event in node:
    logger.debug(f"Received event: {event['type']}")
```

## Related Skills

- **dataflow-config** - YAML configuration
- **node-api-rust** - Rust alternative
- **hub-nodes** - Pre-built Python nodes
