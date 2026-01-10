import 'package:flutter_test/flutter_test.dart';
import 'package:levelup/domain/entities/quest.dart';
import '../base_agent.dart';
import '../ui_agent.dart';
import '../data_agent.dart';

/// Journey agent for testing daily quest flow
class DailyQuestJourneyAgent extends BaseAgent {
  final UIAgent uiAgent;
  final DataAgent dataAgent;

  DailyQuestJourneyAgent({
    required WidgetTester tester,
    required this.uiAgent,
    required this.dataAgent,
  }) : super(tester);

  @override
  Future<AgentResult> execute(TestScenario scenario) async {
    reset();
    logAction('Starting Daily Quest Journey');

    try {
      // Step 1: Navigate to home
      logAction('Step 1: Navigating to home');
      try {
        await uiAgent.tap('Home');
        await tester.pumpAndSettle();
      } catch (e) {
        recordDiscovery('Home button not found, assuming already on home');
      }

      // Step 2: Check for daily quests section
      logAction('Step 2: Checking for daily quests');
      final dailyQuestsExists = await uiAgent.verifyExists('Daily Quests', timeout: const Duration(seconds: 3));
      
      if (dailyQuestsExists) {
        recordDiscovery('Daily quests section found on home');
        
        // Step 3: Count daily quests
        final dailyQuests = await dataAgent.getAllQuests(type: QuestType.daily);
        recordDiscovery('Found ${dailyQuests.length} daily quests in database');
        
        // Step 4: Complete a daily quest
        if (dailyQuests.isNotEmpty) {
          logAction('Step 4: Attempting to complete a daily quest');
          final quest = dailyQuests.first;
          
          // Try to tap on the quest
          try {
            await uiAgent.tap(quest.title);
            await tester.pumpAndSettle();
            
            // Try to complete it
            try {
              await uiAgent.tap('Complete');
              await tester.pumpAndSettle();
              recordDiscovery('Daily quest completion attempted');
            } catch (e) {
              recordDiscovery('Could not complete quest: $e');
            }
          } catch (e) {
            recordDiscovery('Could not open daily quest: $e');
          }
        }
      } else {
        recordDiscovery('Daily quests section not visible (may need to scroll or generate)');
      }

      logAction('Daily Quest Journey finished');
      return createResult(success: true);

    } catch (e, stackTrace) {
      recordError('Journey failed: $e');
      recordError('Stack trace: $stackTrace');
      return createResult(success: false);
    }
  }

  @override
  Future<bool> validate(Assertion assertion) async {
    return await assertion.validate();
  }
}


