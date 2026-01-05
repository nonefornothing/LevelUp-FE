import 'package:hive/hive.dart';

import '../../domain/entities/quest.dart';

/// Hive model for storing a Quest locally.
class QuestHiveModel {
  final String id;
  final String title;
  final String? description;
  final int typeIndex;
  final int categoryIndex;
  final int difficulty;
  final int rewardExperience;
  final int rewardCurrency;
  final List<QuestTaskHiveModel> tasks;
  final List<QuestMilestoneHiveModel> milestones;
  final DateTime? deadline;
  final int statusIndex;
  final double progressPercentage;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int requiredLevel;

  QuestHiveModel({
    required this.id,
    required this.title,
    this.description,
    required this.typeIndex,
    required this.categoryIndex,
    required this.difficulty,
    required this.rewardExperience,
    required this.rewardCurrency,
    required this.tasks,
    required this.milestones,
    this.deadline,
    required this.statusIndex,
    required this.progressPercentage,
    required this.createdAt,
    this.completedAt,
    this.requiredLevel = 1,
  });

  Quest toDomain() {
    final type = QuestType.values[typeIndex.clamp(0, QuestType.values.length - 1)];
    final category = QuestCategory.values[categoryIndex.clamp(0, QuestCategory.values.length - 1)];
    final status = QuestStatus.values[statusIndex.clamp(0, QuestStatus.values.length - 1)];

    return Quest(
      id: id,
      title: title,
      description: description,
      type: type,
      category: category,
      difficulty: difficulty,
      reward: QuestReward(experience: rewardExperience, currency: rewardCurrency),
      tasks: tasks.map((t) => t.toDomain()).toList(growable: false),
      milestones: milestones.map((m) => m.toDomain()).toList(growable: false),
      deadline: deadline,
      status: status,
      progressPercentage: progressPercentage,
      createdAt: createdAt,
      completedAt: completedAt,
      requiredLevel: requiredLevel,
    );
  }

  static QuestHiveModel fromDomain(Quest quest) {
    return QuestHiveModel(
      id: quest.id,
      title: quest.title,
      description: quest.description,
      typeIndex: quest.type.index,
      categoryIndex: quest.category.index,
      difficulty: quest.difficulty,
      rewardExperience: quest.reward.experience,
      rewardCurrency: quest.reward.currency,
      tasks: quest.tasks.map(QuestTaskHiveModel.fromDomain).toList(growable: false),
      milestones: quest.milestones.map(QuestMilestoneHiveModel.fromDomain).toList(growable: false),
      deadline: quest.deadline,
      statusIndex: quest.status.index,
      progressPercentage: quest.progressPercentage,
      createdAt: quest.createdAt,
      completedAt: quest.completedAt,
    );
  }
}

class QuestTaskHiveModel {
  final String id;
  final String questId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final int orderIndex;

  QuestTaskHiveModel({
    required this.id,
    required this.questId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.completedAt,
    required this.orderIndex,
  });

  QuestTask toDomain() => QuestTask(
        id: id,
        questId: questId,
        title: title,
        description: description,
        isCompleted: isCompleted,
        completedAt: completedAt,
        orderIndex: orderIndex,
      );

  static QuestTaskHiveModel fromDomain(QuestTask task) => QuestTaskHiveModel(
        id: task.id,
        questId: task.questId,
        title: task.title,
        description: task.description,
        isCompleted: task.isCompleted,
        completedAt: task.completedAt,
        orderIndex: task.orderIndex,
      );
}

class QuestMilestoneHiveModel {
  final String id;
  final String questId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final int rewardExperience;
  final int rewardCurrency;
  final int orderIndex;

  QuestMilestoneHiveModel({
    required this.id,
    required this.questId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.completedAt,
    required this.rewardExperience,
    required this.rewardCurrency,
    required this.orderIndex,
  });

  QuestMilestone toDomain() => QuestMilestone(
        id: id,
        questId: questId,
        title: title,
        description: description,
        isCompleted: isCompleted,
        completedAt: completedAt,
        reward: QuestReward(experience: rewardExperience, currency: rewardCurrency),
        orderIndex: orderIndex,
      );

  static QuestMilestoneHiveModel fromDomain(QuestMilestone milestone) => QuestMilestoneHiveModel(
        id: milestone.id,
        questId: milestone.questId,
        title: milestone.title,
        description: milestone.description,
        isCompleted: milestone.isCompleted,
        completedAt: milestone.completedAt,
        rewardExperience: milestone.reward.experience,
        rewardCurrency: milestone.reward.currency,
        orderIndex: milestone.orderIndex,
      );
}

/// Adapter type IDs must be unique across the app.
const int _questTypeId = 1;
const int _questTaskTypeId = 2;
const int _questMilestoneTypeId = 3;

class QuestHiveModelAdapter extends TypeAdapter<QuestHiveModel> {
  @override
  final int typeId = _questTypeId;

  @override
  QuestHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return QuestHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      typeIndex: fields[3] as int,
      categoryIndex: fields[4] as int,
      difficulty: fields[5] as int,
      rewardExperience: fields[6] as int,
      rewardCurrency: fields[7] as int,
      tasks: (fields[8] as List).cast<QuestTaskHiveModel>(),
      milestones: (fields[9] as List).cast<QuestMilestoneHiveModel>(),
      deadline: fields[10] as DateTime?,
      statusIndex: fields[11] as int,
      progressPercentage: fields[12] as double,
      createdAt: fields[13] as DateTime,
      completedAt: fields[14] as DateTime?,
      requiredLevel: fields[15] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, QuestHiveModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.typeIndex)
      ..writeByte(4)
      ..write(obj.categoryIndex)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.rewardExperience)
      ..writeByte(7)
      ..write(obj.rewardCurrency)
      ..writeByte(8)
      ..write(obj.tasks)
      ..writeByte(9)
      ..write(obj.milestones)
      ..writeByte(10)
      ..write(obj.deadline)
      ..writeByte(11)
      ..write(obj.statusIndex)
      ..writeByte(12)
      ..write(obj.progressPercentage)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.completedAt)
      ..writeByte(15)
      ..write(obj.requiredLevel);
  }
}

class QuestTaskHiveModelAdapter extends TypeAdapter<QuestTaskHiveModel> {
  @override
  final int typeId = _questTaskTypeId;

  @override
  QuestTaskHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return QuestTaskHiveModel(
      id: fields[0] as String,
      questId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String?,
      isCompleted: fields[4] as bool,
      completedAt: fields[5] as DateTime?,
      orderIndex: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuestTaskHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.questId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.orderIndex);
  }
}

class QuestMilestoneHiveModelAdapter extends TypeAdapter<QuestMilestoneHiveModel> {
  @override
  final int typeId = _questMilestoneTypeId;

  @override
  QuestMilestoneHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return QuestMilestoneHiveModel(
      id: fields[0] as String,
      questId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String?,
      isCompleted: fields[4] as bool,
      completedAt: fields[5] as DateTime?,
      rewardExperience: fields[6] as int,
      rewardCurrency: fields[7] as int,
      orderIndex: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuestMilestoneHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.questId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.rewardExperience)
      ..writeByte(7)
      ..write(obj.rewardCurrency)
      ..writeByte(8)
      ..write(obj.orderIndex);
  }
}


