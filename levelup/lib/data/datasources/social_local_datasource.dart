import 'package:hive/hive.dart';

import '../../domain/entities/friend.dart';
import '../models/friend_hive_models.dart';

/// Local data source for social features
class SocialLocalDataSource {
  static const String _friendsBoxName = 'friends';
  static const String _friendRequestsBoxName = 'friend_requests';
  static const String _sharedQuestsBoxName = 'shared_quests';

  Future<Box<FriendHiveModel>> get _friendsBox async =>
      await Hive.openBox<FriendHiveModel>(_friendsBoxName);

  Future<Box<FriendRequestHiveModel>> get _friendRequestsBox async =>
      await Hive.openBox<FriendRequestHiveModel>(_friendRequestsBoxName);

  Future<Box<SharedQuestHiveModel>> get _sharedQuestsBox async =>
      await Hive.openBox<SharedQuestHiveModel>(_sharedQuestsBoxName);

  /// Get all friends
  Future<List<Friend>> getFriends() async {
    final box = await _friendsBox;
    return box.values.map((model) => model.toEntity()).toList();
  }

  /// Get friend by ID
  Future<Friend?> getFriendById(String friendId) async {
    final box = await _friendsBox;
    final model = box.get(friendId);
    return model?.toEntity();
  }

  /// Add a friend
  Future<Friend> addFriend(Friend friend) async {
    final box = await _friendsBox;
    final model = FriendHiveModel.fromEntity(friend);
    await box.put(friend.id, model);
    return friend;
  }

  /// Remove a friend
  Future<void> removeFriend(String friendId) async {
    final box = await _friendsBox;
    await box.delete(friendId);
  }

  /// Get all friend requests
  Future<List<FriendRequest>> getFriendRequests() async {
    final box = await _friendRequestsBox;
    return box.values.map((model) => model.toEntity()).toList();
  }

  /// Save a friend request
  Future<FriendRequest> saveFriendRequest(FriendRequest request) async {
    final box = await _friendRequestsBox;
    final model = FriendRequestHiveModel.fromEntity(request);
    await box.put(request.id, model);
    return request;
  }

  /// Update friend request status
  Future<void> updateFriendRequestStatus(
    String requestId,
    FriendRequestStatus status,
  ) async {
    final box = await _friendRequestsBox;
    final model = box.get(requestId);
    if (model != null) {
      final updatedModel = FriendRequestHiveModel(
        id: model.id,
        fromUserId: model.fromUserId,
        fromUsername: model.fromUsername,
        toUserId: model.toUserId,
        sentAtMillis: model.sentAtMillis,
        statusIndex: status.index,
      );
      await box.put(requestId, updatedModel);
    }
  }

  /// Delete a friend request
  Future<void> deleteFriendRequest(String requestId) async {
    final box = await _friendRequestsBox;
    await box.delete(requestId);
  }

  /// Get all shared quests
  Future<List<SharedQuest>> getSharedQuests() async {
    final box = await _sharedQuestsBox;
    return box.values.map((model) => model.toEntity()).toList();
  }

  /// Save a shared quest
  Future<SharedQuest> saveSharedQuest(SharedQuest sharedQuest) async {
    final box = await _sharedQuestsBox;
    final model = SharedQuestHiveModel.fromEntity(sharedQuest);
    await box.put(sharedQuest.id, model);
    return sharedQuest;
  }

  /// Update shared quest acceptance
  Future<void> updateSharedQuestAcceptance(
    String sharedQuestId,
    bool isAccepted,
  ) async {
    final box = await _sharedQuestsBox;
    final model = box.get(sharedQuestId);
    if (model != null) {
      final updatedModel = SharedQuestHiveModel(
        id: model.id,
        questId: model.questId,
        questTitle: model.questTitle,
        fromUserId: model.fromUserId,
        fromUsername: model.fromUsername,
        toUserId: model.toUserId,
        sharedAtMillis: model.sharedAtMillis,
        isAccepted: isAccepted,
        acceptedAtMillis: isAccepted ? DateTime.now().millisecondsSinceEpoch : null,
      );
      await box.put(sharedQuestId, updatedModel);
    }
  }
}



