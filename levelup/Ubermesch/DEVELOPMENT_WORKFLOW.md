# 🔄 Development Workflow - Local Development & Google Play Testing

## 📋 Overview

Panduan lengkap untuk development workflow: dari local development hingga upload ke Google Play untuk testing.

---

## 🏠 Part 1: Local Development Workflow

### **Daily Development Flow**

```
┌─────────────────────────────────────────────────────────┐
│                   LOCAL DEVELOPMENT                      │
│                                                          │
│  1. Start Services (Docker)                             │
│  2. Run Backend Services                                │
│  3. Run Android App (Emulator/Device)                   │
│  4. Develop & Test                                       │
│  5. Commit & Push                                        │
└─────────────────────────────────────────────────────────┘
```

---

### **Step 1: Morning Setup (Setiap Hari)**

#### **Start Database Services**

```bash
# Navigate ke project root
cd D:\Ubermesch\Ubermesch

# Start Docker services
docker-compose up -d

# Verify services running
docker-compose ps

# Should see:
# - ubermensch-postgres (running on port 5432)
# - ubermensch-redis (running on port 6379)
# - ubermensch-minio (running on port 9000, 9001)
```

#### **Verify Database**

```bash
# Test PostgreSQL connection
docker exec -it ubermensch-postgres psql -U ubermensch_user -d ubermensch

# List tables
\dt

# Exit
\q
```

#### **Start Backend Services**

**Terminal 1: Auth Service**
```bash
cd backend/auth-service
dotnet run
# Should run on http://localhost:5001
# Swagger: http://localhost:5001/swagger
```

**Terminal 2: Core Service**
```bash
cd backend/core-service
dotnet run
# Should run on http://localhost:5002
# Swagger: http://localhost:5002/swagger
```

**Terminal 3: Coach Service (Optional untuk MVP)**
```bash
cd backend/coach-service
dotnet run
# Should run on http://localhost:5003
```

#### **Start Android App**

1. Open Android Studio
2. Open project: `D:\Ubermesch\Ubermesch\app`
3. Wait for Gradle sync
4. Select device/emulator
5. Click **Run** (green play button)
6. App should launch

---

### **Step 2: Development Process**

#### **Backend Development**

**Workflow:**
1. Create/Edit controller/service
2. Test dengan Swagger UI: `http://localhost:5002/swagger`
3. Test dengan Postman (optional)
4. Write unit tests
5. Commit changes

**Example: Create Goal Endpoint**

```csharp
// 1. Create Controller
[ApiController]
[Route("api/v1/goals")]
public class GoalController : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> CreateGoal([FromBody] CreateGoalDto dto)
    {
        // Implementation
    }
}

// 2. Test di Swagger
// http://localhost:5002/swagger
// POST /api/v1/goals
// Body: { "title": "Test Goal", ... }

// 3. Verify di database
docker exec -it ubermensch-postgres psql -U ubermensch_user -d ubermensch
SELECT * FROM goals;
```

#### **Android Development**

**Workflow:**
1. Create/Edit screen/viewmodel
2. Run app di emulator/device
3. Test feature
4. Test offline mode (turn off WiFi)
5. Test sync (turn on WiFi)
6. Commit changes

**Example: Create Goal Screen**

```kotlin
// 1. Create Screen
@Composable
fun GoalBuilderScreen(viewModel: GoalBuilderViewModel) {
    // UI implementation
}

// 2. Run app
// Click Run button in Android Studio

// 3. Test:
// - Create goal
// - Turn off WiFi
// - Create another goal (offline)
// - Turn on WiFi
// - Verify sync
```

---

### **Step 3: Testing Workflow**

#### **Backend Testing**

```bash
# Run all tests
cd backend
dotnet test

# Run specific project tests
cd core-service
dotnet test

# Run with coverage (optional)
dotnet test /p:CollectCoverage=true
```

#### **Android Testing**

```bash
# Run unit tests
./gradlew test

# Run instrumented tests (need device/emulator)
./gradlew connectedAndroidTest

# Run specific test
./gradlew test --tests "com.ubermensch.app.GoalViewModelTest"
```

#### **Manual Testing Checklist**

**Backend:**
- [ ] All endpoints work di Swagger
- [ ] Authentication works
- [ ] Authorization works (user hanya akses data sendiri)
- [ ] Error handling works
- [ ] Validation works

**Android:**
- [ ] All screens work
- [ ] Navigation works
- [ ] Offline mode works
- [ ] Sync works
- [ ] No crashes
- [ ] Performance acceptable

