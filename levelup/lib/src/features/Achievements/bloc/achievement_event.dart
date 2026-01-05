import 'package:equatable/equatable.dart';

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all achievements
class LoadAchievements extends AchievementEvent {
  const LoadAchievements();
}

/// Refresh achievements
class RefreshAchievements extends AchievementEvent {
  const RefreshAchievements();
}





