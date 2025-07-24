# Configuration Documentation

This document details all configuration options and customization methods for the nvim-qt-dev plugin.

## 📋 Table of Contents

- [Basic Configuration](#basic-configuration)
- [Qt Environment Configuration](#qt-environment-configuration)
- [Compiler Configuration](#compiler-configuration)
- [Project Template Configuration](#project-template-configuration)
- [Development Tools Configuration](#development-tools-configuration)
- [Keybinding Configuration](#keybinding-configuration)
- [LSP Configuration](#lsp-configuration)
- [Advanced Configuration](#advanced-configuration)

## 🚀 Basic Configuration

### Default Configuration

The plugin's default configuration is as follows:

```lua
require("qt-dev").setup({
  -- Basic settings
  enabled = true,                    -- Enable plugin
  auto_detect = true,                -- Auto-detect Qt projects
  default_mappings = true,           -- Enable default keybindings
  notify_level = vim.log.levels.INFO, -- Notification level
  auto_lsp_config = true,            -- Auto-configure LSP
})
```

### Plugin-level Configuration

```lua
require("qt-dev").setup({
  -- Disable default keybindings
  default_mappings = false,
  
  -- Set notification level (ERROR, WARN, INFO, DEBUG)
  notify_level = vim.log.levels.WARN,
  
  -- Disable auto LSP configuration
  auto_lsp_config = false,
  
  -- VS Code mode
  vscode_mode = false,
})
```

## 🎯 Qt Environment Configuration

### Qt Installation Paths

```lua
require("qt-dev").setup({
  qt = {
    -- Qt installation base paths
    base_paths = {
      windows = {
        "D:/Qt",              -- Custom installation path
        "C:/Qt",
        "C:/Program Files/Qt",
        "C:/Program Files (x86)/Qt",
      },
      linux = {
        "/usr/lib/qt6",
        "/usr/lib/x86_64-linux-gnu/qt6",
        "/usr/lib/qt5", 
        "/usr/lib/x86_64-linux-gnu/qt5",
        "/opt/Qt",
        "/usr/local/qt6",
        "/usr/local/qt5",
      }
    },
    
    -- Preferred Qt version
    preferred_version = "6.6.0",
    
    -- Preferred compiler (Windows)
    preferred_compiler = "msvc2022_64",
  }
})
```

### Multi-version Qt Support

```lua
qt = {
  -- Specific version configurations
  versions = {
    ["6.6.0"] = {
      path = "C:/Qt/6.6.0/msvc2022_64",
      compiler = "msvc2022_64"
    },
    ["5.15.2"] = {
      path = "C:/Qt/5.15.2/msvc2019_64",
      compiler = "msvc2019_64"
    }
  },
  
  -- Default version
  preferred_version = "6.6.0"
}
```

## 🔧 Compiler Configuration

### Windows Compiler Configuration

```lua
compiler = {
  -- MSVC installation paths
  msvc_paths = {
    "C:/Program Files/Microsoft Visual Studio",
    "C:/Program Files (x86)/Microsoft Visual Studio",
  },
  
  -- Windows SDK paths
  windows_sdk_paths = {
    "C:/Program Files (x86)/Windows Kits/10/Include",
    "C:/Program Files/Windows Kits/10/Include",
  },
  
  -- Preferred MSVC version
  preferred_msvc_version = "2022",
  
  -- Preferred architecture
  preferred_architecture = "x64",
}
```

### Linux Compiler Configuration

```lua
compiler = {
  -- Preferred compiler
  preferred_compiler = "gcc", -- or "clang"
  
  -- Compiler flags
  cxx_flags = {
    "-std=c++17",
    "-Wall",
    "-Wextra"
  },
  
  -- Linker flags
  link_flags = {
    "-pthread"
  }
}
```

## 📝 Project Template Configuration

### Default Templates

```lua
templates = {
  -- Default project type
  default_project_type = "desktop",
  
  -- Default C++ standard
  default_cpp_standard = "17",
  
  -- Default namespace
  default_namespace = "",
  
  -- Include test files
  include_tests = false,
  
  -- Include resource files
  include_resources = true,
}
```

### Custom Templates

```lua
templates = {
  -- Custom project templates
  custom_projects = {
    my_app = {
      name = "My Custom App",
      description = "Custom application template",
      files = {
        ["main.cpp"] = "custom_main_template",
        ["app.h"] = "custom_header_template",
        ["app.cpp"] = "custom_source_template"
      }
    }
  },
  
  -- Custom class templates
  custom_classes = {
    my_widget = {
      name = "My Widget Template",
      description = "Custom widget class template",
      files = {
        ["{name}.h"] = "custom_widget_header",
        ["{name}.cpp"] = "custom_widget_source",
        ["{name}.ui"] = "custom_widget_ui"
      }
    }
  }
}
```

## 🛠️ Development Tools Configuration

### Build Configuration

```lua
build = {
  -- Default build type
  default_config = "Debug",
  
  -- Parallel build
  parallel = true,
  
  -- Number of build jobs (0 = auto-detect CPU cores)
  jobs = 0,
  
  -- Auto-build on save
  auto_build_on_save = false,
  
  -- Build output directory
  build_dir = "build",
  
  -- CMake generator
  cmake_generator = "Ninja", -- or "Unix Makefiles", "Visual Studio 17 2022"
}
```

### Qt Designer Configuration

```lua
designer = {
  -- Auto-open UI files
  auto_open_ui = true,
  
  -- Open Designer when creating UI files
  designer_on_ui_create = true,
  
  -- Designer executable path (auto-detect if nil)
  executable = nil,
  
  -- Additional arguments
  args = {}
}
```

### Status Check Configuration

```lua
status = {
  -- Check interval (seconds)
  check_interval = 30,
  
  -- Auto-check on file changes
  auto_check = true,
  
  -- Notification for status changes
  notify_changes = true
}
```

## ⌨️ Keybinding Configuration

### Default Keybindings

```lua
keymaps = {
  ["<leader>qn"] = "QtCreate",
  ["<leader>qb"] = "QtBuild",
  ["<leader>qr"] = "QtRun",
  ["<leader>qd"] = "QtDesigner",
  ["<leader>qc"] = "QtClass",
  ["<leader>qs"] = "QtStatus",
  ["<leader>qt"] = "QtTest",
  ["<leader>qf"] = "QtFormat",
  ["<leader>qh"] = "QtHeader",
}
```

### Custom Keybindings

```lua
require("qt-dev").setup({
  -- Disable default keybindings
  default_mappings = false,
  
  -- Custom keybindings
  keymaps = {
    ["<F5>"] = "QtBuild",
    ["<F6>"] = "QtRun",
    ["<F7>"] = "QtDebug",
    ["<leader>qp"] = "QtCreate",
    ["<leader>qo"] = "QtDesigner",
  }
})
```

### Advanced Keybinding Configuration

```lua
keymaps = {
  -- Conditional keybindings
  conditional = {
    -- Only in Qt projects
    qt_project = {
      ["<leader>qb"] = "QtBuild",
      ["<leader>qr"] = "QtRun"
    },
    
    -- Only for C++ files
    cpp_files = {
      ["<leader>qc"] = "QtClass",
      ["<leader>qh"] = "QtHeader"
    }
  },
  
  -- Mode-specific keybindings
  modes = {
    normal = {
      ["<leader>qn"] = "QtCreate"
    },
    visual = {
      ["<leader>qf"] = "QtFormat"
    }
  }
}
```

## 🔍 LSP Configuration

### Basic LSP Configuration

```lua
lsp = {
  -- Auto-configure LSP
  auto_config = true,
  
  -- Preferred LSP server
  server = "clangd", -- or "ccls"
  
  -- Auto-generate compile_commands.json
  compile_commands = true,
  
  -- Auto-restart LSP on config changes
  auto_restart = true,
}
```

### clangd Configuration

```lua
lsp = {
  clangd = {
    -- clangd executable path
    cmd = { "clangd", "--background-index" },
    
    -- Initialization options
    init_options = {
      clangdFileStatus = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticHighlighting = true
    },
    
    -- Server capabilities
    capabilities = {
      textDocument = {
        completion = {
          completionItem = {
            snippetSupport = true
          }
        }
      }
    }
  }
}
```

### Custom LSP Configuration

```lua
lsp = {
  -- Custom LSP server
  custom_server = {
    name = "my_cpp_lsp",
    cmd = { "my-lsp-server", "--stdio" },
    filetypes = { "cpp", "c", "h", "hpp" },
    root_dir = function(fname)
      return require("qt-dev.core.detection").detect_project_root(fname)
    end
  }
}
```

## 🎛️ Advanced Configuration

### Hooks and Events

```lua
hooks = {
  -- Before project creation
  before_project_create = function(options)
    print("Creating project: " .. options.name)
  end,
  
  -- After project creation
  after_project_create = function(project)
    print("Project created: " .. project.path)
  end,
  
  -- Before build
  before_build = function(project)
    -- Custom pre-build steps
  end,
  
  -- After build
  after_build = function(project, success)
    if success then
      print("Build successful!")
    else
      print("Build failed!")
    end
  end,
  
  -- On file save
  on_file_save = function(filename)
    -- Custom save actions
  end
}
```

### Environment Variables

```lua
environment = {
  -- Custom environment variables
  variables = {
    QT_DEBUG_PLUGINS = "1",
    QML_IMPORT_TRACE = "1"
  },
  
  -- Path modifications
  path_additions = {
    windows = {
      "C:/CustomTools/bin"
    },
    linux = {
      "/opt/custom-tools/bin"
    }
  }
}
```

### Logging Configuration

```lua
logging = {
  -- Log level
  level = "INFO", -- DEBUG, INFO, WARN, ERROR
  
  -- Log file
  file = vim.fn.stdpath("cache") .. "/qt-dev.log",
  
  -- Max log file size (MB)
  max_size = 10,
  
  -- Enable console output
  console = true
}
```

## 📁 User Configuration File

Create `~/.config/nvim/lua/qt-dev-config.lua`:

```lua
return {
  -- Qt configuration
  qt = {
    base_paths = {
      windows = { "D:/Qt", "C:/Qt" },
      linux = { "/usr/lib/qt6", "/opt/Qt" }
    },
    preferred_version = "6.6.0",
    preferred_compiler = "msvc2022_64",
  },
  
  -- Compiler configuration
  compiler = {
    preferred_msvc_version = "2022",
  },
  
  -- Project templates
  templates = {
    default_project_type = "desktop",
    default_cpp_standard = "17",
  },
  
  -- Development tools
  tools = {
    auto_generate_compile_commands = true,
    auto_restart_lsp = true,
    preferred_lsp = "clangd",
    auto_open_ui_files = true,
    designer_on_ui_create = true,
  },
  
  -- Build configuration
  build = {
    parallel = true,
    jobs = 4,
    default_config = "Debug"
  }
}
```

## 🔄 Configuration Loading Order

1. Plugin default configuration
2. User configuration file (`qt-dev-config.lua`)
3. Setup function parameters
4. Project-specific configuration (`.qt-dev.lua` in project root)

## 🧪 Configuration Validation

Check your configuration:

```vim
:QtConfig validate
```

Show current configuration:

```vim
:QtConfig show
```

Reset to default configuration:

```vim
:QtConfig reset
```

## 📚 Configuration Examples

See [examples/qt-dev-config.lua](../../examples/qt-dev-config.lua) for a complete configuration example.

---

For more configuration options and advanced usage, please refer to the [API Reference](api.md).
