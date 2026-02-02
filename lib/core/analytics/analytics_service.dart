import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';

/// Analytics service interface. Implement with Firebase, Mixpanel, etc.
abstract class AnalyticsService {
  void logEvent(String name, [Map<String, Object?>? params]);
  void setUserId(String? id);
  void setUserProperty(String name, String? value);
}

/// No-op implementation until real analytics is integrated.
class NoOpAnalyticsService implements AnalyticsService {
  @override
  void logEvent(String name, [Map<String, Object?>? params]) {
    AppLogger.debug('Analytics: $name', params);
  }

  @override
  void setUserId(String? id) {
    AppLogger.debug('Analytics setUserId: $id');
  }

  @override
  void setUserProperty(String name, String? value) {
    AppLogger.debug('Analytics setUserProperty: $name = $value');
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return NoOpAnalyticsService();
});
