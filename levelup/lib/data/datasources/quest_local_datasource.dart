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
    final all = _box.values.map((m) => m.toDomain()).toList(growable: false);

    Iterable<Quest> filtered = all;
    if (type != null) {
      filtered = filtered.where((q) => q.type == type);
    }
    if (status != null) {
      filtered = filtered.where((q) => q.status == status);
    }

    // Default sort: newest first
    final list = filtered.toList(growable: false);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
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


