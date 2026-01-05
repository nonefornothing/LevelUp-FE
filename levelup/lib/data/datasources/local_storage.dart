import 'package:hive_flutter/hive_flutter.dart';

import '../models/player_hive_models.dart';
import '../models/quest_hive_models.dart';
import '../models/achievement_hive_models.dart';
import '../models/weekly_challenge_hive_models.dart';
import '../models/item_hive_models.dart';
import '../models/notification_hive_models.dart';
import '../models/friend_hive_models.dart';
import '../models/quest_template_hive_models.dart';

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
  static const String weeklyChallengeBoxName = 'weekly_challenges';
  static const String inventoryBoxName = 'inventory';
  static const String notificationBoxName = 'notifications';
  static const String notificationPrefsBoxName = 'notification_preferences';
  static const String friendsBoxName = 'friends';
  static const String friendRequestsBoxName = 'friend_requests';
  static const String sharedQuestsBoxName = 'shared_quests';
  static const String questTemplatesBoxName = 'quest_templates';

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
    _registerAdapterIfNeeded(WeeklyChallengeHiveModelAdapter());
    _registerAdapterIfNeeded(ItemHiveModelAdapter());
    _registerAdapterIfNeeded(InventoryItemHiveModelAdapter());
    _registerAdapterIfNeeded(InventoryHiveModelAdapter());
    _registerAdapterIfNeeded(NotificationHiveModelAdapter());
    _registerAdapterIfNeeded(NotificationPreferencesHiveModelAdapter());
    _registerAdapterIfNeeded(FriendHiveModelAdapter());
    _registerAdapterIfNeeded(FriendRequestHiveModelAdapter());
    _registerAdapterIfNeeded(SharedQuestHiveModelAdapter());
    _registerAdapterIfNeeded(QuestTemplateHiveModelAdapter());
    _registerAdapterIfNeeded(QuestTemplateTaskHiveModelAdapter());
    _registerAdapterIfNeeded(QuestTemplateMilestoneHiveModelAdapter());

    // Open boxes
    await Hive.openBox<QuestHiveModel>(questBoxName);
    await Hive.openBox<PlayerHiveModel>(playerBoxName);
    await Hive.openBox(prefsBoxName);
    await Hive.openBox<AchievementHiveModel>(achievementBoxName);
    await Hive.openBox<WeeklyChallengeHiveModel>(weeklyChallengeBoxName);
    await Hive.openBox<InventoryHiveModel>(inventoryBoxName);
    await Hive.openBox<NotificationHiveModel>(notificationBoxName);
    await Hive.openBox<NotificationPreferencesHiveModel>(notificationPrefsBoxName);
    await Hive.openBox<FriendHiveModel>(friendsBoxName);
    await Hive.openBox<FriendRequestHiveModel>(friendRequestsBoxName);
    await Hive.openBox<SharedQuestHiveModel>(sharedQuestsBoxName);
    await Hive.openBox<QuestTemplateHiveModel>(questTemplatesBoxName);
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

