import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/utils/result.dart';
import '../../../domain/entities/quest.dart';
import '../../../domain/entities/quest_template.dart';
import '../../../domain/repositories/quest_repository.dart';
import '../Player/bloc/player_bloc.dart';
import '../Player/bloc/player_event.dart';
import '../Player/bloc/player_state.dart';
import '../Quests/bloc/quest_bloc.dart';
import '../Quests/bloc/quest_event.dart';
import 'bloc/quest_template_bloc.dart';
import 'bloc/quest_template_event.dart';
import 'bloc/quest_template_state.dart';

class QuestTemplatesScreen extends StatefulWidget {
  const QuestTemplatesScreen({super.key});

  @override
  State<QuestTemplatesScreen> createState() => _QuestTemplatesScreenState();
}

class _QuestTemplatesScreenState extends State<QuestTemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  QuestCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<PlayerBloc>().add(const PlayerLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<QuestTemplateBloc>().add(const ClearQuestTemplateFilters());
    } else {
      context.read<QuestTemplateBloc>().add(SearchQuestTemplates(query));
    }
  }

  void _onCategorySelected(QuestCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
    if (category == null) {
      context.read<QuestTemplateBloc>().add(const ClearQuestTemplateFilters());
    } else {
      context.read<QuestTemplateBloc>().add(FilterQuestTemplatesByCategory(category));
    }
  }

  Future<void> _addTemplateAsQuest(QuestTemplate template) async {
    final playerState = context.read<PlayerBloc>().state;
    if (playerState is! PlayerLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get player level')),
      );
      return;
    }

    final player = playerState.player;
    if (!template.isUnlocked(player.level)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(template.getUnlockMessage(player.level)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Convert template to quest
    final quest = template.toQuest(customId: const Uuid().v4());

    // Add quest via repository
    final questRepository = sl<QuestRepository>();
    final result = await questRepository.createQuest(quest);

    if (result is ResultError<Quest>) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Refresh quest list
    if (mounted) {
      context.read<QuestBloc>().add(LoadQuests());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quest added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<QuestTemplateBloc>()..add(const LoadQuestTemplates()),
      child: BlocProvider.value(
        value: context.read<PlayerBloc>(),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Quest Templates',
              style: TextStyle(color: Colors.lightBlueAccent),
            ),
          ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search templates...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip(null, 'All'),
                ...QuestCategory.values.map(
                  (category) => _buildCategoryChip(category, _getCategoryName(category)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Templates list
          Expanded(
            child: BlocBuilder<QuestTemplateBloc, QuestTemplateState>(
              builder: (context, state) {
                if (state is QuestTemplateLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.lightBlueAccent,
                    ),
                  );
                }

                if (state is QuestTemplateError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<QuestTemplateBloc>().add(
                                  const LoadQuestTemplates(),
                                );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is QuestTemplateLoaded) {
                  final templates = state.templates;
                  final featuredTemplates = state.featuredTemplates;

                  if (templates.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No templates found',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          if (state.isSearching) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                context.read<QuestTemplateBloc>().add(
                                      const ClearQuestTemplateFilters(),
                                    );
                              },
                              child: const Text('Clear search'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<QuestTemplateBloc>().add(
                            const LoadQuestTemplates(),
                          );
                    },
                    child: CustomScrollView(
                      slivers: [
                        // Featured templates section
                        if (featuredTemplates.isNotEmpty && !state.isSearching)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Featured Templates',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),

                        if (featuredTemplates.isNotEmpty && !state.isSearching)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final template = featuredTemplates[index];
                                  return _buildTemplateCard(template);
                                },
                                childCount: featuredTemplates.length,
                              ),
                            ),
                          ),

                        // All templates section
                        if (!state.isSearching)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: const Text(
                                'All Templates',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final template = templates[index];
                                return _buildTemplateCard(template);
                              },
                              childCount: templates.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(QuestCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          _onCategorySelected(selected ? category : null);
        },
        backgroundColor: Colors.grey[900],
        selectedColor: Colors.blueAccent,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  Widget _buildTemplateCard(QuestTemplate template) {
    final playerState = context.read<PlayerBloc>().state;
    final playerLevel = playerState is PlayerLoaded ? playerState.player.level : 1;
    final isUnlocked = template.isUnlocked(playerLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: InkWell(
        onTap: isUnlocked ? () => _addTemplateAsQuest(template) : null,
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
                            if (template.isFeatured)
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            if (template.isFeatured) const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                template.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.category,
                    _getCategoryName(template.category),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.signal_cellular_alt,
                    'Difficulty: ${template.difficulty}/5',
                  ),
                  if (template.estimatedDurationDays != null) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.calendar_today,
                      '${template.estimatedDurationDays} days',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${template.reward.experience} XP',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.monetization_on,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${template.reward.currency} coins',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  if (!isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        template.getUnlockMessage(playerLevel),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => _addTemplateAsQuest(template),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Quest'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(QuestCategory category) {
    switch (category) {
      case QuestCategory.combat:
        return 'Combat';
      case QuestCategory.crafting:
        return 'Crafting';
      case QuestCategory.exploration:
        return 'Exploration';
      case QuestCategory.social:
        return 'Social';
      case QuestCategory.health:
        return 'Health';
      case QuestCategory.learning:
        return 'Learning';
      case QuestCategory.work:
        return 'Work';
      case QuestCategory.personal:
        return 'Personal';
    }
  }
}

