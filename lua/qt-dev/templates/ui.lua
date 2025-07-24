-- Qt UI模板创建模块
local utils = require("qt-dev.core.utils")
local M = {}

-- UI模板类型
local ui_templates = {
  mainwindow = {
    name = "主窗口",
    description = "带菜单栏和状态栏的主窗口",
    widget_class = "QMainWindow"
  },
  dialog = {
    name = "对话框",
    description = "标准对话框窗口",
    widget_class = "QDialog"
  },
  widget = {
    name = "普通窗口",
    description = "基础的QWidget窗口",
    widget_class = "QWidget"
  },
  form = {
    name = "表单窗口",
    description = "带表单布局的窗口",
    widget_class = "QWidget"
  }
}

-- 选择并创建UI模板
function M.select_and_create_ui_template()
  local template_names = {}
  local template_keys = {}
  
  for key, template in pairs(ui_templates) do
    table.insert(template_keys, key)
    table.insert(template_names, string.format("%s - %s", template.name, template.description))
  end
  
  vim.ui.select(template_names, {
    prompt = "选择UI模板类型:",
  }, function(choice, idx)
    if choice and idx then
      local template_key = template_keys[idx]
      
      vim.ui.input({
        prompt = "请输入UI文件名 (不含.ui扩展名): ",
        default = template_key,
      }, function(filename)
        if filename and filename ~= "" then
          M.create_ui_template(filename, template_key)
        end
      end)
    end
  end)
end

-- 创建UI模板
function M.create_ui_template(filename, template_type)
  template_type = template_type or "widget"
  
  if not filename:match("%.ui$") then
    filename = filename .. ".ui"
  end
  
  if utils.file_exists(filename) then
    vim.ui.select({"覆盖", "取消"}, {
      prompt = string.format("文件 '%s' 已存在，是否覆盖？", filename),
    }, function(choice)
      if choice == "覆盖" then
        M.write_ui_file(filename, template_type)
      end
    end)
  else
    M.write_ui_file(filename, template_type)
  end
end

-- 写入UI文件
function M.write_ui_file(filename, template_type)
  local content = M.generate_ui_content(filename, template_type)
  
  local file = io.open(filename, "w")
  if not file then
    utils.error("无法创建UI文件: " .. filename)
    return false
  end
  
  file:write(content)
  file:close()
  
  utils.success(string.format("UI文件创建成功: %s", filename))
  
  -- 询问是否打开Qt Designer
  vim.ui.select({"是", "否"}, {
    prompt = "是否用Qt Designer打开新创建的UI文件？",
  }, function(choice)
    if choice == "是" then
      local designer = require("qt-dev.tools.designer")
      designer.open_designer(filename)
    end
  end)
  
  return true
end

-- 生成UI内容
function M.generate_ui_content(filename, template_type)
  local basename = filename:gsub("%.ui$", "")
  local class_name = basename:gsub("^%l", string.upper)
  local template = ui_templates[template_type] or ui_templates.widget
  
  if template_type == "mainwindow" then
    return M.generate_mainwindow_ui(class_name)
  elseif template_type == "dialog" then
    return M.generate_dialog_ui(class_name)
  elseif template_type == "form" then
    return M.generate_form_ui(class_name)
  else
    return M.generate_widget_ui(class_name)
  end
end

-- 生成主窗口UI
function M.generate_mainwindow_ui(class_name)
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
       <string>欢迎使用%s</string>
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
   <widget class="QMenu" name="menu_file">
    <property name="title">
     <string>文件(&amp;F)</string>
    </property>
    <addaction name="action_new"/>
    <addaction name="action_open"/>
    <addaction name="separator"/>
    <addaction name="action_exit"/>
   </widget>
   <widget class="QMenu" name="menu_help">
    <property name="title">
     <string>帮助(&amp;H)</string>
    </property>
    <addaction name="action_about"/>
   </widget>
   <addaction name="menu_file"/>
   <addaction name="menu_help"/>
  </widget>
  <widget class="QStatusBar" name="statusbar"/>
  <action name="action_new">
   <property name="text">
    <string>新建(&amp;N)</string>
   </property>
   <property name="shortcut">
    <string>Ctrl+N</string>
   </property>
  </action>
  <action name="action_open">
   <property name="text">
    <string>打开(&amp;O)</string>
   </property>
   <property name="shortcut">
    <string>Ctrl+O</string>
   </property>
  </action>
  <action name="action_exit">
   <property name="text">
    <string>退出(&amp;X)</string>
   </property>
   <property name="shortcut">
    <string>Ctrl+Q</string>
   </property>
  </action>
  <action name="action_about">
   <property name="text">
    <string>关于(&amp;A)</string>
   </property>
  </action>
 </widget>
 <resources/>
 <connections/>
