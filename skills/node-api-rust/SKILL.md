---
name: node-api-rust
description: "Use for Rust dora-node-api development questions.
Triggers on: DoraNode, EventStream, init_from_env, send_output, Event::Input,
Event::Stop, Event::InputClosed, Metadata, MetadataParameters, DataSample,
arrow array, shared memory, ZERO_COPY_THRESHOLD,
Rust节点, Rust API, 发送输出, 事件流"
globs: ["**/*.rs", "**/Cargo.toml"]
source: "https://docs.rs/dora-node-api/latest/dora_node_api/"
---

# Rust Node API (dora-node-api)

> Complete guide to building dora nodes in Rust

## Dependencies

```toml
[dependencies]
dora-node-api = "0.4"
eyre = "0.6"
```

## Basic Usage

```rust
use dora_node_api::{DoraNode, Event, MetadataParameters};
use dora_node_api::arrow::array::StringArray;

fn main() -> eyre::Result<()> {
    // Initialize node from environment (set by dora daemon)
    let (mut node, mut events) = DoraNode::init_from_env()?;

    // Process events
    while let Some(event) = events.recv() {
        match event {
            Event::Input { id, metadata, data } => {
                println!("Received input '{}' with {} bytes", id, data.len());

                // Send output
                let output_data = StringArray::from(vec!["hello"]);
                node.send_output(
                    "output_id".into(),
                    MetadataParameters::default(),
                    output_data,
                )?;
            }
            Event::InputClosed { id } => {
                println!("Input '{}' closed", id);
            }
            Event::Stop(cause) => {
                println!("Stopping: {:?}", cause);
                break;
            }
            Event::Error(e) => {
                eprintln!("Error: {}", e);
            }
            _ => {}
        }
    }

    Ok(())
}
```

## DoraNode Initialization

### Standard (Recommended)

```rust
// For nodes spawned by dora daemon
let (node, events) = DoraNode::init_from_env()?;
```

### Dynamic Nodes

```rust
use dora_node_api::dora_core::config::NodeId;

// For manually started nodes
let (node, events) = DoraNode::init_from_node_id(
    NodeId::from("my_node".to_string())
)?;
```

### Flexible

```rust
// Tries env first, falls back to dynamic
let (node, events) = DoraNode::init_flexible(
    NodeId::from("my_node".to_string())
)?;
```

### Interactive (Debugging)

```rust
// For terminal debugging
let (node, events) = DoraNode::init_interactive()?;
```

## Sending Outputs

### Arrow Array (Recommended)

```rust
use dora_node_api::arrow::array::*;

// Integer array
let data = Int32Array::from(vec![1, 2, 3]);
node.send_output("numbers".into(), MetadataParameters::default(), data)?;

// String array
let data = StringArray::from(vec!["hello", "world"]);
node.send_output("text".into(), MetadataParameters::default(), data)?;

// Float array
let data = Float64Array::from(vec![1.0, 2.5, 3.14]);
node.send_output("floats".into(), MetadataParameters::default(), data)?;
```

### Raw Bytes

```rust
let bytes = b"hello world";
node.send_output_bytes(
    "raw_data".into(),
    MetadataParameters::default(),
    bytes.len(),
    bytes,
)?;
```

### Zero-Copy (Large Data)

```rust
// For data > 4KB, uses shared memory automatically
node.send_output_raw(
    "large_data".into(),
    MetadataParameters::default(),
    data_len,
    |buffer| {
        buffer.copy_from_slice(&my_large_data);
    },
)?;
```

### Close Outputs Early

```rust
// Notify subscribers that output is finished
node.close_outputs(vec!["output_id".into()])?;
```

## Event Types

