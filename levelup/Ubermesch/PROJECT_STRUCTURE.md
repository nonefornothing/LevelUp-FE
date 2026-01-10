# Struktur Project Android - Ubermensch App

## 📁 Project Structure (Clean Architecture)

```
ubermensch-android/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/ubermensch/app/
│   │   │   │   ├── MainActivity.kt
│   │   │   │   └── UbermenschApplication.kt
│   │   │   ├── res/
│   │   │   │   ├── values/
│   │   │   │   │   ├── strings.xml
│   │   │   │   │   ├── colors.xml
│   │   │   │   │   └── themes.xml
│   │   │   │   └── drawable/
│   │   │   └── AndroidManifest.xml
│   │   └── test/                    # Unit tests
│   │   └── androidTest/             # Instrumented tests
│   ├── build.gradle.kts
│   └── proguard-rules.pro
│
├── core/
│   ├── common/                      # Shared utilities
│   │   ├── src/main/java/com/ubermensch/core/common/
│   │   │   ├── Result.kt           # Sealed class for API results
│   │   │   ├── NetworkException.kt
│   │   │   ├── DateUtils.kt
│   │   │   └── Extensions.kt
│   │   └── build.gradle.kts
│   │
│   ├── database/                    # Room database module
│   │   ├── src/main/java/com/ubermensch/core/database/
│   │   │   ├── UbermenschDatabase.kt
│   │   │   ├── dao/
│   │   │   │   ├── GoalDao.kt
│   │   │   │   ├── ActionDao.kt
│   │   │   │   ├── CheckInDao.kt
│   │   │   │   └── DomainScoreDao.kt
│   │   │   └── entities/
│   │   │       ├── GoalEntity.kt
│   │   │       ├── ActionEntity.kt
│   │   │       ├── CheckInEntity.kt
│   │   │       └── DomainScoreEntity.kt
│   │   └── build.gradle.kts
│   │
│   ├── network/                     # Network module
│   │   ├── src/main/java/com/ubermensch/core/network/
│   │   │   ├── ApiService.kt
│   │   │   ├── NetworkModule.kt    # DI module
│   │   │   └── interceptors/
│   │   │       ├── AuthInterceptor.kt
│   │   │       └── LoggingInterceptor.kt
│   │   └── build.gradle.kts
│   │
│   └── di/                          # Dependency Injection
│       ├── src/main/java/com/ubermensch/core/di/
│       │   └── AppModule.kt
│       └── build.gradle.kts
│
├── feature/
│   ├── auth/                        # Authentication feature
│   │   ├── src/main/java/com/ubermensch/feature/auth/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── LoginScreen.kt
│   │   │   │   │   └── OnboardingScreen.kt
│   │   │   │   ├── viewmodel/
│   │   │   │   │   └── AuthViewModel.kt
│   │   │   │   └── components/
│   │   │   ├── domain/
│   │   │   │   ├── usecase/
│   │   │   │   │   ├── LoginUseCase.kt
│   │   │   │   │   └── LogoutUseCase.kt
│   │   │   │   └── repository/
│   │   │   │       └── AuthRepository.kt
│   │   │   └── data/
│   │   │       ├── repository/
│   │   │       │   └── AuthRepositoryImpl.kt
│   │   │       └── remote/
│   │   │           └── AuthApi.kt
│   │   └── build.gradle.kts
│   │
│   ├── dashboard/                   # Home dashboard
│   │   ├── src/main/java/com/ubermensch/feature/dashboard/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── DashboardScreen.kt
│   │   │   │   ├── viewmodel/
│   │   │   │   │   └── DashboardViewModel.kt
│   │   │   │   └── components/
│   │   │   │       ├── DomainCard.kt
│   │   │   │       ├── NextBestActionCard.kt
│   │   │   │       └── GoalProgressCard.kt
│   │   │   ├── domain/
│   │   │   │   ├── usecase/
│   │   │   │   │   ├── GetDomainScoresUseCase.kt
│   │   │   │   │   ├── GetNextBestActionUseCase.kt
│   │   │   │   │   └── GetActiveGoalsUseCase.kt
│   │   │   │   └── repository/
│   │   │   └── data/
│   │   └── build.gradle.kts
│   │
│   ├── goals/                       # Goals/Quests feature
│   │   ├── src/main/java/com/ubermensch/feature/goals/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── GoalsListScreen.kt
│   │   │   │   │   ├── GoalDetailScreen.kt
│   │   │   │   │   └── GoalBuilderScreen.kt
│   │   │   │   ├── viewmodel/
│   │   │   │   │   ├── GoalsViewModel.kt
│   │   │   │   │   └── GoalBuilderViewModel.kt
│   │   │   │   └── components/
│   │   │   ├── domain/
│   │   │   │   ├── usecase/
│   │   │   │   │   ├── CreateGoalUseCase.kt
│   │   │   │   │   ├── UpdateGoalUseCase.kt
│   │   │   │   │   └── CalculateProgressUseCase.kt
│   │   │   │   └── repository/
│   │   │   └── data/
│   │   └── build.gradle.kts
│   │
│   ├── checkin/                     # Daily check-in
│   │   ├── src/main/java/com/ubermensch/feature/checkin/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── CheckInScreen.kt
│   │   │   │   └── viewmodel/
│   │   │   │       └── CheckInViewModel.kt
│   │   │   └── domain/
│   │   └── build.gradle.kts
│   │
│   ├── today/                       # Today screen
│   │   ├── src/main/java/com/ubermensch/feature/today/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── TodayScreen.kt
│   │   │   │   └── viewmodel/
│   │   │   │       └── TodayViewModel.kt
│   │   │   └── domain/
│   │   └── build.gradle.kts
│   │
│   ├── review/                      # Weekly review
│   │   ├── src/main/java/com/ubermensch/feature/review/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── WeeklyReviewScreen.kt
│   │   │   │   └── viewmodel/
│   │   │   │       └── ReviewViewModel.kt
│   │   │   └── domain/
│   │   └── build.gradle.kts
│   │
│   └── insights/                    # Analytics & insights
│       ├── src/main/java/com/ubermensch/feature/insights/
│       │   ├── presentation/
│       │   │   ├── screens/
│       │   │   │   └── InsightsScreen.kt
│       │   │   └── viewmodel/
│       │   │       └── InsightsViewModel.kt
│       │   └── domain/
│       └── build.gradle.kts
│
├── sync/                            # Sync engine module
│   ├── src/main/java/com/ubermensch/sync/
│   │   ├── SyncManager.kt
│   │   ├── ConflictResolver.kt
│   │   └── workers/
│   │       ├── SyncWorker.kt
│   │       └── PeriodicSyncWorker.kt
│   └── build.gradle.kts
│
├── build.gradle.kts                 # Root build file
├── settings.gradle.kts
├── gradle.properties
└── README.md
```

