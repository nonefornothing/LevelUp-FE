# 📋 MVP TODO List - Ubermensch App

## 🎯 Overview

TODO list lengkap untuk development MVP dalam **10 minggu** dengan **2 developers**.

**Timeline**: 10 weeks (2.5 months)  
**Team**: 2 developers (1 Android, 1 Backend)  
**Approach**: Backend-first, kemudian mobile app

---

## 📅 Week-by-Week Breakdown

---

## **WEEK 1: Project Setup & Foundation**

### **Day 1-2: Environment Setup**

#### **Developer 1 (Backend)**
- [ ] Install .NET 8 SDK
- [ ] Install Docker Desktop
- [ ] Verify Docker installation: `docker --version`
- [ ] Clone/create repository
- [ ] Start Docker services: `docker-compose up -d`
- [ ] Verify PostgreSQL running: `docker ps | grep postgres`
- [ ] Test database connection
- [ ] Create .NET solution: `dotnet new sln -n Ubermensch.Backend`
- [ ] Create Auth Service project: `dotnet new webapi -n auth-service`
- [ ] Create Core Service project: `dotnet new webapi -n core-service`
- [ ] Add projects to solution
- [ ] Install NuGet packages (Entity Framework, PostgreSQL, JWT, Swagger)
- [ ] Configure `appsettings.Development.json` untuk setiap service
- [ ] Test service bisa run: `dotnet run`

#### **Developer 2 (Android)**
- [ ] Install Android Studio (Hedgehog atau newer)
- [ ] Install Android SDK (API 24-34)
- [ ] Setup Android Emulator
- [ ] Clone/create repository
- [ ] Create Android project di Android Studio
  - [ ] Project name: Ubermensch
  - [ ] Package: com.ubermensch.app
  - [ ] Language: Kotlin
  - [ ] Minimum SDK: API 24
  - [ ] Template: Empty Compose Activity
- [ ] Configure `build.gradle.kts` dengan dependencies
- [ ] Sync Gradle
- [ ] Test app bisa run di emulator

#### **Both Developers**
- [ ] Setup Git repository
- [ ] Create `.gitignore` (sudah ada)
- [ ] Initial commit: "Initial project setup"
- [ ] Create development branch: `git checkout -b develop`

---

### **Day 3-4: Database Schema & Models**

#### **Developer 1 (Backend)**
- [ ] Review database schema (`backend/scripts/init.sql`)
- [ ] Verify schema sudah created di PostgreSQL
- [ ] Create Entity Framework DbContext
- [ ] Create Entity models:
  - [ ] `User.cs`
  - [ ] `Domain.cs`
  - [ ] `Goal.cs`
  - [ ] `Milestone.cs`
  - [ ] `Action.cs`
  - [ ] `ActionCompletion.cs`
  - [ ] `DailyCheckIn.cs`
  - [ ] `DomainScore.cs`
  - [ ] `EvidenceItem.cs`
- [ ] Configure Entity relationships
- [ ] Create DbContext: `UbermenschDbContext.cs`
- [ ] Test DbContext connection
- [ ] Create migration: `dotnet ef migrations add InitialCreate`
- [ ] Apply migration: `dotnet ef database update`
- [ ] Verify tables created: `docker exec -it ubermensch-postgres psql -U ubermensch_user -d ubermensch -c "\dt"`

#### **Developer 2 (Android)**
- [ ] Review database schema
- [ ] Create Room entities:
  - [ ] `UserEntity.kt`
  - [ ] `DomainEntity.kt`
  - [ ] `GoalEntity.kt`
  - [ ] `MilestoneEntity.kt`
  - [ ] `ActionEntity.kt`
  - [ ] `ActionCompletionEntity.kt`
  - [ ] `CheckInEntity.kt`
  - [ ] `DomainScoreEntity.kt`
  - [ ] `EvidenceEntity.kt`
