import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/weekly_challenge.dart';
import '../models/weekly_challenge_hive_models.dart';
import 'local_storage.dart';

/// Local data source for weekly challenges using Hive
class WeeklyChallengeLocalDataSource {
  final Box<WeeklyChallengeHiveModel> _box;

  WeeklyChallengeLocalDataSource({Box<WeeklyChallengeHiveModel>? box})
      : _box = box ?? Hive.box<WeeklyChallengeHiveModel>(HiveLocalStorage.weeklyChallengeBoxName);

  /// Get all weekly challenges
  List<WeeklyChallenge> getAllWeeklyChallenges() {
    return _box.values.map((model) => model.toDomain()).toList();
  }

  /// Get active weekly challenges (for current week)
  List<WeeklyChallenge> getActiveWeeklyChallenges() {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);

    return _box.values
        .where((model) {
          final challenge = model.toDomain();
          return challenge.weekStartDate.isAtSameMomentAs(currentWeekStart) ||
              (challenge.weekStartDate.isBefore(now) && challenge.weekEndDate.isAfter(now));
        })
        .map((model) => model.toDomain())
        .toList();
  }

  /// Get weekly challenge by ID
  WeeklyChallenge? getWeeklyChallengeById(String id) {
    final model = _box.get(id);
    return model?.toDomain();
  }

  /// Create weekly challenge
  Future<void> createWeeklyChallenge(WeeklyChallenge challenge) async {
    final model = WeeklyChallengeHiveModel.fromDomain(challenge);
    await _box.put(challenge.id, model);
  }

  /// Update weekly challenge
  Future<void> updateWeeklyChallenge(WeeklyChallenge challenge) async {
    final model = WeeklyChallengeHiveModel.fromDomain(challenge);
    await _box.put(challenge.id, model);
  }

  /// Delete weekly challenge
  Future<void> deleteWeeklyChallenge(String id) async {
    await _box.delete(id);
  }

  /// Get week start (Monday)
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final daysFromMonday = weekday == 7 ? 6 : weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }

}

