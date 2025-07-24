-- Qt开发核心模块入口
local M = {}

-- 导入子模块
M.utils = require("qt-dev.core.utils")
M.detection = require("qt-dev.core.detection")
M.environment = require("qt-dev.core.environment")

return M