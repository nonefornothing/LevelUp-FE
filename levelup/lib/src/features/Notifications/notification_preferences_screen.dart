import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/notification.dart' show CustomTimeOfDay;
import 'bloc/notification_bloc.dart';
import 'bloc/notification_event.dart';
import 'bloc/notification_state.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc()
        ..add(const NotificationPreferencesLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Notification Preferences',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoaded && state.preferences != null) {
              final preferences = state.preferences!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Quest Reminders
                    _PreferenceSwitch(
                      title: 'Daily Quest Reminders',
                      subtitle: 'Get reminded to complete your daily quests',
                      value: preferences.dailyQuestReminders,
                      onChanged: (value) {
                        context.read<NotificationBloc>().add(
                              NotificationPreferencesUpdateRequested(
                                preferences.copyWith(dailyQuestReminders: value),
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Quest Completion Notifications
                    _PreferenceSwitch(
                      title: 'Quest Completion',
                      subtitle: 'Get notified when you complete a quest',
                      value: preferences.questCompletionNotifications,
                      onChanged: (value) {
                        context.read<NotificationBloc>().add(
                              NotificationPreferencesUpdateRequested(
                                preferences.copyWith(questCompletionNotifications: value),
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Level Up Notifications
                    _PreferenceSwitch(
                      title: 'Level Up',
                      subtitle: 'Get notified when you level up',
                      value: preferences.levelUpNotifications,
                      onChanged: (value) {
                        context.read<NotificationBloc>().add(
                              NotificationPreferencesUpdateRequested(
                                preferences.copyWith(levelUpNotifications: value),
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Achievement Notifications
                    _PreferenceSwitch(
                      title: 'Achievement Unlocks',
                      subtitle: 'Get notified when you unlock achievements',
                      value: preferences.achievementNotifications,
                      onChanged: (value) {
                        context.read<NotificationBloc>().add(
                              NotificationPreferencesUpdateRequested(
                                preferences.copyWith(achievementNotifications: value),
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Streak Reminders
                    _PreferenceSwitch(
                      title: 'Streak Reminders',
                      subtitle: 'Get reminded to maintain your streak',
                      value: preferences.streakReminders,
                      onChanged: (value) {
                        context.read<NotificationBloc>().add(
                              NotificationPreferencesUpdateRequested(
                                preferences.copyWith(streakReminders: value),
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Weekly Challenge Notifications
                    _PreferenceSwitch(
                      title: 'Weekly Challenges',
                      subtitle: 'Get notified about weekly challenge updates',
                      value: preferences.weeklyChallengeNotifications,
                      onChanged: (value) {
                        context.read<NotificationBloc>().add(
                              NotificationPreferencesUpdateRequested(
                                preferences.copyWith(weeklyChallengeNotifications: value),
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Daily Quest Reminder Time
                    if (preferences.dailyQuestReminders) ...[
                      const Text(
                        'Daily Quest Reminder Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: const Icon(
                            Icons.access_time,
                            color: Colors.lightBlueAccent,
                          ),
                          title: const Text(
                            'Reminder Time',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            preferences.dailyQuestReminderTime != null
                                ? '${preferences.dailyQuestReminderTime!.hour.toString().padLeft(2, '0')}:${preferences.dailyQuestReminderTime!.minute.toString().padLeft(2, '0')}'
                                : 'Not set',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: preferences.dailyQuestReminderTime != null
                                  ? TimeOfDay(
                                      hour: preferences.dailyQuestReminderTime!.hour,
                                      minute: preferences.dailyQuestReminderTime!.minute,
                                    )
                                  : const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (time != null) {
                              final customTimeOfDay = CustomTimeOfDay(
                                hour: time.hour,
                                minute: time.minute,
                              );
                              // Use context directly - this is safe in a callback
                              context.read<NotificationBloc>().add(
                                    NotificationPreferencesUpdateRequested(
                                      preferences.copyWith(
                                        dailyQuestReminderTime: customTimeOfDay,
                                      ),
                                    ),
                                  );
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(
                color: Colors.lightBlueAccent,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.lightBlueAccent,
      ),
    );
  }
}

