import 'package:equatable/equatable.dart';

/// Skill entity (Domain layer)
class Skill extends Equatable {
  final String id;
  final String name;
  final String description;
  final SkillType type;
  final int level; // Current skill level (0-100)
  final int experience; // Current XP in this skill
  final int skillPoints; // Skill points allocated to this skill
  final int maxLevel; // Maximum level for this skill (default 100)
  final List<String> prerequisites; // IDs of prerequisite skills
  final DateTime? unlockedAt;
  final DateTime? lastLevelUpAt;

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.level,
    required this.experience,
    required this.skillPoints,
    this.maxLevel = 100,
    this.prerequisites = const [],
    this.unlockedAt,
    this.lastLevelUpAt,
  });

  /// Check if skill is unlocked (level > 0 or prerequisites met)
  bool get isUnlocked => level > 0;

  /// Calculate XP needed for next level
  int get xpForNextLevel {
    if (level >= maxLevel) return 0;
    // Exponential curve: XP needed = 100 * (level^2)
    return 100 * (level * level);
  }

  /// Calculate XP progress percentage to next level
  double get xpProgressPercentage {
    if (level >= maxLevel) return 100.0;
    if (xpForNextLevel == 0) return 0.0;
    return (experience / xpForNextLevel * 100).clamp(0.0, 100.0);
  }

  /// Check if skill can be leveled up
  bool canLevelUp() {
    if (level >= maxLevel) return false;
    return experience >= xpForNextLevel;
  }

  /// Get skill tier based on level
  SkillTier get tier {
    if (level >= 80) return SkillTier.master;
    if (level >= 60) return SkillTier.expert;
    if (level >= 40) return SkillTier.advanced;
    if (level >= 20) return SkillTier.intermediate;
    if (level >= 1) return SkillTier.beginner;
    return SkillTier.novice;
  }

  Skill copyWith({
    String? id,
    String? name,
    String? description,
    SkillType? type,
    int? level,
    int? experience,
    int? skillPoints,
    int? maxLevel,
    List<String>? prerequisites,
    DateTime? unlockedAt,
    DateTime? lastLevelUpAt,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      skillPoints: skillPoints ?? this.skillPoints,
      maxLevel: maxLevel ?? this.maxLevel,
      prerequisites: prerequisites ?? this.prerequisites,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      lastLevelUpAt: lastLevelUpAt ?? this.lastLevelUpAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        level,
        experience,
        skillPoints,
        maxLevel,
        prerequisites,
        unlockedAt,
        lastLevelUpAt,
      ];
}

/// Skill Type enum - represents different skill categories
enum SkillType {
  // Combat skills
  combat,
  strength,
  agility,
  defense,

  // Crafting skills
  crafting,
  engineering,
  alchemy,
  smithing,

  // Social skills
  social,
  leadership,
  communication,
  charisma,

  // Exploration skills
  exploration,
  survival,
  navigation,
  discovery,

  // Learning skills
  learning,
  research,
  analysis,
  creativity,

  // Health skills
  health,
  fitness,
  wellness,
  endurance,
}

/// Skill Tier - represents skill proficiency level
enum SkillTier {
  novice, // 0
  beginner, // 1-19
  intermediate, // 20-39
  advanced, // 40-59
  expert, // 60-79
  master, // 80-100
}

/// Skill Tree - represents a collection of related skills
class SkillTree extends Equatable {
  final String id;
  final String name;
  final String description;
  final SkillCategory category;
  final List<Skill> skills;
  final String iconName;

  const SkillTree({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.skills,
    required this.iconName,
  });

  /// Get total skill points allocated in this tree
  int get totalSkillPoints {
    return skills.fold(0, (sum, skill) => sum + skill.skillPoints);
  }

  /// Get average skill level in this tree
  double get averageLevel {
    if (skills.isEmpty) return 0.0;
    final total = skills.fold(0, (sum, skill) => sum + skill.level);
    return total / skills.length;
  }

  /// Get unlocked skills count
  int get unlockedSkillsCount {
    return skills.where((skill) => skill.isUnlocked).length;
  }

  @override
  List<Object?> get props => [id, name, description, category, skills, iconName];
}

/// Skill Category - groups related skill trees
enum SkillCategory {
  combat,
  crafting,
  social,
  exploration,
  learning,
  health,
}

