import 'package:equatable/equatable.dart';

import '../../../../domain/entities/item.dart';

/// Events for InventoryBloc
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load inventory
class InventoryLoadRequested extends InventoryEvent {
  const InventoryLoadRequested();
}

/// Refresh inventory
class InventoryRefreshRequested extends InventoryEvent {
  const InventoryRefreshRequested();
}

/// Add item to inventory
class InventoryAddItemRequested extends InventoryEvent {
  final String itemId;
  final int quantity;

  const InventoryAddItemRequested(this.itemId, {this.quantity = 1});

  @override
  List<Object?> get props => [itemId, quantity];
}

/// Use item
class InventoryUseItemRequested extends InventoryEvent {
  final String itemId;
  final int quantity;

  const InventoryUseItemRequested(this.itemId, {this.quantity = 1});

  @override
  List<Object?> get props => [itemId, quantity];
}

/// Filter by type
class InventoryFilterByTypeRequested extends InventoryEvent {
  final ItemType? type;

  const InventoryFilterByTypeRequested(this.type);

  @override
  List<Object?> get props => [type];
}




