-- Qt类创建模板模块
local utils = require("qt-dev.core.utils")
local M = {}

-- 快速创建Qt类
function M.create_quick_qt_class()
  vim.ui.input({
    prompt = "请输入类名: ",
    default = "MyClass",
  }, function(class_name)
    if class_name and class_name ~= "" then
      M.create_qt_class(class_name, "QObject")
    end
  end)
end

-- 创建Qt UI类
function M.create_qt_ui_class()
  vim.ui.input({
    prompt = "请输入UI类名: ",
    default = "MyWidget",
  }, function(class_name)
    if class_name and class_name ~= "" then
      M.create_qt_class(class_name, "QWidget", true)
    end
  end)
end

-- 创建Qt继承类
function M.create_qt_inheritance_class()
  local base_classes = {
    "QObject", "QWidget", "QMainWindow", "QDialog", "QFrame",
    "QPushButton", "QLabel", "QLineEdit", "QTextEdit", "QListWidget"
  }
  
  vim.ui.select(base_classes, {
    prompt = "选择基类:",
  }, function(base_class)
    if base_class then
      vim.ui.input({
        prompt = string.format("请输入继承自%s的类名: ", base_class),
        default = "My" .. base_class:gsub("^Q", ""),
      }, function(class_name)
        if class_name and class_name ~= "" then
          M.create_qt_class(class_name, base_class)
        end
      end)
    end
  end)
end

-- 创建普通C++类
function M.create_normal_class()
  vim.ui.input({
    prompt = "请输入C++类名: ",
    default = "MyClass",
  }, function(class_name)
    if class_name and class_name ~= "" then
      M.create_cpp_class(class_name)
    end
  end)
end

-- 创建Qt类
function M.create_qt_class(class_name, base_class, with_ui)
  base_class = base_class or "QObject"
  with_ui = with_ui or false
  
  -- 生成文件名
  local header_file = class_name:lower() .. ".h"
  local source_file = class_name:lower() .. ".cpp"
  local ui_file = with_ui and (class_name:lower() .. ".ui") or nil
  
  -- 创建头文件
  local header_content = M.generate_qt_header(class_name, base_class, with_ui)
  if not M.write_file(header_file, header_content) then
    return false
  end
  
  -- 创建源文件
  local source_content = M.generate_qt_source(class_name, base_class, with_ui)
  if not M.write_file(source_file, source_content) then
    return false
  end
  
  -- 创建UI文件（如果需要）
  if with_ui then
    local ui_content = M.generate_ui_file(class_name)
    if not M.write_file(ui_file, ui_content) then
      return false
    end
  end
  
  utils.success(string.format("Qt类 '%s' 创建成功", class_name))
  utils.info("创建的文件:")
  utils.info("  - " .. header_file)
  utils.info("  - " .. source_file)
  if with_ui then
    utils.info("  - " .. ui_file)
  end
  
  return true
end

-- 创建C++类
function M.create_cpp_class(class_name)
  local header_file = class_name:lower() .. ".h"
  local source_file = class_name:lower() .. ".cpp"
  
  -- 创建头文件
  local header_content = M.generate_cpp_header(class_name)
  if not M.write_file(header_file, header_content) then
    return false
  end
  
  -- 创建源文件
  local source_content = M.generate_cpp_source(class_name)
  if not M.write_file(source_file, source_content) then
    return false
  end
  
  utils.success(string.format("C++类 '%s' 创建成功", class_name))
  utils.info("创建的文件:")
  utils.info("  - " .. header_file)
  utils.info("  - " .. source_file)
  
  return true
end

-- 生成Qt头文件
function M.generate_qt_header(class_name, base_class, with_ui)
  local guard = string.upper(class_name) .. "_H"
  local includes = {"#include <" .. base_class .. ">"}
  
  if with_ui then
    table.insert(includes, "#include <QWidget>")
  end
  
  local ui_forward_decl = with_ui and string.format([[
QT_BEGIN_NAMESPACE
namespace Ui { class %s; }
QT_END_NAMESPACE
]], class_name) or ""
  
  local ui_member = with_ui and string.format("    Ui::%s *ui;", class_name) or ""
  
  local template = string.format([[#ifndef %s
#define %s

%s
%s
class %s : public %s
{
    Q_OBJECT

public:
    explicit %s(%s *parent = nullptr);
    ~%s();

private slots:
    // 在这里添加槽函数

private:
%s
};

#endif // %s
]], 
    guard, guard, 
    table.concat(includes, "\n"), 
    ui_forward_decl,
    class_name, base_class,
    class_name, base_class == "QWidget" and "QWidget" or "QObject",
    class_name,
    ui_member,
    guard)
  
  return template
end

-- 生成Qt源文件
function M.generate_qt_source(class_name, base_class, with_ui)
  local includes = {string.format('#include "%s.h"', class_name:lower())}
  
  if with_ui then
    table.insert(includes, string.format('#include "ui_%s.h"', class_name:lower()))
  end
  
  local constructor_body = with_ui and string.format([[    , ui(new Ui::%s)
{
    ui->setupUi(this);
}]], class_name) or [[
{
    // 构造函数实现
}]]
  
  local destructor_body = with_ui and [[{
    delete ui;
}]] or [[{
    // 析构函数实现
}]]
  
  local template = string.format([[%s

%s::%s(%s *parent)
    : %s(parent)%s

%s::~%s()
%s
]], 
    table.concat(includes, "\n"),
    class_name, class_name, base_class == "QWidget" and "QWidget" or "QObject",
    base_class, constructor_body,
    class_name, class_name, destructor_body)
  
  return template
end

-- 生成C++头文件
function M.generate_cpp_header(class_name)
  local guard = string.upper(class_name) .. "_H"
  
  local template = string.format([[#ifndef %s
#define %s

class %s
{
public:
    %s();
    ~%s();
    
    // 在这里添加公共成员函数

private:
    // 在这里添加私有成员变量
};

#endif // %s
]], guard, guard, class_name, class_name, class_name, guard)
  
  return template
end

-- 生成C++源文件
function M.generate_cpp_source(class_name)
  local template = string.format([[#include "%s.h"

%s::%s()
{
    // 构造函数实现
}

%s::~%s()
{
    // 析构函数实现
}
]], class_name:lower(), class_name, class_name, class_name, class_name)
  
  return template
end

-- 生成UI文件
function M.generate_ui_file(class_name)
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
</ui>
]], class_name, class_name, class_name)
end

-- 写入文件
function M.write_file(filename, content)
  if utils.file_exists(filename) then
    vim.ui.select({"覆盖", "取消"}, {
      prompt = string.format("文件 '%s' 已存在，是否覆盖？", filename),
    }, function(choice)
      if choice == "覆盖" then
        local file = io.open(filename, "w")
        if file then
          file:write(content)
          file:close()
          return true
        else
          utils.error("无法写入文件: " .. filename)
          return false
        end
      end
    end)
    return false
  else
    local file = io.open(filename, "w")
    if not file then
      utils.error("无法创建文件: " .. filename)
      return false
    end
    
    file:write(content)
    file:close()
    return true
  end
end

return M