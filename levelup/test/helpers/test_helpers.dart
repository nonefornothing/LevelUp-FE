import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:levelup/core/di/injection_container.dart' show sl;
import 'package:levelup/data/models/quest_hive_models.dart';
import 'package:levelup/data/models/player_hive_models.dart';
import 'package:levelup/data/datasources/quest_local_datasource.dart';
import 'package:levelup/data/datasources/player_local_datasource.dart';
import 'package:levelup/data/datasources/auth_local_datasource.dart';
import 'package:levelup/data/datasources/onboarding_local_datasource.dart';
import 'package:levelup/domain/repositories/quest_repository.dart';
import 'package:levelup/data/repositories/quest_repository_impl.dart';
import 'package:levelup/domain/repositories/player_repository.dart';
import 'package:levelup/data/repositories/player_repository_impl.dart';
import 'package:levelup/domain/repositories/auth_repository.dart';
import 'package:levelup/data/repositories/auth_repository_impl.dart';
import 'package:levelup/domain/repositories/onboarding_repository.dart';
import 'package:levelup/data/repositories/onboarding_repository_impl.dart';
import 'package:levelup/core/services/daily_quest_service.dart';
import 'package:levelup/src/features/Player/bloc/player_bloc.dart';

/// Initialize test environment
Future<void> setupTestEnvironment() async {
  // Setup test Hive database in temp directory
  // Use system temp directory directly for tests
  final tempDir = Directory.systemTemp;
  final testPath = path.join(tempDir.path, 'levelup_test');
  
  // Create test directory if it doesn't exist
  final testDir = Directory(testPath);
  if (!await testDir.exists()) {
    await testDir.create(recursive: true);
  }
  
  // Close Hive if already initialized
  if (Hive.isBoxOpen('quests') || Hive.isBoxOpen('player') || Hive.isBoxOpen('preferences')) {
    try {
      await Hive.close();
    } catch (e) {
      // Ignore if already closed
    }
  }
  
  // Initialize Hive with test path (not initFlutter which needs path_provider)
  try {
    Hive.init(testPath);
  } catch (e) {
    // Already initialized, that's fine
  }
  
  // Register adapters
  if (!Hive.isAdapterRegistered(QuestHiveModelAdapter().typeId)) {
    Hive.registerAdapter(QuestHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(QuestTaskHiveModelAdapter().typeId)) {
    Hive.registerAdapter(QuestTaskHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(QuestMilestoneHiveModelAdapter().typeId)) {
    Hive.registerAdapter(QuestMilestoneHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(PlayerHiveModelAdapter().typeId)) {
    Hive.registerAdapter(PlayerHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(PlayerStatsHiveModelAdapter().typeId)) {
    Hive.registerAdapter(PlayerStatsHiveModelAdapter());
  }
  
  // Open boxes directly (bypass LocalStorage.init() which uses path_provider)
  try {
    await Hive.openBox<QuestHiveModel>('quests');
  } catch (e) {
    // Box already open
  }
  try {
    await Hive.openBox<PlayerHiveModel>('player');
  } catch (e) {
    // Box already open
  }
  try {
    await Hive.openBox('preferences');
  } catch (e) {
    // Box already open
  }
  
  // Initialize DI (but skip LocalStorage.init since we already set up Hive)
  await sl.reset();
  
  // Manually register everything except LocalStorage
  sl.registerLazySingleton<QuestLocalDataSource>(() => QuestLocalDataSourceImpl());
  sl.registerLazySingleton<PlayerLocalDataSource>(() => PlayerLocalDataSourceImpl());
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl());
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(),
  );
  
  sl.registerLazySingleton<QuestRepository>(
    () => QuestRepositoryImpl(localDataSource: sl<QuestLocalDataSource>()),
  );
  
  sl.registerLazySingleton<PlayerRepository>(
    () => PlayerRepositoryImpl(localDataSource: sl<PlayerLocalDataSource>()),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl<AuthLocalDataSource>()),
  );
  
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(localDataSource: sl<OnboardingLocalDataSource>()),
  );
  
  // Services
  sl.registerLazySingleton<DailyQuestService>(
    () => DailyQuestService(
      questRepository: sl<QuestRepository>(),
      playerRepository: sl<PlayerRepository>(),
      questDataSource: sl<QuestLocalDataSource>(),
      playerDataSource: sl<PlayerLocalDataSource>(),
    ),
  );
  
  // BLoCs
  sl.registerFactory<PlayerBloc>(
    () => PlayerBloc(playerRepository: sl<PlayerRepository>()),
  );
}

/// Clean up test environment
Future<void> teardownTestEnvironment() async {
  // Close all Hive boxes
  await Hive.close();
  
  // Clean up temp directory
  try {
    final tempDir = Directory.systemTemp;
    final testPath = path.join(tempDir.path, 'levelup_test');
    final dir = Directory(testPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  } catch (e) {
    // Ignore cleanup errors
  }
  
  // Reset DI
  await sl.reset();
}

/// Find widget by multiple strategies
Finder findWidgetByText(String text, {bool exact = true}) {
  if (exact) {
    return find.text(text);
  }
  return find.textContaining(text);
}

/// Wait for widget to appear
Future<void> waitForWidget(Finder finder, WidgetTester tester, {Duration timeout = const Duration(seconds: 5)}) async {
  final endTime = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(endTime)) {
    await tester.pump();
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }
  throw Exception('Widget not found: $finder');
}

/// Tap widget with retry
Future<void> tapWithRetry(WidgetTester tester, Finder finder, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder);
        await tester.pumpAndSettle();
        return;
      }
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }
  }
  throw Exception('Could not tap widget: $finder');
}

/// Enter text with retry
Future<void> enterTextWithRetry(WidgetTester tester, Finder finder, String text, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      if (finder.evaluate().isNotEmpty) {
        await tester.enterText(finder, text);
        await tester.pumpAndSettle();
        return;
      }
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }
  }
  throw Exception('Could not enter text in widget: $finder');
}

