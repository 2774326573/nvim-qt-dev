-- Qt开发插件配置入口模块
local M = {}

-- 内部模块引用
local user_config = require("qt-dev.config.user_config")
local paths = require("qt-dev.config.paths")
local keymaps = require("qt-dev.config.keymaps")

-- 配置是否已初始化
local initialized = false
local current_config = nil

-- 初始化配置系统
function M.init(plugin_config)
  plugin_config = plugin_config or {}
  
  -- 加载用户配置
  current_config = user_config.get_effective_config()
  
  -- 合并插件配置和用户配置
  current_config = vim.tbl_deep_extend("force", current_config, plugin_config)
  
  -- 初始化Qt路径配置
  local qt_config = paths.get_qt_config()
  
  -- 设置快捷键
  if current_config.enable_keymaps ~= false then
    keymaps.setup_keymaps(current_config.vscode_mode or false)
  end
  
  -- 标记已初始化
  initialized = true
  
  if user_config.is_first_run() then
    vim.notify("⚙️ Qt开发环境配置完成", vim.log.levels.INFO)
  end
  
  return current_config
end

-- 获取当前配置
function M.get_config()
  if not initialized then
    vim.notify("⚠️ 配置系统尚未初始化", vim.log.levels.WARN)
    return nil
  end
  return current_config
end

-- 获取Qt配置
function M.get_qt_config()
  return paths.get_qt_config()
end

-- 重新加载配置
function M.reload()
  initialized = false
  return M.init()
end

-- 配置向导
function M.setup_wizard()
  return user_config.setup_wizard()
end

-- 显示配置
function M.show_config()
  return user_config.show_config()
end

-- 创建默认配置
function M.create_default_config()
  return user_config.create_default_config()
end

-- LSP配置模块
M.lsp = {
  setup = function()
    -- LSP配置逻辑
    if user_config.is_first_run() then
      vim.notify("🔧 LSP配置已设置", vim.log.levels.INFO)
    end
  end,
  
  setup_project_lsp = function()
    -- 项目特定LSP配置
    if user_config.is_first_run() then
      vim.notify("📁 项目LSP配置已应用", vim.log.levels.INFO)
    end
  end
}

-- C++配置模块
M.cpp = {
  setup = function()
    -- C++特定配置
    vim.notify("⚡ C++特性已启用", vim.log.levels.INFO)
  end
}

-- QML配置模块
M.qml = {
  setup = function()
    -- QML特定配置
    vim.notify("🎨 QML特性已启用", vim.log.levels.INFO)
  end
}

return M