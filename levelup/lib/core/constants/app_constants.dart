/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'LevelUp';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String storageKeyOnboardingCompleted = 'onboarding_completed';
  static const String storageKeyUserId = 'user_id';
  static const String storageKeyAuthToken = 'auth_token';
  static const String storageKeyLastDailyQuestGeneration = 'last_daily_quest_generation';
  
  // Quest Progress Calculation Weights
  static const double questProgressTaskWeight = 0.5; // 50% from tasks
  static const double questProgressMilestoneWeight = 0.3; // 30% from milestones
  static const double questProgressObjectiveWeight = 0.2; // 20% from final objective
  
  // Player Progression
  static const int baseXPPerLevel = 100;
  static const double xpMultiplierPerLevel = 1.5;
  
  // Inventory
  static const int defaultInventoryMaxSlots = 50;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 15);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

