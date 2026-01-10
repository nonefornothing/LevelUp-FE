import 'package:hive/hive.dart';

import '../../domain/entities/achievement.dart';
import '../models/achievement_hive_models.dart';
import 'local_storage.dart';

abstract class AchievementLocalDataSource {
  Future<List<Achievement>> getAllAchievements();
  Future<Achievement?> getAchievementById(String id);
  Future<void> upsertAchievement(Achievement achievement);
  Future<void> upsertAchievements(List<Achievement> achievements);
  Future<void> deleteAchievement(String id);
}

class AchievementLocalDataSourceImpl implements AchievementLocalDataSource {
  AchievementLocalDataSourceImpl();

  Box<AchievementHiveModel> get _box => Hive.box<AchievementHiveModel>(HiveLocalStorage.achievementBoxName);

  @override
  Future<List<Achievement>> getAllAchievements() async {
    final all = _box.values.map((m) => m.toDomain()).toList(growable: false);
    // Sort by tier, then by type, then by target value
    all.sort((a, b) {
      final tierCompare = a.tier.index.compareTo(b.tier.index);
      if (tierCompare != 0) return tierCompare;
      final typeCompare = a.type.index.compareTo(b.type.index);
      if (typeCompare != 0) return typeCompare;
      return a.targetValue.compareTo(b.targetValue);
    });
    return all;
  }

  @override
  Future<Achievement?> getAchievementById(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> upsertAchievement(Achievement achievement) async {
    await _box.put(achievement.id, AchievementHiveModel.fromDomain(achievement));
  }

  @override
  Future<void> upsertAchievements(List<Achievement> achievements) async {
    final Map<String, AchievementHiveModel> data = {};
    for (final achievement in achievements) {
      data[achievement.id] = AchievementHiveModel.fromDomain(achievement);
    }
    await _box.putAll(data);
  }

  @override
  Future<void> deleteAchievement(String id) async {
    await _box.delete(id);
  }
}





