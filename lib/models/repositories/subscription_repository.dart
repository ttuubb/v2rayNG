import '../subscription.dart';

abstract class SubscriptionRepository {
  // 获取所有订阅
  Future<List<Subscription>> getAllSubscriptions();
  
  // 根据ID获取订阅
  Future<Subscription?> getSubscriptionById(String id);
  
  // 添加订阅
  Future<void> addSubscription(Subscription subscription);
  
  // 更新订阅信息
  Future<void> updateSubscription(Subscription subscription);
  
  // 删除订阅
  Future<void> deleteSubscription(String id);
  
  // 更新订阅内容（从远程获取最新的服务器配置）
  Future<void> updateSubscriptionContent(String id);
  
  // 导入订阅
  Future<void> importSubscriptions(String content);
  
  // 导出订阅
  Future<String> exportSubscriptions();
  
  // 检查并执行自动更新
  Future<void> checkAndAutoUpdate();
  
  // 清除更新错误状态
  Future<void> clearError(String id);
  
  // 获取上次更新时间
  Future<DateTime?> getLastUpdateTime(String id);
  
  // 设置更新间隔
  Future<void> setUpdateInterval(String id, int hours);
  
  // 启用/禁用自动更新
  Future<void> setAutoUpdate(String id, bool enabled);
}