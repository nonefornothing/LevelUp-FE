# 📋 Product Requirements & Architecture Decisions - Ubermensch App

## 🎯 Executive Summary

Dokumen ini menjawab semua pertanyaan tentang product requirements, user needs, dan technical decisions untuk aplikasi **Ubermensch** berdasarkan diskusi lengkap yang sudah dilakukan.

---

## ✅ 1. Jenis Aplikasi: Native vs. Hybrid vs. Cross-platform

### **❓ Pertanyaan:**
Apakah menggunakan Native (Kotlin/Swift), Hybrid (Ionic), atau Cross-platform (React Native/Flutter)?

### **✅ Jawaban & Keputusan:**

**Keputusan: Native Android (Kotlin + Jetpack Compose)**

**Alasan:**

1. **Target Platform**: Hanya Android untuk MVP (remaja Indonesia)
   - 95%+ market share Android di Indonesia
   - Tidak perlu iOS untuk MVP
   - Bisa expand ke iOS nanti jika perlu

2. **Tim Expertise**: 
   - Tim familiar dengan Java, .NET, C, C++
   - Kotlin lebih mudah dipelajari dari Java
   - Tidak perlu belajar Dart (Flutter) atau JavaScript (React Native)

3. **Performance Requirements**:
   - Offline-first dengan Room Database (native SQLite)
   - Real-time sync dengan WorkManager
   - Complex algorithms (Next Best Action, Domain Score)
   - Native lebih performant untuk heavy computation

4. **Best Practices & Maturity**:
   - Kotlin + Compose = modern Android development standard
   - Extensive documentation & community
   - Better integration dengan Android ecosystem

5. **Budget Constraints**:
   - Native development lebih cost-effective untuk single platform
   - Tidak perlu maintain multiple codebases
   - Open source tools (Room, Compose, WorkManager) - semua free

**Kapan Pertimbangkan Cross-platform?**
- Jika nanti perlu iOS juga → bisa pertimbangkan Flutter
- Jika tim lebih familiar JavaScript → bisa pertimbangkan React Native
- Untuk MVP: **Native Android adalah pilihan terbaik**

---

## 🧱 Tech Stack Final Decision

### **🔹 Frontend (Mobile App)**

**Framework**: **Native Android (Kotlin)**
- **Language**: Kotlin 100%
- **UI Framework**: Jetpack Compose
- **Architecture**: MVVM + Clean Architecture
- **State Management**: StateFlow + ViewModel
- **Navigation**: Compose Navigation
- **Local Database**: Room Database (SQLite)
- **Offline Sync**: WorkManager
- **Dependency Injection**: Hilt
- **Networking**: Retrofit + OkHttp
- **Image Loading**: Coil

**Kenapa Bukan Flutter/React Native?**
- ✅ Tim lebih familiar dengan Java/Kotlin ecosystem
- ✅ Native performance untuk offline-first dengan Room
- ✅ Better integration dengan Android services (WorkManager, Background tasks)
- ✅ Single platform (Android) untuk MVP
- ✅ Mature ecosystem untuk productivity apps

### **🔹 Backend / Server-side**

**Runtime**: **.NET Core 8**
- **Framework**: ASP.NET Core Web API
- **Language**: C#
- **Architecture**: Microservices (Auth, Core, Coach)
- **ORM**: Entity Framework Core
- **Database**: PostgreSQL 15
- **Cache**: Redis 7
- **Authentication**: JWT + Google OAuth
- **File Storage**: MinIO (S3-compatible)

**Kenapa .NET bukan Node.js?**
- ✅ Tim sudah familiar dengan .NET/C#
- ✅ Excellent performance (comparable dengan Go/Java)
- ✅ Strong typing & async/await
- ✅ Built-in dependency injection
- ✅ Open source & free
- ✅ Cross-platform (bisa deploy di Linux)

### **🔹 Database**

**Primary Database**: **PostgreSQL 15**
- **Type**: Relational (SQL)
- **Why**: 
  - ACID compliance (critical untuk data integrity)
  - Excellent untuk complex queries (domain scores, progress calculation)
  - JSON support untuk flexible schema
  - Open source & free

**Cache**: **Redis 7**
- **Purpose**: Session storage, domain score cache, rate limiting

**Time-Series**: **TimescaleDB** (PostgreSQL extension)
- **Purpose**: Daily check-ins, progress logs, analytics

**Local Storage (Mobile)**: **Room Database**
- **Purpose**: Offline-first storage
- **Type**: SQLite wrapper

**Kenapa PostgreSQL bukan MongoDB/Firestore?**
- ✅ Complex relationships (users → domains → goals → actions)
- ✅ ACID transactions (critical untuk sync)
- ✅ Complex queries untuk analytics
- ✅ Open source (no vendor lock-in)
- ✅ Better untuk structured data (goals, check-ins)

### **🔹 Push Notifications**

**Service**: **Firebase Cloud Messaging (FCM)**
- **Why**: 
  - Free tier available
  - Easy integration dengan Android
  - Reliable delivery
  - Analytics included

### **🔹 File/Image Storage**

**Service**: **MinIO** (S3-compatible)
- **Why**: 
  - Self-hosted (no vendor lock-in)
  - S3-compatible API
  - Free & open source
  - Perfect untuk evidence vault (screenshots, PDFs)

**Alternative**: Firebase Storage (jika prefer managed service)

