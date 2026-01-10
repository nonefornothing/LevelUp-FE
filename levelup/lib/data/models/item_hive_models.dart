import 'package:hive/hive.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/inventory.dart';

/// Hive model for storing an Item locally
class ItemHiveModel {
  final String id;
  final String name;
  final String? description;
  final int typeIndex;
  final int rarityIndex;
  final String? iconName;
  final int? effectTypeIndex;
  final int? effectValue;
  final int? effectDuration;
  final int? stackSize;
  final DateTime createdAt;

  ItemHiveModel({
    required this.id,
    required this.name,
    this.description,
    required this.typeIndex,
    required this.rarityIndex,
    this.iconName,
    this.effectTypeIndex,
    this.effectValue,
    this.effectDuration,
    this.stackSize,
    required this.createdAt,
  });

  Item toDomain() {
    final type = ItemType.values[typeIndex.clamp(0, ItemType.values.length - 1)];
    final rarity = ItemRarity.values[rarityIndex.clamp(0, ItemRarity.values.length - 1)];

    ItemEffect? effect;
    if (effectTypeIndex != null && effectValue != null) {
      final effectType = EffectType.values[effectTypeIndex!.clamp(0, EffectType.values.length - 1)];
      effect = ItemEffect(
        type: effectType,
        value: effectValue!,
        duration: effectDuration,
      );
    }

    return Item(
      id: id,
      name: name,
      description: description,
      type: type,
      rarity: rarity,
      iconName: iconName,
      effect: effect,
      stackSize: stackSize,
      createdAt: createdAt,
    );
  }

  static ItemHiveModel fromDomain(Item item) {
    return ItemHiveModel(
      id: item.id,
      name: item.name,
      description: item.description,
      typeIndex: item.type.index,
      rarityIndex: item.rarity.index,
      iconName: item.iconName,
      effectTypeIndex: item.effect?.type.index,
      effectValue: item.effect?.value,
      effectDuration: item.effect?.duration,
      stackSize: item.stackSize,
      createdAt: item.createdAt,
    );
  }
}

/// Hive model for storing an InventoryItem locally
class InventoryItemHiveModel {
  final String id;
  final ItemHiveModel item;
  final int quantity;
  final DateTime obtainedAt;
  final DateTime? lastUsedAt;

  InventoryItemHiveModel({
    required this.id,
    required this.item,
    required this.quantity,
    required this.obtainedAt,
    this.lastUsedAt,
  });

  InventoryItem toDomain() {
    return InventoryItem(
      id: id,
      item: item.toDomain(),
      quantity: quantity,
      obtainedAt: obtainedAt,
      lastUsedAt: lastUsedAt,
    );
  }

  static InventoryItemHiveModel fromDomain(InventoryItem inventoryItem) {
    return InventoryItemHiveModel(
      id: inventoryItem.id,
      item: ItemHiveModel.fromDomain(inventoryItem.item),
      quantity: inventoryItem.quantity,
      obtainedAt: inventoryItem.obtainedAt,
      lastUsedAt: inventoryItem.lastUsedAt,
    );
  }
}

/// Hive model for storing Inventory locally
class InventoryHiveModel {
  final String playerId;
  final List<InventoryItemHiveModel> items;
  final DateTime lastUpdated;

  InventoryHiveModel({
    required this.playerId,
    required this.items,
    required this.lastUpdated,
  });

  Inventory toDomain() {
    return Inventory(
      playerId: playerId,
      items: items.map((m) => m.toDomain()).toList(),
      lastUpdated: lastUpdated,
    );
  }

  static InventoryHiveModel fromDomain(Inventory inventory) {
    return InventoryHiveModel(
      playerId: inventory.playerId,
      items: inventory.items.map(InventoryItemHiveModel.fromDomain).toList(),
      lastUpdated: inventory.lastUpdated,
    );
  }
}

/// Adapter type IDs must be unique across the app
const int _itemTypeId = 5;
const int _inventoryItemTypeId = 6;
const int _inventoryTypeId = 7;

class ItemHiveModelAdapter extends TypeAdapter<ItemHiveModel> {
  @override
  final int typeId = _itemTypeId;

  @override
  ItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return ItemHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      typeIndex: fields[3] as int,
      rarityIndex: fields[4] as int,
      iconName: fields[5] as String?,
      effectTypeIndex: fields[6] as int?,
      effectValue: fields[7] as int?,
      effectDuration: fields[8] as int?,
      stackSize: fields[9] as int?,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ItemHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.typeIndex)
      ..writeByte(4)
      ..write(obj.rarityIndex)
      ..writeByte(5)
      ..write(obj.iconName)
      ..writeByte(6)
      ..write(obj.effectTypeIndex)
      ..writeByte(7)
      ..write(obj.effectValue)
      ..writeByte(8)
      ..write(obj.effectDuration)
      ..writeByte(9)
      ..write(obj.stackSize)
      ..writeByte(10)
      ..write(obj.createdAt);
  }
}

class InventoryItemHiveModelAdapter extends TypeAdapter<InventoryItemHiveModel> {
  @override
  final int typeId = _inventoryItemTypeId;

  @override
  InventoryItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return InventoryItemHiveModel(
      id: fields[0] as String,
      item: fields[1] as ItemHiveModel,
      quantity: fields[2] as int,
      obtainedAt: fields[3] as DateTime,
      lastUsedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItemHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.item)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.obtainedAt)
      ..writeByte(4)
      ..write(obj.lastUsedAt);
  }
}

class InventoryHiveModelAdapter extends TypeAdapter<InventoryHiveModel> {
  @override
  final int typeId = _inventoryTypeId;

  @override
  InventoryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return InventoryHiveModel(
      playerId: fields[0] as String,
      items: (fields[1] as List).cast<InventoryItemHiveModel>(),
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.playerId)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }
}




