-- Qt项目打开工具模块 - 基于qt-project移植
local utils = require("qt-dev.core.utils")
local core = require("qt-dev.core")
local M = {}

-- 历史记录文件路径
local history_file = vim.fn.stdpath("data") .. "/nvim_qt_dev_project_history.json"

-- 路径分隔符
local path_sep = utils.is_windows() and "\\" or "/"

-- 加载项目历史记录
local function load_project_history()
  if vim.fn.filereadable(history_file) == 0 then
    return {}
  end
  
  local ok, content = pcall(vim.fn.readfile, history_file)
  if not ok then return {} end
  
  local json_str = table.concat(content, "\n")
  local ok2, history = pcall(vim.fn.json_decode, json_str)
  if not ok2 then return {} end
  
  return history or {}
end

-- 添加到历史记录
local function add_to_history(file_path, project_name)
  local history = load_project_history()
  local entry = {
    path = file_path,
    project = project_name,
    timestamp = os.time(),
    directory = vim.fn.fnamemodify(file_path, ":h")
  }
  
  -- 移除已存在的条目
  for i = #history, 1, -1 do
    if history[i].path == file_path then
      table.remove(history, i)
    end
  end
  
  -- 添加到开头
  table.insert(history, 1, entry)
  
  -- 限制历史记录数量
  if #history > 50 then
    for i = #history, 51, -1 do
      table.remove(history, i)
    end
  end
  
  -- 保存历史记录
  local json_str = vim.fn.json_encode(history)
  pcall(vim.fn.writefile, {json_str}, history_file)
end

-- 递归查找Qt项目
local function find_qt_projects_recursive(dir, max_depth)
  max_depth = max_depth or 3
  if max_depth <= 0 then return {} end
  
  local projects = {}
  local items = vim.fn.glob(dir .. path_sep .. "*", false, true)
  
  for _, item in ipairs(items) do
    if vim.fn.isdirectory(item) == 1 then
      local dirname = vim.fn.fnamemodify(item, ":t")
      -- 跳过常见的非项目目录
      if not dirname:match("^%.") and 
         not dirname:match("^build") and 
         not dirname:match("^node_modules") and
         not dirname:match("^%.git") and
         not dirname:match("^%.vscode") then
        
        -- 检查当前目录是否是Qt项目
        local qt_indicators = {
          "CMakeLists.txt",
          "*.pro",
          "*.pri"
        }
        
        local is_qt_project_dir = false
        local main_file = nil
        
        for _, pattern in ipairs(qt_indicators) do
          local files = vim.fn.glob(item .. path_sep .. pattern, false, true)
          if #files > 0 then
            is_qt_project_dir = true
            main_file = files[1]  -- 记录主要文件
            break
          end
        end
        
        -- 也检查是否有.ui或.qrc文件
        if not is_qt_project_dir then
          local ui_files = vim.fn.glob(item .. path_sep .. "*.ui", false, true)
          local qrc_files = vim.fn.glob(item .. path_sep .. "*.qrc", false, true)
          if #ui_files > 0 or #qrc_files > 0 then
            is_qt_project_dir = true
            main_file = ui_files[1] or qrc_files[1]
          end
        end
        
        if is_qt_project_dir then
          table.insert(projects, {
            path = item,
            name = dirname,
            relative_path = vim.fn.fnamemodify(item, ":."),
            main_file = main_file
          })
        end
        
        -- 递归搜索子目录
        local subprojects = find_qt_projects_recursive(item, max_depth - 1)
        for _, subproject in ipairs(subprojects) do
          table.insert(projects, subproject)
        end
      end
    end
  end
  
  return projects
end