- [ ] Create Room DAOs:
  - [ ] `UserDao.kt`
  - [ ] `DomainDao.kt`
  - [ ] `GoalDao.kt`
  - [ ] `ActionDao.kt`
  - [ ] `CheckInDao.kt`
  - [ ] `DomainScoreDao.kt`
- [ ] Create Room Database: `UbermenschDatabase.kt`
- [ ] Create database version & migrations
- [ ] Test database creation di emulator
- [ ] Verify entities bisa insert/query

---

### **Day 5: Authentication Setup**

#### **Developer 1 (Backend)**
- [ ] Setup Google OAuth di Google Cloud Console
  - [ ] Create OAuth 2.0 credentials
  - [ ] Get Client ID & Client Secret
  - [ ] Add authorized redirect URIs
- [ ] Install JWT packages: `Microsoft.AspNetCore.Authentication.JwtBearer`
- [ ] Configure JWT in `Program.cs`
- [ ] Create `AuthController.cs`:
  - [ ] `POST /api/v1/auth/google` - Google OAuth login
  - [ ] `POST /api/v1/auth/refresh` - Refresh token
  - [ ] `POST /api/v1/auth/logout` - Logout
- [ ] Create `AuthService.cs`:
  - [ ] Validate Google token
  - [ ] Create/update user
  - [ ] Generate JWT tokens
- [ ] Create DTOs: `LoginRequestDto.cs`, `AuthResponseDto.cs`
- [ ] Test authentication endpoint dengan Postman
- [ ] Enable Swagger untuk testing

#### **Developer 2 (Android)**
- [ ] Add Google Sign-In dependency
- [ ] Configure `google-services.json` (Firebase)
- [ ] Create `AuthRepository.kt` interface
- [ ] Create `AuthRepositoryImpl.kt`:
  - [ ] Google Sign-In integration
  - [ ] API call ke backend
  - [ ] Token storage (EncryptedSharedPreferences)
- [ ] Create `AuthViewModel.kt`
- [ ] Create `LoginScreen.kt` (Compose):
  - [ ] Google Sign-In button
  - [ ] Loading state
  - [ ] Error handling
- [ ] Create navigation untuk auth flow
- [ ] Test login flow end-to-end

---

## **WEEK 2: Core Features - Goals & Domains**

### **Day 6-7: Domain Management**

#### **Developer 1 (Backend)**
- [ ] Create `DomainController.cs`:
  - [ ] `GET /api/v1/domains` - Get all domains
  - [ ] `POST /api/v1/domains` - Create domain
  - [ ] `PUT /api/v1/domains/{id}` - Update domain
  - [ ] `DELETE /api/v1/domains/{id}` - Delete domain
- [ ] Create `DomainService.cs`:
  - [ ] Business logic untuk domains
  - [ ] Default domains creation (on user signup)
- [ ] Create DTOs: `DomainDto.cs`, `CreateDomainDto.cs`
- [ ] Add authorization (user hanya bisa akses domains sendiri)
- [ ] Test endpoints dengan Postman
- [ ] Add Swagger documentation

#### **Developer 2 (Android)**
- [ ] Create `DomainRepository.kt` interface
- [ ] Create `DomainRepositoryImpl.kt`:
  - [ ] Local (Room) operations
  - [ ] Remote (API) operations
  - [ ] Sync logic
- [ ] Create `DomainViewModel.kt`
- [ ] Create `DomainScreen.kt`:
  - [ ] List domains dengan cards
  - [ ] Domain score display (0-100%)
  - [ ] Add/edit domain dialog
- [ ] Create `DomainCard.kt` component
- [ ] Implement offline-first (save to Room first)
- [ ] Test create/edit domain offline & sync

---

### **Day 8-10: Goals CRUD**

#### **Developer 1 (Backend)**
- [ ] Create `GoalController.cs`:
  - [ ] `GET /api/v1/goals` - Get all goals (with filters)
  - [ ] `GET /api/v1/goals/{id}` - Get goal by ID
  - [ ] `POST /api/v1/goals` - Create goal
  - [ ] `PUT /api/v1/goals/{id}` - Update goal
  - [ ] `DELETE /api/v1/goals/{id}` - Delete goal
