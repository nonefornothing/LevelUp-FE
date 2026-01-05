import 'package:equatable/equatable.dart';

import '../../../../domain/entities/friend.dart';

/// States for Social BLoC
abstract class SocialState extends Equatable {
  const SocialState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SocialInitial extends SocialState {
  const SocialInitial();
}

/// Loading state
class SocialLoading extends SocialState {
  const SocialLoading();
}

/// Friends loaded state
class FriendsLoaded extends SocialState {
  final List<Friend> friends;
  final List<FriendRequest> friendRequests;
  final List<SharedQuest> sharedQuests;

  const FriendsLoaded({
    required this.friends,
    required this.friendRequests,
    required this.sharedQuests,
  });

  @override
  List<Object?> get props => [friends, friendRequests, sharedQuests];
}

/// Error state
class SocialError extends SocialState {
  final String message;

  const SocialError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Progress comparison state
class ProgressComparisonLoaded extends SocialState {
  final Map<String, dynamic> comparison;

  const ProgressComparisonLoaded(this.comparison);

  @override
  List<Object?> get props => [comparison];
}



