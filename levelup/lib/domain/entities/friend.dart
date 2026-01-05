/// Friend entity representing a friend in the social system
class Friend {
  final String id;
  final String username;
  final String? displayName;
  final int level;
  final int totalQuestsCompleted;
  final int currentStreak;
  final DateTime? lastActive;
  final DateTime addedAt;
  final bool isOnline;

  Friend({
    required this.id,
    required this.username,
    this.displayName,
    required this.level,
    required this.totalQuestsCompleted,
    required this.currentStreak,
    this.lastActive,
    required this.addedAt,
    this.isOnline = false,
  });

  Friend copyWith({
    String? id,
    String? username,
    String? displayName,
    int? level,
    int? totalQuestsCompleted,
    int? currentStreak,
    DateTime? lastActive,
    DateTime? addedAt,
    bool? isOnline,
  }) {
    return Friend(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
      totalQuestsCompleted: totalQuestsCompleted ?? this.totalQuestsCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActive: lastActive ?? this.lastActive,
      addedAt: addedAt ?? this.addedAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// Friend request entity
class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final DateTime sentAt;
  final FriendRequestStatus status;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.sentAt,
    this.status = FriendRequestStatus.pending,
  });

  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? fromUsername,
    String? toUserId,
    DateTime? sentAt,
    FriendRequestStatus? status,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUsername: fromUsername ?? this.fromUsername,
      toUserId: toUserId ?? this.toUserId,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
    );
  }
}

enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
}

/// Shared quest entity
class SharedQuest {
  final String id;
  final String questId;
  final String questTitle;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final DateTime sharedAt;
  final bool isAccepted;
  final DateTime? acceptedAt;

  SharedQuest({
    required this.id,
    required this.questId,
    required this.questTitle,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.sharedAt,
    this.isAccepted = false,
    this.acceptedAt,
  });

  SharedQuest copyWith({
    String? id,
    String? questId,
    String? questTitle,
    String? fromUserId,
    String? fromUsername,
    String? toUserId,
    DateTime? sharedAt,
    bool? isAccepted,
    DateTime? acceptedAt,
  }) {
    return SharedQuest(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      questTitle: questTitle ?? this.questTitle,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUsername: fromUsername ?? this.fromUsername,
      toUserId: toUserId ?? this.toUserId,
      sharedAt: sharedAt ?? this.sharedAt,
      isAccepted: isAccepted ?? this.isAccepted,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}



