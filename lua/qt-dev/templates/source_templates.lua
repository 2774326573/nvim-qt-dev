-- Qt项目源文件模板
local M = {}

-- 获取模板内容
function M.get_template(filename, project_name, project_type)
  local extension = filename:match("%.([^%.]+)$")
  local basename = filename:match("([^%.]+)")
  
  if extension == "cpp" then
    return M.get_cpp_template(basename, project_name, project_type)
  elseif extension == "h" then
    return M.get_header_template(basename, project_name, project_type)
  elseif extension == "ui" then
    return M.get_ui_template(basename, project_name)
  elseif extension == "qml" then
    return M.get_qml_template(basename, project_name)
  elseif extension == "qrc" then
    return M.get_qrc_template(project_name)
  else
    return ""
  end
end

-- C++源文件模板
function M.get_cpp_template(basename, project_name, project_type)
  if basename == "main" then
    return M.get_main_cpp_template(project_name, project_type)
  elseif basename == "mainwindow" then
    return M.get_mainwindow_cpp_template(project_name)
  elseif basename == "library" then
    return M.get_library_cpp_template(project_name)
  else
    return M.get_generic_cpp_template(basename, project_name)
  end
end

-- 头文件模板
function M.get_header_template(basename, project_name, project_type)
  if basename == "mainwindow" then
    return M.get_mainwindow_h_template(project_name)
  elseif basename == "library" then
    return M.get_library_h_template(project_name)
  elseif basename == "library_global" then
    return M.get_library_global_h_template(project_name)
  else
    return M.get_generic_h_template(basename, project_name)
  end
end

-- main.cpp模板
function M.get_main_cpp_template(project_name, project_type)
  if project_type == "desktop" then
    return string.format([[#include "mainwindow.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    MainWindow window;
    window.show();
    
    return app.exec();
}
]])
  elseif project_type == "console" then
    return string.format([[#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    qDebug() << "Hello, Qt Console Application!";
    
    return app.exec();
}
]])
  elseif project_type == "qml" then
    return string.format([[#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    
    if (engine.rootObjects().isEmpty())
        return -1;
    
    return app.exec();
}
]])
  else
    return [[#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    // Your application code here
    
    return app.exec();
}
]]
  end
end

-- mainwindow.cpp模板
function M.get_mainwindow_cpp_template(project_name)
  return [[#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    setWindowTitle("]] .. project_name .. [[");
}

MainWindow::~MainWindow()
{
    delete ui;
}
]]
end

-- mainwindow.h模板
function M.get_mainwindow_h_template(project_name)
  local guard = string.upper(project_name) .. "_MAINWINDOW_H"
  
  return string.format([[#ifndef %s
#define %s

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    Ui::MainWindow *ui;
};

#endif // %s
]], guard, guard, guard)
end

-- mainwindow.ui模板
function M.get_ui_template(basename, project_name)
  return string.format([[<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>MainWindow</class>
 <widget class="QMainWindow" name="MainWindow">
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
       <string>欢迎使用 %s！</string>
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
]], project_name, project_name)
end

-- main.qml模板
function M.get_qml_template(basename, project_name)
  return string.format([[import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "%s"

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f0f0f0" }
            GradientStop { position: 1.0; color: "#e0e0e0" }
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "欢迎使用 %s！"
                font.pixelSize: 24
                font.bold: true
                color: "#333333"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                text: "点击我"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    console.log("按钮被点击了！")
                }
            }
        }
    }
}
]], project_name, project_name)
end

-- qml.qrc模板
function M.get_qrc_template(project_name)
  return [[<RCC>
    <qresource prefix="/">
        <file>main.qml</file>
    </qresource>
</RCC>
]]
end

-- 库项目模板
function M.get_library_cpp_template(project_name)
  return string.format([[#include "library.h"

%s::%s()
{
    // 构造函数实现
}

%s::~%s()
{
    // 析构函数实现
}

QString %s::version()
{
    return "1.0.0";
}
]], project_name, project_name, project_name, project_name, project_name)
end

function M.get_library_h_template(project_name)
  local guard = string.upper(project_name) .. "_LIBRARY_H"
  
  return string.format([[#ifndef %s
#define %s

#include "library_global.h"
#include <QString>

class LIBRARY_EXPORT %s
{
public:
    %s();
    ~%s();
    
    static QString version();
};

#endif // %s
]], guard, guard, project_name, project_name, project_name, guard)
end

function M.get_library_global_h_template(project_name)
  local guard = string.upper(project_name) .. "_LIBRARY_GLOBAL_H"
  
  return string.format([[#ifndef %s
#define %s

#include <QtCore/qglobal.h>

#if defined(LIBRARY_LIBRARY)
#  define LIBRARY_EXPORT Q_DECL_EXPORT
#else
#  define LIBRARY_EXPORT Q_DECL_IMPORT
#endif

#endif // %s
]], guard, guard, guard)
end

-- 通用模板
function M.get_generic_cpp_template(basename, project_name)
  return string.format([[#include "%s.h"

%s::%s()
{
    // 构造函数实现
}

%s::~%s()
{
    // 析构函数实现
}
]], basename, basename, basename, basename, basename)
end

function M.get_generic_h_template(basename, project_name)
  local guard = string.upper(basename) .. "_H"
  local class_name = basename:gsub("^%l", string.upper)
  
  return string.format([[#ifndef %s
#define %s

#include <QObject>

class %s : public QObject
{
    Q_OBJECT

public:
    explicit %s(QObject *parent = nullptr);
    ~%s();

signals:

};

#endif // %s
]], guard, guard, class_name, class_name, class_name, guard)
end

return M