</ui>
]], class_name, class_name, class_name, class_name)
end

-- 生成对话框UI
function M.generate_dialog_ui(class_name)
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
  <layout class="QVBoxLayout" name="verticalLayout">
   <item>
    <widget class="QLabel" name="label">
     <property name="text">
      <string>这是一个对话框</string>
     </property>
     <property name="alignment">
      <set>Qt::AlignCenter</set>
     </property>
    </widget>
   </item>
   <item>
    <spacer name="verticalSpacer">
     <property name="orientation">
      <enum>Qt::Vertical</enum>
     </property>
     <property name="sizeHint" stdset="0">
      <size>
       <width>20</width>
       <height>40</height>
      </size>
     </property>
    </spacer>
   </item>
   <item>
    <widget class="QDialogButtonBox" name="buttonBox">
     <property name="orientation">
      <enum>Qt::Horizontal</enum>
     </property>
     <property name="standardButtons">
      <set>QDialogButtonBox::Cancel|QDialogButtonBox::Ok</set>
     </property>
    </widget>
   </item>
  </layout>
 </widget>
 <resources/>
 <connections>
  <connection>
   <sender>buttonBox</sender>
   <signal>accepted()</signal>
   <receiver>%s</receiver>
   <slot>accept()</slot>
   <hints>
    <hint type="sourcelabel">
     <x>248</x>
     <y>254</y>
    </hint>
    <hint type="destinationlabel">
     <x>157</x>
     <y>274</y>
    </hint>
   </hints>
  </connection>
  <connection>
   <sender>buttonBox</sender>
   <signal>rejected()</signal>
   <receiver>%s</receiver>
   <slot>reject()</slot>
   <hints>
    <hint type="sourcelabel">
     <x>316</x>
     <y>260</y>
    </hint>
    <hint type="destinationlabel">
     <x>286</x>
     <y>274</y>
    </hint>
   </hints>
  </connection>
 </connections>
</ui>
]], class_name, class_name, class_name, class_name, class_name)
end

-- 生成表单UI
function M.generate_form_ui(class_name)
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
  <layout class="QFormLayout" name="formLayout">
   <item row="0" column="0">
    <widget class="QLabel" name="label_name">
     <property name="text">
      <string>姓名:</string>
     </property>
    </widget>
   </item>
   <item row="0" column="1">
    <widget class="QLineEdit" name="lineEdit_name"/>
   </item>
   <item row="1" column="0">
    <widget class="QLabel" name="label_email">
     <property name="text">
      <string>邮箱:</string>
     </property>
    </widget>
   </item>
   <item row="1" column="1">
    <widget class="QLineEdit" name="lineEdit_email"/>
   </item>
   <item row="2" column="0">
    <widget class="QLabel" name="label_age">
     <property name="text">
      <string>年龄:</string>
     </property>
    </widget>
   </item>
   <item row="2" column="1">
    <widget class="QSpinBox" name="spinBox_age"/>
   </item>
   <item row="3" column="0" colspan="2">
    <widget class="QPushButton" name="pushButton_submit">
     <property name="text">
      <string>提交</string>
     </property>
    </widget>
   </item>
  </layout>
 </widget>
 <resources/>
 <connections/>
</ui>
]], class_name, class_name, class_name)
end

-- 生成普通窗口UI
function M.generate_widget_ui(class_name)
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
  <layout class="QVBoxLayout" name="verticalLayout">
   <item>
    <widget class="QLabel" name="label">
     <property name="text">
      <string>Hello, Qt!</string>
     </property>
     <property name="alignment">
      <set>Qt::AlignCenter</set>
     </property>
    </widget>
   </item>
  </layout>
 </widget>
 <resources/>
 <connections/>
</ui>
]], class_name, class_name, class_name)
end

-- 列出UI文件
function M.list_ui_files()
  local ui_files = vim.fn.glob("**/*.ui", false, true)
  
  if #ui_files == 0 then
    utils.info("项目中没有找到UI文件")
    return
  end
  
  utils.info("项目UI文件列表:")
  for i, file in ipairs(ui_files) do
    utils.info(string.format("  %d. %s", i, file))
  end
  
  return ui_files
end

return M