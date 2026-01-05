import '../../domain/entities/quest.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../domain/repositories/player_repository.dart';
import '../../core/utils/result.dart';

/// Model for a recommended quest with explanation
class RecommendedQuest {
  final Quest quest;
  final double score;
  final String explanation;

  const RecommendedQuest({
    required this.quest,
    required this.score,
    required this.explanation,
  });
}

/// Service for recommending quests to players
class QuestRecommendationService {
  final QuestRepository _questRepository;
  final PlayerRepository _playerRepository;

  QuestRecommendationService({
    required QuestRepository questRepository,
    required PlayerRepository playerRepository,
  })  : _questRepository = questRepository,
        _playerRepository = playerRepository;

  /// Get recommended quests for the current player
  Future<List<RecommendedQuest>> getRecommendedQuests({
    int limit = 5,
  }) async {
    // Get player
    final playerResult = await _playerRepository.getPlayer();
    if (playerResult is ResultError) {
      return [];
    }
    final player = (playerResult as Success<Player>).data;

    // Get all active quests (not completed)
    final questsResult = await _questRepository.getQuests(
      status: QuestStatus.notStarted,
    );
    if (questsResult is ResultError) {
      return [];
    }
    final availableQuests = (questsResult as Success<List<Quest>>).data;

    if (availableQuests.isEmpty) {
      return [];
    }

    // Get player preferences by analyzing completed quests
    final preferences = await _analyzePlayerPreferences(player);

    // Score and rank quests
    final recommendations = availableQuests
        .map((quest) => _scoreQuest(quest, player, preferences))
        .where((rec) => rec.score > 0) // Filter out negative scores
        .toList();

    // Sort by score (highest first)
    recommendations.sort((a, b) => b.score.compareTo(a.score));

    // Return top recommendations
    return recommendations.take(limit).toList();
  }

  /// Analyze player preferences from completed quests
  Future<PlayerPreferences> _analyzePlayerPreferences(Player player) async {
    final completedQuestsResult = await _questRepository.getQuests(
      status: QuestStatus.completed,
    );

    List<Quest> completedQuests = [];
    if (completedQuestsResult is Success<List<Quest>>) {
      completedQuests = completedQuestsResult.data;
    }

    if (completedQuests.isEmpty) {
      // New player - return default preferences
      return PlayerPreferences(
        preferredCategories: [],
        preferredDifficulty: 2, // Start with medium difficulty
        averageCompletionTime: 0,
        preferredQuestTypes: [],
      );
    }

    // Calculate category preferences
    final categoryCounts = <QuestCategory, int>{};
    for (final quest in completedQuests) {
      categoryCounts[quest.category] = (categoryCounts[quest.category] ?? 0) + 1;
    }
    final preferredCategories = categoryCounts.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = preferredCategories
        .take(3)
        .map((e) => e.key)
        .toList();

    // Calculate difficulty preference (average)
    final avgDifficulty = completedQuests
            .map((q) => q.difficulty)
            .reduce((a, b) => a + b) /
        completedQuests.length;

    // Calculate average completion time (simplified - using created/completed dates)
    double avgCompletionTime = 0;
    final questsWithCompletion = completedQuests
        .where((q) => q.completedAt != null)
        .toList();
    if (questsWithCompletion.isNotEmpty) {
      final totalTime = questsWithCompletion
          .map((q) => q.completedAt!.difference(q.createdAt).inHours)
          .reduce((a, b) => a + b);
      avgCompletionTime = totalTime / questsWithCompletion.length;
    }

    // Calculate quest type preferences
    final typeCounts = <QuestType, int>{};
    for (final quest in completedQuests) {
      typeCounts[quest.type] = (typeCounts[quest.type] ?? 0) + 1;
    }
    final preferredTypes = typeCounts.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTypes = preferredTypes.take(2).map((e) => e.key).toList();

    return PlayerPreferences(
      preferredCategories: topCategories,
      preferredDifficulty: avgDifficulty.round().clamp(1, 5),
      averageCompletionTime: avgCompletionTime,
      preferredQuestTypes: topTypes,
    );
  }

  /// Score a quest based on player preferences
  RecommendedQuest _scoreQuest(
    Quest quest,
    Player player,
    PlayerPreferences preferences,
  ) {
    double score = 0.0;
    final reasons = <String>[];

    // 1. Category preference (30% weight)
    if (preferences.preferredCategories.contains(quest.category)) {
      final categoryIndex = preferences.preferredCategories.indexOf(quest.category);
      final categoryScore = (3 - categoryIndex) * 0.3; // Top category = 0.9, 2nd = 0.6, 3rd = 0.3
      score += categoryScore;
      reasons.add('Matches your preferred category');
    }

    // 2. Difficulty matching (25% weight)
    final difficultyDiff = (quest.difficulty - preferences.preferredDifficulty).abs();
    if (difficultyDiff == 0) {
      score += 0.25;
      reasons.add('Perfect difficulty match');
    } else if (difficultyDiff == 1) {
      score += 0.15;
      reasons.add('Close to your preferred difficulty');
    } else if (difficultyDiff == 2) {
      score += 0.05;
    }

    // 3. Quest type preference (20% weight)
    if (preferences.preferredQuestTypes.contains(quest.type)) {
      score += 0.2;
      reasons.add('Matches your quest type preference');
    }

    // 4. Reward value (15% weight) - higher rewards = better
    final rewardValue = quest.reward.experience + (quest.reward.currency ~/ 10);
    final maxReward = 1000; // Estimated max
    final rewardScore = (rewardValue / maxReward).clamp(0.0, 1.0) * 0.15;
    score += rewardScore;
    if (rewardValue > 500) {
      reasons.add('High reward value');
    }

    // 5. Progress status (10% weight) - prefer in-progress quests
    if (quest.status == QuestStatus.inProgress) {
      score += 0.1;
      reasons.add('Already in progress');
    }

    // 6. Level appropriateness (bonus)
    // Quests slightly above player level are more engaging
    final levelDiff = quest.difficulty - (player.level ~/ 5).clamp(1, 5);
    if (levelDiff >= 0 && levelDiff <= 1) {
      score += 0.05;
      reasons.add('Appropriate for your level');
    }

    // Generate explanation
    String explanation;
    if (reasons.isEmpty) {
      explanation = 'Good quest to try';
    } else if (reasons.length == 1) {
      explanation = reasons.first;
    } else {
      explanation = reasons.take(2).join(' • ');
    }

    return RecommendedQuest(
      quest: quest,
      score: score,
      explanation: explanation,
    );
  }
}

/// Player preferences derived from quest completion history
class PlayerPreferences {
  final List<QuestCategory> preferredCategories;
  final int preferredDifficulty;
  final double averageCompletionTime;
  final List<QuestType> preferredQuestTypes;

  const PlayerPreferences({
    required this.preferredCategories,
    required this.preferredDifficulty,
    required this.averageCompletionTime,
    required this.preferredQuestTypes,
  });
}




