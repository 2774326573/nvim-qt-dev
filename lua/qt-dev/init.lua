-- nvim-qt-dev 主入口模块
local M = {}

-- 插件版本
M.version = "1.0.0"

-- 内部模块引用
local config = require("qt-dev.config")
local templates = require("qt-dev.templates")
local tools = require("qt-dev.tools")
local core = require("qt-dev.core")

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

return M