# nvim-qt-dev

A powerful Neovim Qt development plugin that provides a complete Qt project development toolchain.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)](https://neovim.io/)

[中文文档](README.md) | **English**

## ✨ Features

- 🚀 **Quick Project Creation** - Support for desktop apps, console apps, web apps, QML apps, library projects
- 🔧 **Smart Configuration** - Auto-detect Qt and compiler paths, support for custom user configuration
- 📝 **LSP Integration** - Auto-generate .clangd config and compile_commands.json
- 🛠️ **Build Tools** - Built-in CMake build and debug support
- 🎨 **Qt Designer** - Seamless Qt Designer integration
- 📱 **VS Code Compatible** - Support for VS Code environment
- 🌍 **Cross-platform** - Perfect support for Windows and Linux

## 📦 Installation

### lazy.nvim (Recommended)

```lua
{
  "2774326573/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx" },
  config = function()
    require("qt-dev").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "2774326573/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx" },
  config = function()
    require("qt-dev").setup()
  end,
}
```

### vim-plug

```vim
Plug '2774326573/nvim-qt-dev'
```

## ⚙️ Configuration

### Quick Start

Run the configuration wizard after installation:

```vim
:QtSetup
```

### Manual Configuration

Create configuration file `~/.config/nvim/lua/qt-dev-config.lua`:

```lua
return {
  qt = {
    -- Qt installation paths (modify according to your system)
    base_paths = {
      windows = { "D:/Qt", "C:/Qt" },
      linux = { "/usr/lib/qt6", "/opt/Qt" }
    },
    preferred_version = "6.6.0",  -- Your Qt version
    preferred_compiler = "msvc2022_64",  -- Windows compiler
  },
  
  tools = {
    auto_generate_compile_commands = true,
    auto_restart_lsp = true,
    preferred_lsp = "clangd",
  }
}
```

For complete configuration options, see [examples/qt-dev-config.lua](examples/qt-dev-config.lua)

## 🎯 Usage

### Keybindings

| Keybinding | Function |
|------------|----------|
| `<leader>qn` | Create new Qt project |
| `<leader>qb` | Build project |
| `<leader>qr` | Run project |
| `<leader>qd` | Open Qt Designer |
| `<leader>qc` | Create Qt class |
| `<leader>qs` | Project status check |

### Commands

| Command | Function |
|---------|----------|
| `:QtCreate [name] [type]` | Create Qt project |
| `:QtDesktop [name]` | Create desktop app |
| `:QtSetup` | Run configuration wizard |
| `:QtConfig` | Show current configuration |
| `:QtStatus` | Check project status |

### Project Types

- `desktop` - Qt Widgets desktop application
- `console` - Qt console application  
- `web` - Qt WebEngine web application
- `qml` - Qt Quick QML application
- `library` - Qt library project

## 🔧 System Requirements

### Windows
- Qt 5.15+ or Qt 6.x
- Visual Studio 2019/2022 or MinGW
- CMake 3.20+
- clangd

### Linux
- qt6-base-dev or qt5-default
- GCC or Clang
- CMake 3.20+
- clangd

### Install Dependencies (Ubuntu)
```bash
sudo apt install qt6-base-dev cmake clangd
```

## 📚 Documentation

- [Installation Guide](docs/en/installation.md)
- [Configuration Documentation](docs/en/configuration.md)  
- [Tutorial](docs/en/tutorial.md)
- [API Reference](docs/en/api.md)
- [Troubleshooting](docs/en/troubleshooting.md)

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING_EN.md](CONTRIBUTING_EN.md)

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

## 🙏 Acknowledgments

Thanks to all contributors and the Qt community for their support!

---

If this plugin helps you, please give it a ⭐️!
