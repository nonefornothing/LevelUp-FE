import 'package:equatable/equatable.dart';

import 'item.dart';

/// Inventory Item (item with quantity)
class InventoryItem extends Equatable {
  final String id;
  final Item item;
  final int quantity;
  final DateTime obtainedAt;
  final DateTime? lastUsedAt;

  const InventoryItem({
    required this.id,
    required this.item,
    required this.quantity,
    required this.obtainedAt,
    this.lastUsedAt,
  });

  /// Check if item can be used
  bool get canUse => item.type == ItemType.consumable && quantity > 0;

  /// Check if item is stackable
  bool get isStackable => item.stackSize != null;

  /// Check if stack is full
  bool get isStackFull {
    if (!isStackable) return false;
    return quantity >= item.stackSize!;
  }

  /// Create a copy with updated quantity
  InventoryItem copyWith({
    String? id,
    Item? item,
    int? quantity,
    DateTime? obtainedAt,
    DateTime? lastUsedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      obtainedAt: obtainedAt ?? this.obtainedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  List<Object?> get props => [id, item, quantity, obtainedAt, lastUsedAt];
}

/// Inventory entity (Domain layer)
class Inventory extends Equatable {
  final String playerId;
  final List<InventoryItem> items;
  final DateTime lastUpdated;

  const Inventory({
    required this.playerId,
    required this.items,
    required this.lastUpdated,
  });

  /// Get item by item ID
  InventoryItem? getItem(String itemId) {
    try {
      return items.firstWhere((invItem) => invItem.item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Get items by type
  List<InventoryItem> getItemsByType(ItemType type) {
    return items.where((invItem) => invItem.item.type == type).toList();
  }

  /// Get items by rarity
  List<InventoryItem> getItemsByRarity(ItemRarity rarity) {
    return items.where((invItem) => invItem.item.rarity == rarity).toList();
  }

  /// Get total item count
  int get totalItemCount => items.length;

  /// Get total quantity of all items
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Create a copy with updated items
  Inventory copyWith({
    String? playerId,
    List<InventoryItem>? items,
    DateTime? lastUpdated,
  }) {
    return Inventory(
      playerId: playerId ?? this.playerId,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [playerId, items, lastUpdated];
}




