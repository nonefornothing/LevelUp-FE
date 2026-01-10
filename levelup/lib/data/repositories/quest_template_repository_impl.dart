import '../../core/utils/result.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_template.dart';
import '../../domain/repositories/quest_template_repository.dart';
import '../datasources/quest_template_local_datasource.dart';

/// Implementation of QuestTemplateRepository
class QuestTemplateRepositoryImpl implements QuestTemplateRepository {
  final QuestTemplateLocalDataSource _dataSource;

  QuestTemplateRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<QuestTemplate>>> getQuestTemplates() async {
    return await _dataSource.getQuestTemplates();
  }

  @override
  Future<Result<QuestTemplate?>> getQuestTemplateById(String id) async {
    return await _dataSource.getQuestTemplateById(id);
  }

  @override
  Future<Result<List<QuestTemplate>>> getQuestTemplatesByCategory(
    QuestCategory category,
  ) async {
    return await _dataSource.getQuestTemplatesByCategory(category);
  }

  @override
  Future<Result<List<QuestTemplate>>> getFeaturedQuestTemplates() async {
    return await _dataSource.getFeaturedQuestTemplates();
  }

  @override
  Future<Result<List<QuestTemplate>>> searchQuestTemplates(
    String query,
  ) async {
    return await _dataSource.searchQuestTemplates(query);
  }

  @override
  Future<Result<List<QuestTemplate>>> getQuestTemplatesByTags(
    List<String> tags,
  ) async {
    return await _dataSource.getQuestTemplatesByTags(tags);
  }

  @override
  Future<Result<void>> saveQuestTemplates(
    List<QuestTemplate> templates,
  ) async {
    return await _dataSource.saveQuestTemplates(templates);
  }
}

