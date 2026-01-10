# 📱 Offline-First Implementation Guide

## ✅ Konfirmasi: Arsitektur Sudah Cocok untuk Offline-First

Arsitektur yang direkomendasikan **SUDAH COCOK** untuk aplikasi offline-first yang akan didownload dari Google Play. Berikut penjelasan detail:

---

## 🎯 Prinsip Offline-First

### **1. Data Local-First (Room Database)**

✅ **Sudah Direkomendasikan:**
- **Room Database** sebagai local storage utama
- Semua data user disimpan lokal di device
- Aplikasi bisa berfungsi penuh tanpa internet

**Implementation:**
```kotlin
// Semua operasi CRUD langsung ke Room DB
@Dao
interface GoalDao {
    @Query("SELECT * FROM goals WHERE userId = :userId")
    suspend fun getGoals(userId: String): List<GoalEntity>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertGoal(goal: GoalEntity)
    
    @Update
    suspend fun updateGoal(goal: GoalEntity)
}
```

**Flow:**
```
User Action (Create Goal)
    ↓
Write to Room DB (INSTANT) ✅
    ↓
UI Update (INSTANT) ✅
    ↓
Queue untuk Sync (Background)
    ↓
Sync ke Backend (ketika online)
```

### **2. Sync Engine (WorkManager)**

✅ **Sudah Direkomendasikan:**
- **WorkManager** untuk background sync
- Queue system untuk pending changes
- Automatic retry jika sync gagal

**Implementation:**
```kotlin
// Sync Worker
class SyncWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result {
        return try {
            // 1. Get pending changes dari Room DB
            val pendingChanges = syncRepository.getPendingChanges()
            
            // 2. Sync ke backend
            pendingChanges.forEach { change ->
                when (change.type) {
                    ChangeType.CREATE -> api.createGoal(change.data)
                    ChangeType.UPDATE -> api.updateGoal(change.data)
                    ChangeType.DELETE -> api.deleteGoal(change.id)
                }
                
                // 3. Mark as synced
                syncRepository.markAsSynced(change.id)
            }
            
            Result.success()
        } catch (e: Exception) {
            // Retry jika gagal
            Result.retry()
        }
    }
}

// Schedule periodic sync
val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES)
    .setConstraints(
        Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()
    )
    .build()

WorkManager.getInstance(context).enqueue(syncRequest)
```

### **3. Conflict Resolution**

✅ **Sudah Direkomendasikan:**
- Last Write Wins untuk simple fields
- Merge untuk arrays
- User choice untuk critical conflicts

**Implementation:**
```kotlin
fun resolveConflict(local: GoalEntity, remote: GoalEntity): GoalEntity {
    return when {
        // Remote lebih baru
        remote.updatedAt > local.updatedAt -> {
            // Merge arrays (evidence, tags)
            remote.copy(
                evidenceUrls = (local.evidenceUrls + remote.evidenceUrls).distinct(),
                tags = (local.tags + remote.tags).distinct()
            )
        }
        // Local lebih baru
        local.updatedAt > remote.updatedAt -> {
            local.copy(
                evidenceUrls = (local.evidenceUrls + remote.evidenceUrls).distinct(),
                tags = (local.tags + remote.tags).distinct()
            )
        }
        // Same: prefer local
        else -> local
    }
}
```

---

## 📦 Data yang Harus Disimpan Lokal

### **Critical Data (Must Cache):**
1. ✅ **User Profile** - Identity, North Star, Core Values
2. ✅ **Domains** - Semua domain user
3. ✅ **Goals/Quests** - Semua goals aktif
4. ✅ **Actions** - Semua actions per goal
5. ✅ **Daily Check-ins** - History check-in
6. ✅ **Domain Scores** - History scores
7. ✅ **Evidence Items** - Evidence vault (metadata)
8. ✅ **Weekly Reviews** - History reviews

### **Optional Data (Can Fetch on Demand):**
- Analytics data (bisa fetch saat online)
- Social circles data (jika ada)
- Experiment results (bisa fetch saat online)

