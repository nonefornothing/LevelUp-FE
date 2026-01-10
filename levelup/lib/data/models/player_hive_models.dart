import 'package:hive/hive.dart';

import '../../domain/entities/player.dart';

class PlayerHiveModel {
  final String id;
  final String username;
  final String? email;
  final int level;
  final int experience;
  final int currency;
  final int availableSkillPoints;
  final PlayerStatsHiveModel stats;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  PlayerHiveModel({
    required this.id,
    required this.username,
    this.email,
    required this.level,
    required this.experience,
    required this.currency,
    this.availableSkillPoints = 0,
    required this.stats,
    required this.createdAt,
    this.lastActiveAt,
  });

  Player toDomain() => Player(
        id: id,
        username: username,
        email: email,
        level: level,
        experience: experience,
        currency: currency,
        availableSkillPoints: availableSkillPoints,
        stats: stats.toDomain(),
        createdAt: createdAt,
        lastActiveAt: lastActiveAt,
      );

  static PlayerHiveModel fromDomain(Player player) => PlayerHiveModel(
        id: player.id,
        username: player.username,
        email: player.email,
        level: player.level,
        experience: player.experience,
        currency: player.currency,
        availableSkillPoints: player.availableSkillPoints,
        stats: PlayerStatsHiveModel.fromDomain(player.stats),
        createdAt: player.createdAt,
        lastActiveAt: player.lastActiveAt,
      );
}

class PlayerStatsHiveModel {
  final int totalQuestsCompleted;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;

  PlayerStatsHiveModel({
    required this.totalQuestsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
  });

  PlayerStats toDomain() => PlayerStats(
        totalQuestsCompleted: totalQuestsCompleted,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastActiveDate: lastActiveDate,
      );

  static PlayerStatsHiveModel fromDomain(PlayerStats stats) => PlayerStatsHiveModel(
        totalQuestsCompleted: stats.totalQuestsCompleted,
        currentStreak: stats.currentStreak,
        longestStreak: stats.longestStreak,
        lastActiveDate: stats.lastActiveDate,
      );
}

const int _playerTypeId = 4;
const int _playerStatsTypeId = 5;

class PlayerHiveModelAdapter extends TypeAdapter<PlayerHiveModel> {
  @override
  final int typeId = _playerTypeId;

  @override
  PlayerHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return PlayerHiveModel(
      id: fields[0] as String,
      username: fields[1] as String,
      email: fields[2] as String?,
      level: fields[3] as int,
      experience: fields[4] as int,
      currency: fields[5] as int,
      availableSkillPoints: fields[9] as int? ?? 0,
      stats: fields[6] as PlayerStatsHiveModel,
      createdAt: fields[7] as DateTime,
      lastActiveAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.experience)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.stats)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastActiveAt)
      ..writeByte(9)
      ..write(obj.availableSkillPoints);
  }
}

class PlayerStatsHiveModelAdapter extends TypeAdapter<PlayerStatsHiveModel> {
  @override
  final int typeId = _playerStatsTypeId;

  @override
  PlayerStatsHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return PlayerStatsHiveModel(
      totalQuestsCompleted: fields[0] as int,
      currentStreak: fields[1] as int,
      longestStreak: fields[2] as int,
      lastActiveDate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerStatsHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalQuestsCompleted)
      ..writeByte(1)
      ..write(obj.currentStreak)
      ..writeByte(2)
      ..write(obj.longestStreak)
      ..writeByte(3)
      ..write(obj.lastActiveDate);
  }
}


