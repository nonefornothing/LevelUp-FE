import 'package:equatable/equatable.dart';

/// Item entity (Domain layer)
class Item extends Equatable {
  final String id;
  final String name;
  final String? description;
  final ItemType type;
  final ItemRarity rarity;
  final String? iconName; // For custom icons
  final ItemEffect? effect; // For consumables with effects
  final int? stackSize; // Max stack size (null = unlimited)
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.rarity,
    this.iconName,
    this.effect,
    this.stackSize,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        rarity,
        iconName,
        effect,
        stackSize,
        createdAt,
      ];
}

/// Item Type
enum ItemType {
  consumable, // Can be used/consumed (potions, boosters)
  equipment, // Can be equipped (weapons, armor)
  collectible, // Just for collection (trophies, badges)
  currency, // Special currency items
}

/// Item Rarity
enum ItemRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// Item Effect (for consumables)
class ItemEffect extends Equatable {
  final EffectType type;
  final int value; // Effect value (e.g., XP boost amount, health restore)
  final int? duration; // Duration in minutes (null = instant)

  const ItemEffect({
    required this.type,
    required this.value,
    this.duration,
  });

  @override
  List<Object?> get props => [type, value, duration];
}

/// Effect Type
enum EffectType {
  xpBoost, // Boost XP gain
  currencyBoost, // Boost currency gain
  healthRestore, // Restore health (if health system exists)
  energyRestore, // Restore energy (if energy system exists)
}




