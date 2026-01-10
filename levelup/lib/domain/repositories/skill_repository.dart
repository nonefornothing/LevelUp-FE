import '../../core/utils/result.dart';
import '../entities/skill.dart';

/// Repository interface for skill management
abstract class SkillRepository {
  /// Get all skills
  Future<Result<List<Skill>>> getSkills();

  /// Get skill by ID
  Future<Result<Skill>> getSkillById(String skillId);

  /// Get skills by type
  Future<Result<List<Skill>>> getSkillsByType(SkillType type);

  /// Get all skill trees
  Future<Result<List<SkillTree>>> getSkillTrees();

  /// Get skill tree by category
  Future<Result<SkillTree>> getSkillTreeByCategory(SkillCategory category);

  /// Update skill (add XP, level up, allocate points)
  Future<Result<Skill>> updateSkill(Skill skill);

  /// Add experience to a skill
  Future<Result<Skill>> addSkillExperience(String skillId, int experience);

  /// Allocate skill points to a skill
  Future<Result<Skill>> allocateSkillPoints(String skillId, int points);

  /// Initialize default skills (call on first app launch)
  Future<Result<void>> initializeSkills();
}

