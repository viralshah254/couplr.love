/// Payload for notification tap — route to open.
const String kNotificationPayloadKeyRoute = 'route';

/// Unique IDs for each daily reminder (must not overlap with other notification IDs).
class NotificationIds {
  NotificationIds._();
  static const int morning = 1001;
  static const int afternoon = 1002;
  static const int evening = 1003;
  static const int urgency = 1004;

  static const List<int> all = [morning, afternoon, evening, urgency];
}
