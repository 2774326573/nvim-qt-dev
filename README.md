# nvim-qt-dev

<div align="center">

🚀 **一个强大的Neovim Qt开发插件，提供完整的Qt项目开发工具链** 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)](https://neovim.io/)
[![Qt](https://img.shields.io/badge/Qt-5.15%2B%20%7C%206.x-blue.svg)](https://www.qt.io/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-lightgrey.svg)]()
[![Stars](https://img.shields.io/github/stars/2774326573/nvim-qt-dev?style=social)](https://github.com/2774326573/nvim-qt-dev/stargazers)

**中文** | [English](README_EN.md)

[🚀 快速开始](#📦-安装) • [📚 文档](#📚-文档) • [🎯 特性](#✨-特性) • [🤝 贡献](#🤝-贡献)

</div>

---

## 📋 目录

- [特性](#✨-特性)
- [安装](#📦-安装)
- [配置](#⚙️-配置)
- [使用方法](#🎯-使用方法)
- [系统要求](#🔧-系统要求)
- [文档](#📚-文档)
- [贡献](#🤝-贡献)
- [许可证](#📄-许可证)

## ✨ 特性

<div align="center">

| 🚀 快速创建 | 🔧 智能配置 | 📝 LSP集成 | 🛠️ 构建工具 |
|:---:|:---:|:---:|:---:|
| 支持多种项目类型 | 自动检测环境 | 完整代码提示 | CMake构建支持 |

| 🎨 Qt Designer | 📱 VS Code兼容 | 🌍 跨平台 | 🔥 活跃维护 |
|:---:|:---:|:---:|:---:|
| 无缝集成设计器 | 完美VS Code支持 | Windows/Linux | 持续更新 |

</div>

### 🎯 核心功能

- 🚀 **快速项目创建** - 支持桌面应用、控制台应用、Web应用、QML应用、库项目
- 🔧 **智能配置** - 自动检测Qt和编译器路径，支持用户自定义配置
- 📝 **LSP集成** - 自动生成.clangd配置和compile_commands.json
- 🛠️ **构建工具** - 内置CMake构建和调试支持
- 🎨 **Qt Designer** - 无缝集成Qt Designer
- 📱 **VS Code兼容** - 支持VS Code环境
- 🌍 **跨平台** - Windows和Linux完美支持

## 📦 安装

> 💡 **提示**: 建议使用 `lazy.nvim` 以获得最佳体验！

<details>
<summary>📋 <strong>lazy.nvim (推荐)</strong></summary>

```lua
{
  "2774326573/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx", "qml" },
  dependencies = {
    "nvim-lua/plenary.nvim", -- 可选：增强功能
  },
  config = function()
    require("qt-dev").setup({
      -- 基本配置
      enabled = true,
      auto_detect = true,
      default_mappings = true,
      
      -- LSP配置
      auto_lsp_config = true,
    })
  end,
}
```
</details>

<details>
<summary>📋 <strong>packer.nvim</strong></summary>

```lua
use {
  "2774326573/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx", "qml" },
  config = function()
    require("qt-dev").setup()
  end
}
```
</details>

<details>
<summary>📋 <strong>vim-plug</strong></summary>

```vim
Plug '2774326573/nvim-qt-dev'
```
</details>

## ⚙️ 配置

<div align="center">

### 🚀 一键配置

```vim
:QtSetup
```

**只需一条命令，自动配置所有环境！**

</div>

---

### 🛠️ 手动配置

<details>
<summary>💡 <strong>点击查看详细配置选项</strong></summary>

创建配置文件 `~/.config/nvim/lua/qt-dev-config.lua`：

```lua
return {
  qt = {
    -- Qt安装路径（根据您的系统修改）
    base_paths = {
      windows = { "D:/Qt", "C:/Qt" },
      linux = { "/usr/lib/qt6", "/opt/Qt" }
    },
    preferred_version = "6.6.0",  -- 您的Qt版本
    preferred_compiler = "msvc2022_64",  -- Windows编译器
  },
  
  tools = {
    auto_generate_compile_commands = true,
    auto_restart_lsp = true,
    preferred_lsp = "clangd",
  }
}
```

📖 完整配置选项请参考 [examples/qt-dev-config.lua](examples/qt-dev-config.lua)

</details>

## 🎯 使用方法

<div align="center">

### ⌨️ 快捷键一览

</div>

| 快捷键 | 功能 | 描述 |
|:------:|:----:|:-----|
| `<leader>qn` | 🆕 创建新Qt项目 | 快速创建各种类型的Qt项目 |
| `<leader>qb` | 🔨 构建项目 | 使用CMake构建当前项目 |
| `<leader>qr` | ▶️ 运行项目 | 编译并运行当前项目 |
| `<leader>qd` | 🎨 打开Qt Designer | 启动Qt设计器 |
| `<leader>qc` | 📝 创建Qt类 | 快速生成Qt类模板 |
| `<leader>qs` | 📊 项目状态检查 | 检查项目配置和环境 |

<div align="center">

### 🖥️ 常用命令

</div>

| 命令 | 功能 | 示例 |
|:-----|:-----|:-----|
| `:QtCreate [名称] [类型]` | 🆕 创建Qt项目 | `:QtCreate MyApp desktop` |
| `:QtDesktop [名称]` | 🖥️ 创建桌面应用 | `:QtDesktop Calculator` |
| `:QtSetup` | ⚙️ 运行配置向导 | 一键配置环境 |
| `:QtConfig` | 📋 显示当前配置 | 查看插件配置 |
| `:QtStatus` | 🔍 检查项目状态 | 诊断项目问题 |

<div align="center">

### 📱 项目类型支持

</div>

| 类型 | 图标 | 描述 | 适用场景 |
|:-----|:----:|:-----|:--------|
| `desktop` | 🖥️ | Qt Widgets桌面应用 | 传统桌面软件 |
| `console` | 🖤 | Qt控制台应用 | 命令行工具 |
| `web` | 🌐 | Qt WebEngine Web应用 | 网页应用 |
| `qml` | ✨ | Qt Quick QML应用 | 现代UI应用 |
| `library` | 📚 | Qt库项目 | 可重用库 |

## 🔧 系统要求

<div align="center">

### 🖥️ 支持平台

[![Windows](https://img.shields.io/badge/Windows-10%2B-blue?logo=windows)](https://www.microsoft.com/windows/)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu%2020.04%2B-orange?logo=linux)](https://ubuntu.com/)

</div>

<table>
<tr>
<td width="50%">

### 🪟 Windows 环境

- **Qt**: 5.15+ 或 Qt 6.x
- **编译器**: Visual Studio 2019/2022 或 MinGW
- **CMake**: 3.20+
- **LSP**: clangd (推荐)

</td>
<td width="50%">

### 🐧 Linux 环境

- **Qt**: qt6-base-dev 或 qt5-default
- **编译器**: GCC 或 Clang
- **CMake**: 3.20+
- **LSP**: clangd (推荐)

</td>
</tr>
</table>

<details>
<summary>🚀 <strong>Ubuntu 快速安装依赖</strong></summary>

```bash
# 一键安装所有依赖
sudo apt update && sudo apt install -y \
  qt6-base-dev \
  qt6-tools-dev \
  cmake \
  clangd \
  build-essential

# 验证安装
qmake --version && cmake --version && clangd --version
```

</details>

## 📚 文档

<div align="center">

### 📖 完整文档导航

**选择您的语言** | **Choose Your Language**

</div>

<table>
<tr>
<td width="50%">

### 🇨🇳 中文文档

- 📦 [安装指南](docs/installation.md) - 详细的安装和配置说明
- ⚙️ [配置文档](docs/configuration.md) - 完整的配置选项
- 🎓 [使用教程](docs/tutorial.md) - 从入门到进阶的使用指南
- 📋 [API参考](docs/api.md) - 完整的API文档
- 🔧 [故障排除](docs/troubleshooting.md) - 常见问题解决方案

</td>
<td width="50%">

### 🇺🇸 English Documentation

- 📦 [Installation Guide](docs/en/installation.md) - Detailed installation instructions
- ⚙️ [Configuration](docs/en/configuration.md) - Complete configuration options
- 🎓 [Tutorial](docs/en/tutorial.md) - Usage guide from basic to advanced
- 📋 [API Reference](docs/en/api.md) - Complete API documentation
- 🔧 [Troubleshooting](docs/en/troubleshooting.md) - Common issues and solutions

</td>
</tr>
</table>

<div align="center">

---

### 📚 推荐阅读顺序

**新手** → [安装指南](docs/installation.md) → [使用教程](docs/tutorial.md) → [配置文档](docs/configuration.md)

**进阶** → [API参考](docs/api.md) → [故障排除](docs/troubleshooting.md)

</div>

## 🤝 贡献

<div align="center">

### 💡 我们欢迎所有形式的贡献！

[![GitHub contributors](https://img.shields.io/github/contributors/2774326573/nvim-qt-dev?style=for-the-badge)](https://github.com/2774326573/nvim-qt-dev/graphs/contributors)

📖 查看我们的 [贡献指南](CONTRIBUTING.md) 了解如何参与项目开发

</div>

<table>
<tr>
<td width="50%">

### 🐛 报告问题

- [创建Issue](https://github.com/2774326573/nvim-qt-dev/issues) 
- 详细描述问题
- 提供复现步骤
- 包含系统信息

</td>
<td width="50%">

### 💡 提出建议

- [讨论区](https://github.com/2774326573/nvim-qt-dev/discussions)
- 功能请求
- 改进建议
- 使用心得

</td>
</tr>
<tr>
<td width="50%">

### 📝 改进文档

- 修正错误
- 添加示例
- 翻译文档
- 提交PR

</td>
<td width="50%">

### 🔧 代码贡献

- Fork项目
- 创建分支
- 提交代码
- 发起PR

</td>
</tr>
</table>

## ⭐ 支持项目

<div align="center">

### 🌟 如果这个插件对您有帮助，请考虑：

[![GitHub stars](https://img.shields.io/github/stars/2774326573/nvim-qt-dev?style=social)](https://github.com/2774326573/nvim-qt-dev/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/2774326573/nvim-qt-dev?style=social)](https://github.com/2774326573/nvim-qt-dev/network/members)

**⭐ 给项目点个星** • **🔄 分享给其他开发者** • **💬 提交反馈建议** • **🤝 参与代码贡献**

</div>

## 📄 许可证

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

本项目采用 **MIT 许可证** - 详情请见 [LICENSE](LICENSE) 文件

*自由使用、修改和分发* 🎉

</div>

## 🙏 致谢

<div align="center">

### 感谢所有让这个项目成为可能的人们 ❤️

</div>

- 🏆 感谢所有 [贡献者](https://github.com/2774326573/nvim-qt-dev/contributors) 的辛勤工作
- 🛠️ 感谢 [Qt](https://www.qt.io/) 社区提供的优秀框架
- 🚀 感谢 [Neovim](https://neovim.io/) 社区的支持和反馈
- 💡 感谢所有用户的宝贵建议和反馈

## 📞 联系我们

<div align="center">

### 🤝 多种方式与我们联系

</div>

<table>
<tr>
<td align="center" width="33%">

### 🐛 问题反馈

[![GitHub Issues](https://img.shields.io/github/issues/2774326573/nvim-qt-dev?style=for-the-badge&logo=github)](https://github.com/2774326573/nvim-qt-dev/issues)

[创建Issue](https://github.com/2774326573/nvim-qt-dev/issues)

</td>
<td align="center" width="33%">

### 💬 社区讨论

[![GitHub Discussions](https://img.shields.io/github/discussions/2774326573/nvim-qt-dev?style=for-the-badge&logo=github)](https://github.com/2774326573/nvim-qt-dev/discussions)

[加入讨论](https://github.com/2774326573/nvim-qt-dev/discussions)

</td>
<td align="center" width="33%">

### 📧 邮件联系

[![Email](https://img.shields.io/badge/Email-jinxinjinqi%40outlook.com-blue?style=for-the-badge&logo=microsoft-outlook)](mailto:jinxinjinqi@outlook.com)

[发送邮件](mailto:jinxinjinqi@outlook.com)

</td>
</tr>
</table>

---

<div align="center">

### 🌟 喜欢这个项目？

**给个 ⭐️ 支持一下吧！您的支持是我们前进的动力！** 🚀

[![GitHub stars](https://img.shields.io/github/stars/2774326573/nvim-qt-dev?style=for-the-badge&logo=github)](https://github.com/2774326573/nvim-qt-dev/stargazers)

**让我们一起打造更好的 Qt 开发体验！** 💪

</div>