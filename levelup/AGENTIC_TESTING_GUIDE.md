# 🤖 Agentic Testing Guide for LevelUp

## 🎯 Overview

This guide explains how to implement and use **Agentic Testing** for the LevelUp application. Agentic testing uses AI agents to simulate realistic user behavior and validate complex workflows.

---

## 🔍 What is Agentic Testing?

Traditional automated testing:
- ✅ Scripted, predictable
- ✅ Fast execution
- ❌ Brittle (breaks on UI changes)
- ❌ Doesn't discover new issues
- ❌ Limited to predefined scenarios

Agentic Testing:
- ✅ Adapts to UI changes
- ✅ Discovers edge cases
- ✅ Simulates realistic behavior
- ✅ Uses AI for validation
- ✅ Generates scenarios dynamically

---

## 🏗️ Architecture

### **Components**

1. **Test Agent**: AI-powered test executor
2. **UI Agent**: Interacts with UI elements
3. **Data Agent**: Validates data state
4. **Scenario Generator**: Creates test scenarios
5. **Result Validator**: Validates outcomes

### **Flow**

```
User Request
    ↓
Scenario Generator → Creates Test Scenario
    ↓
Test Agent → Executes Scenario
    ↓
UI Agent → Interacts with UI
Data Agent → Validates Data
    ↓
Result Validator → Validates Outcome
    ↓
Test Report
```

---

## 💻 Implementation

### **Step 1: Setup Dependencies**

Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  # Agentic testing (custom or use existing)
  integration_test:
  # For AI capabilities
  # You'll need to integrate with:
  # - OpenAI API (for GPT-4 Vision)
  # - Google Gemini API (for multimodal)
  # - Or custom AI service
```

### **Step 2: Create Base Agent**

```dart
// lib/test/agentic/base_agent.dart

abstract class BaseAgent {
  Future<AgentResult> execute(TestScenario scenario);
  Future<bool> validate(Assertion assertion);
}

class AgentResult {
  final bool success;
  final List<String> actions;
  final List<String> discoveries;
  final Map<String, dynamic> observations;
  
  AgentResult({
    required this.success,
    required this.actions,
    required this.discoveries,
    this.observations = const {},
  });
}
```

### **Step 3: Implement UI Agent**

```dart
// lib/test/agentic/ui_agent.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class UIAgent {
  final WidgetTester tester;
  
  UIAgent(this.tester);
  
  /// Tap on element (multiple strategies)
  Future<void> tap(String description) async {
    // Strategy 1: Find by text
    try {
      await tester.tap(find.text(description));
      await tester.pumpAndSettle();
      return;
    } catch (e) {
      // Try next strategy
    }
    
    // Strategy 2: Find by key
    try {
      await tester.tap(find.byKey(Key(description)));
      await tester.pumpAndSettle();
      return;
    } catch (e) {
      // Try next strategy
    }
    
    // Strategy 3: Use AI to locate element
    await _aiLocateAndTap(description);
  }
  
  /// Enter text intelligently
  Future<void> enterText(String fieldDescription, String text) async {
    // Try to find field
    final field = await _findTextField(fieldDescription);
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
  }
  
  /// Verify element exists
  Future<bool> verifyExists(String description) async {
    final finders = [
      find.text(description),
      find.byKey(Key(description)),
      find.textContaining(description),
    ];
    
    for (final finder in finders) {
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
    
    return false;
  }
  
  /// AI-powered element location
  Future<void> _aiLocateAndTap(String description) async {
    // Take screenshot
    final screenshot = await takeScreenshot();
    
    // Use AI Vision API to find element
    // final elementLocation = await aiVision.findElement(
    //   screenshot: screenshot,
    //   description: description,
    // );
    
    // Tap on located element
    // await tester.tapAt(elementLocation);
  }
  
  /// Analyze screen using AI
  Future<ScreenAnalysis> analyzeScreen() async {
    final screenshot = await takeScreenshot();
    
    // Use AI to analyze screen
    // final analysis = await aiVision.analyzeScreen(screenshot);
    
    return ScreenAnalysis(
      widgets: [],
      textElements: [],
      interactiveElements: [],
      suggestions: [],
    );
  }
  
  Future<List<int>> takeScreenshot() async {
    // Implementation for taking screenshot
    return [];
  }
}

class ScreenAnalysis {
  final List<String> widgets;
  final List<String> textElements;
  final List<String> interactiveElements;
  final List<String> suggestions;
  
  ScreenAnalysis({
    required this.widgets,
    required this.textElements,
    required this.interactiveElements,
    required this.suggestions,
  });
}
```

### **Step 4: Implement Data Agent**

```dart
// lib/test/agentic/data_agent.dart

import 'package:hive/hive.dart';
import '../../data/datasources/local_storage.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/player.dart';

class DataAgent {
  /// Verify quest exists in database
  Future<bool> verifyQuestExists({
    required String questId,
    Map<String, dynamic>? expectedData,
  }) async {
    final box = Hive.box<QuestHiveModel>(HiveLocalStorage.questBoxName);
    final quest = box.get(questId);
    
    if (quest == null) return false;
    
    if (expectedData != null) {
      // Verify expected data matches
      final domainQuest = quest.toDomain();
      // Compare fields...
    }
    
    return true;
  }
  