### **🔹 App Deployment & CI/CD**

**CI/CD**: **GitHub Actions** (free untuk public repos)
- **Purpose**: Automated testing, building, deployment

**Distribution**: **Google Play Console**
- **Format**: Android App Bundle (AAB)
- **Signing**: Release keystore

**Obfuscation**: **ProGuard/R8**
- **Purpose**: Code obfuscation, size reduction

---

## 🧩 1. App Type & Core Features

### **❓ What is the purpose of your app?**

**✅ Jawaban:**

**Purpose**: Productivity Life OS - aplikasi untuk tracking dan improvement kehidupan multi-domain dengan sistem goal-setting, progress tracking, dan daily reflection.

**Value Proposition**:
- Membantu remaja Indonesia menjadi lebih produktif dan terorganisir
- Tracking progress di 8-10 domain kehidupan (Vitality, Mind, Character, Craft, Wealth, Relationships, Contribution, Spirit, Environment)
- Evidence-based improvement dengan data tracking
- Offline-first: bisa digunakan tanpa internet

**Problem Solved**:
- Remaja kesulitan track progress di multiple area kehidupan
- Tidak ada sistem yang comprehensive untuk life improvement
- Tools existing terlalu generic atau terlalu spesifik
- Tidak ada yang combine goal-setting + daily habits + reflection

### **❓ What are the core features your app must have?**

**✅ Jawaban (MVP - 8 Core Features):**

1. **✅ User Authentication**
   - Google OAuth login
   - User profile management
   - Secure token storage

2. **✅ Domain Management**
   - Create/edit 6-10 life domains
   - Domain score tracking (0-100%)
   - Visual domain cards

3. **✅ Goal/Quest System**
   - Create goals dengan:
     - Title, description, "why"
     - Domain assignment
     - Outcome metric (number/percentage/frequency)
     - Deadline (optional)
   - View/edit/delete goals
   - Progress tracking (60% actions + 30% milestones + 10% outcome)

4. **✅ Actions/Habits Tracking**
   - Create actions untuk goals
   - Action types: habit, task, deep_work
   - Mark actions as completed
   - Action completion history

5. **✅ Daily Check-in**
   - Energy level (1-5)
   - Focus level (1-5)
   - Mood (1-5)
   - Most Important Thing (text)
   - 3 checkboxes: Move / Create / Connect
   - Check-in history

6. **✅ Progress Calculation**
   - Goal progress: 60% actions + 30% milestones + 10% outcome
   - Domain score: 70% leading indicators + 30% lagging indicators
   - Real-time progress updates

7. **✅ Offline Functionality** (CRITICAL)
   - All CRUD operations work offline
   - Local database (Room) untuk semua data
   - Background sync ketika online
   - Conflict resolution

8. **✅ Push Notifications** (Phase 1.5)
   - Daily check-in reminders
   - Goal stagnation alerts
   - Sync status notifications

**Features untuk Phase 2+ (bukan MVP):**
- Weekly review
- Next Best Action algorithm
- Evidence vault
- Social circles
- N-of-1 experiments
- Life portfolio rebalancing

**📌 Why it matters:**
- Offline mode → Room Database + WorkManager
- Progress calculation → Complex algorithms di backend
- Sync → Conflict resolution strategy
- Push notifications → FCM integration

---

## 👤 2. Target Users & Usage

### **❓ Who are your target users?**

**✅ Jawaban:**

**Primary Users**: Remaja Indonesia (usia 13-25 tahun)
- **Demographics**:
  - Location: Indonesia (primary market)
  - Age: 13-25 (remaja & young adults)
  - Tech-savviness: Medium-High (familiar dengan mobile apps)
  - Education: High school, college students, young professionals

**User Personas**:

1. **"The Ambitious Student"**
   - High school/college student
   - Want to improve grades, skills, health
   - Use app daily untuk track study habits, fitness, personal projects

2. **"The Self-Improver"**
   - Young professional atau college student
   - Focus pada career development, health, relationships
   - Use app untuk track multiple life goals

3. **"The Goal-Setter"**
   - Anyone yang punya multiple goals
   - Want systematic approach untuk achieve goals
   - Use app untuk organize dan track progress

**Market**: Niche market (productivity enthusiasts) dengan potential untuk expand

### **❓ How frequently will they use the app?**

**✅ Jawaban:**

**Frequency**: **Daily** (target: daily active users)

**Usage Pattern**:
- **Morning**: Daily check-in (2-3 minutes)
- **Throughout day**: Mark actions completed (quick updates)
- **Evening**: Review progress, plan tomorrow (5-10 minutes)
- **Weekly**: Weekly review (15-20 minutes)

**Session Duration**:
- Quick sessions: 1-2 minutes (check-in, mark action)
- Regular sessions: 5-10 minutes (create goal, review progress)
- Deep sessions: 15-30 minutes (weekly review, goal planning)

**Expected Usage**:
- **Daily Active Users (DAU)**: Target 70%+ of monthly users
- **Session frequency**: 2-3 times per day
- **Total daily usage**: 10-15 minutes per user

**📌 Why it matters:**
- Daily usage → Need fast app startup (< 2 seconds)
- Quick sessions → Need instant UI updates
- Offline mode critical → Users might use di area dengan poor network
- Background sync → Need efficient sync strategy

---

## 🌐 3. Connectivity Requirements

### **❓ Should the app work offline?**

