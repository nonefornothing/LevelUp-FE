import '../entities/quest.dart';
import '../../core/utils/result.dart';

/// Quest Repository Interface (Domain layer)
abstract class QuestRepository {
  /// Get all quests
  Future<Result<List<Quest>>> getQuests({
    QuestType? type,
    QuestStatus? status,
  });

  /// Get quest by ID
  Future<Result<Quest>> getQuestById(String id);

  /// Create new quest
  Future<Result<Quest>> createQuest(Quest quest);

  /// Update quest
  Future<Result<Quest>> updateQuest(Quest quest);

  /// Delete quest
  Future<Result<void>> deleteQuest(String id);

  /// Complete quest
  Future<Result<Quest>> completeQuest(String id);

  /// Calculate quest progress
  Future<Result<double>> calculateQuestProgress(String questId);
}

