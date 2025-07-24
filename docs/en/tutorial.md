# Tutorial

This tutorial will guide you through using the nvim-qt-dev plugin to develop Qt applications from scratch.

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Creating Your First Qt Project](#creating-your-first-qt-project)
- [Project Structure](#project-structure)
- [Writing Code](#writing-code)
- [Building and Running](#building-and-running)
- [Using Qt Designer](#using-qt-designer)
- [Debugging Projects](#debugging-projects)
- [Advanced Features](#advanced-features)

## 🚀 Quick Start

### Step 1: Initialize Configuration

When using the plugin for the first time, run the configuration wizard:

```vim
:QtSetup
```

This will guide you through basic configuration including:
- Qt installation path detection
- Compiler selection
- LSP configuration

### Step 2: Check Environment

Confirm that the environment is configured correctly:

```vim
:QtStatus
```

## 🏗️ Creating Your First Qt Project

### Desktop Application

Create a simple Qt Widgets desktop application:

```vim
:QtDesktop MyFirstApp
```

Or use the keybinding:
```vim
<leader>qn  " Then select desktop type
```

### Project Type Overview

| Type | Description | Use Case |
|------|-------------|----------|
| `desktop` | Qt Widgets desktop app | Traditional desktop software |
| `console` | Console application | Command-line tools |
| `web` | Qt WebEngine app | Hybrid web applications |
| `qml` | Qt Quick application | Modern UI applications |
| `library` | Static/dynamic library | Reusable components |

## 📁 Project Structure

Typical Qt project structure created by the plugin:

```
MyFirstApp/
├── CMakeLists.txt          # CMake build file
├── .clangd                 # clangd configuration file
├── compile_commands.json   # Compilation database
├── src/                    # Source code directory
│   ├── main.cpp           # Main entry file
│   ├── mainwindow.cpp     # Main window implementation
│   └── mainwindow.h       # Main window declaration
├── ui/                     # UI files directory
│   └── mainwindow.ui      # Qt Designer file
├── resources/              # Resource files
│   └── resources.qrc      # Resource configuration file
└── build/                  # Build output directory
```

## ✍️ Writing Code

### Adding New Qt Classes

Create new classes using commands:

```vim
:QtClass MyWidget
```

Or use the keybinding:
```vim
<leader>qc  " Create Qt class
```

This generates:
- `mywidget.h` - Header file
- `mywidget.cpp` - Implementation file
- `mywidget.ui` - UI file (if it's a Widget class)

### Code Example

Create a simple calculator window:

**mainwindow.h**
```cpp
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QLineEdit>
#include <QPushButton>
#include <QGridLayout>

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void digitClicked();
    void operatorClicked();
    void equalClicked();
    void clearClicked();

private:
    void setupUI();
    
    QLineEdit *display;
    QWidget *centralWidget;
    QGridLayout *layout;
    double currentValue;
    QString currentOperator;
    bool waitingForOperand;
};

#endif // MAINWINDOW_H
```

### LSP Features

The plugin automatically configures clangd LSP, providing:

- **Code Completion**: Auto-complete Qt classes and methods
- **Error Checking**: Real-time syntax and semantic error checking
- **Go to Definition**: `gd` to jump to definition
- **Find References**: `gr` to find all references
- **Rename**: `<leader>rn` to rename symbols

## 🔨 Building and Running

### Build Project

```vim
:QtBuild
```

Or use the keybinding:
```vim
<leader>qb  " Build project
```

### Run Project

```vim
:QtRun
```

Or use the keybinding:
```vim
<leader>qr  " Run project
```

### Build Configurations

Support for multiple build modes:

```vim
:QtBuild Debug      " Debug build
:QtBuild Release    " Release build
:QtBuild RelWithDebInfo  " Release with debug info
```

## 🎨 Using Qt Designer

### Open Designer

```vim
:QtDesigner
```

Or use the keybinding:
```vim
<leader>qd  " Open Qt Designer
```

### Workflow

1. **Create UI Files**: Plugin automatically creates `.ui` files for Widget classes
2. **Design Interface**: Design UI in Qt Designer
3. **Save Files**: Save `.ui` files
4. **Auto-generation**: Plugin automatically generates corresponding header files

### UI File Integration

```cpp
// In class constructor
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    
    // Connect signals and slots
    connect(ui->pushButton, &QPushButton::clicked, 
            this, &MainWindow::onButtonClicked);
}
```

## 🐛 Debugging Projects

### Setting Breakpoints

Use Neovim's debugging features:

1. Install DAP plugin (such as nvim-dap)
2. Configure C++ debugger
3. Set breakpoints and start debugging

### Plugin Debug Support

```vim
:QtDebug        " Start in debug mode
:QtProfile      " Performance analysis mode
```

### Common Debugging Tips

- Use `qDebug()` for debug output
- Enable Qt debug mode: `QT_DEBUG_OUTPUT=1`
- Use Qt Creator's debugging tools

## ⚡ Advanced Features

### Custom Project Templates

Create custom project templates:

```lua
-- In configuration file
templates = {
  custom_app = {
    name = "Custom Application",
    description = "My custom Qt application template",
    files = {
      ["main.cpp"] = "custom_main_template",
      ["app.h"] = "custom_header_template",
    }
  }
}
```

### Multi-project Workspace

Manage multiple Qt projects in workspace:

```vim
:QtWorkspace add /path/to/project1
:QtWorkspace add /path/to/project2
:QtWorkspace list
:QtWorkspace switch project1
```

### Automated Building

Set up automated build triggers:

```lua
-- In configuration file
build = {
  auto_build_on_save = true,
  auto_test_on_build = true,
  parallel_jobs = 4,
}
```

### External Tool Integration

Configure external tool integration:

```vim
:QtTool qmake          " Run qmake
:QtTool lupdate        " Update translation files
:QtTool lrelease       " Generate translation files
:QtTool windeployqt    " Windows deployment tool
```

## 📱 Mobile Development

### Android Development

Configure Android development environment:

```lua
android = {
  sdk_path = "/path/to/android-sdk",
  ndk_path = "/path/to/android-ndk",
  target_api = 30,
}
```

Create Android project:

```vim
:QtAndroid MyMobileApp
```

### iOS Development

Develop iOS applications on macOS:

```vim
:QtIOS MyIOSApp
```

## 🔧 Quick Troubleshooting Reference

### Common Issues

1. **Qt Path Not Found**
   ```vim
   :QtConfig paths    " Check Qt path configuration
   ```

2. **Build Failures**
   ```vim
   :QtStatus         " Check project status
   :QtClean          " Clean build cache
   ```

3. **LSP Not Working**
   ```vim
   :LspInfo          " Check LSP status
   :QtLspRestart     " Restart LSP server
   ```

## 📚 Next Steps

- Check [API Reference](api.md) for all available commands
- Read [Configuration Documentation](configuration.md) for advanced configuration
- See [Troubleshooting](troubleshooting.md) if you encounter issues

---

For more examples and tutorials, visit the project's `examples/` directory.
