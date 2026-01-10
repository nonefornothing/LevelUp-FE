import 'package:equatable/equatable.dart';

import '../../../../domain/entities/notification.dart';

/// States for NotificationBloc
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Loaded state
class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final List<AppNotification> unreadNotifications;
  final int unreadCount;
  final NotificationPreferences? preferences;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadNotifications,
    required this.unreadCount,
    this.preferences,
  });

  @override
  List<Object?> get props => [notifications, unreadNotifications, unreadCount, preferences];
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}




