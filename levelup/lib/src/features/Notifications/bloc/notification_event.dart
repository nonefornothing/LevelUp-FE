import 'package:equatable/equatable.dart';

import '../../../../domain/entities/notification.dart';

/// Events for NotificationBloc
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications
class NotificationLoadRequested extends NotificationEvent {
  const NotificationLoadRequested();
}

/// Refresh notifications
class NotificationRefreshRequested extends NotificationEvent {
  const NotificationRefreshRequested();
}

/// Mark notification as read
class NotificationMarkAsReadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Delete notification
class NotificationDeleteRequested extends NotificationEvent {
  final String notificationId;

  const NotificationDeleteRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Clear all notifications
class NotificationClearAllRequested extends NotificationEvent {
  const NotificationClearAllRequested();
}

/// Load preferences
class NotificationPreferencesLoadRequested extends NotificationEvent {
  const NotificationPreferencesLoadRequested();
}

/// Update preferences
class NotificationPreferencesUpdateRequested extends NotificationEvent {
  final NotificationPreferences preferences;

  const NotificationPreferencesUpdateRequested(this.preferences);

  @override
  List<Object?> get props => [preferences];
}




