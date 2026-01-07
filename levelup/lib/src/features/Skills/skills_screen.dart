import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/utils/result.dart';
import '../../../domain/entities/player.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/repositories/player_repository.dart';
import '../../../domain/repositories/skill_repository.dart';
import '../Player/bloc/player_bloc.dart';
import '../Player/bloc/player_event.dart';
import '../Player/bloc/player_state.dart';
import 'bloc/skill_bloc.dart';
import 'bloc/skill_event.dart';
import 'bloc/skill_state.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SkillBloc(
            skillRepository: sl<SkillRepository>(),
          )..add(const SkillLoadRequested()),
        ),
        BlocProvider(
          create: (context) => PlayerBloc(
            playerRepository: sl<PlayerRepository>(),
          )..add(const PlayerLoadRequested()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Skill Trees',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
        ),
        body: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, playerState) {
            int availableSkillPoints = 0;
            if (playerState is PlayerLoaded) {
              availableSkillPoints = playerState.player.availableSkillPoints;
            }

            return BlocBuilder<SkillBloc, SkillState>(
              builder: (context, state) {
                if (state is SkillLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.lightBlueAccent,
                    ),
                  );
                }

                if (state is SkillError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<SkillBloc>().add(const SkillLoadRequested());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SkillLoaded) {
                  return Column(
                    children: [
                      // Available Skill Points Card
                      if (availableSkillPoints > 0)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.stars,
                                color: Colors.amber,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Available Skill Points',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$availableSkillPoints points ready to allocate',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Skill Trees List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.skillTrees.length,
                          itemBuilder: (context, index) {
                            final tree = state.skillTrees[index];
                            return _buildSkillTreeCard(
                              context,
                              tree,
                              availableSkillPoints,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkillTreeCard(
    BuildContext context,
    SkillTree tree,
    int availableSkillPoints,
  ) {
    final unlockedCount = tree.unlockedSkillsCount;
    final totalCount = tree.skills.length;
    final averageLevel = tree.averageLevel;

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.read<SkillBloc>().add(SkillTreeLoadRequested(tree.category));
          _showSkillTreeDetails(context, tree, availableSkillPoints);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(tree.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(tree.category),
                      color: _getCategoryColor(tree.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tree.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tree.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white70,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    Icons.check_circle,
                    '$unlockedCount/$totalCount',
                    'Unlocked',
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.trending_up,
                    averageLevel.toStringAsFixed(1),
                    'Avg Level',
                  ),
                  if (tree.totalSkillPoints > 0) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.stars,
                      '${tree.totalSkillPoints}',
                      'Points',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.lightBlueAccent, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showSkillTreeDetails(
    BuildContext context,
    SkillTree tree,
    int availableSkillPoints,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(tree.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(tree.category),
                      color: _getCategoryColor(tree.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tree.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tree.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: tree.skills.length,
                itemBuilder: (context, index) {
                  final skill = tree.skills[index];
                  return _buildSkillCard(context, skill, availableSkillPoints);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard(
    BuildContext context,
    Skill skill,
    int availableSkillPoints,
  ) {
    final canAllocate = availableSkillPoints > 0;
    final isUnlocked = skill.isUnlocked;

    return Card(
      color: isUnlocked ? Colors.grey[800] : Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            skill.name,
                            style: TextStyle(
                              color: isUnlocked ? Colors.white : Colors.white60,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTierColor(skill.tier).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getTierColor(skill.tier),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              skill.tier.name.toUpperCase(),
                              style: TextStyle(
                                color: _getTierColor(skill.tier),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        skill.description,
                        style: TextStyle(
                          color: isUnlocked ? Colors.white70 : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnlocked)
                  Text(
                    'Lv. ${skill.level}',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 12),
              // XP Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'XP: ${skill.experience}/${skill.xpForNextLevel}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${skill.xpProgressPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: skill.xpProgressPercentage / 100,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTierColor(skill.tier),
                    ),
                  ),
                ],
              ),
              if (skill.skillPoints > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${skill.skillPoints} skill points allocated',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              const SizedBox(height: 8),
              const Text(
                'Locked - Complete prerequisites to unlock',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (canAllocate && isUnlocked) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _showAllocatePointsDialog(context, skill, availableSkillPoints);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Allocate Points'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllocatePointsDialog(
    BuildContext context,
    Skill skill,
    int availablePoints,
  ) {
    int pointsToAllocate = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Allocate Skill Points',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${skill.name}\nAvailable: $availablePoints points',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: pointsToAllocate > 1
                        ? () => setState(() => pointsToAllocate--)
                        : null,
                    icon: const Icon(Icons.remove_circle, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '$pointsToAllocate',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: pointsToAllocate < availablePoints
                        ? () => setState(() => pointsToAllocate++)
                        : null,
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Deduct skill points from player
                final playerRepo = sl<PlayerRepository>();
                final playerResult = await playerRepo.getPlayer();
                if (playerResult is Success<Player>) {
                  final player = playerResult.data;
                  if (player.availableSkillPoints >= pointsToAllocate) {
                    await playerRepo.updatePlayer(
                      player.copyWith(
                        availableSkillPoints: player.availableSkillPoints - pointsToAllocate,
                      ),
                    );
                    
                    if (!context.mounted) return;
                    
                    // Allocate points to skill
                    context.read<SkillBloc>().add(
                          SkillPointsAllocated(
                            skillId: skill.id,
                            points: pointsToAllocate,
                          ),
                        );
                    context.read<PlayerBloc>().add(const PlayerRefreshRequested());
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Not enough skill points available'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('Allocate'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(SkillCategory category) {
    switch (category) {
      case SkillCategory.combat:
        return Colors.red;
      case SkillCategory.crafting:
        return Colors.orange;
      case SkillCategory.social:
        return Colors.blue;
      case SkillCategory.exploration:
        return Colors.green;
      case SkillCategory.learning:
        return Colors.purple;
      case SkillCategory.health:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon(SkillCategory category) {
    switch (category) {
      case SkillCategory.combat:
        return Icons.sports_martial_arts;
      case SkillCategory.crafting:
        return Icons.build;
      case SkillCategory.social:
        return Icons.people;
      case SkillCategory.exploration:
        return Icons.explore;
      case SkillCategory.learning:
        return Icons.school;
      case SkillCategory.health:
        return Icons.favorite;
    }
  }

  Color _getTierColor(SkillTier tier) {
    switch (tier) {
      case SkillTier.novice:
        return Colors.grey;
      case SkillTier.beginner:
        return Colors.green;
      case SkillTier.intermediate:
        return Colors.blue;
      case SkillTier.advanced:
        return Colors.purple;
      case SkillTier.expert:
        return Colors.orange;
      case SkillTier.master:
        return Colors.amber;
    }
  }
}

