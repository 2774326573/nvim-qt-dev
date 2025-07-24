-- QML特定配置模块
local M = {}

-- QML文件类型配置
function M.setup()
  -- QML特定的配置设置
  vim.bo.commentstring = "// %s"
  vim.bo.expandtab = true
  vim.bo.shiftwidth = 4
  vim.bo.tabstop = 4
  vim.bo.softtabstop = 4
  vim.bo.filetype = "qml"
  
  -- QML特定的键映射
  local opts = { noremap = true, silent = true, buffer = true }
  
  -- 快速注释
  vim.keymap.set('n', '<leader>/', 'gcc', { desc = '切换行注释', remap = true, buffer = true })
  vim.keymap.set('v', '<leader>/', 'gc', { desc = '切换块注释', remap = true, buffer = true })
  
  -- 格式化
  vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format()<cr>', 
    vim.tbl_extend('force', opts, { desc = '格式化QML代码' }))
  
  -- QML预览(如果有qmlscene可用)
  vim.keymap.set('n', '<leader>qp', function()
    local current_file = vim.fn.expand("%:p")
    if vim.fn.executable("qmlscene") == 1 then
      vim.fn.system("qmlscene " .. current_file .. " &")
      vim.notify("启动QML预览: " .. vim.fn.fnamemodify(current_file, ":t"), vim.log.levels.INFO)
    elseif vim.fn.executable("qml") == 1 then
      vim.fn.system("qml " .. current_file .. " &")
      vim.notify("启动QML预览: " .. vim.fn.fnamemodify(current_file, ":t"), vim.log.levels.INFO)
    else
      vim.notify("未找到QML预览工具 (qmlscene/qml)", vim.log.levels.WARN)
    end
  end, vim.tbl_extend('force', opts, { desc = 'QML预览' }))
  
  -- LSP相关快捷键
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, 
    vim.tbl_extend('force', opts, { desc = '跳转到定义' }))
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, 
    vim.tbl_extend('force', opts, { desc = '查找引用' }))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, 
    vim.tbl_extend('force', opts, { desc = '显示悬浮信息' }))
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, 
    vim.tbl_extend('force', opts, { desc = '重命名' }))
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, 
    vim.tbl_extend('force', opts, { desc = '代码操作' }))
  
  -- 诊断相关
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, 
    vim.tbl_extend('force', opts, { desc = '上一个诊断' }))
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, 
    vim.tbl_extend('force', opts, { desc = '下一个诊断' }))
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, 
    vim.tbl_extend('force', opts, { desc = '显示诊断信息' }))
  
  -- QML特定的文本对象和移动
  -- 组件块移动
  vim.keymap.set('n', ']]', function()
    vim.fn.search("^\\s*\\w\\+\\s*{", "W")
  end, vim.tbl_extend('force', opts, { desc = '下一个QML组件' }))
  
  vim.keymap.set('n', '[[', function()
    vim.fn.search("^\\s*\\w\\+\\s*{", "bW")
  end, vim.tbl_extend('force', opts, { desc = '上一个QML组件' }))
end

return M