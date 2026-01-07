import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' as material;

/// Notification entity (Domain layer)
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledTime;
  final bool isScheduled;
  final bool isDelivered;
  final DateTime? deliveredAt;
  final Map<String, dynamic>? payload; // For navigation or additional data
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    required this.isScheduled,
    required this.isDelivered,
    this.deliveredAt,
    this.payload,
    required this.createdAt,
  });

  /// Create a copy with updated fields
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? scheduledTime,
    bool? isScheduled,
    bool? isDelivered,
    DateTime? deliveredAt,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isScheduled: isScheduled ?? this.isScheduled,
      isDelivered: isDelivered ?? this.isDelivered,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        scheduledTime,
        isScheduled,
        isDelivered,
        deliveredAt,
        payload,
        createdAt,
      ];
}

/// Notification Type
enum NotificationType {
  dailyQuestReminder, // Reminder to complete daily quests
  questCompletion, // Quest completed notification
  levelUp, // Level up notification
  achievementUnlock, // Achievement unlocked
  streakReminder, // Streak reminder
  weeklyChallenge, // Weekly challenge updates
}

/// Notification Preferences
class NotificationPreferences extends Equatable {
  final bool dailyQuestReminders;
  final bool questCompletionNotifications;
  final bool levelUpNotifications;
  final bool achievementNotifications;
  final bool streakReminders;
  final bool weeklyChallengeNotifications;
  final CustomTimeOfDay? dailyQuestReminderTime; // Time for daily quest reminder

  const NotificationPreferences({
    this.dailyQuestReminders = true,
    this.questCompletionNotifications = true,
    this.levelUpNotifications = true,
    this.achievementNotifications = true,
    this.streakReminders = true,
    this.weeklyChallengeNotifications = true,
    this.dailyQuestReminderTime,
  });

  /// Create a copy with updated fields
  NotificationPreferences copyWith({
    bool? dailyQuestReminders,
    bool? questCompletionNotifications,
    bool? levelUpNotifications,
    bool? achievementNotifications,
    bool? streakReminders,
    bool? weeklyChallengeNotifications,
    CustomTimeOfDay? dailyQuestReminderTime,
  }) {
    return NotificationPreferences(
      dailyQuestReminders: dailyQuestReminders ?? this.dailyQuestReminders,
      questCompletionNotifications:
          questCompletionNotifications ?? this.questCompletionNotifications,
      levelUpNotifications: levelUpNotifications ?? this.levelUpNotifications,
      achievementNotifications:
          achievementNotifications ?? this.achievementNotifications,
      streakReminders: streakReminders ?? this.streakReminders,
      weeklyChallengeNotifications:
          weeklyChallengeNotifications ?? this.weeklyChallengeNotifications,
      dailyQuestReminderTime:
          dailyQuestReminderTime ?? this.dailyQuestReminderTime,
    );
  }

  /// Check if a notification type is enabled
  bool isEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.dailyQuestReminder:
        return dailyQuestReminders;
      case NotificationType.questCompletion:
        return questCompletionNotifications;
      case NotificationType.levelUp:
        return levelUpNotifications;
      case NotificationType.achievementUnlock:
        return achievementNotifications;
      case NotificationType.streakReminder:
        return streakReminders;
      case NotificationType.weeklyChallenge:
        return weeklyChallengeNotifications;
    }
  }

  @override
  List<Object?> get props => [
        dailyQuestReminders,
        questCompletionNotifications,
        levelUpNotifications,
        achievementNotifications,
        streakReminders,
        weeklyChallengeNotifications,
        dailyQuestReminderTime,
      ];
}

/// CustomTimeOfDay helper (to avoid conflict with Flutter's TimeOfDay)
class CustomTimeOfDay extends Equatable {
  final int hour;
  final int minute;

  const CustomTimeOfDay({required this.hour, required this.minute});

  @override
  List<Object?> get props => [hour, minute];

  /// Convert to DateTime for today
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
  
  /// Convert from Flutter's TimeOfDay
  factory CustomTimeOfDay.fromFlutterTimeOfDay(
    material.TimeOfDay timeOfDay,
  ) {
    return CustomTimeOfDay(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }
  
  /// Convert to Flutter's TimeOfDay
  material.TimeOfDay toFlutterTimeOfDay() {
    return material.TimeOfDay(hour: hour, minute: minute);
  }
}

