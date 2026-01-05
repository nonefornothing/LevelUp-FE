import 'package:equatable/equatable.dart';

import '../../../../domain/entities/quest.dart';

/// Events for QuestTemplateBloc
abstract class QuestTemplateEvent extends Equatable {
  const QuestTemplateEvent();

  @override
  List<Object?> get props => [];
}

/// Load all quest templates
class LoadQuestTemplates extends QuestTemplateEvent {
  const LoadQuestTemplates();
}

/// Load featured quest templates
class LoadFeaturedQuestTemplates extends QuestTemplateEvent {
  const LoadFeaturedQuestTemplates();
}

/// Search quest templates
class SearchQuestTemplates extends QuestTemplateEvent {
  final String query;

  const SearchQuestTemplates(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter quest templates by category
class FilterQuestTemplatesByCategory extends QuestTemplateEvent {
  final QuestCategory category;

  const FilterQuestTemplatesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Clear search/filter
class ClearQuestTemplateFilters extends QuestTemplateEvent {
  const ClearQuestTemplateFilters();
}


