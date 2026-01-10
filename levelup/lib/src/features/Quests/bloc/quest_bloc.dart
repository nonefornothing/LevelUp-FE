import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../domain/entities/quest.dart';
import '../../../../domain/repositories/quest_repository.dart';
import 'quest_event.dart';
import 'quest_state.dart';

class QuestBloc extends Bloc<QuestEvent, QuestState> {
  final QuestRepository _questRepository;

  QuestBloc({required QuestRepository questRepository})
      : _questRepository = questRepository,
        super(QuestState.initial()) {
    on<LoadQuests>(_onLoadQuests);
    on<LoadQuestById>(_onLoadQuestById);
    on<CreateQuestRequested>(_onCreateQuest);
    on<UpdateQuestRequested>(_onUpdateQuest);
    on<DeleteQuestRequested>(_onDeleteQuest);
    on<CompleteQuestRequested>(_onCompleteQuest);
  }

  Future<void> _onLoadQuests(LoadQuests event, Emitter<QuestState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    final res = await _questRepository.getQuests(type: event.type, status: event.status);
    if (res is Success<List<Quest>>) {
      emit(state.copyWith(loading: false, quests: res.data, error: null));
    } else if (res is ResultError<List<Quest>>) {
      emit(state.copyWith(loading: false, error: res.message));
    } else {
      emit(state.copyWith(loading: false, error: 'Unknown error'));
    }
  }

  Future<void> _onLoadQuestById(
    LoadQuestById event,
    Emitter<QuestState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    final res = await _questRepository.getQuestById(event.id);
    if (res is Success<Quest>) {
      emit(state.copyWith(loading: false, selectedQuest: res.data));
    } else if (res is ResultError<Quest>) {
      emit(state.copyWith(loading: false, error: res.message));
    } else {
      emit(state.copyWith(loading: false, error: 'Unknown error'));
    }
  }

  Future<void> _onCreateQuest(
    CreateQuestRequested event,
    Emitter<QuestState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    final res = await _questRepository.createQuest(event.quest);
    if (res is Success<Quest>) {
      // Reload list so UI updates
      add(LoadQuests());
    } else if (res is ResultError<Quest>) {
      emit(state.copyWith(loading: false, error: res.message));
    } else {
      emit(state.copyWith(loading: false, error: 'Unknown error'));
    }
  }

  Future<void> _onUpdateQuest(
    UpdateQuestRequested event,
    Emitter<QuestState> emit,
  ) async {
    final res = await _questRepository.updateQuest(event.quest);
    if (res is Success<Quest>) {
      final updated = res.data;
      final updatedList = state.quests.map((q) => q.id == updated.id ? updated : q).toList();
      emit(state.copyWith(quests: updatedList, selectedQuest: updated, error: null));
    } else if (res is ResultError<Quest>) {
      emit(state.copyWith(error: res.message));
    } else {
      emit(state.copyWith(error: 'Unknown error'));
    }
  }

  Future<void> _onDeleteQuest(
    DeleteQuestRequested event,
    Emitter<QuestState> emit,
  ) async {
    final res = await _questRepository.deleteQuest(event.id);
    if (res is Success<void>) {
      final updatedList = state.quests.where((q) => q.id != event.id).toList();
      emit(state.copyWith(quests: updatedList, selectedQuest: null, error: null));
    } else if (res is ResultError<void>) {
      emit(state.copyWith(error: res.message));
    } else {
      emit(state.copyWith(error: 'Unknown error'));
    }
  }

  Future<void> _onCompleteQuest(
    CompleteQuestRequested event,
    Emitter<QuestState> emit,
  ) async {
    final res = await _questRepository.completeQuest(event.id);
    if (res is Success<Quest>) {
      final updated = res.data;
      final updatedList = state.quests.map((q) => q.id == updated.id ? updated : q).toList();
      emit(state.copyWith(quests: updatedList, selectedQuest: updated, error: null));
    } else if (res is ResultError<Quest>) {
      emit(state.copyWith(error: res.message));
    } else {
      emit(state.copyWith(error: 'Unknown error'));
    }
  }
}