**✅ Jawaban:**

**YES - Fully Offline-First** (Critical Requirement)

**Offline Capabilities**:
- ✅ **All CRUD operations work offline**
  - Create/edit/delete goals
  - Create/edit/delete actions
  - Mark actions completed
  - Daily check-in
  - View all data

- ✅ **Local Database**: Room Database (SQLite)
  - All user data cached locally
  - Instant read/write operations
  - No internet required untuk core features

- ✅ **Background Sync**: WorkManager
  - Automatic sync every 15 minutes (when online)
  - Sync on app open
  - Manual sync (pull-to-refresh)
  - Conflict resolution (last write wins untuk MVP)

- ✅ **Sync Strategy**:
  - Initial sync: Download all data on login
  - Incremental sync: Only changes since last sync
  - Full sync: Weekly untuk data integrity

**Partial Offline Support**:
- ✅ Core features: 100% offline
- ⚠️ Advanced features (Phase 2): Some require online (social, analytics)

**Online-Only Features** (Phase 2+):
- Social circles
- Advanced analytics
- Cloud backup (optional)

**📌 Why it matters:**
- Indonesia: Network coverage tidak selalu stable
- Remaja: Might use di area dengan poor signal
- User experience: Instant response tanpa waiting untuk network
- Architecture: Room Database + WorkManager + Sync queue

---

## 🔐 4. Authentication & User Management

### **❓ How do users register/login?**

**✅ Jawaban:**

**Primary Method**: **Google OAuth 2.0**

**Why Google OAuth**:
- ✅ Remaja Indonesia: Most have Google accounts
- ✅ Easy sign-up (one-click)
- ✅ No password management
- ✅ Secure (OAuth 2.0)
- ✅ Free (no cost)

**Implementation**:
- Backend: Validate Google token, create/update user
- Mobile: Google Sign-In SDK
- Token storage: EncryptedSharedPreferences (secure)

**Future Options** (Phase 2+):
- Email/password (optional)
- Phone number OTP (untuk users tanpa Google)
- Apple Sign-In (jika expand ke iOS)

### **❓ Do different user roles exist?**

**✅ Jawaban:**

**MVP**: **Single Role - Regular User**

**No role-based access control needed untuk MVP** karena:
- Each user hanya akses data sendiri
- No admin/moderator features
- No multi-user collaboration (Phase 2: social circles)

**Future Roles** (Phase 2+):
- **Regular User**: Standard features
- **Premium User**: Advanced features (coach engine, analytics)
- **Admin** (optional): App management, analytics

**Authorization Strategy**:
- JWT token dengan user_id
- Backend: Check user_id untuk semua operations
- Mobile: Store user_id securely

**📌 Why it matters:**
- Simple auth untuk MVP → Faster development
- JWT tokens → Stateless authentication
- User isolation → Each user hanya akses data sendiri
- Future-proof → Can add roles later tanpa breaking changes

---

## 📈 5. Scalability & Traffic Expectations

### **❓ What scale are you expecting?**

**✅ Jawaban:**

**MVP Phase (0-3 months)**:
- **Target**: 1,000-10,000 users
- **Concurrent users**: 100-1,000
- **Daily active users**: 500-5,000

**Growth Phase (3-12 months)**:
- **Target**: 10,000-100,000 users
- **Concurrent users**: 1,000-10,000
- **Daily active users**: 5,000-50,000

**Scale Phase (12+ months)**:
- **Target**: 100,000-1,000,000 users
- **Concurrent users**: 10,000-100,000
- **Daily active users**: 50,000-500,000

**Ultimate Goal**: **1 Million Concurrent Users**

**Regional Focus**: 
- **Primary**: Indonesia (remaja Indonesia)
- **Secondary**: Southeast Asia (Malaysia, Singapore, Philippines)
- **Future**: Global (English version)

**Infrastructure Scaling**:
- **Phase 1 (0-10K)**: Single server ($50-90/month)
- **Phase 2 (10K-100K)**: Horizontal scaling, read replicas ($200-500/month)
- **Phase 3 (100K-1M)**: Database sharding, load balancing ($800-2800/month)

**📌 Why it matters:**
- Architecture designed untuk scale dari awal
- Database sharding strategy (by user_id)
- Caching strategy (Redis) untuk performance
- CDN untuk static assets
- Load balancing untuk backend services

---

## 📦 6. Data Management

### **❓ What kind of data will be stored?**

**✅ Jawaban:**

**Structured Data** (PostgreSQL):
- User profiles (text)
- Goals (text, JSON for metrics)
- Actions (text, JSON for frequency)
- Daily check-ins (numbers, text)
- Domain scores (numbers, JSON for indicators)
- Milestones (text)
- Evidence items (metadata, file URLs)

**File Data** (MinIO/S3):
- Screenshots (images)
- PDFs (documents)
- Photos (evidence)
- **Size**: Typically < 5MB per file
- **Total per user**: ~100-500MB (estimated)

**Time-Series Data** (TimescaleDB):
- Daily check-ins (high frequency)
- Action completions (high frequency)
- Domain scores (daily calculations)
- Progress logs

**Data Volume Estimates**:
- **Per user**: ~10-50MB (structured + files)
- **1M users**: ~10-50TB total
- **Daily writes**: ~10-20 records per user
- **Daily reads**: ~50-100 queries per user

### **❓ Do you need real-time updates?**

