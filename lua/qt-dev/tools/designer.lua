-- Qt Designer集成工具模块
local utils = require("qt-dev.core.utils")
local config = require("qt-dev.config.paths")
local M = {}

-- 获取Qt Designer路径
local function get_designer_path()
  local qt_config = config.get_qt_config()
  return qt_config.designer_path
end

-- 检查Qt Designer是否可用
function M.is_designer_available()
  local designer_path = get_designer_path()
  return utils.executable_exists(designer_path) or utils.file_exists(designer_path)
end

-- 打开Qt Designer
function M.open_designer(file_path)
  if not M.is_designer_available() then
    utils.error("Qt Designer不可用，请检查Qt安装")
    return false
  end
  
  local designer_path = get_designer_path()
  local cmd = {designer_path}
  
  if file_path and utils.file_exists(file_path) then
    table.insert(cmd, file_path)
    utils.info(string.format("使用Qt Designer打开: %s", file_path))
  else
    utils.info("打开Qt Designer")
  end
  
  -- 异步启动Qt Designer
  utils.run_command(cmd, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        utils.error("Qt Designer退出异常")
      end
    end
  })
  
  return true
end

-- 打开空的Qt Designer
function M.open_empty_designer()
  return M.open_designer()
end

-- 智能打开Qt Designer
-- 如果当前文件是.ui文件，则打开该文件
-- 否则查找项目中的.ui文件并提供选择
function M.open_current_file_ui()
  local current_file = vim.fn.expand("%:p")
  
  -- 如果当前文件是.ui文件，直接打开
  if current_file:match("%.ui$") then
    return M.open_designer(current_file)
  end
  
  -- 查找项目中的所有.ui文件
  local ui_files = vim.fn.glob("**/*.ui", false, true)
  
  if #ui_files == 0 then
    -- 没有.ui文件，询问是否创建新的
    vim.ui.select({"创建新UI文件", "打开空Designer", "取消"}, {
      prompt = "项目中没有找到UI文件，请选择操作:",
    }, function(choice)
      if choice == "创建新UI文件" then
        M.create_new_ui_file()
      elseif choice == "打开空Designer" then
        M.open_empty_designer()
      end
    end)
    return true
  elseif #ui_files == 1 then
    -- 只有一个.ui文件，直接打开
    return M.open_designer(ui_files[1])
  else
    -- 多个.ui文件，让用户选择
    vim.ui.select(ui_files, {
      prompt = "选择要打开的UI文件:",
    }, function(choice)
      if choice then
        M.open_designer(choice)
      end
    end)
    return true
  end
end

-- 创建新的UI文件
function M.create_new_ui_file()
  vim.ui.input({
    prompt = "请输入UI文件名 (不含.ui扩展名): ",
    default = "mainwindow",
  }, function(filename)
    if filename and filename ~= "" then
      if not filename:match("%.ui$") then
        filename = filename .. ".ui"
      end
      
      M.create_ui_template(filename)
    end
  end)
end

-- 创建UI模板文件
function M.create_ui_template(filename)
  local ui_content = M.get_ui_template(filename)
  
  local file = io.open(filename, "w")
  if not file then
    utils.error("无法创建UI文件: " .. filename)
    return false
  end
  
  file:write(ui_content)
  file:close()
  
  utils.success(string.format("UI文件创建成功: %s", filename))
  
  -- 询问是否立即打开
  vim.ui.select({"是", "否"}, {
    prompt = "是否用Qt Designer打开新创建的UI文件？",
  }, function(choice)
    if choice == "是" then
      M.open_designer(filename)
    end
  end)
  
  return true
end

-- 获取UI模板内容
function M.get_ui_template(filename)
  local class_name = filename:gsub("%.ui$", ""):gsub("^%l", string.upper)
  
  return string.format([[<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>%s</class>
 <widget class="QMainWindow" name="%s">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>800</width>
    <height>600</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>%s</string>
  </property>
  <widget class="QWidget" name="centralwidget">
   <layout class="QVBoxLayout" name="verticalLayout">
    <item>
     <widget class="QLabel" name="label">
      <property name="text">
       <string>欢迎使用Qt Designer！</string>
      </property>
      <property name="alignment">
       <set>Qt::AlignCenter</set>
      </property>
     </widget>
    </item>
   </layout>
  </widget>
  <widget class="QMenuBar" name="menubar">
   <property name="geometry">
    <rect>
     <x>0</x>
     <y>0</y>
     <width>800</width>
     <height>22</height>
    </rect>
   </property>
  </widget>
  <widget class="QStatusBar" name="statusbar"/>
 </widget>
 <resources/>
 <connections/>
</ui>
]], class_name, class_name, class_name)
end

-- 列出项目中的所有UI文件
function M.list_ui_files()
  local ui_files = vim.fn.glob("**/*.ui", false, true)
  
  if #ui_files == 0 then
    utils.info("项目中没有找到UI文件")
    return
  end
  
  utils.info("项目UI文件列表:")
  for i, file in ipairs(ui_files) do
    print(string.format("  %d. %s", i, file))
  end
  
  -- 询问是否打开某个文件
  vim.ui.select(ui_files, {
    prompt = "选择要用Qt Designer打开的UI文件:",
  }, function(choice)
    if choice then
      M.open_designer(choice)
    end
  end)
end

-- 同步UI文件到头文件
function M.sync_ui_to_header(ui_file)
  if not ui_file or not utils.file_exists(ui_file) then
    utils.error("UI文件不存在: " .. (ui_file or ""))
    return false
  end
  
  local base_name = ui_file:gsub("%.ui$", "")
  local header_file = base_name .. ".h"
  
  -- 使用uic工具生成头文件
  local qt_config = config.get_qt_config()
  local uic_path = qt_config.uic_path
  
  if not utils.executable_exists(uic_path) then
    utils.error("uic工具不可用")
    return false
  end
  
  local ui_header = "ui_" .. base_name .. ".h"
  local cmd = {uic_path, ui_file, "-o", ui_header}
  
  local result = utils.run_command(cmd, {wait = true})
  
  if result.exit_code == 0 then
    utils.success(string.format("UI头文件生成成功: %s", ui_header))
    return true
  else
    utils.error("UI头文件生成失败")
    return false
  end
end

-- 获取Designer状态
function M.get_designer_status()
  return {
    available = M.is_designer_available(),
    path = get_designer_path(),
    ui_files_count = #vim.fn.glob("**/*.ui", false, true)
  }
end

return M