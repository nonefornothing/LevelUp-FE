import '../../core/utils/quest_progress_calculator.dart';
import '../../core/utils/result.dart';
import '../../core/utils/result_extensions.dart';
import '../../domain/entities/quest.dart';
import '../../domain/repositories/quest_repository.dart';
import '../datasources/quest_local_datasource.dart';

/// Quest Repository Implementation (Data layer)
class QuestRepositoryImpl implements QuestRepository {
  final QuestLocalDataSource _localDataSource;

  QuestRepositoryImpl({required QuestLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Result<List<Quest>>> getQuests({
    QuestType? type,
    QuestStatus? status,
  }) async {
    try {
      final quests = await _localDataSource.getQuests(type: type, status: status);
      return Success(quests);
    } catch (e) {
      return ResultError(
        'Failed to get quests: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Quest>> getQuestById(String id) async {
    try {
      final quest = await _localDataSource.getQuestById(id);
      if (quest == null) return const ResultError('Quest not found');
      return Success(quest);
    } catch (e) {
      return ResultError(
        'Failed to get quest: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Quest>> createQuest(Quest quest) async {
    try {
      await _localDataSource.upsertQuest(quest);
      return Success(quest);
    } catch (e) {
      return ResultError(
        'Failed to create quest: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Quest>> updateQuest(Quest quest) async {
    try {
      await _localDataSource.upsertQuest(quest);
      return Success(quest);
    } catch (e) {
      return ResultError(
        'Failed to update quest: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> deleteQuest(String id) async {
    try {
      await _localDataSource.deleteQuest(id);
      return const Success(null);
    } catch (e) {
      return ResultError(
        'Failed to delete quest: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Quest>> completeQuest(String id) async {
    try {
      final questResult = await getQuestById(id);
      return questResult.when(
        success: (quest) async {
          final completed = Quest(
            id: quest.id,
            title: quest.title,
            description: quest.description,
            type: quest.type,
            category: quest.category,
            difficulty: quest.difficulty,
            reward: quest.reward,
            tasks: quest.tasks,
            milestones: quest.milestones,
            deadline: quest.deadline,
            status: QuestStatus.completed,
            progressPercentage: 100.0,
            createdAt: quest.createdAt,
            completedAt: DateTime.now(),
          );
          await _localDataSource.upsertQuest(completed);
          return Success(completed);
        },
        failure: (message, exception) async =>
            ResultError(message, exception: exception),
      );
    } catch (e) {
      return ResultError(
        'Failed to complete quest: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<double>> calculateQuestProgress(String questId) async {
    try {
      final questResult = await getQuestById(questId);
      return questResult.when(
        success: (quest) => Success(QuestProgressCalculator.calculateProgress(quest)),
        failure: (message, exception) => ResultError(message, exception: exception),
      );
    } catch (e) {
      return ResultError(
        'Failed to calculate progress: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}

