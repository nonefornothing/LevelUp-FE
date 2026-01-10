# 🚀 Running LevelUp App - Manual Testing Guide

## 📋 Quick Start

### **Option 1: Run on Windows Desktop (Recommended for Quick Testing)**

```bash
flutter run -d windows
```

This will:
- Build and run the app on Windows desktop
- Launch a window with your app
- Enable hot reload (press `r` in terminal to reload, `R` to restart)

### **Option 2: Run on Chrome (Web Browser)**

```bash
flutter run -d chrome
```

This will:
- Build and run the app in Chrome browser
- Open Chrome automatically
- Enable hot reload (press `r` in terminal to reload, `R` to restart)

### **Option 3: Run on Edge**

```bash
flutter run -d edge
```

---

## 🎯 Available Devices

Your current available devices:
- ✅ **Windows (desktop)** - `windows`
- ✅ **Chrome (web)** - `chrome`
- ✅ **Edge (web)** - `edge`

To see all available devices:
```bash
flutter devices
```

---

## 📱 Running on Android Emulator (Optional)

### **Step 1: Check Available Emulators**

```bash
flutter emulators
```

### **Step 2: Launch an Emulator**

If you have emulators installed:
```bash
flutter emulators --launch <emulator_id>
```

Or launch from Android Studio:
1. Open Android Studio
2. Tools → Device Manager
3. Click the play button on an emulator

### **Step 3: Run on Android**

Once emulator is running:
```bash
flutter run
```

Or specify the device:
```bash
flutter run -d <device-id>
```

---

## 🔥 Hot Reload & Hot Restart

While the app is running:

- **`r`** - Hot reload (fast refresh, keeps state)
- **`R`** - Hot restart (full restart, resets state)
- **`q`** - Quit the app
- **`h`** - List all available commands

---

## 🐛 Troubleshooting

### **Issue: "Some Android licenses not accepted"**

This is optional, but if you want to use Android:

```bash
flutter doctor --android-licenses
```

Press `y` to accept all licenses.

### **Issue: "No devices found"**

1. Check devices:
   ```bash
   flutter devices
   ```

2. For Android, make sure emulator is running or device is connected

3. For web, Chrome/Edge should be available automatically

### **Issue: Build errors**

1. Clean build:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Try running again:
   ```bash
   flutter run
   ```

---

## 📝 Testing Checklist

Once the app is running, you can manually test:

### **1. Authentication Flow**
- [ ] Splash screen appears
- [ ] Onboarding flow (if first time)
- [ ] Login screen
- [ ] Registration
- [ ] Logout

### **2. Quest System**
- [ ] View quest list
- [ ] Create new quest
- [ ] View quest details
- [ ] Update quest progress
- [ ] Complete quest
- [ ] Claim rewards

### **3. Player Profile**
- [ ] View player profile
- [ ] Check XP and level
- [ ] Level up animation

### **4. Daily Quests**
- [ ] View daily quests
- [ ] Complete daily quests
- [ ] Daily reset behavior

### **5. Navigation**
- [ ] Navigate between screens
- [ ] Back button works
- [ ] Deep linking (if applicable)

### **6. Offline Mode**
- [ ] Turn off network
- [ ] Create quest offline
- [ ] Complete quest offline
- [ ] Turn on network
- [ ] Verify data persisted

---

## 🎨 Development Tips

### **Debug Mode**

The app runs in debug mode by default, which includes:
- Hot reload
- Debug banners
- Detailed error messages

### **Release Mode (for Performance Testing)**

To test performance:
```bash
flutter run --release -d windows
```

Or:
```bash
flutter run --release -d chrome
```

### **Verbose Output**

For more detailed output:
```bash
flutter run -v
```

---

## 🚀 Recommended Workflow

1. **Start Development Session**
   ```bash
   flutter run -d windows
   ```

2. **Make Changes**
   - Edit code in your IDE
   - Save file
   - Press `r` in terminal for hot reload

3. **Test Feature**
   - Interact with the app
   - Verify behavior
   - Check for errors

4. **Restart if Needed**
   - Press `R` for hot restart (if hot reload doesn't work)
   - Or stop and run again: `flutter run -d windows`

---

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Flutter Debugging Guide](https://docs.flutter.dev/tools/debugging)

---

**Happy Testing! 🎉**

