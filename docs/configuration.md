# 配置文档

本文档详细介绍 nvim-qt-dev 插件的所有配置选项和自定义方法。

## 📋 目录

- [基础配置](#基础配置)
- [Qt 环境配置](#qt-环境配置)
- [编译器配置](#编译器配置)
- [项目模板配置](#项目模板配置)
- [开发工具配置](#开发工具配置)
- [快捷键配置](#快捷键配置)
- [LSP 配置](#lsp-配置)
- [高级配置](#高级配置)

## 🚀 基础配置

### 默认配置

插件的默认配置如下：

```lua
require("qt-dev").setup({
  -- 基础设置
  enabled = true,                    -- 启用插件
  auto_detect = true,                -- 自动检测Qt项目
  default_mappings = true,           -- 启用默认快捷键
  notify_level = vim.log.levels.INFO, -- 通知级别
  auto_lsp_config = true,            -- 自动配置LSP
})
```

### 插件级别配置

```lua
require("qt-dev").setup({
  -- 禁用默认快捷键
  default_mappings = false,
  
  -- 设置通知级别 (ERROR, WARN, INFO, DEBUG)
  notify_level = vim.log.levels.WARN,
  
  -- 禁用自动LSP配置
  auto_lsp_config = false,
  
  -- VS Code 模式
  vscode_mode = false,
})
```

## 🎯 Qt 环境配置

### 自动检测配置

插件会自动检测 Qt 安装，但您可以自定义检测路径：

```lua
-- 在 ~/.config/nvim/qt-dev-config.lua 中配置
return {
  qt = {
    -- Qt 安装基础路径
    base_paths = {
      windows = {
        "D:/Qt",                      -- 您的自定义路径
        "C:/Qt",
        "C:/Program Files/Qt",
      },
      linux = {
        "/usr/lib/qt6",
        "/opt/Qt",
        "/usr/local/qt6",
      }
    },
    
    -- 首选 Qt 版本
    preferred_version = "6.6.0",
    
    -- 首选编译器 (Windows)
    preferred_compiler = "msvc2022_64",
  }
}
```

### 手动指定 Qt 路径

如果自动检测失败，可以手动指定完整路径：

```lua
return {
  paths = {
    -- 完全自定义 Qt 路径 (覆盖自动检测)
    custom_qt_path = "D:/Qt/6.6.0/msvc2022_64",  -- Windows
    -- custom_qt_path = "/usr/lib/qt6",            -- Linux
  }
}
```

### Qt 版本特定配置

```lua
return {
  qt = {
    preferred_version = "6.6.0",
    
    -- Qt5 和 Qt6 特定设置
    version_specific = {
      ["5"] = {
        cmake_modules = {"Qt5::Core", "Qt5::Widgets", "Qt5::Gui"},
        include_suffix = "qt5",
      },
      ["6"] = {
        cmake_modules = {"Qt6::Core", "Qt6::Widgets", "Qt6::Gui"},
        include_suffix = "qt6",
      }
    }
  }
}
```

## 🔧 编译器配置

### Windows 编译器配置

```lua
return {
  compiler = {
    -- MSVC 安装路径
    msvc_paths = {
      "D:/VisualStudio",              -- 自定义路径
      "C:/Program Files/Microsoft Visual Studio",
    },
    
    -- Windows SDK 路径
    windows_sdk_paths = {
      "C:/Program Files (x86)/Windows Kits/10/Include",
    },
    
    -- 首选 MSVC 版本
    preferred_msvc_version = "2022",
    
    -- 编译器特定标志
    msvc_flags = {
      "/std:c++17",
      "/permissive-",
    },
  }
}
```

### Linux 编译器配置

```lua
return {
  compiler = {
    -- 首选编译器
    preferred_compiler = "gcc",  -- 或 "clang"
    
    -- 编译器标志
    gcc_flags = {
      "-std=c++17",
      "-Wall",
      "-Wextra",
    },
    
    clang_flags = {
      "-std=c++17",
      "-Wall",
      "-Wextra",
    },
  }
}
```

## 📄 项目模板配置

### 默认模板设置

```lua
return {
  templates = {
    -- 默认项目类型
    default_project_type = "desktop",
    
    -- 默认 C++ 标准
    cpp_standard = "17",            -- 或 "20", "23"
    
    -- 默认 CMake 最低版本
    cmake_minimum_version = "3.22",
    
    -- 项目结构选项
    create_build_dir = true,        -- 自动创建 build 目录
    create_docs_dir = false,        -- 创建文档目录
    create_tests_dir = true,        -- 创建测试目录
  }
}
```

### 自定义项目模板

```lua
return {
  templates = {
    -- 自定义模板
    custom_templates = {
      my_app = {
        name = "我的应用模板",
        description = "带有自定义配置的应用模板",
        files = {
          "main.cpp",
          "myapp.cpp",
          "myapp.h",
          "config.h.in",
        },
        cmake_options = {
          "set(CMAKE_CXX_STANDARD 20)",
          "find_package(Qt6 REQUIRED COMPONENTS Core Widgets Network)",
        }
      }
    }
  }
}
```

## 🛠️ 开发工具配置

### LSP 配置

```lua
return {
  tools = {
    -- 首选语言服务器
    preferred_lsp = "clangd",         -- 或 "ccls"
    
    -- 自动生成 compile_commands.json
    auto_generate_compile_commands = true,
    
    -- 自动重启 LSP
    auto_restart_lsp = true,
    
    -- clangd 特定配置
    clangd_options = {
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
    },
  }
}
```

### 构建工具配置

```lua
return {
  tools = {
    -- 默认构建类型
    default_build_type = "Debug",     -- 或 "Release", "RelWithDebInfo"
    
    -- 并行构建任务数
    build_jobs = 4,                   -- 或 "auto" 自动检测
    
    -- CMake 生成器
    cmake_generator = "Ninja",        -- 或 "Unix Makefiles", "Visual Studio 17 2022"
    
    -- 额外的 CMake 选项
    cmake_options = {
      "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
      "-DCMAKE_BUILD_TYPE=Debug",
    },
  }
}
```

### Qt Designer 配置

```lua
return {
  tools = {
    -- Designer 启动选项
    designer_options = {
      "--no-splash",                  -- 不显示启动画面
    },
    
    -- 自动打开相关的 UI 文件
    auto_open_ui = true,
    
    -- UI 文件变更时自动更新头文件
    auto_sync_ui_headers = true,
  }
}
```

## ⌨️ 快捷键配置

### 禁用默认快捷键

```lua
require("qt-dev").setup({
  default_mappings = false,
})
```

### 自定义快捷键

```lua
-- 在您的 init.lua 中
local qt_dev = require("qt-dev")

-- 项目管理
vim.keymap.set("n", "<leader>qn", qt_dev.create_project_interactive, { desc = "创建新Qt项目" })
vim.keymap.set("n", "<leader>qb", function() require("qt-dev.tools.build").build_project() end, { desc = "构建项目" })
vim.keymap.set("n", "<leader>qr", function() require("qt-dev.tools.build").run_project() end, { desc = "运行项目" })

-- Qt Designer
vim.keymap.set("n", "<leader>qd", function() require("qt-dev.tools.designer").open_current_file_ui() end, { desc = "打开Designer" })

-- 配置管理
vim.keymap.set("n", "<leader>qs", function() require("qt-dev.config").setup_wizard() end, { desc = "配置向导" })
```

### 按文件类型的快捷键

```lua
-- 创建 ~/.config/nvim/after/ftplugin/cpp.lua
local qt_dev = require("qt-dev")

-- C++ 文件特定快捷键
vim.keymap.set("n", "<leader>qc", function() 
  require("qt-dev.templates.class").create_quick_qt_class() 
end, { desc = "创建Qt类", buffer = true })

vim.keymap.set("n", "<leader>qh", function()
  -- 在 .cpp 和 .h 文件间切换
  local current_file = vim.fn.expand("%")
  if current_file:match("%.cpp$") then
    vim.cmd("edit " .. current_file:gsub("%.cpp$", ".h"))
  elseif current_file:match("%.h$") then
    vim.cmd("edit " .. current_file:gsub("%.h$", ".cpp"))
  end
end, { desc = "切换头文件", buffer = true })
```

## 🔍 LSP 配置

### clangd 配置

插件会自动生成 `.clangd` 配置，您也可以自定义：

```yaml
# .clangd 文件
CompileFlags:
  Add:
    - "-I/path/to/qt/include"
    - "-I/path/to/qt/include/QtCore"
    - "-I/path/to/qt/include/QtWidgets"
    - "-std=c++17"
    - "-DQT_CORE_LIB"
    - "-DQT_GUI_LIB"
    - "-DQT_WIDGETS_LIB"
  Remove:
    - "-W*"                    # 移除所有警告标志
  CompilationDatabase: build
```

### LSP 客户端配置

如果您使用 `nvim-lspconfig`：

```lua
-- 在您的 LSP 配置中
local lspconfig = require('lspconfig')

lspconfig.clangd.setup({
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
  on_attach = function(client, bufnr)
    -- Qt 项目特定的 LSP 设置
    if require("qt-dev.core.detection").is_qt_project() then
      -- 启用特定功能
    end
  end,
})
```

## 🔧 高级配置

### 环境检测配置

```lua
return {
  advanced = {
    -- 环境检测超时 (毫秒)
    detection_timeout = 5000,
    
    -- 缓存配置
    cache_config = true,
    cache_duration = 3600,           -- 1小时
    
    -- 调试模式
    debug_mode = false,
    verbose_logging = false,
  }
}
```

### 集成配置

```lua
return {
  integrations = {
    -- Telescope 集成
    telescope = {
      enabled = true,
      find_qt_files = true,          -- 添加 Qt 文件查找
    },
    
    -- nvim-tree 集成
    nvim_tree = {
      enabled = true,
      qt_file_icons = true,          -- Qt 文件图标
    },
    
    -- which-key 集成
    which_key = {
      enabled = true,
      prefix = "<leader>q",          -- 快捷键前缀
    },
  }
}
```

### 自动命令配置

```lua
return {
  autocmds = {
    -- 项目检测时自动执行
    on_project_detected = {
      "echo 'Qt项目已检测到'",
      -- 可以添加更多命令
    },
    
    -- CMake 文件变更时自动执行
    on_cmake_change = {
      "echo 'CMake配置已更新'",
    },
    
    -- UI 文件保存时自动同步
    on_ui_save = true,
  }
}
```

## 📂 配置文件位置

插件按以下优先级查找配置文件：

1. `~/.config/nvim/qt-dev-config.lua` (推荐)
2. `~/.config/nvim/lua/qt-dev-local.lua`
3. 项目根目录的 `.qt-dev.lua`

### 项目特定配置

在项目根目录创建 `.qt-dev.lua`：

```lua
-- 项目特定配置
return {
  qt = {
    preferred_version = "5.15.2",    -- 项目使用的特定版本
  },
  
  templates = {
    cpp_standard = "14",             -- 项目使用 C++14
  },
  
  tools = {
    cmake_options = {
      "-DCUSTOM_OPTION=ON",          -- 项目特定的 CMake 选项
    },
  }
}
```

## 🔄 配置管理命令

### 配置相关命令

```vim
" 运行配置向导
:QtSetup

" 显示当前配置
:QtConfig

" 创建默认配置文件
:lua require("qt-dev.config.user_config").create_default_config()

" 重新加载配置
:lua require("qt-dev.config").reload()

" 验证配置
:lua require("qt-dev.config.user_config").validate_config()
```

### 配置调试

```vim
" 显示详细的环境信息
:lua require("qt-dev.core.environment").show_full_environment_report()

" 显示插件调试信息
:lua require("qt-dev").debug()

" 检查插件健康状态
:checkhealth qt-dev
```

## 📚 配置示例

### 完整配置示例

参考 [`examples/qt-dev-config.lua`](../examples/qt-dev-config.lua) 文件，包含所有配置选项的详细示例。

### 最小配置

```lua
-- 最小配置示例
return {
  qt = {
    preferred_version = "6.6.0",
    preferred_compiler = "msvc2022_64",  -- Windows
  }
}
```

### 高级用户配置

```lua
-- 高级用户配置示例
return {
  qt = {
    base_paths = {
      windows = {"D:/Qt", "C:/Qt"},
    },
    preferred_version = "6.6.0",
    preferred_compiler = "msvc2022_64",
  },
  
  templates = {
    cpp_standard = "20",
    cmake_minimum_version = "3.25",
    create_tests_dir = true,
  },
  
  tools = {
    preferred_lsp = "clangd",
    build_jobs = "auto",
    cmake_generator = "Ninja",
  },
  
  paths = {
    custom_qt_path = "D:/Qt/6.6.0/msvc2022_64",
  }
}
```

配置完成后，重启 Neovim 或运行 `:lua require("qt-dev.config").reload()` 使配置生效。