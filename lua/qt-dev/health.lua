-- nvim-qt-dev 健康检查模块
local utils = require("qt-dev.core.utils")
local environment = require("qt-dev.core.environment")
local detection = require("qt-dev.core.detection")
local M = {}

-- 执行健康检查
function M.check()
  local health = {}
  
  -- 检查基本环境
  local env_info = environment.get_info()
  
  -- 系统检查
  table.insert(health, {
    type = "info",
    message = string.format("操作系统: %s (%s)", env_info.system.os, env_info.system.arch)
  })
  
  table.insert(health, {
    type = "info", 
    message = string.format("Neovim版本: %s", vim.inspect(env_info.system.neovim_version))
  })
  
  -- Qt环境检查
  if env_info.qt.qmake_available then
    table.insert(health, {
      type = "ok",
      message = "qmake 可用"
    })
  else
    table.insert(health, {
      type = "error",
      message = "qmake 不可用",
      advice = "请检查Qt安装和PATH环境变量"
    })
  end
  
  if env_info.qt.cmake_available then
    table.insert(health, {
      type = "ok",
      message = "cmake 可用"
    })
  else
    table.insert(health, {
      type = "warn",
      message = "cmake 不可用",
      advice = "建议安装CMake以获得更好的构建体验"
    })
  end
  
  -- 编译器检查
  local has_compiler = env_info.compilers.gcc or env_info.compilers.clang or env_info.compilers.msvc
  if has_compiler then
    local compilers = {}
    if env_info.compilers.gcc then table.insert(compilers, "GCC") end
    if env_info.compilers.clang then table.insert(compilers, "Clang") end  
    if env_info.compilers.msvc then table.insert(compilers, "MSVC") end
    
    table.insert(health, {
      type = "ok",
      message = string.format("C++编译器可用: %s", table.concat(compilers, ", "))
    })
  else
    table.insert(health, {
      type = "error",
      message = "未检测到C++编译器",
      advice = "请安装GCC、Clang或MSVC编译器"
    })
  end
  
  -- LSP检查
  if env_info.lsp.clangd_available then
    table.insert(health, {
      type = "ok",
      message = "clangd LSP服务器可用"
    })
  elseif env_info.lsp.ccls_available then
    table.insert(health, {
      type = "ok", 
      message = "ccls LSP服务器可用"
    })
  else
    table.insert(health, {
      type = "warn",
      message = "未检测到LSP服务器(clangd/ccls)",
      advice = "建议安装clangd以获得智能代码提示"
    })
  end
  
  -- 项目检查（如果在Qt项目中）
  local project_info = detection.get_project_info()
  if project_info.is_qt_project then
    table.insert(health, {
      type = "info",
      message = string.format("当前项目: %s (%s)", project_info.name, project_info.type_display)
    })
    
    if utils.file_exists("compile_commands.json") then
      table.insert(health, {
        type = "ok",
        message = "compile_commands.json 存在"
      })
    else
      table.insert(health, {
        type = "warn",
        message = "compile_commands.json 缺失",
        advice = "运行 :QtBuild 来生成编译数据库"
      })
    end
    
    if utils.file_exists(".clangd") then
      table.insert(health, {
        type = "ok",
        message = ".clangd 配置文件存在"
      })
    else
      table.insert(health, {
        type = "warn",
        message = ".clangd 配置文件缺失",
        advice = "运行 :QtStatus 来自动创建配置文件"
      })
    end
  end
  
  return health
end

return M