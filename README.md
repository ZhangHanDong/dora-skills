# dora-skills

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](https://github.com/dora-rs/dora-skills)
[![License](https://img.shields.io/badge/license-Apache--2.0-green.svg)](LICENSE)
[![Dora](https://img.shields.io/badge/dora--rs-compatible-orange.svg)](https://dora-rs.ai)

[English](#english) | [中文](#chinese)

---

<a name="english"></a>
## English

### Introduction

Skills for building AI agents, workflows, and embodied intelligence applications with the [dora-rs](https://github.com/dora-rs/dora) dataflow framework.

Dora is a high-performance dataflow framework that orchestrates AI models, sensors, and actuators through declarative YAML pipelines. It's ideal for scenarios requiring real-time data flow coordination — from multi-modal AI agents to robotic systems.

**Current Focus**: Embodied Intelligence — combining perception, language models, and physical control.

### Install Skills

#### Claude Code (Recommended)

Install directly from GitHub using the plugin marketplace:

```bash
/plugin marketplace add dora-rs/dora-skills
```

#### Alternative: Clone and Add

```bash
# Clone the repository
git clone https://github.com/dora-rs/dora-skills.git

# Add to Claude Code
claude mcp add ./dora-skills
```

#### Manual Usage

You can also browse the `skills/` directory and use the SKILL.md files as reference documentation.

### Project Structure

```
dora-skills/
├── skills/                     # Main skills directory
│   ├── dora-router/           # Main question router (load first)
│   ├── dataflow-config/       # YAML configuration
│   ├── node-api-rust/         # Rust DoraNode API
│   ├── node-api-python/       # Python dora.Node API
│   ├── operator-api/          # Operator development
│   ├── cli-commands/          # CLI usage
│   ├── integration-testing/   # Node testing
│   ├── domain-vision/         # Vision/ML pipelines
│   ├── domain-audio/          # Audio processing
│   ├── domain-robot/          # Robot control
│   ├── data-pipeline/         # Data recording/replay
│   └── hub-nodes/             # Pre-built node packages
├── commands/                   # Slash commands
├── agents/                     # Background agents
├── hooks/                      # Auto-trigger hooks
├── docs/                       # Development documentation
└── index/                      # Skill catalog
```

### Auto-Triggering Mechanism

Skills are automatically triggered through two mechanisms:

1. **Hooks** (`hooks/hooks.json`): UserPromptSubmit hook matches keywords in user messages
2. **Skill Frontmatter**: Each `SKILL.md` contains a `description` field with trigger keywords

Example skill frontmatter:
```yaml
---
name: hub-audio
description: "Use for audio processing nodes in dora.
Triggers on: dora-microphone, dora-vad, whisper, kokoro-tts, VAD, speech-to-text..."
---
```

When you ask about "dora-microphone" or "speech-to-text", the appropriate skill loads automatically.

### Available Skills

| Category | Skills | Description |
|----------|--------|-------------|
| Core | `dataflow-config`, `cli-commands` | Dataflow YAML and CLI usage |
| API | `node-api-rust`, `node-api-python`, `operator-api` | Node and operator development |
| Testing | `integration-testing` | Node testing with JSONL inputs |
| Vision | `domain-vision` | YOLO, SAM2, CoTracker, VLM |
| Audio | `domain-audio` | Whisper, Kokoro TTS, VAD |
| Robot | `domain-robot` | Arm control, chassis, kinematics |
| Data | `data-pipeline` | LeRobot recording and replay |
| Hub | `hub-nodes` | Pre-built node packages |

### Hub Node Skills (Detailed)

| Skill | Description | Key Nodes |
|-------|-------------|-----------|
| `hub-camera` | Camera capture | opencv-video-capture, dora-pyrealsense, dora-pyorbbecksdk |
| `hub-audio` | Audio processing | dora-microphone, dora-vad, dora-distil-whisper, dora-kokoro-tts |
| `hub-detection` | Detection/tracking | dora-yolo, dora-sam2, dora-cotracker |
| `hub-llm` | Language models | dora-qwen, dora-qwen2-5-vl, dora-internvl |
| `hub-robot` | Robot control | dora-piper, dora-reachy2, dora-ugv, dora-rdt-1b |
| `hub-visualization` | Visualization | dora-rerun (12 primitives), opencv-plot |
| `hub-recording` | Data recording | llama-factory-recorder, lerobot-dashboard |
| `hub-translation` | Translation | dora-opus, dora-argotranslate |

### Commands

- `/new-dataflow` - Create a new dataflow project
- `/add-node` - Add a node to existing dataflow
- `/visualize` - Generate dataflow visualization

### Agents

- `dataflow-builder` - Generate dataflow YAML configurations
- `node-debugger` - Troubleshoot dataflow issues

### Using with Dora

After loading skills, you can ask Claude to help you:

```
# Create a vision detection pipeline
"Help me build a dataflow with camera input and YOLO detection"

# Set up speech-to-speech
"Create an audio pipeline with microphone, Whisper, and TTS"

# Robot teleoperation
"I want to record demonstrations with a robot arm"
```

### Dora Quick Start

1. Install dora CLI:
```bash
pip install dora-rs-cli
# or
cargo install dora-cli
```

2. Create and run a dataflow:
```bash
dora new my-project --lang python
dora build dataflow.yml --uv
dora run dataflow.yml
```

### Resources

- [Dora Documentation](https://dora-rs.ai)
- [Dora GitHub](https://github.com/dora-rs/dora)
- [Node Hub](https://github.com/dora-rs/dora-hub)

---

<a name="chinese"></a>
## 中文

### 简介

使用 [dora-rs](https://github.com/dora-rs/dora) 数据流框架构建 AI Agent、工作流和具身智能应用的技能集。

Dora 是一个高性能数据流框架，通过声明式 YAML 管道编排 AI 模型、传感器和执行器。适用于需要实时数据流协调的场景 —— 从多模态 AI Agent 到机器人系统。

**当前重点**: 具身智能 (Embodied Intelligence) —— 融合感知、语言模型与物理控制。

### 安装 Skills

#### Claude Code (推荐)

通过插件市场直接从 GitHub 安装：

```bash
/plugin marketplace add dora-rs/dora-skills
```

#### 备选：克隆并添加

```bash
# 克隆仓库
git clone https://github.com/dora-rs/dora-skills.git

# 添加到 Claude Code
claude mcp add ./dora-skills
```

### 项目结构

```
dora-skills/
├── skills/                     # 主技能目录
│   ├── dora-router/           # 主路由器（首先加载）
│   ├── dataflow-config/       # YAML 配置
│   ├── node-api-rust/         # Rust DoraNode API
│   ├── node-api-python/       # Python dora.Node API
│   ├── operator-api/          # 操作符开发
│   ├── cli-commands/          # CLI 使用
│   ├── integration-testing/   # 节点测试
│   ├── domain-vision/         # 视觉/ML 管道
│   ├── domain-audio/          # 音频处理
│   ├── domain-robot/          # 机器人控制
│   ├── data-pipeline/         # 数据记录/回放
│   └── hub-nodes/             # 预构建节点包
├── commands/                   # 斜杠命令
├── agents/                     # 后台代理
├── hooks/                      # 自动触发钩子
├── docs/                       # 开发文档
└── index/                      # 技能目录
```

### 自动触发机制

Skills 通过两种机制自动触发：

1. **Hooks** (`hooks/hooks.json`): UserPromptSubmit 钩子匹配用户消息中的关键词
2. **Skill Frontmatter**: 每个 `SKILL.md` 包含带有触发关键词的 `description` 字段

Skill frontmatter 示例：
```yaml
---
name: hub-audio
description: "Use for audio processing nodes in dora.
Triggers on: dora-microphone, dora-vad, whisper, kokoro-tts, VAD, 语音识别..."
---
```

当你询问 "dora-microphone" 或 "语音识别" 时，相应的 skill 会自动加载。

### 可用技能

| 类别 | 技能 | 说明 |
|------|------|------|
| 核心 | `dataflow-config`, `cli-commands` | 数据流 YAML 和 CLI 使用 |
| API | `node-api-rust`, `node-api-python`, `operator-api` | 节点和操作符开发 |
| 测试 | `integration-testing` | 使用 JSONL 输入测试节点 |
| 视觉 | `domain-vision` | YOLO, SAM2, CoTracker, VLM |
| 音频 | `domain-audio` | Whisper, Kokoro TTS, VAD |
| 机器人 | `domain-robot` | 机械臂控制、底盘、运动学 |
| 数据 | `data-pipeline` | LeRobot 记录和回放 |
| Hub | `hub-nodes` | 预构建节点包 |

### Hub 节点技能 (详细)

| 技能 | 说明 | 主要节点 |
|------|------|----------|
| `hub-camera` | 摄像头采集 | opencv-video-capture, dora-pyrealsense, dora-pyorbbecksdk |
| `hub-audio` | 音频处理 | dora-microphone, dora-vad, dora-distil-whisper, dora-kokoro-tts |
| `hub-detection` | 检测/跟踪 | dora-yolo, dora-sam2, dora-cotracker |
| `hub-llm` | 语言模型 | dora-qwen, dora-qwen2-5-vl, dora-internvl |
| `hub-robot` | 机器人控制 | dora-piper, dora-reachy2, dora-ugv, dora-rdt-1b |
| `hub-visualization` | 可视化 | dora-rerun (12种图元), opencv-plot |
| `hub-recording` | 数据记录 | llama-factory-recorder, lerobot-dashboard |
| `hub-translation` | 翻译 | dora-opus, dora-argotranslate |

### 命令

- `/new-dataflow` - 创建新的数据流项目
- `/add-node` - 向现有数据流添加节点
- `/visualize` - 生成数据流可视化图

### Agents

- `dataflow-builder` - 生成 dataflow YAML 配置
- `node-debugger` - 调试数据流问题

### 配合 Dora 使用

加载 skills 后，你可以让 Claude 帮助你：

```
# 创建视觉检测管道
"帮我构建一个带摄像头输入和 YOLO 检测的数据流"

# 搭建语音对话
"创建一个带麦克风、Whisper 和 TTS 的音频管道"

# 机器人遥操作
"我想用机械臂录制演示数据"
```

### Dora 快速开始

1. 安装 dora CLI：
```bash
pip install dora-rs-cli
# 或者
cargo install dora-cli
```

2. 创建并运行数据流：
```bash
dora new my-project --lang python
dora build dataflow.yml --uv
dora run dataflow.yml
```

### 资源

- [Dora 文档](https://dora-rs.ai)
- [Dora GitHub](https://github.com/dora-rs/dora)
- [节点仓库](https://github.com/dora-rs/dora-hub)

---

## License

Apache-2.0
