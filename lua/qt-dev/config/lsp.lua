-- Qt项目LSP配置模块
local utils = require("qt-dev.core.utils")
local M = {}

-- 设置LSP
function M.setup()
  local user_config = require("qt-dev.config.user_config")
  if user_config.is_first_run() then
    utils.info("🔧 LSP配置已设置")
  end
  
  -- 检查是否有clangd
  if utils.executable_exists("clangd") then
    M.setup_clangd()
  else
    utils.warn("未检测到clangd，请安装clangd以获得更好的代码提示")
  end
end

-- 设置clangd LSP
function M.setup_clangd()
  -- 这里可以添加特定的clangd配置
  -- 由于LSP通常在用户的init.lua中配置，这里主要提供项目特定的配置
  
  -- 确保.clangd配置文件存在
  if not utils.file_exists(".clangd") then
    M.create_clangd_config()
  end
  
  -- 确保compile_commands.json存在
  if not utils.file_exists("compile_commands.json") then
    local user_config = require("qt-dev.config.user_config")
    if user_config.is_first_run() then
      utils.info("建议运行 :QtBuild 来生成 compile_commands.json")
    end
  end
end

-- 创建.clangd配置
function M.create_clangd_config()
  local config = require("qt-dev.config.paths")
  local qt_config = config.get_qt_config()
  
  local clangd_content = string.format([[CompileFlags:
  Add:
    - "-I%s/include"
    - "-I%s/include/QtCore"
    - "-I%s/include/QtGui"
    - "-I%s/include/QtWidgets"
    - "-I%s/include/QtQml"
    - "-I%s/include/QtQuick"
    - "-std=c++17"
    - "-DQT_CORE_LIB"
    - "-DQT_GUI_LIB"
    - "-DQT_WIDGETS_LIB"
  CompilationDatabase: build
]], qt_config.qt_path, qt_config.qt_path, qt_config.qt_path, 
    qt_config.qt_path, qt_config.qt_path, qt_config.qt_path)
  
  local file = io.open(".clangd", "w")
  if file then
    file:write(clangd_content)
    file:close()
    utils.success("✅ .clangd配置文件已创建")
    return true
  else
    utils.error("无法创建.clangd配置文件")
    return false
  end
end

-- 设置项目特定LSP
function M.setup_project_lsp()
  local user_config = require("qt-dev.config.user_config")
  if user_config.is_first_run() then
    utils.info("📁 项目LSP配置已应用")
  end
  
  -- 重启LSP以应用新配置
  vim.defer_fn(function()
    vim.cmd("LspRestart")
  end, 1000)
end

-- 获取LSP状态
function M.get_lsp_status()
  return {
    clangd_available = utils.executable_exists("clangd"),
    clangd_config_exists = utils.file_exists(".clangd"),
    compile_commands_exists = utils.file_exists("compile_commands.json"),
  }
end

return M