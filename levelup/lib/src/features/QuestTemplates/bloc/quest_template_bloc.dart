import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/quest_template_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/quest.dart';
import '../../../../domain/entities/quest_template.dart';
import 'quest_template_event.dart';
import 'quest_template_state.dart';

/// BLoC for managing quest template state
class QuestTemplateBloc
    extends Bloc<QuestTemplateEvent, QuestTemplateState> {
  final QuestTemplateService _service;

  QuestTemplateBloc({
    required QuestTemplateService service,
  })  : _service = service,
        super(const QuestTemplateInitial()) {
    on<LoadQuestTemplates>(_onLoadQuestTemplates);
    on<LoadFeaturedQuestTemplates>(_onLoadFeaturedQuestTemplates);
    on<SearchQuestTemplates>(_onSearchQuestTemplates);
    on<FilterQuestTemplatesByCategory>(_onFilterQuestTemplatesByCategory);
    on<ClearQuestTemplateFilters>(_onClearQuestTemplateFilters);
  }

  Future<void> _onLoadQuestTemplates(
    LoadQuestTemplates event,
    Emitter<QuestTemplateState> emit,
  ) async {
    emit(const QuestTemplateLoading());

    final result = await _service.getQuestTemplates();
    if (result is ResultError) {
      emit(QuestTemplateError(
        result is ResultError<dynamic>
            ? result.message
            : 'Failed to load quest templates',
      ));
      return;
    }

    final templates = (result as Success<List<QuestTemplate>>).data;

    // Also load featured templates
    final featuredResult = await _service.getFeaturedQuestTemplates();
    final featuredTemplates = featuredResult is Success<List<QuestTemplate>>
        ? featuredResult.data
        : <QuestTemplate>[];

    emit(QuestTemplateLoaded(
      templates: templates,
      featuredTemplates: featuredTemplates,
    ));
  }

  Future<void> _onLoadFeaturedQuestTemplates(
    LoadFeaturedQuestTemplates event,
    Emitter<QuestTemplateState> emit,
  ) async {
    final result = await _service.getFeaturedQuestTemplates();
    if (result is ResultError) {
      emit(QuestTemplateError(
        result is ResultError<dynamic>
            ? result.message
            : 'Failed to load featured quest templates',
      ));
      return;
    }

    final featuredTemplates = (result as Success<List<QuestTemplate>>).data;

    // Also load all templates
    final allResult = await _service.getQuestTemplates();
    final allTemplates = allResult is Success<List<QuestTemplate>>
        ? allResult.data
        : <QuestTemplate>[];

    emit(QuestTemplateLoaded(
      templates: allTemplates,
      featuredTemplates: featuredTemplates,
    ));
  }

  Future<void> _onSearchQuestTemplates(
    SearchQuestTemplates event,
    Emitter<QuestTemplateState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadQuestTemplates());
      return;
    }

    emit(const QuestTemplateLoading());

    final result = await _service.searchQuestTemplates(event.query);
    if (result is ResultError) {
      emit(QuestTemplateError(
        result is ResultError<dynamic>
            ? result.message
            : 'Failed to search quest templates',
      ));
      return;
    }

    final templates = (result as Success<List<QuestTemplate>>).data;

    // Get featured templates for display
    final featuredResult = await _service.getFeaturedQuestTemplates();
    final featuredTemplates = featuredResult is Success<List<QuestTemplate>>
        ? featuredResult.data
        : <QuestTemplate>[];

    emit(QuestTemplateLoaded(
      templates: templates,
      featuredTemplates: featuredTemplates,
      searchQuery: event.query,
      isSearching: true,
    ));
  }

  Future<void> _onFilterQuestTemplatesByCategory(
    FilterQuestTemplatesByCategory event,
    Emitter<QuestTemplateState> emit,
  ) async {
    emit(const QuestTemplateLoading());

    final result = await _service.getQuestTemplatesByCategory(event.category);
    if (result is ResultError) {
      emit(QuestTemplateError(
        result is ResultError<dynamic>
            ? result.message
            : 'Failed to filter quest templates',
      ));
      return;
    }

    final templates = (result as Success<List<QuestTemplate>>).data;

    // Get featured templates for display
    final featuredResult = await _service.getFeaturedQuestTemplates();
    final featuredTemplates = featuredResult is Success<List<QuestTemplate>>
        ? featuredResult.data
        : <QuestTemplate>[];

    emit(QuestTemplateLoaded(
      templates: templates,
      featuredTemplates: featuredTemplates,
    ));
  }

  Future<void> _onClearQuestTemplateFilters(
    ClearQuestTemplateFilters event,
    Emitter<QuestTemplateState> emit,
  ) async {
    add(const LoadQuestTemplates());
  }
}


