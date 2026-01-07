import 'package:equatable/equatable.dart';

import '../../../../domain/entities/skill.dart';

/// Base class for skill events
abstract class SkillEvent extends Equatable {
  const SkillEvent();

  @override
  List<Object?> get props => [];
}

/// Load all skills and skill trees
class SkillLoadRequested extends SkillEvent {
  const SkillLoadRequested();
}

/// Refresh skills data
class SkillRefreshRequested extends SkillEvent {
  const SkillRefreshRequested();
}

/// Load skill tree by category
class SkillTreeLoadRequested extends SkillEvent {
  final SkillCategory category;

  const SkillTreeLoadRequested(this.category);

  @override
  List<Object?> get props => [category];
}

/// Allocate skill points to a skill
class SkillPointsAllocated extends SkillEvent {
  final String skillId;
  final int points;

  const SkillPointsAllocated({
    required this.skillId,
    required this.points,
  });

  @override
  List<Object?> get props => [skillId, points];
}

/// View skill details
class SkillDetailsRequested extends SkillEvent {
  final String skillId;

  const SkillDetailsRequested(this.skillId);

  @override
  List<Object?> get props => [skillId];
}

