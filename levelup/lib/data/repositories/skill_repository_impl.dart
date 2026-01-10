import '../../core/utils/result.dart';
import '../../domain/entities/skill.dart';
import '../../domain/repositories/skill_repository.dart';
import '../datasources/skill_local_datasource.dart';

class SkillRepositoryImpl implements SkillRepository {
  final SkillLocalDataSource _local;

  SkillRepositoryImpl({required SkillLocalDataSource localDataSource})
      : _local = localDataSource;

  @override
  Future<Result<List<Skill>>> getSkills() async {
    return await _local.getAllSkills();
  }

  @override
  Future<Result<Skill>> getSkillById(String skillId) async {
    return await _local.getSkillById(skillId);
  }

  @override
  Future<Result<List<Skill>>> getSkillsByType(SkillType type) async {
    return await _local.getSkillsByType(type);
  }

  @override
  Future<Result<List<SkillTree>>> getSkillTrees() async {
    try {
      final skillsResult = await _local.getAllSkills();
      if (skillsResult is ResultError<List<Skill>>) {
        return ResultError(skillsResult.message, exception: skillsResult.exception);
      }

      final skills = (skillsResult as Success<List<Skill>>).data;
      final trees = _buildSkillTrees(skills);
      return Success(trees);
    } catch (e) {
      return ResultError(
        'Failed to get skill trees: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<SkillTree>> getSkillTreeByCategory(SkillCategory category) async {
    try {
      final treesResult = await getSkillTrees();
      if (treesResult is ResultError<List<SkillTree>>) {
        return ResultError(treesResult.message, exception: treesResult.exception);
      }

      final trees = (treesResult as Success<List<SkillTree>>).data;
      final tree = trees.firstWhere(
        (t) => t.category == category,
        orElse: () => _createDefaultSkillTree(category),
      );
      return Success(tree);
    } catch (e) {
      return ResultError(
        'Failed to get skill tree: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Skill>> updateSkill(Skill skill) async {
    return await _local.saveSkill(skill);
  }

  @override
  Future<Result<Skill>> addSkillExperience(String skillId, int experience) async {
    try {
      final skillResult = await _local.getSkillById(skillId);
      if (skillResult is ResultError<Skill>) {
        return ResultError(skillResult.message, exception: skillResult.exception);
      }

      final skill = (skillResult as Success<Skill>).data;
      var newExperience = skill.experience + experience;
      var newLevel = skill.level;
      var lastLevelUpAt = skill.lastLevelUpAt;

      // Check for level ups
      while (newLevel < skill.maxLevel && newExperience >= skill.xpForNextLevel) {
        newExperience -= skill.xpForNextLevel;
        newLevel++;
        lastLevelUpAt = DateTime.now();
      }

      final updated = skill.copyWith(
        level: newLevel,
        experience: newExperience,
        unlockedAt: skill.unlockedAt ?? (newLevel > 0 ? DateTime.now() : null),
        lastLevelUpAt: lastLevelUpAt,
      );

      return await _local.saveSkill(updated);
    } catch (e) {
      return ResultError(
        'Failed to add skill experience: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Skill>> allocateSkillPoints(String skillId, int points) async {
    try {
      final skillResult = await _local.getSkillById(skillId);
      if (skillResult is ResultError<Skill>) {
        return ResultError(skillResult.message, exception: skillResult.exception);
      }

      final skill = (skillResult as Success<Skill>).data;
      final updated = skill.copyWith(
        skillPoints: skill.skillPoints + points,
      );

      return await _local.saveSkill(updated);
    } catch (e) {
      return ResultError(
        'Failed to allocate skill points: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> initializeSkills() async {
    try {
      final existingResult = await _local.getAllSkills();
      if (existingResult is Success<List<Skill>>) {
        final existing = existingResult.data;
        if (existing.isNotEmpty) {
          return const Success(null);
        }
      }

      // Create default skills
      final defaultSkills = _createDefaultSkills();
      await _local.saveAllSkills(defaultSkills);
      return const Success(null);
    } catch (e) {
      return ResultError(
        'Failed to initialize skills: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  List<SkillTree> _buildSkillTrees(List<Skill> skills) {
    final trees = <SkillTree>[];

    for (final category in SkillCategory.values) {
      final categorySkills = skills.where((skill) {
        return _getSkillCategory(skill.type) == category;
      }).toList();

      trees.add(SkillTree(
        id: category.name,
        name: _getCategoryName(category),
        description: _getCategoryDescription(category),
        category: category,
        skills: categorySkills,
        iconName: category.name,
      ));
    }

    return trees;
  }

  SkillCategory _getSkillCategory(SkillType type) {
    switch (type) {
      case SkillType.combat:
      case SkillType.strength:
      case SkillType.agility:
      case SkillType.defense:
        return SkillCategory.combat;
      case SkillType.crafting:
      case SkillType.engineering:
      case SkillType.alchemy:
      case SkillType.smithing:
        return SkillCategory.crafting;
      case SkillType.social:
      case SkillType.leadership:
      case SkillType.communication:
      case SkillType.charisma:
        return SkillCategory.social;
      case SkillType.exploration:
      case SkillType.survival:
      case SkillType.navigation:
      case SkillType.discovery:
        return SkillCategory.exploration;
      case SkillType.learning:
      case SkillType.research:
      case SkillType.analysis:
      case SkillType.creativity:
        return SkillCategory.learning;
      case SkillType.health:
      case SkillType.fitness:
      case SkillType.wellness:
      case SkillType.endurance:
        return SkillCategory.health;
    }
  }

  String _getCategoryName(SkillCategory category) {
    switch (category) {
      case SkillCategory.combat:
        return 'Combat';
      case SkillCategory.crafting:
        return 'Crafting';
      case SkillCategory.social:
        return 'Social';
      case SkillCategory.exploration:
        return 'Exploration';
      case SkillCategory.learning:
        return 'Learning';
      case SkillCategory.health:
        return 'Health';
    }
  }

  String _getCategoryDescription(SkillCategory category) {
    switch (category) {
      case SkillCategory.combat:
        return 'Master the art of combat and physical prowess';
      case SkillCategory.crafting:
        return 'Create and build amazing things';
      case SkillCategory.social:
        return 'Develop your social and leadership skills';
      case SkillCategory.exploration:
        return 'Explore the world and discover new places';
      case SkillCategory.learning:
        return 'Expand your knowledge and creativity';
      case SkillCategory.health:
        return 'Improve your physical and mental wellness';
    }
  }

  SkillTree _createDefaultSkillTree(SkillCategory category) {
    return SkillTree(
      id: category.name,
      name: _getCategoryName(category),
      description: _getCategoryDescription(category),
      category: category,
      skills: const [],
      iconName: category.name,
    );
  }

  List<Skill> _createDefaultSkills() {
    return [
      // Combat skills
      Skill(
        id: 'combat',
        name: 'Combat',
        description: 'Basic combat proficiency',
        type: SkillType.combat,
        level: 0,
        experience: 0,
        skillPoints: 0,
      ),
      Skill(
        id: 'strength',
        name: 'Strength',
        description: 'Physical strength and power',
        type: SkillType.strength,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['combat'],
      ),
      Skill(
        id: 'agility',
        name: 'Agility',
        description: 'Speed and flexibility',
        type: SkillType.agility,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['combat'],
      ),
      Skill(
        id: 'defense',
        name: 'Defense',
        description: 'Defensive capabilities',
        type: SkillType.defense,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['combat'],
      ),

      // Crafting skills
      Skill(
        id: 'crafting',
        name: 'Crafting',
        description: 'Basic crafting ability',
        type: SkillType.crafting,
        level: 0,
        experience: 0,
        skillPoints: 0,
      ),
      Skill(
        id: 'engineering',
        name: 'Engineering',
        description: 'Technical engineering skills',
        type: SkillType.engineering,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['crafting'],
      ),
      Skill(
        id: 'alchemy',
        name: 'Alchemy',
        description: 'Potion and material crafting',
        type: SkillType.alchemy,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['crafting'],
      ),
      Skill(
        id: 'smithing',
        name: 'Smithing',
        description: 'Metalworking and forging',
        type: SkillType.smithing,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['crafting'],
      ),

      // Social skills
      Skill(
        id: 'social',
        name: 'Social',
        description: 'Basic social interaction',
        type: SkillType.social,
        level: 0,
        experience: 0,
        skillPoints: 0,
      ),
      Skill(
        id: 'leadership',
        name: 'Leadership',
        description: 'Leading and inspiring others',
        type: SkillType.leadership,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['social'],
      ),
      Skill(
        id: 'communication',
        name: 'Communication',
        description: 'Effective communication skills',
        type: SkillType.communication,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['social'],
      ),
      Skill(
        id: 'charisma',
        name: 'Charisma',
        description: 'Charm and persuasion',
        type: SkillType.charisma,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['social'],
      ),

      // Exploration skills
      Skill(
        id: 'exploration',
        name: 'Exploration',
        description: 'Basic exploration ability',
        type: SkillType.exploration,
        level: 0,
        experience: 0,
        skillPoints: 0,
      ),
      Skill(
        id: 'survival',
        name: 'Survival',
        description: 'Survival in challenging environments',
        type: SkillType.survival,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['exploration'],
      ),
      Skill(
        id: 'navigation',
        name: 'Navigation',
        description: 'Finding your way',
        type: SkillType.navigation,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['exploration'],
      ),
      Skill(
        id: 'discovery',
        name: 'Discovery',
        description: 'Finding hidden secrets',
        type: SkillType.discovery,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['exploration'],
      ),

      // Learning skills
      Skill(
        id: 'learning',
        name: 'Learning',
        description: 'Basic learning ability',
        type: SkillType.learning,
        level: 0,
        experience: 0,
        skillPoints: 0,
      ),
      Skill(
        id: 'research',
        name: 'Research',
        description: 'Research and investigation',
        type: SkillType.research,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['learning'],
      ),
      Skill(
        id: 'analysis',
        name: 'Analysis',
        description: 'Critical thinking and analysis',
        type: SkillType.analysis,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['learning'],
      ),
      Skill(
        id: 'creativity',
        name: 'Creativity',
        description: 'Creative thinking and innovation',
        type: SkillType.creativity,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['learning'],
      ),

      // Health skills
      Skill(
        id: 'health',
        name: 'Health',
        description: 'Basic health and wellness',
        type: SkillType.health,
        level: 0,
        experience: 0,
        skillPoints: 0,
      ),
      Skill(
        id: 'fitness',
        name: 'Fitness',
        description: 'Physical fitness and conditioning',
        type: SkillType.fitness,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['health'],
      ),
      Skill(
        id: 'wellness',
        name: 'Wellness',
        description: 'Mental and emotional wellness',
        type: SkillType.wellness,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['health'],
      ),
      Skill(
        id: 'endurance',
        name: 'Endurance',
        description: 'Stamina and endurance',
        type: SkillType.endurance,
        level: 0,
        experience: 0,
        skillPoints: 0,
        prerequisites: ['health'],
      ),
    ];
  }
}

