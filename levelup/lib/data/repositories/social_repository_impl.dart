import '../../core/utils/result.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/social_local_datasource.dart';

/// Implementation of SocialRepository
class SocialRepositoryImpl implements SocialRepository {
  final SocialLocalDataSource _localDataSource;

  SocialRepositoryImpl(this._localDataSource);

  @override
  Future<Result<List<Friend>>> getFriends() async {
    try {
      final friends = await _localDataSource.getFriends();
      return Success(friends);
    } catch (e) {
      return ResultError('Failed to get friends: $e');
    }
  }

  @override
  Future<Result<Friend?>> getFriendById(String friendId) async {
    try {
      final friend = await _localDataSource.getFriendById(friendId);
      return Success(friend);
    } catch (e) {
      return ResultError('Failed to get friend: $e');
    }
  }

  @override
  Future<Result<Friend>> addFriend({
    required String username,
    String? displayName,
  }) async {
    try {
      // For offline demo, create a mock friend with random stats
      final friend = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        displayName: displayName,
        level: 1,
        totalQuestsCompleted: 0,
        currentStreak: 0,
        addedAt: DateTime.now(),
      );
      await _localDataSource.addFriend(friend);
      return Success(friend);
    } catch (e) {
      return ResultError('Failed to add friend: $e');
    }
  }

  @override
  Future<Result<void>> removeFriend(String friendId) async {
    try {
      await _localDataSource.removeFriend(friendId);
      return Success(null);
    } catch (e) {
      return ResultError('Failed to remove friend: $e');
    }
  }

  @override
  Future<Result<List<FriendRequest>>> getFriendRequests() async {
    try {
      final requests = await _localDataSource.getFriendRequests();
      return Success(requests);
    } catch (e) {
      return ResultError('Failed to get friend requests: $e');
    }
  }

  @override
  Future<Result<FriendRequest>> sendFriendRequest({
    required String toUserId,
    required String toUsername,
  }) async {
    try {
      // For offline demo, we'll create a mock request
      // In a real app, this would be sent to a backend
      final request = FriendRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fromUserId: 'current_user', // Would come from auth
        fromUsername: 'You', // Would come from auth
        toUserId: toUserId,
        sentAt: DateTime.now(),
      );
      await _localDataSource.saveFriendRequest(request);
      return Success(request);
    } catch (e) {
      return ResultError('Failed to send friend request: $e');
    }
  }

  @override
  Future<Result<Friend>> acceptFriendRequest(String requestId) async {
    try {
      final requests = await _localDataSource.getFriendRequests();
      final request = requests.firstWhere((r) => r.id == requestId);
      
      await _localDataSource.updateFriendRequestStatus(
        requestId,
        FriendRequestStatus.accepted,
      );

      // Create friend from request
      final friend = Friend(
        id: request.fromUserId,
        username: request.fromUsername,
        level: 1,
        totalQuestsCompleted: 0,
        currentStreak: 0,
        addedAt: DateTime.now(),
      );
      await _localDataSource.addFriend(friend);
      
      return Success(friend);
    } catch (e) {
      return ResultError('Failed to accept friend request: $e');
    }
  }

  @override
  Future<Result<void>> rejectFriendRequest(String requestId) async {
    try {
      await _localDataSource.updateFriendRequestStatus(
        requestId,
        FriendRequestStatus.rejected,
      );
      return Success(null);
    } catch (e) {
      return ResultError('Failed to reject friend request: $e');
    }
  }

  @override
  Future<Result<List<SharedQuest>>> getSharedQuests() async {
    try {
      final sharedQuests = await _localDataSource.getSharedQuests();
      return Success(sharedQuests);
    } catch (e) {
      return ResultError('Failed to get shared quests: $e');
    }
  }

  @override
  Future<Result<SharedQuest>> shareQuest({
    required String questId,
    required String questTitle,
    required String toUserId,
  }) async {
    try {
      final sharedQuest = SharedQuest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questId: questId,
        questTitle: questTitle,
        fromUserId: 'current_user', // Would come from auth
        fromUsername: 'You', // Would come from auth
        toUserId: toUserId,
        sharedAt: DateTime.now(),
      );
      await _localDataSource.saveSharedQuest(sharedQuest);
      return Success(sharedQuest);
    } catch (e) {
      return ResultError('Failed to share quest: $e');
    }
  }

  @override
  Future<Result<void>> acceptSharedQuest(String sharedQuestId) async {
    try {
      await _localDataSource.updateSharedQuestAcceptance(
        sharedQuestId,
        true,
      );
      return Success(null);
    } catch (e) {
      return ResultError('Failed to accept shared quest: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getFriendProgress(String friendId) async {
    try {
      final friend = await _localDataSource.getFriendById(friendId);
      if (friend == null) {
        return ResultError('Friend not found');
      }

      // Return comparison data
      return Success({
        'friend': {
          'level': friend.level,
          'totalQuestsCompleted': friend.totalQuestsCompleted,
          'currentStreak': friend.currentStreak,
        },
        // In a real app, we'd also get current user's stats for comparison
      });
    } catch (e) {
      return ResultError('Failed to get friend progress: $e');
    }
  }
}



