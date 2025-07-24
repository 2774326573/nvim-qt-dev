# API Reference

This document comprehensively lists all APIs, commands, and functions of the nvim-qt-dev plugin.

## 📋 Table of Contents

- [Vim Commands](#vim-commands)
- [Lua API](#lua-api)
- [Configuration API](#configuration-api)
- [Events and Callbacks](#events-and-callbacks)
- [Utility Functions](#utility-functions)
- [Extension API](#extension-api)

## 🎯 Vim Commands

### Project Management Commands

#### `:QtCreate [name] [type]`
Create a new Qt project.

**Parameters**:
- `name` (optional): Project name, defaults to current directory name
- `type` (optional): Project type, options:
  - `desktop` - Qt Widgets desktop application (default)
  - `console` - Console application
  - `web` - Qt WebEngine application
  - `qml` - Qt Quick application
  - `library` - Library project

**Examples**:
```vim
:QtCreate MyApp desktop
:QtCreate Calculator
:QtCreate MyLib library
```

#### `:QtDesktop [name]`
Quickly create Qt Widgets desktop application.

**Parameters**:
- `name` (optional): Project name

**Examples**:
```vim
:QtDesktop Calculator
```

#### `:QtConsole [name]`
Quickly create Qt console application.

#### `:QtQml [name]`
Quickly create Qt Quick QML application.

#### `:QtLibrary [name]`
Quickly create Qt library project.

### Class and File Management

#### `:QtClass [name] [type]`
Create a new Qt class.

**Parameters**:
- `name`: Class name
- `type` (optional): Class type
  - `widget` - QWidget derived class (default)
  - `dialog` - QDialog derived class
  - `mainwindow` - QMainWindow derived class
  - `object` - QObject derived class
  - `plain` - Plain C++ class

**Examples**:
```vim
:QtClass MyWidget widget
:QtClass MyDialog dialog
:QtClass MyModel object
```

#### `:QtHeader [name]`
Create header file.

#### `:QtSource [name]`
Create source file.

#### `:QtUI [name]`
Create UI file and open in Qt Designer.

### Build and Run

#### `:QtBuild [config]`
Build project.

**Parameters**:
- `config` (optional): Build configuration
  - `Debug` (default)
  - `Release`
  - `RelWithDebInfo`
  - `MinSizeRel`

**Examples**:
```vim
:QtBuild
:QtBuild Release
:QtBuild Debug
```

#### `:QtRun [args]`
Run project.

**Parameters**:
- `args` (optional): Command line arguments

#### `:QtClean`
Clean build files.

#### `:QtRebuild [config]`
Rebuild project (equivalent to `:QtClean` + `:QtBuild`).

### Tool Integration

#### `:QtDesigner [file]`
Open Qt Designer.

**Parameters**:
- `file` (optional): UI file path to open

#### `:QtAssistant`
Open Qt Assistant help documentation.

#### `:QtLinguist [file]`
Open Qt Linguist translation tool.

### Configuration and Status

#### `:QtSetup`
Run configuration wizard.

#### `:QtConfig [section]`
Show or edit configuration.

**Parameters**:
- `section` (optional): Configuration section
  - `qt` - Qt environment configuration
  - `build` - Build configuration
  - `tools` - Tools configuration
  - `paths` - Path configuration

**Examples**:
```vim
:QtConfig          " Show all configuration
:QtConfig qt       " Show Qt configuration
:QtConfig paths    " Show path configuration
```

#### `:QtStatus`
Check project and environment status.

#### `:QtVersion`
Show Qt version information.

### LSP and Development Tools

#### `:QtLspRestart`
Restart LSP server.

#### `:QtLspStatus`
Show LSP status.

#### `:QtFormat`
Format current file or selection.

#### `:QtInclude [header]`
Add header file include.

### Debugging and Analysis

#### `:QtDebug [args]`
Run project in debug mode.

#### `:QtProfile [args]`
Run project in performance analysis mode.

#### `:QtTest [test]`
Run tests.

**Parameters**:
- `test` (optional): Specific test name

### Deployment

#### `:QtDeploy [target]`
Deploy application.

**Parameters**:
- `target` (optional): Deployment target
  - `windows` - Windows deployment
  - `linux` - Linux deployment
  - `android` - Android deployment
  - `ios` - iOS deployment

## 🔧 Lua API

### Core Module

#### `require("qt-dev")`
Main module providing core plugin functionality.

```lua
local qt_dev = require("qt-dev")

-- Setup plugin
qt_dev.setup(config)

-- Check if current project is Qt project
local is_qt = qt_dev.is_qt_project()

-- Get current project information
local project = qt_dev.get_current_project()
```

### Project Management

#### `qt_dev.core.detection`

```lua
local detection = require("qt-dev.core.detection")

-- Detect Qt project type
local project_type = detection.detect_project_type()

-- Detect build directory
local build_dir = detection.detect_build_directory()

-- Detect project root directory
local project_root = detection.detect_project_root()

-- Check if it's a Qt project
local is_qt = detection.is_qt_project()
```

#### `qt_dev.core.environment`

```lua
local env = require("qt-dev.core.environment")

-- Detect Qt installations
local qt_paths = env.detect_qt_installations()

-- Detect compilers
local compilers = env.detect_compilers()

-- Get system information
local system = env.get_system_info()

-- Validate environment
local valid, errors = env.validate_environment()
```

### Build System

#### `qt_dev.tools.build`

```lua
local build = require("qt-dev.tools.build")

-- Configure CMake build
build.configure_cmake()

-- Build project
build.build_project({
  config = "Release",
  parallel = true,
  jobs = 4
})

-- Run project
build.run_project({
  args = {"--debug"},
  working_dir = "/path/to/project"
})

-- Clean build files
build.clean_build()

-- Check build status
local status = build.get_build_status()
```

### Template System

#### `qt_dev.templates`

```lua
local templates = require("qt-dev.templates")

-- Create class files
templates.create_class({
  name = "MyWidget",
  type = "widget",
  namespace = "MyNamespace",
  include_ui = true
})

-- Create project template
templates.create_project({
  name = "MyProject",
  template = "desktop",
  options = {
    with_tests = true,
    with_resources = true
  }
})

-- Get available templates
local available = templates.get_available()

-- Register custom template
templates.register("custom", {
  name = "Custom Template",
  files = {
    ["main.cpp"] = template_content
  }
})
```

### Tool Integration

#### `qt_dev.tools.designer`

```lua
local designer = require("qt-dev.tools.designer")

-- Check if Qt Designer is available
local available = designer.is_designer_available()

-- Open Qt Designer
designer.open_designer("mainwindow.ui")

-- Create and open new UI file
designer.create_and_open_ui("newwindow")
```

#### `qt_dev.tools.status`

```lua
local status = require("qt-dev.tools.status")

-- Get environment status
local env_status = status.get_environment_status()

-- Get project status
local project_status = status.get_project_status()

-- Show complete status report
status.show_status_report()
```

### Environment Detection

#### `qt_dev.core.environment`

```lua
local env = require("qt-dev.core.environment")

-- Detect Qt installations
local qt_paths = env.detect_qt()

-- Detect compilers
local compilers = env.detect_compilers()

-- Get system information
local system = env.get_system_info()

-- Validate environment
local valid, errors = env.validate()
```

## ⚙️ Configuration API

### Basic Configuration

```lua
require("qt-dev").setup({
  -- Enable/disable plugin
  enabled = true,
  
  -- Auto-detect Qt projects
  auto_detect = true,
  
  -- Default keybindings
  default_mappings = true,
  
  -- Notification level
  notify_level = vim.log.levels.INFO,
  
  -- Auto LSP configuration
  auto_lsp_config = true,
  
  -- VS Code integration mode
  vscode_mode = false,
})
```

### User Configuration File

Create `~/.config/nvim/lua/qt-dev-config.lua`:

```lua
return {
  -- Qt installation configuration
  qt = {
    -- Qt installation base paths
    base_paths = {
      windows = {
        "D:/Qt",  -- Your Qt installation path
        "C:/Qt",
        "C:/Program Files/Qt",
      },
      linux = {
        "/usr/lib/qt6",
        "/opt/Qt",
        "/usr/local/qt6",
      }
    },
    -- Preferred Qt version
    preferred_version = "6.6.0",
    -- Preferred compiler (Windows)
    preferred_compiler = "msvc2022_64",
  },
  
  -- Compiler configuration
  compiler = {
    -- MSVC installation paths (Windows)
    msvc_paths = {
      "C:/Program Files/Microsoft Visual Studio",
      "C:/Program Files (x86)/Microsoft Visual Studio",
    },
    -- Preferred MSVC version
    preferred_msvc_version = "2022",
  },
  
  -- Project template configuration
  templates = {
    -- Default project type
    default_project_type = "desktop",
    -- Default C++ standard
    default_cpp_standard = "17",
  },
  
  -- Development tools configuration
  tools = {
    -- LSP configuration
    auto_generate_compile_commands = true,
    auto_restart_lsp = true,
    preferred_lsp = "clangd",
    
    -- Qt Designer configuration
    auto_open_ui_files = true,
    designer_on_ui_create = true,
  }
}
```

### Advanced Configuration

```lua
-- Custom templates
templates = {
  my_widget = {
    name = "My Widget Template",
    description = "Custom widget class template",
    files = {
      ["{name}.h"] = function(context)
        return render_template("widget_header", context)
      end,
      ["{name}.cpp"] = "widget_source_template"
    }
  }
}

-- Custom keybindings
keymaps = {
  ["<leader>qn"] = "QtCreate",
  ["<leader>qb"] = "QtBuild",
  ["<leader>qr"] = "QtRun",
  ["<leader>qd"] = "QtDesigner",
  ["<leader>qc"] = "QtClass",
  ["<leader>qs"] = "QtStatus"
}

-- Custom hooks
hooks = {
  before_build = function(project)
    -- Execute before build
  end,
  
  after_build = function(project, success)
    -- Execute after build
  end,
  
  project_created = function(project)
    -- Execute after project creation
  end
}
```

## 📡 Events and Callbacks

### Event Types

#### `QtProjectCreated`
Triggered when project is created.

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "QtProjectCreated",
  callback = function(args)
    local project = args.data
    print("Project created: " .. project.name)
  end
})
```

#### `QtBuildStarted`
Triggered when build starts.

#### `QtBuildCompleted`
Triggered when build completes.

#### `QtBuildFailed`
Triggered when build fails.

#### `QtRunStarted`
Triggered when run starts.

#### `QtClassCreated`
Triggered when class is created.

### Callback Functions

```lua
local qt_dev = require("qt-dev")

-- Register event listeners
qt_dev.on("project_created", function(project)
  -- Handle project creation event
end)

qt_dev.on("build_completed", function(result)
  if result.success then
    print("Build successful!")
  else
    print("Build failed: " .. result.error)
  end
end)
```

## 🛠️ Utility Functions

### Path Utilities

```lua
local utils = require("qt-dev.core.utils")

-- Normalize path
local normalized = utils.path.normalize("/path/to/file")

-- Relative path
local relative = utils.path.relative("/base/path", "/base/path/sub/file")

-- Check file existence
local exists = utils.path.exists("/path/to/file")

-- Create directory
utils.path.mkdir("/path/to/dir")
```

### String Utilities

```lua
-- Template rendering
local rendered = utils.string.template("Hello {name}!", {name = "World"})

-- Case conversions
local camel = utils.string.to_camel_case("my_variable")
local snake = utils.string.to_snake_case("MyVariable")
local pascal = utils.string.to_pascal_case("my_variable")
```

### System Utilities

```lua
-- Execute command
local result = utils.system.execute("cmake --version")

-- Check executable existence
local exists = utils.system.executable_exists("cmake")

-- Get environment variable
local path = utils.system.getenv("PATH")
```

## 🔌 Extension API

### Custom Project Types

```lua
local qt_dev = require("qt-dev")

-- Register custom project type
qt_dev.register_project_type("my_app", {
  name = "My Application Type",
  description = "Custom application type",
  
  -- Detection function
  detect = function(path)
    return utils.path.exists(path .. "/my_app.json")
  end,
  
  -- Creation function
  create = function(options)
    -- Project creation logic
  end,
  
  -- Build function
  build = function(config)
    -- Custom build logic
  end
})
```

### Custom Tools

```lua
-- Register custom tool
qt_dev.register_tool("my_tool", {
  name = "My Tool",
  executable = "mytool",
  
  -- Tool commands
  commands = {
    process = function(args)
      return utils.system.execute("mytool process " .. table.concat(args, " "))
    end
  }
})
```

### Custom LSP Configuration

```lua
-- Extend LSP configuration
qt_dev.extend_lsp_config("clangd", {
  init_options = {
    clangdFileStatus = true,
    usePlaceholders = true,
    completeUnimported = true
  }
})
```

## 📊 Type Definitions

### Project Type

```lua
---@class Project
---@field name string Project name
---@field path string Project path
---@field type string Project type
---@field qt_version string Qt version
---@field build_config string Build configuration
---@field files table Project file list
```

### BuildResult Type

```lua
---@class BuildResult
---@field success boolean Whether build was successful
---@field error string? Error message
---@field output string Build output
---@field duration number Build duration (seconds)
```

### ToolInfo Type

```lua
---@class ToolInfo
---@field name string Tool name
---@field version string? Tool version
---@field path string Executable file path
---@field available boolean Whether available
```

---

For more detailed information, please refer to the type definitions and documentation comments in the source code.
