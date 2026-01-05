import '../../core/utils/result.dart';
import '../entities/inventory.dart';
import '../entities/item.dart';

/// Inventory Repository Interface (Domain layer)
abstract class InventoryRepository {
  /// Get player's inventory
  Future<Result<Inventory>> getInventory(String playerId);

  /// Add item to inventory
  Future<Result<Inventory>> addItem(String playerId, Item item, {int quantity = 1});

  /// Remove item from inventory
  Future<Result<Inventory>> removeItem(String playerId, String itemId, {int quantity = 1});

  /// Use item (for consumables)
  Future<Result<Inventory>> useItem(String playerId, String itemId, {int quantity = 1});

  /// Update item quantity
  Future<Result<Inventory>> updateItemQuantity(String playerId, String itemId, int quantity);

  /// Get item by ID
  Future<Result<InventoryItem?>> getItem(String playerId, String itemId);

  /// Get items by type
  Future<Result<List<InventoryItem>>> getItemsByType(String playerId, ItemType type);

  /// Clear inventory (for testing/reset)
  Future<Result<void>> clearInventory(String playerId);
}