---

### **Step 4: Git Workflow**

#### **Branch Strategy**

```
main (production-ready code)
  └── develop (integration branch)
      ├── feature/goal-crud
      ├── feature/check-in
      └── feature/sync
```

#### **Daily Git Workflow**

```bash
# 1. Start new feature
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# 2. Develop & commit
git add .
git commit -m "feat: add goal creation screen"

# 3. Push to remote
git push origin feature/my-feature

# 4. Create Pull Request (optional, atau merge langsung ke develop)
git checkout develop
git merge feature/my-feature
git push origin develop
```

#### **Commit Message Convention**

```
feat: add goal creation screen
fix: resolve sync conflict issue
refactor: optimize database queries
test: add unit tests for GoalViewModel
docs: update API documentation
```

---

### **Step 5: End of Day**

#### **Stop Services**

```bash
# Stop backend services (Ctrl+C di terminal)

# Stop Docker services (optional, bisa tetap running)
docker-compose stop

# Or keep running untuk next day
```

#### **Commit & Push**

```bash
# Commit all changes
git add .
git commit -m "feat: implement goal CRUD"

# Push to remote
git push origin feature/my-feature
```

---

## 📱 Part 2: Google Play Testing Workflow

### **Testing Tracks Overview**

```
┌─────────────────────────────────────────────────────────┐
│              GOOGLE PLAY TESTING TRACKS                  │
│                                                          │
│  Internal Testing (Fast, no review)                      │
│      ↓                                                   │
│  Closed Testing / Beta (Optional)                        │
│      ↓                                                   │
│  Production (Public release)                            │
└─────────────────────────────────────────────────────────┘
```

---

### **Phase 1: Internal Testing (Recommended untuk Development)**

#### **Setup Internal Testing**

**Step 1: Create Google Play Developer Account**
1. Go to: https://play.google.com/console
2. Pay $25 one-time fee
3. Complete account setup

**Step 2: Create App**
1. Click **Create app**
2. Fill details:
   - App name: Ubermensch
   - Default language: Indonesian
   - App or game: App
   - Free or paid: Free

**Step 3: Build Release AAB**

```bash
# 1. Generate release keystore (first time only)
keytool -genkey -v -keystore app/keystore/ubermensch-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ubermensch

# 2. Configure signing di build.gradle.kts
# (See GOOGLE_PLAY_DEPLOYMENT.md for details)

# 3. Build release AAB
cd app
./gradlew bundleRelease

# Output: app/build/outputs/bundle/release/app-release.aab
```

**Step 4: Test AAB Locally (Optional)**

```bash
# Install bundletool
# Download: https://github.com/google/bundletool/releases

# Generate APKs dari AAB
bundletool build-apks \
  --bundle=app/build/outputs/bundle/release/app-release.aab \
  --output=app.apks \
  --ks=app/keystore/ubermensch-release.jks \
  --ks-pass=pass:your_password \
  --ks-key-alias=ubermensch \
  --key-pass=pass:your_password

# Install ke device
bundletool install-apks --apks=app.apks
```

**Step 5: Upload ke Internal Testing**

1. Go to Google Play Console
2. Navigate to **Testing** → **Internal testing**
3. Click **Create new release**
4. Upload AAB file: `app-release.aab`
5. Fill release notes:
   ```
   Internal testing build
   - Goal CRUD working
   - Check-in feature added
   - Offline mode working
   ```
6. Click **Save**
7. Click **Review release**
8. Click **Start rollout to Internal testing**

**Step 6: Add Testers**

1. Go to **Testers** tab
2. Click **Create email list**
3. Add tester emails (max 100)
4. Save list
5. Share link dengan testers:
   ```
   https://play.google.com/apps/internaltest/...
   ```

**Step 7: Testers Download App**

1. Testers click link
2. Accept invitation
3. Download app dari Play Store
4. Test app
5. Provide feedback

**Step 8: Monitor & Iterate**

- Monitor crash reports di Play Console
- Collect feedback dari testers
- Fix bugs
- Build new AAB
- Upload new release
- Repeat

---

### **Phase 2: Closed Beta Testing (Optional)**

#### **When to Use:**
- After Internal Testing successful
- Want larger testing group (100-1000 users)
- Before public release

#### **Setup Closed Beta:**

1. Go to **Testing** → **Closed testing**
2. Create new track: **Beta**
3. Upload AAB (same process as Internal Testing)
4. Add testers atau create opt-in link
5. Share link publicly (optional)
6. Monitor feedback

