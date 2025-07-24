# nvim-qt-dev

一个强大的Neovim Qt开发插件，提供完整的Qt项目开发工具链。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)](https://neovim.io/)

## ✨ 特性

- 🚀 **快速项目创建** - 支持桌面应用、控制台应用、Web应用、QML应用、库项目
- 🔧 **智能配置** - 自动检测Qt和编译器路径，支持用户自定义配置
- 📝 **LSP集成** - 自动生成.clangd配置和compile_commands.json
- 🛠️ **构建工具** - 内置CMake构建和调试支持
- 🎨 **Qt Designer** - 无缝集成Qt Designer
- 📱 **VS Code兼容** - 支持VS Code环境
- 🌍 **跨平台** - Windows和Linux完美支持

## 📦 安装

### lazy.nvim (推荐)

```lua
{
  "your-username/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx" },
  config = function()
    require("qt-dev").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "your-username/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx" },
  config = function()
    require("qt-dev").setup()
  end,
}
```

### vim-plug

```vim
Plug 'your-username/nvim-qt-dev'
```

## ⚙️ 配置

### 快速开始

安装后运行配置向导：

```vim
:QtSetup
```

### 手动配置

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

完整配置选项请参考 [examples/qt-dev-config.lua](examples/qt-dev-config.lua)

## 🎯 使用方法

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| `<leader>qn` | 创建新Qt项目 |
| `<leader>qb` | 构建项目 |
| `<leader>qr` | 运行项目 |
| `<leader>qd` | 打开Qt Designer |
| `<leader>qc` | 创建Qt类 |
| `<leader>qs` | 项目状态检查 |

### 命令

| 命令 | 功能 |
|------|------|
| `:QtCreate [名称] [类型]` | 创建Qt项目 |
| `:QtDesktop [名称]` | 创建桌面应用 |
| `:QtSetup` | 运行配置向导 |
| `:QtConfig` | 显示当前配置 |
| `:QtStatus` | 检查项目状态 |

### 项目类型

- `desktop` - Qt Widgets桌面应用
- `console` - Qt控制台应用  
- `web` - Qt WebEngine Web应用
- `qml` - Qt Quick QML应用
- `library` - Qt库项目

## 🔧 系统要求

### Windows
- Qt 5.15+ 或 Qt 6.x
- Visual Studio 2019/2022 或 MinGW
- CMake 3.20+
- clangd

### Linux
- qt6-base-dev 或 qt5-default
- GCC 或 Clang
- CMake 3.20+
- clangd

### 安装依赖 (Ubuntu)
```bash
sudo apt install qt6-base-dev cmake clangd
```

## 📚 文档

- [安装指南](docs/installation.md)
- [配置文档](docs/configuration.md)  
- [使用教程](docs/tutorial.md)
- [API参考](docs/api.md)
- [故障排除](docs/troubleshooting.md)

## 🤝 贡献

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md)

## 📄 许可证

MIT License - 详情请见 [LICENSE](LICENSE)

## 🙏 致谢

感谢所有贡献者和Qt社区的支持！

---

如果这个插件对您有帮助，请给个⭐️支持一下！