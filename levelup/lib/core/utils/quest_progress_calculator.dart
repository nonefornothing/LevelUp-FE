import '../../domain/entities/quest.dart';
import '../constants/app_constants.dart';

/// Utility class untuk calculate quest progress
class QuestProgressCalculator {
  /// Calculate quest progress berdasarkan formula:
  /// 50% tasks + 30% milestones + 20% final objective
  static double calculateProgress(Quest quest) {
    if (quest.tasks.isEmpty && quest.milestones.isEmpty) {
      return quest.status == QuestStatus.completed ? 100.0 : 0.0;
    }

    // 50% dari tasks completion
    double taskProgress = 0.0;
    if (quest.tasks.isNotEmpty) {
      final completedTasks = quest.tasks.where((t) => t.isCompleted).length;
      taskProgress = (completedTasks / quest.tasks.length) *
          AppConstants.questProgressTaskWeight;
    }

    // 30% dari milestones
    double milestoneProgress = 0.0;
    if (quest.milestones.isNotEmpty) {
      final completedMilestones =
          quest.milestones.where((m) => m.isCompleted).length;
      milestoneProgress = (completedMilestones / quest.milestones.length) *
          AppConstants.questProgressMilestoneWeight;
    }

    // 20% dari final objective (quest completion)
    final objectiveProgress = quest.status == QuestStatus.completed
        ? AppConstants.questProgressObjectiveWeight
        : 0.0;

    final totalProgress = (taskProgress + milestoneProgress + objectiveProgress) * 100;
    return totalProgress.clamp(0.0, 100.0);
  }
}

