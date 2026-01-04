import 'package:go_router/go_router.dart';

import '../features/Authentication/login_screen.dart';
import '../features/Authentication/register_screen.dart';
import '../features/Home/home_screen.dart';
import '../features/Onboarding/onboarding_screen.dart';
import '../features/Splash/splash_screen.dart';
import '../features/Quests/quest_create_screen.dart';
import '../features/Quests/quest_detail_screen.dart';
import '../features/Quests/quest_list_screen.dart';
import '../features/Rewards/reward_claim_screen.dart';
import '../features/Player/player_profile_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.quests,
          builder: (context, state) => const QuestListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const QuestCreateScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  QuestDetailScreen(questId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.rewardClaim,
          builder: (context, state) =>
              RewardClaimScreen(args: state.extra! as RewardArgs),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const PlayerProfileScreen(),
        ),
      ],
    );
  }
}


