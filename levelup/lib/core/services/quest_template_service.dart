import 'package:uuid/uuid.dart';

import '../../core/utils/result.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_template.dart';
import '../../domain/repositories/quest_template_repository.dart';
import '../../data/datasources/quest_template_local_datasource.dart';

/// Service for managing quest templates
class QuestTemplateService {
  final QuestTemplateRepository _repository;
  final QuestTemplateLocalDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  QuestTemplateService({
    required QuestTemplateRepository repository,
    required QuestTemplateLocalDataSource dataSource,
  })  : _repository = repository,
        _dataSource = dataSource;

  /// Initialize datasource and predefined quest templates
  Future<Result<void>> initializeTemplates() async {
    try {
      // Initialize datasource
      await _dataSource.init();

      final existingResult = await _repository.getQuestTemplates();
      if (existingResult is Success<List<QuestTemplate>>) {
        final existing = existingResult.data;
        // If templates already exist, don't reinitialize
        if (existing.isNotEmpty) {
          return Result.success(null);
        }
      }

      final templates = _getPredefinedTemplates();
      final saveResult = await _saveTemplates(templates);
      return saveResult;
    } catch (e) {
      return Result.error('Failed to initialize quest templates: $e');
    }
  }

  /// Get all quest templates
  Future<Result<List<QuestTemplate>>> getQuestTemplates() async {
    return await _repository.getQuestTemplates();
  }

  /// Get featured quest templates
  Future<Result<List<QuestTemplate>>> getFeaturedQuestTemplates() async {
    return await _repository.getFeaturedQuestTemplates();
  }

  /// Search quest templates
  Future<Result<List<QuestTemplate>>> searchQuestTemplates(
    String query,
  ) async {
    return await _repository.searchQuestTemplates(query);
  }

  /// Get quest templates by category
  Future<Result<List<QuestTemplate>>> getQuestTemplatesByCategory(
    QuestCategory category,
  ) async {
    return await _repository.getQuestTemplatesByCategory(category);
  }

  /// Get quest template by ID
  Future<Result<QuestTemplate?>> getQuestTemplateById(String id) async {
    return await _repository.getQuestTemplateById(id);
  }

  /// Save templates (internal use)
  Future<Result<void>> _saveTemplates(
    List<QuestTemplate> templates,
  ) async {
    return await _repository.saveQuestTemplates(templates);
  }

  /// Get predefined quest templates
  List<QuestTemplate> _getPredefinedTemplates() {
    final now = DateTime.now();
    return [
      // Health & Fitness Templates
      QuestTemplate(
        id: _uuid.v4(),
        title: '7-Day Fitness Challenge',
        description:
            'Complete a week of daily workouts to build healthy habits and improve your fitness level.',
        type: QuestType.side,
        category: QuestCategory.health,
        difficulty: 3,
        reward: const QuestReward(experience: 500, currency: 200),
        tasks: [
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Day 1: 20-minute workout',
            description: 'Complete any form of exercise for 20 minutes',
            orderIndex: 0,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Day 2: Cardio session',
            description: '30 minutes of cardio (running, cycling, etc.)',
            orderIndex: 1,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Day 3: Strength training',
            description: 'Focus on strength exercises',
            orderIndex: 2,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Day 4: Active recovery',
            description: 'Light activity like walking or yoga',
            orderIndex: 3,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Day 5: Full body workout',
            description: 'Complete a full body workout routine',
            orderIndex: 4,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Day 6: Endurance training',
            description: 'Longer duration activity (45+ minutes)',
            orderIndex: 5,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Day 7: Rest day with stretching',
            description: 'Gentle stretching and mobility work',
            orderIndex: 6,
          ),
        ],
        milestones: [
          QuestTemplateMilestone(
            id: _uuid.v4(),
            title: 'Halfway Point',
            description: 'Complete 4 days of workouts',
            reward: const QuestReward(experience: 200, currency: 100),
            orderIndex: 0,
          ),
        ],
        estimatedDurationDays: 7,
        requiredLevel: 1,
        tags: ['fitness', 'health', 'challenge', 'weekly'],
        isFeatured: true,
        createdAt: now,
      ),

      // Learning Templates
      QuestTemplate(
        id: _uuid.v4(),
        title: 'Learn a New Skill',
        description:
            'Dedicate time to learning something new. Choose any skill you\'re interested in!',
        type: QuestType.side,
        category: QuestCategory.learning,
        difficulty: 2,
        reward: const QuestReward(experience: 400, currency: 150),
        tasks: [
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Research and choose a skill',
            description: 'Pick something you want to learn',
            orderIndex: 0,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Find learning resources',
            description: 'Books, courses, videos, or tutorials',
            orderIndex: 1,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Study for 2 hours',
            description: 'Dedicate focused learning time',
            orderIndex: 2,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Practice the skill',
            description: 'Apply what you\'ve learned',
            orderIndex: 3,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Create a small project',
            description: 'Build something using your new skill',
            orderIndex: 4,
          ),
        ],
        milestones: [
          QuestTemplateMilestone(
            id: _uuid.v4(),
            title: 'Learning Milestone',
            description: 'Complete 3 hours of study',
            reward: const QuestReward(experience: 150, currency: 75),
            orderIndex: 0,
          ),
        ],
        estimatedDurationDays: 5,
        requiredLevel: 1,
        tags: ['learning', 'education', 'skill'],
        isFeatured: true,
        createdAt: now,
      ),

