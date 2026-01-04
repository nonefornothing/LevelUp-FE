import 'package:hive_flutter/hive_flutter.dart';

import '../models/player_hive_models.dart';
import '../models/quest_hive_models.dart';
import '../models/achievement_hive_models.dart';

/// Local storage interface
abstract class LocalStorage {
  Future<void> init();
  Future<void> close();
  Future<void> clear();
}

/// Hive implementation of local storage
class HiveLocalStorage implements LocalStorage {
  static const String questBoxName = 'quests';
  static const String playerBoxName = 'player';
  static const String prefsBoxName = 'preferences';
  static const String achievementBoxName = 'achievements';

  @override
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (manual, no codegen)
    _registerAdapterIfNeeded(QuestHiveModelAdapter());
    _registerAdapterIfNeeded(QuestTaskHiveModelAdapter());
    _registerAdapterIfNeeded(QuestMilestoneHiveModelAdapter());
    _registerAdapterIfNeeded(PlayerHiveModelAdapter());
    _registerAdapterIfNeeded(PlayerStatsHiveModelAdapter());
    _registerAdapterIfNeeded(AchievementHiveModelAdapter());

    // Open boxes
    await Hive.openBox<QuestHiveModel>(questBoxName);
    await Hive.openBox<PlayerHiveModel>(playerBoxName);
    await Hive.openBox(prefsBoxName);
    await Hive.openBox<AchievementHiveModel>(achievementBoxName);
  }

  void _registerAdapterIfNeeded<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  @override
  Future<void> close() async {
    await Hive.close();
  }

  @override
  Future<void> clear() async {
    await Hive.deleteFromDisk();
  }
}

