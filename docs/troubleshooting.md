# 故障排除

本文档帮助您解决使用 nvim-qt-dev 插件时可能遇到的常见问题。

## 📋 目录

- [环境配置问题](#环境配置问题)
- [Qt安装问题](#qt安装问题)
- [编译器问题](#编译器问题)
- [构建问题](#构建问题)
- [LSP问题](#lsp问题)
- [插件问题](#插件问题)
- [平台特定问题](#平台特定问题)
- [性能问题](#性能问题)

## 🔧 环境配置问题

### 问题: 插件无法找到Qt安装

**症状**:
```
[ERROR] Qt installation not found
[ERROR] Please configure Qt paths manually
```

**解决方案**:

1. **检查Qt安装路径**:
   ```vim
   :QtConfig paths
   ```

2. **手动配置Qt路径**:
   ```lua
   -- 在配置文件中
   qt = {
     search_paths = {
       windows = { "D:/Qt", "C:/Qt" },
       linux = { "/usr/lib/qt6", "/opt/Qt", "/usr/local/Qt" }
     }
   }
   ```

3. **验证Qt安装**:
   ```bash
   # Windows
   dir "C:\Qt"
   
   # Linux
   ls -la /usr/lib/qt6
   which qmake
   ```

4. **设置环境变量**:
   ```bash
   # Windows (PowerShell)
   $env:QTDIR = "C:\Qt\6.6.0\msvc2022_64"
   $env:PATH += ";$env:QTDIR\bin"
   
   # Linux (Bash)
   export QTDIR=/usr/lib/qt6
   export PATH=$QTDIR/bin:$PATH
   ```

### 问题: 编译器未找到

**症状**:
```
[ERROR] No suitable compiler found
[ERROR] CMake configuration failed
```

**解决方案**:

1. **Windows - 安装Visual Studio**:
   - 下载Visual Studio 2019/2022
   - 安装"C++桌面开发"工作负载
   - 或安装MinGW-w64

2. **Linux - 安装GCC/Clang**:
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install build-essential cmake
   
   # 或安装Clang
   sudo apt install clang cmake
   
   # CentOS/RHEL
   sudo yum groupinstall "Development Tools"
   sudo yum install cmake
   ```

3. **验证编译器**:
   ```bash
   # 检查编译器版本
   gcc --version
   clang --version
   cl.exe  # Windows MSVC
   ```

### 问题: CMake版本过低

**症状**:
```
CMake Error: CMake 3.20 or higher is required
```

**解决方案**:

1. **Windows - 安装最新CMake**:
   - 从 [CMake官网](https://cmake.org/download/) 下载
   - 或使用包管理器: `winget install cmake`

2. **Linux - 更新CMake**:
   ```bash
   # Ubuntu (可能需要添加PPA)
   sudo apt remove cmake
   sudo apt install snapd
   sudo snap install cmake --classic
   
   # 或从源码编译
   wget https://github.com/Kitware/CMake/releases/download/v3.27.0/cmake-3.27.0.tar.gz
   tar -xf cmake-3.27.0.tar.gz
   cd cmake-3.27.0
   ./bootstrap && make && sudo make install
   ```

## 🎯 Qt安装问题

### 问题: Qt版本不兼容

**症状**:
```
[ERROR] Qt version 5.x is not supported for this feature
[WARNING] Consider upgrading to Qt 6.x
```

**解决方案**:

1. **升级到Qt 6.x**:
   - 从Qt官网下载Qt 6.6+
   - 或使用在线安装器

2. **配置多Qt版本**:
   ```lua
   qt = {
     versions = {
       ["6.6.0"] = "C:/Qt/6.6.0/msvc2022_64",
       ["5.15.2"] = "C:/Qt/5.15.2/msvc2022_64"
     },
     preferred_version = "6.6.0"
   }
   ```

3. **项目特定Qt版本**:
   ```cmake
   # 在CMakeLists.txt中指定
   find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
   ```

### 问题: Qt模块缺失

**症状**:
```
[ERROR] Qt module 'WebEngine' not found
[ERROR] Required Qt components are missing
```

**解决方案**:

1. **安装缺失模块**:
   ```bash
   # 使用Qt维护工具重新安装
   # 或手动安装特定模块
   
   # Linux包管理器
   sudo apt install qt6-webengine-dev
   sudo apt install qt6-multimedia-dev
   ```

2. **检查已安装模块**:
   ```bash
   # Linux
   dpkg -l | grep qt6
   
   # Windows - 检查Qt安装目录
   dir "C:\Qt\6.6.0\msvc2022_64\lib\cmake"
   ```

## 🏗️ 构建问题

### 问题: 构建失败 - 链接错误

**症状**:
```
[ERROR] undefined reference to Qt symbols
[ERROR] LNK2019: unresolved external symbol
```

**解决方案**:

1. **检查Qt库链接**:
   ```cmake
   # 确保CMakeLists.txt正确链接Qt
   find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
   target_link_libraries(myapp Qt6::Core Qt6::Widgets)
   ```

2. **清理重新构建**:
   ```vim
   :QtClean
   :QtBuild
   ```

3. **检查编译器架构匹配**:
   ```bash
   # 确保Qt和编译器架构一致 (x64/x86)
   ```

### 问题: 找不到头文件

**症状**:
```
[ERROR] fatal error: QApplication: No such file or directory
[ERROR] Cannot find Qt headers
```

**解决方案**:

1. **检查include路径**:
   ```cpp
   // 确保正确包含Qt头文件
   #include <QApplication>
   #include <QWidget>
   ```

2. **验证Qt安装完整性**:
   ```bash
   # 检查头文件是否存在
   # Windows
   dir "C:\Qt\6.6.0\msvc2022_64\include\QtCore"
   
   # Linux
   ls /usr/include/qt6/QtCore
   ```

3. **重新生成构建文件**:
   ```vim
   :QtClean
   :QtBuild
   ```

### 问题: 资源文件未找到

**症状**:
```
[ERROR] RCC: Cannot open resource file
[WARNING] Resource files not embedded
```

**解决方案**:

1. **检查资源文件路径**:
   ```xml
   <!-- resources.qrc -->
   <RCC>
     <qresource prefix="/">
       <file>icons/app.png</file>
     </qresource>
   </RCC>
   ```

2. **验证文件存在**:
   ```bash
   # 确保资源文件存在于指定路径
   ls resources/icons/app.png
   ```

3. **重新生成资源**:
   ```vim
   :QtClean
   :QtBuild
   ```

## 🔍 LSP问题

### 问题: clangd无法启动

**症状**:
```
[ERROR] LSP server clangd is not available
[ERROR] clangd executable not found
```

**解决方案**:

1. **安装clangd**:
   ```bash
   # Windows
   winget install llvm
   
   # Ubuntu
   sudo apt install clangd
   
   # CentOS
   sudo yum install clang-tools-extra
   ```

2. **配置clangd路径**:
   ```lua
   lsp = {
     clangd = {
       cmd = { "/usr/bin/clangd", "--background-index" },
       -- 或 Windows: "C:/Program Files/LLVM/bin/clangd.exe"
     }
   }
   ```

3. **重启LSP**:
   ```vim
   :QtLspRestart
   :LspInfo
   ```

### 问题: compile_commands.json未生成

**症状**:
```
[WARNING] compile_commands.json not found
[ERROR] clangd cannot find compilation database
```

**解决方案**:

1. **启用编译数据库生成**:
   ```lua
   build = {
     generate_compile_commands = true
   }
   ```

2. **手动生成**:
   ```bash
   cd your_project
   cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
   ```

3. **检查CMake版本**:
   ```bash
   # CMake 3.5+ 支持编译数据库导出
   cmake --version
   ```

### 问题: LSP性能差

**症状**:
- 代码补全很慢
- 跳转到定义延迟
- 高CPU使用率

**解决方案**:

1. **优化clangd配置**:
   ```lua
   lsp = {
     clangd = {
       cmd = { 
         "clangd",
         "--background-index=false",  -- 禁用后台索引
         "--clang-tidy=false",        -- 禁用clang-tidy
         "--completion-style=bundled" -- 使用打包补全
       }
     }
   }
   ```

2. **限制索引范围**:
   ```yaml
   # .clangd 文件
   CompileFlags:
     Remove: [-W*, -std=*]
   Index:
     Background: Skip
   ```

## 🐛 插件问题

### 问题: 命令无法识别

**症状**:
```
[ERROR] Not an editor command: QtCreate
[ERROR] Unknown command
```

**解决方案**:

1. **检查插件是否加载**:
   ```vim
   :echo has_key(g:, 'loaded_qt_dev')
   ```

2. **重新加载插件**:
   ```vim
   :source ~/.config/nvim/init.lua
   " 或
   :PackerSync  " 如果使用Packer
   :Lazy reload qt-dev  " 如果使用Lazy
   ```

3. **检查插件配置**:
   ```lua
   -- 确保正确配置和调用setup
   require("qt-dev").setup()
   ```

### 问题: 快捷键不工作

**症状**:
- `<leader>qn` 等快捷键无响应
- 快捷键被其他插件覆盖

**解决方案**:

1. **检查leader键**:
   ```vim
   :echo mapleader
   ```

2. **手动设置快捷键**:
   ```lua
   -- 在配置中明确设置
   vim.keymap.set('n', '<leader>qn', ':QtCreate<CR>')
   vim.keymap.set('n', '<leader>qb', ':QtBuild<CR>')
   ```

3. **检查键映射冲突**:
   ```vim
   :verbose map <leader>qn
   ```

### 问题: 插件加载缓慢

**症状**:
- Neovim启动变慢
- 插件响应延迟

**解决方案**:

1. **启用懒加载**:
   ```lua  {
    "2774326573/nvim-qt-dev",
    ft = { "cpp", "c", "h", "hpp" },  -- 仅在C++文件中加载
     cmd = { "QtCreate", "QtBuild" },  -- 或按命令懒加载
   }
   ```

2. **优化配置**:
   ```lua
   qt_dev.setup({
     auto_detect = false,  -- 禁用自动检测
     lazy_load_tools = true  -- 懒加载工具
   })
   ```

## 💻 平台特定问题

### Windows问题

#### 问题: 路径分隔符错误

**症状**:
```
[ERROR] Invalid path format
[ERROR] Cannot find file with Unix-style path
```

**解决方案**:
```lua
-- 使用正确的路径分隔符
qt = {
  search_paths = {
    windows = { "C:\\Qt", "D:\\Qt" }  -- 使用反斜杠
  }
}
```

#### 问题: PowerShell执行策略

**症状**:
```
[ERROR] Execution of scripts is disabled on this system
```

**解决方案**:
```powershell
# 以管理员身份运行PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Linux问题

#### 问题: 权限不足

**症状**:
```
[ERROR] Permission denied
[ERROR] Cannot write to /usr/local/bin
```

**解决方案**:
```bash
# 使用用户目录安装
mkdir -p ~/.local/bin
export PATH=$HOME/.local/bin:$PATH

# 或使用sudo安装系统级组件
sudo apt install qt6-base-dev
```

#### 问题: 动态库找不到

**症状**:
```
[ERROR] error while loading shared libraries: libQt6Core.so.6
```

**解决方案**:
```bash
# 添加Qt库路径到LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib/qt6/lib:$LD_LIBRARY_PATH

# 或创建符号链接
sudo ldconfig
```

## ⚡ 性能问题

### 问题: 构建速度慢

**解决方案**:

1. **启用并行构建**:
   ```lua
   build = {
     parallel = true,
     jobs = 8  -- 根据CPU核心数调整
   }
   ```

2. **使用ninja构建系统**:
   ```cmake
   # 在CMakeLists.txt中
   set(CMAKE_GENERATOR "Ninja")
   ```

3. **启用预编译头**:
   ```cmake
   target_precompile_headers(myapp PRIVATE 
     <QtWidgets/QApplication>
     <QtWidgets/QWidget>
   )
   ```

### 问题: 内存使用过高

**解决方案**:

1. **限制并行作业**:
   ```lua
   build = {
     jobs = 2  -- 减少并行作业数
   }
   ```

2. **优化编译选项**:
   ```cmake
   # 减少调试信息
   set(CMAKE_CXX_FLAGS_DEBUG "-g1 -O0")
   ```

## 🆘 获取帮助

### 收集诊断信息

```vim
:QtStatus         " 检查环境状态
:checkhealth qt-dev  " 运行健康检查
:LspInfo         " 检查LSP状态
:messages        " 查看错误消息
```

### 启用调试日志

```lua
require("qt-dev").setup({
  debug = true,
  log_level = "DEBUG"
})
```

### 提交Bug报告

提交Bug时请包含以下信息:

1. **系统信息**:
   - 操作系统版本
   - Neovim版本
   - Qt版本
   - 编译器版本

2. **配置信息**:
   - 插件配置
   - 相关的Neovim配置

3. **错误信息**:
   - 完整的错误消息
   - 复现步骤
   - `:QtStatus` 输出

4. **最小重现示例**:
   - 最简单的重现步骤
   - 示例项目文件

### 社区资源

- **GitHub Issues**: 报告Bug和请求功能
- **GitHub Discussions**: 提问和讨论
- **Qt社区**: Qt相关的技术问题

---

如果以上解决方案都无法解决您的问题，请在GitHub上提交详细的问题报告。
