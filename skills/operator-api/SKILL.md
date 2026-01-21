---
name: operator-api
description: "Use for dora operator development questions.
Triggers on: DoraOperator, on_event, register_operator, DoraOutputSender, DoraStatus,
operator:, operators:, runtime node, shared runtime, lightweight,
操作符, 运算符, 轻量级节点"
globs: ["**/*.rs"]
source: "https://docs.rs/dora-operator-api/latest/dora_operator_api/"
---

# Operator API (dora-operator-api)

> Lightweight alternative to nodes that run in a shared runtime process

## Overview

Operators are lightweight alternatives to nodes:
- Run in a shared runtime process (not separate processes)
- Lower overhead than full nodes
- Ideal for simple transformations
- Currently best supported in Rust

## Rust Operator

### Dependencies

```toml
[dependencies]
dora-operator-api = "0.4"

[lib]
crate-type = ["cdylib"]
```

### Basic Usage

```rust
use dora_operator_api::{
    register_operator, DoraOperator, DoraOutputSender, DoraStatus, Event
};
use dora_operator_api::arrow::array::*;

#[derive(Default)]
struct MyOperator {
    counter: u32,
}

impl DoraOperator for MyOperator {
    fn on_event(
        &mut self,
        event: &Event,
        output_sender: &mut DoraOutputSender,
    ) -> Result<DoraStatus, String> {
        match event {
            Event::Input { id, data } => {
                self.counter += 1;

                // Process input...

                // Send output
                let result = UInt32Array::from(vec![self.counter]);
                output_sender.send("count".to_string(), result)?;

                Ok(DoraStatus::Continue)
            }
            Event::InputClosed { id } => {
                println!("Input {} closed", id);
                Ok(DoraStatus::Continue)
            }
            Event::Stop => Ok(DoraStatus::Stop),
            _ => Ok(DoraStatus::Continue),
        }
    }
}

register_operator!(MyOperator);
```

## Event Types

```rust
pub enum Event<'a> {
    // Input received
    Input {
        id: &'a str,
        data: ArrowData,
    },

    // Input parsing failed
    InputParseError {
        id: &'a str,
        error: String,
    },

    // Input closed by sender
    InputClosed {
        id: &'a str,
    },

    // Stop signal
    Stop,
}
```

## DoraStatus

```rust
pub enum DoraStatus {
    Continue,  // Keep running
    Stop,      // Stop the operator
}
```

## Sending Outputs

```rust
impl DoraOutputSender<'_> {
    /// Send output with Arrow data
    pub fn send(&mut self, id: String, data: impl Array) -> Result<(), String>;
}
```

### Examples

```rust
use dora_operator_api::arrow::array::*;

// Integer output
let data = Int32Array::from(vec![1, 2, 3]);
output_sender.send("numbers".to_string(), data)?;

// String output
let data = StringArray::from(vec!["hello", "world"]);
output_sender.send("text".to_string(), data)?;

// Binary output
let data = BinaryArray::from(vec![b"bytes".as_slice()]);
output_sender.send("binary".to_string(), data)?;
```

## Python Operator

### Basic Usage

```python
# my_operator.py
class Operator:
    def __init__(self):
        self.counter = 0

    def on_event(
        self,
        dora_event,
        send_output,
    ):
        if dora_event["type"] == "INPUT":
            self.counter += 1

            # Process input
            value = dora_event["value"]

            # Send output
            send_output("count", [self.counter])

        return DoraStatus.CONTINUE
```

## Dataflow Configuration

### Single Operator

```yaml
nodes:
  - id: processor
    operator:
      python: my_operator.py
      # Or for Rust:
      # shared-library: target/release/libmy_operator
      inputs:
        data: source/output
      outputs:
        - processed
```

### Multiple Operators

```yaml
nodes:
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

### Rust Shared Library

```yaml
nodes:
  - id: rust-operator
    operator:
      shared-library: target/release/my_operator
      inputs:
        data: source/output
      outputs:
        - processed
```

## Complete Example: Counter Operator

### Rust Implementation

```rust
// src/lib.rs
use dora_operator_api::{
    register_operator, DoraOperator, DoraOutputSender, DoraStatus, Event
};
use dora_operator_api::arrow::array::UInt64Array;

#[derive(Default)]
struct Counter {
    count: u64,
}

impl DoraOperator for Counter {
    fn on_event(
        &mut self,
        event: &Event,
        output_sender: &mut DoraOutputSender,
    ) -> Result<DoraStatus, String> {
        if let Event::Input { .. } = event {
            self.count += 1;

            let output = UInt64Array::from(vec![self.count]);
            output_sender.send("count".to_string(), output)?;
        }

        if matches!(event, Event::Stop) {
            return Ok(DoraStatus::Stop);
        }

        Ok(DoraStatus::Continue)
    }
}

register_operator!(Counter);
```

### Cargo.toml

```toml
[package]
name = "counter-operator"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["cdylib"]

[dependencies]
dora-operator-api = "0.4"
```

### Dataflow

```yaml
nodes:
  - id: timer
    path: timer-source
    inputs:
      tick: dora/timer/millis/1000
    outputs:
      - tick

  - id: counter
    operator:
      shared-library: target/release/libcounter_operator
      inputs:
        tick: timer/tick
      outputs:
        - count

  - id: logger
    path: logger-sink
    inputs:
      count: counter/count
```

## Operators vs Nodes

| Feature | Operators | Nodes |
|---------|-----------|-------|
| Process | Shared runtime | Separate process |
| Overhead | Lower | Higher |
| Isolation | Less | More |
| Memory | Shared | Separate |
| Languages | Rust, Python | Any |
| Use case | Simple transforms | Complex logic |

## Best Practices

1. **Keep operators simple** - Complex logic belongs in nodes
2. **Avoid blocking operations** - Don't block the runtime
3. **Handle errors gracefully** - Return appropriate DoraStatus
4. **Use shared state carefully** - Operators share address space

## Related Skills

- **node-api-rust** - Full Rust nodes
- **node-api-python** - Full Python nodes
- **dataflow-config** - YAML configuration
