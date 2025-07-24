-- Qt开发工具模块入口
local M = {}

-- 导入子模块
M.build = require("qt-dev.tools.build")
M.designer = require("qt-dev.tools.designer")
M.status = require("qt-dev.tools.status")

return M