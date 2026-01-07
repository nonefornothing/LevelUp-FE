import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/result.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_template.dart';
import '../models/quest_template_hive_models.dart';

/// Local data source for Quest Templates
class QuestTemplateLocalDataSource {
  static const String _boxName = 'quest_templates';
  late Box<QuestTemplateHiveModel> _box;

  /// Initialize the Hive box
  Future<void> init() async {
    _box = await Hive.openBox<QuestTemplateHiveModel>(_boxName);
  }

  /// Get all quest templates
  Future<Result<List<QuestTemplate>>> getQuestTemplates() async {
    try {
      final templates = _box.values.map((model) => model.toDomain()).toList();
      return Success<List<QuestTemplate>>(templates);
    } catch (e) {
      return ResultError<List<QuestTemplate>>('Failed to get quest templates: $e');
    }
  }

  /// Get quest template by ID
  Future<Result<QuestTemplate?>> getQuestTemplateById(String id) async {
    try {
      final model = _box.get(id);
      return Success<QuestTemplate?>(model?.toDomain());
    } catch (e) {
      return ResultError<QuestTemplate?>('Failed to get quest template: $e');
    }
  }

  /// Save quest templates
  Future<Result<void>> saveQuestTemplates(
    List<QuestTemplate> templates,
  ) async {
    try {
      final models = templates
          .map((t) => QuestTemplateHiveModel.fromDomain(t))
          .toList();

      // Clear existing templates
      await _box.clear();

      // Save new templates
      for (final model in models) {
        await _box.put(model.id, model);
      }

      return const Success<void>(null);
    } catch (e) {
      return ResultError<void>('Failed to save quest templates: $e');
    }
  }

  /// Search quest templates
  Future<Result<List<QuestTemplate>>> searchQuestTemplates(
    String query,
  ) async {
    try {
      final allTemplates = _box.values.map((model) => model.toDomain()).toList();
      final lowerQuery = query.toLowerCase();

      final filtered = allTemplates.where((template) {
        return template.title.toLowerCase().contains(lowerQuery) ||
            template.description.toLowerCase().contains(lowerQuery) ||
            template.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();

      return Success<List<QuestTemplate>>(filtered);
    } catch (e) {
      return ResultError<List<QuestTemplate>>('Failed to search quest templates: $e');
    }
  }

  /// Get quest templates by category
  Future<Result<List<QuestTemplate>>> getQuestTemplatesByCategory(
    QuestCategory category,
  ) async {
    try {
      final allTemplates = _box.values.map((model) => model.toDomain()).toList();
      final filtered = allTemplates
          .where((template) => template.category == category)
          .toList();
      return Success<List<QuestTemplate>>(filtered);
    } catch (e) {
      return ResultError<List<QuestTemplate>>('Failed to get quest templates by category: $e');
    }
  }

  /// Get featured quest templates
  Future<Result<List<QuestTemplate>>> getFeaturedQuestTemplates() async {
    try {
      final allTemplates = _box.values.map((model) => model.toDomain()).toList();
      final featured = allTemplates
          .where((template) => template.isFeatured)
          .toList();
      return Success<List<QuestTemplate>>(featured);
    } catch (e) {
      return ResultError<List<QuestTemplate>>('Failed to get featured quest templates: $e');
    }
  }

  /// Get quest templates by tags
  Future<Result<List<QuestTemplate>>> getQuestTemplatesByTags(
    List<String> tags,
  ) async {
    try {
      final allTemplates = _box.values.map((model) => model.toDomain()).toList();
      final filtered = allTemplates.where((template) {
        return tags.any((tag) => template.tags.contains(tag));
      }).toList();
      return Success<List<QuestTemplate>>(filtered);
    } catch (e) {
      return ResultError<List<QuestTemplate>>('Failed to get quest templates by tags: $e');
    }
  }
}


