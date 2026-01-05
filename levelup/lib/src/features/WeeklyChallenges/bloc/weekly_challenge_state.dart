import 'package:equatable/equatable.dart';

import '../../../../domain/entities/weekly_challenge.dart';

/// States for WeeklyChallengeBloc
abstract class WeeklyChallengeState extends Equatable {
  const WeeklyChallengeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WeeklyChallengeInitial extends WeeklyChallengeState {
  const WeeklyChallengeInitial();
}

/// Loading state
class WeeklyChallengeLoading extends WeeklyChallengeState {
  const WeeklyChallengeLoading();
}

/// Loaded state
class WeeklyChallengeLoaded extends WeeklyChallengeState {
  final List<WeeklyChallenge> challenges;
  final List<WeeklyChallenge> activeChallenges;
  final List<WeeklyChallenge> completedChallenges;

  const WeeklyChallengeLoaded({
    required this.challenges,
    required this.activeChallenges,
    required this.completedChallenges,
  });

  @override
  List<Object?> get props => [challenges, activeChallenges, completedChallenges];
}

/// Error state
class WeeklyChallengeError extends WeeklyChallengeState {
  final String message;

  const WeeklyChallengeError(this.message);

  @override
  List<Object?> get props => [message];
}




