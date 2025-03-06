import '../subscription.dart';

/// 订阅管理仓库接口
/// 负责管理V2ray的订阅信息，包括订阅的增删改查、导入导出、
/// 自动更新等功能，以及订阅状态的管理
abstract class SubscriptionRepository {
  /// 获取所有订阅
  /// 返回系统中所有配置的订阅列表
  Future<List<Subscription>> getAllSubscriptions();

  /// 根据ID获取订阅
  ///
  /// [id] 订阅ID
  /// 返回指定ID的订阅信息，如果不存在则返回null
  Future<Subscription?> getSubscriptionById(String id);

  /// 添加订阅
  ///
  /// [subscription] 要添加的订阅对象
  /// 将新的订阅信息保存到系统中
  Future<void> addSubscription(Subscription subscription);

  /// 更新订阅信息
  ///
  /// [subscription] 要更新的订阅对象
  /// 更新现有订阅的基本信息
  Future<void> updateSubscription(Subscription subscription);

  /// 删除订阅
  ///
  /// [id] 要删除的订阅ID
  /// 从系统中移除指定的订阅信息
  Future<void> deleteSubscription(String id);

  /// 更新订阅内容
  ///
  /// [id] 订阅ID
  /// 从远程服务器获取最新的服务器配置信息
  /// 并更新到本地存储中
  Future<void> updateSubscriptionContent(String id);

  /// 导入订阅
  ///
  /// [content] 要导入的订阅内容（JSON格式）
  /// 从外部导入订阅信息到系统中
  Future<void> importSubscriptions(String content);

  /// 导出订阅
  /// 将系统中的所有订阅信息导出为JSON格式
  /// 方便备份和迁移
  Future<String> exportSubscriptions();

  /// 检查并执行自动更新
  /// 检查所有启用了自动更新的订阅
  /// 如果达到更新时间则自动更新订阅内容
  Future<void> checkAndAutoUpdate();

  /// 清除更新错误状态
  ///
  /// [id] 订阅ID
  /// 清除指定订阅的更新错误状态
  Future<void> clearError(String id);

  /// 获取上次更新时间
  ///
  /// [id] 订阅ID
  /// 返回指定订阅的最后更新时间
  Future<DateTime?> getLastUpdateTime(String id);

  /// 设置更新间隔
  ///
  /// [id] 订阅ID
  /// [hours] 更新间隔小时数
  /// 设置订阅的自动更新时间间隔
  Future<void> setUpdateInterval(String id, int hours);

  /// 启用/禁用自动更新
  ///
  /// [id] 订阅ID
  /// [enabled] 是否启用自动更新
  /// 控制订阅是否自动更新
  Future<void> setAutoUpdate(String id, bool enabled);
  Future<void> refreshSubscriptions() async {
    // 实现刷新订阅逻辑
    // 例如：从远程更新所有订阅内容
    await Future.delayed(Duration(seconds: 1));
  }
}
