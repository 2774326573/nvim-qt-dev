-- Qt类创建模块
local utils = require("qt-dev.core.utils")
local M = {}

-- 路径分隔符
local path_sep = utils.is_windows() and "\\" or "/"

-- 目录选择器
local function select_directory(default_name, description, callback)
  local cwd = vim.fn.getcwd()
  local subdirs = vim.fn.glob(cwd .. path_sep .. "*", false, true)
  local dirs = {}
  
  -- 添加当前目录选项
  table.insert(dirs, ".")
  
  -- 添加子目录
  for _, dir in ipairs(subdirs) do
    if vim.fn.isdirectory(dir) == 1 then
      local dirname = vim.fn.fnamemodify(dir, ":t")
      if not dirname:match("^%.") then
        table.insert(dirs, dirname)
      end
    end
  end
  
  -- 添加默认目录选项（如果不存在）
  local found_default = false
  for _, dir in ipairs(dirs) do
    if dir == default_name then
      found_default = true
      break
    end
  end
  
  if not found_default then
    table.insert(dirs, default_name .. " (新建)")
  end
  
  vim.ui.select(dirs, {
    prompt = "选择" .. description .. "目录:",
  }, function(selected_dir)
    if not selected_dir then return end
    
    local final_dir
    if selected_dir == "." then
      final_dir = cwd
    elseif selected_dir:match(" %(新建%)$") then
      local new_dir_name = selected_dir:gsub(" %(新建%)$", "")
      final_dir = cwd .. path_sep .. new_dir_name
      if not utils.ensure_directory(final_dir) then
        return
      end
    else
      final_dir = cwd .. path_sep .. selected_dir
    end
    
    callback(final_dir)
  end)
end

