# API参考

本文档详细列出了 nvim-qt-dev 插件的所有API、命令和函数。

## 📋 目录

- [Vim命令](#vim命令)
- [Lua API](#lua-api)
- [配置API](#配置api)
- [事件和回调](#事件和回调)
- [工具函数](#工具函数)
- [扩展API](#扩展api)

## 🎯 Vim命令

### 项目管理命令

#### `:QtCreate [name] [type]`
创建新的Qt项目。

**参数**:
- `name` (可选): 项目名称，默认为当前目录名
- `type` (可选): 项目类型，可选值：
  - `desktop` - Qt Widgets桌面应用 (默认)
  - `console` - 控制台应用
  - `web` - Qt WebEngine应用
  - `qml` - Qt Quick应用
  - `library` - 库项目

**示例**:
```vim
:QtCreate MyApp desktop
:QtCreate Calculator
:QtCreate MyLib library
```

#### `:QtDesktop [name]`
快速创建Qt Widgets桌面应用。

**参数**:
- `name` (可选): 项目名称

**示例**:
```vim
:QtDesktop Calculator
```

#### `:QtConsole [name]`
快速创建Qt控制台应用。

#### `:QtQml [name]`
快速创建Qt Quick QML应用。

#### `:QtLibrary [name]`
快速创建Qt库项目。

### 类和文件管理

#### `:QtClass [name] [type]`
创建新的Qt类。

**参数**:
- `name`: 类名
- `type` (可选): 类类型
  - `widget` - QWidget派生类 (默认)
  - `dialog` - QDialog派生类
  - `mainwindow` - QMainWindow派生类
  - `object` - QObject派生类
  - `plain` - 普通C++类

**示例**:
```vim
:QtClass MyWidget widget
:QtClass MyDialog dialog
:QtClass MyModel object
```

#### `:QtHeader [name]`
创建头文件。

#### `:QtSource [name]`
创建源文件。

#### `:QtUI [name]`
创建UI文件并在Qt Designer中打开。

### 构建和运行

#### `:QtBuild [config]`
构建项目。

**参数**:
- `config` (可选): 构建配置
  - `Debug` (默认)
  - `Release`
  - `RelWithDebInfo`
  - `MinSizeRel`

**示例**:
```vim
:QtBuild
:QtBuild Release
:QtBuild Debug
```

#### `:QtRun [args]`
运行项目。

**参数**:
- `args` (可选): 命令行参数

#### `:QtClean`
清理构建文件。

#### `:QtRebuild [config]`
重新构建项目（等同于 `:QtClean` + `:QtBuild`）。

### 工具集成

#### `:QtDesigner [file]`
打开Qt Designer。

**参数**:
- `file` (可选): 要打开的UI文件路径

#### `:QtAssistant`
打开Qt Assistant帮助文档。

#### `:QtLinguist [file]`
打开Qt Linguist翻译工具。

### 配置和状态

#### `:QtSetup`
运行配置向导。

#### `:QtConfig [section]`
显示或编辑配置。

**参数**:
- `section` (可选): 配置节
  - `qt` - Qt环境配置
  - `build` - 构建配置
  - `tools` - 工具配置
  - `paths` - 路径配置

**示例**:
```vim
:QtConfig          " 显示所有配置
:QtConfig qt       " 显示Qt配置
:QtConfig paths    " 显示路径配置
```

#### `:QtStatus`
检查项目和环境状态。

#### `:QtVersion`
显示Qt版本信息。

### LSP和开发工具

#### `:QtLspRestart`
重启LSP服务器。

#### `:QtLspStatus`
显示LSP状态。

#### `:QtFormat`
格式化当前文件或选中内容。

#### `:QtInclude [header]`
添加头文件包含。

### 调试和分析

#### `:QtDebug [args]`
以调试模式运行项目。

#### `:QtProfile [args]`
以性能分析模式运行项目。

#### `:QtTest [test]`
运行测试。

**参数**:
- `test` (可选): 特定测试名称

### 部署

#### `:QtDeploy [target]`
部署应用程序。

**参数**:
- `target` (可选): 部署目标
  - `windows` - Windows部署
  - `linux` - Linux部署
  - `android` - Android部署
  - `ios` - iOS部署

## 🔧 Lua API

### 核心模块

#### `require("qt-dev")`
主模块，提供插件的核心功能。

```lua
local qt_dev = require("qt-dev")

-- 设置插件
qt_dev.setup(config)

-- 检查是否为Qt项目
local is_qt = qt_dev.is_qt_project()

-- 获取当前项目信息
local project = qt_dev.get_current_project()
```

### 项目管理

#### `qt_dev.core.detection`

```lua
local detection = require("qt-dev.core.detection")

-- 检测Qt项目类型
local project_type = detection.detect_project_type()

-- 检测构建目录
local build_dir = detection.detect_build_directory()

-- 检测项目根目录
local project_root = detection.detect_project_root()

-- 检查是否为Qt项目
local is_qt = detection.is_qt_project()
```

#### `qt_dev.core.environment`

```lua
local env = require("qt-dev.core.environment")

-- 检测Qt安装
local qt_paths = env.detect_qt_installations()

-- 检测编译器
local compilers = env.detect_compilers()

-- 获取系统信息
local system = env.get_system_info()

-- 验证环境
local valid, errors = env.validate_environment()
```

### 构建系统

#### `qt_dev.tools.build`

```lua
local build = require("qt-dev.tools.build")

-- 配置CMake构建
build.configure_cmake()

-- 构建项目
build.build_project({
  config = "Release",
  parallel = true,
  jobs = 4
})

-- 运行项目
build.run_project({
  args = {"--debug"},
  working_dir = "/path/to/project"
})

-- 清理构建文件
build.clean_build()

-- 检查构建状态
local status = build.get_build_status()
```

### 模板系统

#### `qt_dev.templates`

```lua
local templates = require("qt-dev.templates")

-- 创建类文件
templates.create_class({
  name = "MyWidget",
  type = "widget",
  namespace = "MyNamespace",
  include_ui = true
})

-- 创建项目模板
templates.create_project({
  name = "MyProject",
  template = "desktop",
  options = {
    with_tests = true,
    with_resources = true
  }
})

-- 获取可用模板
local available = templates.get_available()

-- 注册自定义模板
templates.register("custom", {
  name = "自定义模板",
  files = {
    ["main.cpp"] = template_content
  }
})
```

### 工具集成

#### `qt_dev.tools.designer`

```lua
local designer = require("qt-dev.tools.designer")

-- 检查Qt Designer是否可用
local available = designer.is_designer_available()

-- 打开Qt Designer
designer.open_designer("mainwindow.ui")

-- 创建并打开新的UI文件
designer.create_and_open_ui("newwindow")
```

#### `qt_dev.tools.status`

```lua
local status = require("qt-dev.tools.status")

-- 获取环境状态
local env_status = status.get_environment_status()

-- 获取项目状态
local project_status = status.get_project_status()

-- 显示完整状态报告
status.show_status_report()
```

### 环境检测

#### `qt_dev.environment`

```lua
local env = require("qt-dev.core.environment")

-- 检测Qt安装
local qt_paths = env.detect_qt()

-- 检测编译器
local compilers = env.detect_compilers()

-- 获取系统信息
local system = env.get_system_info()

-- 验证环境
local valid, errors = env.validate()
```

## ⚙️ 配置API

### 基础配置

```lua
require("qt-dev").setup({
  -- 启用/禁用插件
  enabled = true,
  
  -- 自动检测Qt项目
  auto_detect = true,
  
  -- 默认快捷键
  default_mappings = true,
  
  -- 通知级别
  notify_level = vim.log.levels.INFO,
  
  -- LSP自动配置
  auto_lsp_config = true,
  
  -- VS Code集成模式
  vscode_mode = false,
})
```

### 用户配置文件

创建 `~/.config/nvim/lua/qt-dev-config.lua`：

```lua
return {
  -- Qt安装配置
  qt = {
    -- Qt安装基础路径
    base_paths = {
      windows = {
        "D:/Qt",  -- 您的Qt安装路径
        "C:/Qt",
        "C:/Program Files/Qt",
      },
      linux = {
        "/usr/lib/qt6",
        "/opt/Qt",
        "/usr/local/qt6",
      }
    },
    -- 首选Qt版本
    preferred_version = "6.6.0",
    -- 首选编译器 (Windows)
    preferred_compiler = "msvc2022_64",
  },
  
  -- 编译器配置
  compiler = {
    -- MSVC安装路径 (Windows)
    msvc_paths = {
      "C:/Program Files/Microsoft Visual Studio",
      "C:/Program Files (x86)/Microsoft Visual Studio",
    },
    -- 首选MSVC版本
    preferred_msvc_version = "2022",
  },
  
  -- 项目模板配置
  templates = {
    -- 默认项目类型
    default_project_type = "desktop",
    -- 默认C++标准
    default_cpp_standard = "17",
  },
  
  -- 开发工具配置
  tools = {
    -- LSP配置
    auto_generate_compile_commands = true,
    auto_restart_lsp = true,
    preferred_lsp = "clangd",
    
    -- Qt Designer配置
    auto_open_ui_files = true,
    designer_on_ui_create = true,
  }
}
```

### 高级配置

```lua
-- 自定义模板
templates = {
  my_widget = {
    name = "我的Widget模板",
    description = "自定义Widget类模板",
    files = {
      ["{name}.h"] = function(context)
        return render_template("widget_header", context)
      end,
      ["{name}.cpp"] = "widget_source_template"
    }
  }
}

-- 自定义快捷键
keymaps = {
  ["<leader>qn"] = "QtCreate",
  ["<leader>qb"] = "QtBuild",
  ["<leader>qr"] = "QtRun",
  ["<leader>qd"] = "QtDesigner",
  ["<leader>qc"] = "QtClass",
  ["<leader>qs"] = "QtStatus"
}

-- 自定义钩子
hooks = {
  before_build = function(project)
    -- 构建前执行
  end,
  
  after_build = function(project, success)
    -- 构建后执行
  end,
  
  project_created = function(project)
    -- 项目创建后执行
  end
}
```

## 📡 事件和回调

### 事件类型

#### `QtProjectCreated`
项目创建时触发。

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "QtProjectCreated",
  callback = function(args)
    local project = args.data
    print("项目创建: " .. project.name)
  end
})
```

#### `QtBuildStarted`
构建开始时触发。

#### `QtBuildCompleted`
构建完成时触发。

#### `QtBuildFailed`
构建失败时触发。

#### `QtRunStarted`
运行开始时触发。

#### `QtClassCreated`
类创建时触发。

### 回调函数

```lua
local qt_dev = require("qt-dev")

-- 注册事件监听器
qt_dev.on("project_created", function(project)
  -- 处理项目创建事件
end)

qt_dev.on("build_completed", function(result)
  if result.success then
    print("构建成功!")
  else
    print("构建失败: " .. result.error)
  end
end)
```

## 🛠️ 工具函数

### 路径工具

```lua
local utils = require("qt-dev.core.utils")

-- 规范化路径
local normalized = utils.path.normalize("/path/to/file")

-- 相对路径
local relative = utils.path.relative("/base/path", "/base/path/sub/file")

-- 检查文件存在
local exists = utils.path.exists("/path/to/file")

-- 创建目录
utils.path.mkdir("/path/to/dir")
```

### 字符串工具

```lua
-- 模板渲染
local rendered = utils.string.template("Hello {name}!", {name = "World"})

-- 大小写转换
local camel = utils.string.to_camel_case("my_variable")
local snake = utils.string.to_snake_case("MyVariable")
local pascal = utils.string.to_pascal_case("my_variable")
```

### 系统工具

```lua
-- 执行命令
local result = utils.system.execute("cmake --version")

-- 检查可执行文件
local exists = utils.system.executable_exists("cmake")

-- 获取环境变量
local path = utils.system.getenv("PATH")
```

## 🔌 扩展API

### 自定义项目类型

```lua
local qt_dev = require("qt-dev")

-- 注册自定义项目类型
qt_dev.register_project_type("my_app", {
  name = "我的应用类型",
  description = "自定义应用程序类型",
  
  -- 检测函数
  detect = function(path)
    return utils.path.exists(path .. "/my_app.json")
  end,
  
  -- 创建函数
  create = function(options)
    -- 创建项目逻辑
  end,
  
  -- 构建函数
  build = function(config)
    -- 自定义构建逻辑
  end
})
```

### 自定义工具

```lua
-- 注册自定义工具
qt_dev.register_tool("my_tool", {
  name = "我的工具",
  executable = "mytool",
  
  -- 工具命令
  commands = {
    process = function(args)
      return utils.system.execute("mytool process " .. table.concat(args, " "))
    end
  }
})
```

### 自定义LSP配置

```lua
-- 扩展LSP配置
qt_dev.extend_lsp_config("clangd", {
  init_options = {
    clangdFileStatus = true,
    usePlaceholders = true,
    completeUnimported = true
  }
})
```

## 📊 类型定义

### Project类型

```lua
---@class Project
---@field name string 项目名称
---@field path string 项目路径
---@field type string 项目类型
---@field qt_version string Qt版本
---@field build_config string 构建配置
---@field files table 项目文件列表
```

### BuildResult类型

```lua
---@class BuildResult
---@field success boolean 构建是否成功
---@field error string? 错误信息
---@field output string 构建输出
---@field duration number 构建时长(秒)
```

### ToolInfo类型

```lua
---@class ToolInfo
---@field name string 工具名称
---@field version string? 工具版本
---@field path string 可执行文件路径
---@field available boolean 是否可用
```

---

更多详细信息请查看源代码中的类型定义和文档注释。
