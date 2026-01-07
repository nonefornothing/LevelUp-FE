import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'src/features/Splash/splash_event.dart';
import 'src/features/Splash/splash_bloc.dart';
import 'src/routing/app_router.dart';
import 'core/di/injection_container.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/onboarding_repository.dart';
import 'src/features/Authentication/bloc/auth_bloc.dart';
import 'src/features/Authentication/bloc/auth_event.dart';
import 'domain/repositories/quest_repository.dart';
import 'src/features/Quests/bloc/quest_bloc.dart';
import 'domain/repositories/player_repository.dart';
import 'core/services/achievement_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/quest_template_service.dart';
import 'core/services/skill_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection first (required for app to run)
  await di.init();
  
  // Initialize local notifications early (needed for scheduling)
  try {
    final localNotificationService = LocalNotificationService();
    await localNotificationService.initialize();
    await localNotificationService.requestPermissions();
  } catch (e) {
    Logger.warning('Failed to initialize local notifications: $e');
  }
  
  // Run app immediately - don't block startup
  runApp(const MyGameApp());
  
  // Initialize non-critical services in background after app starts
  _initializeBackgroundServices();
}

/// Initialize non-critical services in the background
/// This prevents blocking app startup
Future<void> _initializeBackgroundServices() async {
  // Use a microtask to ensure this runs after the app is built
  await Future.microtask(() async {
    try {
      // Initialize achievements in background
      await sl<AchievementService>().initializeAchievements();
    } catch (e) {
      Logger.warning('Failed to initialize achievements: $e');
    }
    
    try {
      // Schedule daily quest reminder notification
      await sl<NotificationService>().scheduleDailyQuestReminder();
    } catch (e) {
      Logger.warning('Failed to schedule daily quest reminder: $e');
    }
    
    try {
      // Initialize quest templates in background
      await sl<QuestTemplateService>().initializeTemplates();
    } catch (e) {
      Logger.warning('Failed to initialize quest templates: $e');
    }
    
    try {
      // Initialize skills in background
      await sl<SkillService>().initializeSkills();
    } catch (e) {
      Logger.warning('Failed to initialize skills: $e');
    }
  });
}

class MyGameApp extends StatelessWidget {
  const MyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            authRepository: sl<AuthRepository>(),
            playerRepository: sl<PlayerRepository>(),
          )
            ..add(AuthAppStarted()),
        ),
        BlocProvider<QuestBloc>(
          create: (_) => QuestBloc(questRepository: sl<QuestRepository>()),
        ),
        BlocProvider<SplashBloc>(
          create: (_) => SplashBloc(
            authRepository: sl<AuthRepository>(),
            onboardingRepository: sl<OnboardingRepository>(),
          )..add(SplashStarted()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        routerConfig: router,
      ),
    );
  }
}