```rust
pub enum Event {
    // Input received from another node
    Input {
        id: DataId,           // Input ID as specified in YAML
        metadata: Metadata,   // Timestamp and type info
        data: ArrowData,      // Apache Arrow data
    },

    // Input was closed by sender
    InputClosed { id: DataId },

    // Node should stop
    Stop(StopCause),

    // Reload operator (runtime nodes only)
    Reload { operator_id: Option<OperatorId> },

    // Internal error
    Error(String),
}

pub enum StopCause {
    Manual,           // User issued stop command (dora stop / ctrl-c)
    AllInputsClosed,  // All inputs finished
}
```

## EventStream Methods

### Synchronous (Blocking)

```rust
// Block until next event
while let Some(event) = events.recv() { ... }

// With timeout
if let Some(event) = events.recv_timeout(Duration::from_secs(5)) { ... }
```

### Asynchronous

```rust
// Async receive
while let Some(event) = events.recv_async().await { ... }

// With timeout
let event = events.recv_async_timeout(Duration::from_secs(5)).await;
```

### Non-Blocking

```rust
match events.try_recv() {
    Ok(event) => { /* handle event */ }
    Err(TryRecvError::Empty) => { /* no event ready */ }
    Err(TryRecvError::Closed) => { /* stream closed */ }
}

// Drain all buffered events
if let Some(events) = events.drain() {
    for event in events { ... }
}
```

## Data Conversion

```rust
use dora_node_api::arrow::array::*;

// Convert to specific array type
if let Some(int_array) = data.as_any().downcast_ref::<Int32Array>() {
    for value in int_array.iter() {
        println!("{:?}", value);
    }
}

// For string data
if let Some(str_array) = data.as_any().downcast_ref::<StringArray>() {
    for s in str_array.iter() {
        println!("{}", s.unwrap_or(""));
    }
}

// For binary data
if let Some(bin_array) = data.as_any().downcast_ref::<BinaryArray>() {
    for bytes in bin_array.iter() {
        if let Some(b) = bytes {
            // Process bytes
        }
    }
}
```

## Node Information

```rust
let node_id = node.id();                    // Node ID
let dataflow_id = node.dataflow_id();       // Dataflow UUID
let config = node.node_config();            // Input/output config
let descriptor = node.dataflow_descriptor()?; // Full dataflow YAML
```

## Shared Memory

Data larger than `ZERO_COPY_THRESHOLD` (4096 bytes) automatically uses shared memory:

```rust
use dora_node_api::ZERO_COPY_THRESHOLD;

// Allocate data sample (auto uses shared memory for large data)
let mut sample = node.allocate_data_sample(large_data_len)?;
sample.copy_from_slice(&large_data);
```

## Complete Example: Image Processor

```rust
use dora_node_api::{DoraNode, Event, MetadataParameters};
use dora_node_api::arrow::array::{BinaryArray, StructArray};
use eyre::Result;

fn main() -> Result<()> {
    let (mut node, mut events) = DoraNode::init_from_env()?;

    while let Some(event) = events.recv() {
        match event {
            Event::Input { id, data, .. } => {
                if id.as_ref() == "image" {
                    // Process image data
                    if let Some(bin) = data.as_any().downcast_ref::<BinaryArray>() {
                        if let Some(image_bytes) = bin.value(0).into() {
                            // Process image...
                            let result = process_image(image_bytes);

                            // Send result
                            node.send_output(
                                "processed".into(),
                                MetadataParameters::default(),
                                result,
                            )?;
                        }
                    }
                }
            }
            Event::Stop(_) => break,
            _ => {}
        }
    }

    Ok(())
}
```

## Tracing (OpenTelemetry)

```rust
use dora_node_api::init_tracing;

fn main() -> eyre::Result<()> {
    let (node, events) = DoraNode::init_from_env()?;

    // Initialize tracing (requires tokio runtime)
    let _guard = init_tracing(node.id(), node.dataflow_id())?;

    // ... rest of node logic
}
```

## Related Skills

- **dataflow-config** - YAML configuration
- **operator-api** - Lightweight operators
- **integration-testing** - Testing nodes
