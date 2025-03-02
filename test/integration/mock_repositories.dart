import 'package:mockito/mockito.dart';
import 'package:v2rayng/models/repositories/subscription_repository.dart';
import 'package:v2rayng/models/subscription.dart';

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {
  final List<Subscription> _subscriptions = [];

  @override
  Future<List<Subscription>> getAllSubscriptions() async {
    return _subscriptions;
  }

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    try {
      return _subscriptions.firstWhere((sub) => sub.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addSubscription(Subscription subscription) async {
    _subscriptions.add(subscription);
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    final index = _subscriptions.indexWhere((sub) => sub.id == subscription.id);
    if (index >= 0) {
      _subscriptions[index] = subscription;
    } else {
      _subscriptions.add(subscription);
    }
    // 模拟更新订阅内容
    subscription.lastUpdateTime = DateTime.now();
  }

  @override
  Future<void> deleteSubscription(String id) async {
    _subscriptions.removeWhere((sub) => sub.id == id);
  }

  @override
  Future<void> updateSubscriptionContent(String id) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      subscription.lastUpdateTime = DateTime.now();
    }
  }

  @override
  Future<void> importSubscriptions(String content) async {
    // 模拟导入操作
  }

  @override
  Future<String> exportSubscriptions() async {
    return "";
  }

  @override
  Future<void> checkAndAutoUpdate() async {
    // 模拟自动更新检查
  }

  @override
  Future<void> clearError(String id) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      subscription.lastError = null;
    }
  }

  @override
  Future<DateTime?> getLastUpdateTime(String id) async {
    final subscription = await getSubscriptionById(id);
    return subscription?.lastUpdateTime;
  }

  @override
  Future<void> setUpdateInterval(String id, int hours) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      // 创建更新后的订阅对象
      final updatedSubscription = subscription.copyWith(updateInterval: hours);
      // 更新订阅
      await updateSubscription(updatedSubscription);
    }
  }

  @override
  Future<void> setAutoUpdate(String id, bool enabled) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      // 创建更新后的订阅对象
      final updatedSubscription = subscription.copyWith(autoUpdate: enabled);
      // 更新订阅
      await updateSubscription(updatedSubscription);
    }
  }
}