import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/result.dart';
import '../../domain/entities/skill.dart';
import '../models/skill_hive_models.dart';

/// Local data source for skills using Hive
class SkillLocalDataSource {
  static const String skillBoxName = 'skills';
  Box<SkillHiveModel>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<SkillHiveModel>(skillBoxName);
  }

  Future<Result<List<Skill>>> getAllSkills() async {
    try {
      if (_box == null) await init();
      final models = _box!.values.toList();
      final skills = models.map((model) => model.toDomain()).toList();
      return Success(skills);
    } catch (e) {
      return ResultError(
        'Failed to get skills: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<Result<Skill>> getSkillById(String skillId) async {
    try {
      if (_box == null) await init();
      final model = _box!.get(skillId);
      if (model == null) {
        return ResultError('Skill not found: $skillId');
      }
      return Success(model.toDomain());
    } catch (e) {
      return ResultError(
        'Failed to get skill: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<Result<List<Skill>>> getSkillsByType(SkillType type) async {
    try {
      if (_box == null) await init();
      final models = _box!.values
          .where((model) => model.typeIndex == type.index)
          .toList();
      final skills = models.map((model) => model.toDomain()).toList();
      return Success(skills);
    } catch (e) {
      return ResultError(
        'Failed to get skills by type: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<Result<Skill>> saveSkill(Skill skill) async {
    try {
      if (_box == null) await init();
      final model = SkillHiveModel.fromDomain(skill);
      await _box!.put(skill.id, model);
      return Success(skill);
    } catch (e) {
      return ResultError(
        'Failed to save skill: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<Result<void>> saveAllSkills(List<Skill> skills) async {
    try {
      if (_box == null) await init();
      final Map<String, SkillHiveModel> models = {};
      for (final skill in skills) {
        models[skill.id] = SkillHiveModel.fromDomain(skill);
      }
      await _box!.putAll(models);
      return Success(null);
    } catch (e) {
      return ResultError(
        'Failed to save skills: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<Result<void>> clearAllSkills() async {
    try {
      if (_box == null) await init();
      await _box!.clear();
      return Success(null);
    } catch (e) {
      return ResultError(
        'Failed to clear skills: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}

