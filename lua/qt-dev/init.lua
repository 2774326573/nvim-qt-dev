-- nvim-qt-dev 主入口模块 - 集成qt-project功能
local M = {}

-- 插件版本
M.version = "1.0.0"

-- 内部模块引用
local config = require("qt-dev.config")
local templates = require("qt-dev.templates")
local tools = require("qt-dev.tools")
local core = require("qt-dev.core")
local compile_commands = require("qt-dev.tools.compile_commands")
local environment_detector = require("qt-dev.core.environment_detector")

-- 插件是否已初始化
local initialized = false

-- 默认配置
local default_config = {
  -- 启用插件
  enabled = true,
  -- 自动检测Qt项目
  auto_detect = true,
  -- 默认快捷键
  default_mappings = true,
  -- 通知级别
  notify_level = vim.log.levels.INFO,
  -- LSP自动配置
  auto_lsp_config = true,
  -- 自动构建功能
  auto_build = true,
  -- 环境检测
  environment_check = true,
}

-- 插件设置
function M.setup(user_config)
  user_config = user_config or {}
  
  -- 合并用户配置
  local final_config = vim.tbl_deep_extend("force", default_config, user_config)
  
  -- 保存到全局配置
  vim.g.qt_dev_config = final_config
  
  -- 初始化配置系统
  config.init(final_config)
  
  -- 如果启用了自动LSP配置
  if final_config.auto_lsp_config then
    M.setup_lsp()
  end
  
  -- 设置自动构建功能
  if final_config.auto_build then
    M.setup_auto_build()
  end
  
  -- 设置环境检测
  if final_config.environment_check then
    M.setup_environment_detection()
  end
  
  -- 标记为已初始化
  initialized = true
  
  -- 通知初始化完成
  if final_config.notify_level <= vim.log.levels.INFO then
    vim.notify("🎉 nvim-qt-dev 已初始化", vim.log.levels.INFO)
  end
end

-- 设置LSP
function M.setup_lsp()
  local lsp_config = require("qt-dev.config.lsp")
  lsp_config.setup()
end

-- 创建Qt项目
function M.create_project(name, project_type)
  if not M.ensure_initialized() then return end
  
  project_type = project_type or "desktop"
  
  if name and name ~= "" then
    templates.create_project_direct(name, project_type)
  else
    templates.create_project_interactive()
  end
end

-- 创建桌面应用
function M.create_desktop(name)
  M.create_project(name, "desktop")
end

-- 创建控制台应用
function M.create_console(name)
  M.create_project(name, "console")
end

-- 创建QML应用
function M.create_qml(name)
  M.create_project(name, "qml")
end

-- Qt项目检测到时的回调
function M.on_qt_project_detected()
  if not M.ensure_initialized() then return end
  
  local project_info = core.detection.get_project_info()
  
  -- 通知用户
  vim.notify(string.format("🎯 检测到Qt项目: %s", project_info.type), vim.log.levels.INFO)
  
  -- 设置项目特定配置
  M.setup_project_features(project_info)
end

-- 设置项目特定功能
function M.setup_project_features(project_info)
  -- 设置快捷键
  if vim.g.qt_dev_config.default_mappings then
    require("qt-dev.config.keymaps").setup_project_keymaps()
  end
  
  -- 设置LSP
  if vim.g.qt_dev_config.auto_lsp_config then
    require("qt-dev.config.lsp").setup_project_lsp()
  end
  
  -- 设置构建工具
  tools.build.setup_project_build(project_info)
end

-- 设置C++文件特定功能
function M.setup_cpp_features()
  if not M.ensure_initialized() then return end
  
  -- C++特定的功能配置
  require("qt-dev.config.cpp").setup()
end

-- 设置QML文件特定功能
function M.setup_qml_features()
  if not M.ensure_initialized() then return end
  
  -- QML特定的功能配置
  require("qt-dev.config.qml").setup()
end

-- 确保插件已初始化
function M.ensure_initialized()
  if not initialized then
    vim.notify("⚠️ nvim-qt-dev 尚未初始化，请在配置中调用 require('qt-dev').setup()", vim.log.levels.WARN)
    return false
  end
  return true
end

-- 获取插件信息
function M.info()
  return {
    version = M.version,
    initialized = initialized,
    config = vim.g.qt_dev_config,
  }
end

-- 健康检查
function M.health_check()
  local health = require("qt-dev.health")
  return health.check()
end

