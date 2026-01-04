# Getting Started - Ubermensch Development Guide

## 🎯 Untuk Developer Baru

Panduan step-by-step untuk memulai development aplikasi Ubermensch.

---

## 📋 Prerequisites Checklist

### **1. Install Development Tools**

#### **Android Development:**
- [ ] **Android Studio** (Hedgehog atau newer)
  - Download: https://developer.android.com/studio
  - Install Android SDK (API 24-34)
  - Install Android Emulator

- [ ] **JDK 17+**
  - Android Studio biasanya include JDK
  - Atau download: https://adoptium.net/

- [ ] **Git**
  - Download: https://git-scm.com/downloads

#### **Backend Development:**
- [ ] **.NET 8 SDK**
  - Download: https://dotnet.microsoft.com/download/dotnet/8.0
  - Verify: `dotnet --version` (should show 8.x.x)

- [ ] **Docker Desktop**
  - Download: https://www.docker.com/products/docker-desktop
  - Required untuk PostgreSQL, Redis, MinIO local

- [ ] **PostgreSQL** (optional, bisa pakai Docker)
  - Download: https://www.postgresql.org/download/
  - Atau pakai Docker: `docker run -d -p 5432:5432 postgres:15`

- [ ] **Redis** (optional, bisa pakai Docker)
  - Download: https://redis.io/download
  - Atau pakai Docker: `docker run -d -p 6379:6379 redis:7`

#### **Editor/IDE:**
- [ ] **Android Studio** (untuk Android)
- [ ] **Visual Studio Code** atau **Visual Studio 2022** (untuk backend)
  - VS Code extensions:
    - C# Dev Kit
    - Docker
    - REST Client

---

## 🚀 Setup Project

### **Step 1: Clone Repository**

```bash
# Clone repository
git clone <repository-url>
cd ubermensch-android

# Verify structure
ls -la
# Should see: app/, backend/, docs/, etc.
```

### **Step 2: Setup Backend (Local Development)**

#### **Option A: Docker Compose (Recommended)**

```bash
cd backend

# Copy environment file
cp .env.example .env

# Edit .env dengan credentials lokal
# DB_PASSWORD=your_password
# REDIS_PASSWORD=your_redis_password
# JWT_SECRET_KEY=your_jwt_secret

# Start services (PostgreSQL, Redis, MinIO)
docker-compose up -d

# Verify services running
docker-compose ps
# Should see: postgres, redis, minio running
```

#### **Option B: Manual Setup**

```bash
# Start PostgreSQL
docker run -d \
  --name ubermensch-postgres \
  -e POSTGRES_DB=ubermensch \
  -e POSTGRES_USER=ubermensch_user \
  -e POSTGRES_PASSWORD=your_password \
  -p 5432:5432 \
  postgres:15-alpine

# Start Redis
docker run -d \
  --name ubermensch-redis \
  -p 6379:6379 \
  redis:7-alpine

# Start MinIO
docker run -d \
  --name ubermensch-minio \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  -p 9000:9000 \
  -p 9001:9001 \
  minio/minio server /data --console-address ":9001"
```

#### **Run Backend Services**

```bash
# Auth Service
cd backend/auth-service
dotnet restore
dotnet run
# Should run on http://localhost:5001

# Core Service (new terminal)
cd backend/core-service
dotnet restore
dotnet run
# Should run on http://localhost:5002

# Coach Service (new terminal)
cd backend/coach-service
dotnet restore
dotnet run
# Should run on http://localhost:5003
```

### **Step 3: Setup Android App**

```bash
cd app

# Open in Android Studio
# File → Open → Select "app" folder

# Wait for Gradle sync (first time might take 5-10 minutes)

# Verify build
# Build → Make Project (Ctrl+F9)
```

#### **Configure API Endpoint**

Edit `app/src/main/java/com/ubermensch/app/BuildConfig.kt` atau `build.gradle.kts`:

**Untuk Android Emulator:**
```kotlin
buildConfigField("String", "API_BASE_URL", "\"http://10.0.2.2:5002\"")
```

**Untuk Physical Device:**
```kotlin
// Ganti dengan IP komputer kamu di local network
buildConfigField("String", "API_BASE_URL", "\"http://192.168.1.100:5002\"")
```

#### **Run App**

1. Connect device atau start emulator
2. Click "Run" button (green play icon)
3. App should install and launch

---

## 🧪 Verify Setup

### **Backend Health Check**

```bash
# Test Auth Service
curl http://localhost:5001/health
# Should return: {"status":"Healthy"}

# Test Core Service
curl http://localhost:5002/health
# Should return: {"status":"Healthy"}

# Test Coach Service
curl http://localhost:5003/health
# Should return: {"status":"Healthy"}
```

### **Database Connection**

```bash
# Connect to PostgreSQL
docker exec -it ubermensch-postgres psql -U ubermensch_user -d ubermensch

# Should see PostgreSQL prompt
# Type: \dt (list tables)
# Type: \q (quit)
```

### **Android App**

1. Launch app
2. Should see login screen
3. Try login dengan Google OAuth (butuh setup Firebase dulu)

---

## 🔧 Development Workflow

### **Daily Workflow**

1. **Pull latest changes**
   ```bash
   git pull origin main
   ```

2. **Start backend services**
   ```bash
   cd backend
   docker-compose up -d
   cd core-service && dotnet run
   ```

3. **Open Android Studio**
   - Open project
   - Wait for Gradle sync
   - Run app

4. **Make changes**
   - Create feature branch: `git checkout -b feature/my-feature`
   - Make changes
   - Test locally
   - Commit: `git commit -m "feat: add my feature"`
   - Push: `git push origin feature/my-feature`

### **Running Tests**

