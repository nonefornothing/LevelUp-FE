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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  // Initialize achievements on app startup
  try {
    await sl<AchievementService>().initializeAchievements();
  } catch (e) {
    // Fail silently - achievements will be initialized when first accessed
    print('Warning: Failed to initialize achievements: $e');
  }
  
  // Schedule daily quest reminder notification
  try {
    await sl<NotificationService>().scheduleDailyQuestReminder();
  } catch (e) {
    // Fail silently - notifications will be scheduled when needed
    print('Warning: Failed to schedule daily quest reminder: $e');
  }
  
  // Initialize quest templates on app startup
  try {
    await sl<QuestTemplateService>().initializeTemplates();
  } catch (e) {
    // Fail silently - templates will be initialized when first accessed
    print('Warning: Failed to initialize quest templates: $e');
  }
  
  runApp(const MyGameApp());
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
