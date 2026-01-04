import '../../../../domain/entities/quest.dart';

abstract class QuestEvent {}

class LoadQuests extends QuestEvent {
  final QuestType? type;
  final QuestStatus? status;
  LoadQuests({this.type, this.status});
}

class LoadQuestById extends QuestEvent {
  final String id;
  LoadQuestById(this.id);
}

class CreateQuestRequested extends QuestEvent {
  final Quest quest;
  CreateQuestRequested(this.quest);
}

class UpdateQuestRequested extends QuestEvent {
  final Quest quest;
  UpdateQuestRequested(this.quest);
}

class DeleteQuestRequested extends QuestEvent {
  final String id;
  DeleteQuestRequested(this.id);
}

class CompleteQuestRequested extends QuestEvent {
  final String id;
  CompleteQuestRequested(this.id);
}


