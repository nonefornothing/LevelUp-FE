# 🎒 Inventory System - LevelUp Feature Documentation

## 🎯 Overview

Inventory System adalah sistem manajemen item yang didapat player dari menyelesaikan quests. Sistem ini memberikan value tambahan untuk rewards, membuat quest completion lebih meaningful, dan menambah depth ke game mechanics.

---

## 📋 Konsep Inventory System

### **Apa Itu Inventory?**

Inventory adalah sistem untuk:
- **Menyimpan items** yang didapat dari quest rewards
- **Menggunakan items** untuk berbagai keperluan (upgrade, trade, crafting)
- **Mengorganisir items** berdasarkan kategori
- **Menyediakan visual feedback** untuk collection progress

### **Kenapa Penting?**

1. **Value dari Rewards**: Items memberikan value tangible dari quest completion
2. **Collection Aspect**: User ingin collect rare items
3. **Strategic Depth**: User perlu decide how to use items
4. **Engagement**: Inventory management adalah aktivitas engaging
5. **Future Features**: Foundation untuk crafting, trading, upgrades

---

## 🎮 Fitur-Fitur Inventory

### **1. Item Collection**

Player mendapatkan items dari:
- **Quest Completion**: Items sebagai reward
- **Achievements**: Special items untuk milestones
- **Daily Quests**: Common items
- **Weekly Challenges**: Rare items
- **Level Up**: Level-up rewards

### **2. Item Categories (Real-World Based)**

Items dikategorikan menjadi item-item yang relatable dengan kehidupan sehari-hari:

#### **a. Food & Beverages** (Makanan & Minuman) - Consumables dengan Expiry
- Makanan yang memberikan efek (Energy, Health, Buffs)
- Memiliki expiry date (life span)
- Perlu dikonsumsi sebelum expired
- Contoh: 
  - "Nasi Goreng" - +30 Energy, Expires in 24 hours
  - "Sate Ayam" - +50 Energy, Expires in 12 hours
  - "Es Teh Manis" - +20 Energy, Expires in 6 hours
  - "Vitamin C" - +10% XP Boost for 8 hours, Expires in 30 days
  - "Makanan Ringan" - +10 Energy, Expires in 7 days

#### **b. Clothing & Apparel** (Pakaian & Aksesoris) - Equipment dengan Durability
- Pakaian yang memberikan stat boosts
- Memiliki durability (ketahanan)
- Durability berkurang dengan penggunaan
- Perlu diperbaiki atau diganti
- Contoh:
  - "Kemeja Formal" - +5 Confidence, Durability: 100/100
  - "Sepatu Sport" - +10 Stamina, Durability: 80/100
  - "Jaket Hoodie" - +5 Comfort, Durability: 90/100
  - "Jam Tangan" - +5 Focus, Durability: 100/100
  - "Tas Ransel" - +10 Storage, Durability: 85/100

#### **c. Daily Items** (Barang Sehari-hari) - Consumables/Equipment
- Items yang digunakan sehari-hari
- Ada yang consumable, ada yang equipment
- Contoh:
  - "Pensil" - Equipment, +5 Focus, Durability: 50/50
  - "Buku Catatan" - Equipment, +10 Organization, Durability: 100/100
  - "Kopi Sachet" - Consumable, +20 Energy, Expires in 30 days
  - "Tissue" - Consumable, Utility item, Expires in 90 days

#### **d. Materials & Resources** (Material & Sumber Daya)
- Resources untuk crafting/upgrading
- Tidak ada expiry (kecuali bahan makanan)
- Contoh:
  - "Kain" - Crafting material
  - "Benang" - Crafting material
  - "Kertas" - Crafting material
  - "Pulpen" - Crafting/equipment material

#### **e. Collectibles & Achievements** (Koleksi & Pencapaian)
- Trophy items, badges, memorabilia
- Tidak ada expiry atau durability
- Display only (trophy case)
- Contoh:
  - "Sertifikat Kursus" - Achievement item
  - "Foto Kenangan" - Collectible
  - "Medali Prestasi" - Achievement item
  - "Piagam" - Achievement item

