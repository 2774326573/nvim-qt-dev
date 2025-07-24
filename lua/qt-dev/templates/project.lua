-- Qt项目创建模块 (兼容别名)
-- 这个文件作为templates.init的别名，用于向后兼容
local templates = require("qt-dev.templates")

-- 重新导出主要函数
return {
  create_qt_project = templates.create_project_interactive,
  create_project_direct = templates.create_project_direct,
  create_project_interactive = templates.create_project_interactive,
}