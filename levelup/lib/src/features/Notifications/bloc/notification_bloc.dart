import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/notification.dart';
import '../../../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC for managing notification state
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc({
    NotificationRepository? notificationRepository,
  })  : _notificationRepository = notificationRepository ?? sl<NotificationRepository>(),
        super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoadRequested);
    on<NotificationRefreshRequested>(_onRefreshRequested);
    on<NotificationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<NotificationDeleteRequested>(_onDeleteRequested);
    on<NotificationClearAllRequested>(_onClearAllRequested);
    on<NotificationPreferencesLoadRequested>(_onPreferencesLoadRequested);
    on<NotificationPreferencesUpdateRequested>(_onPreferencesUpdateRequested);
  }

  Future<void> _onLoadRequested(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    try {
      final notificationsResult = await _notificationRepository.getNotifications();
      final unreadResult = await _notificationRepository.getUnreadNotifications();
      final preferencesResult = await _notificationRepository.getPreferences();

      if (notificationsResult is ResultError) {
        emit(NotificationError('Failed to load notifications'));
        return;
      }

      final notifications = (notificationsResult as Success<List<AppNotification>>).data;
      final unreadNotifications = unreadResult is Success<List<AppNotification>>
          ? unreadResult.data
          : <AppNotification>[];
      final preferences = preferencesResult is Success<NotificationPreferences>
          ? preferencesResult.data
          : null;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadNotifications: unreadNotifications,
        unreadCount: unreadNotifications.length,
        preferences: preferences,
      ));
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  Future<void> _onRefreshRequested(
    NotificationRefreshRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notificationsResult = await _notificationRepository.getNotifications();
      final unreadResult = await _notificationRepository.getUnreadNotifications();

      if (notificationsResult is ResultError) {
        emit(NotificationError('Failed to refresh notifications'));
        return;
      }

      final notifications = (notificationsResult as Success<List<AppNotification>>).data;
      final unreadNotifications = unreadResult is Success<List<AppNotification>>
          ? unreadResult.data
          : <AppNotification>[];

      final currentState = state;
      NotificationPreferences? preferences;
      if (currentState is NotificationLoaded) {
        preferences = currentState.preferences;
      }

      emit(NotificationLoaded(
        notifications: notifications,
        unreadNotifications: unreadNotifications,
        unreadCount: unreadNotifications.length,
        preferences: preferences,
      ));
    } catch (e) {
      emit(NotificationError('Failed to refresh notifications: $e'));
    }
  }

  Future<void> _onMarkAsReadRequested(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markAsDelivered(event.notificationId);
      add(const NotificationRefreshRequested());
    } catch (e) {
      emit(NotificationError('Failed to mark notification as read: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.deleteNotification(event.notificationId);
      add(const NotificationRefreshRequested());
    } catch (e) {
      emit(NotificationError('Failed to delete notification: $e'));
    }
  }

  Future<void> _onClearAllRequested(
    NotificationClearAllRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.clearAllNotifications();
      add(const NotificationRefreshRequested());
    } catch (e) {
      emit(NotificationError('Failed to clear notifications: $e'));
    }
  }

  Future<void> _onPreferencesLoadRequested(
    NotificationPreferencesLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final preferencesResult = await _notificationRepository.getPreferences();
      if (preferencesResult is ResultError) {
        emit(NotificationError('Failed to load preferences'));
        return;
      }

      final preferences = (preferencesResult as Success<NotificationPreferences>).data;
      final currentState = state;
      if (currentState is NotificationLoaded) {
        emit(NotificationLoaded(
          notifications: currentState.notifications,
          unreadNotifications: currentState.unreadNotifications,
          unreadCount: currentState.unreadCount,
          preferences: preferences,
        ));
      }
    } catch (e) {
      emit(NotificationError('Failed to load preferences: $e'));
    }
  }

  Future<void> _onPreferencesUpdateRequested(
    NotificationPreferencesUpdateRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final result = await _notificationRepository.updatePreferences(event.preferences);
      if (result is ResultError) {
        emit(NotificationError('Failed to update preferences'));
        return;
      }

      final currentState = state;
      if (currentState is NotificationLoaded) {
        emit(NotificationLoaded(
          notifications: currentState.notifications,
          unreadNotifications: currentState.unreadNotifications,
          unreadCount: currentState.unreadCount,
          preferences: event.preferences,
        ));
      }
    } catch (e) {
      emit(NotificationError('Failed to update preferences: $e'));
    }
  }
}

