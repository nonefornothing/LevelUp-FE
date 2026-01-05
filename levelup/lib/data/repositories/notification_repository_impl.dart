import '../../core/utils/result.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource _dataSource;

  NotificationRepositoryImpl({
    required NotificationLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<AppNotification>>> getNotifications() async {
    try {
      final notifications = _dataSource.getAllNotifications();
      // Sort by scheduled time (newest first)
      notifications.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
      return Success(notifications);
    } catch (e) {
      return ResultError('Failed to get notifications: $e');
    }
  }

  @override
  Future<Result<List<AppNotification>>> getUnreadNotifications() async {
    try {
      final notifications = _dataSource.getUnreadNotifications();
      // Sort by scheduled time (newest first)
      notifications.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
      return Success(notifications);
    } catch (e) {
      return ResultError('Failed to get unread notifications: $e');
    }
  }

  @override
  Future<Result<AppNotification>> getNotificationById(String id) async {
    try {
      final notification = _dataSource.getNotificationById(id);
      if (notification == null) {
        return ResultError('Notification not found: $id');
      }
      return Success(notification);
    } catch (e) {
      return ResultError('Failed to get notification: $e');
    }
  }

  @override
  Future<Result<AppNotification>> createNotification(AppNotification notification) async {
    try {
      await _dataSource.createNotification(notification);
      return Success(notification);
    } catch (e) {
      return ResultError('Failed to create notification: $e');
    }
  }

  @override
  Future<Result<AppNotification>> markAsDelivered(String id) async {
    try {
      final notificationResult = await getNotificationById(id);
      if (notificationResult is ResultError) {
        return notificationResult;
      }

      final notification = (notificationResult as Success<AppNotification>).data;
      final updatedNotification = notification.copyWith(
        isDelivered: true,
        deliveredAt: DateTime.now(),
      );

      await _dataSource.updateNotification(updatedNotification);
      return Success(updatedNotification);
    } catch (e) {
      return ResultError('Failed to mark notification as delivered: $e');
    }
  }

  @override
  Future<Result<void>> deleteNotification(String id) async {
    try {
      await _dataSource.deleteNotification(id);
      return Success(null);
    } catch (e) {
      return ResultError('Failed to delete notification: $e');
    }
  }

  @override
  Future<Result<void>> clearAllNotifications() async {
    try {
      await _dataSource.clearAllNotifications();
      return Success(null);
    } catch (e) {
      return ResultError('Failed to clear notifications: $e');
    }
  }

  @override
  Future<Result<NotificationPreferences>> getPreferences() async {
    try {
      final preferences = _dataSource.getPreferences();
      return Success(preferences);
    } catch (e) {
      return ResultError('Failed to get preferences: $e');
    }
  }

  @override
  Future<Result<NotificationPreferences>> updatePreferences(NotificationPreferences preferences) async {
    try {
      await _dataSource.updatePreferences(preferences);
      return Success(preferences);
    } catch (e) {
      return ResultError('Failed to update preferences: $e');
    }
  }
}

