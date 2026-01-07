import '../../core/utils/result.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/skill.dart';
import '../../domain/repositories/skill_repository.dart';

/// Service for managing skill progression and point allocation
class SkillService {
  final SkillRepository _skillRepository;

  SkillService({required SkillRepository skillRepository})
      : _skillRepository = skillRepository;

  /// Initialize default skills (call once on app startup)
  Future<Result<void>> initializeSkills() async {
    return await _skillRepository.initializeSkills();
  }

  /// Award skill experience based on quest completion
  /// Maps quest categories to relevant skills
  Future<Result<List<Skill>>> awardSkillExperienceFromQuest(Quest quest) async {
    try {
      final skillsToUpdate = <Skill>[];

      // Map quest category to skill types
      final skillTypes = _getSkillTypesForCategory(quest.category);

      // Award XP to each relevant skill
      // Base XP = quest difficulty * 10
      final baseXP = quest.difficulty * 10;

      for (final skillType in skillTypes) {
        // Get skills of this type
        final skillsResult = await _skillRepository.getSkillsByType(skillType);
        if (skillsResult is ResultError) continue;

        final skills = (skillsResult as Success<List<Skill>>).data;
        if (skills.isEmpty) continue;

        // Award XP to the primary skill (first one found)
        final primarySkill = skills.first;
        final xpResult = await _skillRepository.addSkillExperience(
          primarySkill.id,
          baseXP,
        );

        if (xpResult is Success<Skill>) {
          skillsToUpdate.add(xpResult.data);
        }
      }

      return Success(skillsToUpdate);
    } catch (e) {
      return ResultError(
        'Failed to award skill experience: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Get skill types that should receive XP for a quest category
  List<SkillType> _getSkillTypesForCategory(QuestCategory category) {
    switch (category) {
      case QuestCategory.combat:
        return [SkillType.combat, SkillType.strength];
      case QuestCategory.crafting:
        return [SkillType.crafting, SkillType.engineering];
      case QuestCategory.exploration:
        return [SkillType.exploration, SkillType.discovery];
      case QuestCategory.social:
        return [SkillType.social, SkillType.communication];
      case QuestCategory.learning:
        return [SkillType.learning, SkillType.research];
      case QuestCategory.health:
        return [SkillType.health, SkillType.fitness];
      case QuestCategory.work:
        return [SkillType.learning, SkillType.analysis];
      case QuestCategory.personal:
        return [SkillType.health, SkillType.wellness];
    }
  }

  /// Allocate skill points to a skill
  Future<Result<Skill>> allocateSkillPoints(
    String skillId,
    int points,
  ) async {
    return await _skillRepository.allocateSkillPoints(skillId, points);
  }

  /// Get all skill trees
  Future<Result<List<SkillTree>>> getSkillTrees() async {
    return await _skillRepository.getSkillTrees();
  }

  /// Get skill tree by category
  Future<Result<SkillTree>> getSkillTreeByCategory(SkillCategory category) async {
    return await _skillRepository.getSkillTreeByCategory(category);
  }

  /// Get skill by ID
  Future<Result<Skill>> getSkillById(String skillId) async {
    return await _skillRepository.getSkillById(skillId);
  }

  /// Get all skills
  Future<Result<List<Skill>>> getAllSkills() async {
    return await _skillRepository.getSkills();
  }

  /// Check if a skill can be unlocked (prerequisites met)
  Future<Result<bool>> canUnlockSkill(String skillId) async {
    try {
      final skillResult = await _skillRepository.getSkillById(skillId);
      if (skillResult is ResultError) {
        return Success(false);
      }

      final skill = (skillResult as Success<Skill>).data;

      // If already unlocked, return true
      if (skill.isUnlocked) return Success(true);

      // Check prerequisites
      if (skill.prerequisites.isEmpty) return Success(true);

      final allSkillsResult = await _skillRepository.getSkills();
      if (allSkillsResult is ResultError) return Success(false);

      final allSkills = (allSkillsResult as Success<List<Skill>>).data;
      final skillMap = {for (var s in allSkills) s.id: s};

      // Check if all prerequisites are unlocked
      for (final prereqId in skill.prerequisites) {
        final prereq = skillMap[prereqId];
        if (prereq == null || !prereq.isUnlocked) {
          return Success(false);
        }
      }

      return Success(true);
    } catch (e) {
      return ResultError(
        'Failed to check skill unlock: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}