-- 设置自动构建功能
function M.setup_auto_build()
  -- BufWritePost 自动重启LSP
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "*.cpp", "*.h", "*.hpp", "*.cxx", "*.cc" },
    callback = function()
      vim.cmd("LspRestart")
    end,
  })

  -- 保存 CMakeLists.txt 时自动构建 CMake
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "CMakeLists.txt", "*.cmake" },
    callback = function()
      local project_dir = vim.fn.getcwd()
      
      -- 检查是否在Qt项目中
      if core.detection.is_qt_project() then
        vim.notify("🔄 检测到CMake文件保存，开始自动构建...", vim.log.levels.INFO)
        
        -- 延迟执行以避免文件保存冲突
        vim.defer_fn(function()
          local build_dir = project_dir .. (core.utils.is_windows() and "\\build" or "/build")
          
          -- 确保build目录存在
          if vim.fn.isdirectory(build_dir) == 0 then
            vim.fn.mkdir(build_dir, "p")
          end
          
          -- 切换到build目录并运行cmake
          local cmake_cmd
          if core.utils.is_windows() then
            cmake_cmd = string.format('cd /d "%s" && cmake .. -G "Visual Studio 17 2022" -A x64', build_dir)
          else
            cmake_cmd = string.format('cd "%s" && cmake ..', build_dir)
          end
          
          -- 在终端中执行CMake命令
          vim.notify("🔧 执行CMake配置: " .. cmake_cmd, vim.log.levels.INFO)
          
          -- 使用vim.system (Neovim 0.10+) 或 vim.fn.system
          if vim.system then
            vim.system({ 'cmake', '..', '-B', build_dir }, {
              cwd = project_dir,
              text = true,
            }, function(result)
              if result.code == 0 then
                vim.notify("✅ CMake配置成功完成", vim.log.levels.INFO)
                -- 更新compile_commands.json
                compile_commands.update_compile_commands(project_dir)
              else
                vim.notify("❌ CMake配置失败: " .. (result.stderr or "未知错误"), vim.log.levels.ERROR)
              end
            end)
          else
            -- 回退到同步执行
            local result = vim.fn.system(cmake_cmd)
            if vim.v.shell_error == 0 then
              vim.notify("✅ CMake配置成功完成", vim.log.levels.INFO)
              compile_commands.update_compile_commands(project_dir)
            else
              vim.notify("❌ CMake配置失败: " .. result, vim.log.levels.ERROR)
            end
          end
        end, 500)
      end
    end,
  })
end

-- 设置环境检测
function M.setup_environment_detection()
  -- 项目检测和通知
  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    callback = function()
      if core.detection.is_qt_project() then
        local env_info = environment_detector.detect_development_environment()
        vim.notify("🎉 检测到Qt项目，Qt开发工具已激活！(" .. env_info.env_type .. ")", vim.log.levels.INFO)
        vim.notify("💡 使用 <leader>q 查看Qt相关快捷键", vim.log.levels.INFO)
        
        -- 快速环境检查
        vim.defer_fn(function()
          environment_detector.quick_environment_check()
        end, 1000)
        
        -- 设置文件监控
        local project_dir = vim.fn.getcwd()
        compile_commands.setup_compile_commands_watcher(project_dir)
      end
    end,
  })

  -- 清理资源的autocmd
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      compile_commands.stop_compile_commands_watcher()
    end,
  })

  -- 创建用户命令 (集成自qt-project)
  vim.api.nvim_create_user_command("QtCreateProject", function(opts)
    if opts.args and opts.args ~= "" then
      local args = vim.split(opts.args, " ")
      local project_name = args[1]
      local project_type = args[2] or "desktop"
      local project_structure = require("qt-dev.templates.project_structure")
      project_structure.create_project_direct(project_name, project_type)
    else
      local project_structure = require("qt-dev.templates.project_structure")
      project_structure.create_project_interactive()
    end
  end, {
    nargs = "*",
    desc = "创建Qt项目 (用法: QtCreateProject [项目名] [类型])",
    complete = function()
      return {"desktop", "console", "web", "qml", "static_lib", "dynamic_lib"}
    end
  })
  
  vim.api.nvim_create_user_command("QtCreateDesktop", function(opts)
    local project_structure = require("qt-dev.templates.project_structure")
    if opts.args and opts.args ~= "" then
      project_structure.create_project_direct(opts.args, "desktop")
    else
      vim.ui.input({ prompt = "请输入桌面应用项目名称: " }, function(input)
        if input and input ~= "" then
          project_structure.create_project_direct(input, "desktop")
        end
      end)
    end
  end, {
    nargs = "?",
    desc = "创建Qt桌面应用项目"
  })

  vim.api.nvim_create_user_command("QtEnvironmentCheck", function()
    environment_detector.show_full_environment_report()
  end, {
    desc = "显示Qt开发环境检测报告"
  })

  vim.api.nvim_create_user_command("QtQuickCheck", function()
    environment_detector.quick_environment_check()
  end, {
    desc = "快速Qt环境检查"
  })
end

-- 调试信息
function M.debug()
  local info = M.info()
  local debug_info = {
    plugin_info = info,
    environment = core.environment.get_info(),
    qt_config = config.get_qt_config(),
  }
  
  print(vim.inspect(debug_info))
  return debug_info
end

-- 环境检测相关函数
function M.quick_environment_check()
  if not M.ensure_initialized() then return end
  return environment_detector.quick_environment_check()
end

function M.show_full_environment_report()
  if not M.ensure_initialized() then return end
  return environment_detector.show_full_environment_report()
end

return M