-- Qt开发环境检测模块
local utils = require("qt-dev.core.utils")
local M = {}

-- 检测系统环境
function M.detect_system_info()
  local system = {
    os = vim.loop.os_uname().sysname,
    arch = vim.loop.os_uname().machine,
    is_windows = utils.is_windows(),
    is_linux = utils.is_linux(),
    is_wsl = utils.is_wsl(),
    neovim_version = vim.version(),
  }
  
  return system
end

-- 检测Qt环境
function M.detect_qt_environment()
  local qt_env = {
    qt_dir = os.getenv("QT_DIR"),
    qtdir = os.getenv("QTDIR"),
    cmake_prefix_path = os.getenv("CMAKE_PREFIX_PATH"),
    path = os.getenv("PATH"),
  }
  
  -- 检测qmake
  qt_env.qmake_available = utils.executable_exists("qmake")
  if qt_env.qmake_available then
    local result = utils.run_command({"qmake", "--version"}, {wait = true})
    if result.stdout and #result.stdout > 0 then
      qt_env.qmake_version = table.concat(result.stdout, "\n")
    end
  end
  
  -- 检测cmake
  qt_env.cmake_available = utils.executable_exists("cmake")
  if qt_env.cmake_available then
    local result = utils.run_command({"cmake", "--version"}, {wait = true})
    if result.stdout and #result.stdout > 0 then
      qt_env.cmake_version = result.stdout[1]
    end
  end
  
  return qt_env
end

-- 检测编译器环境
function M.detect_compiler_environment()
  local compilers = {}
  
  -- 检测GCC
  if utils.executable_exists("gcc") then
    local result = utils.run_command({"gcc", "--version"}, {wait = true})
    if result.stdout and #result.stdout > 0 then
      compilers.gcc = {
        available = true,
        version = result.stdout[1]
      }
    end
  end
  
  -- 检测Clang
  if utils.executable_exists("clang") then
    local result = utils.run_command({"clang", "--version"}, {wait = true})
    if result.stdout and #result.stdout > 0 then
      compilers.clang = {
        available = true,
        version = result.stdout[1]
      }
    end
  end
  
  -- 检测MSVC (Windows)
  if utils.is_windows() then
    if utils.executable_exists("cl") then
      compilers.msvc = {
        available = true,
        version = "检测到MSVC编译器"
      }
    end
  end
  
  return compilers
end

-- 检测LSP环境
function M.detect_lsp_environment()
  local lsp = {}
  
  -- 检测clangd
  lsp.clangd_available = utils.executable_exists("clangd")
  if lsp.clangd_available then
    local result = utils.run_command({"clangd", "--version"}, {wait = true})
    if result.stdout and #result.stdout > 0 then
      lsp.clangd_version = result.stdout[1]
    end
  end
  
  -- 检测ccls
  lsp.ccls_available = utils.executable_exists("ccls")
  
  -- 检查.clangd配置文件
  lsp.clangd_config_exists = utils.file_exists(".clangd")
  
  -- 检查compile_commands.json
  lsp.compile_commands_exists = utils.file_exists("compile_commands.json")
  
  return lsp
end

-- 获取完整环境信息
function M.get_info()
  return {
    system = M.detect_system_info(),
    qt = M.detect_qt_environment(),
    compilers = M.detect_compiler_environment(),
    lsp = M.detect_lsp_environment(),
  }
end

-- 快速环境检查
function M.quick_environment_check()
  local info = M.get_info()
  local issues = {}
  
  -- 检查Qt环境
  if not info.qt.qmake_available then
    table.insert(issues, "qmake不可用，请检查Qt安装")
  end
  
  if not info.qt.cmake_available then
    table.insert(issues, "cmake不可用，请安装CMake")
  end
  
  -- 检查编译器
  local has_compiler = info.compilers.gcc or info.compilers.clang or info.compilers.msvc
  if not has_compiler then
    table.insert(issues, "未检测到可用的C++编译器")
  end
  
  -- 检查LSP
  if not info.lsp.clangd_available and not info.lsp.ccls_available then
    table.insert(issues, "未检测到LSP服务器（clangd或ccls）")
  end
  
  -- 显示结果
  if #issues == 0 then
    utils.success("Qt开发环境检查通过")
  else
    utils.warn("发现环境问题:")
    for _, issue in ipairs(issues) do
      utils.warn("  • " .. issue)
    end
  end
  
  return #issues == 0, issues
end

-- 显示完整环境报告
function M.show_full_environment_report()
  local info = M.get_info()
  
  local report = {
    "🖥️ Qt开发环境报告",
    "=" .. string.rep("=", 30),
    "",
    "📋 系统信息:",
    string.format("  操作系统: %s (%s)", info.system.os, info.system.arch),
    string.format("  Neovim版本: %s", vim.inspect(info.system.neovim_version)),
    ""
  }
  
  -- Qt环境信息
  table.insert(report, "🎯 Qt环境:")
  table.insert(report, string.format("  QT_DIR: %s", info.qt.qt_dir or "未设置"))
  table.insert(report, string.format("  qmake: %s", info.qt.qmake_available and "✅ 可用" or "❌ 不可用"))
  if info.qt.qmake_version then
    table.insert(report, string.format("  qmake版本: %s", info.qt.qmake_version:match("[^\n]+") or ""))
  end
  table.insert(report, string.format("  cmake: %s", info.qt.cmake_available and "✅ 可用" or "❌ 不可用"))
  if info.qt.cmake_version then
    table.insert(report, string.format("  cmake版本: %s", info.qt.cmake_version))
  end
  table.insert(report, "")
  
  -- 编译器信息
  table.insert(report, "🔧 编译器:")
  if info.compilers.gcc then
    table.insert(report, string.format("  GCC: ✅ %s", info.compilers.gcc.version:match("[^\n]+") or ""))
  end
  if info.compilers.clang then
    table.insert(report, string.format("  Clang: ✅ %s", info.compilers.clang.version:match("[^\n]+") or ""))
  end
  if info.compilers.msvc then
    table.insert(report, string.format("  MSVC: ✅ %s", info.compilers.msvc.version))
  end
  if not (info.compilers.gcc or info.compilers.clang or info.compilers.msvc) then
    table.insert(report, "  ❌ 未检测到C++编译器")
  end
  table.insert(report, "")
  
  -- LSP信息
  table.insert(report, "🔍 LSP环境:")
  table.insert(report, string.format("  clangd: %s", info.lsp.clangd_available and "✅ 可用" or "❌ 不可用"))
  if info.lsp.clangd_version then
    table.insert(report, string.format("  clangd版本: %s", info.lsp.clangd_version:match("[^\n]+") or ""))
  end
  table.insert(report, string.format("  ccls: %s", info.lsp.ccls_available and "✅ 可用" or "❌ 不可用"))
  table.insert(report, string.format("  .clangd配置: %s", info.lsp.clangd_config_exists and "✅ 存在" or "❌ 不存在"))
  table.insert(report, string.format("  compile_commands.json: %s", info.lsp.compile_commands_exists and "✅ 存在" or "❌ 不存在"))
  
  local report_text = table.concat(report, "\n")
  utils.info(report_text)
  
  return info
end

return M