import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/notification.dart';
import '../models/notification_hive_models.dart';
import 'local_storage.dart';

/// Local data source for notifications using Hive
class NotificationLocalDataSource {
  final Box<NotificationHiveModel> _notificationBox;
  final Box<NotificationPreferencesHiveModel> _prefsBox;

  NotificationLocalDataSource({
    Box<NotificationHiveModel>? notificationBox,
    Box<NotificationPreferencesHiveModel>? prefsBox,
  })  : _notificationBox = notificationBox ??
            Hive.box<NotificationHiveModel>(HiveLocalStorage.notificationBoxName),
        _prefsBox = prefsBox ??
            Hive.box<NotificationPreferencesHiveModel>(
                HiveLocalStorage.notificationPrefsBoxName);

  /// Get all notifications
  List<AppNotification> getAllNotifications() {
    return _notificationBox.values.map((model) => model.toDomain()).toList();
  }

  /// Get unread notifications
  List<AppNotification> getUnreadNotifications() {
    return _notificationBox.values
        .where((model) => !model.isDelivered)
        .map((model) => model.toDomain())
        .toList();
  }

  /// Get notification by ID
  AppNotification? getNotificationById(String id) {
    final model = _notificationBox.get(id);
    return model?.toDomain();
  }

  /// Create notification
  Future<void> createNotification(AppNotification notification) async {
    final model = NotificationHiveModel.fromDomain(notification);
    await _notificationBox.put(notification.id, model);
  }

  /// Update notification
  Future<void> updateNotification(AppNotification notification) async {
    final model = NotificationHiveModel.fromDomain(notification);
    await _notificationBox.put(notification.id, model);
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    await _notificationBox.delete(id);
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _notificationBox.clear();
  }

  /// Get notification preferences
  NotificationPreferences getPreferences() {
    final model = _prefsBox.get('preferences');
    if (model != null) {
      return model.toDomain();
    }
    // Return default preferences
    return const NotificationPreferences();
  }

  /// Update notification preferences
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    final model = NotificationPreferencesHiveModel.fromDomain(preferences);
    await _prefsBox.put('preferences', model);
  }
}




