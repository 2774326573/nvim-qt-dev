-- Qt项目模板管理模块
local utils = require("qt-dev.core.utils")
local M = {}

-- 项目模板类型
local project_templates = {
  desktop = {
    name = "Qt Widgets桌面应用",
    description = "使用Qt Widgets的传统桌面应用程序",
    files = {"main.cpp", "mainwindow.cpp", "mainwindow.h", "mainwindow.ui"}
  },
  console = {
    name = "Qt控制台应用", 
    description = "基于命令行的Qt控制台应用程序",
    files = {"main.cpp"}
  },
  qml = {
    name = "Qt Quick QML应用",
    description = "使用QML和Qt Quick的现代应用程序",
    files = {"main.cpp", "main.qml", "qml.qrc"}
  },
  web = {
    name = "Qt WebEngine应用",
    description = "集成Web技术的Qt应用程序",
    files = {"main.cpp", "mainwindow.cpp", "mainwindow.h"}
  },
  library = {
    name = "Qt库项目",
    description = "可重用的Qt库项目",
    files = {"library.cpp", "library.h", "library_global.h"}
  }
}

-- 获取项目模板列表
function M.get_project_types()
  return project_templates
end

-- 交互式创建项目
function M.create_project_interactive()
  local types = {}
  local display_names = {}
  
  for key, template in pairs(project_templates) do
    table.insert(types, key)
    table.insert(display_names, string.format("%s - %s", template.name, template.description))
  end
  
  vim.ui.select(display_names, {
    prompt = "选择Qt项目类型:",
  }, function(choice, idx)
    if choice and idx then
      local project_type = types[idx]
      
      vim.ui.input({
        prompt = "请输入项目名称: ",
        default = "MyQtApp",
      }, function(name)
        if name and name ~= "" then
          M.create_project_direct(name, project_type)
        end
      end)
    end
  end)
end

-- 直接创建项目
function M.create_project_direct(name, project_type)
  project_type = project_type or "desktop"
  
  if not project_templates[project_type] then
    utils.error("不支持的项目类型: " .. project_type)
    return
  end
  
  local template = project_templates[project_type]
  local project_dir = utils.join_path(utils.get_cwd(), name)
  
  -- 检查目录是否已存在
  if utils.dir_exists(project_dir) then
    utils.error("项目目录已存在: " .. project_dir)
    return
  end
  
  -- 创建项目目录
  if not utils.mkdir(project_dir) then
    utils.error("无法创建项目目录: " .. project_dir)
    return
  end
  
  utils.info(string.format("创建%s项目: %s", template.name, name))
  
  -- 创建项目文件
  local success = true
  
  -- 创建CMakeLists.txt
  success = success and M.create_cmake_file(project_dir, name, project_type)
  
  -- 创建源文件
  for _, filename in ipairs(template.files) do
    success = success and M.create_source_file(project_dir, filename, name, project_type)
  end
  
  -- 创建.clangd配置
  success = success and M.create_clangd_config(project_dir)
  
  if success then
    utils.success(string.format("项目 '%s' 创建成功！", name))
    utils.info("项目位置: " .. project_dir)
    
    -- 询问是否切换到项目目录
    vim.ui.select({"是", "否"}, {
      prompt = "是否切换到新项目目录？",
    }, function(choice)
      if choice == "是" then
        vim.cmd("cd " .. project_dir)
        utils.success("已切换到项目目录")
      end
    end)
  else
    utils.error("项目创建失败")
  end
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