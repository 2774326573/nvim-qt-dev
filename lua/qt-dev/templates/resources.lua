-- Qt资源文件模板模块
local utils = require("qt-dev.core.utils")
local M = {}

function M.create_resource_template(template_type, resource_name)
  vim.notify("📦 创建资源模板: " .. resource_name, vim.log.levels.INFO)
  -- 资源模板创建逻辑待完善
end

function M.select_and_create_resource_template()
  vim.ui.input({ prompt = "输入资源文件名: " }, function(resource_name)
    if resource_name and resource_name ~= "" then
      M.create_resource_template("qrc", resource_name)
    end
  end)
end

function M.list_resource_files()
  local resource_files = vim.fn.glob("**/*.qrc", false, true)
  if #resource_files > 0 then
    vim.notify("📋 资源文件列表:\n" .. table.concat(resource_files, "\n"), vim.log.levels.INFO)
  else
    vim.notify("ℹ️ 未找到资源文件", vim.log.levels.INFO)
  end
end

return M