### **Storage Strategy:**
```kotlin
// Room Database untuk structured data
@Database(
    entities = [
        GoalEntity::class,
        ActionEntity::class,
        CheckInEntity::class,
        DomainScoreEntity::class,
        EvidenceEntity::class
    ],
    version = 1
)
abstract class UbermenschDatabase : RoomDatabase() {
    abstract fun goalDao(): GoalDao
    abstract fun actionDao(): ActionDao
    abstract fun checkInDao(): CheckInDao
    // ...
}

// File Storage untuk evidence files (images, PDFs)
// Gunakan Android's internal storage atau external storage
val evidenceDir = File(context.filesDir, "evidence")
if (!evidenceDir.exists()) {
    evidenceDir.mkdirs()
}
```

---

## 🔄 Sync Strategy Detail

### **1. Initial Sync (First Launch)**

```kotlin
suspend fun performInitialSync(userId: String) {
    try {
        // 1. Download semua data user dari backend
        val userData = api.getUserData(userId)
        
        // 2. Save ke Room DB
        withContext(Dispatchers.IO) {
            database.withTransaction {
                // Clear old data (optional)
                database.goalDao().deleteAll(userId)
                
                // Insert new data
                userData.goals.forEach { goal ->
                    database.goalDao().insertGoal(goal.toEntity())
                }
                
                userData.checkIns.forEach { checkIn ->
                    database.checkInDao().insertCheckIn(checkIn.toEntity())
                }
                
                // ... other data
            }
        }
        
        // 3. Mark sync timestamp
        preferences.edit()
            .putLong("last_sync_timestamp", System.currentTimeMillis())
            .apply()
            
    } catch (e: Exception) {
        // Handle error - app tetap bisa digunakan dengan data lokal
        Log.e("Sync", "Initial sync failed: ${e.message}")
    }
}
```

### **2. Incremental Sync (Periodic)**

```kotlin
suspend fun performIncrementalSync(userId: String) {
    val lastSyncTimestamp = preferences.getLong("last_sync_timestamp", 0)
    
    try {
        // 1. Get changes dari backend (since last sync)
        val changes = api.getChangesSince(userId, lastSyncTimestamp)
        
        // 2. Apply changes ke local DB
        changes.goals.forEach { goal ->
            database.goalDao().insertGoal(goal.toEntity())
        }
        
        // 3. Upload pending local changes
        val pendingChanges = database.syncQueueDao().getPendingChanges()
        pendingChanges.forEach { change ->
            when (change.type) {
                ChangeType.CREATE -> api.createGoal(change.data)
                ChangeType.UPDATE -> api.updateGoal(change.data)
                ChangeType.DELETE -> api.deleteGoal(change.id)
            }
            database.syncQueueDao().markAsSynced(change.id)
        }
        
        // 4. Update sync timestamp
        preferences.edit()
            .putLong("last_sync_timestamp", System.currentTimeMillis())
            .apply()
            
    } catch (e: Exception) {
        // Sync gagal, tapi app tetap bisa digunakan
        Log.e("Sync", "Incremental sync failed: ${e.message}")
    }
}
```

### **3. On-Demand Sync (User Triggered)**

```kotlin
// Pull-to-refresh di UI
fun onRefresh() {
    viewModelScope.launch {
        try {
            syncRepository.performIncrementalSync()
            // Show success message
        } catch (e: Exception) {
            // Show error message
        }
    }
}
```

---

## 🚫 Handling Offline Scenarios

