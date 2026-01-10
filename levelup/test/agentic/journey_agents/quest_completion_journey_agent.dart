import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup/domain/entities/quest.dart';
import 'package:levelup/core/di/injection_container.dart';
import 'package:levelup/domain/repositories/onboarding_repository.dart';
import 'package:levelup/domain/repositories/auth_repository.dart';
import 'package:levelup/domain/repositories/player_repository.dart';
import 'package:levelup/src/routing/app_routes.dart';
import 'package:levelup/core/utils/id_generator.dart';
import 'package:levelup/core/utils/result.dart';
import '../base_agent.dart';
import '../ui_agent.dart';
import '../data_agent.dart';

/// Journey agent for testing quest completion flow
class QuestCompletionJourneyAgent extends BaseAgent {
  final UIAgent uiAgent;
  final DataAgent dataAgent;

  QuestCompletionJourneyAgent({
    required WidgetTester tester,
    required this.uiAgent,
    required this.dataAgent,
  }) : super(tester);

  /// Ensure onboarding is completed and user is logged in
  /// Note: This is a fallback in case pre-setup in setUpAll didn't work
  Future<void> _ensureOnboardingAndLogin() async {
    logAction('Checking onboarding and login status');

    // Wait a bit for splash screen navigation
    await tester.pump(const Duration(milliseconds: 500));
    
    // Quick check if we're still on onboarding/login screens
    // (should be pre-setup in setUpAll, but handle just in case)
    final onboardingExists = await uiAgent.verifyExists('LevelUp', timeout: const Duration(milliseconds: 500));
    final loginExists = await uiAgent.verifyExists('Login', timeout: const Duration(milliseconds: 500));
    
    if (onboardingExists) {
      logAction('Onboarding detected (unexpected), skipping...');
      try {
        await uiAgent.tap('Skip');
        await tester.pump(const Duration(seconds: 1));
      } catch (e) {
        try {
          await uiAgent.tap('Start');
          await tester.pump(const Duration(seconds: 1));
        } catch (e2) {
          // Ignore
        }
      }
    }
    
    if (loginExists) {
      logAction('Login screen detected (unexpected), this should have been handled in setUpAll');
      recordDiscovery('Login screen still showing - test setup may need adjustment');
    }

    // Wait for any navigation
    await tester.pump(const Duration(milliseconds: 500));
  }

