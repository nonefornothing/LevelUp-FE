import 'package:hive/hive.dart';

import '../../domain/entities/friend.dart';

/// Hive model for storing Friend locally
class FriendHiveModel {
  final String id;
  final String username;
  final String? displayName;
  final int level;
  final int totalQuestsCompleted;
  final int currentStreak;
  final int? lastActiveMillis;
  final int addedAtMillis;
  final bool isOnline;

  FriendHiveModel({
    required this.id,
    required this.username,
    this.displayName,
    required this.level,
    required this.totalQuestsCompleted,
    required this.currentStreak,
    this.lastActiveMillis,
    required this.addedAtMillis,
    this.isOnline = false,
  });

  factory FriendHiveModel.fromEntity(Friend friend) {
    return FriendHiveModel(
      id: friend.id,
      username: friend.username,
      displayName: friend.displayName,
      level: friend.level,
      totalQuestsCompleted: friend.totalQuestsCompleted,
      currentStreak: friend.currentStreak,
      lastActiveMillis: friend.lastActive?.millisecondsSinceEpoch,
      addedAtMillis: friend.addedAt.millisecondsSinceEpoch,
      isOnline: friend.isOnline,
    );
  }

  Friend toEntity() {
    return Friend(
      id: id,
      username: username,
      displayName: displayName,
      level: level,
      totalQuestsCompleted: totalQuestsCompleted,
      currentStreak: currentStreak,
      lastActive: lastActiveMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(lastActiveMillis!)
          : null,
      addedAt: DateTime.fromMillisecondsSinceEpoch(addedAtMillis),
      isOnline: isOnline,
    );
  }
}

/// Hive model for storing FriendRequest locally
class FriendRequestHiveModel {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final int sentAtMillis;
  final int statusIndex;

  FriendRequestHiveModel({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.sentAtMillis,
    required this.statusIndex,
  });

  factory FriendRequestHiveModel.fromEntity(FriendRequest request) {
    return FriendRequestHiveModel(
      id: request.id,
      fromUserId: request.fromUserId,
      fromUsername: request.fromUsername,
      toUserId: request.toUserId,
      sentAtMillis: request.sentAt.millisecondsSinceEpoch,
      statusIndex: request.status.index,
    );
  }

  FriendRequest toEntity() {
    return FriendRequest(
      id: id,
      fromUserId: fromUserId,
      fromUsername: fromUsername,
      toUserId: toUserId,
      sentAt: DateTime.fromMillisecondsSinceEpoch(sentAtMillis),
      status: FriendRequestStatus.values[statusIndex],
    );
  }
}

/// Hive model for storing SharedQuest locally
class SharedQuestHiveModel {
  final String id;
  final String questId;
  final String questTitle;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final int sharedAtMillis;
  final bool isAccepted;
  final int? acceptedAtMillis;

  SharedQuestHiveModel({
    required this.id,
    required this.questId,
    required this.questTitle,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.sharedAtMillis,
    this.isAccepted = false,
    this.acceptedAtMillis,
  });

  factory SharedQuestHiveModel.fromEntity(SharedQuest sharedQuest) {
    return SharedQuestHiveModel(
      id: sharedQuest.id,
      questId: sharedQuest.questId,
      questTitle: sharedQuest.questTitle,
      fromUserId: sharedQuest.fromUserId,
      fromUsername: sharedQuest.fromUsername,
      toUserId: sharedQuest.toUserId,
      sharedAtMillis: sharedQuest.sharedAt.millisecondsSinceEpoch,
      isAccepted: sharedQuest.isAccepted,
      acceptedAtMillis: sharedQuest.acceptedAt?.millisecondsSinceEpoch,
    );
  }

  SharedQuest toEntity() {
    return SharedQuest(
      id: id,
      questId: questId,
      questTitle: questTitle,
      fromUserId: fromUserId,
      fromUsername: fromUsername,
      toUserId: toUserId,
      sharedAt: DateTime.fromMillisecondsSinceEpoch(sharedAtMillis),
      isAccepted: isAccepted,
      acceptedAt: acceptedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(acceptedAtMillis!)
          : null,
    );
  }
}

// TypeAdapters
const int _friendTypeId = 10;
const int _friendRequestTypeId = 11;
const int _sharedQuestTypeId = 12;

class FriendHiveModelAdapter extends TypeAdapter<FriendHiveModel> {
  @override
  final int typeId = _friendTypeId;

  @override
  FriendHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return FriendHiveModel(
      id: fields[0] as String,
      username: fields[1] as String,
      displayName: fields[2] as String?,
      level: fields[3] as int,
      totalQuestsCompleted: fields[4] as int,
      currentStreak: fields[5] as int,
      lastActiveMillis: fields[6] as int?,
      addedAtMillis: fields[7] as int,
      isOnline: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FriendHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.totalQuestsCompleted)
      ..writeByte(5)
      ..write(obj.currentStreak)
      ..writeByte(6)
      ..write(obj.lastActiveMillis)
      ..writeByte(7)
      ..write(obj.addedAtMillis)
      ..writeByte(8)
      ..write(obj.isOnline);
  }
}

class FriendRequestHiveModelAdapter extends TypeAdapter<FriendRequestHiveModel> {
  @override
  final int typeId = _friendRequestTypeId;

  @override
  FriendRequestHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return FriendRequestHiveModel(
      id: fields[0] as String,
      fromUserId: fields[1] as String,
      fromUsername: fields[2] as String,
      toUserId: fields[3] as String,
      sentAtMillis: fields[4] as int,
      statusIndex: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FriendRequestHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromUserId)
      ..writeByte(2)
      ..write(obj.fromUsername)
      ..writeByte(3)
      ..write(obj.toUserId)
      ..writeByte(4)
      ..write(obj.sentAtMillis)
      ..writeByte(5)
      ..write(obj.statusIndex);
  }
}

class SharedQuestHiveModelAdapter extends TypeAdapter<SharedQuestHiveModel> {
  @override
  final int typeId = _sharedQuestTypeId;

  @override
  SharedQuestHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return SharedQuestHiveModel(
      id: fields[0] as String,
      questId: fields[1] as String,
      questTitle: fields[2] as String,
      fromUserId: fields[3] as String,
      fromUsername: fields[4] as String,
      toUserId: fields[5] as String,
      sharedAtMillis: fields[6] as int,
      isAccepted: fields[7] as bool,
      acceptedAtMillis: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SharedQuestHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.questId)
      ..writeByte(2)
      ..write(obj.questTitle)
      ..writeByte(3)
      ..write(obj.fromUserId)
      ..writeByte(4)
      ..write(obj.fromUsername)
      ..writeByte(5)
      ..write(obj.toUserId)
      ..writeByte(6)
      ..write(obj.sharedAtMillis)
      ..writeByte(7)
      ..write(obj.isAccepted)
      ..writeByte(8)
      ..write(obj.acceptedAtMillis);
  }
}

