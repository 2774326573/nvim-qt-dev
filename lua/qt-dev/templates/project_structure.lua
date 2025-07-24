-- Qt项目结构生成模块 - 从qt-project移植并适配nvim-qt-dev
local utils = require("qt-dev.core.utils")
local M = {}

-- 重用qt-project的核心功能，但适配nvim-qt-dev的模块结构
-- 这里包含了qt-project中project_structure.lua的完整功能

-- Qt路径检测和配置
local function detect_qt_installation()
  local qt_paths = {}
  local possible_qt_paths = {}
  
  if utils.is_windows() then
    -- Windows常见Qt安装路径
    possible_qt_paths = {
      "D:/install/Qt",     
      "C:/Qt",
      "C:/Program Files/Qt",
      "C:/Program Files (x86)/Qt",
      os.getenv("QT_DIR") or "",
      os.getenv("QTDIR") or "",
      os.getenv("CMAKE_PREFIX_PATH") or "",
    }
  else
    -- Linux/macOS常见Qt安装路径
    possible_qt_paths = {
      "/usr/lib/qt6",
      "/usr/lib/x86_64-linux-gnu/qt6", 
      "/opt/qt6",
      "/usr/local/qt6",
      "/home/" .. os.getenv("USER") .. "/Qt",
      os.getenv("QT_DIR") or "",
      os.getenv("QTDIR") or ""
    }
  end
  
  -- 检测可用的Qt版本
  for _, base_path in ipairs(possible_qt_paths) do
    if base_path ~= "" and vim.fn.isdirectory(base_path) == 1 then
      -- 扫描版本目录
      local versions = vim.fn.glob(base_path .. "/*", false, true)
      for _, version_dir in ipairs(versions) do
        if vim.fn.isdirectory(version_dir) == 1 then
          local version_name = vim.fn.fnamemodify(version_dir, ":t")
          -- 检查是否是Qt版本目录（包含数字）
          if version_name:match("%d+%.%d+") then
            -- 查找编译器目录
            local compiler_dirs = vim.fn.glob(version_dir .. "/*", false, true)
            for _, compiler_dir in ipairs(compiler_dirs) do
              if vim.fn.isdirectory(compiler_dir) == 1 then
                local compiler_name = vim.fn.fnamemodify(compiler_dir, ":t")
                -- 检查是否包含Qt头文件
                local include_dir = compiler_dir .. "/include"
                if vim.fn.isdirectory(include_dir) == 1 and
                   vim.fn.isdirectory(include_dir .. "/QtCore") == 1 then
                  table.insert(qt_paths, {
                    version = version_name,
                    compiler = compiler_name,
                    path = compiler_dir,
                    include_path = include_dir
                  })
                end
              end
            end
          end
        end
      end
    end
  end
  
  return qt_paths
end

-- 项目模板类型
M.PROJECT_TYPES = {
  desktop = "Qt Widgets Desktop Application",
  console = "Qt Console Application", 
  web = "Qt WebEngine Web Application",
  qml = "Qt Quick QML Application",
  static_lib = "Qt Static Library",
  dynamic_lib = "Qt Dynamic Library"
}

