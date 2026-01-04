import '../../../../domain/entities/quest.dart';

class QuestState {
  final bool loading;
  final String? error;
  final List<Quest> quests;
  final Quest? selectedQuest;

  const QuestState({
    required this.loading,
    required this.quests,
    this.selectedQuest,
    this.error,
  });

  factory QuestState.initial() => const QuestState(
        loading: false,
        quests: [],
        selectedQuest: null,
        error: null,
      );

  QuestState copyWith({
    bool? loading,
    String? error,
    List<Quest>? quests,
    Quest? selectedQuest,
  }) {
    return QuestState(
      loading: loading ?? this.loading,
      error: error,
      quests: quests ?? this.quests,
      selectedQuest: selectedQuest ?? this.selectedQuest,
    );
  }
}


