import 'package:hive/hive.dart';

import '../../domain/entities/skill.dart';

/// Hive model for storing a Skill locally
class SkillHiveModel {
  final String id;
  final String name;
  final String description;
  final int typeIndex;
  final int level;
  final int experience;
  final int skillPoints;
  final int maxLevel;
  final List<String> prerequisites;
  final DateTime? unlockedAt;
  final DateTime? lastLevelUpAt;

  SkillHiveModel({
    required this.id,
    required this.name,
    required this.description,
    required this.typeIndex,
    required this.level,
    required this.experience,
    required this.skillPoints,
    this.maxLevel = 100,
    this.prerequisites = const [],
    this.unlockedAt,
    this.lastLevelUpAt,
  });

  Skill toDomain() {
    final type = SkillType.values[typeIndex.clamp(0, SkillType.values.length - 1)];
    return Skill(
      id: id,
      name: name,
      description: description,
      type: type,
      level: level,
      experience: experience,
      skillPoints: skillPoints,
      maxLevel: maxLevel,
      prerequisites: prerequisites,
      unlockedAt: unlockedAt,
      lastLevelUpAt: lastLevelUpAt,
    );
  }

  static SkillHiveModel fromDomain(Skill skill) {
    return SkillHiveModel(
      id: skill.id,
      name: skill.name,
      description: skill.description,
      typeIndex: skill.type.index,
      level: skill.level,
      experience: skill.experience,
      skillPoints: skill.skillPoints,
      maxLevel: skill.maxLevel,
      prerequisites: skill.prerequisites,
      unlockedAt: skill.unlockedAt,
      lastLevelUpAt: skill.lastLevelUpAt,
    );
  }
}

/// TypeAdapter for SkillHiveModel
class SkillHiveModelAdapter extends TypeAdapter<SkillHiveModel> {
  @override
  final int typeId = 10; // Unique type ID

  @override
  SkillHiveModel read(BinaryReader reader) {
    final hasUnlockedAt = reader.readBool();
    final hasLastLevelUpAt = reader.readBool();
    
    return SkillHiveModel(
      id: reader.readString(),
      name: reader.readString(),
      description: reader.readString(),
      typeIndex: reader.readInt(),
      level: reader.readInt(),
      experience: reader.readInt(),
      skillPoints: reader.readInt(),
      maxLevel: reader.readInt(),
      prerequisites: List<String>.from(reader.readStringList()),
      unlockedAt: hasUnlockedAt ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
      lastLevelUpAt: hasLastLevelUpAt ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
    );
  }

  @override
  void write(BinaryWriter writer, SkillHiveModel obj) {
    writer.writeBool(obj.unlockedAt != null);
    writer.writeBool(obj.lastLevelUpAt != null);
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeInt(obj.typeIndex);
    writer.writeInt(obj.level);
    writer.writeInt(obj.experience);
    writer.writeInt(obj.skillPoints);
    writer.writeInt(obj.maxLevel);
    writer.writeStringList(obj.prerequisites);
    if (obj.unlockedAt != null) {
      writer.writeInt(obj.unlockedAt!.millisecondsSinceEpoch);
    }
    if (obj.lastLevelUpAt != null) {
      writer.writeInt(obj.lastLevelUpAt!.millisecondsSinceEpoch);
    }
  }
}