#### **f. Keys & Access Items** (Kunci & Akses)
- Unlock special quests/features
- Tidak ada expiry
- Contoh:
  - "Kunci Ruang Rapat" - Unlock meeting quest
  - "Kartu Akses" - Unlock special area
  - "Voucher" - Unlock special quest/reward

---

## 📊 Data Models

### **Item Entity**

```dart
class Item {
  final String id;
  final String name;
  final String description;
  final ItemType type;           // Consumable, Equipment, Material, Collectible, Key
  final ItemRarity rarity;        // Common, Uncommon, Rare, Epic, Legendary
  final String iconUrl;           // Item icon/image
  final int maxStackSize;         // Max quantity per stack (default: 99)
  
  // Item-specific properties
  final ItemStats? stats;         // For equipment (attack, defense, etc.)
  final ItemEffect? effect;       // For consumables (XP boost, energy, etc.)
  final int? sellPrice;           // Can sell for currency (optional)
  final bool isTradable;          // Can trade with other players (future)
  final bool isUsable;            // Can use/consume item
  
  // Metadata
  final DateTime? obtainedAt;
  final String? obtainedFrom;     // Quest ID, Achievement ID, etc.
}

enum ItemType {
  consumable,
  equipment,
  material,
  collectible,
  key,
}

enum ItemRarity {
  common,      // Gray
  uncommon,    // Green
  rare,        // Blue
  epic,        // Purple
  legendary,   // Gold
}
```

### **Inventory Item (Player's Item Instance)**

```dart
class InventoryItem {
  final String id;
  final String itemId;            // Reference to Item
  final String playerId;
  final int quantity;             // Stack quantity
  final DateTime obtainedAt;
  final bool isEquipped;          // For equipment items
  
  // Expiry & Durability (instance-specific)
  final DateTime? expiresAt;      // Expiry date (for food/consumables)
  final int? currentDurability;   // Current durability (for clothing/equipment)
  final DateTime? lastUsedAt;     // Last time used (for durability calculation)
  
  // Status
  final bool isExpired;           // Computed: expiresAt != null && expiresAt < now
  final bool isBroken;            // Computed: currentDurability != null && currentDurability <= 0
  final double durabilityPercentage; // Computed: currentDurability / maxDurability
  
  // Reference to full Item data (loaded from repository)
  Item? item;
  
  // Helper methods
  bool get isNearExpiry {
    if (expiresAt == null) return false;
    final daysUntilExpiry = expiresAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry > 0;
  }
  
  bool get isLowDurability {
    if (currentDurability == null || item?.maxDurability == null) return false;
    return durabilityPercentage < 0.3; // Less than 30% durability
  }
}

class ItemStats {
  final int? attack;
  final int? defense;
  final int? health;
  final int? mana;
  final int? speed;
  final Map<String, int> customStats;  // Flexible stats
}

class ItemEffect {
  final EffectType type;          // XPBoost, EnergyRestore, StatBoost, etc.
  final int value;                // Effect value
  final Duration? duration;       // For temporary effects
}

enum EffectType {
  xpBoost,          // +X% XP gain
  energyRestore,    // +X energy
  statBoost,        // +X to stat
  speedBoost,       // +X% speed
  luckBoost,        // +X% luck
}
```

### **Inventory Storage**

```dart
class Inventory {
  final String playerId;
  final int maxSlots;             // Max inventory slots (expandable)
  final List<InventoryItem> items;
  final Map<String, int> itemQuantities;  // Quick lookup: itemId -> quantity
  
  // Equipment slots (for equipped items)
  final Map<EquipmentSlot, String?> equippedItems;  // slot -> inventoryItemId
  
  int get usedSlots => items.length;
  int get availableSlots => maxSlots - usedSlots;
  bool get isFull => usedSlots >= maxSlots;
}

enum EquipmentSlot {
  weapon,
  armor,
  accessory1,
  accessory2,
  // Add more as needed
}
```

---

## 🎨 UI/UX Design

### **1. Inventory Screen**

