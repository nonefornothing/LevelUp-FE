import 'package:equatable/equatable.dart';

/// Player entity (Domain layer)
class Player extends Equatable {
  final String id;
  final String username;
  final String? email;
  final int level;
  final int experience;
  final int currency;
  final int availableSkillPoints; // Skill points available to allocate
  final PlayerStats stats;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  const Player({
    required this.id,
    required this.username,
    this.email,
    required this.level,
    required this.experience,
    required this.currency,
    this.availableSkillPoints = 0,
    required this.stats,
    required this.createdAt,
    this.lastActiveAt,
  });

  /// Calculate XP needed for next level
  int get xpForNextLevel {
    // Formula: baseXP * (level ^ multiplier)
    return (100 * (level * 1.5)).round();
  }

  /// Calculate XP progress percentage
  double get xpProgressPercentage {
    if (xpForNextLevel == 0) return 0.0;
    final previousLevelXP = level > 1 
        ? (100 * ((level - 1) * 1.5)).round() 
        : 0;
    final currentLevelXP = experience - previousLevelXP;
    final xpNeeded = xpForNextLevel - previousLevelXP;
    return (currentLevelXP / xpNeeded * 100).clamp(0.0, 100.0);
  }

  Player copyWith({
    String? id,
    String? username,
    String? email,
    int? level,
    int? experience,
    int? currency,
    int? availableSkillPoints,
    PlayerStats? stats,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return Player(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      currency: currency ?? this.currency,
      availableSkillPoints: availableSkillPoints ?? this.availableSkillPoints,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        level,
        experience,
        currency,
        availableSkillPoints,
        stats,
        createdAt,
        lastActiveAt,
      ];
}

/// Player Stats entity
class PlayerStats extends Equatable {
  final int totalQuestsCompleted;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;

  const PlayerStats({
    required this.totalQuestsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
  });

  @override
  List<Object?> get props => [
        totalQuestsCompleted,
        currentStreak,
        longestStreak,
        lastActiveDate,
      ];
}

