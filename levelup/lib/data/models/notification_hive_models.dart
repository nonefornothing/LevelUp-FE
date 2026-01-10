import 'package:hive/hive.dart';

import '../../domain/entities/notification.dart';

/// Hive model for storing AppNotification locally
class NotificationHiveModel {
  final String id;
  final String title;
  final String body;
  final int typeIndex;
  final int scheduledTimeMs;
  final bool isScheduled;
  final bool isDelivered;
  final int? deliveredAtMs;
  final Map<String, dynamic>? payload;
  final int createdAtMs;

  NotificationHiveModel({
    required this.id,
    required this.title,
    required this.body,
    required this.typeIndex,
    required this.scheduledTimeMs,
    required this.isScheduled,
    required this.isDelivered,
    this.deliveredAtMs,
    this.payload,
    required this.createdAtMs,
  });

  AppNotification toDomain() {
    final type = NotificationType.values[typeIndex.clamp(0, NotificationType.values.length - 1)];

    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(scheduledTimeMs),
      isScheduled: isScheduled,
      isDelivered: isDelivered,
      deliveredAt: deliveredAtMs != null ? DateTime.fromMillisecondsSinceEpoch(deliveredAtMs!) : null,
      payload: payload,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
  }

  static NotificationHiveModel fromDomain(AppNotification notification) {
    return NotificationHiveModel(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      typeIndex: notification.type.index,
      scheduledTimeMs: notification.scheduledTime.millisecondsSinceEpoch,
      isScheduled: notification.isScheduled,
      isDelivered: notification.isDelivered,
      deliveredAtMs: notification.deliveredAt?.millisecondsSinceEpoch,
      payload: notification.payload,
      createdAtMs: notification.createdAt.millisecondsSinceEpoch,
    );
  }
}

/// Hive model for storing NotificationPreferences
class NotificationPreferencesHiveModel {
  final bool dailyQuestReminders;
  final bool questCompletionNotifications;
  final bool levelUpNotifications;
  final bool achievementNotifications;
  final bool streakReminders;
  final bool weeklyChallengeNotifications;
  final int? reminderHour;
  final int? reminderMinute;

  NotificationPreferencesHiveModel({
    this.dailyQuestReminders = true,
    this.questCompletionNotifications = true,
    this.levelUpNotifications = true,
    this.achievementNotifications = true,
    this.streakReminders = true,
    this.weeklyChallengeNotifications = true,
    this.reminderHour,
    this.reminderMinute,
  });

  NotificationPreferences toDomain() {
    return NotificationPreferences(
      dailyQuestReminders: dailyQuestReminders,
      questCompletionNotifications: questCompletionNotifications,
      levelUpNotifications: levelUpNotifications,
      achievementNotifications: achievementNotifications,
      streakReminders: streakReminders,
      weeklyChallengeNotifications: weeklyChallengeNotifications,
      dailyQuestReminderTime: reminderHour != null && reminderMinute != null
          ? CustomTimeOfDay(hour: reminderHour!, minute: reminderMinute!)
          : null,
    );
  }

  static NotificationPreferencesHiveModel fromDomain(NotificationPreferences preferences) {
    return NotificationPreferencesHiveModel(
      dailyQuestReminders: preferences.dailyQuestReminders,
      questCompletionNotifications: preferences.questCompletionNotifications,
      levelUpNotifications: preferences.levelUpNotifications,
      achievementNotifications: preferences.achievementNotifications,
      streakReminders: preferences.streakReminders,
      weeklyChallengeNotifications: preferences.weeklyChallengeNotifications,
      reminderHour: preferences.dailyQuestReminderTime?.hour,
      reminderMinute: preferences.dailyQuestReminderTime?.minute,
    );
  }
}

/// Adapter type IDs must be unique across the app
const int _notificationTypeId = 8;
const int _notificationPreferencesTypeId = 9;

class NotificationHiveModelAdapter extends TypeAdapter<NotificationHiveModel> {
  @override
  final int typeId = _notificationTypeId;

  @override
  NotificationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return NotificationHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      typeIndex: fields[3] as int,
      scheduledTimeMs: fields[4] as int,
      isScheduled: fields[5] as bool,
      isDelivered: fields[6] as bool,
      deliveredAtMs: fields[7] as int?,
      payload: fields[8] as Map<String, dynamic>?,
      createdAtMs: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.typeIndex)
      ..writeByte(4)
      ..write(obj.scheduledTimeMs)
      ..writeByte(5)
      ..write(obj.isScheduled)
      ..writeByte(6)
      ..write(obj.isDelivered)
      ..writeByte(7)
      ..write(obj.deliveredAtMs)
      ..writeByte(8)
      ..write(obj.payload)
      ..writeByte(9)
      ..write(obj.createdAtMs);
  }
}

class NotificationPreferencesHiveModelAdapter extends TypeAdapter<NotificationPreferencesHiveModel> {
  @override
  final int typeId = _notificationPreferencesTypeId;

  @override
  NotificationPreferencesHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return NotificationPreferencesHiveModel(
      dailyQuestReminders: fields[0] as bool? ?? true,
      questCompletionNotifications: fields[1] as bool? ?? true,
      levelUpNotifications: fields[2] as bool? ?? true,
      achievementNotifications: fields[3] as bool? ?? true,
      streakReminders: fields[4] as bool? ?? true,
      weeklyChallengeNotifications: fields[5] as bool? ?? true,
      reminderHour: fields[6] as int?,
      reminderMinute: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationPreferencesHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.dailyQuestReminders)
      ..writeByte(1)
      ..write(obj.questCompletionNotifications)
      ..writeByte(2)
      ..write(obj.levelUpNotifications)
      ..writeByte(3)
      ..write(obj.achievementNotifications)
      ..writeByte(4)
      ..write(obj.streakReminders)
      ..writeByte(5)
      ..write(obj.weeklyChallengeNotifications)
      ..writeByte(6)
      ..write(obj.reminderHour)
      ..writeByte(7)
      ..write(obj.reminderMinute);
  }
}

