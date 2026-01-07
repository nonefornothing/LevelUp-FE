import 'package:get_it/get_it.dart';
import '../../data/repositories/quest_repository_impl.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/datasources/quest_local_datasource.dart';
import '../../data/datasources/player_local_datasource.dart';
import '../../domain/repositories/player_repository.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/onboarding_local_datasource.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../data/datasources/achievement_local_datasource.dart';
import '../../data/repositories/achievement_repository_impl.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../../data/datasources/weekly_challenge_local_datasource.dart';
import '../../data/repositories/weekly_challenge_repository_impl.dart';
import '../../domain/repositories/weekly_challenge_repository.dart';
import '../../data/datasources/inventory_local_datasource.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../data/datasources/notification_local_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/datasources/social_local_datasource.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../domain/repositories/social_repository.dart';
import '../../data/datasources/quest_template_local_datasource.dart';
import '../../data/repositories/quest_template_repository_impl.dart';
import '../../domain/repositories/quest_template_repository.dart';
import '../../data/datasources/streak_local_datasource.dart';
import '../../data/repositories/streak_repository_impl.dart';
import '../../domain/repositories/streak_repository.dart';
import '../../src/features/Player/bloc/player_bloc.dart';
import '../../core/services/daily_quest_service.dart';
import '../../core/services/achievement_service.dart';
import '../../core/services/weekly_challenge_service.dart';
import '../../core/services/quest_recommendation_service.dart';
import '../../core/services/inventory_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/social_service.dart';
import '../../core/services/quest_template_service.dart';
import '../../core/services/streak_service.dart';
import '../../core/services/skill_service.dart';
import '../../core/services/local_notification_service.dart';
import '../../src/features/Social/bloc/social_bloc.dart';
import '../../src/features/QuestTemplates/bloc/quest_template_bloc.dart';
import '../../src/features/Streaks/bloc/streak_bloc.dart';
import '../../src/features/Skills/bloc/skill_bloc.dart';
import '../../data/datasources/skill_local_datasource.dart';
import '../../data/repositories/skill_repository_impl.dart';
import '../../domain/repositories/skill_repository.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize dependency injection container
Future<void> init() async {
  // Data Sources
  sl.registerLazySingleton<LocalStorage>(() => HiveLocalStorage());
  
  // Initialize local storage
  await sl<LocalStorage>().init();

  sl.registerLazySingleton<QuestLocalDataSource>(() => QuestLocalDataSourceImpl());
  sl.registerLazySingleton<PlayerLocalDataSource>(() => PlayerLocalDataSourceImpl());
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl());
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AchievementLocalDataSource>(
    () => AchievementLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<WeeklyChallengeLocalDataSource>(
    () => WeeklyChallengeLocalDataSource(),
  );
  sl.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSource(),
  );
  sl.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSource(),
  );
  sl.registerLazySingleton<SocialLocalDataSource>(
    () => SocialLocalDataSource(),
  );
  sl.registerLazySingleton<QuestTemplateLocalDataSource>(
    () => QuestTemplateLocalDataSource(),
  );
  sl.registerLazySingleton<StreakLocalDataSource>(
    () => StreakLocalDataSource(),
  );
  sl.registerLazySingleton<SkillLocalDataSource>(
    () => SkillLocalDataSource(),
  );

  // Repositories
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

  sl.registerLazySingleton<AchievementRepository>(
    () => AchievementRepositoryImpl(localDataSource: sl<AchievementLocalDataSource>()),
  );

  sl.registerLazySingleton<WeeklyChallengeRepository>(
    () => WeeklyChallengeRepositoryImpl(dataSource: sl<WeeklyChallengeLocalDataSource>()),
  );

  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(dataSource: sl<InventoryLocalDataSource>()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(dataSource: sl<NotificationLocalDataSource>()),
  );

  sl.registerLazySingleton<SocialRepository>(
    () => SocialRepositoryImpl(sl<SocialLocalDataSource>()),
  );

  sl.registerLazySingleton<QuestTemplateRepository>(
    () => QuestTemplateRepositoryImpl(sl<QuestTemplateLocalDataSource>()),
  );

  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepositoryImpl(localDataSource: sl<StreakLocalDataSource>()),
  );

  sl.registerLazySingleton<SkillRepository>(
    () => SkillRepositoryImpl(localDataSource: sl<SkillLocalDataSource>()),
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

  sl.registerLazySingleton<AchievementService>(
    () => AchievementService(achievementRepository: sl<AchievementRepository>()),
  );

  sl.registerLazySingleton<WeeklyChallengeService>(
    () => WeeklyChallengeService(
      challengeRepository: sl<WeeklyChallengeRepository>(),
      questRepository: sl<QuestRepository>(),
      playerRepository: sl<PlayerRepository>(),
    ),
  );

  sl.registerLazySingleton<QuestRecommendationService>(
    () => QuestRecommendationService(
      questRepository: sl<QuestRepository>(),
      playerRepository: sl<PlayerRepository>(),
    ),
  );

  sl.registerLazySingleton<InventoryService>(
    () => InventoryService(
      inventoryRepository: sl<InventoryRepository>(),
      playerRepository: sl<PlayerRepository>(),
    ),
  );

  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(),
  );

  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(
      notificationRepository: sl<NotificationRepository>(),
      localNotificationService: sl<LocalNotificationService>(),
    ),
  );

  sl.registerLazySingleton<SocialService>(
    () => SocialService(
      sl<SocialRepository>(),
      sl<PlayerRepository>(),
    ),
  );

  sl.registerLazySingleton<QuestTemplateService>(
    () => QuestTemplateService(
      repository: sl<QuestTemplateRepository>(),
      dataSource: sl<QuestTemplateLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<StreakService>(
    () => StreakService(streakRepository: sl<StreakRepository>()),
  );

  sl.registerLazySingleton<SkillService>(
    () => SkillService(skillRepository: sl<SkillRepository>()),
  );

  // BLoCs (Factory - new instance per screen)
  sl.registerFactory<PlayerBloc>(
    () => PlayerBloc(playerRepository: sl<PlayerRepository>()),
  );

  sl.registerFactory<SocialBloc>(
    () => SocialBloc(socialService: sl<SocialService>()),
  );

  sl.registerFactory<QuestTemplateBloc>(
    () => QuestTemplateBloc(service: sl<QuestTemplateService>()),
  );

  sl.registerFactory<StreakBloc>(
    () => StreakBloc(streakService: sl<StreakService>()),
  );

  sl.registerFactory<SkillBloc>(
    () => SkillBloc(skillRepository: sl<SkillRepository>()),
  );

  // TODO: Register use cases
  // TODO: Register other BLoCs
}

