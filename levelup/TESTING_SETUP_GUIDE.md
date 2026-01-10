# 🧪 Testing Setup Guide

## ✅ Automatic Setup Complete

I've automatically set up:
- ✅ Test dependencies (`mockito`, `bloc_test`, `integration_test`)
- ✅ Test directory structure
- ✅ Test helpers and utilities
- ✅ Base agent framework
- ✅ UI Agent
- ✅ Data Agent
- ✅ Journey agents (Quest Completion, Daily Quest)
- ✅ Sample agentic test

## 📋 Manual Setup Required

### **1. Enable Developer Mode (Windows)**

The `flutter pub get` output showed a warning about symlink support. To enable:

```bash
# Run this command to open Developer Settings
start ms-settings:developers
```

Then enable:
- **Developer Mode** toggle

### **2. Run Tests**

```bash
# Run all tests
flutter test

# Run agentic tests specifically
flutter test test/agentic/

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### **3. (Optional) AI-Powered Agentic Testing**

For **advanced AI-powered agentic testing** (using OpenAI Vision, Gemini, etc.), you'll need to:

1. **Add API Keys** (Optional - for AI vision/screen analysis):
   ```dart
   // Create test/config/api_keys.dart
   class ApiKeys {
     static const String openAiKey = 'your-key-here';
     static const String geminiKey = 'your-key-here';
   }
   ```

2. **Integrate AI Services** (Optional):
   - Currently, agents use **fallback strategies** (multiple ways to find elements)
   - For true AI-powered testing, integrate vision APIs in `ui_agent.dart`
   - See `AGENTIC_TESTING_GUIDE.md` for details

**Note**: The current implementation works **without AI APIs** using smart fallback strategies!

## 🎯 Test Structure

```
test/
├── helpers/
│   ├── test_helpers.dart      # Test utilities
│   └── mock_factories.dart    # Mock data factories
├── agentic/
│   ├── base_agent.dart        # Base agent class
│   ├── ui_agent.dart          # UI interaction agent
│   ├── data_agent.dart        # Data validation agent
│   ├── journey_agents/
│   │   ├── quest_completion_journey_agent.dart
│   │   └── daily_quest_journey_agent.dart
│   └── scenarios/
│       └── quest_completion_test.dart
└── widget_test.dart           # Default Flutter test
```

## 🚀 Quick Start

### **Run Basic Tests**
```bash
flutter test
```

### **Run Agentic Tests**
```bash
flutter test test/agentic/scenarios/quest_completion_test.dart
```

### **Run with Verbose Output**
```bash
flutter test --verbose
```

## 📊 What's Working

### **✅ Base Framework**
- Multi-strategy element finding
- Adaptive UI interaction
- Data validation
- Error handling and logging
- Discovery reporting

### **✅ Journey Agents**
- Quest Completion Journey
- Daily Quest Journey
- More can be added easily

### **✅ Smart Features**
- Retry logic for flaky operations
- Multiple strategies for finding elements
- Automatic error recovery
- Detailed logging and discovery reporting

## 🔧 Troubleshooting

### **Issue: Symlink Warning**
**Solution**: Enable Developer Mode (see above)

### **Issue: Tests Fail on First Run**
**Solution**: Run `flutter clean && flutter pub get` then try again

### **Issue: Hive Adapters Not Registered**
**Solution**: Tests automatically register adapters in `test_helpers.dart`

## 📚 Next Steps

1. ✅ **Run the tests** - Everything should work out of the box!
2. **Add more journey agents** - Copy the pattern from existing agents
3. **(Optional) Add AI vision** - For advanced screen analysis
4. **Expand test coverage** - Add more scenarios

## 🎉 Ready to Test!

Everything is set up and ready. Just run:

```bash
flutter test
```

No manual configuration needed (except Developer Mode for Windows)!

---

**Status**: ✅ Ready to Run  
**Last Updated**: 2024


