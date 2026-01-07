import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/achievement_service.dart';
import '../../../core/services/weekly_challenge_service.dart';
import '../../../core/services/inventory_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/streak_service.dart';
import '../../../core/services/skill_service.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/achievement.dart';
import '../../../domain/entities/player.dart';
import '../../../domain/entities/quest.dart';
import '../../../domain/repositories/player_repository.dart';
import '../../../domain/repositories/quest_repository.dart';
import '../../routing/app_routes.dart';
import '../Achievements/achievement_unlock_overlay.dart';
import '../Player/level_up_overlay.dart';

class RewardArgs {
  final String questId;
  final String questTitle;
  final int experience;
  final int currency;

  const RewardArgs({
    required this.questId,
    required this.questTitle,
    required this.experience,
    required this.currency,
  });
}

class RewardClaimScreen extends StatefulWidget {
  final RewardArgs args;

  const RewardClaimScreen({super.key, required this.args});

  @override
  State<RewardClaimScreen> createState() => _RewardClaimScreenState();
}

class _RewardClaimScreenState extends State<RewardClaimScreen> {
  bool _applied = false;
  bool _levelUp = false;
  Player? _player;
  String? _error;
  List<Achievement> _newlyUnlockedAchievements = [];

  @override
  void initState() {
    super.initState();
    _applyRewards();
  }

