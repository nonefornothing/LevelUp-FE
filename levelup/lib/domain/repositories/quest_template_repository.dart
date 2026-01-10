import '../../core/utils/result.dart';
import '../entities/quest.dart';
import '../entities/quest_template.dart';

/// Repository interface for Quest Templates
abstract class QuestTemplateRepository {
  /// Get all quest templates
  Future<Result<List<QuestTemplate>>> getQuestTemplates();

  /// Get quest template by ID
  Future<Result<QuestTemplate?>> getQuestTemplateById(String id);

  /// Get quest templates by category
  Future<Result<List<QuestTemplate>>> getQuestTemplatesByCategory(
    QuestCategory category,
  );

  /// Get featured quest templates
  Future<Result<List<QuestTemplate>>> getFeaturedQuestTemplates();

  /// Search quest templates by query
  Future<Result<List<QuestTemplate>>> searchQuestTemplates(String query);

  /// Get quest templates by tags
  Future<Result<List<QuestTemplate>>> getQuestTemplatesByTags(
    List<String> tags,
  );

  /// Save quest templates (for initialization)
  Future<Result<void>> saveQuestTemplates(List<QuestTemplate> templates);
}

