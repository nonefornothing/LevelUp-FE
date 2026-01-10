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
import '../features/Settings/settings_screen.dart';
import '../features/Statistics/statistics_screen.dart';
import '../features/Achievements/achievements_screen.dart';
import '../features/WeeklyChallenges/weekly_challenges_screen.dart';
import '../features/Inventory/inventory_screen.dart';
import '../features/Notifications/notifications_screen.dart';
import '../features/Notifications/notification_preferences_screen.dart';
import '../features/Social/friends_screen.dart';
import '../features/QuestTemplates/quest_templates_screen.dart';
import '../features/Streaks/streaks_screen.dart';
import '../features/Skills/skills_screen.dart';
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
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.statistics,
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(
          path: AppRoutes.achievements,
          builder: (context, state) => const AchievementsScreen(),
        ),
        GoRoute(
          path: AppRoutes.weeklyChallenges,
          builder: (context, state) => const WeeklyChallengesScreen(),
        ),
        GoRoute(
          path: AppRoutes.inventory,
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.notificationPreferences,
          builder: (context, state) => const NotificationPreferencesScreen(),
        ),
        GoRoute(
          path: AppRoutes.friends,
          builder: (context, state) => const FriendsScreen(),
        ),
        GoRoute(
          path: AppRoutes.questTemplates,
          builder: (context, state) => const QuestTemplatesScreen(),
        ),
        GoRoute(
          path: AppRoutes.streaks,
          builder: (context, state) => const StreaksScreen(),
        ),
        GoRoute(
          path: AppRoutes.skills,
          builder: (context, state) => const SkillsScreen(),
        ),
      ],
    );
  }
}


