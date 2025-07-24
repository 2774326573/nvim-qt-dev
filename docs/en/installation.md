# Installation Guide

This document provides detailed instructions for installing and configuring the nvim-qt-dev plugin.

## 📋 System Requirements

### Basic Requirements

- **Neovim**: 0.8.0 or higher
- **Operating System**: Windows 10+ or Linux (Ubuntu 20.04+ recommended)
- **Git**: For plugin managers

### Qt Development Environment

- **Qt**: 5.15+ or 6.x (Qt 6.6+ recommended)
- **CMake**: 3.20 or higher
- **C++ Compiler**:
  - Windows: Visual Studio 2019/2022 or MinGW
  - Linux: GCC 9+ or Clang 12+

### Optional Components

- **clangd**: For LSP support (strongly recommended)
- **Qt Creator**: Optional IDE (compatible with the plugin)

## 🎯 Quick Installation

### Using lazy.nvim (Recommended)

Add to your Neovim configuration file:

```lua
{
  "2774326573/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx", "qml" },
  dependencies = {
    "nvim-lua/plenary.nvim", -- Optional: for enhanced functionality
  },
  config = function()
    require("qt-dev").setup({
      -- Basic configuration
      enabled = true,
      auto_detect = true,
      default_mappings = true,
      
      -- LSP configuration
      auto_lsp_config = true,
    })
  end,
}
```

### Using packer.nvim

```lua
use {
  "2774326573/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx", "qml" },
  config = function()
    require("qt-dev").setup()
  end
}
```

### Using vim-plug

```vim
Plug '2774326573/nvim-qt-dev'

" Configure in init.vim or init.lua
lua << EOF
require("qt-dev").setup()
EOF
```

### Manual Installation

1. Clone the repository to Neovim plugin directory:

```bash
# Linux/macOS
git clone https://github.com/2774326573/nvim-qt-dev.git ~/.local/share/nvim/site/pack/plugins/start/nvim-qt-dev

# Windows
git clone https://github.com/2774326573/nvim-qt-dev.git %LOCALAPPDATA%\nvim\site\pack\plugins\start\nvim-qt-dev
```

2. Restart Neovim and run:

```vim
:lua require("qt-dev").setup()
```

## 🔧 Environment Configuration

### Windows Environment Setup

#### 1. Install Qt

Download and install Qt from [Qt Official Website](https://www.qt.io/download):

```bash
# Recommended installation path
C:\Qt\6.6.0\msvc2022_64
```

#### 2. Install Visual Studio

Install Visual Studio 2019 or 2022, ensure it includes:
- MSVC compiler
- Windows SDK
- CMake tools

#### 3. Install clangd

```bash
# Using winget
winget install LLVM.LLVM

# Or download pre-compiled version
# https://github.com/clangd/clangd/releases
```

#### 4. Environment Variables

Add to system PATH:
```
C:\Qt\6.6.0\msvc2022_64\bin
C:\Program Files\CMake\bin
C:\Program Files\LLVM\bin
```

### Linux Environment Setup

#### Ubuntu/Debian

```bash
# Install Qt development packages
sudo apt update
sudo apt install qt6-base-dev qt6-tools-dev cmake build-essential

# Install clangd
sudo apt install clangd

# Optional: Install Qt Creator
sudo apt install qtcreator
```

#### Arch Linux

```bash
# Install Qt and development tools
sudo pacman -S qt6-base qt6-tools cmake gcc clang

# Install clangd
sudo pacman -S clang-tools-extra
```

#### CentOS/RHEL/Fedora

```bash
# Fedora
sudo dnf install qt6-qtbase-devel qt6-qttools-devel cmake gcc-c++ clang-tools-extra

# CentOS/RHEL (requires EPEL)
sudo yum install epel-release
sudo yum install qt5-qtbase-devel qt5-qttools-devel cmake gcc-c++
```

## ⚙️ Initial Configuration

### 1. Run Configuration Wizard

After installing the plugin, run for first-time use:

```vim
:QtSetup
```

The configuration wizard will guide you through:
- Qt installation path detection
- Compiler selection
- Project default settings

### 2. Verify Installation

Run health check:

```vim
:checkhealth qt-dev
```

Check project status:

```vim
:QtStatus
```

### 3. Create Test Project

```vim
:QtDesktop TestApp
```

## 🎨 IDE Integration

### VS Code Integration

If you use Neovim extension in VS Code:

```lua
require("qt-dev").setup({
  vscode_integration = true,
})
```

### Existing Project Integration

For existing Qt projects:

1. Open project directory
2. Run `:QtStatus` to check status
3. If needed, run `:QtBuild` to configure build

## 🔍 Installation Verification

### Check Commands

Ensure the following commands are available:

```bash
# Check Qt
qmake --version

# Check CMake
cmake --version

# Check compiler
gcc --version  # Linux
cl            # Windows MSVC

# Check clangd
clangd --version
```

### Verification in Neovim

```vim
" Check if plugin is loaded
:lua print(vim.inspect(require("qt-dev").info()))

" Check environment
:lua require("qt-dev.core.environment").quick_environment_check()

" Show configuration
:QtConfig
```

## 🚨 Common Installation Issues

### Qt Path Issues

**Problem**: Qt installation not found

**Solution**:
```vim
:QtSetup  " Re-run configuration wizard
```

Or configure manually:
```lua
require("qt-dev").setup({
  paths = {
    custom_qt_path = "D:/Qt/6.6.0/msvc2022_64"  -- Windows
    -- custom_qt_path = "/usr/lib/qt6"           -- Linux
  }
})
```

### LSP Not Working

**Problem**: Code completion not working

**Solution**:
1. Ensure clangd is installed: `clangd --version`
2. Check .clangd configuration: `:QtStatus`
3. Restart LSP: `:LspRestart`

### Compilation Errors

**Problem**: Project cannot compile

**Solution**:
1. Check compiler: `:lua require("qt-dev.core.environment").show_full_environment_report()`
2. Reconfigure CMake: `:QtBuild`
3. Clean and rebuild: `:QtClean` then `:QtBuild`

## 📚 Next Steps

After installation is complete, please refer to:
- [Configuration Documentation](configuration.md) - Detailed configuration options
- [Tutorial](tutorial.md) - Basic usage tutorial
- [Troubleshooting](troubleshooting.md) - Common problem solutions

## 🆘 Getting Help

If you encounter installation issues:

1. Check [Troubleshooting Documentation](troubleshooting.md)
2. Run `:checkhealth qt-dev` to check status
3. Submit issues at [GitHub Issues](https://github.com/2774326573/nvim-qt-dev/issues)
4. Provide detailed system information and error messages

---

If you have any questions, feel free to create an Issue or Discussion on GitHub. We're happy to help you get started!