## 📦 Module Dependencies

### **app module** depends on:
- All feature modules
- core:common
- core:database
- core:network
- core:di
- sync

### **feature modules** depend on:
- core:common
- core:database (for local data)
- core:network (for remote data)

### **core modules** are independent (no feature dependencies)

---

## 🎨 UI Component Structure (Compose)

```
presentation/
├── screens/                         # Full screen composables
│   └── DashboardScreen.kt
│
├── components/                      # Reusable UI components
│   ├── cards/
│   │   ├── DomainCard.kt
│   │   ├── GoalCard.kt
│   │   └── NextBestActionCard.kt
│   ├── inputs/
│   │   ├── EnergySlider.kt
│   │   ├── FocusSlider.kt
│   │   └── MoodSelector.kt
│   ├── progress/
│   │   ├── ProgressBar.kt
│   │   └── DomainScoreRing.kt
│   └── common/
│       ├── LoadingIndicator.kt
│       └── ErrorMessage.kt
│
├── theme/                           # Design system
│   ├── Color.kt
│   ├── Typography.kt
│   ├── Shape.kt
│   └── Theme.kt
│
└── navigation/                      # Navigation setup
    ├── NavGraph.kt
    └── Destinations.kt
```

---

## 🔄 Data Flow (MVVM Pattern)

```
UI (Compose)
    │
    ├─ User Action
    │
    ▼
ViewModel
    │
    ├─ UseCase (Business Logic)
    │
    ▼
Repository (Interface)
    │
    ├─ Local Repository (Room)
    │   └─ Immediate UI Update
    │
    └─ Remote Repository (API)
        └─ Sync in Background
```

---

## 📱 Screen Flow (Navigation)

