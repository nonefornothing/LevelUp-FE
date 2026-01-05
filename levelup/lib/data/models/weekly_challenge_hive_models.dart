import 'package:hive/hive.dart';

import '../../domain/entities/weekly_challenge.dart';
import '../../domain/entities/quest.dart';

/// Hive model for storing a WeeklyChallenge locally.
class WeeklyChallengeHiveModel {
  final String id;
  final String title;
  final String? description;
  final int typeIndex;
  final int targetValue;
  final int currentProgress;
  final int rewardExperience;
  final int rewardCurrency;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final int statusIndex;
  final DateTime createdAt;
  final DateTime? completedAt;

  WeeklyChallengeHiveModel({
    required this.id,
    required this.title,
    this.description,
    required this.typeIndex,
    required this.targetValue,
    required this.currentProgress,
    required this.rewardExperience,
    required this.rewardCurrency,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.statusIndex,
    required this.createdAt,
    this.completedAt,
  });

  WeeklyChallenge toDomain() {
    final type = WeeklyChallengeType.values[typeIndex.clamp(0, WeeklyChallengeType.values.length - 1)];
    final status = WeeklyChallengeStatus.values[statusIndex.clamp(0, WeeklyChallengeStatus.values.length - 1)];

    return WeeklyChallenge(
      id: id,
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      currentProgress: currentProgress,
      reward: QuestReward(experience: rewardExperience, currency: rewardCurrency),
      weekStartDate: weekStartDate,
      weekEndDate: weekEndDate,
      status: status,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  static WeeklyChallengeHiveModel fromDomain(WeeklyChallenge challenge) {
    return WeeklyChallengeHiveModel(
      id: challenge.id,
      title: challenge.title,
      description: challenge.description,
      typeIndex: challenge.type.index,
      targetValue: challenge.targetValue,
      currentProgress: challenge.currentProgress,
      rewardExperience: challenge.reward.experience,
      rewardCurrency: challenge.reward.currency,
      weekStartDate: challenge.weekStartDate,
      weekEndDate: challenge.weekEndDate,
      statusIndex: challenge.status.index,
      createdAt: challenge.createdAt,
      completedAt: challenge.completedAt,
    );
  }
}

/// Adapter type IDs must be unique across the app.
const int _weeklyChallengeTypeId = 4;

class WeeklyChallengeHiveModelAdapter extends TypeAdapter<WeeklyChallengeHiveModel> {
  @override
  final int typeId = _weeklyChallengeTypeId;

  @override
  WeeklyChallengeHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return WeeklyChallengeHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      typeIndex: fields[3] as int,
      targetValue: fields[4] as int,
      currentProgress: fields[5] as int,
      rewardExperience: fields[6] as int,
      rewardCurrency: fields[7] as int,
      weekStartDate: fields[8] as DateTime,
      weekEndDate: fields[9] as DateTime,
      statusIndex: fields[10] as int,
      createdAt: fields[11] as DateTime,
      completedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyChallengeHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.typeIndex)
      ..writeByte(4)
      ..write(obj.targetValue)
      ..writeByte(5)
      ..write(obj.currentProgress)
      ..writeByte(6)
      ..write(obj.rewardExperience)
      ..writeByte(7)
      ..write(obj.rewardCurrency)
      ..writeByte(8)
      ..write(obj.weekStartDate)
      ..writeByte(9)
      ..write(obj.weekEndDate)
      ..writeByte(10)
      ..write(obj.statusIndex)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.completedAt);
  }
}