- [ ] Create `GoalService.cs`:
  - [ ] Business logic
  - [ ] Progress calculation (60/30/10 formula)
- [ ] Create DTOs: `GoalDto.cs`, `CreateGoalDto.cs`, `UpdateGoalDto.cs`
- [ ] Add validation (FluentValidation)
- [ ] Test endpoints
- [ ] Add pagination untuk goals list

#### **Developer 2 (Android)**
- [ ] Create `GoalRepository.kt` interface
- [ ] Create `GoalRepositoryImpl.kt`:
  - [ ] Local operations (Room)
  - [ ] Remote operations (API)
  - [ ] Sync queue management
- [ ] Create `GoalViewModel.kt`
- [ ] Create `GoalsListScreen.kt`:
  - [ ] List goals dengan cards
  - [ ] Filter by domain
  - [ ] Filter by status
  - [ ] Pull-to-refresh
- [ ] Create `GoalDetailScreen.kt`:
  - [ ] Goal info display
  - [ ] Progress bar
  - [ ] Actions list
  - [ ] Edit/Delete buttons
- [ ] Create `GoalBuilderScreen.kt`:
  - [ ] Form untuk create/edit goal
  - [ ] Domain selection
  - [ ] Outcome metric input
  - [ ] Deadline picker
- [ ] Create `GoalCard.kt` component
- [ ] Implement offline-first
- [ ] Test create/edit/delete goal offline & sync

---

## **WEEK 3: Actions & Progress Tracking**

### **Day 11-12: Actions Management**

#### **Developer 1 (Backend)**
- [ ] Create `ActionController.cs`:
  - [ ] `GET /api/v1/goals/{goalId}/actions` - Get actions for goal
  - [ ] `POST /api/v1/actions` - Create action
  - [ ] `PUT /api/v1/actions/{id}` - Update action
  - [ ] `DELETE /api/v1/actions/{id}` - Delete action
  - [ ] `POST /api/v1/actions/{id}/complete` - Mark as completed
- [ ] Create `ActionService.cs`:
  - [ ] Business logic
  - [ ] Completion tracking
- [ ] Create DTOs: `ActionDto.cs`, `CreateActionDto.cs`, `CompleteActionDto.cs`
- [ ] Test endpoints

#### **Developer 2 (Android)**
- [ ] Create `ActionRepository.kt` interface
- [ ] Create `ActionRepositoryImpl.kt`
- [ ] Create `ActionViewModel.kt`
- [ ] Update `GoalDetailScreen.kt`:
  - [ ] Actions list section
  - [ ] Add action button
  - [ ] Mark action complete
- [ ] Create `ActionItem.kt` component
- [ ] Create `AddActionDialog.kt`
- [ ] Implement action completion tracking
- [ ] Test action CRUD offline & sync

---

### **Day 13-14: Progress Calculation**

#### **Developer 1 (Backend)**
- [ ] Implement progress calculation algorithm:
  - [ ] 60% dari actions completion
  - [ ] 30% dari milestones
  - [ ] 10% dari outcome metric
- [ ] Create `ProgressService.cs`:
  - [ ] Calculate goal progress
  - [ ] Calculate domain score (70/30 formula)
  - [ ] Update progress on action completion
- [ ] Add endpoint: `GET /api/v1/goals/{id}/progress`
- [ ] Add endpoint: `GET /api/v1/domains/{id}/score`
- [ ] Test calculation accuracy

#### **Developer 2 (Android)**
- [ ] Create `ProgressCalculator.kt` utility
- [ ] Implement local progress calculation
- [ ] Update `GoalDetailScreen.kt`:
  - [ ] Progress bar dengan breakdown
  - [ ] Real-time update saat action completed
- [ ] Update `DomainScreen.kt`:
  - [ ] Domain score display
  - [ ] Score history (optional)
- [ ] Test progress calculation

---

### **Day 15: Milestones**