  Future<void> _applyRewards() async {
    if (_applied) return;
    _applied = true;

    final repo = sl<PlayerRepository>();

    final xpRes = await repo.addExperience(widget.args.experience);
    if (xpRes is ResultError<Player>) {
      setState(() => _error = xpRes.message);
      return;
    }

    final goldRes = await repo.addCurrency(widget.args.currency);
    if (goldRes is ResultError<Player>) {
      setState(() => _error = goldRes.message);
      return;
    }

    final lvlRes = await repo.checkLevelUp();
    final levelUp = lvlRes is Success<bool> && lvlRes.data;

    final playerRes = await repo.getPlayer();
    Player? p;
    if (playerRes is Success<Player>) p = playerRes.data;

    setState(() {
      _levelUp = levelUp;
      _player = p;
    });

    // Check and unlock achievements
    if (p != null) {
      await _checkAchievements(p, levelUp);
    }

    // Update weekly challenge progress
    await _updateWeeklyChallenges(levelUp);

    // Award items based on quest completion (random chance for collectibles)
    await _awardItems(levelUp);

    // Update streaks
    await _updateStreaks();

    // Award skill experience
    await _awardSkillExperience();

    // Create notifications
    await _createNotifications(p, levelUp);

    // Show achievement unlock overlay first, then level up
    if (mounted && _newlyUnlockedAchievements.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentPlayer = p;
        if (_newlyUnlockedAchievements.length == 1) {
          AchievementUnlockOverlay.show(
            context: context,
            achievement: _newlyUnlockedAchievements.first,
            onDismiss: () {
              // After achievement overlay, show level up if needed
              if (levelUp && currentPlayer != null && mounted) {
                LevelUpOverlay.show(
                  context: context,
                  newLevel: currentPlayer.level,
                  onDismiss: () {},
                );
              }
            },
          );
        } else {
          AchievementUnlockOverlay.showMultiple(
            context: context,
            achievements: _newlyUnlockedAchievements,
            onDismiss: () {
              // After achievement overlay, show level up if needed
              if (levelUp && currentPlayer != null && mounted) {
                LevelUpOverlay.show(
                  context: context,
                  newLevel: currentPlayer.level,
                  onDismiss: () {},
                );
              }
            },
          );
        }
      });
    } else if (levelUp && p != null && mounted) {
      // Show level up overlay if no achievements unlocked
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LevelUpOverlay.show(
          context: context,
          newLevel: p!.level,
          onDismiss: () {},
        );
      });
    }
  }

  Future<void> _checkAchievements(Player player, bool levelUp) async {
    try {
      final achievementService = sl<AchievementService>();
      final questRepository = sl<QuestRepository>();
      
      // Get completed quests count
      final questsResult = await questRepository.getQuests(status: QuestStatus.completed);
      final completedQuestsCount = questsResult is Success<List<Quest>>
          ? questsResult.data.length
          : player.stats.totalQuestsCompleted;
      
      // Check and unlock achievements
      final result = await achievementService.checkAndUnlockAchievements(
        questsCompleted: completedQuestsCount,
        level: player.level,
        currentStreak: player.stats.currentStreak,
        totalXP: player.experience,
      );
      
      // Store newly unlocked achievements
      if (result is Success<List<Achievement>>) {
        setState(() {
          _newlyUnlockedAchievements = result.data;
        });
        
        // Create notifications for unlocked achievements
        final notificationService = sl<NotificationService>();
        for (final achievement in result.data) {
          await notificationService.notifyAchievementUnlock(achievement.title);
        }
      }
    } catch (e) {
      // Fail silently - achievement checking is not critical
      Logger.warning('Failed to check achievements: $e');
    }
  }

  Future<void> _updateWeeklyChallenges(bool levelUp) async {
    try {
      final weeklyChallengeService = sl<WeeklyChallengeService>();
      final questRepository = sl<QuestRepository>();
      
      // Get the completed quest
      final questResult = await questRepository.getQuestById(widget.args.questId);
      if (questResult is Success<Quest>) {
        final quest = questResult.data;
        // Update challenge progress for quest completion
        await weeklyChallengeService.onQuestCompleted(quest);
      }
      
      // Update challenge progress for XP earned
      await weeklyChallengeService.onXPEarned(widget.args.experience);
      
      // Update challenge progress for level up
      if (levelUp) {
        await weeklyChallengeService.onLevelUp();
      }
    } catch (e) {
      // Fail silently - weekly challenge tracking is not critical
      Logger.warning('Failed to update weekly challenges: $e');
    }
  }

  Future<void> _awardItems(bool levelUp) async {
    try {
      final inventoryService = sl<InventoryService>();
      
      // Award collectible items based on milestones
      final playerResult = await sl<PlayerRepository>().getPlayer();
      if (playerResult is Success<Player>) {
        final player = playerResult.data;
        
        // Award first quest badge if this is the first quest
        if (player.stats.totalQuestsCompleted == 1) {
          await inventoryService.addItemById('item_badge_first_quest');
        }
        
        // Award trophies based on quest count
        if (player.stats.totalQuestsCompleted == 10) {
          await inventoryService.addItemById('item_trophy_bronze');
        } else if (player.stats.totalQuestsCompleted == 50) {
          await inventoryService.addItemById('item_trophy_silver');
        } else if (player.stats.totalQuestsCompleted == 100) {
          await inventoryService.addItemById('item_trophy_gold');
        }
        
        // Award level badges
        if (player.level == 10) {
          await inventoryService.addItemById('item_badge_level_10');
        }
        
        // Random chance for consumable items (10% chance)
        final random = DateTime.now().millisecondsSinceEpoch % 100;
        if (random < 10) {
          // Award a small XP boost
          await inventoryService.addItemById('item_xp_boost_small');
        }
      }
    } catch (e) {
      // Fail silently - item rewards are bonus
      Logger.warning('Failed to award items: $e');
    }
  }

  Future<void> _updateStreaks() async {
    try {
      final streakService = sl<StreakService>();
      final questRepository = sl<QuestRepository>();
      
      // Get the completed quest to determine its type
      final questResult = await questRepository.getQuestById(widget.args.questId);
      if (questResult is Success<Quest>) {
        final quest = questResult.data;
        final completionDate = quest.completedAt ?? DateTime.now();
        
        // Update streaks based on quest completion
        final streakResult = await streakService.updateStreakOnQuestCompletion(
          questType: quest.type,
          completionDate: completionDate,
        );
        
        if (streakResult is Success<StreakUpdateResult>) {
          final updateResult = streakResult.data;
          // Optionally show streak notification if new record
          if (updateResult.newRecord && updateResult.streaks.isNotEmpty) {
            final longestStreak = updateResult.streaks
                .map((s) => s.currentStreak)
                .reduce((a, b) => a > b ? a : b);
            // Could show a snackbar or notification here
            Logger.info('New streak record: $longestStreak days!');
          }
        }
      }
    } catch (e) {
      // Fail silently - streak tracking is not critical
      Logger.warning('Failed to update streaks: $e');
    }
  }

  Future<void> _awardSkillExperience() async {
    try {
      final skillService = sl<SkillService>();
      final questRepository = sl<QuestRepository>();
      
      // Get the completed quest
      final questResult = await questRepository.getQuestById(widget.args.questId);
      if (questResult is Success<Quest>) {
        final quest = questResult.data;
        
        // Award skill experience based on quest category
        await skillService.awardSkillExperienceFromQuest(quest);
      }
    } catch (e) {
      // Fail silently - skill progression is not critical
      Logger.warning('Failed to award skill experience: $e');
    }
  }

  Future<void> _createNotifications(Player? player, bool levelUp) async {
    try {
      final notificationService = sl<NotificationService>();
      
      // Create notification for quest completion
      await notificationService.notifyQuestCompletion(
        widget.args.questTitle,
        widget.args.experience,
        widget.args.currency,
      );
      
      // Create notification for level up if applicable
      if (levelUp && player != null) {
        await notificationService.notifyLevelUp(player.level);
      }
    } catch (e) {
      // Fail silently - notifications are not critical
      Logger.warning('Failed to create notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Rewards',
          style: TextStyle(color: Colors.lightBlueAccent),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Quest Completed!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                args.questTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              _RewardCard(
                title: '+${args.experience} XP',
                subtitle: 'Experience gained',
              ),
              const SizedBox(height: 12),
              _RewardCard(
                title: '+${args.currency} Gold',
                subtitle: 'Currency gained',
              ),
              const SizedBox(height: 16),
              if (_levelUp)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (_player != null)
                Text(
                  'Player: ${_player!.username} • Level ${_player!.level} • XP ${_player!.experience} • Gold ${_player!.currency}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go(AppRoutes.quests),
                child: const Text(
                  'Back to quests',
                  style: TextStyle(color: Colors.lightBlueAccent),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RewardCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}


