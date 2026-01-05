import 'package:equatable/equatable.dart';

/// Events for Social BLoC
abstract class SocialEvent extends Equatable {
  const SocialEvent();

  @override
  List<Object?> get props => [];
}

/// Load friends list
class LoadFriends extends SocialEvent {
  const LoadFriends();
}

/// Refresh friends list
class RefreshFriends extends SocialEvent {
  const RefreshFriends();
}

/// Add a friend by username
class AddFriend extends SocialEvent {
  final String username;

  const AddFriend(this.username);

  @override
  List<Object?> get props => [username];
}

/// Remove a friend
class RemoveFriend extends SocialEvent {
  final String friendId;

  const RemoveFriend(this.friendId);

  @override
  List<Object?> get props => [friendId];
}

/// Load friend requests
class LoadFriendRequests extends SocialEvent {
  const LoadFriendRequests();
}

/// Send a friend request
class SendFriendRequest extends SocialEvent {
  final String toUserId;
  final String toUsername;

  const SendFriendRequest({
    required this.toUserId,
    required this.toUsername,
  });

  @override
  List<Object?> get props => [toUserId, toUsername];
}

/// Accept a friend request
class AcceptFriendRequest extends SocialEvent {
  final String requestId;

  const AcceptFriendRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Reject a friend request
class RejectFriendRequest extends SocialEvent {
  final String requestId;

  const RejectFriendRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Load shared quests
class LoadSharedQuests extends SocialEvent {
  const LoadSharedQuests();
}

/// Share a quest with a friend
class ShareQuest extends SocialEvent {
  final String questId;
  final String questTitle;
  final String friendId;

  const ShareQuest({
    required this.questId,
    required this.questTitle,
    required this.friendId,
  });

  @override
  List<Object?> get props => [questId, questTitle, friendId];
}

/// Accept a shared quest
class AcceptSharedQuest extends SocialEvent {
  final String sharedQuestId;

  const AcceptSharedQuest(this.sharedQuestId);

  @override
  List<Object?> get props => [sharedQuestId];
}

/// Compare progress with a friend
class CompareProgressWithFriend extends SocialEvent {
  final String friendId;

  const CompareProgressWithFriend(this.friendId);

  @override
  List<Object?> get props => [friendId];
}

