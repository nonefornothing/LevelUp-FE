import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/inventory_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/inventory.dart';
import '../../../../domain/entities/item.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

/// BLoC for managing inventory state
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryService _inventoryService;

  InventoryBloc({
    InventoryService? inventoryService,
  })  : _inventoryService = inventoryService ?? sl<InventoryService>(),
        super(const InventoryInitial()) {
    on<InventoryLoadRequested>(_onLoadRequested);
    on<InventoryRefreshRequested>(_onRefreshRequested);
    on<InventoryAddItemRequested>(_onAddItemRequested);
    on<InventoryUseItemRequested>(_onUseItemRequested);
    on<InventoryFilterByTypeRequested>(_onFilterByTypeRequested);
  }

  Future<void> _onLoadRequested(
    InventoryLoadRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    try {
      final result = await _inventoryService.getInventory();
      if (result is ResultError) {
        emit(const InventoryError('Failed to load inventory'));
        return;
      }

      final inventory = (result as Success<Inventory>).data;
      emit(InventoryLoaded(
        inventory: inventory,
        filteredItems: inventory.items,
      ));
    } catch (e) {
      emit(InventoryError('Failed to load inventory: $e'));
    }
  }

  Future<void> _onRefreshRequested(
    InventoryRefreshRequested event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final result = await _inventoryService.getInventory();
      if (result is ResultError) {
        emit(const InventoryError('Failed to refresh inventory'));
        return;
      }

      final inventory = (result as Success<Inventory>).data;
      final currentState = state;
      ItemType? filterType;
      if (currentState is InventoryLoaded) {
        filterType = currentState.filterType;
      }

      final filteredItems = filterType != null
          ? inventory.getItemsByType(filterType)
          : inventory.items;

      emit(InventoryLoaded(
        inventory: inventory,
        filterType: filterType,
        filteredItems: filteredItems,
      ));
    } catch (e) {
      emit(InventoryError('Failed to refresh inventory: $e'));
    }
  }

  Future<void> _onAddItemRequested(
    InventoryAddItemRequested event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final result = await _inventoryService.addItemById(
        event.itemId,
        quantity: event.quantity,
      );

      if (result is ResultError) {
        emit(const InventoryError('Failed to add item'));
        return;
      }

      // Refresh inventory
      add(const InventoryRefreshRequested());
    } catch (e) {
      emit(InventoryError('Failed to add item: $e'));
    }
  }

  Future<void> _onUseItemRequested(
    InventoryUseItemRequested event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final result = await _inventoryService.useItem(
        event.itemId,
        quantity: event.quantity,
      );

      if (result is ResultError) {
        emit(const InventoryError('Failed to use item'));
        return;
      }

      // Refresh inventory
      add(const InventoryRefreshRequested());
    } catch (e) {
      emit(InventoryError('Failed to use item: $e'));
    }
  }

  Future<void> _onFilterByTypeRequested(
    InventoryFilterByTypeRequested event,
    Emitter<InventoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InventoryLoaded) return;

    final filteredItems = event.type != null
        ? currentState.inventory.getItemsByType(event.type!)
        : currentState.inventory.items;

    emit(InventoryLoaded(
      inventory: currentState.inventory,
      filterType: event.type,
      filteredItems: filteredItems,
    ));
  }
}