---

### **Phase 3: Production Release**

#### **Pre-Launch Checklist:**

- [ ] All MVP features working
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Store listing complete:
  - [ ] App icon (512x512)
  - [ ] Feature graphic (1024x500)
  - [ ] Screenshots (min 2)
  - [ ] Short description (80 chars)
  - [ ] Full description (4000 chars)
- [ ] Privacy policy published
- [ ] Content rating completed

#### **Launch Process:**

1. **Build Final AAB:**
   ```bash
   ./gradlew bundleRelease
   ```

2. **Upload to Production:**
   - Go to **Production** track
   - Click **Create new release**
   - Upload AAB
   - Fill release notes
   - Click **Review release**

3. **Staged Rollout (Recommended):**
   - Enable **Staged rollout**
   - Start with **5%** of users
   - Monitor for 24 hours
   - If stable, increase to **20%**
   - Then **50%**
   - Finally **100%**

4. **Monitor:**
   - Crash reports (target: < 0.1%)
   - User reviews
   - Performance metrics
   - Install/uninstall rates

---

## 🔄 Complete Development Cycle

### **Weekly Cycle:**

```
Monday:
  - Start services
  - Pull latest code
  - Start new features

Tuesday-Thursday:
  - Develop features
  - Test locally
  - Commit changes

Friday:
  - Complete features
  - Write tests
  - Code review
  - Build AAB
  - Upload to Internal Testing
  - Share dengan team untuk testing weekend
```

### **Feature Development Cycle:**

```
1. Create feature branch
2. Develop feature (backend + Android)
3. Test locally
4. Write tests
5. Code review
6. Merge to develop
7. Build AAB
8. Upload to Internal Testing
9. Test dengan real devices
10. Fix bugs if any
11. Merge to main (if stable)
```

---

## 🐛 Debugging Workflow

### **Backend Debugging:**

```bash
# 1. Check logs
# Backend services log to console

# 2. Check database
docker exec -it ubermensch-postgres psql -U ubermensch_user -d ubermensch
SELECT * FROM goals WHERE user_id = '...';

# 3. Test API dengan Postman
# Import collection
# Test endpoints

# 4. Use Swagger UI
# http://localhost:5002/swagger
```

### **Android Debugging:**

```bash
# 1. Check Logcat
# Android Studio → Logcat tab
# Filter by package: com.ubermensch.app

# 2. Use breakpoints
# Set breakpoint
# Debug mode (bug icon)
# Step through code

# 3. Check Room database
# Use Database Inspector (Android Studio)
# View → Tool Windows → App Inspection → Database Inspector

# 4. Check sync queue
# Query sync_queue table
```

---

## 📊 Monitoring & Metrics

### **Local Development:**

- **Backend**: Console logs, Swagger UI
- **Android**: Logcat, Database Inspector
- **Database**: Direct queries

### **Google Play Testing:**

- **Crash Reports**: Play Console → Quality → Crashes & ANRs
- **User Reviews**: Play Console → User feedback
- **Analytics**: Firebase Analytics (optional)
- **Performance**: Play Console → Quality → Performance

---

## ✅ Best Practices

### **Development:**

1. **Always test offline mode** sebelum commit
2. **Test sync** setelah setiap feature
3. **Write tests** untuk critical paths
4. **Commit frequently** dengan clear messages
5. **Code review** sebelum merge

### **Testing:**

1. **Test di real devices** (not just emulator)
2. **Test dengan poor network** (simulate 3G)
3. **Test edge cases** (empty data, large data)
4. **Test error scenarios** (network errors, API errors)

### **Deployment:**

1. **Always test AAB locally** sebelum upload
2. **Use Internal Testing** untuk quick iteration
3. **Staged rollout** untuk production
4. **Monitor closely** after release

---

## 🎯 Quick Reference Commands

### **Daily Setup:**
```bash
# Start services
docker-compose up -d
cd backend/core-service && dotnet run &
cd backend/auth-service && dotnet run &

# Run Android app
# Android Studio → Run
```

### **Build & Deploy:**
```bash
# Build AAB
cd app
./gradlew bundleRelease

# Upload to Play Console
# Manual upload via web interface
```

### **Testing:**
```bash
# Backend tests
cd backend && dotnet test

# Android tests
./gradlew test
./gradlew connectedAndroidTest
```

---

**Last Updated**: 2024  
**Status**: Ready to Use! 🚀

