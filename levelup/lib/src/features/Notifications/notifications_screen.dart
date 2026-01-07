import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/notification.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import 'bloc/notification_bloc.dart';
import 'bloc/notification_event.dart';
import 'bloc/notification_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc()
        ..add(const NotificationLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.notifications.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.white70),
                    tooltip: 'Clear All',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: Colors.grey[800],
                          title: const Text(
                            'Clear All Notifications',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to clear all notifications?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.lightBlueAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                context.read<NotificationBloc>().add(
                                      const NotificationClearAllRequested(),
                                    );
                              },
                              child: const Text(
                                'Clear All',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const LoadingWidget(message: 'Loading notifications...');
            }

            if (state is NotificationError) {
              return ErrorStateWidget(
                message: 'Failed to load notifications',
                details: state.message,
                onRetry: () => context.read<NotificationBloc>().add(
                      const NotificationLoadRequested(),
                    ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.notifications_none,
                  title: 'No notifications',
                  message: 'You\'re all caught up! New notifications will appear here.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationBloc>().add(
                        const NotificationRefreshRequested(),
                      );
                },
                color: Colors.lightBlueAccent,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return _NotificationCard(
                      notification: notification,
                      isUnread: !notification.isDelivered,
                      onTap: () {
                        if (!notification.isDelivered) {
                          context.read<NotificationBloc>().add(
                                NotificationMarkAsReadRequested(notification.id),
                              );
                        }
                      },
                      onDelete: () {
                        context.read<NotificationBloc>().add(
                              NotificationDeleteRequested(notification.id),
                            );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final bool isUnread;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.isUnread,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUnread ? Colors.grey[850] : Colors.grey[900],
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.lightBlueAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.scheduledTime),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.white54),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.dailyQuestReminder:
        return Colors.blue;
      case NotificationType.questCompletion:
        return Colors.green;
      case NotificationType.levelUp:
        return Colors.purple;
      case NotificationType.achievementUnlock:
        return Colors.amber;
      case NotificationType.streakReminder:
        return Colors.orange;
      case NotificationType.weeklyChallenge:
        return Colors.cyan;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.dailyQuestReminder:
        return Icons.today;
      case NotificationType.questCompletion:
        return Icons.check_circle;
      case NotificationType.levelUp:
        return Icons.trending_up;
      case NotificationType.achievementUnlock:
        return Icons.emoji_events;
      case NotificationType.streakReminder:
        return Icons.local_fire_department;
      case NotificationType.weeklyChallenge:
        return Icons.calendar_today;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

