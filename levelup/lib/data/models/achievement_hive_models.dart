import 'package:hive/hive.dart';

import '../../domain/entities/achievement.dart';

/// Hive model for storing Achievement locally
class AchievementHiveModel {
  final String id;
  final String title;
  final String description;
  final int typeIndex;
  final int tierIndex;
  final int targetValue;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String iconName;

  AchievementHiveModel({
    required this.id,
    required this.title,
    required this.description,
    required this.typeIndex,
    required this.tierIndex,
    required this.targetValue,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
    required this.iconName,
  });

  Achievement toDomain() {
    final type = AchievementType.values[typeIndex.clamp(0, AchievementType.values.length - 1)];
    final tier = AchievementTier.values[tierIndex.clamp(0, AchievementTier.values.length - 1)];

    return Achievement(
      id: id,
      title: title,
      description: description,
      type: type,
      tier: tier,
      targetValue: targetValue,
      currentProgress: currentProgress,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
      iconName: iconName,
    );
  }

  static AchievementHiveModel fromDomain(Achievement achievement) {
    return AchievementHiveModel(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      typeIndex: achievement.type.index,
      tierIndex: achievement.tier.index,
      targetValue: achievement.targetValue,
      currentProgress: achievement.currentProgress,
      isUnlocked: achievement.isUnlocked,
      unlockedAt: achievement.unlockedAt,
      iconName: achievement.iconName,
    );
  }
}

const int _achievementTypeId = 6;

class AchievementHiveModelAdapter extends TypeAdapter<AchievementHiveModel> {
  @override
  final int typeId = _achievementTypeId;

  @override
  AchievementHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return AchievementHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      typeIndex: fields[3] as int,
      tierIndex: fields[4] as int,
      targetValue: fields[5] as int,
      currentProgress: fields[6] as int,
      isUnlocked: fields[7] as bool,
      unlockedAt: fields[8] as DateTime?,
      iconName: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AchievementHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.typeIndex)
      ..writeByte(4)
      ..write(obj.tierIndex)
      ..writeByte(5)
      ..write(obj.targetValue)
      ..writeByte(6)
      ..write(obj.currentProgress)
      ..writeByte(7)
      ..write(obj.isUnlocked)
      ..writeByte(8)
      ..write(obj.unlockedAt)
      ..writeByte(9)
      ..write(obj.iconName);
  }
}