**✅ Jawaban:**

**MVP**: **No Real-time Updates Required**

**Update Strategy**:
- **Pull-based**: Client polls server every 15 minutes
- **On-demand**: Manual refresh (pull-to-refresh)
- **Background sync**: WorkManager handles sync

**Future Real-time** (Phase 2+):
- **Push notifications**: FCM untuk alerts
- **WebSocket** (optional): Untuk social features, live collaboration
- **SignalR** (backend): Jika perlu real-time updates

**Why No Real-time untuk MVP**:
- Offline-first app → Sync-based lebih cocok
- Reduces complexity
- Better battery life
- Sufficient untuk productivity app

### **❓ Any data that requires sync between devices or multi-user collaboration?**

**✅ Jawaban:**

**MVP**: **Single Device per User**

**Sync Strategy**:
- **Single user, multiple devices**: Data sync via backend
- **Conflict resolution**: Last write wins (simple untuk MVP)
- **No multi-user collaboration**: Each user isolated

**Future Multi-Device** (Phase 2+):
- Same account, multiple devices → Sync via backend
- Conflict resolution → Merge strategy (advanced)

**Future Collaboration** (Phase 3+):
- Social circles → Shared goals, accountability
- Multi-user collaboration → Real-time sync required

**📌 Why it matters:**
- Simple sync untuk MVP → Faster development
- Conflict resolution → Last write wins sufficient
- Future-proof → Can add collaboration later

---

## 💳 7. Third-party Integrations

### **❓ Do you need integration with external services?**

**✅ Jawaban:**

**MVP Integrations**:

1. **✅ Google OAuth**
   - **Purpose**: User authentication
   - **SDK**: Google Sign-In for Android
   - **Cost**: Free

2. **✅ Firebase Cloud Messaging (FCM)**
   - **Purpose**: Push notifications
   - **SDK**: Firebase Android SDK
   - **Cost**: Free tier available

3. **✅ Firebase Analytics** (Optional untuk MVP)
   - **Purpose**: User analytics, crash reporting
   - **SDK**: Firebase Android SDK
   - **Cost**: Free tier available

4. **✅ Google Maps** (Future - Phase 2)
   - **Purpose**: Location-based features (optional)
   - **SDK**: Google Maps SDK
   - **Cost**: Free tier available

**No Integration Needed untuk MVP**:
- ❌ Payment gateway (no monetization di MVP)
- ❌ Chat service (no social features di MVP)
- ❌ Email service (no email notifications di MVP)
- ❌ CMS (static content)

**Future Integrations** (Phase 2+):
- **Payment**: Midtrans (Indonesia), Stripe (global)
- **Analytics**: Mixpanel, Amplitude (advanced analytics)
- **Email**: SendGrid (transactional emails)

**📌 Why it matters:**
- Minimal integrations untuk MVP → Faster development
- Google ecosystem → Well-supported di Android
- Free tiers → Cost-effective untuk startup
- Future integrations → Can add later tanpa breaking changes

---

## 🛠️ 8. Maintenance & Dev Team

### **❓ Who will develop and maintain this app?**

**✅ Jawaban:**

**Development Team**:
- **Size**: 2 developers
- **Experience**: Beginner level
- **Skills**: Java, .NET, C, C++
- **Allocation**:
  - Developer 1: Android app (Kotlin/Compose)
  - Developer 2: Backend (.NET Core) + DevOps

**Maintenance**:
- **Post-launch**: Same team (2 developers)
- **Support**: Self-maintained
- **Updates**: Weekly/bi-weekly releases

**Future Scaling**:
- **Phase 2**: Might add 1-2 developers
- **Phase 3**: Might need dedicated DevOps, QA

### **❓ What is your tech comfort zone?**

**✅ Jawaban:**

**Current Skills**:
- ✅ Java (familiar)
- ✅ .NET / C# (familiar)
- ✅ C, C++ (familiar)
- ⚠️ Kotlin (need to learn, but similar to Java)
- ⚠️ Android development (need to learn)
- ⚠️ React Native / Flutter (not familiar)

**Learning Curve**:
- **Kotlin**: 1-2 weeks (similar to Java)
- **Jetpack Compose**: 2-3 weeks (new UI framework)
- **Android Architecture**: 1-2 weeks (MVVM, Clean Architecture)
- **Total**: ~1 month untuk comfortable dengan Android development

**Why Native Android**:
- ✅ Easier learning curve dari Java
- ✅ Extensive documentation
- ✅ Large community
- ✅ Better untuk beginners (more resources)

**📌 Why it matters:**
- Technology choice based on team skills
- Learning curve manageable (1 month)
- Can start development while learning
- Extensive resources available

---

## 📱 9. Target Platform

### **❓ Do you plan to release on:**

**✅ Jawaban:**

**MVP**: **Android Only (Google Play)**

**Why Android Only**:
- ✅ 95%+ market share di Indonesia
- ✅ Remaja Indonesia: Mostly Android users
- ✅ Faster development (single platform)
- ✅ Lower cost (no need iOS developer, Mac, etc.)

**Future Platforms** (Phase 2+):
- **iOS** (App Store): Jika user base grow dan ada demand
- **Web** (PWA): Optional, untuk desktop users
- **Strategy**: Native Android first, expand later jika needed

**Platform Priority**:
1. **Android** (MVP) - Primary
2. **iOS** (Phase 2) - If needed
3. **Web** (Phase 3) - Optional