  @override
  Future<AgentResult> execute(TestScenario scenario) async {
    reset();
    logAction('Starting Quest Completion Journey');

    try {
      // Step 0: Ensure onboarding and login
      await _ensureOnboardingAndLogin();

      // Step 1: Navigate to quest list using GoRouter
      logAction('Step 1: Navigating to quest list');
      try {
        // Get context from MaterialApp
        final materialAppFinder = find.byType(MaterialApp);
        if (materialAppFinder.evaluate().isNotEmpty) {
          final context = tester.element(materialAppFinder.first);
          GoRouter.of(context).go(AppRoutes.quests);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else {
          throw Exception('MaterialApp not found');
        }
      } catch (e) {
        // Fallback: Try to tap "Quests" if navigation failed
        recordDiscovery('GoRouter navigation failed, trying UI tap: $e');
        try {
          await uiAgent.tap('Quests');
          await tester.pumpAndSettle();
        } catch (e2) {
          recordError('Could not navigate to quests: $e2');
          return createResult(success: false);
        }
      }

      // Step 2: Create a new quest
      logAction('Step 2: Creating new quest');
      // Try to find "Create Quest" button or navigate directly
      try {
        await uiAgent.tap('Create Quest');
        await tester.pumpAndSettle();
      } catch (e) {
        // Try to navigate directly to quest create screen
        try {
          final materialAppFinder = find.byType(MaterialApp);
          if (materialAppFinder.evaluate().isNotEmpty) {
            final context = tester.element(materialAppFinder.first);
            GoRouter.of(context).go(AppRoutes.questCreate);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          } else {
            throw Exception('MaterialApp not found');
          }
        } catch (e2) {
          recordError('Could not navigate to quest create: $e2');
          return createResult(success: false);
        }
      }

      // Step 3: Fill quest form
      logAction('Step 3: Fill quest form');
      // Title field (label: "Title")
      await uiAgent.enterText('Title', 'Agentic Test Quest');
      await tester.pumpAndSettle();
      
      // Try to enter description if field exists (label: "Description (optional)")
      try {
        await uiAgent.enterText('Description', 'This quest was created by an AI agent');
        await tester.pumpAndSettle();
      } catch (e) {
        recordDiscovery('Description field not found or not required: $e');
      }

      // Try to add tasks (label: "Tasks (one per line)")
      try {
        await uiAgent.enterText('Tasks', 'Task 1\nTask 2\nTask 3');
        await tester.pumpAndSettle();
      } catch (e) {
        recordDiscovery('Tasks field not found or not required: $e');
      }

      // Step 4: Save quest
      logAction('Step 4: Saving quest');
      await uiAgent.tap('Create');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 5: Verify quest created
      logAction('Step 5: Verifying quest creation');
      final questExists = await uiAgent.verifyExists('Agentic Test Quest');
      if (!questExists) {
        recordError('Quest not visible in UI after creation');
      }

      // Get quest from database to verify
      final allQuests = await dataAgent.getAllQuests();
      final createdQuest = allQuests.firstWhere(
        (q) => q.title.contains('Agentic Test Quest'),
        orElse: () => throw Exception('Quest not found in database'),
      );
      
      recordDiscovery('Quest created with ID: ${createdQuest.id}');
      recordDiscovery('Quest status: ${createdQuest.status}');

      // Step 6: Open quest detail
      logAction('Step 6: Opening quest detail');
      await uiAgent.tap('Agentic Test Quest');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 7: Complete tasks if any exist
      logAction('Step 7: Checking for tasks');
      final taskExists = await uiAgent.verifyExists('Task', timeout: const Duration(seconds: 2));
      
      if (taskExists) {
        logAction('Completing first task');
        // Try to find and tap first task
        try {
          // Look for checkbox or task item
          final taskCheckbox = find.byType(Checkbox).first;
          if (taskCheckbox.evaluate().isNotEmpty) {
            await tester.tap(taskCheckbox);
            await tester.pumpAndSettle();
            recordDiscovery('Task completed');
          }
        } catch (e) {
          recordDiscovery('Could not complete task automatically: $e');
        }
      } else {
        recordDiscovery('No tasks found in quest');
      }

      // Step 8: Complete quest
      logAction('Step 8: Completing quest');
      try {
        await uiAgent.tap('Complete');
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } catch (e) {
        // Try alternative button text
        try {
          await uiAgent.tap('Complete Quest');
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } catch (e2) {
          recordError('Could not find complete button: $e2');
          return createResult(success: false);
        }
      }

      // Step 9: Claim rewards
      logAction('Step 9: Claiming rewards');
      final rewardScreenExists = await uiAgent.verifyExists('Rewards', timeout: const Duration(seconds: 3));
      
      if (rewardScreenExists) {
        recordDiscovery('Reward screen appeared');
        
        // Verify rewards are displayed
        final xpDisplayed = await uiAgent.verifyExists('XP', timeout: const Duration(seconds: 2));
        final currencyDisplayed = await uiAgent.verifyExists('Gold', timeout: const Duration(seconds: 2));
        
        if (xpDisplayed) recordDiscovery('XP reward displayed');
        if (currencyDisplayed) recordDiscovery('Currency reward displayed');
        
        // Continue to claim
        await uiAgent.tap('Continue');
        await tester.pumpAndSettle();
      } else {
        recordDiscovery('Reward screen did not appear (may have auto-claimed)');
      }

      // Step 10: Verify quest completed in database
      logAction('Step 10: Verifying quest completion');
      final updatedQuest = await dataAgent.verifyQuestExists(
        questId: createdQuest.id,
        expectedData: {'status': QuestStatus.completed},
      );

      if (!updatedQuest) {
        recordError('Quest not marked as completed in database');
      }

      // Step 11: Verify player stats updated
      logAction('Step 11: Verifying player stats');
      final player = await dataAgent.getPlayer();
      if (player != null) {
        recordDiscovery('Player level: ${player.level}');
        recordDiscovery('Player XP: ${player.experience}');
        recordDiscovery('Player currency: ${player.currency}');
        recordDiscovery('Quests completed: ${player.stats.totalQuestsCompleted}');
      } else {
        recordError('Could not retrieve player data');
      }

      logAction('Quest Completion Journey finished successfully');
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

