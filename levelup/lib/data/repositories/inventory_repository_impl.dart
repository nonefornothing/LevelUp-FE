import '../../core/utils/result.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../core/utils/id_generator.dart';
import '../datasources/inventory_local_datasource.dart';

/// Implementation of InventoryRepository
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource _dataSource;

  InventoryRepositoryImpl({
    required InventoryLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<Inventory>> getInventory(String playerId) async {
    try {
      final inventory = _dataSource.getInventory(playerId);
      if (inventory == null) {
        // Create empty inventory if it doesn't exist
        final newInventory = Inventory(
          playerId: playerId,
          items: [],
          lastUpdated: DateTime.now(),
        );
        await _dataSource.saveInventory(newInventory);
        return Success(newInventory);
      }
      return Success(inventory);
    } catch (e) {
      return ResultError('Failed to get inventory: $e');
    }
  }

  @override
  Future<Result<Inventory>> addItem(String playerId, Item item, {int quantity = 1}) async {
    try {
      final inventoryResult = await getInventory(playerId);
      if (inventoryResult is ResultError) {
        return inventoryResult;
      }

      final inventory = (inventoryResult as Success<Inventory>).data;
      final existingItem = inventory.getItem(item.id);

      List<InventoryItem> updatedItems;
      if (existingItem != null) {
        // Update quantity if item exists
        final newQuantity = existingItem.quantity + quantity;
        updatedItems = inventory.items.map((invItem) {
          if (invItem.item.id == item.id) {
            return invItem.copyWith(quantity: newQuantity);
          }
          return invItem;
        }).toList();
      } else {
        // Add new item
        final newInventoryItem = InventoryItem(
          id: IdGenerator.newId(),
          item: item,
          quantity: quantity,
          obtainedAt: DateTime.now(),
        );
        updatedItems = [...inventory.items, newInventoryItem];
      }

      final updatedInventory = inventory.copyWith(
        items: updatedItems,
        lastUpdated: DateTime.now(),
      );

      await _dataSource.saveInventory(updatedInventory);
      return Success(updatedInventory);
    } catch (e) {
      return ResultError('Failed to add item: $e');
    }
  }

  @override
  Future<Result<Inventory>> removeItem(String playerId, String itemId, {int quantity = 1}) async {
    try {
      final inventoryResult = await getInventory(playerId);
      if (inventoryResult is ResultError) {
        return inventoryResult;
      }

      final inventory = (inventoryResult as Success<Inventory>).data;
      final existingItem = inventory.getItem(itemId);

      if (existingItem == null) {
        return ResultError('Item not found in inventory');
      }

      final newQuantity = existingItem.quantity - quantity;
      if (newQuantity <= 0) {
        // Remove item completely
        final updatedItems = inventory.items
            .where((invItem) => invItem.item.id != itemId)
            .toList();
        final updatedInventory = inventory.copyWith(
          items: updatedItems,
          lastUpdated: DateTime.now(),
        );
        await _dataSource.saveInventory(updatedInventory);
        return Success(updatedInventory);
      } else {
        // Update quantity
        final updatedItems = inventory.items.map((invItem) {
          if (invItem.item.id == itemId) {
            return invItem.copyWith(quantity: newQuantity);
          }
          return invItem;
        }).toList();
        final updatedInventory = inventory.copyWith(
          items: updatedItems,
          lastUpdated: DateTime.now(),
        );
        await _dataSource.saveInventory(updatedInventory);
        return Success(updatedInventory);
      }
    } catch (e) {
      return ResultError('Failed to remove item: $e');
    }
  }

  @override
  Future<Result<Inventory>> useItem(String playerId, String itemId, {int quantity = 1}) async {
    try {
      final inventoryResult = await getInventory(playerId);
      if (inventoryResult is ResultError) {
        return inventoryResult;
      }

      final inventory = (inventoryResult as Success<Inventory>).data;
      final existingItem = inventory.getItem(itemId);

      if (existingItem == null) {
        return ResultError('Item not found in inventory');
      }

      if (!existingItem.canUse) {
        return ResultError('Item cannot be used');
      }

      if (existingItem.quantity < quantity) {
        return ResultError('Not enough items');
      }

      // Remove item quantity and update lastUsedAt
      return await removeItem(playerId, itemId, quantity: quantity);
    } catch (e) {
      return ResultError('Failed to use item: $e');
    }
  }

  @override
  Future<Result<Inventory>> updateItemQuantity(String playerId, String itemId, int quantity) async {
    try {
      final inventoryResult = await getInventory(playerId);
      if (inventoryResult is ResultError) {
        return inventoryResult;
      }

      final inventory = (inventoryResult as Success<Inventory>).data;
      final existingItem = inventory.getItem(itemId);

      if (existingItem == null) {
        return ResultError('Item not found in inventory');
      }

      if (quantity <= 0) {
        return await removeItem(playerId, itemId, quantity: existingItem.quantity);
      }

      final updatedItems = inventory.items.map((invItem) {
        if (invItem.item.id == itemId) {
          return invItem.copyWith(quantity: quantity);
        }
        return invItem;
      }).toList();

      final updatedInventory = inventory.copyWith(
        items: updatedItems,
        lastUpdated: DateTime.now(),
      );

      await _dataSource.saveInventory(updatedInventory);
      return Success(updatedInventory);
    } catch (e) {
      return ResultError('Failed to update item quantity: $e');
    }
  }

  @override
  Future<Result<InventoryItem?>> getItem(String playerId, String itemId) async {
    try {
      final inventoryResult = await getInventory(playerId);
      if (inventoryResult is ResultError) {
        return ResultError('Failed to get inventory');
      }

      final inventory = (inventoryResult as Success<Inventory>).data;
      final item = inventory.getItem(itemId);
      return Success(item);
    } catch (e) {
      return ResultError('Failed to get item: $e');
    }
  }

  @override
  Future<Result<List<InventoryItem>>> getItemsByType(String playerId, ItemType type) async {
    try {
      final inventoryResult = await getInventory(playerId);
      if (inventoryResult is ResultError) {
        return ResultError('Failed to get inventory');
      }

      final inventory = (inventoryResult as Success<Inventory>).data;
      final items = inventory.getItemsByType(type);
      return Success(items);
    } catch (e) {
      return ResultError('Failed to get items by type: $e');
    }
  }

  @override
  Future<Result<void>> clearInventory(String playerId) async {
    try {
      await _dataSource.deleteInventory(playerId);
      return Success(null);
    } catch (e) {
      return ResultError('Failed to clear inventory: $e');
    }
  }
}