**📌 Why it matters:**
- Single platform untuk MVP → Faster development
- Can validate product-market fit sebelum expand
- Lower initial cost
- Easier maintenance

---

## 📆 10. Timeline & Budget Constraints

### **❓ What's your target timeline?**

**✅ Jawaban:**

**MVP Timeline**: **10 Weeks (2.5 Months)**

**Breakdown**:
- **Week 1**: Project setup, database, authentication
- **Week 2**: Goals & domains CRUD
- **Week 3**: Actions & progress tracking
- **Week 4**: Daily check-in
- **Week 5**: Offline mode & sync
- **Week 6**: UI/UX polish
- **Week 7**: Testing & bug fixes
- **Week 8**: Performance optimization
- **Week 9**: Google Play preparation
- **Week 10**: Beta testing & launch

**Post-MVP**:
- **Month 3-4**: User feedback, bug fixes, minor features
- **Month 5-6**: Phase 2 features (weekly review, evidence vault)
- **Month 7-12**: Scale, advanced features, iOS (optional)

### **❓ Do you have a budget for infrastructure or are you looking for free tiers only?**

**✅ Jawaban:**

**Budget**: **Startup Budget (Minimal Cost)**

**Infrastructure Costs**:

**Development (Local)**:
- ✅ **Free**: Docker Desktop, Android Studio, .NET SDK
- ✅ **Free**: Local development (PostgreSQL, Redis via Docker)

