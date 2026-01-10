import 'package:levelup/domain/entities/quest.dart';
import 'package:levelup/domain/entities/player.dart';
import 'package:levelup/core/utils/id_generator.dart';

/// Factory for creating test quest data
class QuestFactory {
  static Quest createTestQuest({
    String? id,
    String? title,
    QuestType type = QuestType.side,
    QuestStatus status = QuestStatus.notStarted,
    int taskCount = 3,
  }) {
    final questId = id ?? IdGenerator.newId();
    return Quest(
      id: questId,
      title: title ?? 'Test Quest',
      description: 'Test quest description',
      type: type,
      category: QuestCategory.personal,
      difficulty: 2,
      reward: QuestReward(
        experience: 100,
        currency: 50,
      ),
      tasks: List.generate(taskCount, (index) => QuestTask(
        id: IdGenerator.newId(),
        questId: questId,
        title: 'Task ${index + 1}',
        isCompleted: false,
        orderIndex: index,
      )),
      milestones: [],
      status: status,
      progressPercentage: 0.0,
      createdAt: DateTime.now(),
    );
  }

  static Quest createCompletedQuest() {
    final quest = createTestQuest(taskCount: 3);
    return Quest(
      id: quest.id,
      title: quest.title,
      description: quest.description,
      type: quest.type,
      category: quest.category,
      difficulty: quest.difficulty,
      reward: quest.reward,
      tasks: quest.tasks.map((task) => QuestTask(
        id: task.id,
        questId: task.questId,
        title: task.title,
        isCompleted: true,
        completedAt: DateTime.now(),
        orderIndex: task.orderIndex,
      )).toList(),
      milestones: quest.milestones,
      status: QuestStatus.completed,
      progressPercentage: 100.0,
      createdAt: quest.createdAt,
      completedAt: DateTime.now(),
    );
  }
}

/// Factory for creating test player data
class PlayerFactory {
  static Player createTestPlayer({
    String? id,
    String? username,
    int level = 1,
    int experience = 0,
    int currency = 0,
  }) {
    return Player(
      id: id ?? IdGenerator.newId(),
      username: username ?? 'TestUser',
      email: 'test@example.com',
      level: level,
      experience: experience,
      currency: currency,
      stats: const PlayerStats(
        totalQuestsCompleted: 0,
        currentStreak: 0,
        longestStreak: 0,
      ),
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }
}


