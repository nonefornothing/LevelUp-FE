import '../../core/utils/result.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/repositories/social_repository.dart';

/// Service for managing social features
class SocialService {
  final SocialRepository _repository;
  final PlayerRepository _playerRepository;

  SocialService(this._repository, this._playerRepository);

  /// Get all friends
  Future<Result<List<Friend>>> getFriends() {
    return _repository.getFriends();
  }

  /// Get friend by ID
  Future<Result<Friend?>> getFriendById(String friendId) {
    return _repository.getFriendById(friendId);
  }

  /// Add a friend by username (for offline demo)
  Future<Result<Friend>> addFriendByUsername(String username) async {
    return _repository.addFriend(username: username);
  }

  /// Remove a friend
  Future<Result<void>> removeFriend(String friendId) {
    return _repository.removeFriend(friendId);
  }

  /// Get friend requests
  Future<Result<List<FriendRequest>>> getFriendRequests() {
    return _repository.getFriendRequests();
  }

  /// Send a friend request
  Future<Result<FriendRequest>> sendFriendRequest({
    required String toUserId,
    required String toUsername,
  }) {
    return _repository.sendFriendRequest(
      toUserId: toUserId,
      toUsername: toUsername,
    );
  }

  /// Accept a friend request
  Future<Result<Friend>> acceptFriendRequest(String requestId) {
    return _repository.acceptFriendRequest(requestId);
  }

  /// Reject a friend request
  Future<Result<void>> rejectFriendRequest(String requestId) {
    return _repository.rejectFriendRequest(requestId);
  }

  /// Get shared quests
  Future<Result<List<SharedQuest>>> getSharedQuests() {
    return _repository.getSharedQuests();
  }

  /// Share a quest with a friend
  Future<Result<SharedQuest>> shareQuestWithFriend({
    required String questId,
    required String questTitle,
    required String friendId,
  }) {
    return _repository.shareQuest(
      questId: questId,
      questTitle: questTitle,
      toUserId: friendId,
    );
  }

  /// Accept a shared quest
  Future<Result<void>> acceptSharedQuest(String sharedQuestId) {
    return _repository.acceptSharedQuest(sharedQuestId);
  }

  /// Get friend progress comparison
  Future<Result<Map<String, dynamic>>> compareProgressWithFriend(
    String friendId,
  ) async {
    final friendProgressResult = await _repository.getFriendProgress(friendId);
    if (friendProgressResult is ResultError) {
      return friendProgressResult;
    }

    final friendProgress = (friendProgressResult as Success<Map<String, dynamic>>).data;
    
    // Get current player stats
    final playerResult = await _playerRepository.getPlayer();
    if (playerResult is ResultError) {
      return friendProgressResult; // Return friend progress only
    }

    final player = (playerResult as Success).data;
    final playerStats = player.stats;

    // Add player comparison
    friendProgress['player'] = {
      'level': player.level,
      'totalQuestsCompleted': playerStats.totalQuestsCompleted,
      'currentStreak': playerStats.currentStreak,
    };

    return Success(friendProgress);
  }

  /// Initialize demo friends (for offline testing)
  Future<void> initializeDemoFriends() async {
    final friendsResult = await getFriends();
    if (friendsResult is Success<List<Friend>>) {
      final friends = friendsResult.data;
      if (friends.isEmpty) {
        // Add some demo friends
        await addFriendByUsername('QuestMaster');
        await addFriendByUsername('LevelUpPro');
        await addFriendByUsername('StreakKing');
      }
    }
  }
}

