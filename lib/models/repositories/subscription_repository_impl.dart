import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../subscription.dart';
import 'subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SharedPreferences _prefs;
  final String _subscriptionKey = 'subscriptions';
  final http.Client _httpClient;

  SubscriptionRepositoryImpl(this._prefs, this._httpClient);

  @override
  Future<List<Subscription>> getAllSubscriptions() async {
    final String? data = _prefs.getString(_subscriptionKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Subscription.fromJson(json)).toList();
  }

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    final subscriptions = await getAllSubscriptions();
    return subscriptions.firstWhere((sub) => sub.id == id);
  }

  @override
  Future<void> addSubscription(Subscription subscription) async {
    final subscriptions = await getAllSubscriptions();
    subscriptions.add(subscription);
    await _saveSubscriptions(subscriptions);
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    final subscriptions = await getAllSubscriptions();
    final index = subscriptions.indexWhere((sub) => sub.id == subscription.id);
    if (index != -1) {
      subscriptions[index] = subscription;
      await _saveSubscriptions(subscriptions);
    }
  }

  @override
  Future<void> deleteSubscription(String id) async {
    final subscriptions = await getAllSubscriptions();
    subscriptions.removeWhere((sub) => sub.id == id);
    await _saveSubscriptions(subscriptions);
  }

  @override
  Future<void> updateSubscriptionContent(String id) async {
    final subscription = await getSubscriptionById(id);
    if (subscription == null) return;

    try {
      final response = await _httpClient.get(Uri.parse(subscription.url));
      if (response.statusCode == 200) {
        // 更新订阅内容的处理逻辑
        final updatedSubscription = subscription.copyWith(
          lastUpdateTime: DateTime.now(),
          lastError: null,
          isUpdating: false
        );
        await updateSubscription(updatedSubscription);
      } else {
        throw Exception('Failed to update subscription: ${response.statusCode}');
      }
    } catch (e) {
      final updatedSubscription = subscription.copyWith(
        lastError: e.toString(),
        isUpdating: false
      );
      await updateSubscription(updatedSubscription);
      rethrow;
    }
  }

  @override
  Future<void> importSubscriptions(String content) async {
    try {
      final List<dynamic> jsonList = json.decode(content);
      final List<Subscription> subscriptions = jsonList
          .map((json) => Subscription.fromJson(json))
          .toList();
      await _saveSubscriptions(subscriptions);
    } catch (e) {
      throw Exception('Invalid subscription format');
    }
  }

  @override
  Future<String> exportSubscriptions() async {
    final subscriptions = await getAllSubscriptions();
    return json.encode(subscriptions.map((sub) => sub.toJson()).toList());
  }

  @override
  Future<void> checkAndAutoUpdate() async {
    final subscriptions = await getAllSubscriptions();
    for (final subscription in subscriptions) {
      if (!subscription.autoUpdate) continue;
      
      final lastUpdate = subscription.lastUpdateTime ?? DateTime.now();
      final hoursSinceUpdate = DateTime.now().difference(lastUpdate).inHours;
      
      if (hoursSinceUpdate >= subscription.updateInterval) {
        try {
          await updateSubscriptionContent(subscription.id);
        } catch (e) {
          // 错误已在updateSubscriptionContent中处理
          continue;
        }
      }
    }
  }

  @override
  Future<void> clearError(String id) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      final updatedSubscription = subscription.copyWith(lastError: null);
      await updateSubscription(updatedSubscription);
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
      final updatedSubscription = subscription.copyWith(updateInterval: hours);
      await updateSubscription(updatedSubscription);
    }
  }

  @override
  Future<void> setAutoUpdate(String id, bool enabled) async {
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      final updatedSubscription = subscription.copyWith(autoUpdate: enabled);
      await updateSubscription(updatedSubscription);
    }
  }

  Future<void> _saveSubscriptions(List<Subscription> subscriptions) async {
    final String data = json.encode(
      subscriptions.map((sub) => sub.toJson()).toList()
    );
    await _prefs.setString(_subscriptionKey, data);
  }
}