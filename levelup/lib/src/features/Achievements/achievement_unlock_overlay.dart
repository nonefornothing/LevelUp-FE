import 'package:flutter/material.dart';

import '../../../domain/entities/achievement.dart';

/// Achievement Unlock Overlay Widget
class AchievementUnlockOverlay extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockOverlay({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  /// Show achievement unlock overlay
  static void show({
    required BuildContext context,
    required Achievement achievement,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => AchievementUnlockOverlay(
        achievement: achievement,
        onDismiss: onDismiss ?? () {},
      ),
    );
  }

  /// Show multiple achievements unlocked
  static void showMultiple({
    required BuildContext context,
    required List<Achievement> achievements,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => _MultipleAchievementsOverlay(
        achievements: achievements,
        onDismiss: onDismiss ?? () {},
      ),
    );
  }

  @override
  State<AchievementUnlockOverlay> createState() => _AchievementUnlockOverlayState();
}

class _AchievementUnlockOverlayState extends State<AchievementUnlockOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstQuest:
        return Icons.flag;
      case AchievementType.questMilestone:
        return Icons.emoji_events;
      case AchievementType.levelMilestone:
        return Icons.trending_up;
      case AchievementType.dailyStreak:
        return Icons.local_fire_department;
      case AchievementType.perfectWeek:
        return Icons.calendar_today;
      case AchievementType.totalXP:
        return Icons.stars;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(widget.achievement.tier);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tierColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: tierColor.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Achievement Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: tierColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: tierColor, width: 3),
                      ),
                      child: Icon(
                        _getAchievementIcon(widget.achievement.type),
                        color: tierColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Achievement Unlocked!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Achievement Name
                    Text(
                      widget.achievement.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: tierColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      widget.achievement.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Close button
                    TextButton(
                      onPressed: () {
                        _controller.reverse().then((_) {
                          widget.onDismiss();
                          if (mounted) Navigator.of(context).pop();
                        });
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MultipleAchievementsOverlay extends StatefulWidget {
  final List<Achievement> achievements;
  final VoidCallback onDismiss;

  const _MultipleAchievementsOverlay({
    required this.achievements,
    required this.onDismiss,
  });

  @override
  State<_MultipleAchievementsOverlay> createState() => _MultipleAchievementsOverlayState();
}

class _MultipleAchievementsOverlayState extends State<_MultipleAchievementsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto-dismiss after 4 seconds for multiple achievements
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstQuest:
        return Icons.flag;
      case AchievementType.questMilestone:
        return Icons.emoji_events;
      case AchievementType.levelMilestone:
        return Icons.trending_up;
      case AchievementType.dailyStreak:
        return Icons.local_fire_department;
      case AchievementType.perfectWeek:
        return Icons.calendar_today;
      case AchievementType.totalXP:
        return Icons.stars;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.lightBlueAccent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlueAccent.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Achievements Unlocked!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.achievements.length} achievement${widget.achievements.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.achievements.map((achievement) {
                            final tierColor = _getTierColor(achievement.tier);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: tierColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: tierColor, width: 2),
                                    ),
                                    child: Icon(
                                      _getAchievementIcon(achievement.type),
                                      color: tierColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          achievement.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: tierColor,
                                          ),
                                        ),
                                        Text(
                                          achievement.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _controller.reverse().then((_) {
                          widget.onDismiss();
                          if (mounted) Navigator.of(context).pop();
                        });
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}





