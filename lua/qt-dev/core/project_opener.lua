-- Qt项目打开器模块
local utils = require("qt-dev.core.utils")
local detection = require("qt-dev.core.detection")
local M = {}

-- 打开Qt项目
function M.open_qt_project()
  -- 检查当前目录是否已经是Qt项目
  local project_info = detection.get_project_info()
  
  if project_info.is_qt_project then
    utils.info(string.format("当前已在Qt项目中: %s (%s)", 
      project_info.name, project_info.type_display))
    return
  end
  
  -- 询问用户选择操作
  vim.ui.select({
    "浏览并打开Qt项目",
    "在当前目录创建新Qt项目",
    "取消"
  }, {
    prompt = "请选择操作:",
  }, function(choice)
    if choice == "浏览并打开Qt项目" then
      M.browse_and_open_project()
    elseif choice == "在当前目录创建新Qt项目" then
      local templates = require("qt-dev.templates")
      templates.create_project_interactive()
    end
  end)
end

-- 浏览并打开项目
function M.browse_and_open_project()
  -- 使用文件选择器选择项目目录
  local current_dir = utils.get_cwd()
  
  vim.ui.input({
    prompt = "请输入Qt项目路径: ",
    default = current_dir,
    completion = "dir",
  }, function(path)
    if path and path ~= "" then
      if utils.dir_exists(path) then
        vim.cmd("cd " .. path)
        
        -- 检查新目录是否为Qt项目
        local new_project_info = detection.get_project_info()
        if new_project_info.is_qt_project then
          utils.success(string.format("已切换到Qt项目: %s (%s)", 
            new_project_info.name, new_project_info.type_display))
          
          -- 触发Qt项目检测事件
          local qt_dev = require("qt-dev")
          qt_dev.on_qt_project_detected()
        else
          utils.warn("所选目录不是Qt项目")
        end
      else
        utils.error("目录不存在: " .. path)
      end
    end
  end)
end

-- 列出最近的Qt项目（占位功能）
function M.list_recent_projects()
  utils.info("最近项目功能暂未实现")
  -- TODO: 实现项目历史记录功能
end

return M