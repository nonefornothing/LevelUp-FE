import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../domain/entities/skill.dart';
import '../../../../domain/repositories/skill_repository.dart';
import 'skill_event.dart';
import 'skill_state.dart';

class SkillBloc extends Bloc<SkillEvent, SkillState> {
  final SkillRepository _skillRepository;

  SkillBloc({required SkillRepository skillRepository})
      : _skillRepository = skillRepository,
        super(const SkillInitial()) {
    on<SkillLoadRequested>(_onLoadRequested);
    on<SkillRefreshRequested>(_onRefreshRequested);
    on<SkillTreeLoadRequested>(_onTreeLoadRequested);
    on<SkillPointsAllocated>(_onPointsAllocated);
    on<SkillDetailsRequested>(_onDetailsRequested);
  }

  Future<void> _onLoadRequested(
    SkillLoadRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(const SkillLoading());

    final skillsResult = await _skillRepository.getSkills();
    final treesResult = await _skillRepository.getSkillTrees();

    if (skillsResult is ResultError<List<Skill>>) {
      emit(SkillError(skillsResult.message));
      return;
    }

    if (treesResult is ResultError<List<SkillTree>>) {
      emit(SkillError(treesResult.message));
      return;
    }

    final skills = (skillsResult as Success<List<Skill>>).data;
    final trees = (treesResult as Success<List<SkillTree>>).data;

    emit(SkillLoaded(skills: skills, skillTrees: trees));
  }

  Future<void> _onRefreshRequested(
    SkillRefreshRequested event,
    Emitter<SkillState> emit,
  ) async {
    final skillsResult = await _skillRepository.getSkills();
    final treesResult = await _skillRepository.getSkillTrees();

    if (skillsResult is ResultError || treesResult is ResultError) {
      // Don't emit error on refresh, just keep current state
      return;
    }

    final skills = (skillsResult as Success<List<Skill>>).data;
    final trees = (treesResult as Success<List<SkillTree>>).data;

    if (state is SkillLoaded) {
      final currentState = state as SkillLoaded;
      emit(currentState.copyWith(skills: skills, skillTrees: trees));
    } else {
      emit(SkillLoaded(skills: skills, skillTrees: trees));
    }
  }

  Future<void> _onTreeLoadRequested(
    SkillTreeLoadRequested event,
    Emitter<SkillState> emit,
  ) async {
    final treeResult = await _skillRepository.getSkillTreeByCategory(event.category);

    if (treeResult is ResultError<SkillTree>) {
      emit(SkillError(treeResult.message));
      return;
    }

    final tree = (treeResult as Success<SkillTree>).data;

    if (state is SkillLoaded) {
      final currentState = state as SkillLoaded;
      emit(currentState.copyWith(
        selectedCategory: event.category,
        selectedTree: tree,
      ));
    }
  }

  Future<void> _onPointsAllocated(
    SkillPointsAllocated event,
    Emitter<SkillState> emit,
  ) async {
    final result = await _skillRepository.allocateSkillPoints(
      event.skillId,
      event.points,
    );

    if (result is ResultError<Skill>) {
      emit(SkillError(result.message));
      return;
    }

    // Refresh skills after allocation
    add(const SkillRefreshRequested());
  }

  Future<void> _onDetailsRequested(
    SkillDetailsRequested event,
    Emitter<SkillState> emit,
  ) async {
    // This could be used to show skill details in a dialog or navigate
    // For now, just refresh to ensure latest data
    add(const SkillRefreshRequested());
  }
}

