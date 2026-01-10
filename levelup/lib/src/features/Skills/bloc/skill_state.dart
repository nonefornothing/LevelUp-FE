import 'package:equatable/equatable.dart';

import '../../../../domain/entities/skill.dart';

/// Base class for skill states
abstract class SkillState extends Equatable {
  const SkillState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SkillInitial extends SkillState {
  const SkillInitial();
}

/// Loading state
class SkillLoading extends SkillState {
  const SkillLoading();
}

/// Loaded state with skills and trees
class SkillLoaded extends SkillState {
  final List<Skill> skills;
  final List<SkillTree> skillTrees;
  final SkillCategory? selectedCategory;
  final SkillTree? selectedTree;

  const SkillLoaded({
    required this.skills,
    required this.skillTrees,
    this.selectedCategory,
    this.selectedTree,
  });

  SkillLoaded copyWith({
    List<Skill>? skills,
    List<SkillTree>? skillTrees,
    SkillCategory? selectedCategory,
    SkillTree? selectedTree,
  }) {
    return SkillLoaded(
      skills: skills ?? this.skills,
      skillTrees: skillTrees ?? this.skillTrees,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedTree: selectedTree ?? this.selectedTree,
    );
  }

  @override
  List<Object?> get props => [skills, skillTrees, selectedCategory, selectedTree];
}

/// Error state
class SkillError extends SkillState {
  final String message;

  const SkillError(this.message);

  @override
  List<Object?> get props => [message];
}