```
┌─────────────────────────────────────┐
│  🎒 Inventory            [Filter]   │
├─────────────────────────────────────┤
│  Slots: 45/50                       │
│  ┌─────┬─────┬─────┬─────┬─────┐   │
│  │ 🗡️  │ ⚔️  │ 🛡️  │ 💊  │ 💎  │   │
│  │ x1  │ x5  │ x1  │ x10 │ x3  │   │
│  ├─────┼─────┼─────┼─────┼─────┤   │
│  │ 📜  │ 🔑  │ 💰  │ ⭐  │ ⚡  │   │
│  │ x2  │ x1  │ x99 │ x1  │ x5  │   │
│  └─────┴─────┴─────┴─────┴─────┘   │
│                                     │
│  [Filter: All ▼] [Sort: Newest ▼]  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🗡️ Hero's Sword            │   │
│  │    [Rare] Attack +15        │   │
│  │    [EQUIPPED]               │   │
│  │    Tap for details          │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 💊 Energy Potion x10        │   │
│  │    [Common] Restore +20 Energy│ │
│  │    [USE] [SELL]             │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### **2. Item Detail Screen**

```
┌─────────────────────────────────────┐
│  ← Back          [EQUIP] [SELL]     │
├─────────────────────────────────────┤
│                                     │
│         [Item Icon Large]           │
│                                     │
│  Hero's Sword                       │
│  [Rare] ⭐⭐⭐                       │
│                                     │
│  A legendary sword passed down      │
│  through generations.               │
│                                     │
│  Stats:                             │
│  ⚔️ Attack: +15                    │
│  ⚡ Speed: +5                       │
│                                     │
│  Obtained:                          │
│  From: "Defeat the Dragon" Quest    │
│  Date: 2 days ago                   │
│                                     │
│  Quantity: 1                        │
│                                     │
└─────────────────────────────────────┘
```

### **3. Quick Access (Bottom Sheet)**

```
┌─────────────────────────────────────┐
│  Quick Use Items                    │
├─────────────────────────────────────┤
│  💊 Energy Potion x10      [USE]   │
│  ⚡ XP Boost x3            [USE]   │
│  💎 Magic Crystal x5      [USE]   │
│                                     │
│  [View All Items →]                │
└─────────────────────────────────────┘
```

---

## 🔄 User Journey dengan Inventory

### **1. Obtain Item (Quest Completion)**

```
Complete Quest
    ↓
Quest Completion Screen
    ↓
Reward Screen
    ├─ XP +100
    ├─ Gold +50
    └─ Item Rewards:
        ├─ 🗡️ Hero's Sword (x1) [Rare]
        └─ 💊 Energy Potion (x5) [Common]
    ↓
[Claim Rewards] Button
    ↓
Items added to Inventory
    ↓
Notification: "New items added to inventory!"
    ↓
[View Inventory] Button (optional)
```

### **2. Use Item (Consumable)**

```
Open Inventory
    ↓
Select Item (e.g., Energy Potion)
    ↓
Item Detail Screen
    ↓
[USE] Button
    ↓
Confirmation: "Use Energy Potion? +20 Energy"
    ↓
[Confirm]
    ↓
Item used (quantity -1)
    ↓
Effect applied (Energy +20)
    ↓
Notification: "Energy restored! +20"
```

### **3. Equip Item (Equipment)**

```
Open Inventory
    ↓
Select Equipment (e.g., Hero's Sword)
    ↓
Item Detail Screen
    ↓
[EQUIP] Button
    ↓
If already equipped:
    - Unequip current item
    - Equip new item
    ↓
Equipment changed
    ↓
Stats updated
    ↓
Notification: "Hero's Sword equipped! +15 Attack"
```

### **4. Sell Item**

```
Open Inventory
    ↓
Select Item
    ↓
Item Detail Screen
    ↓
[SELL] Button
    ↓
Confirmation: "Sell Energy Potion x10 for 50 Gold?"
    ↓
[Confirm]
    ↓
Item removed from inventory
    ↓
Gold added
    ↓
Notification: "Sold! +50 Gold"
```

---

## 💻 Implementation Details

### **1. Inventory Repository**

```dart
abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory(String playerId);
  Future<InventoryItem?> getItem(String inventoryItemId);
  Future<void> addItem(String playerId, String itemId, int quantity);
  Future<void> removeItem(String inventoryItemId, int quantity);
  Future<void> useItem(String inventoryItemId);
  Future<void> equipItem(String inventoryItemId, EquipmentSlot slot);
  Future<void> unequipItem(EquipmentSlot slot);
  Future<void> sellItem(String inventoryItemId, int quantity);
  
  // Local operations
  Future<void> saveInventoryLocally(Inventory inventory);
  Future<Inventory?> loadInventoryLocally(String playerId);
}
```

### **2. Inventory Use Cases**

```dart
// Use consumable item
class UseConsumableItemUseCase {
  Future<ItemEffect> execute(String inventoryItemId) async {
    // 1. Get inventory item
    // 2. Validate item type (must be consumable)
    // 3. Check quantity > 0
    // 4. Apply effect (update player stats/energy)
    // 5. Decrease quantity (or remove if quantity = 1)
    // 6. Save inventory
    // 7. Return effect
  }
}

