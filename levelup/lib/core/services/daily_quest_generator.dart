import '../../domain/entities/quest.dart';
import '../../domain/entities/player.dart';
import '../utils/id_generator.dart';

/// Service for generating daily quests
class DailyQuestGenerator {
  /// Generate 3-5 daily quests for today
  static List<Quest> generateDailyQuests({
    required DateTime today,
    Player? player,
  }) {
    final quests = <Quest>[];
    final random = DateTime.now().millisecondsSinceEpoch;
    
    // Generate 3-5 quests
    final count = 3 + (random % 3); // 3, 4, or 5
    
    // Template quests (can be expanded later)
    final templates = _getQuestTemplates(player?.level ?? 1);
    
    for (int i = 0; i < count && i < templates.length; i++) {
      final template = templates[i % templates.length];
      final questId = IdGenerator.newId();
      final quest = Quest(
        id: questId,
        title: template.title,
        description: template.description,
        type: QuestType.daily,
        category: template.category,
        difficulty: template.difficulty,
        reward: QuestReward(
          experience: template.baseXP * (player?.level ?? 1),
          currency: template.baseCurrency,
        ),
        tasks: template.tasks.asMap().entries.map((entry) => QuestTask(
          id: IdGenerator.newId(),
          questId: questId,
          title: entry.value,
          isCompleted: false,
          orderIndex: entry.key,
        )).toList(),
        milestones: [],
        deadline: DateTime(today.year, today.month, today.day, 23, 59),
        status: QuestStatus.notStarted,
        progressPercentage: 0.0,
        createdAt: today,
      );
      quests.add(quest);
    }
    
    return quests;
  }

  /// Check if daily quests need to be regenerated
  static bool needsRegeneration(DateTime lastGenerationDate, DateTime today) {
    final lastDate = DateTime(
      lastGenerationDate.year,
      lastGenerationDate.month,
      lastGenerationDate.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    return lastDate.isBefore(todayDate);
  }
}

class _QuestTemplate {
  final String title;
  final String? description;
  final QuestCategory category;
  final int difficulty;
  final int baseXP;
  final int baseCurrency;
  final List<String> tasks;

  const _QuestTemplate({
    required this.title,
    this.description,
    required this.category,
    required this.difficulty,
    required this.baseXP,
    required this.baseCurrency,
    required this.tasks,
  });
}

List<_QuestTemplate> _getQuestTemplates(int playerLevel) {
  return [
    _QuestTemplate(
      title: 'Start Your Day Right',
      description: 'Complete a morning routine to boost your productivity',
      category: QuestCategory.health,
      difficulty: 1,
      baseXP: 50,
      baseCurrency: 10,
      tasks: [
        'Drink a glass of water',
        'Do 10 minutes of exercise',
        'Eat a healthy breakfast',
      ],
    ),
    _QuestTemplate(
      title: 'Learn Something New',
      description: 'Expand your knowledge with today\'s learning quest',
      category: QuestCategory.learning,
      difficulty: 2,
      baseXP: 75,
      baseCurrency: 15,
      tasks: [
        'Read for 20 minutes',
        'Watch an educational video',
        'Take notes on what you learned',
      ],
    ),
    _QuestTemplate(
      title: 'Connect with Others',
      description: 'Build relationships and strengthen your social connections',
      category: QuestCategory.social,
      difficulty: 1,
      baseXP: 50,
      baseCurrency: 10,
      tasks: [
        'Message a friend or family member',
        'Have a meaningful conversation',
        'Show appreciation to someone',
      ],
    ),
    _QuestTemplate(
      title: 'Stay Active',
      description: 'Get moving and boost your energy levels',
      category: QuestCategory.health,
      difficulty: 2,
      baseXP: 75,
      baseCurrency: 15,
      tasks: [
        'Take a 15-minute walk',
        'Do 3 sets of exercises',
        'Stretch for 10 minutes',
      ],
    ),
    _QuestTemplate(
      title: 'Focus and Create',
      description: 'Dedicate time to meaningful work or creative projects',
      category: QuestCategory.work,
      difficulty: 3,
      baseXP: 100,
      baseCurrency: 20,
      tasks: [
        'Work on an important project for 1 hour',
        'Complete 3 priority tasks',
        'Review and plan tomorrow\'s goals',
      ],
    ),
    _QuestTemplate(
      title: 'Self Care Session',
      description: 'Take care of your mental and emotional well-being',
      category: QuestCategory.personal,
      difficulty: 1,
      baseXP: 50,
      baseCurrency: 10,
      tasks: [
        'Practice 10 minutes of meditation',
        'Write in a journal',
        'Do something that brings you joy',
      ],
    ),
  ];
}

