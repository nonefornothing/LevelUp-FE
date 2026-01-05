import '../../domain/entities/item.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/player_repository.dart';
import '../../core/utils/result.dart';

/// Service for managing inventory and items
class InventoryService {
  final InventoryRepository _inventoryRepository;
  final PlayerRepository _playerRepository;

  InventoryService({
    required InventoryRepository inventoryRepository,
    required PlayerRepository playerRepository,
  })  : _inventoryRepository = inventoryRepository,
        _playerRepository = playerRepository;

  /// Initialize predefined items (can be called on app startup)
  Future<void> initializeItems() async {
    // Items are created on-demand when needed
    // This method can be used to seed initial items if needed
  }

  /// Get predefined items (for rewards, shops, etc.)
  static List<Item> getPredefinedItems() {
    return [
      // Consumables
      Item(
        id: 'item_xp_boost_small',
        name: 'Small XP Boost',
        description: 'Increases XP gain by 20% for 30 minutes',
        type: ItemType.consumable,
        rarity: ItemRarity.common,
        iconName: 'star',
        effect: ItemEffect(
          type: EffectType.xpBoost,
          value: 20,
          duration: 30,
        ),
        stackSize: 10,
        createdAt: DateTime.now(),
      ),
      Item(
        id: 'item_xp_boost_medium',
        name: 'Medium XP Boost',
        description: 'Increases XP gain by 50% for 1 hour',
        type: ItemType.consumable,
        rarity: ItemRarity.uncommon,
        iconName: 'star',
        effect: ItemEffect(
          type: EffectType.xpBoost,
          value: 50,
          duration: 60,
        ),
        stackSize: 5,
        createdAt: DateTime.now(),
      ),
      Item(
        id: 'item_currency_boost',
        name: 'Currency Boost',
        description: 'Increases currency gain by 30% for 1 hour',
        type: ItemType.consumable,
        rarity: ItemRarity.uncommon,
        iconName: 'monetization_on',
        effect: ItemEffect(
          type: EffectType.currencyBoost,
          value: 30,
          duration: 60,
        ),
        stackSize: 5,
        createdAt: DateTime.now(),
      ),
      // Collectibles
      Item(
        id: 'item_trophy_bronze',
        name: 'Bronze Trophy',
        description: 'Awarded for completing 10 quests',
        type: ItemType.collectible,
        rarity: ItemRarity.common,
        iconName: 'emoji_events',
        stackSize: null,
        createdAt: DateTime.now(),
      ),
      Item(
        id: 'item_trophy_silver',
        name: 'Silver Trophy',
        description: 'Awarded for completing 50 quests',
        type: ItemType.collectible,
        rarity: ItemRarity.rare,
        iconName: 'emoji_events',
        stackSize: null,
        createdAt: DateTime.now(),
      ),
      Item(
        id: 'item_trophy_gold',
        name: 'Gold Trophy',
        description: 'Awarded for completing 100 quests',
        type: ItemType.collectible,
        rarity: ItemRarity.epic,
        iconName: 'emoji_events',
        stackSize: null,
        createdAt: DateTime.now(),
      ),
      Item(
        id: 'item_badge_first_quest',
        name: 'First Quest Badge',
        description: 'Completed your first quest!',
        type: ItemType.collectible,
        rarity: ItemRarity.common,
        iconName: 'badge',
        stackSize: null,
        createdAt: DateTime.now(),
      ),
      Item(
        id: 'item_badge_level_10',
        name: 'Level 10 Badge',
        description: 'Reached level 10!',
        type: ItemType.collectible,
        rarity: ItemRarity.uncommon,
        iconName: 'badge',
        stackSize: null,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Get item by ID from predefined items
  static Item? getPredefinedItem(String itemId) {
    try {
      return getPredefinedItems().firstWhere(
        (item) => item.id == itemId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get player's inventory
  Future<Result<Inventory>> getInventory() async {
    final playerResult = await _playerRepository.getPlayer();
    if (playerResult is ResultError) {
      return ResultError('Failed to get player');
    }

    final player = (playerResult as Success<dynamic>).data;
    return await _inventoryRepository.getInventory(player.id);
  }

  /// Add item to player's inventory
  Future<Result<Inventory>> addItem(Item item, {int quantity = 1}) async {
    final playerResult = await _playerRepository.getPlayer();
    if (playerResult is ResultError) {
      return ResultError('Failed to get player');
    }

    final player = (playerResult as Success<dynamic>).data;
    return await _inventoryRepository.addItem(player.id, item, quantity: quantity);
  }

  /// Add item by ID (from predefined items)
  Future<Result<Inventory>> addItemById(String itemId, {int quantity = 1}) async {
    try {
      final item = getPredefinedItem(itemId);
      if (item == null) {
        return ResultError('Item not found: $itemId');
      }
      return await addItem(item, quantity: quantity);
    } catch (e) {
      return ResultError('Item not found: $itemId');
    }
  }

  /// Use item (for consumables)
  Future<Result<ItemEffect?>> useItem(String itemId, {int quantity = 1}) async {
    final playerResult = await _playerRepository.getPlayer();
    if (playerResult is ResultError) {
      return ResultError('Failed to get player');
    }

    final player = (playerResult as Success<dynamic>).data;
    final inventoryResult = await _inventoryRepository.useItem(player.id, itemId, quantity: quantity);
    
    if (inventoryResult is ResultError) {
      return ResultError('Failed to use item');
    }

    // Get item effect
    final itemResult = await _inventoryRepository.getItem(player.id, itemId);
    if (itemResult is Success<InventoryItem?>) {
      final inventoryItem = itemResult.data;
      if (inventoryItem != null && inventoryItem.item.effect != null) {
        // Apply effect (this would be handled by a separate effect service)
        return Success(inventoryItem.item.effect);
      }
    }

    return Success(null);
  }

  /// Get items by type
  Future<Result<List<InventoryItem>>> getItemsByType(ItemType type) async {
    final playerResult = await _playerRepository.getPlayer();
    if (playerResult is ResultError) {
      return ResultError('Failed to get player');
    }

    final player = (playerResult as Success<dynamic>).data;
    return await _inventoryRepository.getItemsByType(player.id, type);
  }
}

