import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/inventory.dart';
import '../../../domain/entities/item.dart';
import 'bloc/inventory_bloc.dart';
import 'bloc/inventory_event.dart';
import 'bloc/inventory_state.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryBloc()
        ..add(const InventoryLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Inventory',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightBlueAccent,
                ),
              );
            }

            if (state is InventoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<InventoryBloc>().add(
                              const InventoryLoadRequested(),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is InventoryLoaded) {
              return Column(
                children: [
                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: state.filterType == null,
                            onTap: () {
                              context.read<InventoryBloc>().add(
                                    const InventoryFilterByTypeRequested(null),
                                  );
                            },
                          ),
                          const SizedBox(width: 8),
                          ...ItemType.values.map((type) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterChip(
                                  label: _getTypeLabel(type),
                                  isSelected: state.filterType == type,
                                  onTap: () {
                                    context.read<InventoryBloc>().add(
                                          InventoryFilterByTypeRequested(type),
                                        );
                                  },
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  // Items List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<InventoryBloc>().add(
                              const InventoryRefreshRequested(),
                            );
                      },
                      color: Colors.lightBlueAccent,
                      child: state.filteredItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.filterType != null
                                        ? 'No ${_getTypeLabel(state.filterType!)} items'
                                        : 'Your inventory is empty',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.filteredItems.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final inventoryItem = state.filteredItems[index];
                                return _InventoryItemCard(
                                  inventoryItem: inventoryItem,
                                  onUse: inventoryItem.canUse
                                      ? () {
                                          context.read<InventoryBloc>().add(
                                                InventoryUseItemRequested(
                                                  inventoryItem.item.id,
                                                ),
                                              );
                                        }
                                      : null,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _getTypeLabel(ItemType type) {
    switch (type) {
      case ItemType.consumable:
        return 'Consumables';
      case ItemType.equipment:
        return 'Equipment';
      case ItemType.collectible:
        return 'Collectibles';
      case ItemType.currency:
        return 'Currency';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.lightBlueAccent.withOpacity(0.3),
      checkmarkColor: Colors.lightBlueAccent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.lightBlueAccent : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final InventoryItem inventoryItem;
  final VoidCallback? onUse;

  const _InventoryItemCard({
    required this.inventoryItem,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final item = inventoryItem.item;
    final rarityColor = _getRarityColor(item.rarity);

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Item Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: rarityColor, width: 2),
              ),
              child: Icon(
                _getItemIcon(item.iconName, item.type),
                color: rarityColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Item Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (inventoryItem.quantity > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'x${inventoryItem.quantity}',
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: rarityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.rarity.name.toUpperCase(),
                          style: TextStyle(
                            color: rarityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.type.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Use Button
            if (onUse != null)
              IconButton(
                onPressed: onUse,
                icon: const Icon(Icons.play_arrow),
                color: Colors.lightBlueAccent,
                tooltip: 'Use Item',
              ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.uncommon:
        return Colors.green;
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
    }
  }

  IconData _getItemIcon(String? iconName, ItemType type) {
    if (iconName != null) {
      // Map common icon names to Material icons
      switch (iconName) {
        case 'star':
          return Icons.star;
        case 'monetization_on':
          return Icons.monetization_on;
        case 'emoji_events':
          return Icons.emoji_events;
        case 'badge':
          return Icons.badge;
        default:
          break;
      }
    }

    // Default icons by type
    switch (type) {
      case ItemType.consumable:
        return Icons.local_drink;
      case ItemType.equipment:
        return Icons.shield;
      case ItemType.collectible:
        return Icons.collections;
      case ItemType.currency:
        return Icons.monetization_on;
    }
  }
}

