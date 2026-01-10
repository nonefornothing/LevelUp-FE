# 🚀 Setup Guide - MVP Development

Panduan setup untuk mulai development MVP Ubermensch.

## ✅ Prerequisites

### **1. Install Development Tools**

#### **Android Development:**
- [ ] **Android Studio** (Hedgehog atau newer)
  - Download: https://developer.android.com/studio
  - Install Android SDK (API 24-34)
  - Install Android Emulator

- [ ] **JDK 17+**
  - Android Studio biasanya include JDK
  - Atau download: https://adoptium.net/

#### **Backend Development:**
- [ ] **.NET 8 SDK**
  - Download: https://dotnet.microsoft.com/download/dotnet/8.0
  - Verify: `dotnet --version` (should show 8.x.x)

- [ ] **Docker Desktop**
  - Download: https://www.docker.com/products/docker-desktop
  - Required untuk PostgreSQL, Redis, MinIO local

#### **Version Control:**
- [ ] **Git**
  - Download: https://git-scm.com/downloads

---

## 🚀 Setup Steps

### **Step 1: Clone Repository**

```bash
# Jika belum, initialize Git repository
git init
git add .
git commit -m "Initial commit: MVP setup"

# Atau jika sudah ada remote
git clone <repository-url>
cd Ubermensch
```

### **Step 2: Start Database Services (Docker)**

```bash
# Start PostgreSQL, Redis, MinIO
docker-compose up -d

# Verify services running
docker-compose ps

# Should see:
# - ubermensch-postgres (running)
# - ubermensch-redis (running)
# - ubermensch-minio (running)
```

### **Step 3: Verify Database Connection**

```bash
# Connect to PostgreSQL
docker exec -it ubermensch-postgres psql -U ubermensch_user -d ubermensch

# Should see PostgreSQL prompt
# Type: \dt (list tables)
# Type: \q (quit)
```

### **Step 4: Setup Backend Services**

#### **Create .NET Projects (jika belum ada):**

```bash
# Create solution
cd backend
dotnet new sln -n Ubermensch.Backend

# Create Auth Service
dotnet new webapi -n auth-service -f net8.0
dotnet sln add auth-service/auth-service.csproj

# Create Core Service
dotnet new webapi -n core-service -f net8.0
dotnet sln add core-service/core-service.csproj

# Create Coach Service
dotnet new webapi -n coach-service -f net8.0
dotnet sln add coach-service/coach-service.csproj
```

#### **Install Required Packages:**

```bash
# For each service, install:
cd auth-service
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Swashbuckle.AspNetCore

# Repeat for core-service and coach-service
```

#### **Configure Services:**

Edit `appsettings.Development.json` di setiap service:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=ubermensch;Username=ubermensch_user;Password=ubermensch_dev_password"
  },
  "JWT": {
    "SecretKey": "your-secret-key-min-32-characters-change-in-production",
    "Issuer": "ubermensch.app",
    "Audience": "ubermensch.app",
    "ExpirationMinutes": 15
  },
  "GoogleOAuth": {
    "ClientId": "your-google-client-id",
    "ClientSecret": "your-google-client-secret"
  }
}
```

#### **Run Services:**

```bash
# Terminal 1: Auth Service
cd backend/auth-service
dotnet run
# Should run on http://localhost:5001

# Terminal 2: Core Service
cd backend/core-service
dotnet run
# Should run on http://localhost:5002

# Terminal 3: Coach Service (optional untuk MVP)
cd backend/coach-service
dotnet run
# Should run on http://localhost:5003
```

### **Step 5: Setup Android App**

#### **Create Android Project:**

1. Open **Android Studio**
2. **File** → **New** → **New Project**
3. Select **Empty Compose Activity**
4. Configure:
   - **Name**: Ubermensch
   - **Package name**: com.ubermensch.app
   - **Language**: Kotlin
   - **Minimum SDK**: API 24 (Android 7.0)
   - **Build configuration**: Kotlin DSL

#### **Configure API Endpoint:**

Edit `app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        buildConfigField("String", "API_BASE_URL", "\"http://10.0.2.2:5002\"") // Emulator
        // Or for physical device: "\"http://192.168.1.100:5002\"" (your computer's IP)
    }
}
```

#### **Add Dependencies:**

Edit `app/build.gradle.kts`:

```kotlin
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
}
```

---

## ✅ Verification

### **Backend Health Check:**

```bash
# Test Auth Service
curl http://localhost:5001/health
# Should return: {"status":"Healthy"}

# Test Core Service
curl http://localhost:5002/health
# Should return: {"status":"Healthy"}
```

### **Database Verification:**

```bash
# List tables
docker exec -it ubermensch-postgres psql -U ubermensch_user -d ubermensch -c "\dt"

# Should show:
# - users
# - domains
# - goals
# - actions
# - daily_checkins
# - etc.
```

### **Android App:**

1. Start Android Emulator atau connect device
2. Run app dari Android Studio
3. App should launch (even if shows error, that's OK - we'll implement features)

---

## 🎯 Next Steps

### **Week 1 Tasks:**

1. **Day 1-2: Project Structure**
   - [ ] Create Android project structure (Clean Architecture)
   - [ ] Create backend project structure
   - [ ] Setup Git repository
   - [ ] Verify Docker services running

2. **Day 3-4: Database Setup**
   - [ ] Verify PostgreSQL schema created
   - [ ] Create Room entities (Android)
   - [ ] Create Entity Framework models (Backend)
   - [ ] Test database connections

3. **Day 5: Authentication Setup**
   - [ ] Setup Google OAuth (Google Cloud Console)
   - [ ] Implement login API (Backend)
   - [ ] Implement login UI (Android)
   - [ ] Test end-to-end login flow

---

## 🐛 Troubleshooting

### **Docker Issues:**

```bash
# If services not starting
docker-compose down
docker-compose up -d

# Check logs
docker-compose logs postgres
docker-compose logs redis
```

### **Database Connection Issues:**

```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Test connection
docker exec -it ubermensch-postgres psql -U ubermensch_user -d ubermensch
```

### **Android Build Issues:**

```bash
# Clean and rebuild
./gradlew clean
./gradlew build

# Invalidate caches in Android Studio
# File → Invalidate Caches / Restart
```

### **Backend Build Issues:**

```bash
# Restore packages
dotnet restore

# Clean and rebuild
dotnet clean
dotnet build
```

---

## 📚 Resources

- [Android Developer Docs](https://developer.android.com/docs)
- [.NET Documentation](https://docs.microsoft.com/dotnet/)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## ✅ Setup Complete!

Setelah semua steps selesai, development environment sudah siap. Mulai implement features sesuai roadmap di `MVP_PRE_DEVELOPMENT_CHECKLIST.md`.

**Happy Coding! 🚀**

