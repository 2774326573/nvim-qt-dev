-- 编译数据库管理模块 - nvim-qt-dev集成版本
local utils = require("qt-dev.core.utils")
local M = {}

-- 模块级别的变量来保存timer
local qt_compile_commands_timer = nil

-- 更新compile_commands.json
function M.update_compile_commands(project_dir)
  vim.notify("🔄 更新compile_commands.json...", vim.log.levels.INFO)
  
  local build_dir = project_dir .. (utils.is_windows() and "\\build" or "/build")
  local compile_commands_src = build_dir .. (utils.is_windows() and "\\compile_commands.json" or "/compile_commands.json")
  local compile_commands_dst = project_dir .. (utils.is_windows() and "\\compile_commands.json" or "/compile_commands.json")
  
  -- 检查源文件是否存在
  if vim.fn.filereadable(compile_commands_src) == 1 then
    -- 复制文件到项目根目录
    local copy_cmd
    if utils.is_windows() then
      copy_cmd = string.format('copy "%s" "%s"', compile_commands_src, compile_commands_dst)
    else
      copy_cmd = string.format('cp "%s" "%s"', compile_commands_src, compile_commands_dst)
    end
    
    vim.fn.system(copy_cmd)
    
    if vim.v.shell_error == 0 then
      vim.notify("✅ compile_commands.json 更新成功", vim.log.levels.INFO)
    else
      vim.notify("❌ compile_commands.json 更新失败", vim.log.levels.ERROR)
    end
  else
    vim.notify("⚠️ 未找到build目录中的compile_commands.json", vim.log.levels.WARN)
  end
end

-- 设置compile_commands监控
function M.setup_compile_commands_watcher(project_dir)
  local build_dir = project_dir .. (utils.is_windows() and "\\build" or "/build")
  local compile_commands_file = build_dir .. (utils.is_windows() and "\\compile_commands.json" or "/compile_commands.json")
  
  -- 如果已经有timer在运行，先停止它
  M.stop_compile_commands_watcher()
  
  -- 创建新的timer
  qt_compile_commands_timer = vim.loop.new_timer()
  
  if qt_compile_commands_timer then
    -- 每5秒检查一次
    qt_compile_commands_timer:start(5000, 5000, vim.schedule_wrap(function()
      if vim.fn.filereadable(compile_commands_file) == 1 then
        -- 检查文件是否需要更新
        local build_time = vim.fn.getftime(compile_commands_file)
        local project_file = project_dir .. (utils.is_windows() and "\\compile_commands.json" or "/compile_commands.json")
        local project_time = vim.fn.getftime(project_file)
        
        if build_time > project_time then
          M.update_compile_commands(project_dir)
        end
      end
    end))
  end
end

-- 停止compile_commands监控
function M.stop_compile_commands_watcher()
  if qt_compile_commands_timer then
    qt_compile_commands_timer:stop()
    qt_compile_commands_timer:close()
    qt_compile_commands_timer = nil
  end
end

return M