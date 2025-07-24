-- Qt项目快捷键配置模块 - 用户配置版本
local M = {}

function M.setup_keymaps(is_vscode)
  is_vscode = is_vscode or false
  
  -- 根据环境选择不同的实现
  local get_build_func = function(action)
    if is_vscode then
      local vscode_integration = require("qt-dev.core.vscode_integration")
      if action == "build" then
        return vscode_integration.integrated_build
      elseif action == "run" then
        return vscode_integration.integrated_run
      elseif action == "clean" then
        return vscode_integration.integrated_clean
      end
    end
    
    -- 默认使用qt-dev原生功能
    local build_module = require("qt-dev.tools.build")
    if action == "build" then
      return build_module.build_project
    elseif action == "run" then
      return build_module.run_project
    elseif action == "clean" then
      return build_module.clean_project
    end
  end
  
  local get_designer_func = function()
    if is_vscode then
      local vscode_integration = require("qt-dev.core.vscode_integration")
      return vscode_integration.open_designer
    else
      return require("qt-dev.tools.designer").open_current_file_ui
    end
  end

  -- 设置键盘快捷键 - 包含配置管理
  local keymaps = {
    -- 项目管理
    ["<leader>qo"] = { function() require("qt-dev.core.project_opener").open_qt_project() end, "打开Qt项目" },
    ["<leader>qn"] = { function() require("qt-dev.templates.project").create_qt_project() end, "创建新Qt项目" },
    
    -- 构建和运行 - 智能选择VS Code或原生实现
    ["<leader>qb"] = { get_build_func("build"), is_vscode and "构建项目 (VS Code集成)" or "构建项目" },
    ["<leader>qd"] = { get_designer_func(), is_vscode and "智能打开Qt Designer (VS Code集成)" or "智能打开Qt Designer" },
    ["<leader>qD"] = { function() require("qt-dev.tools.designer").open_empty_designer() end, "直接打开Qt Designer" },
    
    -- 工具组 (qt + tools) - 集成版本
    ["<leader>qtb"] = { get_build_func("build"), is_vscode and "Tools: 构建项目 (集成)" or "Tools: 构建项目" },
    ["<leader>qtc"] = { get_build_func("clean"), is_vscode and "Tools: 清理项目 (集成)" or "Tools: 清理项目" },
    ["<leader>qtr"] = { get_build_func("run"), is_vscode and "Tools: 运行项目 (集成)" or "Tools: 运行项目" },
    ["<leader>qtd"] = { function() require("qt-dev.tools.build").build_debug_project() end, "Tools: Debug构建" },
    ["<leader>qtD"] = { get_designer_func(), is_vscode and "Tools: 智能Qt Designer (集成)" or "Tools: 智能打开Qt Designer" },
    
    -- 类创建相关快捷键
    ["<leader>qc"] = { function() require("qt-dev.templates.class").create_quick_qt_class() end, "快速创建Qt类" },
    ["<leader>qcu"] = { function() require("qt-dev.templates.class").create_qt_ui_class() end, "创建Qt UI类" },
    ["<leader>qci"] = { function() require("qt-dev.templates.class").create_qt_inheritance_class() end, "创建Qt继承类" },
    ["<leader>qcn"] = { function() require("qt-dev.templates.class").create_normal_class() end, "创建普通C++类" },
    
    -- UI模板相关快捷键
    ["<leader>qui"] = { function() require("qt-dev.templates.ui").select_and_create_ui_template() end, "创建UI模板" },
    ["<leader>qul"] = { function() require("qt-dev.templates.ui").list_ui_files() end, "列出UI文件" },
    
    -- 状态检查和诊断
    ["<leader>qst"] = { function() require("qt-dev.tools.status").check_project_status() end, "完整状态检查" },
    ["<leader>qsd"] = { function() require("qt-dev.tools.status").quick_diagnose() end, "快速诊断" },
    ["<leader>qsf"] = { function() require("qt-dev.tools.status").auto_fix_common_issues() end, "自动修复问题" },
    
    -- 配置管理 - 新增功能
    ["<leader>qcs"] = { function() require("qt-dev.config.user_config").setup_wizard() end, "运行配置向导" },
    ["<leader>qcc"] = { function() require("qt-dev.config.user_config").show_config() end, "显示当前配置" },
    ["<leader>qcf"] = { function() require("qt-dev.config.user_config").create_default_config() end, "创建配置文件" },
    
    -- 插件问题修复
    ["<leader>qpf"] = { function() require("qt-dev.core.utils").fix_common_plugin_issues() end, "修复插件问题" },
    
    -- 环境检测功能
    ["<leader>qse"] = { function() require("qt-dev.core.environment").show_full_environment_report() end, "完整环境报告" },
    ["<leader>qsq"] = { function() require("qt-dev.core.environment").quick_environment_check() end, "快速环境检查" },
  }
  
  -- VS Code集成功能 - 条件添加
  if is_vscode then
    keymaps["<leader>qvs"] = { function() 
      local vscode_integration = require("qt-dev.core.vscode_integration")
      vscode_integration.sync_config_to_vscode() 
    end, "同步配置到VS Code" }
    
    keymaps["<leader>qvi"] = { function() 
      local vscode_integration = require("qt-dev.core.vscode_integration")
      vscode_integration.detect_and_suggest() 
    end, "VS Code集成建议" }
  end

  -- 使用更高优先级设置快捷键
  for key, mapping in pairs(keymaps) do
    vim.keymap.set("n", key, mapping[1], { 
      desc = mapping[2], 
      noremap = true, 
      silent = true,
      buffer = false -- 全局快捷键
    })
  end
  
  -- 显示配置相关快捷键提示
  vim.notify("💡 配置管理快捷键: <leader>qcs(向导) <leader>qcc(显示) <leader>qcf(创建)", vim.log.levels.INFO)
end

-- 设置项目特定快捷键
function M.setup_project_keymaps()
  -- 项目特定的快捷键可以在这里设置
  vim.notify("📋 Qt项目快捷键已激活", vim.log.levels.INFO)
end

return M