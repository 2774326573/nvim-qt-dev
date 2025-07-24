-- Qt项目状态检查工具模块
local utils = require("qt-dev.core.utils")
local detection = require("qt-dev.core.detection")
local environment = require("qt-dev.core.environment")
local build = require("qt-dev.tools.build")
local designer = require("qt-dev.tools.designer")
local M = {}

-- 检查项目状态
function M.check_project_status()
  utils.info("🔍 检查Qt项目状态...")
  
  local project_info = detection.get_project_info()
  local build_status = build.get_build_status()
  local designer_status = designer.get_designer_status()
  local env_ok, env_issues = environment.quick_environment_check()
  
  -- 生成状态报告
  local report = {
    "📊 Qt项目状态报告",
    "=" .. string.rep("=", 30),
    ""
  }
  
  -- 项目信息
  table.insert(report, "📁 项目信息:")
  if project_info.is_qt_project then
    table.insert(report, string.format("  ✅ Qt项目: %s (%s)", project_info.name, project_info.type_display))
    table.insert(report, string.format("  📁 项目根目录: %s", project_info.root))
    table.insert(report, string.format("  🔧 构建系统: %s", project_info.build_system))
  else
    table.insert(report, "  ❌ 当前目录不是Qt项目")
  end
  table.insert(report, "")
  
  -- 构建状态
  table.insert(report, "🛠️ 构建状态:")
  table.insert(report, string.format("  构建目录: %s", build_status.build_dir_exists and "✅ 存在" or "❌ 不存在"))
  table.insert(report, string.format("  CMake配置: %s", build_status.cmake_configured and "✅ 已配置" or "❌ 未配置"))
  table.insert(report, string.format("  compile_commands.json: %s", build_status.compile_commands_exists and "✅ 存在" or "❌ 不存在"))
  table.insert(report, string.format("  可执行文件: %s", build_status.executable_exists and "✅ 存在" or "❌ 不存在"))
  table.insert(report, "")
  
  -- Qt Designer状态
  table.insert(report, "🎨 Qt Designer:")
  table.insert(report, string.format("  Designer可用: %s", designer_status.available and "✅ 可用" or "❌ 不可用"))
  table.insert(report, string.format("  UI文件数量: %d", designer_status.ui_files_count))
  table.insert(report, "")
  
  -- 环境状态
  table.insert(report, "🌍 环境状态:")
  if env_ok then
    table.insert(report, "  ✅ 环境检查通过")
  else
    table.insert(report, "  ❌ 发现环境问题:")
    for _, issue in ipairs(env_issues) do
      table.insert(report, "    • " .. issue)
    end
  end
  
  local report_text = table.concat(report, "\n")
  utils.info(report_text)
  
  return {
    project = project_info,
    build = build_status,
    designer = designer_status,
    environment_ok = env_ok,
    environment_issues = env_issues
  }
end

-- 快速诊断
function M.quick_diagnose()
  utils.info("⚡ 快速诊断...")
  
  local issues = {}
  local suggestions = {}
  
  -- 检查是否为Qt项目
  local project_info = detection.get_project_info()
  if not project_info.is_qt_project then
    table.insert(issues, "当前目录不是Qt项目")
    table.insert(suggestions, "请切换到Qt项目目录或创建新的Qt项目")
    
    utils.warn("诊断结果:")
    utils.warn("  问题: " .. issues[1])
    utils.info("  建议: " .. suggestions[1])
    return issues, suggestions
  end
  
  -- 检查构建配置
  local build_status = build.get_build_status()
  if not build_status.cmake_configured then
    table.insert(issues, "CMake未配置")
    table.insert(suggestions, "运行 :QtBuild 或手动执行 cmake 配置")
  end
  
  if not build_status.compile_commands_exists then
    table.insert(issues, "缺少compile_commands.json，LSP可能无法正常工作")
    table.insert(suggestions, "重新配置CMake以生成compile_commands.json")
  end
  
  -- 检查环境
  local env_ok, env_issues = environment.quick_environment_check()
  if not env_ok then
    for _, issue in ipairs(env_issues) do
      table.insert(issues, issue)
    end
    table.insert(suggestions, "请检查Qt安装和环境配置")
  end
  
  -- 显示诊断结果
  if #issues == 0 then
    utils.success("✅ 快速诊断通过，项目状态良好")
  else
    utils.warn("⚠️ 发现以下问题:")
    for i, issue in ipairs(issues) do
      utils.warn(string.format("  %d. %s", i, issue))
    end
    
    utils.info("💡 建议解决方案:")
    for i, suggestion in ipairs(suggestions) do
      utils.info(string.format("  %d. %s", i, suggestion))
    end
  end
  
  return issues, suggestions