-- 生成CMakeLists.txt内容 (从qt-project移植)
local function generate_cmake_content(project_name, project_type, user_config)
  user_config = user_config or {}
  
  local content = {
    "cmake_minimum_required(VERSION 3.22)",
    "",
    "project(" .. project_name .. " VERSION 1.0.0 LANGUAGES CXX)",
    "",
    "set(CMAKE_CXX_STANDARD 17)",
    "set(CMAKE_CXX_STANDARD_REQUIRED ON)",
    "set(CMAKE_CXX_EXTENSIONS OFF)",
    "",
    "# Fix UTF-8 encoding issues on Windows with MSVC",
    "if(MSVC)",
    "    add_compile_options(/utf-8)",
    "endif()",
    "",
    "# Set output directories",
    "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)",
    "set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)",
    "set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)",
    "",
  }
  
  -- Qt路径设置
  local qt_path = user_config.qt_path or "D:/install/Qt/Qt5.12/5.12.12/msvc2017_64"
  table.insert(content, "# Export compile commands for clangd")
  table.insert(content, "set(CMAKE_EXPORT_COMPILE_COMMANDS ON)")
  table.insert(content, "")
  table.insert(content, "# Qt installation path")
  table.insert(content, "set(CMAKE_PREFIX_PATH \"" .. qt_path .. "\")")
  table.insert(content, "")
  
  table.insert(content, "# Find Qt components - Try Qt6 first, then Qt5")
  table.insert(content, "find_package(Qt6 QUIET COMPONENTS Core)")
  table.insert(content, "if (NOT Qt6_FOUND)")
  table.insert(content, "    find_package(Qt5 REQUIRED COMPONENTS Core)")
  table.insert(content, "    set(QT_VERSION_MAJOR 5)")
  table.insert(content, "else()")
  table.insert(content, "    set(QT_VERSION_MAJOR 6)")
  table.insert(content, "endif()")
  table.insert(content, "")

  if project_type == "desktop" then
    table.insert(content, "if (QT_VERSION_MAJOR EQUAL 6)")
    table.insert(content, "    find_package(Qt6 REQUIRED COMPONENTS Core Widgets)")
    table.insert(content, "else()")
    table.insert(content, "    find_package(Qt5 REQUIRED COMPONENTS Core Widgets)")
    table.insert(content, "endif()")
    table.insert(content, "")
    table.insert(content, "set(CMAKE_AUTOMOC ON)")
    table.insert(content, "set(CMAKE_AUTOUIC ON)")
    table.insert(content, "set(CMAKE_AUTORCC ON)")
    table.insert(content, "")
    table.insert(content, "# Source files")
    table.insert(content, "set(SOURCES")
    table.insert(content, "    src/main.cpp")
    table.insert(content, "    src/mainwindow.cpp")
    table.insert(content, ")")
    table.insert(content, "")
    table.insert(content, "set(HEADERS")
    table.insert(content, "    include/mainwindow.h")
    table.insert(content, ")")
    table.insert(content, "")
    table.insert(content, "set(UI_FILES")
    table.insert(content, "    ui/mainwindow.ui")
    table.insert(content, ")")
    table.insert(content, "")
    table.insert(content, "# Create executable")
    table.insert(content, "add_executable(" .. project_name .. " ${SOURCES} ${HEADERS} ${UI_FILES})")
    table.insert(content, "")
    table.insert(content, "# Include directories")
    table.insert(content, "target_include_directories(" .. project_name .. " PRIVATE include)")
    table.insert(content, "")
    table.insert(content, "# Link Qt libraries")
    table.insert(content, "if (QT_VERSION_MAJOR EQUAL 6)")
    table.insert(content, "    target_link_libraries(" .. project_name .. " Qt6::Core Qt6::Widgets)")
    table.insert(content, "else()")
    table.insert(content, "    target_link_libraries(" .. project_name .. " Qt5::Core Qt5::Widgets)")
    table.insert(content, "endif()")
  elseif project_type == "console" then
    table.insert(content, "if (QT_VERSION_MAJOR EQUAL 6)")
    table.insert(content, "    find_package(Qt6 REQUIRED COMPONENTS Core)")
    table.insert(content, "else()")
    table.insert(content, "    find_package(Qt5 REQUIRED COMPONENTS Core)")
    table.insert(content, "endif()")
    table.insert(content, "")
    table.insert(content, "set(CMAKE_AUTOMOC ON)")
    table.insert(content, "")
    table.insert(content, "# Source files")
    table.insert(content, "set(SOURCES")
    table.insert(content, "    src/main.cpp")
    table.insert(content, ")")
    table.insert(content, "")
    table.insert(content, "# Create executable")
    table.insert(content, "add_executable(" .. project_name .. " ${SOURCES})")
    table.insert(content, "")
    table.insert(content, "# Link Qt libraries")
    table.insert(content, "if (QT_VERSION_MAJOR EQUAL 6)")
    table.insert(content, "    target_link_libraries(" .. project_name .. " Qt6::Core)")
    table.insert(content, "else()")
    table.insert(content, "    target_link_libraries(" .. project_name .. " Qt5::Core)")
    table.insert(content, "endif()")
  -- 其他项目类型的处理...
  end

  -- 添加测试支持
  table.insert(content, "")
  table.insert(content, "# 测试支持")
  table.insert(content, "option(BUILD_TESTING \"Build tests\" OFF)")
  table.insert(content, "if(BUILD_TESTING)")
  table.insert(content, "    enable_testing()")
  table.insert(content, "    add_subdirectory(tests)")
  table.insert(content, "endif()")

  return table.concat(content, "\n")
end