// Equip equipment item
class EquipItemUseCase {
  Future<void> execute(String inventoryItemId, EquipmentSlot slot) async {
    // 1. Get inventory item
    // 2. Validate item type (must be equipment)
    // 3. Unequip current item in slot (if any)
    // 4. Equip new item
    // 5. Update player stats
    // 6. Save inventory
  }
}

// Add item to inventory (from quest reward)
class AddItemToInventoryUseCase {
  Future<void> execute(String playerId, String itemId, int quantity) async {
    // 1. Check if item already exists in inventory
    // 2. If exists and stackable: increase quantity
    // 3. If not exists: add new inventory item
    // 4. Check inventory space
    // 5. Save inventory
  }
}
```

### **3. Inventory BLoC**

```dart
// Inventory Events
abstract class InventoryEvent {}

class LoadInventory extends InventoryEvent {}
class UseItem extends InventoryEvent {
  final String inventoryItemId;
}
class EquipItem extends InventoryEvent {
  final String inventoryItemId;
  final EquipmentSlot slot;
}
class UnequipItem extends InventoryEvent {
  final EquipmentSlot slot;
}
class SellItem extends InventoryEvent {
  final String inventoryItemId;
  final int quantity;
}

// Inventory States
class InventoryState {}

class InventoryInitial extends InventoryState {}
class InventoryLoading extends InventoryState {}
class InventoryLoaded extends InventoryState {
  final Inventory inventory;
  final List<InventoryItem> items;
}
class InventoryError extends InventoryState {
  final String message;
}
class ItemUsed extends InventoryState {
  final ItemEffect effect;
}
```

---

## 🎯 Integration dengan Quest System

### **Quest Rewards dengan Items**

```dart
class QuestReward {
  final int experience;
  final int currency;
  final List<ItemReward> items;  // NEW
  final List<Achievement>? achievements;
}

class ItemReward {
  final String itemId;
  final int quantity;
  final ItemRarity? guaranteedRarity;  // For random rewards
}

// Quest completion flow
class CompleteQuestUseCase {
  Future<QuestReward> execute(String questId) async {
    // 1. Mark quest as completed
    // 2. Calculate rewards
    // 3. Add XP and currency to player
    // 4. Add items to inventory (NEW)
    // 5. Check for achievements
    // 6. Return reward summary
  }
}
```

### **Items sebagai Quest Requirements**

```dart
class QuestRequirement {
  final RequirementType type;
  final String? itemId;      // For item requirements
  final int? quantity;       // For item quantity
  final int? level;          // For level requirements
  // ... other requirements
}

