import 'package:equatable/equatable.dart';

import '../../../../domain/entities/quest_template.dart';

/// States for QuestTemplateBloc
abstract class QuestTemplateState extends Equatable {
  const QuestTemplateState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class QuestTemplateInitial extends QuestTemplateState {
  const QuestTemplateInitial();
}

/// Loading state
class QuestTemplateLoading extends QuestTemplateState {
  const QuestTemplateLoading();
}

/// Loaded state
class QuestTemplateLoaded extends QuestTemplateState {
  final List<QuestTemplate> templates;
  final List<QuestTemplate> featuredTemplates;
  final String? searchQuery;
  final bool isSearching;

  const QuestTemplateLoaded({
    required this.templates,
    required this.featuredTemplates,
    this.searchQuery,
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [
        templates,
        featuredTemplates,
        searchQuery,
        isSearching,
      ];
}

/// Error state
class QuestTemplateError extends QuestTemplateState {
  final String message;

  const QuestTemplateError(this.message);

  @override
  List<Object?> get props => [message];
}


