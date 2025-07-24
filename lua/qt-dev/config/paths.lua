-- Qt路径配置模块 - 使用用户配置系统
local utils = require("qt-dev.core.utils")
local user_config = require("qt-dev.config.user_config")
local M = {}

-- 获取Qt基础路径 - 使用用户配置
local function get_qt_base_path()
  local config = user_config.get_effective_config()
  
  -- 如果用户指定了自定义Qt路径，直接使用
  if config.paths.custom_qt_path then
    if vim.fn.isdirectory(config.paths.custom_qt_path) == 1 then
      -- 返回到版本目录的父目录
      local parent = config.paths.custom_qt_path:gsub("([^/\\]+)[/\\]*$", "")
      return parent:gsub("[/\\]+$", "")
    end
  end
  
  if utils.is_windows() then
    -- 使用用户配置的Windows Qt路径
    local windows_qt_paths = {}
    
    -- 添加用户配置的基础路径，构建具体版本路径
    for _, base_path in ipairs(config.qt.base_paths.windows) do
      -- 构建首选版本路径
      local version = config.qt.preferred_version
      table.insert(windows_qt_paths, base_path .. "\\Qt" .. version .. "\\" .. version)
      table.insert(windows_qt_paths, base_path .. "\\" .. version)
      
      -- 添加常见版本
      local common_versions = {"Qt6.6\\6.6.0", "Qt6.5\\6.5.0", "Qt5.15\\5.15.2", "Qt5.12\\5.12.12"}
      for _, ver_path in ipairs(common_versions) do
        table.insert(windows_qt_paths, base_path .. "\\" .. ver_path)
      end
    end
    
    -- 添加环境变量支持
    table.insert(windows_qt_paths, os.getenv("QT_DIR") or "")
    table.insert(windows_qt_paths, os.getenv("QTDIR") or "")
    table.insert(windows_qt_paths, (os.getenv("QT_DIR") and os.getenv("QT_DIR") .. "\\" .. config.qt.preferred_compiler) or "")
    table.insert(windows_qt_paths, (os.getenv("QTDIR") and os.getenv("QTDIR") .. "\\" .. config.qt.preferred_compiler) or "")
    
    -- 调试信息：输出正在检查的路径
    print("Qt路径检测开始...")
    for _, path in ipairs(windows_qt_paths) do
      if path ~= "" then
        local exists = vim.fn.isdirectory(path) == 1
        print(string.format("检查路径: %s - %s", path, exists and "存在" or "不存在"))
        if exists then
          print(string.format("找到Qt安装路径: %s", path))
          return path
        end
      end
    end
    
    -- 如果没找到，返回默认路径
    local default_path = config.qt.base_paths.windows[1] .. "\\Qt" .. config.qt.preferred_version .. "\\" .. config.qt.preferred_version
    print("使用默认Qt路径: " .. default_path)
    return default_path
  else
    -- Linux/WSL Qt路径检测 - 使用用户配置
    local linux_paths = {}
    
    -- 添加用户配置的Linux路径
    for _, path in ipairs(config.qt.base_paths.linux) do
      table.insert(linux_paths, path)
    end
    
    -- 添加环境变量路径
    table.insert(linux_paths, os.getenv("QT_DIR") or "")
    table.insert(linux_paths, os.getenv("QTDIR") or "")
    table.insert(linux_paths, os.getenv("CMAKE_PREFIX_PATH") or "")
    
    for _, path in ipairs(linux_paths) do
      if path ~= "" and vim.fn.isdirectory(path) == 1 then
        return path
      end
    end
    
    -- 如果没找到，返回用户配置的第一个路径
    return config.qt.base_paths.linux[1]
  end
end

