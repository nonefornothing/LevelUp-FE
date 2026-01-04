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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
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
