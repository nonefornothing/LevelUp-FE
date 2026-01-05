import '../entities/friend.dart';
import '../../core/utils/result.dart';

/// Repository interface for social features
abstract class SocialRepository {
  /// Get all friends
  Future<Result<List<Friend>>> getFriends();

  /// Get friend by ID
  Future<Result<Friend?>> getFriendById(String friendId);

  /// Add a friend (for offline demo, we'll create a mock friend)
  Future<Result<Friend>> addFriend({
    required String username,
    String? displayName,
  });

  /// Remove a friend
  Future<Result<void>> removeFriend(String friendId);

  /// Get friend requests (sent and received)
  Future<Result<List<FriendRequest>>> getFriendRequests();

  /// Send a friend request
  Future<Result<FriendRequest>> sendFriendRequest({
    required String toUserId,
    required String toUsername,
  });

  /// Accept a friend request
  Future<Result<Friend>> acceptFriendRequest(String requestId);

  /// Reject a friend request
  Future<Result<void>> rejectFriendRequest(String requestId);

  /// Get shared quests (received)
  Future<Result<List<SharedQuest>>> getSharedQuests();

  /// Share a quest with a friend
  Future<Result<SharedQuest>> shareQuest({
    required String questId,
    required String questTitle,
    required String toUserId,
  });

  /// Accept a shared quest
  Future<Result<void>> acceptSharedQuest(String sharedQuestId);

  /// Get friend's progress comparison
  Future<Result<Map<String, dynamic>>> getFriendProgress(String friendId);
}



