import 'package:hive/hive.dart';
import 'package:levelup/data/datasources/local_storage.dart';
import 'package:levelup/data/models/quest_hive_models.dart';
import 'package:levelup/data/models/player_hive_models.dart';
import 'package:levelup/domain/entities/quest.dart';
import 'package:levelup/domain/entities/player.dart';
import 'base_agent.dart';

/// Data validation agent
/// Note: This agent doesn't execute full scenarios, it's used by journey agents
class DataAgent extends BaseAgent {
  DataAgent(super.tester);

  @override
  Future<AgentResult> execute(TestScenario scenario) async {
    throw UnimplementedError('DataAgent does not execute scenarios directly');
  }

  @override
  Future<bool> validate(Assertion assertion) async {
    return await assertion.validate();
  }

  /// Verify quest exists in database
  Future<bool> verifyQuestExists({
    required String questId,
    Map<String, dynamic>? expectedData,
  }) async {
    logAction('Verifying quest exists: $questId');

    try {
      final box = Hive.box<QuestHiveModel>(HiveLocalStorage.questBoxName);
      final questModel = box.get(questId);

      if (questModel == null) {
        recordError('Quest not found: $questId');
        return false;
      }

      final quest = questModel.toDomain();

      if (expectedData != null) {
        // Verify expected data matches
        if (expectedData.containsKey('title') && quest.title != expectedData['title']) {
          recordError('Quest title mismatch: expected ${expectedData['title']}, got ${quest.title}');
          return false;
        }
        if (expectedData.containsKey('status')) {
          final expectedStatus = expectedData['status'] as QuestStatus;
          if (quest.status != expectedStatus) {
            recordError('Quest status mismatch: expected $expectedStatus, got ${quest.status}');
            return false;
          }
        }
      }

      logAction('Quest verified: $questId');
      return true;
    } catch (e) {
      recordError('Error verifying quest: $e');
      return false;
    }
  }

  /// Verify player data
  Future<bool> verifyPlayerData({
    required Map<String, dynamic> expected,
  }) async {
    logAction('Verifying player data');

    try {
      final box = Hive.box<PlayerHiveModel>(HiveLocalStorage.playerBoxName);
      
      // Get current player ID from preferences
      final prefsBox = Hive.box(HiveLocalStorage.prefsBoxName);
      final playerId = prefsBox.get('current_player_id') as String?;

      if (playerId == null) {
        recordError('No current player ID found');
        return false;
      }

      final playerModel = box.get(playerId);
      if (playerModel == null) {
        recordError('Player not found: $playerId');
        return false;
      }

      final player = playerModel.toDomain();

      // Verify expected values
      if (expected.containsKey('level') && player.level != expected['level']) {
        recordError('Player level mismatch: expected ${expected['level']}, got ${player.level}');
        return false;
      }

      if (expected.containsKey('experience') && player.experience != expected['experience']) {
        recordError('Player experience mismatch: expected ${expected['experience']}, got ${player.experience}');
        return false;
      }

      if (expected.containsKey('currency') && player.currency != expected['currency']) {
        recordError('Player currency mismatch: expected ${expected['currency']}, got ${player.currency}');
        return false;
      }

      logAction('Player data verified');
      recordDiscovery('Player level: ${player.level}, XP: ${player.experience}, Currency: ${player.currency}');
      return true;
    } catch (e) {
      recordError('Error verifying player data: $e');
      return false;
    }
  }

  /// Get all quests
  Future<List<Quest>> getAllQuests({QuestType? type}) async {
    logAction('Getting all quests${type != null ? " (type: $type)" : ""}');

    try {
      final box = Hive.box<QuestHiveModel>(HiveLocalStorage.questBoxName);
      final quests = box.values.map((m) => m.toDomain()).toList();

      if (type != null) {
        final filtered = quests.where((q) => q.type == type).toList();
        logAction('Found ${filtered.length} quests of type $type');
        return filtered;
      }

      logAction('Found ${quests.length} total quests');
      return quests;
    } catch (e) {
      recordError('Error getting quests: $e');
      return [];
    }
  }

  /// Get player data
  Future<Player?> getPlayer() async {
    logAction('Getting player data');

    try {
      final prefsBox = Hive.box(HiveLocalStorage.prefsBoxName);
      final playerId = prefsBox.get('current_player_id') as String?;

      if (playerId == null) {
        recordError('No current player ID found');
        return null;
      }

      final box = Hive.box<PlayerHiveModel>(HiveLocalStorage.playerBoxName);
      final playerModel = box.get(playerId);

      if (playerModel == null) {
        recordError('Player not found: $playerId');
        return null;
      }

      logAction('Player data retrieved');
      return playerModel.toDomain();
    } catch (e) {
      recordError('Error getting player: $e');
      return null;
    }
  }

  /// Discover data anomalies
  Future<List<String>> discoverAnomalies() async {
    logAction('Discovering data anomalies');
    final anomalies = <String>[];

    try {
      // Check for orphaned tasks
      final questBox = Hive.box<QuestHiveModel>(HiveLocalStorage.questBoxName);
      final quests = questBox.values.map((m) => m.toDomain()).toList();

      for (final quest in quests) {
        // Check for invalid progress percentages
        if (quest.progressPercentage < 0 || quest.progressPercentage > 100) {
          anomalies.add('Quest ${quest.id} has invalid progress: ${quest.progressPercentage}%');
        }

        // Check for completed quests with 0% progress
        if (quest.status == QuestStatus.completed && quest.progressPercentage < 100) {
          anomalies.add('Quest ${quest.id} is marked completed but has ${quest.progressPercentage}% progress');
        }

        // Check for tasks with wrong quest IDs
        for (final task in quest.tasks) {
          if (task.questId != quest.id) {
            anomalies.add('Task ${task.id} has mismatched quest ID: ${task.questId} != ${quest.id}');
          }
        }
      }

      if (anomalies.isEmpty) {
        logAction('No anomalies discovered');
      } else {
        recordDiscovery('Discovered ${anomalies.length} anomalies');
        for (final anomaly in anomalies) {
          recordDiscovery(anomaly);
        }
      }
    } catch (e) {
      recordError('Error discovering anomalies: $e');
    }

    return anomalies;
  }

  /// Count quests by status
  Future<Map<QuestStatus, int>> countQuestsByStatus() async {
    logAction('Counting quests by status');

    try {
      final quests = await getAllQuests();
      final counts = <QuestStatus, int>{};

      for (final quest in quests) {
        counts[quest.status] = (counts[quest.status] ?? 0) + 1;
      }

      recordDiscovery('Quest counts: $counts');
      return counts;
    } catch (e) {
      recordError('Error counting quests: $e');
      return {};
    }
  }
}

