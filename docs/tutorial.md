# 使用教程

本教程将带您从零开始使用 nvim-qt-dev 插件开发 Qt 应用程序。

## 📋 目录

- [快速开始](#快速开始)
- [创建第一个Qt项目](#创建第一个qt项目)
- [项目结构](#项目结构)
- [编写代码](#编写代码)
- [构建和运行](#构建和运行)
- [使用Qt Designer](#使用qt-designer)
- [调试项目](#调试项目)
- [高级功能](#高级功能)

## 🚀 快速开始

### 步骤 1: 初始化配置

首次使用插件时，请运行配置向导：

```vim
:QtSetup
```

这将引导您完成基础配置，包括：
- Qt安装路径检测
- 编译器选择
- LSP配置

### 步骤 2: 检查环境

确认环境配置正确：

```vim
:QtStatus
```

## 🏗️ 创建第一个Qt项目

### 桌面应用程序

创建一个简单的Qt Widgets桌面应用：

```vim
:QtDesktop MyFirstApp
```

或使用快捷键：
```vim
<leader>qn  " 然后选择 desktop 类型
```

### 项目类型说明

| 类型 | 描述 | 适用场景 |
|------|------|----------|
| `desktop` | Qt Widgets桌面应用 | 传统桌面软件 |
| `console` | 控制台应用 | 命令行工具 |
| `web` | Qt WebEngine应用 | 混合Web应用 |
| `qml` | Qt Quick应用 | 现代UI应用 |
| `library` | 静态/动态库 | 可复用组件 |

## 📁 项目结构

插件创建的典型Qt项目结构：

```
MyFirstApp/
├── CMakeLists.txt          # CMake构建文件
├── .clangd                 # clangd配置文件
├── compile_commands.json   # 编译数据库
├── src/                    # 源代码目录
│   ├── main.cpp           # 主入口文件
│   ├── mainwindow.cpp     # 主窗口实现
│   └── mainwindow.h       # 主窗口声明
├── ui/                     # UI文件目录
│   └── mainwindow.ui      # Qt Designer文件
├── resources/              # 资源文件
│   └── resources.qrc      # 资源配置文件
└── build/                  # 构建输出目录
```

## ✍️ 编写代码

### 添加新的Qt类

使用命令创建新类：

```vim
:QtClass MyWidget
```

或使用快捷键：
```vim
<leader>qc  " 创建Qt类
```

这会生成：
- `mywidget.h` - 头文件
- `mywidget.cpp` - 实现文件
- 如果是Widget类，还会创建 `mywidget.ui`

### 代码示例

创建一个简单的计算器窗口：

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

### LSP 功能

插件自动配置了 clangd LSP，提供：

- **代码补全**: 自动完成Qt类和方法
- **错误检查**: 实时语法和语义错误检查
- **转到定义**: `gd` 跳转到定义
- **查找引用**: `gr` 查找所有引用
- **重命名**: `<leader>rn` 重命名符号

## 🔨 构建和运行

### 构建项目

```vim
:QtBuild
```

或使用快捷键：
```vim
<leader>qb  " 构建项目
```

### 运行项目

```vim
:QtRun
```

或使用快捷键：
```vim
<leader>qr  " 运行项目
```

### 构建配置

支持多种构建模式：

```vim
:QtBuild Debug      " 调试版本
:QtBuild Release    " 发布版本
:QtBuild RelWithDebInfo  " 带调试信息的发布版本
```

## 🎨 使用Qt Designer

### 打开Designer

```vim
:QtDesigner
```

或使用快捷键：
```vim
<leader>qd  " 打开Qt Designer
```

### 工作流程

1. **创建UI文件**: 插件会自动为Widget类创建`.ui`文件
2. **设计界面**: 在Qt Designer中设计UI
3. **保存文件**: 保存`.ui`文件
4. **自动生成**: 插件会自动生成对应的头文件

### UI文件集成

```cpp
// 在类构造函数中
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    
    // 连接信号和槽
    connect(ui->pushButton, &QPushButton::clicked, 
            this, &MainWindow::onButtonClicked);
}
```

## 🐛 调试项目

### 设置断点

使用Neovim的调试功能：

1. 安装DAP插件（如nvim-dap）
2. 配置C++调试器
3. 设置断点并开始调试

### 插件调试支持

```vim
:QtDebug        " 以调试模式启动
:QtProfile      " 性能分析模式
```

### 常用调试技巧

- 使用 `qDebug()` 输出调试信息
- 启用Qt的调试模式：`QT_DEBUG_OUTPUT=1`
- 使用Qt Creator的调试工具

## ⚡ 高级功能

### 项目模板自定义

创建自定义项目模板：

```lua
-- 在配置文件中
templates = {
  custom_app = {
    name = "自定义应用",
    description = "我的自定义Qt应用模板",
    files = {
      ["main.cpp"] = "custom_main_template",
      ["app.h"] = "custom_header_template",
    }
  }
}
```

### 多项目工作区

在工作区中管理多个Qt项目：

```vim
:QtWorkspace add /path/to/project1
:QtWorkspace add /path/to/project2
:QtWorkspace list
:QtWorkspace switch project1
```

### 自动化构建

设置自动构建触发器：

```lua
-- 配置文件中
build = {
  auto_build_on_save = true,
  auto_test_on_build = true,
  parallel_jobs = 4,
}
```

### 集成外部工具

配置外部工具集成：

```vim
:QtTool qmake          " 运行qmake
:QtTool lupdate        " 更新翻译文件
:QtTool lrelease       " 生成翻译文件
:QtTool windeployqt    " Windows部署工具
```

## 📱 移动开发

### Android开发

配置Android开发环境：

```lua
android = {
  sdk_path = "/path/to/android-sdk",
  ndk_path = "/path/to/android-ndk",
  target_api = 30,
}
```

创建Android项目：

```vim
:QtAndroid MyMobileApp
```

### iOS开发

在macOS上开发iOS应用：

```vim
:QtIOS MyIOSApp
```

## 🔧 故障排除快速参考

### 常见问题

1. **Qt路径未找到**
   ```vim
   :QtConfig paths    " 检查Qt路径配置
   ```

2. **编译失败**
   ```vim
   :QtStatus         " 检查项目状态
   :QtClean          " 清理构建缓存
   ```

3. **LSP不工作**
   ```vim
   :LspInfo          " 检查LSP状态
   :QtLspRestart     " 重启LSP服务器
   ```

## 📚 下一步

- 查看 [API参考](api.md) 了解所有可用命令
- 阅读 [配置文档](configuration.md) 进行高级配置
- 遇到问题请查看 [故障排除](troubleshooting.md)

---

更多示例和教程请访问项目的 `examples/` 目录。