-- 检测可用的编译器版本 - 使用用户配置
local function detect_qt_compiler(qt_base_path)
  local config = user_config.get_effective_config()
  
  if utils.is_windows() then
    -- 首先尝试用户首选的编译器
    local preferred = config.qt.preferred_compiler
    local test_path = qt_base_path .. "\\" .. preferred .. "\\bin\\qmake.exe"
    local executable = vim.fn.executable(test_path) == 1
    print(string.format("检查首选编译器: %s - qmake路径: %s - %s", preferred, test_path, executable and "可用" or "不可用"))
    if executable then
      print(string.format("使用首选编译器: %s", preferred))
      return preferred
    end
    
    -- 如果首选编译器不可用，尝试其他编译器
    local possible_compilers = {
      "msvc2022_64", "msvc2019_64", "msvc2017_64",
      "mingw81_64", "mingw73_64", "mingw_64",
      "msvc2022", "msvc2019", "msvc2017",
    }

    print(string.format("检测Qt编译器，基础路径: %s", qt_base_path))
    for _, compiler in ipairs(possible_compilers) do
      if compiler ~= preferred then  -- 跳过已经测试过的首选编译器
        local test_path = qt_base_path .. "\\" .. compiler .. "\\bin\\qmake.exe"
        local executable = vim.fn.executable(test_path) == 1
        print(string.format("检查编译器: %s - qmake路径: %s - %s", compiler, test_path, executable and "可用" or "不可用"))
        if executable then
          print(string.format("找到可用编译器: %s", compiler))
          return compiler
        end
      end
    end
    print("使用默认编译器: " .. preferred)
    return preferred
  else
    -- Linux下直接使用基础路径，不需要编译器子目录
    return ""
  end
end

-- 检测Qt版本 (5.x 或 6.x)
local function detect_qt_version(qt_full_path)
  local qmake_path = utils.is_windows() and (qt_full_path .. "\\bin\\qmake.exe") or (qt_full_path .. "/bin/qmake")
  
  if vim.fn.executable(qmake_path) == 1 then
    -- 尝试运行qmake --version来获取版本信息
    local handle = io.popen(qmake_path .. " --version 2>/dev/null")
    if handle then
      local result = handle:read("*a")
      handle:close()
      
      if result:match("Qt version 6%.") then
        return "6"
      elseif result:match("Qt version 5%.") then
        return "5"
      end
    end
  end
  
  -- 根据路径推测版本
  if qt_full_path:match("Qt6") or qt_full_path:match("/qt6") then
    return "6"
  else
    return "5"  -- 默认假设Qt5
  end
end

-- 获取Qt配置
function M.get_qt_config()
  local config = user_config.get_effective_config()
  local qt_base_path = get_qt_base_path()
  local qt_compiler = detect_qt_compiler(qt_base_path)
  local qt_full_path = utils.is_windows() and (qt_base_path .. "\\" .. qt_compiler) or qt_base_path
  local qt_version = detect_qt_version(qt_full_path)
  
  -- 根据操作系统设置路径分隔符和可执行文件扩展名
  local path_sep = utils.is_windows() and "\\" or "/"
  local exe_ext = utils.is_windows() and ".exe" or ""

  local qt_config = {
    qt_path = qt_full_path,
    qt_version = qt_version, -- 动态检测的版本 (5 或 6)
    qt_version_string = config.qt.preferred_version, -- 用户配置的版本
    qt_compiler = qt_compiler,
    qmake_path = qt_full_path .. path_sep .. "bin" .. path_sep .. "qmake" .. exe_ext,
    cmake_path = qt_full_path .. path_sep .. "bin",
    designer_path = qt_full_path .. path_sep .. "bin" .. path_sep .. "designer" .. exe_ext,
    uic_path = qt_full_path .. path_sep .. "bin" .. path_sep .. "uic" .. exe_ext,
    lrelease_path = qt_full_path .. path_sep .. "bin" .. path_sep .. "lrelease" .. exe_ext,
    lupdate_path = qt_full_path .. path_sep .. "bin" .. path_sep .. "lupdate" .. exe_ext,
    moc_path = qt_full_path .. path_sep .. "bin" .. path_sep .. "moc" .. exe_ext,
    rcc_path = qt_full_path .. path_sep .. "bin" .. path_sep .. "rcc" .. exe_ext,
  }

  -- 保存配置到全局变量
  vim.g.qt_local_config = qt_config
  
  return qt_config
end

return M