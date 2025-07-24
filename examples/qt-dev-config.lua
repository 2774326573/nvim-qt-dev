-- nvim-qt-dev 配置示例文件
-- 复制此文件到 ~/.config/nvim/qt-dev-config.lua 并根据您的环境进行修改

return {
  -- Qt安装配置
  qt = {
    -- Qt安装基础路径 (根据您的系统修改)
    base_paths = {
      windows = {
        "D:/Qt",              -- 您的Qt安装路径
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
    -- 首选Qt版本 (修改为您安装的版本)
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
    -- Windows SDK路径
    windows_sdk_paths = {
      "C:/Program Files (x86)/Windows Kits/10/Include",
      "C:/Program Files/Windows Kits/10/Include",
    },
    -- 首选MSVC版本
    preferred_msvc_version = "2022",
  },
  
  -- 项目模板配置
  templates = {
    -- 默认项目类型
    default_project_type = "desktop",
    -- 默认C++标准
    cpp_standard = "17",
    -- 默认CMake最低版本
    cmake_minimum_version = "3.22",
  },
  
  -- 开发工具配置
  tools = {
    -- 首选语言服务器
    preferred_lsp = "clangd",  -- clangd 或 ccls
    -- 是否自动生成compile_commands.json
    auto_generate_compile_commands = true,
    -- 是否自动重启LSP
    auto_restart_lsp = true,
    -- VS Code集成
    vscode_integration = false,
  },
  
  -- 高级路径配置 (完全自定义路径，覆盖自动检测)
  paths = {
    -- 自定义Qt完整路径 (可选)
    custom_qt_path = nil,  -- 例: "D:/Qt/6.6.0/msvc2022_64"
    -- 自定义MSVC路径 (可选)
    custom_msvc_path = nil,  -- 例: "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.38.33130"
  }
}