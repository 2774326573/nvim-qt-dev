# 贡献指南

感谢您对 nvim-qt-dev 项目的兴趣！我们欢迎各种形式的贡献。

## 📋 贡献方式

- 🐛 报告Bug
- 💡 提出新功能建议
- 📝 改进文档
- 🔧 提交代码修复
- 🎨 增强用户体验
- 🧪 编写测试

## 🚀 快速开始

### 开发环境设置

1. **Fork 仓库**
   ```bash
   # 克隆您的fork
   git clone https://github.com/2774326573/nvim-qt-dev.git
   cd nvim-qt-dev
   ```

2. **安装开发依赖**
   ```bash
   # 安装Neovim (0.8+)
   # 安装Qt开发环境
   # 安装Lua语言服务器 (可选)
   ```

3. **设置开发环境**
   ```lua
   -- 在Neovim配置中添加本地路径
   vim.opt.rtp:prepend('/path/to/nvim-qt-dev')
   ```

## 🐛 报告Bug

### Bug报告清单

提交Bug报告时，请包含以下信息：

- [ ] **系统信息**
  - 操作系统版本
  - Neovim版本 (`:version`)
  - Qt版本
  - 编译器版本

- [ ] **插件信息**
  - 插件版本
  - 配置信息
  - `:QtStatus` 输出

- [ ] **重现步骤**
  - 详细的操作步骤
  - 预期行为
  - 实际行为

- [ ] **错误信息**
  - 完整的错误消息
  - `:messages` 输出
  - 日志文件（如果有）

## 💡 功能建议

### 功能请求清单

- [ ] **功能描述**
  - 清晰描述建议的功能
  - 解释为什么需要这个功能

- [ ] **使用场景**
  - 描述具体的使用场景
  - 提供使用示例

- [ ] **实现建议**
  - 如果有想法，描述可能的实现方式
  - 考虑与现有功能的兼容性

## 🔧 代码贡献

### 开发流程

1. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **编写代码**
   - 遵循项目代码风格
   - 添加必要的注释
   - 确保向后兼容性

3. **测试**
   - 测试新功能
   - 确保不破坏现有功能
   - 在不同环境下测试

4. **提交代码**
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

5. **创建Pull Request**
   - 描述变更内容
   - 关联相关Issue
   - 请求代码审查

### 代码风格

#### Lua代码风格

```lua
-- 使用2个空格缩进
local M = {}

-- 函数命名使用snake_case
function M.create_project(options)
  -- 变量命名使用snake_case
  local project_name = options.name
  
  -- 常量使用UPPER_CASE
  local DEFAULT_TYPE = "desktop"
  
  -- 字符串使用双引号
  local message = "项目创建成功"
  
  -- 表格格式化
  local config = {
    name = project_name,
    type = DEFAULT_TYPE,
    enabled = true
  }
end

return M
```

### 提交信息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**类型 (type):**
- `feat`: 新功能
- `fix`: Bug修复
- `docs`: 文档更新
- `style`: 代码格式化
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具相关

## 📝 文档贡献

### 文档编写指南

1. **结构清晰**
   - 使用标题层次结构
   - 添加目录导航
   - 合理使用列表和表格

2. **内容准确**
   - 确保示例代码可运行
   - 及时更新过时信息
   - 提供完整的配置示例

3. **用户友好**
   - 使用清晰的说明
   - 提供故障排除信息
   - 包含截图或录屏（如适用）

## 🧪 测试

### 手动测试

在提交代码前，请确保：

1. **基础功能测试**
   ```vim
   :QtCreate TestApp desktop
   :QtBuild
   :QtRun
   :QtDesigner
   :QtStatus
   ```

2. **多环境测试**
   - Windows + MSVC
   - Windows + MinGW
   - Linux + GCC
   - Linux + Clang

## 🤝 社区

### 行为准则

- 尊重所有参与者
- 建设性地提供反馈
- 保持友好和专业
- 帮助新手贡献者

### 交流渠道

- **GitHub Issues**: Bug报告和功能请求
- **GitHub Discussions**: 一般讨论和问答
- **Pull Requests**: 代码审查和讨论

## 📄 许可证

通过贡献代码，您同意将您的贡献按照 [MIT License](LICENSE) 进行许可。

## 🙏 致谢

感谢所有贡献者！您的贡献让这个项目变得更好。

---

如果您有任何问题，请随时在GitHub上创建Issue或Discussion。我们很乐意帮助您开始贡献！