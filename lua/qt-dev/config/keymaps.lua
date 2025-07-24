-- Qt开发快捷键配置模块 - 基于qt-project优化
local M = {}

function M.setup_keymaps()
  -- Qt项目管理快捷键
  local project_keymaps = {
    -- 项目管理核心功能
    ["<leader>qo"] = { 
      function() require("qt-dev.tools.project_opener").open_qt_project() end, 
      "打开Qt项目（历史记录+递归搜索）" 
    },
    ["<leader>qn"] = { 
      function() require("qt-dev.templates.project_structure").create_project_interactive() end, 
      "创建新Qt项目" 
    },
    ["<leader>qp"] = { 
      function() require("qt-dev").show_qt_project_info() end, 
      "显示项目信息" 
    },
    ["<leader>qm"] = { 
      function() require("qt-dev").open_cmake_file() end, 
      "打开CMakeLists.txt" 
    },
    
    -- 项目历史管理
    ["<leader>qh"] = { 
      function() require("qt-dev").show_project_history() end, 
      "显示项目历史记录" 
    },
    ["<leader>qH"] = { 
      function() require("qt-dev").clean_project_history() end, 
      "清理项目历史记录" 
    },
    ["<leader>qa"] = { 
      function() require("qt-dev").add_current_to_history() end, 
      "添加当前项目到历史" 
    },
    
    -- Qt Designer集成
    ["<leader>qd"] = { 
      function() require("qt-dev.tools.designer").open_current_file_ui() end, 
      "智能打开Qt Designer" 
    },
    ["<leader>qD"] = { 
      function() require("qt-dev.tools.designer").open_empty_designer() end, 
      "打开空的Qt Designer" 
    },
    
    -- 类创建快捷键
    ["<leader>qc"] = { 
      function() require("qt-dev.templates.class_creator").create_quick_qt_class() end, 
      "快速创建Qt类" 
    },
    ["<leader>qcu"] = { 
      function() require("qt-dev.templates.class_creator").create_qt_ui_class() end, 
      "创建Qt UI类" 
    },
    ["<leader>qci"] = { 
      function() require("qt-dev.templates.class_creator").create_qt_inheritance_class() end, 
      "创建Qt继承类" 
    },
    ["<leader>qcn"] = { 
      function() require("qt-dev.templates.class_creator").create_normal_class() end, 
      "创建普通C++类" 
    },
    
    -- UI模板快捷键
    ["<leader>qui"] = { 
      function() require("qt-dev.templates.ui").select_and_create_ui_template() end, 
      "创建UI模板" 
    },
    ["<leader>qul"] = { 
      function() require("qt-dev.templates.ui").list_ui_files() end, 
      "列出UI文件" 
    },
    
    -- 资源文件快捷键
    ["<leader>qrs"] = { 
      function() require("qt-dev.templates.resources").select_and_create_resource_template() end, 
      "创建资源模板" 
    },
    ["<leader>qrl"] = { 
      function() require("qt-dev.templates.resources").list_resource_files() end, 
      "列出资源文件" 
    },
    
    -- 翻译文件快捷键
    ["<leader>qts"] = { 
      function() require("qt-dev.templates.translations").select_and_create_translation_template() end, 
      "创建翻译模板" 
    },
    ["<leader>qtl"] = { 
      function() require("qt-dev.templates.translations").list_translation_files() end, 
      "列出翻译文件" 
    },
    
    -- 环境检测快捷键
    ["<leader>qe"] = { 
      function() require("qt-dev.core.environment_detector").show_full_environment_report() end, 
      "完整环境报告" 
    },
    ["<leader>qE"] = { 
      function() require("qt-dev.core.environment_detector").quick_environment_check() end, 
      "快速环境检查" 
    },
    
    -- 配置管理快捷键
    ["<leader>qcfg"] = { 
      function() require("qt-dev.config").show_config() end, 
      "显示配置信息" 
    },
    ["<leader>qwiz"] = { 
      function() require("qt-dev.config").setup_wizard() end, 
      "配置向导" 
    },
  }
  
  -- 注册快捷键
  for key, mapping in pairs(project_keymaps) do
    vim.keymap.set("n", key, mapping[1], { desc = mapping[2], noremap = true, silent = true })
  end
  
  -- 创建Which-Key分组描述（如果安装了which-key）
  local has_which_key, wk = pcall(require, "which-key")
  if has_which_key then
    wk.register({
      ["<leader>q"] = {
        name = "+Qt开发",
        o = "打开项目",
        n = "新建项目", 
        p = "项目信息",
        m = "打开CMake",
        h = "项目历史",
        H = "清理历史",
        a = "添加到历史",
        d = "Qt Designer",
        D = "空Designer",
        e = "环境报告",
        E = "快速检查",
        c = {
          name = "+创建类",
          [""] = "快速创建",
          u = "UI类",
          i = "继承类", 
          n = "普通类",
          f = "配置",
        },
        u = {
          name = "+UI模板",
          i = "创建UI",
          l = "列出UI",
        },
        r = {
          name = "+资源文件",
          s = "创建资源",
          l = "列出资源",
        },
        t = {
          name = "+翻译文件",
          s = "创建翻译",
          l = "列出翻译",
        },
      }
    })
  end
end

-- 获取快捷键映射表（用于显示帮助）
function M.get_keymaps()
  return {
    ["项目管理"] = {
      ["<leader>qo"] = "打开Qt项目（智能搜索）",
      ["<leader>qn"] = "创建新Qt项目",
      ["<leader>qp"] = "显示项目信息",
      ["<leader>qm"] = "打开CMakeLists.txt",
    },
    ["项目历史"] = {
      ["<leader>qh"] = "显示项目历史记录",
      ["<leader>qH"] = "清理项目历史记录",
      ["<leader>qa"] = "添加当前项目到历史",
    },
    ["Qt Designer"] = {
      ["<leader>qd"] = "智能打开Qt Designer",
      ["<leader>qD"] = "打开空的Qt Designer",
    },
    ["类创建"] = {
      ["<leader>qc"] = "快速创建Qt类",
      ["<leader>qcu"] = "创建Qt UI类",
      ["<leader>qci"] = "创建Qt继承类",
      ["<leader>qcn"] = "创建普通C++类",
    },
    ["UI模板"] = {
      ["<leader>qui"] = "创建UI模板",
      ["<leader>qul"] = "列出UI文件",
    },
    ["资源文件"] = {
      ["<leader>qrs"] = "创建资源模板",
      ["<leader>qrl"] = "列出资源文件",
    },
    ["翻译文件"] = {
      ["<leader>qts"] = "创建翻译模板",
      ["<leader>qtl"] = "列出翻译文件",
    },
    ["环境检测"] = {
      ["<leader>qe"] = "完整环境报告",
      ["<leader>qE"] = "快速环境检查",
    },
  }
end

-- 显示快捷键帮助
function M.show_keymaps()
  local keymaps = M.get_keymaps()
  local help_lines = {
    "🎯 nvim-qt-dev 快捷键帮助",
    "================================",
    ""
  }
  
  for category, keys in pairs(keymaps) do
    table.insert(help_lines, "📋 " .. category .. ":")
    for key, desc in pairs(keys) do
      table.insert(help_lines, string.format("  %-15s - %s", key, desc))
    end
    table.insert(help_lines, "")
  end
  
  table.insert(help_lines, "💡 提示: 使用 :QtOpenProject 或 <leader>qo 开始你的Qt开发之旅！")
  
  vim.notify(table.concat(help_lines, "\n"), vim.log.levels.INFO)
end

return M