// Quest unlock check
bool canStartQuest(Quest quest, Player player, Inventory inventory) {
  // Check level requirement
  if (quest.requiredLevel > player.level) return false;
  
  // Check item requirements (NEW)
  for (var requirement in quest.requirements) {
    if (requirement.type == RequirementType.item) {
      final itemQuantity = inventory.getItemQuantity(requirement.itemId!);
      if (itemQuantity < requirement.quantity!) return false;
    }
  }
  
  return true;
}
```

---

## 📈 MVP Implementation Plan

### **Phase 1: Basic Inventory (MVP)**

**Week 1-2: Data Models & Storage**
- [ ] Create Item, InventoryItem, Inventory entities
- [ ] Setup inventory repository
- [ ] Local storage for inventory (Hive/SQLite)
- [ ] Basic CRUD operations

**Week 3-4: UI & Basic Operations**
- [ ] Inventory screen (list view)
- [ ] Item detail screen
- [ ] Add items to inventory (from quest rewards)
- [ ] View inventory
- [ ] Basic filtering (by type)

**Week 5-6: Item Usage**
- [ ] Use consumable items
- [ ] Apply item effects (XP boost, energy restore)
- [ ] Item quantity management
- [ ] Basic animations/feedback

**Week 7-8: Equipment System (Optional untuk MVP)**
- [ ] Equip/Unequip items
- [ ] Equipment slots
- [ ] Stat calculation from equipment
- [ ] Or: Skip equipment, focus on consumables only

### **Phase 2: Enhanced Inventory**

- [ ] Item selling
- [ ] Item sorting & advanced filters
- [ ] Inventory expansion (buy more slots)
- [ ] Item categories/tabs
- [ ] Item search
- [ ] Collection view (for collectibles)

### **Phase 3: Advanced Features**

- [ ] Item crafting (combine materials)
- [ ] Item trading (multiplayer)
- [ ] Item upgrading/enhancing
- [ ] Item sets (set bonuses)
- [ ] Item marketplace (future)

---

## 🎮 Example Items untuk LevelUp (Real-World Based)

### **Food & Beverages** (Makanan & Minuman)

```
🍱 Nasi Goreng (Common)
- Type: Food
- Effect: +30 Energy
- Expiry: 24 hours setelah diperoleh
- Stack: 10
- Sell Price: 5 Gold
- Life Span: Short (perishable)

🍗 Sate Ayam (Common)
- Type: Food
- Effect: +50 Energy
- Expiry: 12 hours setelah diperoleh
- Stack: 5
- Sell Price: 8 Gold
- Life Span: Short (perishable)

🧊 Es Teh Manis (Common)
- Type: Beverage
- Effect: +20 Energy
- Expiry: 6 hours setelah diperoleh
- Stack: 20
- Sell Price: 3 Gold
- Life Span: Very Short (drinks)

💊 Vitamin C (Uncommon)
- Type: Supplement
- Effect: +10% XP Boost for 8 hours
- Expiry: 30 days setelah diperoleh
- Stack: 30
- Sell Price: 15 Gold
- Life Span: Medium (supplements)

🍪 Makanan Ringan (Common)
- Type: Snack
- Effect: +10 Energy
- Expiry: 7 days setelah diperoleh
- Stack: 50
- Sell Price: 2 Gold
- Life Span: Medium (packaged food)

☕ Kopi Sachet (Common)
- Type: Beverage
- Effect: +25 Energy, +5% Focus for 2 hours
- Expiry: 90 days setelah diperoleh
- Stack: 30
- Sell Price: 5 Gold
- Life Span: Long (packaged)

🍎 Buah Apel (Common)
- Type: Food
- Effect: +15 Energy, +5 Health
- Expiry: 7 days setelah diperoleh
- Stack: 20
- Sell Price: 4 Gold
- Life Span: Medium (fresh fruit)
```

### **Clothing & Apparel** (Pakaian & Aksesoris)

```
👔 Kemeja Formal (Uncommon)
- Type: Clothing
- Stats: +5 Confidence, +3 Professionalism
- Durability: 100/100 (max)
- Durability Loss: -1 per use (worn)
- Repair Cost: 10 Gold per 10 durability
- Obtained from: "Job Interview" Quest
- Life Span: Long (with maintenance)

👟 Sepatu Sport (Common)
- Type: Footwear
- Stats: +10 Stamina, +5 Speed
- Durability: 100/100 (max)
- Durability Loss: -2 per use (more wear)
- Repair Cost: 15 Gold per 10 durability
- Obtained from: "Daily Exercise" Quest
- Life Span: Medium (high wear)

🧥 Jaket Hoodie (Common)
- Type: Clothing
- Stats: +5 Comfort, +3 Warmth
- Durability: 100/100 (max)
- Durability Loss: -1 per use
- Repair Cost: 8 Gold per 10 durability
- Obtained from: Daily quest reward
- Life Span: Long (casual wear)

⌚ Jam Tangan (Rare)
- Type: Accessory
- Stats: +5 Focus, +3 Punctuality
- Durability: 100/100 (max)
- Durability Loss: -0.5 per use (very durable)
- Repair Cost: 20 Gold per 10 durability
- Obtained from: "Time Management" Quest
- Life Span: Very Long (durable item)

