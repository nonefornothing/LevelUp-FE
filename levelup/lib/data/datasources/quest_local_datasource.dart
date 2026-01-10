import 'package:hive/hive.dart';

import '../../domain/entities/quest.dart';
import '../models/quest_hive_models.dart';
import 'local_storage.dart';

abstract class QuestLocalDataSource {
  Future<List<Quest>> getQuests({QuestType? type, QuestStatus? status});
  Future<Quest?> getQuestById(String id);
  Future<void> upsertQuest(Quest quest);
  Future<void> deleteQuest(String id);
}

class QuestLocalDataSourceImpl implements QuestLocalDataSource {
  QuestLocalDataSourceImpl();

  Box<QuestHiveModel> get _box => Hive.box<QuestHiveModel>(HiveLocalStorage.questBoxName);

  @override
  Future<List<Quest>> getQuests({QuestType? type, QuestStatus? status}) async {
    // Filter at the model level before converting to domain objects for better performance
    Iterable<QuestHiveModel> models = _box.values;
    
    if (type != null) {
      final typeIndex = type.index;
      models = models.where((m) => m.typeIndex == typeIndex);
    }
    if (status != null) {
      final statusIndex = status.index;
      models = models.where((m) => m.statusIndex == statusIndex);
    }

    // Convert to domain objects and sort
    final quests = models.map((m) => m.toDomain()).toList(growable: false);
    
    // Default sort: newest first
    quests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return quests;
  }

  @override
  Future<Quest?> getQuestById(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> upsertQuest(Quest quest) async {
    await _box.put(quest.id, QuestHiveModel.fromDomain(quest));
  }

  @override
  Future<void> deleteQuest(String id) async {
    await _box.delete(id);
  }
}


