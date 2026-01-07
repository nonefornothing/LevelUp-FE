import '../../core/utils/result.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/player_local_datasource.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerLocalDataSource _local;

  PlayerRepositoryImpl({required PlayerLocalDataSource localDataSource})
      : _local = localDataSource;

  @override
  Future<Result<Player>> getPlayer() async {
    try {
      final player = await _local.getCurrentPlayer();
      if (player == null) return const ResultError('No current player');
      return Success(player);
    } catch (e) {
      return ResultError(
        'Failed to get player: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Player>> getPlayerById(String id) async {
    try {
      final player = await _local.getPlayerById(id);
      if (player == null) return const ResultError('Player not found');
      return Success(player);
    } catch (e) {
      return ResultError(
        'Failed to get player: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Player>> createPlayer(Player player) async {
    try {
      await _local.upsertPlayer(player);
      await _local.setCurrentPlayerId(player.id);
      return Success(player);
    } catch (e) {
      return ResultError(
        'Failed to create player: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Player>> updatePlayer(Player player) async {
    try {
      await _local.upsertPlayer(player);
      return Success(player);
    } catch (e) {
      return ResultError(
        'Failed to update player: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Player>> addExperience(int amount) async {
    try {
      final current = await _local.getCurrentPlayer();
      if (current == null) return const ResultError('No current player');

      final updated = Player(
        id: current.id,
        username: current.username,
        email: current.email,
        level: current.level,
        experience: current.experience + amount,
        currency: current.currency,
        stats: current.stats,
        createdAt: current.createdAt,
        lastActiveAt: DateTime.now(),
      );

      await _local.upsertPlayer(updated);
      return Success(updated);
    } catch (e) {
      return ResultError(
        'Failed to add experience: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<Player>> addCurrency(int amount) async {
    try {
      final current = await _local.getCurrentPlayer();
      if (current == null) return const ResultError('No current player');

      final updated = Player(
        id: current.id,
        username: current.username,
        email: current.email,
        level: current.level,
        experience: current.experience,
        currency: current.currency + amount,
        stats: current.stats,
        createdAt: current.createdAt,
        lastActiveAt: DateTime.now(),
      );

      await _local.upsertPlayer(updated);
      return Success(updated);
    } catch (e) {
      return ResultError(
        'Failed to add currency: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<bool>> checkLevelUp() async {
    try {
      final current = await _local.getCurrentPlayer();
      if (current == null) return const ResultError('No current player');

      // Very simple leveling rule for now:
      // if experience >= xpForNextLevel => level up once
      if (current.experience < current.xpForNextLevel) {
        return const Success(false);
      }

      // Award 1 skill point per level up
      final newSkillPoints = current.availableSkillPoints + 1;
      
      final leveled = Player(
        id: current.id,
        username: current.username,
        email: current.email,
        level: current.level + 1,
        experience: current.experience,
        currency: current.currency,
        availableSkillPoints: newSkillPoints,
        stats: current.stats,
        createdAt: current.createdAt,
        lastActiveAt: DateTime.now(),
      );

      await _local.upsertPlayer(leveled);
      return const Success(true);
    } catch (e) {
      return ResultError(
        'Failed to check level up: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}


