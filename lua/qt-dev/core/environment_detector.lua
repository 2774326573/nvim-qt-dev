-- 环境检测和建议工具 - nvim-qt-dev集成版本
local utils = require("qt-dev.core.utils")
local M = {}

-- 全面的环境检测
function M.detect_development_environment()
  local env_info = {
    -- 基础环境
    is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1,
    is_vscode = vim.env.VSCODE ~= nil or vim.env.VSCODE_CWD ~= nil,
    
    -- 显示环境
    display = os.getenv("DISPLAY"),
    wayland_display = os.getenv("WAYLAND_DISPLAY"),
    
    -- 开发工具
    has_git = vim.fn.executable("git") == 1,
    has_cmake = vim.fn.executable("cmake") == 1,
    has_ninja = vim.fn.executable("ninja") == 1,
    has_make = vim.fn.executable("make") == 1,
    
    -- Qt工具
    has_qmake = vim.fn.executable("qmake") == 1,
    has_qmake6 = vim.fn.executable("qmake6") == 1,
    has_designer = vim.fn.executable("designer") == 1,
    has_uic = vim.fn.executable("uic") == 1,
    has_moc = vim.fn.executable("moc") == 1,
    
    -- 编译器
    has_gcc = vim.fn.executable("gcc") == 1,
    has_clang = vim.fn.executable("clang") == 1,
    has_cl = vim.fn.executable("cl") == 1,
  }
  
  -- 确定环境类型
  if env_info.is_windows then
    env_info.env_type = "Windows"
    env_info.platform = "windows"
    env_info.has_gui = true
  else
    env_info.env_type = "Linux"
    env_info.platform = "linux"
    env_info.has_gui = env_info.display ~= nil or env_info.wayland_display ~= nil
  end
  
  -- VS Code集成状态
  if env_info.is_vscode then
    env_info.env_type = env_info.env_type .. " + VS Code"
  end
  
  return env_info
end

-- 生成环境报告
function M.generate_environment_report()
  local env_info = M.detect_development_environment()
  local report = {}
  
  -- 标题
  table.insert(report, "🔍 Qt开发环境检测报告")
  table.insert(report, string.rep("=", 50))
  table.insert(report, "")
  
  -- 基础环境信息
  table.insert(report, "📋 基础环境信息:")
  table.insert(report, "  环境类型: " .. env_info.env_type)
  table.insert(report, "  平台: " .. (env_info.platform == "windows" and "Windows" or "Linux"))
  
  -- GUI支持
  table.insert(report, "")
  table.insert(report, "🖥️ GUI支持:")
  if env_info.platform == "windows" then
    table.insert(report, "  Windows GUI: ✅ 原生支持")
  else
    if env_info.has_gui then
      local display_info = env_info.wayland_display and ("Wayland: " .. env_info.wayland_display) 
                          or env_info.display and ("X11: " .. env_info.display) 
                          or "未知显示协议"
      table.insert(report, "  GUI支持: ✅ " .. display_info)
    else
      table.insert(report, "  GUI支持: ❌ 未配置")
    end
  end
  
  -- 开发工具检测
  table.insert(report, "")
  table.insert(report, "⚙️ 开发工具:")
  local tools = {
    {name = "Git", cmd = "git", has = env_info.has_git},
    {name = "CMake", cmd = "cmake", has = env_info.has_cmake},
    {name = "Ninja", cmd = "ninja", has = env_info.has_ninja},
    {name = "Make", cmd = "make", has = env_info.has_make},
  }
  
  for _, tool in ipairs(tools) do
    local status = tool.has and "✅" or "❌"
    local version = ""
    if tool.has then
      local handle = io.popen(tool.cmd .. " --version 2>/dev/null")
      if handle then
        version = " (" .. (handle:read("*line") or "版本未知") .. ")"
        handle:close()
      end
    end
    table.insert(report, "  " .. tool.name .. ": " .. status .. version)
  end
  
  -- Qt工具检测
  table.insert(report, "")
  table.insert(report, "🛠️ Qt工具:")
  local qt_tools = {
    {name = "QMake", cmd = "qmake", has = env_info.has_qmake},
    {name = "QMake6", cmd = "qmake6", has = env_info.has_qmake6},
    {name = "Designer", cmd = "designer", has = env_info.has_designer},
    {name = "UIC", cmd = "uic", has = env_info.has_uic},
    {name = "MOC", cmd = "moc", has = env_info.has_moc},
  }
  
  for _, tool in ipairs(qt_tools) do
    local status = tool.has and "✅" or "❌"
    table.insert(report, "  " .. tool.name .. ": " .. status)
  end
  
  -- 编译器检测
  table.insert(report, "")
  table.insert(report, "🔧 编译器:")
  local compilers = {
    {name = "GCC", cmd = "gcc", has = env_info.has_gcc},
    {name = "Clang", cmd = "clang", has = env_info.has_clang},
    {name = "MSVC", cmd = "cl", has = env_info.has_cl},
  }
  
  for _, compiler in ipairs(compilers) do
    local status = compiler.has and "✅" or "❌"
    local version = ""
    if compiler.has then
      local version_cmd = compiler.cmd == "cl" and "cl 2>&1 | head -1" or compiler.cmd .. " --version | head -1"
      local handle = io.popen(version_cmd .. " 2>/dev/null")
      if handle then
        version = " (" .. (handle:read("*line") or "版本未知") .. ")"
        handle:close()
      end
    end
    table.insert(report, "  " .. compiler.name .. ": " .. status .. version)
  end
  
  return report, env_info
