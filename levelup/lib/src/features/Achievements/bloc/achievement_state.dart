import 'package:equatable/equatable.dart';

import '../../../../domain/entities/achievement.dart';

class AchievementState extends Equatable {
  final bool loading;
  final List<Achievement> achievements;
  final List<Achievement> unlockedAchievements;
  final List<Achievement> lockedAchievements;
  final String? error;

  const AchievementState({
    required this.loading,
    required this.achievements,
    required this.unlockedAchievements,
    required this.lockedAchievements,
    this.error,
  });

  factory AchievementState.initial() {
    return const AchievementState(
      loading: false,
      achievements: [],
      unlockedAchievements: [],
      lockedAchievements: [],
      error: null,
    );
  }

  AchievementState copyWith({
    bool? loading,
    List<Achievement>? achievements,
    List<Achievement>? unlockedAchievements,
    List<Achievement>? lockedAchievements,
    String? error,
  }) {
    return AchievementState(
      loading: loading ?? this.loading,
      achievements: achievements ?? this.achievements,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      lockedAchievements: lockedAchievements ?? this.lockedAchievements,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        achievements,
        unlockedAchievements,
        lockedAchievements,
        error,
      ];
}

