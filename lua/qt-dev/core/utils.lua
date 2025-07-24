-- Qt开发插件工具函数模块
local M = {}

-- 检测是否为Windows系统
function M.is_windows()
  return vim.loop.os_uname().sysname == "Windows_NT" or 
         vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

-- 检测是否为Linux系统
function M.is_linux()
  return vim.loop.os_uname().sysname == "Linux"
end

-- 检测是否为WSL环境
function M.is_wsl()
  if not M.is_linux() then
    return false
  end
  
  local wsl_env = os.getenv("WSL_DISTRO_NAME")
  if wsl_env then
    return true
  end
  
  -- 检查/proc/version文件
  local file = io.open("/proc/version", "r")
  if file then
    local content = file:read("*a")
    file:close()
    return content:lower():find("microsoft") ~= nil
  end
  
  return false
end

-- 获取路径分隔符
function M.path_separator()
  return M.is_windows() and "\\" or "/"
end

-- 规范化路径
function M.normalize_path(path)
  if not path then return "" end
  
  -- 将所有斜杠统一为当前系统的路径分隔符
  local sep = M.path_separator()
  path = path:gsub("[/\\]", sep)
  
  -- 移除末尾的路径分隔符
  path = path:gsub(sep .. "+$", "")
  
  return path
end

-- 连接路径
function M.join_path(...)
  local parts = {...}
  local sep = M.path_separator()
  local result = ""
  
  for i, part in ipairs(parts) do
    if part and part ~= "" then
      part = M.normalize_path(part)
      if i == 1 then
        result = part
      else
        result = result .. sep .. part
      end
    end
  end
  
  return result
end

-- 检查文件是否存在
function M.file_exists(path)
  return vim.fn.filereadable(path) == 1
end

-- 检查目录是否存在
function M.dir_exists(path)
  return vim.fn.isdirectory(path) == 1
end

-- 检查可执行文件是否存在
function M.executable_exists(name)
  return vim.fn.executable(name) == 1
end

-- 获取当前工作目录
function M.get_cwd()
  return vim.fn.getcwd()
end

-- 查找项目根目录
function M.find_project_root(markers)
  markers = markers or {"CMakeLists.txt", ".git", "*.pro", "*.pri"}
  
  local current_dir = M.get_cwd()
  local root_dir = vim.fn.fnamemodify(current_dir, ":p")
  
  while root_dir ~= "/" and root_dir ~= "" do
    for _, marker in ipairs(markers) do
      local marker_path = M.join_path(root_dir, marker)
      if marker:match("%*") then
        -- 使用glob模式匹配
        local glob_result = vim.fn.glob(marker_path)
        if glob_result ~= "" then
          return root_dir
        end
      else
        -- 直接文件/目录检查
        if M.file_exists(marker_path) or M.dir_exists(marker_path) then
          return root_dir
        end
      end
    end
    
    -- 向上一级目录
    local parent = vim.fn.fnamemodify(root_dir, ":h")
    if parent == root_dir then
      break
    end
    root_dir = parent
  end
  
  return current_dir
end

-- 执行系统命令
function M.run_command(cmd, opts)
  opts = opts or {}
  
  local job_opts = {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = opts.on_exit,
  }
  
  if opts.cwd then
    job_opts.cwd = opts.cwd
  end
  
  local stdout = {}
  local stderr = {}
  
  job_opts.on_stdout = function(_, data)
    if data then
      vim.list_extend(stdout, data)
    end
  end
  
  job_opts.on_stderr = function(_, data)
    if data then
      vim.list_extend(stderr, data)
    end
  end
  
  local job_id = vim.fn.jobstart(cmd, job_opts)
  
  if opts.wait then
    vim.fn.jobwait({job_id}, opts.timeout or 10000)
    return {
      stdout = stdout,
      stderr = stderr,
      exit_code = vim.v.shell_error or 0
    }
  end
  
  return job_id
end

-- 显示通知
function M.notify(msg, level, opts)
  level = level or vim.log.levels.INFO
  opts = opts or {}
  
  vim.notify(msg, level, opts)
end

-- 错误通知
function M.error(msg)
  M.notify("❌ " .. msg, vim.log.levels.ERROR)
end

-- 警告通知
function M.warn(msg)
  M.notify("⚠️ " .. msg, vim.log.levels.WARN)
end

-- 信息通知
function M.info(msg)
  M.notify("ℹ️ " .. msg, vim.log.levels.INFO)
end

-- 成功通知
function M.success(msg)
  M.notify("✅ " .. msg, vim.log.levels.INFO)
end

-- 修复常见插件问题
function M.fix_common_plugin_issues()
  M.info("开始修复常见插件问题...")
  
  -- 重启LSP
  vim.cmd("LspRestart")
  
  -- 清理插件缓存
  if M.dir_exists(vim.fn.stdpath("cache") .. "/lua") then
    vim.cmd("!rm -rf " .. vim.fn.stdpath("cache") .. "/lua")
  end
  
  M.success("插件问题修复完成")
end

-- 创建目录
function M.mkdir(path, recursive)
  recursive = recursive == nil and true or recursive
  
  if recursive then
    return vim.fn.mkdir(path, "p") == 1
  else
    return vim.fn.mkdir(path) == 1
  end
end

-- 复制文件
function M.copy_file(src, dst)
  local src_file = io.open(src, "r")
  if not src_file then
    return false, "无法读取源文件: " .. src
  end
  
  local content = src_file:read("*a")
  src_file:close()
  
  local dst_dir = vim.fn.fnamemodify(dst, ":h")
  if not M.dir_exists(dst_dir) then
    if not M.mkdir(dst_dir) then
      return false, "无法创建目标目录: " .. dst_dir
    end
  end
  
  local dst_file = io.open(dst, "w")
  if not dst_file then
    return false, "无法写入目标文件: " .. dst
  end
  
  dst_file:write(content)
  dst_file:close()
  
  return true
end

-- 字符串处理工具
function M.trim(str)
  return str:match("^%s*(.-)%s*$")
end

function M.split(str, delimiter)
  delimiter = delimiter or "%s"
  local result = {}
  for match in str:gmatch("([^" .. delimiter .. "]+)") do
    table.insert(result, match)
  end
  return result
end

return M