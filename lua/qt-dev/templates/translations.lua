-- Qt翻译文件模板模块
local utils = require("qt-dev.core.utils")
local M = {}

function M.create_translation_template(language, project_name)
  vim.notify("🌐 创建翻译模板: " .. language, vim.log.levels.INFO)
  -- 翻译模板创建逻辑待完善
end

function M.select_and_create_translation_template()
  vim.ui.select({ "zh_CN", "en_US", "ja_JP", "ko_KR" }, {
    prompt = "选择语言:",
  }, function(language)
    if language then
      local project_name = vim.fn.input("项目名称: ")
      if project_name ~= "" then
        M.create_translation_template(language, project_name)
      end
    end
  end)
end

function M.create_all_translations()
  vim.notify("🌍 创建所有翻译文件...", vim.log.levels.INFO)
  -- 批量创建翻译逻辑待完善
end

function M.list_translation_files()
  local ts_files = vim.fn.glob("**/*.ts", false, true)
  if #ts_files > 0 then
    vim.notify("📋 翻译文件列表:\n" .. table.concat(ts_files, "\n"), vim.log.levels.INFO)
  else
    vim.notify("ℹ️ 未找到翻译文件", vim.log.levels.INFO)
  end
end

function M.update_translations()
  vim.notify("🔄 更新翻译文件...", vim.log.levels.INFO)
  -- 更新翻译逻辑待完善
end

return M