-- 创建UI类文件
local function create_ui_class_files(class_name, base_class, include_dir, src_dir, ui_dir)
  local h_file = include_dir .. path_sep .. class_name .. ".h"
  local cpp_file = src_dir .. path_sep .. class_name .. ".cpp"
  local ui_file = ui_dir .. path_sep .. class_name .. ".ui"

  -- 检查文件是否已存在
  if vim.fn.filereadable(h_file) == 1 or vim.fn.filereadable(cpp_file) == 1 or vim.fn.filereadable(ui_file) == 1 then
    vim.notify("❌ 类文件已存在: " .. class_name, vim.log.levels.ERROR)
    return
  end

  -- 生成UI类头文件内容
  local h_content = string.format([[#ifndef %s_H
#define %s_H

#include <%s>

QT_BEGIN_NAMESPACE
namespace Ui { class %s; }
QT_END_NAMESPACE

class %s : public %s
{
    Q_OBJECT

public:
    explicit %s(QWidget *parent = nullptr);
    ~%s();

private slots:
    // 在这里添加槽函数

private:
    Ui::%s *ui;
};

#endif // %s_H]], 
    class_name:upper(), class_name:upper(), base_class, class_name, 
    class_name, base_class, class_name, class_name, class_name, class_name:upper())

  -- 生成UI类源文件内容
  local cpp_content = string.format([[#include "%s.h"
#include "ui_%s.h"

%s::%s(QWidget *parent)
    : %s(parent)
    , ui(new Ui::%s)
{
    ui->setupUi(this);
    
    // 在这里添加初始化代码
}

%s::~%s()
{
    delete ui;
}]], 
    class_name, class_name, 
    class_name, class_name, base_class, class_name,
    class_name, class_name)

  -- 生成UI文件内容
  local ui_content = string.format([[<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>%s</class>
 <widget class="%s" name="%s">
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
</ui>]], class_name, base_class, class_name, class_name)

  -- 写入文件
  if utils.write_file_safely(h_file, h_content) and
     utils.write_file_safely(cpp_file, cpp_content) and
     utils.write_file_safely(ui_file, ui_content) then
    vim.notify("✅ UI类创建成功: " .. class_name, vim.log.levels.INFO)
    vim.cmd("edit " .. vim.fn.fnameescape(h_file))
  end
end

-- 创建继承类文件
local function create_inheritance_class_files(class_name, base_class, include_dir, src_dir)
  local h_file = include_dir .. path_sep .. class_name .. ".h"
  local cpp_file = src_dir .. path_sep .. class_name .. ".cpp"

  -- 检查文件是否已存在
  if vim.fn.filereadable(h_file) == 1 or vim.fn.filereadable(cpp_file) == 1 then
    vim.notify("❌ 类文件已存在: " .. class_name, vim.log.levels.ERROR)
    return
  end

  -- 生成继承类头文件内容
  local h_content = string.format([[#ifndef %s_H
#define %s_H

#include <%s>

class %s : public %s
{
    Q_OBJECT

public:
    explicit %s(QWidget *parent = nullptr);
    ~%s();

protected:
    // 在这里添加受保护的成员

private slots:
    // 在这里添加槽函数

private:
    // 在这里添加私有成员
};

#endif // %s_H]], 
    class_name:upper(), class_name:upper(), base_class,
    class_name, base_class, class_name, class_name, class_name:upper())

  -- 生成继承类源文件内容
  local cpp_content = string.format([[#include "%s.h"

%s::%s(QWidget *parent)
    : %s(parent)
{
    // 在这里添加初始化代码
}

%s::~%s()
{
    // 在这里添加清理代码
}]], 
    class_name, class_name, class_name, base_class, class_name, class_name)

  -- 写入文件
  if utils.write_file_safely(h_file, h_content) and
     utils.write_file_safely(cpp_file, cpp_content) then
    vim.notify("✅ 继承类创建成功: " .. class_name, vim.log.levels.INFO)
    vim.cmd("edit " .. vim.fn.fnameescape(h_file))
  end
end

-- 创建普通类文件
local function create_normal_class_files(class_name, include_dir, src_dir)
  local h_file = include_dir .. path_sep .. class_name .. ".h"
  local cpp_file = src_dir .. path_sep .. class_name .. ".cpp"

  -- 检查文件是否已存在
  if vim.fn.filereadable(h_file) == 1 or vim.fn.filereadable(cpp_file) == 1 then
    vim.notify("❌ 类文件已存在: " .. class_name, vim.log.levels.ERROR)
    return
  end

  -- 生成普通类头文件内容
  local h_content = string.format([[#ifndef %s_H
#define %s_H

class %s
{
public:
    %s();
    ~%s();

    // 在这里添加公共成员函数

private:
    // 在这里添加私有成员变量
};

#endif // %s_H]], 
    class_name:upper(), class_name:upper(), class_name, 
    class_name, class_name, class_name:upper())

  -- 生成普通类源文件内容
  local cpp_content = string.format([[#include "%s.h"

%s::%s()
{
    // 在这里添加构造函数代码
}

%s::~%s()
{
    // 在这里添加析构函数代码
}]], 
    class_name, class_name, class_name, class_name, class_name)

  -- 写入文件
  if utils.write_file_safely(h_file, h_content) and
     utils.write_file_safely(cpp_file, cpp_content) then
    vim.notify("✅ 普通类创建成功: " .. class_name, vim.log.levels.INFO)
    vim.cmd("edit " .. vim.fn.fnameescape(h_file))
  end
end

-- 创建自定义继承类函数（增强版）
local function create_custom_class(class_name, base_class, class_type)
  if not class_name or class_name == "" then
    vim.ui.input({ prompt = "请输入类名 (如: MyButton): " }, function(input)
      if input and input ~= "" then
        create_custom_class(input, base_class, class_type)
      end
    end)
    return
  end

  -- 验证类名
  if not class_name:match("^[A-Z][%w_]*$") then
    vim.notify("❌ 类名必须以大写字母开头，只能包含字母、数字和下划线", vim.log.levels.ERROR)
    return
  end

  -- 根据类类型进行目录选择和文件创建
  if class_type == "ui" then
    -- UI类：需要选择三个目录（include, src, ui）
    select_directory("include", "头文件", function(include_dir)
      select_directory("src", "源文件", function(src_dir)
        select_directory("ui", "UI文件", function(ui_dir)
          create_ui_class_files(class_name, base_class, include_dir, src_dir, ui_dir)
        end)
      end)
    end)
  elseif class_type == "inheritance" then
    -- 继承类：需要选择两个目录（include, src）
    select_directory("include", "头文件", function(include_dir)
      select_directory("src", "源文件", function(src_dir)
        create_inheritance_class_files(class_name, base_class, include_dir, src_dir)
      end)
    end)
  else
    -- 普通类：需要选择两个目录（include, src）
    select_directory("include", "头文件", function(include_dir)
      select_directory("src", "源文件", function(src_dir)
        create_normal_class_files(class_name, include_dir, src_dir)
      end)
    end)
  end
end

-- 创建Qt UI类
function M.create_qt_ui_class()
  local base_classes = {
    "QWidget",
    "QDialog", 
    "QMainWindow",
    "QFrame",
    "QGroupBox"
  }
  
  vim.ui.select(base_classes, {
    prompt = "选择基类:",
  }, function(selected_base)
    if selected_base then
      create_custom_class(nil, selected_base, "ui")
    end
  end)
end

-- 创建Qt继承类
function M.create_qt_inheritance_class()
  local base_classes = {
    "QObject",
    "QWidget",
    "QDialog",
    "QMainWindow", 
    "QPushButton",
    "QLabel",
    "QLineEdit",
    "QTextEdit",
    "QListWidget",
    "QTreeWidget",
    "QTableWidget",
    "QFrame",
    "QGroupBox"
  }
  
  vim.ui.select(base_classes, {
    prompt = "选择基类:",
  }, function(selected_base)
    if selected_base then
      create_custom_class(nil, selected_base, "inheritance")
    end
  end)
end

-- 创建普通C++类
function M.create_normal_class()
  create_custom_class(nil, nil, "normal")
end

-- 快速创建常用Qt类
function M.create_quick_qt_class()
  local quick_options = {
    "QWidget UI类",
    "QDialog UI类", 
    "QMainWindow UI类",
    "QPushButton 继承类",
    "QObject 继承类",
    "普通C++类"
  }
  
  vim.ui.select(quick_options, {
    prompt = "选择要创建的类类型:",
  }, function(selected)
    if not selected then return end
    
    if selected == "QWidget UI类" then
      create_custom_class(nil, "QWidget", "ui")
    elseif selected == "QDialog UI类" then
      create_custom_class(nil, "QDialog", "ui")
    elseif selected == "QMainWindow UI类" then
      create_custom_class(nil, "QMainWindow", "ui")
    elseif selected == "QPushButton 继承类" then
      create_custom_class(nil, "QPushButton", "inheritance")
    elseif selected == "QObject 继承类" then
      create_custom_class(nil, "QObject", "inheritance")
    elseif selected == "普通C++类" then
      create_custom_class(nil, nil, "normal")
    end
  end)
end

return M