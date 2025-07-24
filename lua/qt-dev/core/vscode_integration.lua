-- VS Code集成模块（可选功能）
local utils = require("qt-dev.core.utils")
local M = {}

-- 检测是否在VS Code环境中
function M.is_vscode_environment()
  return vim.env.VSCODE ~= nil or vim.g.vscode ~= nil
end

-- 集成构建
function M.integrated_build()
  utils.info("VS Code集成构建功能暂未实现")
  -- 回退到标准构建
  local build = require("qt-dev.tools.build")
  return build.build_project()
end

-- 集成运行
function M.integrated_run()
  utils.info("VS Code集成运行功能暂未实现")
  -- 回退到标准运行
  local build = require("qt-dev.tools.build")
  return build.run_project()
end

-- 集成清理
function M.integrated_clean()
  utils.info("VS Code集成清理功能暂未实现")
  -- 回退到标准清理
  local build = require("qt-dev.tools.build")
  return build.clean_project()
end

-- 打开Designer
function M.open_designer(file_path)
  -- 回退到标准Designer
  local designer = require("qt-dev.tools.designer")
  return designer.open_designer(file_path)
end

-- 同步配置到VS Code
function M.sync_config_to_vscode()
  utils.info("VS Code配置同步功能暂未实现")
end

-- 检测并提供建议
function M.detect_and_suggest()
  if M.is_vscode_environment() then
    utils.info("检测到VS Code环境，建议安装C++扩展包以获得更好的开发体验")
  else
    utils.info("未检测到VS Code环境")
  end
end

return M