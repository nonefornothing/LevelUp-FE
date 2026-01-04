import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/result.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/datasources/quest_local_datasource.dart';
import '../../data/datasources/player_local_datasource.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../domain/repositories/player_repository.dart';
import 'daily_quest_generator.dart';

/// Service for managing daily quests
class DailyQuestService {
  final QuestRepository _questRepository;
  final PlayerRepository _playerRepository;

  DailyQuestService({
    required QuestRepository questRepository,
    required PlayerRepository playerRepository,
    QuestLocalDataSource? questDataSource,
    PlayerLocalDataSource? playerDataSource,
  })  : _questRepository = questRepository,
        _playerRepository = playerRepository;

  /// Get daily quests, generating new ones if needed
  Future<List<Quest>> getDailyQuests() async {
    final today = DateTime.now();
    final lastGeneration = _getLastGenerationDate();
    
    // Check if we need to regenerate
    if (DailyQuestGenerator.needsRegeneration(lastGeneration, today)) {
      await _regenerateDailyQuests(today);
    }
    
    // Get all daily quests
    final result = await _questRepository.getQuests(type: QuestType.daily);
    if (result is Success<List<Quest>>) {
      return result.data;
    }
    
    return [];
  }

  /// Regenerate daily quests for today
  Future<void> _regenerateDailyQuests(DateTime today) async {
    // Delete old daily quests (completed ones are kept for history)
    final existingResult = await _questRepository.getQuests(type: QuestType.daily);
    if (existingResult is Success<List<Quest>>) {
      final existingQuests = existingResult.data;
      // Delete incomplete daily quests from previous days
      for (final quest in existingQuests) {
        final questDate = DateTime(
          quest.createdAt.year,
          quest.createdAt.month,
          quest.createdAt.day,
        );
        final todayDate = DateTime(today.year, today.month, today.day);
        
        if (questDate.isBefore(todayDate) && quest.status != QuestStatus.completed) {
          await _questRepository.deleteQuest(quest.id);
        }
      }
    }
    
    // Get player for level-based rewards
    final playerResult = await _playerRepository.getPlayer();
    final player = playerResult is Success<Player> ? playerResult.data : null;
    
    // Generate new daily quests
    final newQuests = DailyQuestGenerator.generateDailyQuests(
      today: today,
      player: player,
    );
    
    // Create quests (tasks already have correct quest IDs from generator)
    for (final quest in newQuests) {
      await _questRepository.createQuest(quest);
    }
    
    // Save generation date
    _setLastGenerationDate(today);
  }

  DateTime _getLastGenerationDate() {
    try {
      final prefsBox = Hive.box(HiveLocalStorage.prefsBoxName);
      final timestamp = prefsBox.get(AppConstants.storageKeyLastDailyQuestGeneration);
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      // Ignore
    }
    // Return a date far in the past to force regeneration
    return DateTime(2000, 1, 1);
  }

  void _setLastGenerationDate(DateTime date) {
    try {
      final prefsBox = Hive.box(HiveLocalStorage.prefsBoxName);
      prefsBox.put(
        AppConstants.storageKeyLastDailyQuestGeneration,
        date.millisecondsSinceEpoch,
      );
    } catch (e) {
      // Ignore
    }
  }
}

