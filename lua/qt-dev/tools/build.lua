-- Qt项目构建工具模块
local utils = require("qt-dev.core.utils")
local detection = require("qt-dev.core.detection")
local M = {}

-- 获取构建目录
local function get_build_dir()
  return detection.detect_build_directory()
end

-- 确保构建目录存在
local function ensure_build_dir()
  local build_dir = get_build_dir()
  if not utils.dir_exists(build_dir) then
    if not utils.mkdir(build_dir) then
      utils.error("无法创建构建目录: " .. build_dir)
      return false
    end
    utils.info("创建构建目录: " .. build_dir)
  end
  return true, build_dir
end

-- 生成CMake构建文件
function M.configure_cmake()
  local ok, build_dir = ensure_build_dir()
  if not ok then return false end
  
  utils.info("配置CMake构建...")
  
  local cmd = {"cmake", "..", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"}
  local result = utils.run_command(cmd, {
    cwd = build_dir,
    wait = true,
    timeout = 30000
  })
  
  if result.exit_code == 0 then
    utils.success("CMake配置完成")
    
    -- 复制compile_commands.json到项目根目录
    local compile_commands_src = utils.join_path(build_dir, "compile_commands.json")
    local compile_commands_dst = "compile_commands.json"
    
    if utils.file_exists(compile_commands_src) then
      utils.copy_file(compile_commands_src, compile_commands_dst)
      utils.info("已更新 compile_commands.json")
    end
    
    return true
  else
    utils.error("CMake配置失败")
    if result.stderr and #result.stderr > 0 then
      utils.error("错误信息: " .. table.concat(result.stderr, "\n"))
    end
    return false
  end
end

-- 构建项目
function M.build_project()
  local project_info = detection.get_project_info()
  if not project_info.is_qt_project then
    utils.warn("当前目录不是Qt项目")
    return false
  end
  
  -- 如果没有构建文件，先配置CMake
  local build_dir = get_build_dir()
  local cmake_cache = utils.join_path(build_dir, "CMakeCache.txt")
  if not utils.file_exists(cmake_cache) then
    if not M.configure_cmake() then
      return false
    end
  end
  
  utils.info(string.format("构建项目: %s", project_info.name))
  
  local cmd = {"cmake", "--build", ".", "--config", "Debug"}
  local result = utils.run_command(cmd, {
    cwd = build_dir,
    wait = true,
    timeout = 60000
  })
  
  if result.exit_code == 0 then
    utils.success("项目构建成功")
    return true
  else
    utils.error("项目构建失败")
    if result.stderr and #result.stderr > 0 then
      utils.error("错误信息: " .. table.concat(result.stderr, "\n"))
    end
    return false
  end
end

-- 构建Debug版本
function M.build_debug_project()
  local build_dir = get_build_dir()
  
  utils.info("构建Debug版本...")
  
  local cmd = {"cmake", "--build", ".", "--config", "Debug"}
  local result = utils.run_command(cmd, {
    cwd = build_dir,
    wait = true,
    timeout = 60000
  })
  
  if result.exit_code == 0 then
    utils.success("Debug版本构建成功")
    return true
  else
    utils.error("Debug版本构建失败")
    return false
  end
end

-- 构建Release版本
function M.build_release_project()
  local build_dir = get_build_dir()
  
  utils.info("构建Release版本...")
  
  local cmd = {"cmake", "--build", ".", "--config", "Release"}
  local result = utils.run_command(cmd, {
    cwd = build_dir,
    wait = true,
    timeout = 60000
  })
  
  if result.exit_code == 0 then
    utils.success("Release版本构建成功")
    return true
  else
    utils.error("Release版本构建失败")
    return false
  end
end

-- 清理构建
function M.clean_project()
  local build_dir = get_build_dir()
  
  if not utils.dir_exists(build_dir) then
    utils.warn("构建目录不存在，无需清理")
    return true
  end
  
  utils.info("清理构建目录...")
  
  local cmd = {"cmake", "--build", ".", "--target", "clean"}
  local result = utils.run_command(cmd, {
    cwd = build_dir,
    wait = true,
    timeout = 30000
  })
  
  if result.exit_code == 0 then
    utils.success("构建清理完成")
    return true
  else
    -- 如果cmake clean失败，尝试删除构建目录
    utils.warn("CMake清理失败，尝试删除构建目录...")
    
    local rm_cmd = utils.is_windows() and {"rmdir", "/s", "/q", build_dir} or {"rm", "-rf", build_dir}
    local rm_result = utils.run_command(rm_cmd, {wait = true})
    
    if rm_result.exit_code == 0 then
      utils.success("构建目录删除成功")
      return true
    else
      utils.error("清理构建失败")
      return false
    end
  end
end

-- 运行项目
function M.run_project()
  local project_info = detection.get_project_info()
  if not project_info.is_qt_project then
    utils.warn("当前目录不是Qt项目")
    return false
  end
  
  -- 先尝试构建项目
  if not M.build_project() then
    utils.error("构建失败，无法运行项目")
    return false
  end
  
  -- 查找可执行文件
  local exe_path = detection.detect_executable()
  if not exe_path then
    utils.error("找不到可执行文件")
    return false
  end
  
  utils.info(string.format("运行项目: %s", exe_path))
  
  -- 在新终端中运行（异步）
  local cmd = {exe_path}
  utils.run_command(cmd, {
    cwd = utils.get_cwd(),
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        utils.info("程序正常退出")
      else
        utils.warn(string.format("程序退出，退出码: %d", exit_code))
      end
    end
  })
  
  utils.success("项目已启动")
  return true
end

-- 设置项目构建
function M.setup_project_build(project_info)
  if not project_info.is_qt_project then
    return
  end
  
  -- 自动配置CMake（如果需要）
  local build_dir = get_build_dir()
  local cmake_cache = utils.join_path(build_dir, "CMakeCache.txt")
  
  if not utils.file_exists(cmake_cache) and utils.file_exists("CMakeLists.txt") then
    utils.info("检测到新的Qt项目，自动配置构建...")
    M.configure_cmake()
  end
end

-- CMake文件变更处理
function M.on_cmake_change()
  utils.info("检测到CMake文件变更，重新配置...")
  M.configure_cmake()
  
  -- 重启LSP以便更新智能提示
  vim.cmd("LspRestart")
end

-- 获取构建状态
function M.get_build_status()
  local build_dir = get_build_dir()
  local cmake_cache = utils.join_path(build_dir, "CMakeCache.txt")
  
  return {
    build_dir_exists = utils.dir_exists(build_dir),
    cmake_configured = utils.file_exists(cmake_cache),
    compile_commands_exists = utils.file_exists("compile_commands.json"),
    executable_exists = detection.detect_executable() ~= nil
  }
end

return M