-- Qt项目模板管理模块 - 集成qt-project功能
local utils = require("qt-dev.core.utils")
local M = {}

-- 项目模板类型 (与qt-project保持一致)
M.PROJECT_TYPES = {
  desktop = "Qt Widgets Desktop Application",
  console = "Qt Console Application", 
  web = "Qt WebEngine Web Application",
  qml = "Qt Quick QML Application",
  static_lib = "Qt Static Library",
  dynamic_lib = "Qt Dynamic Library"
}

-- 获取项目模板列表
function M.get_project_types()
  return M.PROJECT_TYPES
end

-- 交互式创建项目 (使用qt-project的完整功能)
function M.create_project_interactive()
  local project_structure = require("qt-dev.templates.project_structure")
  return project_structure.create_project_interactive()
end

-- 直接创建项目 (使用qt-project的完整功能)
function M.create_project_direct(name, project_type, project_path)
  local project_structure = require("qt-dev.templates.project_structure")
  return project_structure.create_project_direct(name, project_type, project_path)
end

-- 创建CMakeLists.txt文件
function M.create_cmake_file(project_dir, name, project_type)
  local cmake_content = M.get_cmake_template(name, project_type)
  local cmake_path = utils.join_path(project_dir, "CMakeLists.txt")
  
  local file = io.open(cmake_path, "w")
  if not file then
    utils.error("无法创建CMakeLists.txt")
    return false
  end
  
  file:write(cmake_content)
  file:close()
  
  return true
end

-- 创建源文件
function M.create_source_file(project_dir, filename, project_name, project_type)
  local content = M.get_source_template(filename, project_name, project_type)
  local file_path = utils.join_path(project_dir, filename)
  
  local file = io.open(file_path, "w")
  if not file then
    utils.error("无法创建文件: " .. filename)
    return false
  end
  
  file:write(content)
  file:close()
  
  return true
end

-- 创建.clangd配置文件
function M.create_clangd_config(project_dir)
  local config = require("qt-dev.config.paths")
  local qt_config = config.get_qt_config()
  
  local clangd_content = string.format([[CompileFlags:
  Add:
    - "-I%s/include"
    - "-I%s/include/QtCore"
    - "-I%s/include/QtGui"
    - "-I%s/include/QtWidgets"
    - "-std=c++17"
  CompilationDatabase: build
]], qt_config.qt_path, qt_config.qt_path, qt_config.qt_path, qt_config.qt_path)
  
  local clangd_path = utils.join_path(project_dir, ".clangd")
  local file = io.open(clangd_path, "w")
  if not file then
    utils.error("无法创建.clangd配置文件")
    return false
  end
  
  file:write(clangd_content)
  file:close()
  
  return true
end

-- 获取CMake模板
function M.get_cmake_template(name, project_type)
  local qt_version = "5" -- 默认Qt5，可以从配置中获取
  
  local template = string.format([[cmake_minimum_required(VERSION 3.22)
project(%s)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找Qt
find_package(Qt%s REQUIRED COMPONENTS Core %s)

# 启用Qt的自动处理
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# 源文件
set(SOURCES
    main.cpp
]], name, qt_version, M.get_qt_components(project_type))

  -- 添加项目特定的源文件
  if project_type == "desktop" then
    template = template .. [[    mainwindow.cpp
)

# UI文件
set(UI_FILES
    mainwindow.ui
)

# 创建可执行文件
add_executable(${PROJECT_NAME} ${SOURCES} ${UI_FILES})

# 链接Qt库
target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Gui Qt5::Widgets)
]]
  elseif project_type == "qml" then
    template = template .. [[)

# QML资源文件
qt5_add_resources(QML_RESOURCES qml.qrc)

# 创建可执行文件
add_executable(${PROJECT_NAME} ${SOURCES} ${QML_RESOURCES})

# 链接Qt库
target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Quick Qt5::Qml)
]]
  else
    template = template .. [[)

# 创建可执行文件
add_executable(${PROJECT_NAME} ${SOURCES})

# 链接Qt库
target_link_libraries(${PROJECT_NAME} Qt5::Core)
]]
  end
  
  return template
end

-- 获取Qt组件
function M.get_qt_components(project_type)
  local components = {
    desktop = "Gui Widgets",
    console = "",
    qml = "Quick Qml",
    web = "WebEngine WebEngineWidgets",
    library = "Gui"
  }
  
  return components[project_type] or ""
end

-- 获取源文件模板
function M.get_source_template(filename, project_name, project_type)
  local templates = require("qt-dev.templates.source_templates")
  return templates.get_template(filename, project_name, project_type)
end

return M