#### **Android Tests:**
```bash
# Unit tests
./gradlew test

# Instrumented tests (need device/emulator)
./gradlew connectedAndroidTest
```

#### **Backend Tests:**
```bash
cd backend/core-service
dotnet test
```

---

## 📱 Common Development Tasks

### **Add New Feature**

1. **Create feature module** (if needed)
   ```
   feature/my-feature/
   ├── presentation/
   ├── domain/
   └── data/
   ```

2. **Add to navigation**
   - Edit `app/src/main/java/.../navigation/NavGraph.kt`

3. **Create screen**
   - Create Composable in `presentation/screens/`

4. **Create ViewModel**
   - Create ViewModel in `presentation/viewmodel/`

5. **Create UseCase**
   - Create UseCase in `domain/usecase/`

6. **Create Repository**
   - Create Repository interface in `domain/repository/`
   - Create implementation in `data/repository/`

### **Add New API Endpoint**

1. **Define endpoint** in backend
   ```csharp
   [HttpGet("goals")]
   public async Task<IActionResult> GetGoals() { ... }
   ```

2. **Create API interface** in Android
   ```kotlin
   interface GoalApi {
       @GET("goals")
       suspend fun getGoals(): Response<List<GoalDto>>
   }
   ```

3. **Update Repository** implementation
   ```kotlin
   override suspend fun getGoals(): Result<List<Goal>> {
       return try {
           val response = api.getGoals()
           if (response.isSuccessful) {
               Result.Success(response.body()?.map { it.toDomain() } ?: emptyList())
           } else {
               Result.Error(Exception("API Error"))
           }
       } catch (e: Exception) {
           Result.Error(e)
       }
   }
   ```

### **Add Database Table**

1. **Create Entity** (Room)
   ```kotlin
   @Entity(tableName = "my_table")
   data class MyEntity(
       @PrimaryKey val id: String,
       val name: String
   )
   ```

2. **Create DAO**
   ```kotlin
   @Dao
   interface MyDao {
       @Query("SELECT * FROM my_table")
       suspend fun getAll(): List<MyEntity>
   }
   ```

3. **Update Database**
   ```kotlin
   @Database(entities = [MyEntity::class], version = 2)
   abstract class UbermenschDatabase : RoomDatabase() {
       abstract fun myDao(): MyDao
   }
   ```

4. **Create Migration** (if needed)
   ```kotlin
   val MIGRATION_1_2 = object : Migration(1, 2) {
       override fun migrate(database: SupportSQLiteDatabase) {
           database.execSQL("CREATE TABLE my_table ...")
       }
   }
   ```

---

## 🐛 Troubleshooting

### **Android Studio Issues**

**Problem: Gradle sync failed**
```bash
# Solution:
# 1. Invalidate caches: File → Invalidate Caches / Restart
# 2. Delete .gradle folder: rm -rf .gradle
# 3. Re-sync
```

**Problem: Build failed**
```bash
# Solution:
# 1. Clean project: Build → Clean Project
# 2. Rebuild: Build → Rebuild Project
```

**Problem: Emulator not starting**
```bash
# Solution:
# 1. Check Android SDK installed
# 2. Create new AVD: Tools → Device Manager → Create Device
# 3. Use x86_64 image (faster)
```

### **Backend Issues**

**Problem: Cannot connect to database**
```bash
# Solution:
# 1. Check Docker containers running: docker ps
# 2. Check connection string in appsettings.json
# 3. Test connection: docker exec -it postgres psql -U ubermensch_user -d ubermensch
```

**Problem: Port already in use**
```bash
# Solution:
# 1. Find process: netstat -ano | findstr :5002 (Windows)
# 2. Kill process: taskkill /PID <pid> /F (Windows)
#    atau: lsof -ti:5002 | xargs kill (Mac/Linux)
```

**Problem: Migration failed**
```bash
# Solution:
# 1. Check migration files
# 2. Rollback: dotnet ef database update <previous_version>
# 3. Fix migration and re-run
```

### **Network Issues**

**Problem: Android app cannot connect to backend**
```bash
# Solution:
# 1. Check API_BASE_URL in build.gradle.kts
# 2. For emulator: use 10.0.2.2 (not localhost)
# 3. For physical device: use computer's local IP
# 4. Check firewall allows connection
```

---

## 📚 Learning Resources

### **Android Development:**
- [Android Developer Documentation](https://developer.android.com/docs)
- [Jetpack Compose Tutorial](https://developer.android.com/jetpack/compose/tutorial)
- [Room Database Guide](https://developer.android.com/training/data-storage/room)
- [Kotlin Coroutines Guide](https://kotlinlang.org/docs/coroutines-guide.html)

### **Backend Development:**
- [ASP.NET Core Documentation](https://docs.microsoft.com/en-us/aspnet/core/)
- [Entity Framework Core](https://docs.microsoft.com/en-us/ef/core/)
- [.NET Microservices](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/)

### **Architecture:**
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [MVVM Pattern](https://developer.android.com/topic/architecture)
- [Repository Pattern](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design)

---

## ✅ Next Steps

Setelah setup selesai:

1. **Baca dokumentasi lengkap:**
   - [ARCHITECTURE.md](./ARCHITECTURE.md)
   - [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)
   - [ALGORITHMS.md](./ALGORITHMS.md)

2. **Explore codebase:**
   - Start dengan `MainActivity.kt`
   - Check `DashboardScreen.kt`
   - Understand data flow

3. **Pick first task:**
   - Start dengan bug fix atau small feature
   - Get familiar dengan codebase
   - Ask questions!

4. **Setup CI/CD** (optional):
   - GitHub Actions untuk automated tests
   - Automated deployment ke staging

---

**Happy Coding! 🚀**

