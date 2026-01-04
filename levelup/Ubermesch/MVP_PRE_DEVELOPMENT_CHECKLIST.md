# ✅ Pre-Development Checklist - MVP Ubermensch

## 🎯 Konfirmasi Sebelum Mulai Development

Dokumen ini berisi pertanyaan dan konfirmasi penting sebelum mulai development MVP.

---

## 📋 Technology Stack Confirmation

### **Mobile App (Android)**
- [ ] **Kotlin 100%** - Apakah tim comfortable dengan Kotlin? (Jika belum, perlu learning curve ~1-2 minggu)
- [ ] **Jetpack Compose** - Apakah tim familiar dengan Compose? (Jika belum, bisa pakai XML dulu untuk MVP)
- [ ] **Minimum SDK 24** - Apakah OK untuk drop support Android < 7.0? (Covers ~95% devices)
- [ ] **Room Database** - Untuk offline-first storage

**Question**: Apakah tim sudah familiar dengan Kotlin & Compose, atau perlu waktu learning?

### **Backend**
- [ ] **.NET Core 8** - Tim sudah familiar dengan .NET/C#?
- [ ] **PostgreSQL** - Apakah OK dengan PostgreSQL? (Bisa pakai MySQL jika prefer)
- [ ] **Redis** - Untuk caching (optional di MVP, bisa skip dulu)

**Question**: Apakah tim lebih comfortable dengan .NET atau Java Spring Boot? (Keduanya bisa, tapi .NET lebih sesuai dengan skill yang disebutkan)

### **Infrastructure**
- [ ] **Self-hosted VPS** - Apakah sudah punya VPS atau perlu setup?
- [ ] **Docker** - Apakah familiar dengan Docker?
- [ ] **Domain** - Apakah sudah punya domain name?

**Question**: Apakah sudah punya server/VPS, atau perlu rekomendasi provider?

---

## 🎯 MVP Scope Confirmation

### **Must-Have Features (MVP Phase 1)**

#### **1. Authentication**
- [ ] Google OAuth login
- [ ] User profile creation
- [ ] Logout functionality

**Question**: Apakah Google OAuth sudah setup di Google Cloud Console?

#### **2. Domain Setup**
- [ ] Create 6-10 default domains (Vitality, Mind, Character, Craft, Wealth, Relationships, Contribution, Spirit, Environment)
- [ ] User bisa edit domain names
- [ ] Domain color & icon selection

**Question**: Apakah 8-10 domain sudah final, atau perlu adjust?

#### **3. Goal/Quest System**
- [ ] Create goal dengan:
  - Title, description
  - Domain assignment
  - Why (deep reason)
  - Outcome metric (number/percentage/frequency)
  - Deadline (optional)
- [ ] View goals list
- [ ] View goal detail
- [ ] Edit goal
- [ ] Delete goal

**Question**: Apakah goal builder perlu "Simple" dan "Advanced" mode, atau cukup satu mode dulu?

#### **4. Actions/Habits**
- [ ] Create action untuk goal
- [ ] Action types: habit, task, deep_work
- [ ] Mark action as completed
- [ ] View action history

**Question**: Apakah action completion perlu timer (pomodoro), atau cukup checkbox dulu?

#### **5. Daily Check-in**
- [ ] Energy slider (1-5)
- [ ] Focus slider (1-5)
- [ ] Mood selector (1-5)
- [ ] Most Important Thing (text input)
- [ ] 3 checkboxes: Move / Create / Connect
- [ ] Save check-in
- [ ] View check-in history

**Question**: Apakah check-in harus sekali per hari, atau bisa multiple times?

#### **6. Progress Calculation**
- [ ] Calculate goal progress (60% actions + 30% milestones + 10% outcome)
- [ ] Calculate domain score (70% leading + 30% lagging)
- [ ] Display progress bars
- [ ] Update real-time saat action completed

**Question**: Apakah progress calculation perlu real-time atau bisa batch (setiap sync)?

#### **7. Offline Mode**
- [ ] All CRUD operations work offline
- [ ] Data saved to Room DB immediately
- [ ] Sync queue for pending changes
- [ ] Background sync when online
- [ ] Offline indicator in UI

**Question**: Apakah offline mode adalah priority #1, atau bisa implement bertahap?