#### **Developer 1 (Backend)**
- [ ] Create `MilestoneController.cs`:
  - [ ] `GET /api/v1/goals/{goalId}/milestones`
  - [ ] `POST /api/v1/milestones`
  - [ ] `PUT /api/v1/milestones/{id}`
  - [ ] `POST /api/v1/milestones/{id}/complete`
- [ ] Create DTOs: `MilestoneDto.cs`
- [ ] Test endpoints

#### **Developer 2 (Android)**
- [ ] Create `MilestoneRepository.kt`
- [ ] Update `GoalDetailScreen.kt`:
  - [ ] Milestones section
  - [ ] Mark milestone complete
- [ ] Create `MilestoneItem.kt` component
- [ ] Test milestone tracking

---

## **WEEK 4: Daily Check-in**

### **Day 16-18: Check-in Feature**

#### **Developer 1 (Backend)**
- [ ] Create `CheckInController.cs`:
  - [ ] `GET /api/v1/checkins` - Get check-ins (with date range)
  - [ ] `GET /api/v1/checkins/today` - Get today's check-in
  - [ ] `POST /api/v1/checkins` - Create check-in
  - [ ] `PUT /api/v1/checkins/{id}` - Update check-in
- [ ] Create `CheckInService.cs`:
  - [ ] Business logic
  - [ ] Validation (one check-in per day)
- [ ] Create DTOs: `CheckInDto.cs`, `CreateCheckInDto.cs`
- [ ] Test endpoints

#### **Developer 2 (Android)**
- [ ] Create `CheckInRepository.kt` interface
- [ ] Create `CheckInRepositoryImpl.kt`
- [ ] Create `CheckInViewModel.kt`
- [ ] Create `CheckInScreen.kt`:
  - [ ] Energy slider (1-5)
  - [ ] Focus slider (1-5)
  - [ ] Mood selector (1-5)
  - [ ] Most Important Thing input
  - [ ] 3 checkboxes: Move / Create / Connect
  - [ ] Save button
- [ ] Create slider components
- [ ] Create `CheckInHistoryScreen.kt` (optional)
- [ ] Implement offline-first
- [ ] Test check-in offline & sync

---

## **WEEK 5: Offline Mode & Sync**

### **Day 19-21: Offline-First Implementation**

#### **Developer 1 (Backend)**
- [ ] Add `synced_at` timestamp ke semua entities
- [ ] Create sync endpoints:
  - [ ] `POST /api/v1/sync/push` - Push local changes
  - [ ] `POST /api/v1/sync/pull` - Pull server changes
  - [ ] `GET /api/v1/sync/changes?since={timestamp}` - Get changes since
- [ ] Implement conflict resolution (last write wins untuk MVP)
- [ ] Test sync endpoints

#### **Developer 2 (Android)**
- [ ] Create `SyncManager.kt`:
  - [ ] Sync queue management
  - [ ] Pending changes tracking
  - [ ] Conflict resolution
- [ ] Create `SyncWorker.kt` (WorkManager):
  - [ ] Background sync every 15 minutes
  - [ ] Sync on app open
  - [ ] Retry logic
- [ ] Update all repositories untuk mark `synced` status
- [ ] Create `SyncQueue` table di Room
- [ ] Implement sync flow:
  - [ ] User action → Save to Room → Add to sync queue
  - [ ] Background sync → Push changes → Pull changes
  - [ ] Update UI
- [ ] Create offline indicator component
- [ ] Test full offline scenario:
  - [ ] Create goal offline
  - [ ] Edit goal offline
  - [ ] Go online → Verify sync
  - [ ] Check conflicts resolved

---

### **Day 22-23: Sync Testing & Refinement**

#### **Both Developers**
- [ ] Test sync dengan multiple devices
- [ ] Test conflict scenarios
- [ ] Test dengan poor network
- [ ] Test dengan large data
- [ ] Fix sync bugs
- [ ] Optimize sync performance
- [ ] Add sync status indicator di UI
- [ ] Add manual sync button (pull-to-refresh)

