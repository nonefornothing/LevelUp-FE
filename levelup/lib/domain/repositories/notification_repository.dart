import '../../core/utils/result.dart';
import '../entities/notification.dart';

/// Notification Repository Interface (Domain layer)
abstract class NotificationRepository {
  /// Get all notifications
  Future<Result<List<AppNotification>>> getNotifications();

  /// Get unread notifications
  Future<Result<List<AppNotification>>> getUnreadNotifications();

  /// Get notification by ID
  Future<Result<AppNotification>> getNotificationById(String id);

  /// Create notification
  Future<Result<AppNotification>> createNotification(AppNotification notification);

  /// Mark notification as read/delivered
  Future<Result<AppNotification>> markAsDelivered(String id);

  /// Delete notification
  Future<Result<void>> deleteNotification(String id);

  /// Clear all notifications
  Future<Result<void>> clearAllNotifications();

  /// Get notification preferences
  Future<Result<NotificationPreferences>> getPreferences();

  /// Update notification preferences
  Future<Result<NotificationPreferences>> updatePreferences(NotificationPreferences preferences);
}