#### **8. Basic Sync**
- [ ] Initial sync on login
- [ ] Incremental sync (every 15 min or on app open)
- [ ] Conflict resolution (last write wins untuk MVP)
- [ ] Sync status indicator

**Question**: Apakah conflict resolution perlu complex (merge arrays) atau simple (last write wins) dulu?

---

## 🚫 Features to Skip in MVP (Phase 1)

### **Will Add Later:**
- [ ] Quest system (4-12 week projects) - Simplify jadi regular goals dulu
- [ ] Weekly review - Skip dulu, focus daily check-in
- [ ] Next Best Action algorithm - Skip dulu, manual action selection
- [ ] Evidence vault - Skip dulu, focus core tracking
- [ ] Stagnation detection - Skip dulu
- [ ] Social circles - Skip dulu
- [ ] Push notifications - Skip dulu (bisa add later)
- [ ] Analytics/Insights - Skip dulu, basic progress bars cukup

**Question**: Apakah ada fitur di atas yang HARUS ada di MVP? (Jika ya, perlu adjust timeline)

---

## 🗄️ Database Schema Confirmation

### **Core Tables (MVP)**
- [ ] `users` - User profiles
- [ ] `domains` - Life domains
- [ ] `goals` - Goals/Quests
- [ ] `actions` - Actions per goal
- [ ] `action_completions` - Completion history
- [ ] `daily_checkins` - Check-in history
- [ ] `domain_scores` - Domain score history (calculated, bisa skip di MVP)

**Question**: Apakah schema sudah OK, atau perlu adjust?

---

## 🎨 UI/UX Confirmation

### **Screens (MVP)**
1. [ ] **Splash Screen** - Logo, loading
2. [ ] **Onboarding** - Domain selection, North Star input (optional)
3. [ ] **Login Screen** - Google OAuth button
4. [ ] **Dashboard/Home** - Domain cards, active goals, quick stats
5. [ ] **Goals List** - List semua goals
6. [ ] **Goal Detail** - Goal info, actions, progress
7. [ ] **Goal Builder** - Create/edit goal form
8. [ ] **Today/Check-in** - Daily check-in screen
9. [ ] **Profile/Settings** - User profile, logout

**Question**: Apakah 9 screens ini sudah cukup untuk MVP, atau perlu tambah/kurangi?

### **Navigation**
- [ ] Bottom navigation (Home, Goals, Today, Profile)
- [ ] Or drawer navigation?

**Question**: Bottom nav atau drawer nav? (Bottom nav lebih modern untuk mobile)

---

## 🔐 Security & Privacy

### **MVP Requirements**
- [ ] HTTPS only (backend)
- [ ] JWT authentication
- [ ] Encrypted local storage (sensitive data)
- [ ] Privacy policy URL (required untuk Google Play)

**Question**: Apakah privacy policy sudah dibuat, atau perlu template?

---

## 📱 Google Play Requirements

### **Pre-Launch**
- [ ] Google Play Developer account ($25) - Sudah punya?
- [ ] App icon (512x512) - Sudah ada design?
- [ ] Screenshots (min 2) - Bisa ambil dari app nanti
- [ ] Store listing text - Bisa tulis nanti
- [ ] Privacy policy - Perlu dibuat

**Question**: Apakah Google Play Developer account sudah dibuat?

---

## 🧪 Testing Strategy

### **MVP Testing**
- [ ] Unit tests untuk business logic (UseCases)
- [ ] UI tests untuk critical flows (login, create goal, check-in)
- [ ] Manual testing di real devices
- [ ] Test offline mode
- [ ] Test sync functionality

**Question**: Apakah testing akan dilakukan parallel dengan development, atau setelah feature complete?

---

## ⏱️ Timeline & Resources

### **Estimated Timeline (2 Developers)**
- **Week 1-2**: Setup project, authentication, basic UI
- **Week 3-4**: Goal CRUD, actions, check-in
- **Week 5-6**: Progress calculation, offline mode
- **Week 7-8**: Sync functionality, testing, bug fixes
- **Week 9-10**: Polish, Google Play preparation, launch

**Total: ~10 weeks (2.5 months)**

**Question**: Apakah timeline ini realistic untuk tim, atau perlu adjust?

### **Resource Allocation**
- [ ] Developer 1: Mobile app (Android)
- [ ] Developer 2: Backend + DevOps

