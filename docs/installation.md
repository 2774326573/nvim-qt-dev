# 安装指南

本文档详细介绍如何安装和配置 nvim-qt-dev 插件。

## 📋 系统要求

### 基础要求

- **Neovim**: 0.8.0 或更高版本
- **操作系统**: Windows 10+ 或 Linux (推荐 Ubuntu 20.04+)
- **Git**: 用于插件管理器

### Qt 开发环境

- **Qt**: 5.15+ 或 6.x (推荐 Qt 6.6+)
- **CMake**: 3.20 或更高版本
- **C++ 编译器**:
  - Windows: Visual Studio 2019/2022 或 MinGW
  - Linux: GCC 9+ 或 Clang 12+

### 可选组件

- **clangd**: 用于 LSP 支持 (强烈推荐)
- **Qt Creator**: 可选的 IDE (与插件兼容)

## 🎯 快速安装

### 使用 lazy.nvim (推荐)

在您的 Neovim 配置文件中添加：

```lua
{
  "2774326573/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx", "qml" },
  dependencies = {
    "nvim-lua/plenary.nvim", -- 可选：用于增强功能
  },
  config = function()
    require("qt-dev").setup({
      -- 基础配置
      enabled = true,
      auto_detect = true,
      default_mappings = true,
      
      -- LSP配置
      auto_lsp_config = true,
    })
  end,
}
```

### 使用 packer.nvim

```lua
use {
  "2774326573/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx", "qml" },
  config = function()
    require("qt-dev").setup()
  end
}
```

### 使用 vim-plug

```vim
Plug '2774326573/nvim-qt-dev'

" 在 init.vim 或 init.lua 中配置
lua << EOF
require("qt-dev").setup()
EOF
```

### 手动安装

1. 克隆仓库到 Neovim 插件目录：

```bash
# Linux/macOS
git clone https://github.com/2774326573/nvim-qt-dev.git ~/.local/share/nvim/site/pack/plugins/start/nvim-qt-dev

# Windows
git clone https://github.com/2774326573/nvim-qt-dev.git %LOCALAPPDATA%\nvim\site\pack\plugins\start\nvim-qt-dev
```

2. 重启 Neovim 并运行：

```vim
:lua require("qt-dev").setup()
```

## 🔧 环境配置

### Windows 环境配置

#### 1. 安装 Qt

从 [Qt 官网](https://www.qt.io/download) 下载并安装 Qt：

```bash
# 推荐安装路径
C:\Qt\6.6.0\msvc2022_64
```

#### 2. 安装 Visual Studio

安装 Visual Studio 2019 或 2022，确保包含：
- MSVC 编译器
- Windows SDK
- CMake 工具

#### 3. 安装 clangd

```bash
# 使用 winget
winget install LLVM.LLVM

# 或下载预编译版本
# https://github.com/clangd/clangd/releases
```

#### 4. 环境变量设置

添加到系统 PATH：
```
C:\Qt\6.6.0\msvc2022_64\bin
C:\Program Files\CMake\bin
C:\Program Files\LLVM\bin
```

### Linux 环境配置

#### Ubuntu/Debian

```bash
# 安装 Qt 开发包
sudo apt update
sudo apt install qt6-base-dev qt6-tools-dev cmake build-essential

# 安装 clangd
sudo apt install clangd

# 可选：安装 Qt Creator
sudo apt install qtcreator
```

#### Arch Linux

```bash
# 安装 Qt 和开发工具
sudo pacman -S qt6-base qt6-tools cmake gcc clang

# 安装 clangd
sudo pacman -S clang-tools-extra
```

#### CentOS/RHEL/Fedora

```bash
# Fedora
sudo dnf install qt6-qtbase-devel qt6-qttools-devel cmake gcc-c++ clang-tools-extra

# CentOS/RHEL (需要 EPEL)
sudo yum install epel-release
sudo yum install qt5-qtbase-devel qt5-qttools-devel cmake gcc-c++
```

## ⚙️ 首次配置

### 1. 运行配置向导

安装插件后，首次使用时运行：

```vim
:QtSetup
```

配置向导将引导您完成：
- Qt 安装路径检测
- 编译器选择
- 项目默认设置

### 2. 验证安装

运行健康检查：

```vim
:checkhealth qt-dev
```

检查项目状态：

```vim
:QtStatus
```

### 3. 创建测试项目

```vim
:QtDesktop TestApp
```

## 🎨 IDE 集成

### VS Code 集成

如果您使用 VS Code 中的 Neovim 扩展：

```lua
require("qt-dev").setup({
  vscode_integration = true,
})
```

### 现有项目集成

对于现有的 Qt 项目：

1. 打开项目目录
2. 运行 `:QtStatus` 检查状态
3. 如需要，运行 `:QtBuild` 配置构建

## 🔍 验证安装

### 检查命令

确保以下命令可用：

```bash
# 检查 Qt
qmake --version

# 检查 CMake
cmake --version

# 检查编译器
gcc --version  # Linux
cl            # Windows MSVC

# 检查 clangd
clangd --version
```

### Neovim 中的验证

```vim
" 检查插件是否加载
:lua print(vim.inspect(require("qt-dev").info()))

" 检查环境
:lua require("qt-dev.core.environment").quick_environment_check()

" 显示配置
:QtConfig
```

## 🚨 常见安装问题

### Qt 路径问题

**问题**: 提示找不到 Qt 安装

**解决方案**:
```vim
:QtSetup  " 重新运行配置向导
```

或手动配置：
```lua
require("qt-dev").setup({
  paths = {
    custom_qt_path = "D:/Qt/6.6.0/msvc2022_64"  -- Windows
    -- custom_qt_path = "/usr/lib/qt6"           -- Linux
  }
})
```

### LSP 不工作

**问题**: 代码提示不工作

**解决方案**:
1. 确保 clangd 已安装: `clangd --version`
2. 检查 .clangd 配置: `:QtStatus`
3. 重启 LSP: `:LspRestart`

### 编译错误

**问题**: 项目无法编译

**解决方案**:
1. 检查编译器: `:lua require("qt-dev.core.environment").show_full_environment_report()`
2. 重新配置 CMake: `:QtBuild`
3. 清理并重建: `:QtClean` 然后 `:QtBuild`

## 📚 下一步

安装完成后，请参考：
- [配置文档](configuration.md) - 详细配置选项
- [使用教程](tutorial.md) - 基础使用教程
- [故障排除](troubleshooting.md) - 常见问题解决

## 🆘 获取帮助

如果遇到安装问题：

1. 查看 [故障排除文档](troubleshooting.md)
2. 运行 `:checkhealth qt-dev` 检查状态
3. 在 [GitHub Issues](https://github.com/2774326573/nvim-qt-dev/issues) 提交问题
4. 提供详细的系统信息和错误信息