### **1. App Launch (No Internet)**

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Check internet connection
        val isOnline = isNetworkAvailable()
        
        if (!isOnline) {
            // Show offline indicator
            // App tetap bisa digunakan dengan data lokal
        }
        
        // Load data dari Room DB (always works)
        viewModel.loadDataFromLocal()
    }
}
```

### **2. Create Goal (Offline)**

```kotlin
fun createGoal(goal: Goal) {
    viewModelScope.launch {
        // 1. Save ke Room DB (instant)
        val goalEntity = goal.toEntity().copy(
            id = UUID.randomUUID().toString(),
            synced = false // Mark as not synced
        )
        database.goalDao().insertGoal(goalEntity)
        
        // 2. Add to sync queue
        database.syncQueueDao().addToQueue(
            SyncQueueItem(
                id = UUID.randomUUID().toString(),
                type = ChangeType.CREATE,
                entityType = "goal",
                entityId = goalEntity.id,
                data = goalEntity.toJson(),
                createdAt = System.currentTimeMillis()
            )
        )
        
        // 3. Update UI (instant)
        _goals.value = database.goalDao().getAllGoals(userId)
        
        // 4. Try sync (if online)
        if (isNetworkAvailable()) {
            syncRepository.syncPendingChanges()
        }
    }
}
```

### **3. Update Progress (Offline)**

```kotlin
fun updateActionProgress(actionId: String, completed: Boolean) {
    viewModelScope.launch {
        // 1. Update local DB
        val completion = ActionCompletion(
            id = UUID.randomUUID().toString(),
            actionId = actionId,
            completedAt = System.currentTimeMillis(),
            synced = false
        )
        database.actionCompletionDao().insertCompletion(completion)
        
        // 2. Recalculate goal progress (local)
        val goal = database.goalDao().getGoalByActionId(actionId)
        val newProgress = calculateProgress(goal.id)
        database.goalDao().updateProgress(goal.id, newProgress)
        
        // 3. Add to sync queue
        database.syncQueueDao().addToQueue(...)
        
        // 4. Update UI
        _progress.value = newProgress
    }
}
```

---

## 🔔 User Experience (Offline Indicators)

### **1. Offline Badge**

```kotlin
@Composable
fun OfflineIndicator() {
    val isOnline = remember { mutableStateOf(true) }
    
    LaunchedEffect(Unit) {
        // Monitor network state
        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                isOnline.value = true
            }
            override fun onLost(network: Network) {
                isOnline.value = false
            }
        }
        connectivityManager.registerDefaultNetworkCallback(callback)
    }
    
    if (!isOnline.value) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color.Orange)
                .padding(8.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Default.CloudOff, "Offline")
                Spacer(Modifier.width(8.dp))
                Text("Offline - Changes will sync when online")
            }
        }
    }
}
```

### **2. Sync Status**

```kotlin
@Composable
fun SyncStatus() {
    val pendingChanges = viewModel.pendingSyncCount.collectAsState()
    
    if (pendingChanges.value > 0) {
        Text(
            text = "${pendingChanges.value} changes pending sync",
            style = MaterialTheme.typography.caption,
            color = MaterialTheme.colorScheme.primary
        )
    }
}
```

---

## ✅ Checklist: Offline-First Implementation

### **Data Layer:**
- [ ] Room Database setup dengan semua entities
- [ ] DAOs untuk semua CRUD operations
- [ ] Migration strategy untuk schema changes
- [ ] Local-first data access (semua read dari Room)

### **Sync Layer:**
- [ ] Sync queue system (pending changes)
- [ ] WorkManager untuk background sync
- [ ] Conflict resolution logic
- [ ] Incremental sync (only changes)
- [ ] Full sync (initial & periodic)

### **UI Layer:**
- [ ] Offline indicator
- [ ] Sync status indicator
- [ ] Error handling untuk sync failures
- [ ] Pull-to-refresh untuk manual sync

### **Testing:**
- [ ] Test app launch tanpa internet
- [ ] Test CRUD operations offline
- [ ] Test sync ketika kembali online
- [ ] Test conflict resolution
- [ ] Test dengan data besar (performance)

---

## 🎯 Kesimpulan

✅ **Arsitektur yang direkomendasikan SUDAH COCOK untuk offline-first:**

1. ✅ **Room Database** - Local storage yang powerful
2. ✅ **WorkManager** - Background sync yang reliable
3. ✅ **MVVM Pattern** - Separation of concerns untuk offline/online logic
4. ✅ **Repository Pattern** - Abstraction untuk data source (local vs remote)

**Aplikasi akan:**
- ✅ Bekerja penuh tanpa internet
- ✅ Sync otomatis ketika online
- ✅ Handle conflicts dengan baik
- ✅ Memberikan feedback ke user tentang sync status

**Tidak perlu perubahan arsitektur** - implementasi sesuai dokumentasi sudah cukup!

---

**Next Step**: Implement sesuai dengan contoh code di atas. Semua sudah sesuai dengan arsitektur yang direkomendasikan.

