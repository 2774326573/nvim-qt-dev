# Troubleshooting

This document helps you resolve common issues when using the nvim-qt-dev plugin.

## 📋 Table of Contents

- [Environment Configuration Issues](#environment-configuration-issues)
- [Qt Installation Issues](#qt-installation-issues)
- [Compiler Issues](#compiler-issues)
- [Build Issues](#build-issues)
- [LSP Issues](#lsp-issues)
- [Plugin Issues](#plugin-issues)
- [Platform-specific Issues](#platform-specific-issues)
- [Performance Issues](#performance-issues)

## 🔧 Environment Configuration Issues

### Issue: Plugin Cannot Find Qt Installation

**Symptoms**:
```
[ERROR] Qt installation not found
[ERROR] Please configure Qt paths manually
```

**Solutions**:

1. **Check Qt installation paths**:
   ```vim
   :QtConfig paths
   ```

2. **Manually configure Qt paths**:
   ```lua
   -- In configuration file
   qt = {
     search_paths = {
       windows = { "D:/Qt", "C:/Qt" },
       linux = { "/usr/lib/qt6", "/opt/Qt", "/usr/local/Qt" }
     }
   }
   ```

3. **Verify Qt installation**:
   ```bash
   # Windows
   dir "C:\Qt"
   
   # Linux
   ls -la /usr/lib/qt6
   which qmake
   ```

4. **Set environment variables**:
   ```bash
   # Windows (PowerShell)
   $env:QTDIR = "C:\Qt\6.6.0\msvc2022_64"
   $env:PATH += ";$env:QTDIR\bin"
   
   # Linux (Bash)
   export QTDIR=/usr/lib/qt6
   export PATH=$QTDIR/bin:$PATH
   ```

### Issue: Compiler Not Found

**Symptoms**:
```
[ERROR] No suitable compiler found
[ERROR] CMake configuration failed
```

**Solutions**:

1. **Windows - Install Visual Studio**:
   - Download Visual Studio 2019/2022
   - Install "Desktop development with C++" workload
   - Or install MinGW-w64

2. **Linux - Install GCC/Clang**:
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install build-essential cmake
   
   # Or install Clang
   sudo apt install clang cmake
   
   # CentOS/RHEL
   sudo yum groupinstall "Development Tools"
   sudo yum install cmake
   ```

3. **Verify compiler**:
   ```bash
   # Check compiler versions
   gcc --version
   clang --version
   cl.exe  # Windows MSVC
   ```

### Issue: CMake Version Too Old

**Symptoms**:
```
CMake Error: CMake 3.20 or higher is required
```

**Solutions**:

1. **Windows - Install latest CMake**:
   - Download from [CMake official website](https://cmake.org/download/)
   - Or use package manager: `winget install cmake`

2. **Linux - Update CMake**:
   ```bash
   # Ubuntu (may need to add PPA)
   sudo apt remove cmake
   sudo apt install snapd
   sudo snap install cmake --classic
   
   # Or compile from source
   wget https://github.com/Kitware/CMake/releases/download/v3.27.0/cmake-3.27.0.tar.gz
   tar -xf cmake-3.27.0.tar.gz
   cd cmake-3.27.0
   ./bootstrap && make && sudo make install
   ```

## 🎯 Qt Installation Issues

### Issue: Incompatible Qt Version

**Symptoms**:
```
[ERROR] Qt version 5.x is not supported for this feature
[WARNING] Consider upgrading to Qt 6.x
```

**Solutions**:

1. **Upgrade to Qt 6.x**:
   - Download Qt 6.6+ from Qt official website
   - Or use online installer

2. **Configure multiple Qt versions**:
   ```lua
   qt = {
     versions = {
       ["6.6.0"] = "C:/Qt/6.6.0/msvc2022_64",
       ["5.15.2"] = "C:/Qt/5.15.2/msvc2022_64"
     },
     preferred_version = "6.6.0"
   }
   ```

3. **Project-specific Qt version**:
   ```cmake
   # Specify in CMakeLists.txt
   find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
   ```

### Issue: Missing Qt Modules

**Symptoms**:
```
[ERROR] Qt module 'WebEngine' not found
[ERROR] Required Qt components are missing
```

**Solutions**:

1. **Install missing modules**:
   ```bash
   # Use Qt Maintenance Tool to reinstall
   # Or manually install specific modules
   
   # Linux package manager
   sudo apt install qt6-webengine-dev
   sudo apt install qt6-multimedia-dev
   ```

2. **Check installed modules**:
   ```bash
   # Linux
   dpkg -l | grep qt6
   
   # Windows - Check Qt installation directory
   dir "C:\Qt\6.6.0\msvc2022_64\lib\cmake"
   ```

## 🏗️ Build Issues

### Issue: Build Failure - Linking Errors

**Symptoms**:
```
[ERROR] undefined reference to Qt symbols
[ERROR] LNK2019: unresolved external symbol
```

**Solutions**:

1. **Check Qt library linking**:
   ```cmake
   # Ensure CMakeLists.txt correctly links Qt
   find_package(Qt6 REQUIRED COMPONENTS Core Widgets)
   target_link_libraries(myapp Qt6::Core Qt6::Widgets)
   ```

2. **Clean and rebuild**:
   ```vim
   :QtClean
   :QtBuild
   ```

3. **Check compiler architecture match**:
   ```bash
   # Ensure Qt and compiler architecture match (x64/x86)
   ```

### Issue: Header Files Not Found

**Symptoms**:
```
[ERROR] fatal error: QApplication: No such file or directory
[ERROR] Cannot find Qt headers
```

**Solutions**:

1. **Check include paths**:
   ```cpp
   // Ensure correct Qt header includes
   #include <QApplication>
   #include <QWidget>
   ```

2. **Verify Qt installation completeness**:
   ```bash
   # Check if header files exist
   # Windows
   dir "C:\Qt\6.6.0\msvc2022_64\include\QtCore"
   
   # Linux
   ls /usr/include/qt6/QtCore
   ```

3. **Regenerate build files**:
   ```vim
   :QtClean
   :QtBuild
   ```

### Issue: Resource Files Not Found

**Symptoms**:
```
[ERROR] RCC: Cannot open resource file
[WARNING] Resource files not embedded
```

**Solutions**:

1. **Check resource file paths**:
   ```xml
   <!-- resources.qrc -->
   <RCC>
     <qresource prefix="/">
       <file>icons/app.png</file>
     </qresource>
   </RCC>
   ```

2. **Verify file existence**:
   ```bash
   # Ensure resource files exist at specified paths
   ls resources/icons/app.png
   ```

3. **Regenerate resources**:
   ```vim
   :QtClean
   :QtBuild
   ```

## 🔍 LSP Issues

### Issue: clangd Cannot Start

**Symptoms**:
```
[ERROR] LSP server clangd is not available
[ERROR] clangd executable not found
```

**Solutions**:

1. **Install clangd**:
   ```bash
   # Windows
   winget install llvm
   
   # Ubuntu
   sudo apt install clangd
   
   # CentOS
   sudo yum install clang-tools-extra
   ```

2. **Configure clangd path**:
   ```lua
   lsp = {
     clangd = {
       cmd = { "/usr/bin/clangd", "--background-index" },
       -- or Windows: "C:/Program Files/LLVM/bin/clangd.exe"
     }
   }
   ```

3. **Restart LSP**:
   ```vim
   :QtLspRestart
   :LspInfo
   ```

### Issue: compile_commands.json Not Generated

**Symptoms**:
```
[WARNING] compile_commands.json not found
[ERROR] clangd cannot find compilation database
```

**Solutions**:

1. **Enable compilation database generation**:
   ```lua
   build = {
     generate_compile_commands = true
   }
   ```

2. **Generate manually**:
   ```bash
   cd your_project
   cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
   ```

3. **Check CMake version**:
   ```bash
   # CMake 3.5+ supports compilation database export
   cmake --version
   ```

### Issue: Poor LSP Performance

**Symptoms**:
- Slow code completion
- Delayed go-to-definition
- High CPU usage

**Solutions**:

1. **Optimize clangd configuration**:
   ```lua
   lsp = {
     clangd = {
       cmd = { 
         "clangd",
         "--background-index=false",  -- Disable background indexing
         "--clang-tidy=false",        -- Disable clang-tidy
         "--completion-style=bundled" -- Use bundled completion
       }
     }
   }
   ```

2. **Limit indexing scope**:
   ```yaml
   # .clangd file
   CompileFlags:
     Remove: [-W*, -std=*]
   Index:
     Background: Skip
   ```

## 🐛 Plugin Issues

### Issue: Commands Not Recognized

**Symptoms**:
```
[ERROR] Not an editor command: QtCreate
[ERROR] Unknown command
```

**Solutions**:

1. **Check if plugin is loaded**:
   ```vim
   :echo has_key(g:, 'loaded_qt_dev')
   ```

2. **Reload plugin**:
   ```vim
   :source ~/.config/nvim/init.lua
   " or
   :PackerSync  " if using Packer
   :Lazy reload qt-dev  " if using Lazy
   ```

3. **Check plugin configuration**:
   ```lua
   -- Ensure proper configuration and setup call
   require("qt-dev").setup()
   ```

### Issue: Keybindings Not Working

**Symptoms**:
- `<leader>qn` and other keybindings not responding
- Keybindings overridden by other plugins

**Solutions**:

1. **Check leader key**:
   ```vim
   :echo mapleader
   ```

2. **Manually set keybindings**:
   ```lua
   -- Explicitly set in configuration
   vim.keymap.set('n', '<leader>qn', ':QtCreate<CR>')
   vim.keymap.set('n', '<leader>qb', ':QtBuild<CR>')
   ```

3. **Check keymap conflicts**:
   ```vim
   :verbose map <leader>qn
   ```

### Issue: Slow Plugin Loading

**Symptoms**:
- Neovim startup becomes slow
- Plugin response delays

**Solutions**:

1. **Enable lazy loading**:
   ```lua
   {
     "2774326573/nvim-qt-dev",
     ft = { "cpp", "c", "h", "hpp" },  -- Load only in C++ files
     cmd = { "QtCreate", "QtBuild" },  -- Or lazy load by command
   }
   ```

2. **Optimize configuration**:
   ```lua
   qt_dev.setup({
     auto_detect = false,  -- Disable auto-detection
     lazy_load_tools = true  -- Lazy load tools
   })
   ```

## 💻 Platform-specific Issues

### Windows Issues

#### Issue: Incorrect Path Separators

**Symptoms**:
```
[ERROR] Invalid path format
[ERROR] Cannot find file with Unix-style path
```

**Solutions**:
```lua
-- Use correct path separators
qt = {
  search_paths = {
    windows = { "C:\\Qt", "D:\\Qt" }  -- Use backslashes
  }
}
```

#### Issue: PowerShell Execution Policy

**Symptoms**:
```
[ERROR] Execution of scripts is disabled on this system
```

**Solutions**:
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Linux Issues

#### Issue: Insufficient Permissions

**Symptoms**:
```
[ERROR] Permission denied
[ERROR] Cannot write to /usr/local/bin
```

**Solutions**:
```bash
# Use user directory for installation
mkdir -p ~/.local/bin
export PATH=$HOME/.local/bin:$PATH

# Or use sudo for system-level components
sudo apt install qt6-base-dev
```

#### Issue: Shared Libraries Not Found

**Symptoms**:
```
[ERROR] error while loading shared libraries: libQt6Core.so.6
```

**Solutions**:
```bash
# Add Qt library path to LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib/qt6/lib:$LD_LIBRARY_PATH

# Or create symbolic links
sudo ldconfig
```

## ⚡ Performance Issues

### Issue: Slow Build Speed

**Solutions**:

1. **Enable parallel building**:
   ```lua
   build = {
     parallel = true,
     jobs = 8  -- Adjust based on CPU cores
   }
   ```

2. **Use ninja build system**:
   ```cmake
   # In CMakeLists.txt
   set(CMAKE_GENERATOR "Ninja")
   ```

3. **Enable precompiled headers**:
   ```cmake
   target_precompile_headers(myapp PRIVATE 
     <QtWidgets/QApplication>
     <QtWidgets/QWidget>
   )
   ```

### Issue: High Memory Usage

**Solutions**:

1. **Limit parallel jobs**:
   ```lua
   build = {
     jobs = 2  -- Reduce number of parallel jobs
   }
   ```

2. **Optimize compilation options**:
   ```cmake
   # Reduce debug information
   set(CMAKE_CXX_FLAGS_DEBUG "-g1 -O0")
   ```

## 🆘 Getting Help

### Collect Diagnostic Information

```vim
:QtStatus         " Check environment status
:checkhealth qt-dev  " Run health check
:LspInfo         " Check LSP status
:messages        " View error messages
```

### Enable Debug Logging

```lua
require("qt-dev").setup({
  debug = true,
  log_level = "DEBUG"
})
```

### Submit Bug Reports

When submitting bugs, please include:

1. **System Information**:
   - Operating system version
   - Neovim version
   - Qt version
   - Compiler version

2. **Configuration Information**:
   - Plugin configuration
   - Relevant Neovim configuration

3. **Error Information**:
   - Complete error messages
   - Reproduction steps
   - `:QtStatus` output

4. **Minimal Reproduction Example**:
   - Simplest reproduction steps
   - Sample project files

### Community Resources

- **GitHub Issues**: Report bugs and request features
- **GitHub Discussions**: Ask questions and discuss
- **Qt Community**: Qt-related technical questions

---

If none of the above solutions resolve your issue, please submit a detailed bug report on GitHub.
