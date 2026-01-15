# dora-skills

[English](#english) | [中文](#chinese)

---

<a name="english"></a>
## English

### Introduction

Skills for building AI agents, workflows, and embodied intelligence applications with the [dora-rs](https://github.com/dora-rs/dora) dataflow framework.

Dora is a high-performance dataflow framework that orchestrates AI models, sensors, and actuators through declarative YAML pipelines. It's ideal for scenarios requiring real-time data flow coordination — from multi-modal AI agents to robotic systems.

**Current Focus**: Embodied Intelligence — combining perception, language models, and physical control.

### Install Skills

#### Claude Code

```bash
# Clone the repository
git clone https://github.com/dora-rs/dora-skills.git

# Add to Claude Code
claude mcp add ./dora-skills
```

Or add directly in Claude Code settings:
```json
{
  "skills": ["path/to/dora-skills"]
}
```

#### Manual Usage

You can also browse the `skills/` directory and use the SKILL.md files as reference documentation.

### Available Skills

| Category | Skills | Description |
|----------|--------|-------------|
| Core | `core-development`, `custom-node`, `cli-workflow` | Dataflow building and node development |
| Vision | `object-detection`, `segmentation`, `tracking`, `vlm` | YOLO, SAM2, CoTracker, InternVL |
| Audio | `speech-to-text`, `text-to-speech`, `voice-activity` | Whisper, Kokoro TTS, VAD |
| Robot | `arm-control`, `actuators`, `chassis` | Piper, Dynamixel, Robomaster |
| Data | `recording`, `replay`, `lerobot` | Dataset collection and training |

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
"I want to record demonstrations with a Piper arm"
```

### Dora Quick Start

1. Install dora CLI:
```bash
pip install dora-rs
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
- [Node Hub](https://github.com/dora-rs/dora/tree/main/node-hub)

---

<a name="chinese"></a>
## 中文

### 简介

使用 [dora-rs](https://github.com/dora-rs/dora) 数据流框架构建 AI Agent、工作流和具身智能应用的技能集。

Dora 是一个高性能数据流框架，通过声明式 YAML 管道编排 AI 模型、传感器和执行器。适用于需要实时数据流协调的场景 —— 从多模态 AI Agent 到机器人系统。

**当前重点**: 具身智能 (Embodied Intelligence) —— 融合感知、语言模型与物理控制。

### 安装 Skills

#### Claude Code

```bash
# 克隆仓库
git clone https://github.com/dora-rs/dora-skills.git

# 添加到 Claude Code
claude mcp add ./dora-skills
```

或在 Claude Code 设置中添加：
```json
{
  "skills": ["path/to/dora-skills"]
}
```

#### 手动使用

你也可以直接浏览 `skills/` 目录，将 SKILL.md 文件作为参考文档使用。

### 可用技能

| 类别 | 技能 | 说明 |
|------|------|------|
| 核心 | `core-development`, `custom-node`, `cli-workflow` | 数据流构建和节点开发 |
| 视觉 | `object-detection`, `segmentation`, `tracking`, `vlm` | YOLO, SAM2, CoTracker, InternVL |
| 音频 | `speech-to-text`, `text-to-speech`, `voice-activity` | Whisper, Kokoro TTS, VAD |
| 机器人 | `arm-control`, `actuators`, `chassis` | Piper, Dynamixel, Robomaster |
| 数据 | `recording`, `replay`, `lerobot` | 数据集采集和训练 |

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
"我想用 Piper 机械臂录制演示数据"
```

### Dora 快速开始

1. 安装 dora CLI：
```bash
pip install dora-rs
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
- [节点仓库](https://github.com/dora-rs/dora/tree/main/node-hub)

---

## License

Apache-2.0
