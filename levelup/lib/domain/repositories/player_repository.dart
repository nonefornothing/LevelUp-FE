import '../../core/utils/result.dart';
import '../entities/player.dart';

/// Player Repository Interface (Domain layer)
abstract class PlayerRepository {
  /// Get current player
  Future<Result<Player>> getPlayer();

  /// Get player by ID
  Future<Result<Player>> getPlayerById(String id);

  /// Create player
  Future<Result<Player>> createPlayer(Player player);

  /// Update player
  Future<Result<Player>> updatePlayer(Player player);

  /// Add experience to player
  Future<Result<Player>> addExperience(int amount);

  /// Add currency to player
  Future<Result<Player>> addCurrency(int amount);

  /// Check and handle level up
  Future<Result<bool>> checkLevelUp(); // Returns true if leveled up
}