🎒 Tas Ransel (Common)
- Type: Accessory
- Stats: +10 Storage Capacity, +5 Organization
- Durability: 100/100 (max)
- Durability Loss: -1.5 per use
- Repair Cost: 12 Gold per 10 durability
- Obtained from: "Get Organized" Quest
- Life Span: Medium-Long

👓 Kacamata (Uncommon)
- Type: Accessory
- Stats: +8 Focus, +5 Eye Comfort
- Durability: 100/100 (max)
- Durability Loss: -0.3 per use (very durable)
- Repair Cost: 25 Gold per 10 durability
- Obtained from: "Eye Health" Quest
- Life Span: Very Long
```

### **Daily Items** (Barang Sehari-hari)

```
✏️ Pensil (Common)
- Type: DailyItem (Equipment)
- Stats: +5 Focus, +3 Creativity
- Durability: 50/50 (max) - disposable
- Durability Loss: -5 per use (fast wear)
- Cannot repair (disposable)
- Stack: 20
- Sell Price: 1 Gold
- Life Span: Short (disposable)

📔 Buku Catatan (Common)
- Type: DailyItem (Equipment)
- Stats: +10 Organization, +5 Memory
- Durability: 100/100 (max)
- Durability Loss: -2 per use
- Repair Cost: 5 Gold per 10 durability
- Stack: 5
- Sell Price: 8 Gold
- Life Span: Medium

📱 Charger HP (Common)
- Type: DailyItem (Equipment)
- Stats: +10 Energy Management (metaphorically)
- Durability: 80/80 (max)
- Durability Loss: -1 per use
- Repair Cost: 15 Gold per 10 durability
- Sell Price: 20 Gold
- Life Span: Medium-Long

🧴 Parfum (Uncommon)
- Type: DailyItem (Consumable)
- Effect: +5 Confidence, +3 Charisma for 6 hours
- Expiry: 365 days (1 year)
- Stack: 3
- Sell Price: 50 Gold
- Life Span: Long (fragrance)

💧 Air Mineral (Common)
- Type: DailyItem (Consumable)
- Effect: +10 Energy, +5 Health
- Expiry: Tidak expired (water)
- Stack: 24 (1 pack)
- Sell Price: 1 Gold
- Life Span: Unlimited (water)
```

### **Materials & Resources**

```
🧵 Kain (Common)
- Type: Material
- Used for: Crafting clothing, repairs
- Stack: 99
- Sell Price: 5 Gold
- No expiry
- Obtained from: Crafting quests, Daily quests

📄 Kertas (Common)
- Type: Material
- Used for: Crafting, notes, documents
- Stack: 99
- Sell Price: 2 Gold
- No expiry
- Obtained from: Office quests, Daily quests

🪡 Benang (Common)
- Type: Material
- Used for: Clothing repairs, crafting
- Stack: 99
- Sell Price: 3 Gold
- No expiry
- Obtained from: Crafting quests

📦 Kotak (Common)
- Type: Material
- Used for: Storage, organization
- Stack: 50
- Sell Price: 4 Gold
- No expiry
- Obtained from: Organization quests
```

### **Collectibles & Achievements**

```
🏆 Sertifikat Kursus (Collectible)
- Type: Collectible
- Rarity: Uncommon
- Obtained from: Complete course quest
- Display only (trophy case)
- No expiry, no durability

📸 Foto Kenangan (Collectible)
- Type: Collectible
- Rarity: Common
- Obtained from: Social quests, Events
- Display only
- No expiry, no durability

🥇 Medali Prestasi (Collectible)
- Type: Collectible
- Rarity: Rare
- Obtained from: Achievement milestones
- Display only
- No expiry, no durability

📜 Piagam (Collectible)
- Type: Collectible
- Rarity: Epic
- Obtained from: Major achievements
- Display only
- No expiry, no durability
```

### **Keys & Access Items**

```
🔑 Kunci Ruang Rapat (Key)
- Type: Key
- Unlocks: Meeting quests, Office areas
- No expiry, no durability
- Stack: 1 (unique item)

💳 Kartu Akses (Key)
- Type: Key
- Unlocks: Special quest areas
- No expiry, no durability
- Stack: 1 (unique item)