-- 扫描项目文件
local function scan_project_files(directory)
  local cwd = directory or vim.fn.getcwd()
  local project_files = {}
  
  -- 检测项目文件类型和路径
  local file_patterns = {
    {
      pattern = "CMakeLists.txt",
      desc = "CMake构建文件",
      priority = 1,
      icon = "🏗️"
    },
    {
      pattern = "*.pro",
      desc = "Qt项目文件 (.pro)",
      priority = 2,
      icon = "⚙️"
    },
    {
      pattern = "*.pri",
      desc = "Qt包含文件 (.pri)",
      priority = 3,
      icon = "📄"
    },
    {
      pattern = "resources" .. path_sep .. "*.qrc",
      desc = "Qt资源文件 (.qrc)",
      priority = 4,
      icon = "📦"
    },
    {
      pattern = "*.qrc",
      desc = "Qt资源文件 (.qrc)",
      priority = 4,
      icon = "📦"
    },
    {
      pattern = "ui" .. path_sep .. "*.ui",
      desc = "Qt UI文件 (.ui)",
      priority = 5,
      icon = "🎨"
    },
    {
      pattern = "*.ui",
      desc = "Qt UI文件 (.ui)",  
      priority = 5,
      icon = "🎨"
    },
    {
      pattern = "*.ts",
      desc = "Qt翻译文件 (.ts)",
      priority = 6,
      icon = "🌐"
    },
    {
      pattern = "*.qm",
      desc = "Qt编译翻译文件 (.qm)",
      priority = 7,
      icon = "🌍"
    }
  }
  
  for _, file_info in ipairs(file_patterns) do
    local full_pattern = cwd .. path_sep .. file_info.pattern
    local files = vim.fn.glob(full_pattern, false, true)
    
    for _, file_path in ipairs(files) do
      local filename = vim.fn.fnamemodify(file_path, ":t")
      local relative_path = vim.fn.fnamemodify(file_path, ":.")
      
      table.insert(project_files, {
        path = file_path,
        name = filename,
        relative_path = relative_path,
        desc = file_info.desc,
        priority = file_info.priority,
        icon = file_info.icon
      })
    end
  end
  
  return project_files
end