end

-- 生成安装建议
function M.generate_installation_suggestions(env_info)
  local suggestions = {}
  
  table.insert(suggestions, "")
  table.insert(suggestions, "💡 安装建议:")
  table.insert(suggestions, string.rep("-", 30))
  
  -- Windows环境建议
  if env_info.is_windows then
    table.insert(suggestions, "")
    table.insert(suggestions, "🪟 Windows环境建议:")
    
    if not env_info.has_qmake then
      table.insert(suggestions, "  📦 建议安装Qt:")
      table.insert(suggestions, "    下载Qt在线安装器: https://www.qt.io/download")
      table.insert(suggestions, "    推荐安装路径: C:\\Qt\\ 或 D:\\install\\Qt\\")
    end
    
  -- 纯Linux环境建议
  else
    table.insert(suggestions, "")
    table.insert(suggestions, "🐧 Linux环境优化:")
    
    if not env_info.has_qmake and not env_info.has_qmake6 then
      table.insert(suggestions, "  📦 安装Qt开发环境:")
      table.insert(suggestions, "    # Ubuntu/Debian:")
      table.insert(suggestions, "    sudo apt install qt6-base-dev qt6-tools-dev")
      table.insert(suggestions, "    # Fedora:")
      table.insert(suggestions, "    sudo dnf install qt6-qtbase-devel qt6-qttools-devel")
      table.insert(suggestions, "    # Arch:")
      table.insert(suggestions, "    sudo pacman -S qt6-base qt6-tools")
    end
  end
  
  -- 通用建议
  table.insert(suggestions, "")
  table.insert(suggestions, "🎯 nvim-qt-dev使用建议:")
  table.insert(suggestions, "  <leader>qst - 完整状态检查")
  table.insert(suggestions, "  <leader>qsd - 快速诊断")
  table.insert(suggestions, "  <leader>qsf - 自动修复问题")
  
  return suggestions
end

-- 显示完整环境报告
function M.show_full_environment_report()
  local report, env_info = M.generate_environment_report()
  local suggestions = M.generate_installation_suggestions(env_info)
  
  -- 合并报告和建议
  for _, suggestion in ipairs(suggestions) do
    table.insert(report, suggestion)
  end
  
  -- 显示报告
  for _, line in ipairs(report) do
    vim.notify(line, vim.log.levels.INFO)
  end
  
  return env_info
end

-- 快速环境检查
function M.quick_environment_check()
  local env_info = M.detect_development_environment()
  
  -- 快速状态
  local status = "🔍 环境: " .. env_info.env_type
  
  vim.notify(status, vim.log.levels.INFO)
  
  -- 关键工具状态
  local qt_status = (env_info.has_qmake or env_info.has_qmake6) and "✅" or "❌"
  local build_status = env_info.has_cmake and "✅" or "❌"
  local gui_status = env_info.has_gui and "✅" or "❌"
  
  vim.notify(string.format("Qt: %s | 构建工具: %s | GUI: %s", qt_status, build_status, gui_status), vim.log.levels.INFO)
  
  -- 给出下一步建议
  if not (env_info.has_qmake or env_info.has_qmake6) then
    vim.notify("💡 需要安装Qt开发环境", vim.log.levels.WARN)
  elseif not env_info.has_cmake then
    vim.notify("💡 需要安装CMake构建工具", vim.log.levels.WARN)
  else
    vim.notify("🎉 环境已就绪，可以开始Qt开发！", vim.log.levels.INFO)
  end
  
  return env_info
end

return M