end

-- 自动修复常见问题
function M.auto_fix_common_issues()
  utils.info("🔧 自动修复常见问题...")
  
  local fixes_applied = {}
  local project_info = detection.get_project_info()
  
  if not project_info.is_qt_project then
    utils.warn("当前目录不是Qt项目，无法自动修复")
    return fixes_applied
  end
  
  -- 修复1: 配置CMake
  local build_status = build.get_build_status()
  if not build_status.cmake_configured then
    utils.info("修复: 配置CMake...")
    if build.configure_cmake() then
      table.insert(fixes_applied, "CMake配置")
    end
  end
  
  -- 修复2: 创建.clangd配置
  if not utils.file_exists(".clangd") then
    utils.info("修复: 创建.clangd配置...")
    if M.create_clangd_config() then
      table.insert(fixes_applied, ".clangd配置文件")
    end
  end
  
  -- 修复3: 重启LSP
  utils.info("修复: 重启LSP服务...")
  vim.cmd("LspRestart")
  table.insert(fixes_applied, "LSP重启")
  
  -- 显示修复结果
  if #fixes_applied > 0 then
    utils.success("✅ 自动修复完成，应用了以下修复:")
    for i, fix in ipairs(fixes_applied) do
      utils.info(string.format("  %d. %s", i, fix))
    end
  else
    utils.info("ℹ️ 没有发现需要自动修复的问题")
  end
  
  return fixes_applied
end

-- 创建.clangd配置文件
function M.create_clangd_config()
  local config = require("qt-dev.config.paths")
  local qt_config = config.get_qt_config()
  
  local clangd_content = string.format([[CompileFlags:
  Add:
    - "-I%s/include"
    - "-I%s/include/QtCore"
    - "-I%s/include/QtGui"
    - "-I%s/include/QtWidgets"
    - "-std=c++17"
  CompilationDatabase: build
]], qt_config.qt_path, qt_config.qt_path, qt_config.qt_path, qt_config.qt_path)
  
  local file = io.open(".clangd", "w")
  if not file then
    utils.error("无法创建.clangd配置文件")
    return false
  end
  
  file:write(clangd_content)
  file:close()
  
  utils.success("✅ .clangd配置文件创建成功")
  return true
end

-- 获取项目健康评分
function M.get_project_health_score()
  local score = 0
  local max_score = 10
  
  local project_info = detection.get_project_info()
  if project_info.is_qt_project then
    score = score + 2 -- Qt项目基础分
  else
    return 0, max_score, "不是Qt项目"
  end
  
  local build_status = build.get_build_status()
  if build_status.cmake_configured then score = score + 2 end
  if build_status.compile_commands_exists then score = score + 2 end
  if build_status.executable_exists then score = score + 1 end
  
  local env_ok = environment.quick_environment_check()
  if env_ok then score = score + 2 end
  
  if utils.file_exists(".clangd") then score = score + 1 end
  
  local health_level = "差"
  if score >= 8 then
    health_level = "优秀"
  elseif score >= 6 then
    health_level = "良好"
  elseif score >= 4 then
    health_level = "一般"
  end
  
  return score, max_score, health_level
end

-- 项目健康检查
function M.health_check()
  local score, max_score, level = M.get_project_health_score()
  local percentage = math.floor((score / max_score) * 100)
  
  utils.info(string.format("📊 项目健康评分: %d/%d (%d%%) - %s", 
    score, max_score, percentage, level))
  
  if score < max_score then
    utils.info("💡 运行 :QtStatus 查看详细信息和改进建议")
  end
  
  return score, max_score, level
end

return M