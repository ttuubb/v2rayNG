# v2rayNG 测试指南

本文档列出了项目中所有测试文件及其运行指令，方便开发人员快速执行测试。

## 单元测试 (Unit Tests)

### Models 测试

```bash
# 运行所有 models 测试
flutter test test/unit/models/

# 运行单个测试文件
flutter test test/unit/models/routing_rule_test.dart
flutter test test/unit/models/server_config_test.dart
flutter test test/unit/models/subscription_test.dart
flutter test test/unit/models/traffic_history_test.dart
flutter test test/unit/models/traffic_stats_test.dart
```

### ViewModels 测试

```bash
# 运行所有 viewmodels 测试
flutter test test/unit/viewmodels/

# 运行单个测试文件
flutter test test/unit/viewmodels/log_viewmodel_test.dart
flutter test test/unit/viewmodels/routing_rule_viewmodel_test.dart
flutter test test/unit/viewmodels/server_list_viewmodel_test.dart
flutter test test/unit/viewmodels/traffic_viewmodel_test.dart
```

## 集成测试 (Integration Tests)

```bash
# 运行所有集成测试
flutter test test/integration/

# 运行单个测试文件
flutter test test/integration/module_integration_test.dart
flutter test test/integration/server_management_test.dart
```

## 性能测试 (Performance Tests)

```bash
# 运行所有性能测试
flutter test test/performance/

# 运行单个测试文件
flutter test test/performance/server_performance_test.dart
flutter test test/performance/subscription_performance_test.dart
flutter test test/performance/traffic_performance_test.dart
```

## UI 测试 (UI Tests)

```bash
# 运行所有 UI 测试
flutter test test/ui/

# 运行单个测试文件
flutter test test/ui/server_list_page_test.dart
```

## 运行所有测试

```bash
# 运行项目中的所有测试
flutter test
```

## 生成测试覆盖率报告

```bash
# 生成测试覆盖率报告
flutter test --coverage

# 将覆盖率数据转换为HTML报告（需要安装lcov）
genhtml coverage/lcov.info -o coverage/html
```

## 注意事项

1. 确保在运行测试前已安装所有依赖：`flutter pub get`
2. 对于模拟类的测试，可能需要先生成模拟类：`flutter pub run build_runner build`
3. 集成测试可能需要模拟器或真机设备连接
4. 性能测试结果可能因设备性能而异