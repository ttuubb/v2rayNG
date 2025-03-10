class SubscriptionModel {
  final String name;
  final String url;
  final bool enabled;
  final DateTime? lastUpdate;
  final Duration updateInterval;

  SubscriptionModel({
    required this.name,
    required this.url,
    this.enabled = true,
    this.lastUpdate,
    this.updateInterval = const Duration(hours: 24),
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'enabled': enabled,
      'lastUpdate': lastUpdate?.toIso8601String(),
      'updateInterval': updateInterval.inSeconds,
    };
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      name: json['name'] as String,
      url: json['url'] as String,
      enabled: json['enabled'] as bool,
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.parse(json['lastUpdate'] as String)
          : null,
      updateInterval: Duration(seconds: json['updateInterval'] as int),
    );
  }

  bool validateUrl() {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (_) {
      return false;
    }
  }

  bool needsUpdate() {
    if (!enabled) return false;
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(lastUpdate!);
    return timeSinceLastUpdate >= updateInterval;
  }
}
