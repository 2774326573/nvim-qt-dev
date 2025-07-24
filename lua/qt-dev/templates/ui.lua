-- Qt UI模板模块
local utils = require("qt-dev.core.utils")
local designer = require("qt-dev.tools.designer")
local M = {}

-- 路径分隔符
local path_sep = utils.is_windows() and "\\" or "/"

-- UI模板
local ui_templates = {
  widget = function(name)
    return string.format([[<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>%s</class>
 <widget class="QWidget" name="%s">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>400</width>
    <height>300</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>%s</string>
  </property>
 </widget>
 <resources/>
 <connections/>
</ui>]], name, name, name)
  end,
  
  dialog = function(name)
    return string.format([[<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>%s</class>
 <widget class="QDialog" name="%s">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>400</width>
    <height>300</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>%s</string>
  </property>
  <widget class="QDialogButtonBox" name="buttonBox">
   <property name="geometry">
    <rect>
     <x>30</x>
     <y>240</y>
     <width>341</width>
     <height>32</height>
    </rect>
   </property>
   <property name="orientation">
    <enum>Qt::Horizontal</enum>
   </property>
   <property name="standardButtons">
    <set>QDialogButtonBox::Cancel|QDialogButtonBox::Ok</set>
   </property>
  </widget>
 </widget>
 <resources/>
 <connections>
  <connection>
   <sender>buttonBox</sender>
   <signal>accepted()</signal>
   <receiver>%s</receiver>
   <slot>accept()</slot>
  </connection>
  <connection>
   <sender>buttonBox</sender>
   <signal>rejected()</signal>
   <receiver>%s</receiver>
   <slot>reject()</slot>
  </connection>
 </connections>
</ui>]], name, name, name, name, name)
  end,
  
  mainwindow = function(name)
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
  <widget class="QWidget" name="centralwidget"/>
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
</ui>]], name, name, name)
  end
}

function M.create_ui_template(template_type, ui_name)
  if not ui_name or ui_name == "" then
    vim.ui.input({ prompt = "请输入UI文件名称 (不含扩展名): " }, function(input)
      if input and input ~= "" then
        M.create_ui_template(template_type, input)
      end
    end)
    return
  end

  -- 验证名称
  if not ui_name:match("^[%w_%-]+$") then
    vim.notify("❌ 文件名只能包含字母、数字、下划线和连字符", vim.log.levels.ERROR)
    return
  end

  -- 设置各文件的目录路径
  local cwd = vim.fn.getcwd()
  local ui_dir = vim.g.qt_ui_dir or (cwd .. path_sep .. "ui")
  local include_dir = cwd .. path_sep .. "include"
  local src_dir = cwd .. path_sep .. "src"
  
  local ui_file = ui_dir .. path_sep .. ui_name .. ".ui"
  local h_file = include_dir .. path_sep .. ui_name .. ".h"
  local cpp_file = src_dir .. path_sep .. ui_name .. ".cpp"

  -- 检查文件是否已存在
  if vim.fn.filereadable(ui_file) == 1 or vim.fn.filereadable(h_file) == 1 or vim.fn.filereadable(cpp_file) == 1 then
    vim.notify("❌ UI或类文件已存在: " .. ui_name, vim.log.levels.ERROR)
    return
  end

  -- 确保所有目录存在
  if not utils.ensure_directory(ui_dir) or not utils.ensure_directory(include_dir) or not utils.ensure_directory(src_dir) then
    return
  end

  -- 生成UI内容
  local template_func = ui_templates[template_type]
  if not template_func then
    vim.notify("❌ 未知的UI模板类型: " .. template_type, vim.log.levels.ERROR)
    return
  end

  local ui_content = template_func(ui_name)
  local class_name = ui_name:gsub("^%l", string.upper)
  
  -- 根据模板类型确定基类
  local base_class = "QWidget"
  if template_type == "dialog" then
    base_class = "QDialog"
  elseif template_type == "mainwindow" then
    base_class = "QMainWindow"
  end

  -- 生成头文件内容
  local h_content = string.format([[#ifndef %s_H
#define %s_H

#include <%s>

namespace Ui {
class %s;
}

class %s : public %s
{
    Q_OBJECT

public:
    explicit %s(%s *parent = nullptr);
    ~%s();

private:
    Ui::%s *ui;
};

#endif // %s_H]], 
    ui_name:upper(), ui_name:upper(), base_class, class_name, 
    class_name, base_class, class_name, 
    base_class == "QMainWindow" and "QWidget" or base_class,
    class_name, class_name, ui_name:upper())

  -- 生成源文件内容
  local cpp_content = string.format([[#include "%s.h"
#include "ui_%s.h"

%s::%s(%s *parent) :
    %s(parent),
    ui(new Ui::%s)
{
    ui->setupUi(this);
}

%s::~%s()
{
    delete ui;
}]], 
    ui_name, ui_name, class_name, class_name, 
    base_class == "QMainWindow" and "QWidget" or base_class,
    base_class, class_name, class_name, class_name)

  -- 写入文件
  local ok_ui = utils.write_file_safely(ui_file, ui_content)
  local ok_h = utils.write_file_safely(h_file, h_content)
  local ok_cpp = utils.write_file_safely(cpp_file, cpp_content)

  if ok_ui and ok_h and ok_cpp then
    vim.notify("✅ UI及类文件创建成功: " .. ui_name, vim.log.levels.INFO)
    vim.notify("💡 可以使用 <leader>qd 打开Qt Designer编辑", vim.log.levels.INFO)

    -- 询问是否立即打开
    vim.ui.select({ "是", "否" }, {
      prompt = "是否立即在Qt Designer中打开？",
    }, function(choice)
      if choice == "是" then
        designer.open_designer(ui_file)
      end
    end)
    
    -- 打开头文件
    vim.cmd("edit " .. vim.fn.fnameescape(h_file))
  end
end

function M.select_and_create_ui_template()
  local templates = {
    { name = "QWidget", type = "widget" },
    { name = "QDialog", type = "dialog" },
    { name = "QMainWindow", type = "mainwindow" }
  }
  
  local choices = {}
  for _, template in ipairs(templates) do
    table.insert(choices, template.name)
  end
  
  vim.ui.select(choices, {
    prompt = "选择UI模板类型:",
  }, function(choice, idx)
    if choice and idx then
      local template_type = templates[idx].type
      vim.ui.input({ prompt = "输入UI文件名: " }, function(ui_name)
        if ui_name and ui_name ~= "" then
          M.create_ui_template(template_type, ui_name)
        end
      end)
    end
  end)
end

function M.list_ui_files()
  local ui_files = vim.fn.glob("**/*.ui", false, true)
  if #ui_files > 0 then
    local display_files = {}
    for _, file in ipairs(ui_files) do
      table.insert(display_files, vim.fn.fnamemodify(file, ":."))
    end
    vim.notify("📋 UI文件列表:\n" .. table.concat(display_files, "\n"), vim.log.levels.INFO)
  else
    vim.notify("ℹ️ 未找到UI文件", vim.log.levels.INFO)
  end
end

return M