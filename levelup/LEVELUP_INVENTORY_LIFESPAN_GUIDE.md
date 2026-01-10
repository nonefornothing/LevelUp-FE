# ⏰ Inventory Life Span & Durability Guide

## 📋 Overview

Guide lengkap untuk sistem **Life Span (Expiry)** dan **Durability** untuk inventory items yang berdasarkan real-world items.

---

## 🍱 Food & Beverages - Expiry System

### **Expiry Categories**

#### **1. Very Short Life Span (6-12 hours)**
- **Minuman**: Es teh, es jeruk, jus segar
- **Makanan cepat saji**: Burger, hot dog (yang perlu cepat dikonsumsi)
- **Contoh**: Es Teh Manis (6 hours), Juice Segar (12 hours)

#### **2. Short Life Span (12-24 hours)**
- **Makanan segar**: Nasi goreng, sate, gado-gado
- **Makanan rumah**: Masakan yang baru dimasak
- **Contoh**: Nasi Goreng (24 hours), Sate Ayam (12 hours)

#### **3. Medium Life Span (7-30 days)**
- **Makanan ringan**: Snacks, biskuit, kerupuk
- **Buah-buahan**: Apel, pisang (fresh fruit)
- **Vitamin/Supplement**: Vitamin C, multivitamin
- **Contoh**: Makanan Ringan (7 days), Vitamin C (30 days), Buah Apel (7 days)

#### **4. Long Life Span (30-365 days)**
- **Makanan kemasan**: Mie instan, kopi sachet, makanan kaleng
- **Bahan dapur**: Bumbu, rempah (packaged)
- **Contoh**: Kopi Sachet (90 days), Mie Instan (365 days)

#### **5. Unlimited Life Span**
- **Air mineral**: Tidak expired
- **Garam, gula** (basic ingredients)
- **Contoh**: Air Mineral (no expiry)

### **Expiry Implementation**

```dart
class FoodItem extends Item {
  final Duration expiryDuration;
  
  // Calculate expiry date when item obtained
  DateTime calculateExpiryDate(DateTime obtainedAt) {
    return obtainedAt.add(expiryDuration);
  }
  
  // Check if expired
  bool isExpired(DateTime currentTime, DateTime? expiresAt) {
    return expiresAt != null && currentTime.isAfter(expiresAt);
  }
  
  // Get days until expiry
  int daysUntilExpiry(DateTime? expiresAt) {
    if (expiresAt == null) return -1;
    return expiresAt.difference(DateTime.now()).inDays;
  }
  
  // Check if near expiry (warning threshold)
  bool isNearExpiry(DateTime? expiresAt, {int thresholdDays = 3}) {
    final days = daysUntilExpiry(expiresAt);
    return days > 0 && days <= thresholdDays;
  }
}
```

### **Expiry Warnings**

- **Green**: > 7 days remaining (safe)
- **Yellow**: 3-7 days remaining (warning)
- **Orange**: 1-3 days remaining (near expiry)
- **Red**: < 1 day remaining (critical)
- **Gray**: Expired (cannot use)

---

## 👔 Clothing & Apparel - Durability System

### **Durability Categories**

#### **1. Very Durable (0.3-0.5 per use)**
- **Jewelry & Accessories**: Jam tangan, kacamata, cincin
- **High-quality items**: Items dengan build quality tinggi
- **Contoh**: Jam Tangan (-0.5), Kacamata (-0.3)

#### **2. Durable (1 per use)**
- **Casual Clothing**: Kemeja, jaket, celana
- **Standard quality items**
- **Contoh**: Kemeja Formal (-1), Jaket Hoodie (-1)

#### **3. Medium Durability (1.5-2 per use)**
- **High-wear items**: Sepatu, tas (lebih sering digunakan)
- **Active wear**: Items untuk aktivitas fisik
- **Contoh**: Sepatu Sport (-2), Tas Ransel (-1.5)

#### **4. Fast Wear (5+ per use)**
- **Disposable items**: Pensil, pulpen (disposable)
- **Single-use items**: Items yang tidak dirancang untuk reuse
- **Contoh**: Pensil (-5), Pulpen (-5)

### **Durability Implementation**

```dart
class ClothingItem extends Item {
  final int maxDurability;
  final double durabilityLossPerUse;
  final int repairCostPerDurability;
  
  // Calculate durability after use
  int calculateDurabilityAfterUse(int currentDurability, ItemUsageType usage) {
    final loss = calculateDurabilityLoss(usage);
    return (currentDurability - loss).clamp(0, maxDurability);
  }
  
  // Check if broken
  bool isBroken(int currentDurability) {
    return currentDurability <= 0;
  }
  
  // Check if low durability
  bool isLowDurability(int currentDurability, {double threshold = 0.3}) {
    return (currentDurability / maxDurability) < threshold;
  }
  
  // Calculate repair cost
  int calculateRepairCost(int durabilityToRestore) {
    return (durabilityToRestore * repairCostPerDurability).round();
  }
}
```

### **Durability Warnings**

- **Green**: > 70% durability (excellent)
- **Yellow**: 30-70% durability (good)
- **Orange**: 10-30% durability (low - repair soon)
- **Red**: < 10% durability (critical - repair needed)
- **Gray**: 0% durability (broken - cannot use)

---

## 🔄 Item Life Cycle Examples

### **Example 1: Nasi Goreng (Food)**

