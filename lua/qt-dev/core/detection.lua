-- Qt项目检测模块
local utils = require("qt-dev.core.utils")
local M = {}

-- Qt项目类型
local project_types = {
  desktop = "Qt Widgets桌面应用",
  console = "Qt控制台应用",
  qml = "Qt Quick QML应用",
  web = "Qt WebEngine应用",
  library = "Qt库项目",
  unknown = "未知Qt项目"
}

-- 检测Qt项目文件
local function check_qt_files()
  local qt_indicators = {
    cmake = "CMakeLists.txt",
    qmake = {"*.pro", "*.pri"},
    ui_files = "*.ui",
    qrc_files = "*.qrc",
    qml_files = "*.qml",
    ts_files = "*.ts"
  }
  
  local found = {}
  
  -- 检查CMake文件
  if utils.file_exists(qt_indicators.cmake) then
    found.cmake = true
    
    -- 读取CMakeLists.txt检查Qt相关内容
    local file = io.open(qt_indicators.cmake, "r")
    if file then
      local content = file:read("*a")
      file:close()
      
      if content:match("find_package.*Qt[56]") or content:match("find_package.*Qt") then
        found.qt_cmake = true
      end
    end
  end
  
  -- 检查qmake文件
  for _, pattern in ipairs(qt_indicators.qmake) do
    local files = vim.fn.glob(pattern)
    if files ~= "" then
      found.qmake = true
      break
    end
  end
  
  -- 检查UI文件
  local ui_files = vim.fn.glob(qt_indicators.ui_files)
  if ui_files ~= "" then
    found.ui_files = true
  end
  
  -- 检查资源文件
  local qrc_files = vim.fn.glob(qt_indicators.qrc_files)
  if qrc_files ~= "" then
    found.qrc_files = true
  end
  
  -- 检查QML文件
  local qml_files = vim.fn.glob(qt_indicators.qml_files)
  if qml_files ~= "" then
    found.qml_files = true
  end
  
  -- 检查翻译文件
  local ts_files = vim.fn.glob(qt_indicators.ts_files)
  if ts_files ~= "" then
    found.ts_files = true
  end
  
  return found
end

-- 检测项目类型
local function detect_project_type(qt_files)
  -- QML项目
  if qt_files.qml_files then
    return "qml"
  end
  
  -- 桌面应用（有UI文件）
  if qt_files.ui_files then
    return "desktop"
  end
  
  -- 检查CMakeLists.txt或.pro文件内容
  local cmake_file = "CMakeLists.txt"
  local pro_files = vim.fn.glob("*.pro")
  
  if utils.file_exists(cmake_file) then
    local file = io.open(cmake_file, "r")
    if file then
      local content = file:read("*a")
      file:close()
      
      -- 检查Qt模块
      if content:match("Qt.*Widgets") or content:match("Qt5::Widgets") or content:match("Qt6::Widgets") then
        return "desktop"
      elseif content:match("Qt.*Quick") or content:match("Qt5::Quick") or content:match("Qt6::Quick") then
        return "qml"
      elseif content:match("Qt.*WebEngine") or content:match("Qt5::WebEngine") or content:match("Qt6::WebEngine") then
        return "web"
      elseif content:match("add_library") then
        return "library"
      elseif not content:match("Qt.*Gui") and not content:match("Qt5::Gui") and not content:match("Qt6::Gui") then
        return "console"
      end
    end
  elseif pro_files ~= "" then
    local pro_file = vim.fn.split(pro_files, "\n")[1]
    local file = io.open(pro_file, "r")
    if file then
      local content = file:read("*a")
      file:close()
      
      if content:match("QT.*widgets") then
        return "desktop"
      elseif content:match("QT.*quick") then
        return "qml"
      elseif content:match("QT.*webengine") then
        return "web"
      elseif content:match("TEMPLATE.*lib") then
        return "library"
      elseif not content:match("QT.*gui") then
        return "console"
      end
    end
  end
  
  -- 默认为桌面应用
  return "desktop"
end

-- 检测是否为Qt项目
function M.is_qt_project()
  local qt_files = check_qt_files()
  
  -- 任何Qt相关文件存在就认为是Qt项目
  return qt_files.qt_cmake or qt_files.qmake or qt_files.ui_files or 
         qt_files.qrc_files or qt_files.qml_files
end

-- 获取项目信息
function M.get_project_info()
  local qt_files = check_qt_files()
  local project_type = detect_project_type(qt_files)
  local project_root = utils.find_project_root()
  local project_name = vim.fn.fnamemodify(project_root, ":t")
  
  return {
    is_qt_project = M.is_qt_project(),
    type = project_type,
    type_display = project_types[project_type] or project_types.unknown,
    name = project_name,
    root = project_root,
    files = qt_files,
    build_system = qt_files.cmake and "cmake" or (qt_files.qmake and "qmake" or "unknown")
  }
end

-- 检测构建目录
function M.detect_build_directory()
  local common_build_dirs = {
    "build",
    "build-debug",
    "build-release", 
    "cmake-build-debug",
    "cmake-build-release",
    "out/build"
  }
  
  for _, dir in ipairs(common_build_dirs) do
    if utils.dir_exists(dir) then
      return dir
    end
  end
  
  return "build" -- 默认构建目录
end

-- 检测可执行文件
function M.detect_executable()
  local project_info = M.get_project_info()
  local build_dir = M.detect_build_directory()
  
  local possible_names = {
    project_info.name,
    project_info.name .. ".exe",
    "app",
    "app.exe",
    "main",
    "main.exe"
  }
  
  for _, name in ipairs(possible_names) do
    local exe_path = utils.join_path(build_dir, name)
    if utils.file_exists(exe_path) then
      return exe_path
    end
    
    -- 检查Debug/Release子目录
    for _, config in ipairs({"Debug", "Release"}) do
      local config_exe = utils.join_path(build_dir, config, name)
      if utils.file_exists(config_exe) then
        return config_exe
      end
    end
  end
  
  return nil
end

-- 自动检测并设置项目环境
function M.auto_detect_and_setup()
  local project_info = M.get_project_info()
  
  if not project_info.is_qt_project then
    return false, "当前目录不是Qt项目"
  end
  
  utils.info(string.format("检测到Qt项目: %s (%s)", 
    project_info.name, project_info.type_display))
  
  -- 保存项目信息到全局变量
  vim.g.qt_project_info = project_info
  
  return true, project_info
end

return M