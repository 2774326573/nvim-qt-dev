-- Qt项目用户配置管理模块
local utils = require("qt-dev.core.utils")
local M = {}

-- 默认配置
M.default_config = {
  -- Qt安装配置
  qt = {
    -- Qt安装基础路径 (Windows/Linux)
    base_paths = {
      windows = {
        "D:/install/Qt",  -- 用户自定义路径示例
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
    -- 首选Qt版本
    preferred_version = "5.12.12",
    -- 首选编译器 (Windows)
    preferred_compiler = "msvc2017_64",
  },
  
  -- 编译器配置
  compiler = {
    -- MSVC安装路径 (Windows)
    msvc_paths = {
      "D:/install/visualStudio",  -- 用户自定义路径示例
      "C:/Program Files/Microsoft Visual Studio",
      "C:/Program Files (x86)/Microsoft Visual Studio",
    },
    -- Windows SDK路径
    windows_sdk_paths = {
      "C:/Program Files (x86)/Windows Kits/10/Include",
      "C:/Program Files/Windows Kits/10/Include",
    },
    -- 首选MSVC版本
    preferred_msvc_version = "2017",
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
    vscode_integration = true,
  },
  
  -- 高级路径配置 (完全自定义路径，覆盖自动检测)
  paths = {
    -- 自定义Qt完整路径
    custom_qt_path = nil,  -- 例: "D:/install/Qt/Qt5.12/5.12.12/msvc2017_64"
    -- 自定义MSVC路径
    custom_msvc_path = nil,  -- 例: "D:/install/visualStudio/2017/Community/VC/Tools/MSVC/14.16.27023"
  }
}

-- 用户配置文件路径
M.config_file_path = vim.fn.stdpath("config") .. "/qt-dev-config.lua"

-- 加载用户配置
function M.load_user_config()
  local user_config = {}
  
  -- 尝试加载用户配置文件
  if vim.fn.filereadable(M.config_file_path) == 1 then
    local ok, config = pcall(dofile, M.config_file_path)
    if ok and type(config) == "table" then
      user_config = config
      vim.notify("✅ 已加载用户配置: " .. M.config_file_path, vim.log.levels.INFO)
    else
      vim.notify("⚠️ 用户配置文件格式错误，使用默认配置", vim.log.levels.WARN)
    end
  end
  
  -- 合并用户配置和默认配置
  return vim.tbl_deep_extend("force", M.default_config, user_config)
end

-- 保存用户配置
function M.save_user_config(config)
  local config_content = string.format([[-- Qt项目用户配置文件
-- 此文件由nvim-qt-dev自动生成，您可以手动修改
-- 更多配置选项请参考: https://github.com/your-username/nvim-qt-dev

return %s
]], vim.inspect(config, {
    indent = "  ",
    depth = 4,
  }))
  
  local file = io.open(M.config_file_path, "w")
  if file then
    file:write(config_content)
    file:close()
    vim.notify("✅ 配置已保存到: " .. M.config_file_path, vim.log.levels.INFO)
    return true
  else
    vim.notify("❌ 保存配置失败: " .. M.config_file_path, vim.log.levels.ERROR)
    return false
  end
end

-- 创建默认配置文件
function M.create_default_config()
  if vim.fn.filereadable(M.config_file_path) == 1 then
    vim.ui.select({"覆盖", "取消"}, {
      prompt = "配置文件已存在，是否覆盖？",
    }, function(choice)
      if choice == "覆盖" then
        M.save_user_config(M.default_config)
      end
    end)
  else
    M.save_user_config(M.default_config)
  end
end

-- 交互式配置向导
function M.setup_wizard()
  vim.notify("🚀 nvim-qt-dev配置向导启动", vim.log.levels.INFO)
  local config = vim.deepcopy(M.default_config)
  
  -- Step 1: Qt路径配置
  vim.ui.input({
    prompt = "请输入Qt安装基础路径 (例: D:/install/Qt): ",
    default = utils.is_windows() and "D:/install/Qt" or "/usr/lib/qt6",
  }, function(qt_base)
    if qt_base and qt_base ~= "" then
      if utils.is_windows() then
        table.insert(config.qt.base_paths.windows, 1, qt_base)
      else
        table.insert(config.qt.base_paths.linux, 1, qt_base)
      end
    end
    
    -- Step 2: Qt版本选择
    vim.ui.select({"5.12.12", "5.15.2", "6.5.0", "6.6.0", "其他"}, {
      prompt = "选择首选Qt版本:",
    }, function(version)
      if version and version ~= "其他" then
        config.qt.preferred_version = version
      elseif version == "其他" then
        vim.ui.input({
          prompt = "请输入Qt版本 (例: 6.4.2): ",
        }, function(custom_version)
          if custom_version and custom_version ~= "" then
            config.qt.preferred_version = custom_version
          end
        end)
      end
      
      -- Step 3: 编译器选择 (仅Windows)
      if utils.is_windows() then
        vim.ui.select({"msvc2017_64", "msvc2019_64", "msvc2022_64", "mingw_64", "其他"}, {
          prompt = "选择首选编译器:",
        }, function(compiler)
          if compiler and compiler ~= "其他" then
            config.qt.preferred_compiler = compiler
          elseif compiler == "其他" then
            vim.ui.input({
              prompt = "请输入编译器名称: ",
            }, function(custom_compiler)
              if custom_compiler and custom_compiler ~= "" then
                config.qt.preferred_compiler = custom_compiler
              end
            end)
          end
          
          -- 保存配置
          M.save_user_config(config)
          vim.notify("🎉 配置向导完成！重启Neovim后生效", vim.log.levels.INFO)
        end)
      else
        -- Linux直接保存
        M.save_user_config(config)
        vim.notify("🎉 配置向导完成！重启Neovim后生效", vim.log.levels.INFO)
      end
    end)
  end)
end

-- 验证配置
function M.validate_config(config)
  local issues = {}
  
  -- 检查Qt路径
  if config.paths.custom_qt_path then
    if vim.fn.isdirectory(config.paths.custom_qt_path) == 0 then
      table.insert(issues, "自定义Qt路径不存在: " .. config.paths.custom_qt_path)
    end
  end
  
  -- 检查MSVC路径 (Windows)
  if utils.is_windows() and config.paths.custom_msvc_path then
    if vim.fn.isdirectory(config.paths.custom_msvc_path) == 0 then
      table.insert(issues, "自定义MSVC路径不存在: " .. config.paths.custom_msvc_path)
    end
  end
  
  return issues
end

-- 获取当前有效配置
function M.get_effective_config()
  local config = M.load_user_config()
  local issues = M.validate_config(config)
  
  if #issues > 0 then
    vim.notify("⚠️ 配置验证发现问题:", vim.log.levels.WARN)
    for _, issue in ipairs(issues) do
      vim.notify("  - " .. issue, vim.log.levels.WARN)
    end
  end
  
  return config
end

-- 显示当前配置
function M.show_config()
  local config = M.get_effective_config()
  
  local info = {
    "🔧 nvim-qt-dev当前配置:",
    "",
    "📁 Qt配置:",
    "  - 首选版本: " .. config.qt.preferred_version,
    "  - 首选编译器: " .. config.qt.preferred_compiler,
    "",
    "🛠️ 编译器配置:",
    "  - 首选MSVC版本: " .. config.compiler.preferred_msvc_version,
    "",
    "📄 项目模板:",
    "  - 默认项目类型: " .. config.templates.default_project_type,
    "  - C++标准: " .. config.templates.cpp_standard,
    "",
    "⚙️ 开发工具:",
    "  - 语言服务器: " .. config.tools.preferred_lsp,
    "  - 自动生成compile_commands: " .. (config.tools.auto_generate_compile_commands and "是" or "否"),
    "",
    "📍 配置文件位置: " .. M.config_file_path,
  }
  
  -- 自定义路径信息
  if config.paths.custom_qt_path then
    table.insert(info, "")
    table.insert(info, "🎯 自定义路径:")
    table.insert(info, "  - Qt路径: " .. config.paths.custom_qt_path)
  end
  if config.paths.custom_msvc_path then
    if not config.paths.custom_qt_path then
      table.insert(info, "")
      table.insert(info, "🎯 自定义路径:")
    end
    table.insert(info, "  - MSVC路径: " .. config.paths.custom_msvc_path)
  end
  
  vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
end

return M