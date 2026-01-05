import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/inventory.dart';
import '../../domain/entities/item.dart';
import '../models/item_hive_models.dart';
import 'local_storage.dart';

/// Local data source for inventory using Hive
class InventoryLocalDataSource {
  final Box<InventoryHiveModel> _box;

  InventoryLocalDataSource({Box<InventoryHiveModel>? box})
      : _box = box ?? Hive.box<InventoryHiveModel>(HiveLocalStorage.inventoryBoxName);

  /// Get inventory for player
  Inventory? getInventory(String playerId) {
    final model = _box.get(playerId);
    return model?.toDomain();
  }

  /// Create or update inventory
  Future<void> saveInventory(Inventory inventory) async {
    final model = InventoryHiveModel.fromDomain(inventory);
    await _box.put(inventory.playerId, model);
  }

  /// Delete inventory
  Future<void> deleteInventory(String playerId) async {
    await _box.delete(playerId);
  }
}




