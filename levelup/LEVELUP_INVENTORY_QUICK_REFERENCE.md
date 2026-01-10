# 🎒 Inventory System - Quick Reference

## 🎯 Overview

Inventory System adalah sistem untuk menyimpan dan menggunakan items yang didapat dari quest rewards. Items memberikan value tangible dari quest completion dan menambah depth ke game mechanics.

**Full Documentation**: Lihat `LEVELUP_INVENTORY_FEATURE.md` untuk detail lengkap.

---

## 📋 Konsep Utama

### **Apa Itu Inventory?**

Sistem untuk:
- **Menyimpan items** dari quest rewards
- **Menggunakan items** (consumables, equipment)
- **Mengorganisir items** berdasarkan kategori
- **Collection progress** tracking

### **Item Categories**

1. **Consumables** 💊 - Dapat dipakai (Potions, Buffs)
2. **Equipment** 🗡️ - Dapat dipasang (Weapons, Armor, Accessories)
3. **Materials** 💎 - Untuk crafting/trading (Resources, Ores)
4. **Collectibles** 🏆 - Trophy items (Achievements, Badges)
5. **Keys** 🔑 - Unlock items (Quest keys, Access items)

---

## 🎮 Fitur Utama

### **1. Item Collection**
- Items dari quest completion
- Items dari achievements
- Items dari daily/weekly challenges
- Items dari level ups

### **2. Item Usage**
- **Use Consumables**: Potions, buffs, temporary effects
- **Equip Equipment**: Weapons, armor, accessories
- **Sell Items**: Convert items to currency
- **View Details**: Item stats, description, rarity

### **3. Inventory Management**
- View all items (grid/list view)
- Filter by type, rarity
- Sort by name, date, rarity
- Search items (optional)
- Item quantity management

---

## 📊 Data Models (Simplified)

```dart
// Item Entity
class Item {
  String id;
  String name;
  ItemType type;        // Consumable, Equipment, Material, etc.
  ItemRarity rarity;    // Common, Uncommon, Rare, Epic, Legendary
  ItemStats? stats;     // For equipment
  ItemEffect? effect;   // For consumables
  int maxStackSize;     // Stack limit
  bool isUsable;
  bool isTradable;
}

// Player's Inventory Item
class InventoryItem {
  String id;
  String itemId;        // Reference to Item
  int quantity;         // Stack quantity
  bool isEquipped;      // For equipment
  DateTime obtainedAt;
}

// Inventory
class Inventory {
  List<InventoryItem> items;
  Map<EquipmentSlot, String?> equippedItems;
  int maxSlots;
  int usedSlots;
}
```

---

## 🎨 UI/UX (Key Screens)

### **1. Inventory Screen**
- Grid/List view items
- Filter buttons (Type, Rarity)
- Sort options
- Item slots indicator (45/50)
- Quick actions (Use, Equip, Sell)

### **2. Item Detail Screen**
- Large item icon
- Item name & rarity
- Description
- Stats/Effects
- Action buttons (Use, Equip, Sell)
- Obtained info

### **3. Quick Access (Bottom Sheet)**
- Quick use items
- Frequently used items
- Fast access untuk consumables

---

## 🔄 Integration dengan Quest System

### **Quest Rewards**
```dart
QuestReward {
  int experience;
  int currency;
  List<ItemReward> items;  // NEW
}

ItemReward {
  String itemId;
  int quantity;
}
```

### **Quest Requirements**
```dart
// Quest bisa require items
QuestRequirement {
  RequirementType.item;
  String itemId;
  int quantity;
}

// Check before starting quest
canStartQuest(Quest quest, Inventory inventory) {
  // Check if player has required items
}
```

---

## 🚀 MVP Implementation

### **Phase 1: Basic Inventory (MVP - Phase 2)**

**Must Have**:
- ✅ Item storage (add/remove items)
- ✅ Inventory screen (view items)
- ✅ Item detail screen
- ✅ Use consumables (basic)
- ✅ Item rewards from quests

**Should Have**:
- Equip equipment (basic)
- Item filtering (by type)
- Item selling (basic)
- Empty states

**Nice to Have**:
- Equipment slots
- Item sorting
- Item search
- Advanced animations

### **Phase 2: Enhanced Inventory**

- Equipment system (full)
- Item selling (full)
- Advanced filters & search
- Inventory expansion
- Item categories/tabs
- Collection view

### **Phase 3: Advanced Features**

- Item crafting
- Item trading (multiplayer)
- Item upgrading
- Item sets
- Item marketplace

---

## 📈 Example Items

### **Consumables**
- 💊 Energy Potion: +20 Energy (Common)
- ⚡ XP Boost Potion: +50% XP for 1 hour (Uncommon)
- 🧪 Stamina Elixir: +50 Energy (Rare)

### **Equipment**
- 🗡️ Hero's Sword: Attack +15, Speed +5 (Rare)
- 🛡️ Guardian Shield: Defense +20, Health +50 (Epic)
- 💍 Wisdom Ring: XP +25%, Mana +30 (Legendary)

### **Materials**
- 💎 Magic Crystal: Crafting material (Common)
- ⚙️ Iron Ore: Weapon crafting (Common)
- ✨ Rare Gem: High-level crafting (Rare)

### **Collectibles**
- 🏆 First Quest Badge: Complete first quest (Trophy)
- ⭐ Level 10 Trophy: Reach Level 10 (Trophy)
- 👑 Dragon Slayer Medal: Complete dragon quest (Trophy)

---

## 🎯 Key Points

1. **Items dari Quest Rewards**: Quest completion memberikan items sebagai rewards
2. **Item Usage**: Items dapat digunakan (consumables) atau dipasang (equipment)
3. **Collection Aspect**: User ingin collect rare items
4. **Integration**: Items terintegrasi dengan quest system (rewards & requirements)
5. **MVP Scope**: Start dengan basic inventory (store, view, use), expand later

---

## ✅ Quick Checklist untuk Implementation

### **Data Layer**
- [ ] Item entity
- [ ] InventoryItem entity
- [ ] Inventory entity
- [ ] Repository interface
- [ ] Repository implementation
- [ ] Local storage

### **Business Logic**
- [ ] Add item use case
- [ ] Use item use case
- [ ] Equip item use case
- [ ] Sell item use case
- [ ] Get inventory use case

### **UI Layer**
- [ ] Inventory screen
- [ ] Item detail screen
- [ ] Item card widget
- [ ] Filter widgets
- [ ] Quick access bottom sheet

### **Integration**
- [ ] Quest rewards dengan items
- [ ] Add items to inventory after quest
- [ ] Item requirements untuk quests
- [ ] Equipment stats affect player stats

---

**Full Documentation**: `LEVELUP_INVENTORY_FEATURE.md`  
**Status**: Ready for Phase 2 Implementation 🚀