      // Work Templates
      QuestTemplate(
        id: _uuid.v4(),
        title: 'Productivity Boost Week',
        description:
            'Focus on improving your work productivity with structured daily goals.',
        type: QuestType.mainStory,
        category: QuestCategory.work,
        difficulty: 3,
        reward: const QuestReward(experience: 600, currency: 250),
        tasks: [
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Plan your week',
            description: 'Create a detailed weekly plan',
            orderIndex: 0,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Complete top 3 priorities',
            description: 'Focus on most important tasks',
            orderIndex: 1,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Minimize distractions',
            description: 'Work in focused blocks',
            orderIndex: 2,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Review and adjust',
            description: 'Reflect on progress and optimize',
            orderIndex: 3,
          ),
        ],
        milestones: [
          QuestTemplateMilestone(
            id: _uuid.v4(),
            title: 'Mid-week Check',
            description: 'Complete 2 days of focused work',
            reward: const QuestReward(experience: 200, currency: 100),
            orderIndex: 0,
          ),
        ],
        estimatedDurationDays: 5,
        requiredLevel: 2,
        tags: ['work', 'productivity', 'professional'],
        isFeatured: true,
        createdAt: now,
      ),

      // Personal Development Templates
      QuestTemplate(
        id: _uuid.v4(),
        title: 'Morning Routine Mastery',
        description:
            'Establish a consistent morning routine to start your days with purpose and energy.',
        type: QuestType.side,
        category: QuestCategory.personal,
        difficulty: 2,
        reward: const QuestReward(experience: 350, currency: 150),
        tasks: [
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Wake up at consistent time',
            description: 'Set and follow a wake-up schedule',
            orderIndex: 0,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Morning meditation or reflection',
            description: '5-10 minutes of mindfulness',
            orderIndex: 1,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Healthy breakfast',
            description: 'Start with nutritious meal',
            orderIndex: 2,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Plan your day',
            description: 'Review goals and priorities',
            orderIndex: 3,
          ),
        ],
        milestones: [
          QuestTemplateMilestone(
            id: _uuid.v4(),
            title: 'Routine Established',
            description: 'Complete 5 consecutive days',
            reward: const QuestReward(experience: 150, currency: 75),
            orderIndex: 0,
          ),
        ],
        estimatedDurationDays: 7,
        requiredLevel: 1,
        tags: ['routine', 'personal', 'habits'],
        createdAt: now,
      ),

      // Social Templates
      QuestTemplate(
        id: _uuid.v4(),
        title: 'Social Connection Week',
        description:
            'Strengthen your relationships by reaching out to friends and family.',
        type: QuestType.side,
        category: QuestCategory.social,
        difficulty: 2,
        reward: const QuestReward(experience: 300, currency: 120),
        tasks: [
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Call a family member',
            description: 'Reach out to someone you haven\'t talked to recently',
            orderIndex: 0,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Message an old friend',
            description: 'Reconnect with someone from your past',
            orderIndex: 1,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Plan a social activity',
            description: 'Organize time with friends',
            orderIndex: 2,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Express gratitude',
            description: 'Thank someone who helped you',
            orderIndex: 3,
          ),
        ],
        milestones: [],
        estimatedDurationDays: 7,
        requiredLevel: 1,
        tags: ['social', 'relationships', 'connection'],
        createdAt: now,
      ),

      // Exploration Templates
      QuestTemplate(
        id: _uuid.v4(),
        title: 'Local Explorer',
        description:
            'Discover new places and experiences in your local area.',
        type: QuestType.side,
        category: QuestCategory.exploration,
        difficulty: 2,
        reward: const QuestReward(experience: 400, currency: 150),
        tasks: [
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Research local attractions',
            description: 'Find interesting places nearby',
            orderIndex: 0,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Visit a new park or nature spot',
            description: 'Explore outdoor areas',
            orderIndex: 1,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Try a new restaurant or cafe',
            description: 'Experience local cuisine',
            orderIndex: 2,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Attend a local event',
            description: 'Find and join community activities',
            orderIndex: 3,
          ),
        ],
        milestones: [
          QuestTemplateMilestone(
            id: _uuid.v4(),
            title: 'Explorer Milestone',
            description: 'Visit 2 new places',
            reward: const QuestReward(experience: 150, currency: 75),
            orderIndex: 0,
          ),
        ],
        estimatedDurationDays: 7,
        requiredLevel: 1,
        tags: ['exploration', 'local', 'adventure'],
        createdAt: now,
      ),

      // Health Templates
      QuestTemplate(
        id: _uuid.v4(),
        title: 'Hydration Challenge',
        description:
            'Build the habit of drinking enough water daily for better health.',
        type: QuestType.side,
        category: QuestCategory.health,
        difficulty: 1,
        reward: const QuestReward(experience: 250, currency: 100),
        tasks: [
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Drink 8 glasses of water',
            description: 'Meet daily hydration goal',
            orderIndex: 0,
          ),
        ],
        milestones: [
          QuestTemplateMilestone(
            id: _uuid.v4(),
            title: '3-Day Streak',
            description: 'Complete 3 consecutive days',
            reward: const QuestReward(experience: 100, currency: 50),
            orderIndex: 0,
          ),
          QuestTemplateMilestone(
            id: _uuid.v4(),
            title: 'Week Complete',
            description: 'Complete 7 consecutive days',
            reward: const QuestReward(experience: 200, currency: 100),
            orderIndex: 1,
          ),
        ],
        estimatedDurationDays: 7,
        requiredLevel: 1,
        tags: ['health', 'hydration', 'habits'],
        createdAt: now,
      ),

      // Learning Templates
      QuestTemplate(
        id: _uuid.v4(),
        title: 'Read a Book',
        description:
            'Complete reading a book from start to finish. Choose any genre that interests you!',
        type: QuestType.side,
        category: QuestCategory.learning,
        difficulty: 2,
        reward: const QuestReward(experience: 450, currency: 180),
        tasks: [
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Choose a book',
            description: 'Select what you want to read',
            orderIndex: 0,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Read 25% of the book',
            description: 'Complete first quarter',
            orderIndex: 1,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Read 50% of the book',
            description: 'Reach the halfway point',
            orderIndex: 2,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Read 75% of the book',
            description: 'Almost there!',
            orderIndex: 3,
          ),
          QuestTemplateTask(
            id: _uuid.v4(),
            title: 'Finish the book',
            description: 'Complete your reading',
            orderIndex: 4,
          ),
        ],
        milestones: [
          QuestTemplateMilestone(
            id: _uuid.v4(),
            title: 'Halfway Point',
            description: 'Complete 50% of the book',
            reward: const QuestReward(experience: 150, currency: 75),
            orderIndex: 0,
          ),
        ],
        estimatedDurationDays: 14,
        requiredLevel: 1,
        tags: ['reading', 'learning', 'books'],
        createdAt: now,
      ),
    ];
  }
}