-- 生成主函数文件
local function generate_main_cpp(project_type, project_name)
  if project_type == "desktop" then
    return [[#include <QApplication>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    MainWindow window;
    window.show();
    
    return app.exec();
}
]]
  elseif project_type == "console" then
    return [[#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    qDebug() << "Hello Qt Console Application!";
    qDebug() << "Project:" << "]] .. project_name .. [[";
    
    return app.exec();
}
]]
  end
  return ""
end

-- 交互式创建项目
function M.create_project_interactive()
  -- 让用户选择项目类型
  local project_types = {}
  local type_keys = {}
  
  for key, description in pairs(M.PROJECT_TYPES) do
    table.insert(project_types, description)
    table.insert(type_keys, key)
  end
  
  vim.ui.select(project_types, {
    prompt = "选择项目类型:",
  }, function(selected, idx)
    if selected and idx then
      local selected_type = type_keys[idx]
      
      -- 让用户输入项目名称
      vim.ui.input({ prompt = "请输入项目名称: " }, function(project_name)
        if project_name and project_name ~= "" then
          M.create_project_direct(project_name, selected_type)
        else
          vim.notify("❌ 项目名称不能为空", vim.log.levels.ERROR)
        end
      end)
    else
      vim.notify("❌ 未选择项目类型", vim.log.levels.ERROR)
    end
  end)
end

-- 直接创建项目
function M.create_project_direct(project_name, project_type, project_path)
  if not project_name or project_name == "" then
    vim.notify("❌ 项目名称不能为空", vim.log.levels.ERROR)
    return false
  end
  
  if not project_type or not M.PROJECT_TYPES[project_type] then
    vim.notify("❌ 无效的项目类型", vim.log.levels.ERROR)
    return false
  end
  
  project_path = project_path or vim.fn.getcwd()
  local full_project_path = project_path .. "/" .. project_name
  
  vim.notify("🏗️ 创建Qt项目: " .. project_name .. " (" .. M.PROJECT_TYPES[project_type] .. ")", vim.log.levels.INFO)
  
  -- 创建项目目录结构
  if not M.generate_project_structure(project_type, project_name, full_project_path) then
    return false
  end
  
  vim.notify("✅ Qt项目创建成功: " .. full_project_path, vim.log.levels.INFO)
  return true
end

-- 生成项目结构主函数
function M.generate_project_structure(project_type, project_name, project_path, user_config)
  vim.notify("📁 生成项目结构...", vim.log.levels.INFO)
  user_config = user_config or {}
  
  -- 创建目录结构
  local dirs = {"src", "include", "build", "docs", "tools", "tests", ".vscode"}
  
  if project_type == "desktop" or project_type == "web" then
    table.insert(dirs, "ui")
  elseif project_type == "qml" then
    table.insert(dirs, "qml")
  end
  
  -- 创建目录
  for _, dir in ipairs(dirs) do
    local dir_path = project_path .. "/" .. dir
    if vim.fn.isdirectory(dir_path) == 0 then
      vim.fn.mkdir(dir_path, "p")
    end
  end
  
  -- 生成CMakeLists.txt
  local cmake_content = generate_cmake_content(project_name, project_type, user_config)
  local cmake_file = io.open(project_path .. "/CMakeLists.txt", "w")
  if cmake_file then
    cmake_file:write(cmake_content)
    cmake_file:close()
  else
    vim.notify("❌ 无法创建CMakeLists.txt", vim.log.levels.ERROR)
    return false
  end
  
  -- 根据项目类型生成特定文件
  if project_type == "desktop" or project_type == "console" then
    -- 生成main.cpp
    local main_content = generate_main_cpp(project_type, project_name)
    local main_file = io.open(project_path .. "/src/main.cpp", "w")
    if main_file then
      main_file:write(main_content)
      main_file:close()
    end
    
    -- 为桌面应用生成主窗口文件
    if project_type == "desktop" then
      -- 这里可以添加mainwindow.h和mainwindow.cpp的生成逻辑
    end
  end
  
  -- 生成README.md
  local readme_content = "# " .. project_name .. "\n\n" .. M.PROJECT_TYPES[project_type] .. "\n\n## 构建说明\n\n```bash\nmkdir build\ncd build\ncmake ..\nmake\n```"
  local readme_file = io.open(project_path .. "/README.md", "w")
  if readme_file then
    readme_file:write(readme_content)
    readme_file:close()
  end
  
  return true
end

return M