---

## **WEEK 6: UI/UX Polish & Navigation**

### **Day 24-26: Navigation & Dashboard**

#### **Developer 2 (Android)**
- [ ] Setup Navigation Component
- [ ] Create bottom navigation:
  - [ ] Home/Dashboard
  - [ ] Goals
  - [ ] Today/Check-in
  - [ ] Profile
- [ ] Create `DashboardScreen.kt`:
  - [ ] Domain cards grid
  - [ ] Active goals list (top 3)
  - [ ] Quick stats
  - [ ] Today's check-in status
- [ ] Create `HomeScreen.kt` (main entry)
- [ ] Create `ProfileScreen.kt`:
  - [ ] User info
  - [ ] Settings
  - [ ] Logout
- [ ] Implement navigation flow
- [ ] Add loading states
- [ ] Add error states
- [ ] Test navigation

---

### **Day 27-28: UI Components & Theme**

#### **Developer 2 (Android)**
- [ ] Create design system:
  - [ ] Colors (primary, secondary, etc.)
  - [ ] Typography
  - [ ] Spacing
  - [ ] Components
- [ ] Create reusable components:
  - [ ] `ProgressBar.kt`
  - [ ] `DomainCard.kt`
  - [ ] `GoalCard.kt`
  - [ ] `ActionItem.kt`
  - [ ] `LoadingIndicator.kt`
  - [ ] `ErrorMessage.kt`
- [ ] Apply theme ke semua screens
- [ ] Add animations (optional)
- [ ] Test UI di different screen sizes
- [ ] Test dark mode (optional untuk MVP)

---

## **WEEK 7: Testing & Bug Fixes**

### **Day 29-31: Comprehensive Testing**

#### **Developer 1 (Backend)**
- [ ] Write unit tests untuk services
- [ ] Write integration tests untuk controllers
- [ ] Test semua endpoints dengan Postman
- [ ] Load testing (optional)
- [ ] Security testing:
  - [ ] JWT validation
  - [ ] Authorization checks
  - [ ] Input validation
- [ ] Fix bugs found

#### **Developer 2 (Android)**
- [ ] Write unit tests untuk ViewModels
- [ ] Write unit tests untuk Repositories
- [ ] Write UI tests untuk critical flows:
  - [ ] Login flow
  - [ ] Create goal flow
  - [ ] Check-in flow
- [ ] Test di multiple devices:
  - [ ] Different Android versions (7.0, 10, 12, 14)
  - [ ] Different screen sizes
- [ ] Test offline mode thoroughly
- [ ] Test sync functionality
- [ ] Performance testing:
  - [ ] App startup time
  - [ ] Screen navigation
  - [ ] Database queries
- [ ] Fix bugs found

---

### **Day 32-33: Bug Fixes & Refinement**

#### **Both Developers**
- [ ] Review semua bugs dari testing
- [ ] Prioritize bugs (critical, high, medium, low)
- [ ] Fix critical & high priority bugs
- [ ] Code review
- [ ] Refactor jika perlu
- [ ] Update documentation

---

## **WEEK 8: Performance & Optimization**

### **Day 34-35: Performance Optimization**

#### **Developer 1 (Backend)**
- [ ] Add database indexes (jika belum)
- [ ] Optimize queries (N+1 problems)
- [ ] Add response caching (Redis)
- [ ] Add pagination untuk large lists
- [ ] Optimize API response times
- [ ] Add compression (gzip)

#### **Developer 2 (Android)**
- [ ] Optimize Room queries
- [ ] Add pagination untuk lists
- [ ] Optimize Compose recomposition
- [ ] Add image caching (Coil)
- [ ] Optimize app startup
- [ ] Reduce APK size (ProGuard)
- [ ] Memory leak detection (LeakCanary)

---

### **Day 36-37: Final Testing**