  /// Verify player data
  Future<bool> verifyPlayerData({
    required Map<String, dynamic> expected,
  }) async {
    final box = Hive.box<PlayerHiveModel>(HiveLocalStorage.playerBoxName);
    // Verify player data matches expected
    return true;
  }
  
  /// Get all quests
  Future<List<Quest>> getAllQuests() async {
    final box = Hive.box<QuestHiveModel>(HiveLocalStorage.questBoxName);
    return box.values.map((m) => m.toDomain()).toList();
  }
  
  /// Discover data anomalies
  Future<List<String>> discoverAnomalies() async {
    final anomalies = <String>[];
    
    // Check for orphaned tasks
    // Check for invalid progress percentages
    // Check for missing relationships
    
    return anomalies;
  }
}
```

### **Step 5: Create Journey Agent**

```dart
// lib/test/agentic/journey_agent.dart

class QuestCompletionJourneyAgent extends BaseAgent {
  final UIAgent uiAgent;
  final DataAgent dataAgent;
  
  QuestCompletionJourneyAgent({
    required this.uiAgent,
    required this.dataAgent,
  });
  
  @override
  Future<AgentResult> execute(TestScenario scenario) async {
    final actions = <String>[];
    final discoveries = <String>[];
    
    try {
      // 1. Navigate to quest list
      await uiAgent.tap('Quests');
      actions.add('Navigated to quest list');
      await Future.delayed(Duration(milliseconds: 500));
      
      // 2. Create a new quest
      await uiAgent.tap('Create Quest');
      actions.add('Opened quest creation');
      
      // 3. Fill quest form
      await uiAgent.enterText('Quest Title', 'Test Quest');
      await uiAgent.enterText('Description', 'This is a test quest');
      actions.add('Filled quest form');
      
      // 4. Save quest
      await uiAgent.tap('Save');
      actions.add('Saved quest');
      await Future.delayed(Duration(milliseconds: 500));
      
      // 5. Verify quest created
      final questExists = await dataAgent.verifyQuestExists(
        questId: 'test_quest_id', // Would need to extract from UI
      );
      
      if (!questExists) {
        discoveries.add('Quest not found in database after creation');
      }
      
      // 6. Open quest detail
      await uiAgent.tap('Test Quest');
      actions.add('Opened quest detail');
      
      // 7. Complete a task
      await uiAgent.tap('Task 1');
      actions.add('Completed task');
      
      // 8. Verify progress updated
      final progress = await _getQuestProgress();
      discoveries.add('Quest progress: $progress%');
      
      // 9. Complete quest
      await uiAgent.tap('Complete Quest');
      actions.add('Completed quest');
      
      // 10. Claim rewards
      await uiAgent.tap('Claim Rewards');
      actions.add('Claimed rewards');
      
      // 11. Verify rewards applied
      final playerUpdated = await dataAgent.verifyPlayerData(
        expected: {'level': 2}, // Assuming level up
      );
      
      return AgentResult(
        success: questExists && playerUpdated,
        actions: actions,
        discoveries: discoveries,
      );
    } catch (e) {
      discoveries.add('Error during execution: $e');
      return AgentResult(
        success: false,
        actions: actions,
        discoveries: discoveries,
      );
    }
  }
  
  @override
  Future<bool> validate(Assertion assertion) async {
    // Implement validation logic
    return true;
  }
  
  Future<double> _getQuestProgress() async {
    // Extract progress from UI or data
    return 0.0;
  }
}
```

### **Step 6: Create Test Scenario**

```dart
// test/agentic/scenarios/quest_completion_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../../lib/test/agentic/journey_agent.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Quest Completion Journey', () {
    testWidgets('Complete quest from creation to reward', (tester) async {
      // Setup
      final uiAgent = UIAgent(tester);
      final dataAgent = DataAgent();
      final agent = QuestCompletionJourneyAgent(
        uiAgent: uiAgent,
        dataAgent: dataAgent,
      );
      
      // Execute
      final result = await agent.execute(TestScenario(
        name: 'Quest Completion',
        steps: [],
      ));
      
      // Validate
      expect(result.success, true);
      expect(result.discoveries, isEmpty);
      
      // Print actions for debugging
      print('Actions taken:');
      for (final action in result.actions) {
        print('  - $action');
      }
    });
  });
}
```

---

## 🚀 Running Agentic Tests

### **Basic Run**
```bash
flutter test test/agentic/
```

### **With Coverage**
```bash
flutter test test/agentic/ --coverage
```

### **Specific Scenario**
```bash
flutter test test/agentic/scenarios/quest_completion_test.dart
```

---

## 📊 Best Practices

1. **Make Agents Resilient**
   - Multiple strategies for finding elements
   - Graceful error handling
   - Recovery mechanisms

2. **Use AI Wisely**
   - Use AI for complex scenarios
   - Use traditional methods for simple checks
   - Balance speed vs. intelligence

3. **Document Discoveries**
   - Log all findings
   - Report edge cases
   - Track improvements

4. **Iterative Improvement**
   - Refine agents based on results
   - Add new strategies
   - Expand test coverage

---

## 🎯 Next Steps

1. Implement base agent framework
2. Create first journey agent
3. Integrate AI vision API
4. Run initial agentic tests
5. Expand test scenarios

---

**Status**: Implementation Guide  
**Ready**: For Development  
**Focus**: AI-Powered Testing

