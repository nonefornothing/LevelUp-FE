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
import '../../src/features/Player/bloc/player_bloc.dart';
import '../../core/services/daily_quest_service.dart';

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

  // Services
  sl.registerLazySingleton<DailyQuestService>(
    () => DailyQuestService(
      questRepository: sl<QuestRepository>(),
      playerRepository: sl<PlayerRepository>(),
      questDataSource: sl<QuestLocalDataSource>(),
      playerDataSource: sl<PlayerLocalDataSource>(),
    ),
  );

  // BLoCs (Factory - new instance per screen)
  sl.registerFactory<PlayerBloc>(
    () => PlayerBloc(playerRepository: sl<PlayerRepository>()),
  );

  // TODO: Register use cases
  // TODO: Register other BLoCs
}