#### **Both Developers**
- [ ] End-to-end testing semua features
- [ ] Test dengan real data (100+ goals, 1000+ actions)
- [ ] Test edge cases
- [ ] Test error scenarios
- [ ] Final bug fixes
- [ ] Performance verification

---

## **WEEK 9: Google Play Preparation**

### **Day 38-40: App Preparation**

#### **Developer 2 (Android)**
- [ ] Generate release keystore
- [ ] Configure signing di `build.gradle.kts`
- [ ] Enable ProGuard/R8
- [ ] Test release build
- [ ] Generate signed AAB: `./gradlew bundleRelease`
- [ ] Test AAB dengan bundletool
- [ ] Update version code & version name
- [ ] Create app icon (512x512)
- [ ] Create feature graphic (1024x500)
- [ ] Take screenshots (min 2)
- [ ] Write store listing:
  - [ ] Short description (80 chars)
  - [ ] Full description (4000 chars)
- [ ] Create privacy policy (host di GitHub Pages atau website)
- [ ] Complete content rating questionnaire

---

### **Day 41-42: Google Play Console Setup**

#### **Developer 2 (Android)**
- [ ] Create Google Play Developer account ($25)
- [ ] Create app di Play Console
- [ ] Upload AAB ke Internal Testing
- [ ] Add testers (email addresses)
- [ ] Complete store listing
- [ ] Upload screenshots
- [ ] Add privacy policy URL
- [ ] Submit untuk review (Internal Testing)
- [ ] Wait for review (usually instant untuk Internal Testing)

---

## **WEEK 10: Beta Testing & Launch**

### **Day 43-45: Internal Testing**

#### **Both Developers**
- [ ] Share Internal Testing link dengan testers
- [ ] Collect feedback
- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Fix critical bugs
- [ ] Update app jika perlu
- [ ] Re-upload AAB

---

### **Day 46-47: Closed Beta (Optional)**

#### **Developer 2 (Android)**
- [ ] Create Closed Testing track
- [ ] Upload AAB
- [ ] Add beta testers (100-1000 users)
- [ ] Monitor feedback
- [ ] Fix bugs
- [ ] Prepare untuk production

---

### **Day 48-50: Production Launch**

#### **Developer 2 (Android)**
- [ ] Final testing
- [ ] Update version code
- [ ] Generate final AAB
- [ ] Upload ke Production track
- [ ] Enable staged rollout (5% → 20% → 50% → 100%)
- [ ] Monitor:
  - [ ] Crash reports
  - [ ] User reviews
  - [ ] Performance metrics
- [ ] Respond to user feedback
- [ ] Plan next update

---

## 📊 Progress Tracking

### **Weekly Checkpoints**

**End of Week 1**: Environment setup, database, authentication ✅  
**End of Week 2**: Domains & Goals CRUD ✅  
**End of Week 3**: Actions & Progress tracking ✅  
**End of Week 4**: Daily check-in ✅  
**End of Week 5**: Offline mode & sync ✅  
**End of Week 6**: UI/UX polish ✅  
**End of Week 7**: Testing & bug fixes ✅  
**End of Week 8**: Performance optimization ✅  
**End of Week 9**: Google Play preparation ✅  
**End of Week 10**: Launch! 🚀

---

## ✅ Definition of Done (per Feature)

Setiap feature dianggap "Done" jika:
- [ ] Backend API implemented & tested
- [ ] Android UI implemented
- [ ] Offline mode working
- [ ] Sync working
- [ ] Unit tests written
- [ ] Manual testing passed
- [ ] Code reviewed
- [ ] Documentation updated

---

## 🎯 Success Criteria (MVP)

MVP dianggap "Complete" jika:
- [ ] All 8 core features working
- [ ] Offline mode working 100%
- [ ] Sync working reliably
- [ ] No critical bugs
- [ ] App bisa di-download dari Google Play
- [ ] App bisa digunakan end-to-end tanpa errors
- [ ] Performance acceptable (startup < 2s, navigation < 300ms)

---

**Last Updated**: 2024  
**Status**: Ready to Start! 🚀

