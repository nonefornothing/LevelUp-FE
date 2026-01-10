import 'package:flutter_test/flutter_test.dart';
import 'package:levelup/main.dart';
import 'package:levelup/domain/entities/quest.dart';
import 'package:levelup/core/di/injection_container.dart';
import 'package:levelup/domain/repositories/onboarding_repository.dart';
import 'package:levelup/data/datasources/auth_local_datasource.dart';
import 'package:levelup/domain/repositories/player_repository.dart';
import 'package:levelup/core/utils/id_generator.dart';
import 'package:levelup/core/utils/result.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../helpers/test_helpers.dart';
import '../ui_agent.dart';
import '../data_agent.dart';
import '../base_agent.dart';
import '../journey_agents/quest_completion_journey_agent.dart';

void main() {

  group('Quest Completion Journey - Agentic Test', () {
    setUpAll(() async {
      await setupTestEnvironment();
      
      // Pre-setup: Complete onboarding
      final onboardingRepo = sl<OnboardingRepository>();
      await onboardingRepo.setCompleted(true);
      
      // Pre-setup: Create test user and login state directly in Hive
      final authDataSource = sl<AuthLocalDataSource>();
      final testEmail = 'test@example.com';
      final testPassword = 'testpassword123';
      
      // Generate token and userId (same way as AuthRepositoryImpl)
      String hash(String input) {
        final bytes = utf8.encode(input);
        return sha256.convert(bytes).toString();
      }
      
      final token = hash('$testEmail:$testPassword');
      final userId = hash(testEmail).substring(0, 16);
      
      await authDataSource.setAuthToken(token);
      await authDataSource.setUserId(userId);
      
      // Ensure player exists
      final playerRepo = sl<PlayerRepository>();
      final playerResult = await playerRepo.getPlayer();
      if (playerResult is ResultError) {
        // Player doesn't exist, create one
        // This will be handled by AuthBloc._ensurePlayer when app starts
      }
    });

    tearDownAll(() async {
      await teardownTestEnvironment();
    });

    testWidgets('Complete quest from creation to reward (Agentic)', (tester) async {
      // Build app
      await tester.pumpWidget(const MyGameApp());
      
      // Wait for splash screen (2 seconds delay) and navigation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2)); // Wait for splash delay
      await tester.pump(const Duration(milliseconds: 500)); // Wait for navigation
      
      // Wait for home screen to load (skip onboarding/login since already done)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Setup agents
      final uiAgent = UIAgent(tester);
      final dataAgent = DataAgent(tester);
      final journeyAgent = QuestCompletionJourneyAgent(
        tester: tester,
        uiAgent: uiAgent,
        dataAgent: dataAgent,
      );

      // Define scenario
      final scenario = TestScenario(
        name: 'Quest Completion Journey',
        description: 'Test complete quest lifecycle from creation to reward',
        steps: [],
        assertions: [
          Assertion(
            description: 'Quest should be created',
            validate: () async {
              final quests = await dataAgent.getAllQuests();
              return quests.any((q) => q.title.contains('Agentic Test Quest'));
            },
          ),
          Assertion(
            description: 'Quest should be completed',
            validate: () async {
              final quests = await dataAgent.getAllQuests();
              final quest = quests.firstWhere(
                (q) => q.title.contains('Agentic Test Quest'),
                orElse: () => throw Exception('Quest not found'),
              );
              return quest.status == QuestStatus.completed;
            },
          ),
          Assertion(
            description: 'Player stats should be updated',
            validate: () async {
              final player = await dataAgent.getPlayer();
              return player != null && player.stats.totalQuestsCompleted > 0;
            },
          ),
        ],
      );

      // Execute journey
      final result = await journeyAgent.execute(scenario);

      // Validate assertions
      // ignore: avoid_print
      print('\n${'=' * 60}');
      // ignore: avoid_print
      print('AGENTIC TEST RESULT');
      // ignore: avoid_print
      print('${'=' * 60}');
      // ignore: avoid_print
      print(result.toString());
      // ignore: avoid_print
      print('${'=' * 60}\n');

      // Validate all assertions
      bool allAssertionsPassed = true;
      for (final assertion in scenario.assertions) {
        final passed = await journeyAgent.validate(assertion);
        if (!passed) {
          allAssertionsPassed = false;
          // ignore: avoid_print
          print('❌ Assertion failed: ${assertion.description}');
        } else {
          // ignore: avoid_print
          print('✅ Assertion passed: ${assertion.description}');
        }
      }

      // Verify result
      expect(result.success, true, reason: 'Journey should complete successfully');
      expect(result.errors.isEmpty, true, reason: 'No errors should occur');
      expect(allAssertionsPassed, true, reason: 'All assertions should pass');
    });
  });
}

