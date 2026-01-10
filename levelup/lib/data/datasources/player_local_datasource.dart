import 'package:hive/hive.dart';

import '../../domain/entities/player.dart';
import '../models/player_hive_models.dart';
import 'local_storage.dart';

abstract class PlayerLocalDataSource {
  Future<Player?> getCurrentPlayer();
  Future<Player?> getPlayerById(String id);
  Future<void> upsertPlayer(Player player);
  Future<void> setCurrentPlayerId(String id);
  Future<String?> getCurrentPlayerId();
  Future<void> clearCurrentPlayer();
}

class PlayerLocalDataSourceImpl implements PlayerLocalDataSource {
  static const String _currentPlayerIdKey = 'current_player_id';

  Box<PlayerHiveModel> get _playerBox =>
      Hive.box<PlayerHiveModel>(HiveLocalStorage.playerBoxName);

  Box<dynamic> get _prefsBox => Hive.box(HiveLocalStorage.prefsBoxName);

  @override
  Future<Player?> getCurrentPlayer() async {
    final id = await getCurrentPlayerId();
    if (id == null) return null;
    return getPlayerById(id);
  }

  @override
  Future<Player?> getPlayerById(String id) async {
    final model = _playerBox.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> upsertPlayer(Player player) async {
    await _playerBox.put(player.id, PlayerHiveModel.fromDomain(player));
  }

  @override
  Future<void> setCurrentPlayerId(String id) async {
    await _prefsBox.put(_currentPlayerIdKey, id);
  }

  @override
  Future<String?> getCurrentPlayerId() async {
    final value = _prefsBox.get(_currentPlayerIdKey);
    return value is String ? value : null;
  }

  @override
  Future<void> clearCurrentPlayer() async {
    final id = await getCurrentPlayerId();
    if (id != null) {
      await _playerBox.delete(id);
    }
    await _prefsBox.delete(_currentPlayerIdKey);
  }
}


