import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/streak.dart';
import '../models/streak_hive_models.dart';
import 'local_storage.dart';

/// Local data source for streaks using Hive
class StreakLocalDataSource {
  final Box<StreakHiveModel> _streakBox;

  StreakLocalDataSource({
    Box<StreakHiveModel>? streakBox,
  }) : _streakBox = streakBox ??
            Hive.box<StreakHiveModel>(HiveLocalStorage.streakBoxName);

  /// Get all streaks
  List<Streak> getAllStreaks() {
    return _streakBox.values.map((model) => model.toEntity()).toList();
  }

  /// Get streak by ID
  Streak? getStreakById(String id) {
    final model = _streakBox.get(id);
    return model?.toEntity();
  }

  /// Get streak by type
  Streak? getStreakByType(StreakType type) {
    for (final model in _streakBox.values) {
      if (StreakType.values[model.typeIndex] == type) {
        return model.toEntity();
      }
    }
    return null;
  }

  /// Save or update streak
  Future<void> saveStreak(Streak streak) async {
    final model = StreakHiveModel.fromEntity(streak);
    await _streakBox.put(streak.id, model);
  }

  /// Delete streak
  Future<void> deleteStreak(String id) async {
    await _streakBox.delete(id);
  }

  /// Delete all streaks
  Future<void> deleteAllStreaks() async {
    await _streakBox.clear();
  }
}



