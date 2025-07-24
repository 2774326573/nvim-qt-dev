-- C++特定配置模块
local M = {}

-- C++文件类型配置
function M.setup()
  -- C++特定的配置设置
  vim.bo.commentstring = "// %s"
  vim.bo.expandtab = true
  vim.bo.shiftwidth = 4
  vim.bo.tabstop = 4
  vim.bo.softtabstop = 4
  
  -- C++特定的键映射
  local opts = { noremap = true, silent = true, buffer = true }
  
  -- 快速注释
  vim.keymap.set('n', '<leader>/', 'gcc', { desc = '切换行注释', remap = true, buffer = true })
  vim.keymap.set('v', '<leader>/', 'gc', { desc = '切换块注释', remap = true, buffer = true })
  
  -- 格式化
  vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format()<cr>', 
    vim.tbl_extend('force', opts, { desc = '格式化代码' }))
  
  -- 头文件/源文件切换
  vim.keymap.set('n', '<leader>h', function()
    local current_file = vim.fn.expand("%:p")
    local base_name = vim.fn.fnamemodify(current_file, ":r")
    local extension = vim.fn.fnamemodify(current_file, ":e")
    
    local alternate_file = ""
    if extension == "cpp" or extension == "cc" or extension == "cxx" then
      -- 从源文件切换到头文件
      local possible_headers = {base_name .. ".h", base_name .. ".hpp", base_name .. ".hxx"}
      for _, header in ipairs(possible_headers) do
        if vim.fn.filereadable(header) == 1 then
          alternate_file = header
          break
        end
      end
    elseif extension == "h" or extension == "hpp" or extension == "hxx" then
      -- 从头文件切换到源文件
      local possible_sources = {base_name .. ".cpp", base_name .. ".cc", base_name .. ".cxx"}
      for _, source in ipairs(possible_sources) do
        if vim.fn.filereadable(source) == 1 then
          alternate_file = source
          break
        end
      end
    end
    
    if alternate_file ~= "" then
      vim.cmd("edit " .. alternate_file)
    else
      vim.notify("未找到对应的头文件/源文件", vim.log.levels.WARN)
    end
  end, vim.tbl_extend('force', opts, { desc = '切换头文件/源文件' }))
  
  -- LSP相关快捷键
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, 
    vim.tbl_extend('force', opts, { desc = '跳转到定义' }))
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, 
    vim.tbl_extend('force', opts, { desc = '跳转到声明' }))
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
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, 
    vim.tbl_extend('force', opts, { desc = '诊断列表' }))
end

return M