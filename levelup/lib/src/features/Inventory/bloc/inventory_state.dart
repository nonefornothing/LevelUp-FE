import 'package:equatable/equatable.dart';

import '../../../../domain/entities/inventory.dart';
import '../../../../domain/entities/item.dart';

/// States for InventoryBloc
abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

/// Loading state
class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

/// Loaded state
class InventoryLoaded extends InventoryState {
  final Inventory inventory;
  final ItemType? filterType;
  final List<InventoryItem> filteredItems;

  const InventoryLoaded({
    required this.inventory,
    this.filterType,
    required this.filteredItems,
  });

  @override
  List<Object?> get props => [inventory, filterType, filteredItems];
}

/// Error state
class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}




