import 'package:equatable/equatable.dart';

/// Events for WeeklyChallengeBloc
abstract class WeeklyChallengeEvent extends Equatable {
  const WeeklyChallengeEvent();

  @override
  List<Object?> get props => [];
}

/// Load weekly challenges
class WeeklyChallengeLoadRequested extends WeeklyChallengeEvent {
  const WeeklyChallengeLoadRequested();
}

/// Refresh weekly challenges
class WeeklyChallengeRefreshRequested extends WeeklyChallengeEvent {
  const WeeklyChallengeRefreshRequested();
}

/// Claim challenge reward
class WeeklyChallengeClaimRewardRequested extends WeeklyChallengeEvent {
  final String challengeId;

  const WeeklyChallengeClaimRewardRequested(this.challengeId);

  @override
  List<Object?> get props => [challengeId];
}




