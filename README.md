# V2rayNG Flutter

[![Flutter Tests](https://github.com/yourusername/v2rayng/actions/workflows/flutter_tests.yml/badge.svg)](https://github.com/yourusername/v2rayng/actions/workflows/flutter_tests.yml)

## 项目概述

V2rayNG Flutter 是一个使用 Flutter 框架开发的跨平台代理工具客户端，支持 Android、iOS 等多个平台。本项目是对原生 Android 版本 V2rayNG 的重新实现，旨在提供更好的跨平台体验和更现代化的用户界面。

## 主要特性

- **多协议支持**：支持 VMess、VLESS、Shadowsocks、Trojan 等多种代理协议
- **服务器管理**：便捷的服务器添加、编辑、删除和分享功能
- **订阅功能**：支持订阅地址导入和自动更新
- **路由规则**：灵活的路由规则配置，支持应用分流
- **流量统计**：实时监控和记录网络流量使用情况
- **多语言支持**：内置多语言界面
- **暗黑模式**：支持系统暗黑模式，保护您的眼睛

## 截图展示

(此处可添加应用截图)

## 技术栈

- **前端框架**: Flutter
- **编程语言**: Dart
- **状态管理**: Provider
- **本地存储**: Hive、SharedPreferences
- **网络请求**: Dio
- **依赖注入**: GetIt

## 安装说明

### 环境要求

- Flutter SDK: >=2.19.0 <4.0.0
- Dart SDK: >=2.19.0

### 从源码构建

1. 克隆仓库

```bash
git clone https://github.com/ttuubb/v2rayNG.git
cd v2rayng
```

2. 安装依赖

```bash
flutter pub get
```

3. 运行应用

```bash
flutter run
```

### 下载预编译版本

您可以从 [Releases](https://github.com/ttuubb/v2rayNG.git/releases) 页面下载最新的预编译版本。

## 使用指南

### 添加服务器

1. 打开应用，进入「服务器列表」页面
2. 点击右下角的「+」按钮
3. 选择添加方式：手动添加、扫描二维码或从剪贴板导入
4. 填写或确认服务器信息后保存

### 订阅管理

1. 进入「订阅管理」页面
2. 点击「添加订阅」
3. 输入订阅地址并保存
4. 点击「更新」按钮刷新订阅内容

### 启动代理

1. 在服务器列表中选择一个服务器
2. 点击「启动」按钮
3. 授予 VPN 权限（首次使用时）

### 流量统计

应用会自动记录您的网络流量使用情况，您可以在「流量统计」页面查看详细数据。

## 架构设计

本项目采用 MVVM (Model-View-ViewModel) 架构模式，主要分为以下几个层次：

- **Model 层**：定义数据结构和业务逻辑
- **View 层**：负责 UI 展示和用户交互
- **ViewModel 层**：连接 Model 和 View，处理业务逻辑
- **Service 层**：提供底层服务，如网络请求、本地存储等

### 目录结构

```
lib/
├── core/           # 核心功能和服务
│   ├── di/        # 依赖注入
│   ├── events/    # 事件定义
│   ├── services/  # 服务实现
│   └── utils/     # 工具类
├── models/        # 数据模型
├── repositories/  # 数据仓库
├── viewmodels/    # 视图模型
├── views/         # UI 界面
│   └── themes/    # 主题定义
└── main.dart      # 应用入口
```

## 贡献指南

我们欢迎并感谢任何形式的贡献！

### 提交 Issue

- 使用清晰的标题和详细的描述
- 如果是 Bug 报告，请提供复现步骤和环境信息
- 如果是功能请求，请描述您的需求和使用场景

### 提交 Pull Request

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开一个 Pull Request

### 代码风格

请遵循 [Dart 风格指南](https://dart.dev/guides/language/effective-dart/style) 和项目现有的代码风格。

## 测试

本项目包含单元测试、集成测试和性能测试。运行测试：

```bash
# 运行所有测试
flutter test

# 运行单元测试
flutter test test/unit

# 运行集成测试
flutter test test/integration

# 运行性能测试
flutter test test/performance
```

## 许可证

本项目采用 [MIT 许可证](LICENSE)。

## 致谢

- [V2Ray 项目](https://github.com/v2ray/v2ray-core)
- [Flutter 团队](https://flutter.dev/)
- 所有贡献者和用户

## 联系方式

如有任何问题或建议，请通过以下方式联系我们：

- 提交 [Issue](https://github.com/ttuubb/v2rayNG.git/issues)
- 发送邮件至：ttuubb1988@outlook.com

---

**免责声明**：本项目仅供学习和研究网络技术使用，请遵守当地法律法规。