**Question**: Apakah pembagian tugas sudah jelas?

---

## 🚀 Development Environment

### **Setup Required**
- [ ] Android Studio installed
- [ ] .NET 8 SDK installed
- [ ] Docker Desktop installed
- [ ] Git repository created
- [ ] Development server/VPS ready (optional, bisa local dulu)

**Question**: Apakah development environment sudah siap?

---

## 📊 Success Metrics (MVP)

### **Technical Metrics**
- [ ] App startup < 2 seconds
- [ ] All features work offline
- [ ] Sync success rate > 95%
- [ ] Crash rate < 0.1%

### **Business Metrics (Post-Launch)**
- [ ] 100+ downloads (first month)
- [ ] 4.0+ star rating
- [ ] 50%+ retention (7 days)
- [ ] < 5% uninstall rate

**Question**: Apakah metrics ini realistic untuk MVP?

---

## ❓ Critical Questions

### **1. Backend First or Mobile First?**
**Recommendation**: Start dengan backend API (simple CRUD) → kemudian mobile app

**Question**: Apakah setuju dengan approach ini?

### **2. Database Migration Strategy**
- [ ] Entity Framework migrations (.NET)
- [ ] Room migrations (Android)
- [ ] Manual SQL scripts

**Question**: Apakah perlu versioning strategy dari awal, atau bisa simple dulu?

### **3. Error Handling**
- [ ] Global error handler
- [ ] User-friendly error messages
- [ ] Error logging (Firebase Crashlytics)

**Question**: Apakah error handling perlu comprehensive dari awal, atau basic dulu?

### **4. Logging & Monitoring**
- [ ] Backend logging (Serilog)
- [ ] Mobile crash reporting (Firebase Crashlytics)
- [ ] Analytics (Firebase Analytics - free)

**Question**: Apakah monitoring perlu setup dari awal, atau bisa add later?

---

## ✅ Final Confirmation

### **Before Starting Development:**

1. **Technology Stack**: ✅ Confirmed
   - [ ] Kotlin + Compose (or XML if prefer)
   - [ ] .NET Core 8
   - [ ] PostgreSQL
   - [ ] Room Database

2. **MVP Scope**: ✅ Confirmed
   - [ ] 8 core features (auth, domains, goals, actions, check-in, progress, offline, sync)
   - [ ] 9 screens
   - [ ] Skip advanced features (quest, review, coach, etc.)

3. **Timeline**: ✅ Confirmed
   - [ ] 10 weeks (2.5 months) realistic
   - [ ] 2 developers assigned

4. **Infrastructure**: ✅ Ready
   - [ ] Development environment setup
   - [ ] Git repository
   - [ ] Google Play account (optional, bisa later)

5. **Design**: ✅ Ready
   - [ ] UI/UX mockups (optional, bisa iterate)
   - [ ] App icon (bisa simple dulu)

---

## 🎯 Recommended Starting Point

### **Week 1 Tasks:**

1. **Day 1-2: Project Setup**
   - [ ] Create Android project (Kotlin, Compose)
   - [ ] Create backend project (.NET Core)
   - [ ] Setup Git repository
   - [ ] Setup Docker Compose (PostgreSQL, Redis)

2. **Day 3-4: Database Schema**
   - [ ] Create PostgreSQL schema
   - [ ] Create Room entities
   - [ ] Create DAOs

3. **Day 5: Authentication**
   - [ ] Setup Google OAuth (backend)
   - [ ] Implement login flow (mobile)
   - [ ] Test end-to-end

---

## 📞 Questions to Answer

**Please confirm:**

1. ✅ **Technology Stack** - Apakah semua teknologi sudah OK?
2. ✅ **MVP Scope** - Apakah 8 features sudah cukup, atau perlu adjust?
3. ✅ **Timeline** - Apakah 10 weeks realistic?
4. ✅ **Development Environment** - Apakah sudah siap?
5. ✅ **Starting Point** - Apakah setuju dengan Week 1 tasks?

**Jika ada yang perlu adjust atau clarify, silakan sebutkan sebelum mulai development!**

---

## 🚀 Ready to Start?

Setelah semua konfirmasi, kita bisa mulai dengan:
1. Create project structure
2. Setup database schema
3. Implement authentication
4. Build core features one by one

**Let's build! 🎉**

---

**Last Updated**: 2024

