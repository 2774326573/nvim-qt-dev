# 发布指南

## 🚀 GitHub发布步骤

### 1. 创建GitHub仓库

1. 在GitHub上创建新仓库：
   - 仓库名: `nvim-qt-dev` (推荐) 或 `qt.nvim`
   - 描述: "A powerful Qt development plugin for Neovim"
   - 设置为Public
   - 不要初始化README (我们已经有了)

### 2. 上传代码

```bash
# 在 nvim-qt-dev 目录中执行
git init
git add .
git commit -m "feat: initial release of nvim-qt-dev v1.0.0

✨ Features:
- Qt project creation (desktop, console, web, qml, library)
- Smart path detection and configuration system
- Automatic .clangd and compile_commands.json generation
- CMake build system integration
- Qt Designer integration
- Cross-platform support (Windows/Linux)
- User-friendly setup wizard
- VS Code compatibility

🔧 Configuration:
- Flexible user configuration system
- Interactive setup wizard
- Path validation and error handling
- Multiple Qt version support

📚 Documentation:
- Comprehensive README and installation guide
- Example configurations
- Troubleshooting guide"

git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/nvim-qt-dev.git
git push -u origin main
```

### 3. 创建发布标签

```bash
# 创建v1.0.0标签
git tag -a v1.0.0 -m "Release v1.0.0

🎉 Initial release of nvim-qt-dev

Major features:
- Complete Qt development environment for Neovim
- Multi-project type support
- Smart configuration system
- Cross-platform compatibility
- LSP integration with clangd
- Built-in build tools and Qt Designer integration

See CHANGELOG.md for detailed changes."

git push origin v1.0.0
```

### 4. 创建GitHub Release

1. 进入GitHub仓库页面
2. 点击 "Releases" → "Create a new release"
3. 填写信息：
   - **Tag version**: `v1.0.0`
   - **Release title**: `nvim-qt-dev v1.0.0 - Initial Release`
   - **Description**:

```markdown
# 🎉 nvim-qt-dev v1.0.0 - Initial Release

A powerful Qt development plugin for Neovim that provides a complete development environment for Qt projects.

## ✨ Key Features

- **🚀 Project Creation**: Support for desktop, console, web, QML, and library projects
- **⚙️ Smart Configuration**: Automatic Qt and compiler path detection with user customization
- **📝 LSP Integration**: Automatic .clangd configuration and compile_commands.json generation
- **🛠️ Build Tools**: Integrated CMake build system and Qt Designer
- **🌍 Cross-Platform**: Full Windows and Linux support
- **📱 VS Code Compatible**: Works seamlessly in VS Code environment

## 🚀 Quick Start

### Installation (lazy.nvim)

\`\`\`lua
{
  "YOUR_USERNAME/nvim-qt-dev",
  ft = { "cpp", "c", "h", "hpp", "cc", "cxx" },
  config = function()
    require("qt-dev").setup()
  end,
}
\`\`\`

### First Time Setup

\`\`\`vim
:QtSetup
\`\`\`

### Create Your First Project

\`\`\`vim
:QtDesktop MyFirstApp
\`\`\`

## 📋 System Requirements

- **Neovim**: 0.8+
- **Qt**: 5.15+ or 6.x
- **CMake**: 3.20+
- **clangd**: For LSP support

## 📚 Documentation

- [Installation Guide](https://github.com/YOUR_USERNAME/nvim-qt-dev#installation)
- [Configuration](https://github.com/YOUR_USERNAME/nvim-qt-dev#configuration)
- [Examples](examples/)

## 🤝 Contributing

Contributions welcome! Please read our [contributing guidelines](CONTRIBUTING.md).

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

If you find this plugin useful, please ⭐ the repository!
```

## 📢 推广和提交

### 1. 提交到awesome-neovim

创建PR到 [awesome-neovim](https://github.com/rockerBOO/awesome-neovim) 仓库:

```markdown
- [nvim-qt-dev](https://github.com/YOUR_USERNAME/nvim-qt-dev) - A powerful Qt development plugin with project creation, smart configuration, and LSP integration.
```

### 2. 提交到dotfyle

在 [dotfyle.com](https://dotfyle.com) 提交您的插件。

### 3. Reddit发布

在以下subreddit发布：
- r/neovim
- r/vim
- r/cpp
- r/Qt

发布模板：
```markdown
[Plugin] nvim-qt-dev - Complete Qt Development Environment for Neovim

I've created a comprehensive Qt development plugin for Neovim that includes:

✨ Features:
- Project creation for multiple Qt project types
- Smart path detection and configuration
- Automatic LSP setup with clangd
- CMake integration and build tools
- Qt Designer integration
- Cross-platform support

The plugin focuses on ease of use with an interactive setup wizard and flexible configuration system.

GitHub: https://github.com/YOUR_USERNAME/nvim-qt-dev
```

### 4. 社区论坛

- [Neovim Discourse](https://neovim.discourse.group/)
- [Qt Forum](https://forum.qt.io/)
- [Dev.to](https://dev.to/) 写技术博客

## 📊 维护和更新

### 版本管理

遵循语义化版本：
- **MAJOR**: 不兼容的API更改
- **MINOR**: 新功能（向后兼容）
- **PATCH**: Bug修复

### 发布清单

每次发布前检查：
- [ ] 更新 CHANGELOG.md
- [ ] 更新版本号 (lua/qt-dev/init.lua)
- [ ] 测试所有功能
- [ ] 更新文档
- [ ] 创建Git标签
- [ ] 发布GitHub Release
- [ ] 通知社区

## 🎯 推荐的GitHub Topics

为仓库添加这些topics提高可发现性：

```
neovim, neovim-plugin, qt, cpp, cmake, lsp, clangd, ide, development-tools, cross-platform
```

## 📈 成功指标

监控这些指标来衡量插件成功：
- GitHub Stars
- Issues/PRs
- Fork数量
- 下载/克隆统计
- 社区反馈

祝您的插件发布成功！🎉