```
1. Quest Completion
   → Obtain "Nasi Goreng" (x1)
   → Expiry: +24 hours from now
   
2. Day 1 (8 AM)
   → Item in inventory
   → Status: Fresh (23 hours remaining)
   
3. Day 1 (6 PM)
   → Use item (+30 Energy)
   → Item consumed (removed from inventory)
   → OR if not used: 17 hours remaining
   
4. Day 2 (8 AM)
   → If not used yesterday:
   → Status: Expired (cannot use)
   → Options: Discard or Sell (reduced price: 1 Gold)
```

### **Example 2: Kemeja Formal (Clothing)**

```
1. Quest Completion
   → Obtain "Kemeja Formal" (x1)
   → Durability: 100/100
   
2. Use Item (Wear to meeting)
   → Durability: 99/100 (-1)
   → Stats applied: +5 Confidence
   
3. After 50 uses
   → Durability: 50/100 (50% remaining)
   → Status: Good condition
   
4. After 70 uses
   → Durability: 30/100 (30% remaining)
   → Warning: "Low durability - Repair soon!"
   
5. After 95 uses
   → Durability: 5/100 (5% remaining)
   → Warning: "Critical durability - Repair needed!"
   
6. After 100 uses
   → Durability: 0/100
   → Status: Broken (cannot use)
   → Option: Repair (cost: 100 Gold to restore to 100/100)
   → OR: Discard/Sell
```

### **Example 3: Pensil (Disposable Item)**

```
1. Quest Completion
   → Obtain "Pensil" (x20)
   → Durability: 50/50 (each)
   
2. Use Item (Write notes)
   → Durability: 45/50 (-5)
   
3. After 10 uses
   → Durability: 0/50
   → Status: Broken (cannot use)
   → Item removed (disposable - cannot repair)
   → Next pencil auto-equipped (if available)
```

---

## 📊 Item Status Indicators

### **Visual Indicators**

```
🍱 Nasi Goreng
   Status: ⚠️ Expires in 2 days
   [Yellow indicator]
   
👔 Kemeja Formal
   Status: ⚠️ 25/100 Durability (Low)
   [Orange indicator]
   
💊 Vitamin C
   Status: ✅ 28 days remaining
   [Green indicator]
   
👟 Sepatu Sport
   Status: ❌ 0/100 (Broken - Repair needed)
   [Red indicator]
```

### **Status Badges**

- ✅ **Good**: Item in good condition
- ⚠️ **Warning**: Near expiry or low durability
- ❌ **Critical**: Expired or broken
- 🔄 **Repairing**: Item being repaired
- 🗑️ **Expired**: Food expired (cannot use)

---

## 🛠️ Repair & Maintenance System

### **Repair Mechanics**

1. **Repair Cost Formula**:
   ```
   Repair Cost = Durability to Restore × Cost per Durability Point
   ```

2. **Repair Options**:
   - **Full Repair**: Restore to max durability (expensive)
   - **Partial Repair**: Restore specific amount (flexible)
   - **Cannot Repair**: Disposable items (pensil, etc.)

3. **Repair Time**:
   - **Instant**: For MVP (simplified)
   - **Delayed**: Future feature (realistic repair time)

### **Maintenance Tips (UI Messages)**

- "Your Kemeja Formal is getting worn (25% durability). Consider repairing soon!"
- "Nasi Goreng will expire in 2 hours. Use it now!"
- "Your Sepatu Sport is broken. Repair for 150 Gold or replace it."

---

## 💡 Best Practices

### **For Food Items**

1. **Use before expiry**: Encourage users to use food items
2. **Expiry warnings**: Notify users 3 days before expiry
3. **Auto-sort**: Sort inventory by expiry date (soonest first)
4. **Discard expired**: Option to auto-discard expired items

### **For Clothing Items**

1. **Regular maintenance**: Repair before durability gets too low
2. **Durability warnings**: Notify at 30% and 10% thresholds
3. **Repair cost awareness**: Show repair cost before confirming
4. **Multiple items**: Allow users to have backup items

---

## 🎯 Integration dengan Quest System

### **Quest Rewards dengan Life Span**

```dart
// Quest reward dengan expiry
QuestReward {
  items: [
    ItemReward(
      itemId: "nasi_goreng",
      quantity: 2,
      // Expiry calculated when obtained
      expiresIn: Duration(hours: 24),
    ),
    ItemReward(
      itemId: "kemeja_formal",
      quantity: 1,
      // Durability: full when obtained
      durability: 100,
    ),
  ],
}
```

### **Quest Requirements dengan Durability**

```dart
// Quest might require items in good condition
QuestRequirement {
  type: RequirementType.item,
  itemId: "kemeja_formal",
  minDurability: 50, // Must have at least 50% durability
}
```

---

## ✅ Summary

### **Key Points**

1. **Food Items**: Have expiry dates (6 hours to unlimited)
2. **Clothing Items**: Have durability (0.3 to 5+ per use)
3. **Warnings**: Visual indicators for expiry and low durability
4. **Repair System**: Restore durability with currency cost
5. **Real-World Logic**: Items behave like real-world items

### **Implementation Priority**

- **MVP**: Basic expiry and durability tracking
- **Phase 2**: Repair system, warnings, notifications
- **Phase 3**: Advanced maintenance, auto-repair, item degradation over time

---

**Related Documents**:
- `LEVELUP_INVENTORY_FEATURE.md` - Full inventory documentation
- `LEVELUP_INVENTORY_QUICK_REFERENCE.md` - Quick reference

**Last Updated**: 2024  
**Status**: Ready for Implementation 🚀

