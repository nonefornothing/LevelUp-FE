import '../../core/utils/id_generator.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../core/utils/result.dart';

/// Service for managing notifications
class NotificationService {
  final NotificationRepository _notificationRepository;

  NotificationService({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  /// Create a notification for quest completion
  Future<void> notifyQuestCompletion(String questTitle, int xpGained, int currencyGained) async {
    final preferencesResult = await _notificationRepository.getPreferences();
    if (preferencesResult is ResultError) return;

    final preferences = (preferencesResult as Success<NotificationPreferences>).data;
    if (!preferences.questCompletionNotifications) return;

    final notification = AppNotification(
      id: IdGenerator.newId(),
      title: 'Quest Completed! 🎉',
      body: 'You completed "$questTitle" and earned $xpGained XP and $currencyGained coins!',
      type: NotificationType.questCompletion,
      scheduledTime: DateTime.now(),
      isScheduled: false,
      isDelivered: false,
      payload: {'type': 'quest_completion'},
      createdAt: DateTime.now(),
    );

    await _notificationRepository.createNotification(notification);
  }

  /// Create a notification for level up
  Future<void> notifyLevelUp(int newLevel) async {
    final preferencesResult = await _notificationRepository.getPreferences();
    if (preferencesResult is ResultError) return;

    final preferences = (preferencesResult as Success<NotificationPreferences>).data;
    if (!preferences.levelUpNotifications) return;

    final notification = AppNotification(
      id: IdGenerator.newId(),
      title: 'Level Up! ⬆️',
      body: 'Congratulations! You reached level $newLevel!',
      type: NotificationType.levelUp,
      scheduledTime: DateTime.now(),
      isScheduled: false,
      isDelivered: false,
      payload: {'type': 'level_up', 'level': newLevel},
      createdAt: DateTime.now(),
    );

    await _notificationRepository.createNotification(notification);
  }

  /// Create a notification for achievement unlock
  Future<void> notifyAchievementUnlock(String achievementTitle) async {
    final preferencesResult = await _notificationRepository.getPreferences();
    if (preferencesResult is ResultError) return;

    final preferences = (preferencesResult as Success<NotificationPreferences>).data;
    if (!preferences.achievementNotifications) return;

    final notification = AppNotification(
      id: IdGenerator.newId(),
      title: 'Achievement Unlocked! 🏆',
      body: 'You unlocked "$achievementTitle"!',
      type: NotificationType.achievementUnlock,
      scheduledTime: DateTime.now(),
      isScheduled: false,
      isDelivered: false,
      payload: {'type': 'achievement_unlock'},
      createdAt: DateTime.now(),
    );

    await _notificationRepository.createNotification(notification);
  }

  /// Schedule daily quest reminder
  Future<void> scheduleDailyQuestReminder() async {
    final preferencesResult = await _notificationRepository.getPreferences();
    if (preferencesResult is ResultError) return;

    final preferences = (preferencesResult as Success<NotificationPreferences>).data;
    if (!preferences.dailyQuestReminders) return;

    // Default reminder time: 9:00 AM
    final reminderTime = preferences.dailyQuestReminderTime ?? const CustomTimeOfDay(hour: 9, minute: 0);
    final scheduledTime = reminderTime.toDateTime();

    // If the time has passed today, schedule for tomorrow
    final now = DateTime.now();
    final todayScheduled = DateTime(now.year, now.month, now.day, scheduledTime.hour, scheduledTime.minute);
    final finalScheduledTime = todayScheduled.isBefore(now)
        ? todayScheduled.add(const Duration(days: 1))
        : todayScheduled;

    final notification = AppNotification(
      id: IdGenerator.newId(),
      title: 'Daily Quests Available! 📋',
      body: 'New daily quests are waiting for you. Complete them to earn rewards!',
      type: NotificationType.dailyQuestReminder,
      scheduledTime: finalScheduledTime,
      isScheduled: true,
      isDelivered: false,
      payload: {'type': 'daily_quest_reminder'},
      createdAt: DateTime.now(),
    );

    await _notificationRepository.createNotification(notification);
  }

  /// Create a notification for streak reminder
  Future<void> notifyStreakReminder(int currentStreak) async {
    final preferencesResult = await _notificationRepository.getPreferences();
    if (preferencesResult is ResultError) return;

    final preferences = (preferencesResult as Success<NotificationPreferences>).data;
    if (!preferences.streakReminders) return;

    final notification = AppNotification(
      id: IdGenerator.newId(),
      title: 'Keep Your Streak Going! 🔥',
      body: 'You have a $currentStreak day streak! Complete a quest today to keep it going.',
      type: NotificationType.streakReminder,
      scheduledTime: DateTime.now(),
      isScheduled: false,
      isDelivered: false,
      payload: {'type': 'streak_reminder', 'streak': currentStreak},
      createdAt: DateTime.now(),
    );

    await _notificationRepository.createNotification(notification);
  }

  /// Create a notification for weekly challenge
  Future<void> notifyWeeklyChallenge(String challengeTitle, int progress, int target) async {
    final preferencesResult = await _notificationRepository.getPreferences();
    if (preferencesResult is ResultError) return;

    final preferences = (preferencesResult as Success<NotificationPreferences>).data;
    if (!preferences.weeklyChallengeNotifications) return;

    final notification = AppNotification(
      id: IdGenerator.newId(),
      title: 'Weekly Challenge Update 📅',
      body: '$challengeTitle: $progress/$target completed. Keep going!',
      type: NotificationType.weeklyChallenge,
      scheduledTime: DateTime.now(),
      isScheduled: false,
      isDelivered: false,
      payload: {'type': 'weekly_challenge'},
      createdAt: DateTime.now(),
    );

    await _notificationRepository.createNotification(notification);
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    final result = await _notificationRepository.getUnreadNotifications();
    if (result is Success<List<AppNotification>>) {
      return result.data.length;
    }
    return 0;
  }
}