```
Splash Screen
    │
    ├─ Not Logged In → Onboarding → Login (Google)
    │
    └─ Logged In → Dashboard
                    │
                    ├─ Today Tab
                    │   └─ Check-in → Action List
                    │
                    ├─ Goals Tab
                    │   ├─ Goals List
                    │   ├─ Goal Detail
                    │   └─ Goal Builder
                    │
                    ├─ Review Tab
                    │   └─ Weekly Review
                    │
                    └─ Insights Tab
                        └─ Analytics & Trends
```

---

## 🗄️ Database Schema (Room Entities)

### **GoalEntity**
```kotlin
@Entity(tableName = "goals")
data class GoalEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val domainId: String,
    val title: String,
    val description: String?,
    val why: String?,
    val outcomeMetric: String, // JSON string
    val deadline: Long?, // timestamp
    val status: String, // active, paused, completed
    val progressPercentage: Float,
    val createdAt: Long,
    val updatedAt: Long,
    val syncedAt: Long? // for sync tracking
)
```

### **ActionEntity**
```kotlin
@Entity(tableName = "actions")
data class ActionEntity(
    @PrimaryKey val id: String,
    val goalId: String,
    val title: String,
    val description: String?,
    val actionType: String, // habit, task, deep_work
    val frequency: String, // JSON string
    val estimatedMinutes: Int,
    val createdAt: Long
)
```

### **CheckInEntity**
```kotlin
@Entity(tableName = "checkins")
data class CheckInEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val checkinDate: Long, // timestamp (start of day)
    val energy: Int, // 1-5
    val focus: Int, // 1-5
    val mood: Int, // 1-5
    val mostImportantThing: String?,
    val moveDone: Boolean,
    val createDone: Boolean,
    val connectDone: Boolean,
    val createdAt: Long,
    val syncedAt: Long?
)
```

### **DomainScoreEntity**
```kotlin
@Entity(tableName = "domain_scores")
data class DomainScoreEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val domainId: String,
    val score: Float, // 0-100
    val leadingIndicators: String, // JSON string
    val laggingIndicators: String, // JSON string
    val calculatedAt: Long
)
```

---

## 🔐 Security Implementation

### **Encrypted Storage**
```kotlin
// For sensitive data (tokens, etc.)
val encryptedPrefs = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build(),
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)
```

### **Certificate Pinning**
```kotlin
// In NetworkModule.kt
val certificatePinner = CertificatePinner.Builder()
    .add("api.ubermensch.app", "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
    .build()

val okHttpClient = OkHttpClient.Builder()
    .certificatePinner(certificatePinner)
    .build()
```

---

## 🧪 Testing Structure

```
test/                                # Unit tests
├── domain/
│   └── usecase/
│       └── GetNextBestActionUseCaseTest.kt
└── data/
    └── repository/
        └── GoalRepositoryImplTest.kt

androidTest/                         # Instrumented tests
├── database/
│   └── GoalDaoTest.kt
└── ui/
    └── DashboardScreenTest.kt
```

---

## 📊 Build Configuration

### **build.gradle.kts (app module)**
```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("kotlin-kapt")
    id("dagger.hilt.android.plugin")
    id("kotlin-parcelize")
}

android {
    namespace = "com.ubermensch.app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.ubermensch.app"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.3"
    }
}

dependencies {
    // Core Android
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    
    // Compose
    implementation(platform("androidx.compose:compose-bom:2023.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.navigation:navigation-compose:2.7.5")
    
    // Room
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")
    
    // Hilt
    implementation("com.google.dagger:hilt-android:2.48")
    kapt("com.google.dagger:hilt-compiler:2.48")
    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")
    
    // Networking
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    
    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    
    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.0")
    
    // DataStore
    implementation("androidx.datastore:datastore-preferences:1.0.0")
    
    // Security
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    
    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
}
```

---

## 🚀 Next Steps

1. **Initialize Project**
   ```bash
   # Create new Android project in Android Studio
   # Select "Empty Compose Activity"
   # Configure modules as above
   ```

2. **Setup Dependencies**
   - Add all dependencies to `build.gradle.kts`
   - Sync project

3. **Create Module Structure**
   - Create feature modules
   - Setup navigation
   - Implement first screen (Login)

4. **Setup Database**
   - Create Room entities
   - Create DAOs
   - Create database class

5. **Implement Sync**
   - Setup WorkManager
   - Implement sync logic
   - Test offline-first flow

