import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_template.dart';

/// Hive model for QuestTemplate
@HiveType(typeId: 15)
class QuestTemplateHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int typeIndex; // QuestType enum index

  @HiveField(4)
  int categoryIndex; // QuestCategory enum index

  @HiveField(5)
  int difficulty;

  @HiveField(6)
  int experience;

  @HiveField(7)
  int currency;

  @HiveField(8)
  List<QuestTemplateTaskHiveModel> tasks;

  @HiveField(9)
  List<QuestTemplateMilestoneHiveModel> milestones;

  @HiveField(10)
  int? estimatedDurationDays;

  @HiveField(11)
  int requiredLevel;

  @HiveField(12)
  String? iconName;

  @HiveField(13)
  List<String> tags;

  @HiveField(14)
  bool isFeatured;

  @HiveField(15)
  int createdAtMillis;

  QuestTemplateHiveModel({
    required this.id,
    required this.title,
    this.description,
    required this.typeIndex,
    required this.categoryIndex,
    required this.difficulty,
    required this.experience,
    required this.currency,
    required this.tasks,
    required this.milestones,
    this.estimatedDurationDays,
    this.requiredLevel = 1,
    this.iconName,
    this.tags = const [],
    this.isFeatured = false,
    required this.createdAtMillis,
  });

  factory QuestTemplateHiveModel.fromDomain(QuestTemplate template) {
    return QuestTemplateHiveModel(
      id: template.id,
      title: template.title,
      description: template.description,
      typeIndex: template.type.index,
      categoryIndex: template.category.index,
      difficulty: template.difficulty,
      experience: template.reward.experience,
      currency: template.reward.currency,
      tasks: template.tasks
          .map((t) => QuestTemplateTaskHiveModel.fromDomain(t))
          .toList(),
      milestones: template.milestones
          .map((m) => QuestTemplateMilestoneHiveModel.fromDomain(m))
          .toList(),
      estimatedDurationDays: template.estimatedDurationDays,
      requiredLevel: template.requiredLevel,
      iconName: template.iconName,
      tags: template.tags,
      isFeatured: template.isFeatured,
      createdAtMillis: template.createdAt.millisecondsSinceEpoch,
    );
  }

  QuestTemplate toDomain() {
    return QuestTemplate(
      id: id,
      title: title,
      description: description ?? '',
      type: QuestType.values[typeIndex],
      category: QuestCategory.values[categoryIndex],
      difficulty: difficulty,
      reward: QuestReward(
        experience: experience,
        currency: currency,
      ),
      tasks: tasks.map((t) => t.toDomain()).toList(),
      milestones: milestones.map((m) => m.toDomain()).toList(),
      estimatedDurationDays: estimatedDurationDays,
      requiredLevel: requiredLevel,
      iconName: iconName,
      tags: tags,
      isFeatured: isFeatured,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    );
  }
}

/// Hive model for QuestTemplateTask
@HiveType(typeId: 16)
class QuestTemplateTaskHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int orderIndex;

  QuestTemplateTaskHiveModel({
    required this.id,
    required this.title,
    this.description,
    required this.orderIndex,
  });

  factory QuestTemplateTaskHiveModel.fromDomain(QuestTemplateTask task) {
    return QuestTemplateTaskHiveModel(
      id: task.id,
      title: task.title,
      description: task.description,
      orderIndex: task.orderIndex,
    );
  }

  QuestTemplateTask toDomain() {
    return QuestTemplateTask(
      id: id,
      title: title,
      description: description,
      orderIndex: orderIndex,
    );
  }
}

/// Hive model for QuestTemplateMilestone
@HiveType(typeId: 17)
class QuestTemplateMilestoneHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int experience;

  @HiveField(4)
  int currency;

  @HiveField(5)
  int orderIndex;

  QuestTemplateMilestoneHiveModel({
    required this.id,
    required this.title,
    this.description,
    required this.experience,
    required this.currency,
    required this.orderIndex,
  });

  factory QuestTemplateMilestoneHiveModel.fromDomain(
    QuestTemplateMilestone milestone,
  ) {
    return QuestTemplateMilestoneHiveModel(
      id: milestone.id,
      title: milestone.title,
      description: milestone.description,
      experience: milestone.reward.experience,
      currency: milestone.reward.currency,
      orderIndex: milestone.orderIndex,
    );
  }

  QuestTemplateMilestone toDomain() {
    return QuestTemplateMilestone(
      id: id,
      title: title,
      description: description,
      reward: QuestReward(
        experience: experience,
        currency: currency,
      ),
      orderIndex: orderIndex,
    );
  }
}

/// Type adapters
class QuestTemplateHiveModelAdapter
    extends TypeAdapter<QuestTemplateHiveModel> {
  @override
  final int typeId = 15;

  @override
  QuestTemplateHiveModel read(BinaryReader reader) {
    return QuestTemplateHiveModel(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readStringOrNull(),
      typeIndex: reader.readInt(),
      categoryIndex: reader.readInt(),
      difficulty: reader.readInt(),
      experience: reader.readInt(),
      currency: reader.readInt(),
      tasks: reader.readList().cast<QuestTemplateTaskHiveModel>(),
      milestones: reader.readList().cast<QuestTemplateMilestoneHiveModel>(),
      estimatedDurationDays: reader.readIntOrNull(),
      requiredLevel: reader.readInt(),
      iconName: reader.readStringOrNull(),
      tags: reader.readList().cast<String>(),
      isFeatured: reader.readBool(),
      createdAtMillis: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestTemplateHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeStringOrNull(obj.description);
    writer.writeInt(obj.typeIndex);
    writer.writeInt(obj.categoryIndex);
    writer.writeInt(obj.difficulty);
    writer.writeInt(obj.experience);
    writer.writeInt(obj.currency);
    writer.writeList(obj.tasks);
    writer.writeList(obj.milestones);
    writer.writeIntOrNull(obj.estimatedDurationDays);
    writer.writeInt(obj.requiredLevel);
    writer.writeStringOrNull(obj.iconName);
    writer.writeList(obj.tags);
    writer.writeBool(obj.isFeatured);
    writer.writeInt(obj.createdAtMillis);
  }
}

class QuestTemplateTaskHiveModelAdapter
    extends TypeAdapter<QuestTemplateTaskHiveModel> {
  @override
  final int typeId = 16;

  @override
  QuestTemplateTaskHiveModel read(BinaryReader reader) {
    return QuestTemplateTaskHiveModel(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readStringOrNull(),
      orderIndex: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestTemplateTaskHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeStringOrNull(obj.description);
    writer.writeInt(obj.orderIndex);
  }
}

class QuestTemplateMilestoneHiveModelAdapter
    extends TypeAdapter<QuestTemplateMilestoneHiveModel> {
  @override
  final int typeId = 17;

  @override
  QuestTemplateMilestoneHiveModel read(BinaryReader reader) {
    return QuestTemplateMilestoneHiveModel(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readStringOrNull(),
      experience: reader.readInt(),
      currency: reader.readInt(),
      orderIndex: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestTemplateMilestoneHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeStringOrNull(obj.description);
    writer.writeInt(obj.experience);
    writer.writeInt(obj.currency);
    writer.writeInt(obj.orderIndex);
  }
}


