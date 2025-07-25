# 更新日志

所有重要的项目变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

## [1.1.0] - 2025-01-24

### 新增
- 📚 完善了所有文档 (安装指南、配置文档、使用教程、API参考、故障排除)
- 🌍 添加了完整的英文文档系统 (docs/en/)
- 🤝 添加了贡献指南 (CONTRIBUTING.md)
- 📖 新增英文主文档 (README_EN.md)
- 🔍 新增智能环境检测器 (environment_detector.lua)
- 🏗️ 新增项目结构管理模块 (project_structure.lua)
- ⚙️ 新增编译命令生成器 (compile_commands.lua)

### 改进
- 🎨 美化 README.md，增加专业的视觉效果和徽章
- 📊 使用表格和响应式布局优化文档展示
- 🔧 更新API文档以反映实际的项目架构
- 📝 统一了所有文档中的仓库引用 (2774326573/nvim-qt-dev)
- ⚙️ 优化了配置示例和用户配置文件
- ⌨️ 完善快捷键配置系统
- 🗂️ 更新模板系统架构
- 📋 优化核心初始化模块

### 功能增强
- 🔍 更智能的Qt和编译器环境自动检测
- 🏗️ 更完善的项目结构管理和模板生成
- ⚙️ 更可靠的LSP配置和编译命令生成
- 🎨 更流畅的用户交互体验
- 📚 完整的双语文档支持 (中文/English)

### 文档完善
- 📦 详细的安装指南 (中英双语)
- ⚙️ 完整的配置文档 (中英双语)
- 🎓 从入门到进阶的使用教程 (中英双语)
- 📋 完整的API参考文档 (中英双语)
- 🔧 详细的故障排除指南 (中英双语)

## [1.0.0] - 2024-01-24

### 新增功能
- 🎉 初始发布 nvim-qt-dev v1.0.0
- 🚀 支持多种Qt项目类型创建（桌面、控制台、QML、Web、库）
- ⚙️ 智能Qt和编译器路径检测系统
- 📝 自动生成.clangd配置和compile_commands.json
- 🛠️ 集成CMake构建系统
- 🎨 Qt Designer集成
- 🌍 完整的跨平台支持（Windows/Linux）
- 📱 VS Code环境兼容性
- 🔧 交互式配置向导
- 📋 项目状态检查和健康评分
- 🔍 环境诊断和自动修复功能
- ⌨️ 丰富的快捷键系统
- 📚 完整的用户文档

### 核心模块
- **配置系统**: 用户配置管理、路径检测、快捷键配置
- **核心功能**: 项目检测、环境检测、工具函数
- **模板系统**: 项目模板、类模板、UI模板
- **开发工具**: 构建工具、Qt Designer集成、状态检查

### 支持的Qt版本
- Qt 5.12+
- Qt 6.x

### 支持的构建系统
- CMake 3.20+
- qmake (基础支持)

### 语言服务器支持
- clangd (推荐)
- ccls

---

**注意**: 这是 nvim-qt-dev 的首个正式版本，提供了完整的Qt开发环境。如果您遇到任何问题，请在GitHub上提交issue。