-- 主要的打开Qt项目功能
function M.open_qt_project()
  local choices = {}
  local all_items = {}
  
  -- 1. 添加历史记录选项
  local history = load_project_history()
  if #history > 0 then
    table.insert(choices, "📚 === 最近访问的项目 ===")
    table.insert(all_items, { type = "separator" })
    
    for i, entry in ipairs(history) do
      if i <= 10 then -- 显示最近10个
        local time_str = os.date("%m-%d %H:%M", entry.timestamp)
        local display = string.format("📚 [%s] %s (%s)", time_str, entry.project, entry.path)
        table.insert(choices, display)
        table.insert(all_items, { type = "history", data = entry })
      end
    end
  end
  
  -- 2. 添加当前目录项目文件
  local current_files = scan_project_files()
  if #current_files > 0 then
    table.insert(choices, "📂 === 当前目录项目文件 ===")
    table.insert(all_items, { type = "separator" })
    
    -- 按优先级排序
    table.sort(current_files, function(a, b)
      if a.priority == b.priority then
        return a.name < b.name
      end
      return a.priority < b.priority
    end)
    
    for _, file in ipairs(current_files) do
      local display = string.format("%s %s - %s", file.icon, file.relative_path, file.desc)
      table.insert(choices, display)
      table.insert(all_items, { type = "file", data = file })
    end
  end
  
  -- 3. 添加子目录Qt项目
  local subprojects = find_qt_projects_recursive(vim.fn.getcwd())
  if #subprojects > 0 then
    table.insert(choices, "🔍 === 子目录中的Qt项目 ===")
    table.insert(all_items, { type = "separator" })
    
    for _, project in ipairs(subprojects) do
      local display = string.format("🔍 %s - Qt项目 (%s)", project.name, project.relative_path)
      table.insert(choices, display)
      table.insert(all_items, { type = "project", data = project })
    end
  end
  
  if #choices == 0 then
    vim.notify("❌ 没有找到Qt项目文件或历史记录", vim.log.levels.ERROR)
    return
  end
  
  vim.ui.select(choices, {
    prompt = "选择要打开的Qt项目：",
  }, function(choice, idx)
    if not choice or not idx then return end
    
    local selected_item = all_items[idx]
    if not selected_item or selected_item.type == "separator" then
      return
    end
    
    if selected_item.type == "history" then
      local entry = selected_item.data
      if vim.fn.filereadable(entry.path) == 1 then
        -- 切换到项目目录
        if entry.directory and vim.fn.isdirectory(entry.directory) == 1 then
          vim.cmd("cd " .. vim.fn.fnameescape(entry.directory))
        end
        vim.notify("📚 打开历史项目: " .. entry.project, vim.log.levels.INFO)
        vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
        
        -- 触发Qt项目检测
        vim.defer_fn(function()
          vim.api.nvim_exec_autocmds("DirChanged", { pattern = "*" })
        end, 100)
      else
        vim.notify("❌ 历史文件不存在: " .. entry.path, vim.log.levels.ERROR)
      end
      
    elseif selected_item.type == "file" then
      local file = selected_item.data
      vim.notify("📂 打开项目文件: " .. file.name, vim.log.levels.INFO)
      vim.cmd("edit " .. vim.fn.fnameescape(file.path))
      add_to_history(file.path, vim.fn.fnamemodify(vim.fn.getcwd(), ":t"))
      
      -- 刷新文件浏览器
      if vim.fn.exists(":Neotree") == 2 then
        vim.cmd("Neotree filesystem reveal")
      end
      
    elseif selected_item.type == "project" then
      local project = selected_item.data
      -- 切换到项目目录并打开主要项目文件
      vim.cmd("cd " .. vim.fn.fnameescape(project.path))
      vim.notify("🔍 切换到Qt项目: " .. project.name, vim.log.levels.INFO)
      
      local project_files = scan_project_files(project.path)
      if #project_files > 0 then
        -- 优先打开CMakeLists.txt或.pro文件
        table.sort(project_files, function(a, b) return a.priority < b.priority end)
        local main_file = project_files[1]
        vim.cmd("edit " .. vim.fn.fnameescape(main_file.path))
        add_to_history(main_file.path, project.name)
        vim.notify("📝 已打开: " .. main_file.name, vim.log.levels.INFO)
      elseif project.main_file then
        -- 使用预先发现的主文件
        vim.cmd("edit " .. vim.fn.fnameescape(project.main_file))
        add_to_history(project.main_file, project.name)
      end
      
      -- 刷新文件浏览器
      if vim.fn.exists(":Neotree") == 2 then
        vim.cmd("Neotree filesystem reveal")
      end
      
      -- 触发Qt项目检测
      vim.defer_fn(function()
        vim.api.nvim_exec_autocmds("DirChanged", { pattern = "*" })
      end, 200)
    end
  end)
end

-- 清理历史记录中不存在的项目
function M.clean_project_history()
  local history = load_project_history()
  local cleaned = {}
  
  for _, entry in ipairs(history) do
    if vim.fn.filereadable(entry.path) == 1 then
      table.insert(cleaned, entry)
    end
  end
  
  local json_str = vim.fn.json_encode(cleaned)
  pcall(vim.fn.writefile, {json_str}, history_file)
  
  vim.notify(string.format("✅ 已清理历史记录，删除了 %d 个无效项目", #history - #cleaned), vim.log.levels.INFO)
end

-- 获取项目历史记录
function M.get_project_history()
  return load_project_history()
end

-- 手动添加项目到历史记录
function M.add_current_project_to_history()
  if not core.detection.is_qt_project() then
    vim.notify("❌ 当前目录不是Qt项目", vim.log.levels.WARN)
    return
  end
  
  local project_files = scan_project_files()
  if #project_files > 0 then
    table.sort(project_files, function(a, b) return a.priority < b.priority end)
    local main_file = project_files[1]
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    
    add_to_history(main_file.path, project_name)
    vim.notify("✅ 已添加当前项目到历史记录: " .. project_name, vim.log.levels.INFO)
  else
    vim.notify("❌ 未找到主要项目文件", vim.log.levels.ERROR)
  end
end

return M