**Production (MVP Phase)**:
- **VPS**: $40-80/month (DigitalOcean/Hetzner)
- **Domain**: $10/year
- **SSL**: Free (Let's Encrypt)
- **CDN**: Free (Cloudflare free tier)
- **Total**: ~$50-90/month

**Third-party Services**:
- ✅ **Firebase**: Free tier (FCM, Analytics, Crashlytics)
- ✅ **Google OAuth**: Free
- ✅ **Google Maps**: Free tier (if used)
- ✅ **Total**: $0/month

**Scaling Costs** (Future):
- **100K users**: $200-500/month
- **1M users**: $800-2800/month

**Why Self-hosted**:
- ✅ Lower cost (vs managed services)
- ✅ Full control
- ✅ No vendor lock-in
- ✅ Can scale gradually

**📌 Why it matters:**
- Minimal cost untuk MVP → Sustainable untuk startup
- Can scale costs dengan growth
- Open source tools → No licensing fees
- Self-hosted → Full control

---

## 🧠 1. Product Side – Vision & Goals

### **❓ What is the main problem your app solves?**

**✅ Jawaban:**

**Problem**:
Remaja Indonesia kesulitan untuk:
1. **Track progress di multiple life domains** (health, career, relationships, etc.)
2. **Set goals dengan sistem yang jelas** (bukan hanya "ingin jadi lebih baik")
3. **Maintain consistency** dalam improvement (tidak "all or nothing")
4. **See evidence of progress** (bukti nyata bahwa mereka berkembang)
5. **Get personalized recommendations** (apa yang harus dilakukan hari ini)

**Current Solutions & Gaps**:
- **Habit trackers**: Too simple, hanya track habits
- **Goal apps**: Too generic, tidak ada domain system
- **Journal apps**: Tidak ada progress tracking
- **Productivity apps**: Tidak ada life balance focus

**Our Solution**:
Ubermensch = **Comprehensive Life OS** yang combine:
- Domain-based tracking (8-10 life areas)
- Goal-setting dengan metrics
- Daily habits & actions
- Progress calculation (evidence-based)
- Offline-first (always available)

### **❓ What is your main goal for v1 (MVP)?**

**✅ Jawaban:**

**MVP Goal**: **Prove Product-Market Fit**

**Success Metrics**:
- **Downloads**: 1,000+ dalam 3 bulan
- **Retention**: 50%+ (7 days), 30%+ (30 days)
- **Daily Active Users**: 70%+ of monthly users
- **User Rating**: 4.0+ stars
- **Feedback**: Positive feedback tentang core value

**Not MVP Goals** (Phase 2+):
- ❌ Monetization (no payment di MVP)
- ❌ Viral growth (focus on retention first)
- ❌ Feature completeness (8 core features cukup)

**Post-MVP**:
- **Month 3-6**: Iterate based on feedback
- **Month 6-12**: Add advanced features, monetization
- **Year 2**: Scale, expand to iOS, global

**📌 Why it matters:**
- MVP focused on core value → Faster to market
- Validate dengan real users sebelum build more
- Iterate based on data, not assumptions

---

## 👥 2. User-Centered Design (UCD) – UX/Research Side

### **❓ Who are your user personas?**

**✅ Jawaban:**

**Persona 1: "The Ambitious Student" - Rizki (18, High School)**
- **Demographics**: 
  - Age: 18
  - Location: Jakarta
  - Education: High school senior
  - Tech-savviness: High (uses multiple apps daily)
- **Goals**: 
  - Improve grades (target: top 10%)
  - Learn new skills (coding, design)
  - Get fit (lose 5kg, run 5K)
- **Pain Points**:
  - Too many goals, tidak tahu mana yang prioritas
  - Tidak konsisten (semangat awal, lalu drop)
  - Tidak tahu apakah progress atau tidak
- **App Usage**:
  - Daily check-in: Morning (5 min)
  - Mark actions: Throughout day (quick)
  - Review: Evening (10 min)

**Persona 2: "The Self-Improver" - Sari (22, College Student)**
- **Demographics**:
  - Age: 22
  - Location: Bandung
  - Education: College (Computer Science)
  - Tech-savviness: Very High
- **Goals**:
  - Career: Get internship, build portfolio
  - Health: Regular exercise, better sleep
  - Relationships: Quality time dengan family
- **Pain Points**:
  - Life balance (too focused on career, ignore health)
  - Tidak ada sistem untuk track multiple areas
  - Want data-driven improvement
- **App Usage**:
  - Daily check-in: Morning
  - Deep sessions: Weekly review (30 min)
  - Track evidence: Screenshots, links

**Persona 3: "The Goal-Setter" - Andi (25, Young Professional)**
- **Demographics**:
  - Age: 25
  - Location: Surabaya
  - Education: University graduate
  - Tech-savviness: Medium
- **Goals**:
  - Career: Promotion, skill development
  - Wealth: Savings, investment
  - Health: Fitness, nutrition
- **Pain Points**:
  - Goals terlalu vague ("jadi lebih sukses")
  - Tidak tahu cara measure progress
  - Tidak konsisten
- **App Usage**:
  - Daily check-in: Morning
  - Goal planning: Weekly (20 min)
  - Progress review: Monthly

### **❓ What is the main user journey in the app?**

**✅ Jawaban:**

**First-Time User Journey**:

1. **Download & Launch** (30 seconds)
   - Download dari Google Play
   - Open app
   - See splash screen

2. **Onboarding** (3-5 minutes)
   - Welcome screen
   - Select life domains (6-10 domains)
   - Optional: Set North Star (1-2 sentences)
   - Google Sign-In

3. **First Goal** (5 minutes)
   - Dashboard shows empty state
   - Prompt: "Create your first goal"
   - Goal builder wizard:
     - Select domain
     - Enter goal title
     - Set outcome metric
     - Add first action
   - Goal created → See on dashboard

4. **Daily Usage** (2-3 minutes)
   - Morning: Daily check-in
     - Energy, Focus, Mood sliders
     - Most Important Thing
     - Move/Create/Connect checkboxes
   - Throughout day: Mark actions completed
   - Evening: Quick progress review

5. **Weekly Review** (15 minutes) - Phase 2
   - Review week's progress
   - What worked, what didn't
   - Plan next week

**Returning User Journey** (Daily):

1. **Open App** (< 2 seconds)
   - Dashboard loads instantly (offline)
   - See domain scores, active goals

2. **Daily Check-in** (1-2 minutes)
   - Quick check-in
   - See today's focus

3. **Mark Actions** (30 seconds - multiple times)
   - Quick action completion
   - See progress update

4. **Review Progress** (2-3 minutes)
   - Check goal progress
   - See domain scores
   - Plan tomorrow

### **❓ What are the top 3 pain points users currently face?**

**✅ Jawaban:**

**Pain Point 1: "Too Many Goals, No System"**
- **Problem**: Users punya banyak goals tapi tidak terorganisir
- **Current Solution**: Spreadsheets, notes apps, atau tidak track sama sekali
- **Our Solution**: Domain-based organization, clear goal structure dengan metrics

**Pain Point 2: "All or Nothing Mentality"**
- **Problem**: Users drop semua goals jika salah satu gagal
- **Current Solution**: Tidak ada, users just give up
- **Our Solution**: Non-zero day rule, recovery mode, progress tracking yang fair (60/30/10)

**Pain Point 3: "No Evidence of Progress"**
- **Problem**: Users tidak tahu apakah mereka benar-benar improve atau tidak
- **Current Solution**: Subjective feeling ("saya merasa lebih baik")
- **Our Solution**: Data-driven progress (domain scores, progress %, evidence vault)

**📌 Why it matters:**
- UX design focused on solving these pain points
- Onboarding: Address "too many goals" dengan domain system
- Progress tracking: Address "no evidence" dengan clear metrics
- Recovery mode: Address "all or nothing" dengan non-zero day rule

---

## 🎨 3. UI/UX Specifics – Visual, Flow, and Interaction

### **❓ Do you already have wireframes or UI designs?**

**✅ Jawaban:**

**Current Status**: **No wireframes yet** (will create during development)

**Design Approach**:
- **Phase 1**: Start dengan Material Design 3 (default Compose theme)
- **Phase 2**: Customize colors, typography based on user feedback
- **Design Tools**: Figma (for future iterations)

**Design Principles**:
- **Simplicity**: Clean, minimal UI
- **Speed**: Fast interactions, instant feedback
- **Clarity**: Clear progress indicators, easy navigation
- **Offline-first**: UI works seamlessly offline

**UI Components** (Compose):
- Material 3 components
- Custom components: DomainCard, GoalCard, ProgressBar
- Consistent spacing, typography, colors

### **❓ What kind of interactions are important?**

**✅ Jawaban:**

**Primary Interactions**:

1. **Swipe Actions** (Goals, Actions)
   - Swipe left: Delete
   - Swipe right: Complete (for actions)
   - Quick, intuitive

2. **Pull-to-Refresh**
   - Dashboard, Goals list
   - Manual sync trigger
   - Visual feedback

3. **Tap & Hold**
   - Long press: Edit/Delete options
   - Context menu

4. **Sliders** (Check-in)
   - Energy, Focus, Mood sliders
   - Smooth, visual feedback

5. **Quick Actions**
   - Floating Action Button (FAB): Quick add goal/action
   - Bottom sheet: Quick check-in
   - Minimize friction

**Gestures**:
- Swipe untuk navigation (optional)
- Pinch to zoom (for charts, Phase 2)

**Animations**:
- Smooth transitions between screens
- Progress bar animations
- Loading states
- Success/error feedback

### **❓ Do you want to support dark mode, RTL languages, or accessibility?**

**✅ Jawaban:**

**Dark Mode**: **Phase 2** (Not MVP)
- **Why**: Reduces development time untuk MVP
- **Future**: Will add dark mode support
- **Implementation**: Material 3 theme system (easy to add later)

**RTL Languages**: **Not Required** (MVP)
- **Why**: Target market (Indonesia) uses LTR
- **Future**: Can add if expand to RTL markets

**Accessibility**: **Basic Support** (MVP)
- **Content descriptions**: For screen readers
- **Touch targets**: Minimum 48dp
- **Text size**: Support system font scaling
- **Color contrast**: WCAG AA compliance
- **Future**: Full accessibility support (Phase 2)

**📌 Why it matters:**
- MVP focus: Core features first
- Accessibility: Basic support sufficient
- Dark mode: Can add later (easy with Material 3)
- Future-proof: Architecture supports these features

---

## 💼 4. Business & Monetization Strategy

### **❓ How do you plan to monetize the app?**

**✅ Jawaban:**

**MVP**: **No Monetization** (Free)

**Phase 2+ Monetization Options**:

1. **Freemium Model** (Recommended)
   - **Free**: Core features (goals, check-in, basic tracking)
   - **Premium** ($4.99/month atau $39.99/year):
     - Advanced analytics
     - Coach engine (Next Best Action)
     - Evidence vault (unlimited)
     - Social circles
     - N-of-1 experiments
     - Priority support

2. **One-time Purchase** (Alternative)
   - **Free**: Basic features
   - **Pro** ($9.99 one-time): Unlock all features

3. **Subscription** (Future)
   - **Basic**: Free
   - **Premium**: $4.99/month
   - **Ultimate**: $9.99/month (with coaching, community)

**Why No Monetization di MVP**:
- Focus on user acquisition & retention
- Validate product-market fit first
- Build user base
- Add monetization after proven value

### **❓ Do you need analytics or KPIs tracked?**

**✅ Jawaban:**

**MVP Analytics** (Free):

1. **Firebase Analytics** (Basic)
   - User acquisition
   - Screen views
   - User engagement
   - Retention (DAU, MAU)

2. **Custom Events** (Track):
   - Goal creation rate
   - Check-in completion rate
   - Action completion rate
   - Sync success rate
   - Feature usage

**Key Metrics to Track**:

**User Metrics**:
- DAU (Daily Active Users)
- MAU (Monthly Active Users)
- Retention: Day 1, Day 7, Day 30
- Churn rate

**Engagement Metrics**:
- Goals created per user
- Check-ins per week
- Actions completed per day
- Average session duration

**Product Metrics**:
- Feature adoption rate
- Sync success rate
- Crash rate (target: < 0.1%)
- App performance (startup time, navigation speed)

**Future Analytics** (Phase 2+):
- Mixpanel (advanced analytics)
- Custom dashboards
- Cohort analysis
- Funnel analysis

### **❓ Are there legal/policy requirements?**

**✅ Jawaban:**

**Required**:

1. **Privacy Policy** (Required untuk Google Play)
   - Data collection: What data we collect
   - Data usage: How we use data
   - Data storage: Where data stored
   - User rights: How to delete data
   - **Implementation**: Host di GitHub Pages atau website

2. **Terms of Service** (Recommended)
   - User agreement
   - App usage rules
   - Liability disclaimers

3. **GDPR Compliance** (If targeting EU - Future)
   - Data export
   - Data deletion
   - Consent management

**Indonesia-Specific**:
- **PDPA** (Personal Data Protection Act): Basic compliance
- **Content Rating**: Complete Google Play questionnaire

**Health Data** (If applicable - Future):
- **HIPAA** (US): Not applicable (not health app)
- **General**: Basic privacy protection

**📌 Why it matters:**
- Privacy policy: Required untuk Google Play
- Terms of service: Protect from liability
- GDPR: Future-proof jika expand globally
- Compliance: Build trust dengan users

---

## 📲 5. Platform Behavior Expectations

### **❓ How should the app behave under:**

**✅ Jawaban:**

**No Internet (Offline Mode)**:

**Behavior**:
- ✅ **App works 100%** (all features available)
- ✅ **Instant UI updates** (no loading states)
- ✅ **Data saved locally** (Room Database)
- ✅ **Visual indicator**: "Offline" badge
- ✅ **Sync queue**: Pending changes tracked
- ✅ **Auto-sync**: When internet returns

**User Experience**:
- No error messages
- No "no internet" dialogs
- Seamless experience
- User might not even notice offline

**Slow Internet (2G/3G)**:

**Behavior**:
- ✅ **App works offline-first** (no waiting)
- ✅ **Background sync** (doesn't block UI)
- ✅ **Progressive loading** (show cached data first)
- ✅ **Timeout handling** (don't wait forever)
- ✅ **Retry logic** (automatic retry)

**User Experience**:
- Fast UI (cached data)
- Background sync (non-blocking)
- Clear sync status
- Graceful degradation

**Background State (Multitasking)**:

**Behavior**:
- ✅ **WorkManager**: Continues sync in background
- ✅ **Notifications**: Push notifications work
- ✅ **Data persistence**: All data saved
- ✅ **State restoration**: App resumes where left off

**User Experience**:
- App remembers state
- Background sync continues
- Notifications for important events
- Fast resume

**📌 Why it matters:**
- Offline-first architecture → Always works
- Background sync → Non-intrusive
- State management → Good UX
- Battery efficient → WorkManager optimized

---

## 💡 Bonus: Critical Questions

### **❓ "What happens if 1,000 users use this app at the same time?"**

**✅ Jawaban:**

**Architecture Handles This**:

**Backend**:
- **Horizontal scaling**: Multiple backend instances
- **Load balancing**: Nginx distributes requests
- **Database**: Connection pooling (20-50 connections)
- **Caching**: Redis cache untuk frequently accessed data
- **Performance**: API response < 200ms (p95)

**Mobile App**:
- **Offline-first**: Most operations local (no server load)
- **Background sync**: Spreads load over time
- **Efficient sync**: Only changes, not full data
- **Caching**: Local cache reduces API calls

**Expected Load** (1,000 concurrent users):
- **API requests**: ~10-20 requests/user/hour
- **Total**: ~10,000-20,000 requests/hour
- **Peak**: ~500 requests/minute
- **Handled by**: 2-3 backend instances

**Scaling Strategy**:
- **Phase 1 (0-10K)**: Single server sufficient
- **Phase 2 (10K-100K)**: 2-3 instances + read replicas
- **Phase 3 (100K-1M)**: 5-10 instances + sharding

### **❓ "What will break if the user loses signal for 5 minutes?"**

**✅ Jawaban:**

**Nothing Breaks - App Designed for This**:

**Offline-First Architecture**:
- ✅ All data cached locally (Room Database)
- ✅ All CRUD operations work offline
- ✅ No server dependency untuk core features
- ✅ Sync queue: Changes tracked locally
- ✅ Auto-sync: When signal returns

**User Experience**:
- ✅ No errors
- ✅ No "no internet" messages
- ✅ Seamless experience
- ✅ User might not even notice

**What Happens**:
1. User loses signal
2. App continues working (offline)
3. User creates goal, marks actions, checks in
4. All data saved locally
5. Signal returns
6. Background sync automatically
7. Data synced to server
8. No data loss

**Edge Cases Handled**:
- Long offline (days/weeks): Data still safe locally
- Conflict resolution: Last write wins (simple untuk MVP)
- Large data: Efficient sync (only changes)

### **❓ "What is the one feature that, if missing, users would uninstall the app?"**

**✅ Jawaban:**

**Critical Feature**: **Offline Mode**

**Why**:
- Indonesia: Network coverage tidak selalu stable
- Remaja: Use di berbagai lokasi (school, home, travel)
- User expectation: App harus selalu work
- Competitor apps: Many require internet

**If Offline Mode Missing**:
- ❌ Users frustrated ketika no internet
- ❌ App unusable di poor network areas
- ❌ High uninstall rate
- ❌ Poor user experience

**Other Critical Features** (but less critical):
- **Daily check-in**: Core feature, but can work around
- **Goal tracking**: Core feature, but can use notes
- **Progress calculation**: Nice to have, but not critical

**MVP Priority**:
1. **Offline mode** (MUST HAVE)
2. **Goal tracking** (MUST HAVE)
3. **Daily check-in** (MUST HAVE)
4. **Progress calculation** (SHOULD HAVE)
5. **Advanced features** (NICE TO HAVE)

---

## ✅ Summary: Architecture Decisions

| Category | Decision | Rationale |
|----------|----------|-----------|
| **Platform** | Native Android (Kotlin) | Single platform, team skills, performance |
| **UI Framework** | Jetpack Compose | Modern, declarative, performant |
| **Backend** | .NET Core 8 | Team skills, performance, open source |
| **Database** | PostgreSQL | ACID, complex queries, open source |
| **Local Storage** | Room Database | Offline-first, SQLite wrapper |
| **Sync** | WorkManager | Background sync, battery efficient |
| **Auth** | Google OAuth | Easy, free, familiar to users |
| **Notifications** | FCM | Free, reliable, easy integration |
| **Storage** | MinIO | Self-hosted, S3-compatible |
| **Infrastructure** | Self-hosted VPS | Cost-effective, full control |
| **Timeline** | 10 weeks | Realistic untuk 2 developers |
| **Budget** | $50-90/month | Startup-friendly |

---

## 🎯 Final Recommendations

### **✅ Proceed With:**
1. Native Android (Kotlin + Compose)
2. .NET Core backend
3. PostgreSQL database
4. Offline-first architecture
5. 10-week MVP timeline
6. Self-hosted infrastructure

### **✅ MVP Focus:**
1. 8 core features (no more)
2. Offline mode (critical)
3. Simple sync (last write wins)
4. Basic UI (Material 3)
5. No monetization

### **✅ Future Considerations:**
1. iOS version (if needed)
2. Advanced features (Phase 2)
3. Monetization (after validation)
4. Social features (Phase 3)
5. Global expansion

---

**Last Updated**: 2024  
**Status**: Complete & Ready for Development 🚀

