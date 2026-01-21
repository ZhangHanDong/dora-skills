---
name: integration-testing
description: "Use for dora node testing questions.
Triggers on: integration testing, test inputs, test outputs, JSONL,
setup_integration_testing, TestingInput, TestingOutput, DORA_TEST_WITH_INPUTS,
节点测试, 集成测试, 测试输入"
globs: ["**/*.rs", "**/test*.py", "**/test*.json"]
source: "https://docs.rs/dora-node-api/latest/dora_node_api/integration_testing/"
---

# Integration Testing

> Built-in support for testing dora nodes

## Overview

Dora provides integration testing capabilities that allow testing nodes in isolation without running the full daemon.

## Rust Testing

### Setup

```rust
use dora_node_api::integration_testing::{
    setup_integration_testing, TestingInput, TestingOutput, TestingOptions
};

#[test]
fn test_my_node() {
    // Setup test environment
    setup_integration_testing(
        TestingInput::FromJsonFile("tests/inputs.jsonl".into()),
        TestingOutput::ToFile("tests/outputs.jsonl".into()),
        TestingOptions::default(),
    );

    // Run your node normally
    let (mut node, mut events) = DoraNode::init_from_env().unwrap();

    // Node will receive inputs from the test file
    while let Some(event) = events.recv() {
        // ... normal processing
    }
}
```

### Test Input File (JSONL)

```json
{"id": "tick", "data": null, "time_offset_secs": 0.0}
{"id": "image", "data": [1, 2, 3, 4], "time_offset_secs": 0.1}
{"id": "config", "data": {"width": 640, "height": 480}, "time_offset_secs": 0.2}
{"type": "Stop", "time_offset_secs": 1.0}
```

### Input Formats

```json
// Null data (like timer tick)
{"id": "tick", "data": null, "time_offset_secs": 0.0}

// Array data
{"id": "numbers", "data": [1, 2, 3], "time_offset_secs": 0.1}

// String data
{"id": "text", "data": "hello world", "time_offset_secs": 0.2}

// Object/struct data
{"id": "config", "data": {"key": "value"}, "time_offset_secs": 0.3}

// Binary data (base64 encoded)
{"id": "image", "data": "base64:SGVsbG8=", "time_offset_secs": 0.4}

// Stop event
{"type": "Stop", "time_offset_secs": 1.0}

// Input closed event
{"type": "InputClosed", "id": "tick", "time_offset_secs": 0.5}
```

### TestingOptions

```rust
let options = TestingOptions {
    skip_output_time_offsets: true,  // Don't record time offsets in outputs
};
```

## Environment Variable Testing

Alternatively, use environment variables:

```bash
# Set input file
export DORA_TEST_WITH_INPUTS=tests/inputs.jsonl

# Optional: set output file
export DORA_TEST_WRITE_OUTPUTS_TO=tests/outputs.jsonl

# Optional: skip time offsets
export DORA_TEST_NO_OUTPUT_TIME_OFFSET=1

# Run your node
./my_node
```

## Output Verification

The test framework writes outputs to a JSONL file:

```json
{"id": "result", "data": [42], "time_offset_secs": 0.05}
{"id": "status", "data": "ok", "time_offset_secs": 0.1}
```

### Verifying Outputs in Rust

```rust
#[test]
fn verify_outputs() {
    // Run test...

    // Read outputs
    let outputs = std::fs::read_to_string("tests/outputs.jsonl").unwrap();
    let lines: Vec<&str> = outputs.lines().collect();

    // Parse and verify
    let first: serde_json::Value = serde_json::from_str(lines[0]).unwrap();
    assert_eq!(first["id"], "result");
    assert_eq!(first["data"], json!([42]));
}
```

## Python Testing

### With pytest

```python
# test_my_node.py
import subprocess
import json
import os

def test_my_node():
    # Create test inputs
    inputs = [
        {"id": "tick", "data": None, "time_offset_secs": 0.0},
        {"id": "data", "data": [1, 2, 3], "time_offset_secs": 0.1},
        {"type": "Stop", "time_offset_secs": 1.0},
    ]

    with open("test_inputs.jsonl", "w") as f:
        for inp in inputs:
            f.write(json.dumps(inp) + "\n")

    # Set environment and run
    env = os.environ.copy()
    env["DORA_TEST_WITH_INPUTS"] = "test_inputs.jsonl"
    env["DORA_TEST_WRITE_OUTPUTS_TO"] = "test_outputs.jsonl"

    result = subprocess.run(
        ["python", "my_node.py"],
        env=env,
        capture_output=True
    )

    assert result.returncode == 0

    # Verify outputs
    with open("test_outputs.jsonl") as f:
        outputs = [json.loads(line) for line in f]

    assert outputs[0]["id"] == "result"
```

## Complete Example

### Node Under Test

```rust
// src/main.rs
use dora_node_api::{DoraNode, Event, MetadataParameters};
use dora_node_api::arrow::array::Int32Array;

fn main() -> eyre::Result<()> {
    let (mut node, mut events) = DoraNode::init_from_env()?;

    let mut sum = 0i32;

    while let Some(event) = events.recv() {
        match event {
            Event::Input { id, data, .. } => {
                if id.as_ref() == "number" {
                    if let Some(arr) = data.as_any().downcast_ref::<Int32Array>() {
                        sum += arr.value(0);
                        let result = Int32Array::from(vec![sum]);
                        node.send_output(
                            "sum".into(),
                            MetadataParameters::default(),
                            result,
                        )?;
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

### Test File

```rust
// tests/integration.rs
use dora_node_api::DoraNode;
use dora_node_api::integration_testing::*;

#[test]
fn test_sum_node() {
    setup_integration_testing(
        TestingInput::FromJsonFile("tests/sum_inputs.jsonl".into()),
        TestingOutput::ToFile("tests/sum_outputs.jsonl".into()),
        TestingOptions::default(),
    );

    // Run node (this would be in a subprocess in real test)
    // ...

    // Verify outputs
    let outputs = std::fs::read_to_string("tests/sum_outputs.jsonl").unwrap();
    // Parse and assert...
}
```

### Test Input (tests/sum_inputs.jsonl)

```json
{"id": "number", "data": [10], "time_offset_secs": 0.0}
{"id": "number", "data": [20], "time_offset_secs": 0.1}
{"id": "number", "data": [30], "time_offset_secs": 0.2}
{"type": "Stop", "time_offset_secs": 1.0}
```

### Expected Output

```json
{"id": "sum", "data": [10], "time_offset_secs": 0.01}
{"id": "sum", "data": [30], "time_offset_secs": 0.11}
{"id": "sum", "data": [60], "time_offset_secs": 0.21}
```

## Best Practices

1. **Use deterministic inputs** - Fixed data, predictable timing
2. **Test edge cases** - Empty data, large data, malformed inputs
3. **Verify all outputs** - Check data and timing
4. **Clean up test files** - Remove generated files after tests
5. **Use CI/CD** - Automate testing in pipelines

## Related Skills

- **node-api-rust** - Rust node development
- **node-api-python** - Python node development