🎫 Voucher Makan (Key)
- Type: Key
- Unlocks: Special quest/reward
- Expiry: 30 days (voucher expiry)
- Stack: 5
- Sell Price: Cannot sell
```

---

## ⏰ Life Span & Durability System

### **Food & Beverages - Expiry System**

**Expiry Duration (Life Span)**:
- **Very Short** (6-12 hours): Minuman, makanan cepat saji
- **Short** (12-24 hours): Makanan segar, nasi goreng, sate
- **Medium** (7-30 days): Makanan ringan, vitamin, buah
- **Long** (30-365 days): Makanan kemasan, kopi sachet, parfum
- **Unlimited**: Air mineral (tidak expired)

**Expiry Behavior**:
- Item expired: Cannot use, can only discard or sell (reduced price)
- Near expiry warning (3 days remaining): Visual indicator, notification
- Auto-remove expired items: Optional (user preference)

### **Clothing & Equipment - Durability System**

**Durability Range**:
- **Very Durable** (0.3-0.5 per use): Jam tangan, kacamata
- **Durable** (1 per use): Kemeja, jaket, tas
- **Medium** (1.5-2 per use): Sepatu, tas (high wear)
- **Fast Wear** (5 per use): Pensil (disposable)

**Durability Behavior**:
- Item broken (0 durability): Cannot use, need repair
- Low durability warning (<30%): Visual indicator, repair suggestion
- Repair system: Pay currency to restore durability
- Cannot repair: Disposable items (pensil)

### **Durability Loss Calculation**

```dart
class DurabilitySystem {
  // Durability loss per use
  static double calculateDurabilityLoss(Item item, ItemUsageType usage) {
    final baseLoss = item.durabilityLossPerUse ?? 1.0;
    
    switch (usage) {
      case ItemUsageType.normal:
        return baseLoss;
      case ItemUsageType.heavy:
        return baseLoss * 1.5; // Heavy use = more wear
      case ItemUsageType.light:
        return baseLoss * 0.5; // Light use = less wear
    }
  }
  
  // Repair cost calculation
  static int calculateRepairCost(Item item, int durabilityToRestore) {
    final costPerDurability = item.repairCostPerDurability ?? 1;
    return (durabilityToRestore * costPerDurability).round();
  }
}
```

---

## 🔐 Considerations

### **1. Inventory Limits**

- **Max Slots**: Start with 50 slots, expandable
- **Stack Size**: Per item type (consumables: 99, equipment: 1)
- **Storage Cost**: Can charge currency untuk expand (future)

### **2. Item Balance**

- **Drop Rates**: Balance item rarity
- **Item Value**: Balance sell prices
- **Item Effects**: Balance consumable effects
- **Item Stats**: Balance equipment stats

### **3. Offline Support**

- Inventory stored locally
- Items can be used offline
- Sync when online
- Handle conflicts (item quantity changes)

### **4. Performance**

- Lazy loading untuk large inventories
- Image caching untuk item icons
- Efficient queries (filter, sort)
- Pagination jika banyak items

---

## 📊 Success Metrics

### **Engagement**
- Items collected per user
- Items used per session
- Inventory screen visits
- Time spent managing inventory

### **Retention**
- Users who collect items daily
- Users who use items regularly
- Users who complete quests for items

### **Economy**
- Item drop rates
- Item usage patterns
- Item sell frequency
- Currency flow from items

---

## ✅ Summary

### **Inventory System Features:**

1. **Item Collection**: Get items from quests, achievements, levels
2. **Item Categories**: Consumables, Equipment, Materials, Collectibles, Keys
3. **Item Usage**: Use consumables, equip equipment
4. **Item Management**: View, filter, sort, sell items
5. **Item Integration**: Items as rewards, items as quest requirements

### **MVP Scope:**

- Basic inventory (store items)
- Item viewing (list, detail)
- Consumable usage (use items)
- Equipment system (equip/unequip) - Optional
- Item rewards from quests
- Local storage & sync

### **Post-MVP:**

- Item selling
- Advanced filters & search
- Item crafting
- Item trading
- Inventory expansion
- Item marketplace

---

**Last Updated**: 2024  
**Status**: Ready for Implementation Planning 🚀

