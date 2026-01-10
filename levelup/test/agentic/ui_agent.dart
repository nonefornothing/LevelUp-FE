import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';
import 'base_agent.dart';

/// UI interaction agent with multiple strategies
/// Note: This agent doesn't execute full scenarios, it's used by journey agents
class UIAgent extends BaseAgent {
  UIAgent(super.tester);

  @override
  Future<AgentResult> execute(TestScenario scenario) async {
    throw UnimplementedError('UIAgent does not execute scenarios directly');
  }

  @override
  Future<bool> validate(Assertion assertion) async {
    return await assertion.validate();
  }

  /// Tap on element using multiple strategies
  Future<void> tap(String description, {bool exact = true}) async {
    logAction('Attempting to tap: $description');
    
    // Strategy 1: Find by exact text
    try {
      final finder = findWidgetByText(description, exact: exact);
      if (finder.evaluate().isNotEmpty) {
        await tapWithRetry(tester, finder);
        logAction('Successfully tapped: $description (exact text)');
        return;
      }
    } catch (e) {
      recordDiscovery('Exact text tap failed: $e');
    }

    // Strategy 2: Find by partial text
    if (exact) {
      try {
        final finder = findWidgetByText(description, exact: false);
        if (finder.evaluate().isNotEmpty) {
          await tapWithRetry(tester, finder);
          logAction('Successfully tapped: $description (partial text)');
          return;
        }
      } catch (e) {
        recordDiscovery('Partial text tap failed: $e');
      }
    }

    // Strategy 3: Find by key
    try {
      final finder = find.byKey(Key(description.toLowerCase().replaceAll(' ', '_')));
      if (finder.evaluate().isNotEmpty) {
        await tapWithRetry(tester, finder);
        logAction('Successfully tapped: $description (key)');
        return;
      }
    } catch (e) {
      recordDiscovery('Key tap failed: $e');
    }

    // Strategy 4: Find by icon data (if description matches common icon names)
    final iconMap = {
      'back': Icons.arrow_back,
      'close': Icons.close,
      'save': Icons.save,
      'delete': Icons.delete,
      'edit': Icons.edit,
      'add': Icons.add,
      'menu': Icons.menu,
      'search': Icons.search,
      'settings': Icons.settings,
    };

    final iconData = iconMap[description.toLowerCase()];
    if (iconData != null) {
      try {
        final finder = find.byIcon(iconData);
        if (finder.evaluate().isNotEmpty) {
          await tapWithRetry(tester, finder);
          logAction('Successfully tapped: $description (icon)');
          return;
        }
      } catch (e) {
        recordDiscovery('Icon tap failed: $e');
      }
    }

    throw Exception('Could not find element to tap: $description');
  }

  /// Enter text in a field
  Future<void> enterText(String fieldDescription, String text) async {
    logAction('Entering text "$text" in field: $fieldDescription');

    // Strategy 1: Find by key (most common)
    try {
      final key = Key(fieldDescription.toLowerCase().replaceAll(' ', '_'));
      final finder = find.byKey(key);
      if (finder.evaluate().isNotEmpty) {
        await enterTextWithRetry(tester, finder, text);
        logAction('Successfully entered text (by key)');
        return;
      }
    } catch (e) {
      recordDiscovery('Key text entry failed: $e');
    }

    // Strategy 2: Find by hint text
    try {
      final finder = find.bySemanticsLabel(fieldDescription);
      if (finder.evaluate().isNotEmpty) {
        await enterTextWithRetry(tester, finder, text);
        logAction('Successfully entered text (by semantics)');
        return;
      }
    } catch (e) {
      recordDiscovery('Semantics text entry failed: $e');
    }

    throw Exception('Could not find field to enter text: $fieldDescription');
  }

  /// Verify element exists
  Future<bool> verifyExists(String description, {Duration timeout = const Duration(seconds: 5)}) async {
    logAction('Verifying existence: $description');

    // Try multiple strategies
    final strategies = [
      () => findWidgetByText(description, exact: true),
      () => findWidgetByText(description, exact: false),
      () => find.byKey(Key(description.toLowerCase().replaceAll(' ', '_'))),
    ];

    for (final strategy in strategies) {
      try {
        final finder = strategy();
        await waitForWidget(finder, tester, timeout: timeout);
        if (finder.evaluate().isNotEmpty) {
          logAction('Found element: $description');
          return true;
        }
      } catch (e) {
        continue;
      }
    }

    logAction('Element not found: $description');
    return false;
  }

  /// Get text from element
  Future<String?> getText(String description) async {
    logAction('Getting text from: $description');

    try {
      final finder = findWidgetByText(description, exact: false);
      if (finder.evaluate().isNotEmpty) {
        final element = finder.evaluate().first;
        final text = (element.widget as Text).data ?? '';
        logAction('Retrieved text: $text');
        return text;
      }
    } catch (e) {
      recordError('Failed to get text: $e');
    }

    return null;
  }

  /// Navigate back
  Future<void> navigateBack() async {
    logAction('Navigating back');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }

  /// Scroll to element
  Future<void> scrollTo(String description) async {
    logAction('Scrolling to: $description');

    try {
      final finder = findWidgetByText(description);
      await tester.scrollUntilVisible(finder, 500, scrollable: find.byType(Scrollable));
      logAction('Scrolled to element: $description');
    } catch (e) {
      recordError('Failed to scroll: $e');
      rethrow;
    }
  }

  /// Wait for element to disappear
  Future<bool> waitForDisappear(String description, {Duration timeout = const Duration(seconds: 5)}) async {
    logAction('Waiting for disappearance: $description');

    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      await tester.pump();
      final finder = findWidgetByText(description);
      if (finder.evaluate().isEmpty) {
        logAction('Element disappeared: $description');
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    logAction('Element did not disappear: $description');
    return false;
  }

  /// Take screenshot (returns base64 encoded string for logging)
  Future<String> takeScreenshot() async {
    // In real implementation, would take actual screenshot
    // For now, return a placeholder
    logAction('Screenshot taken');
    return 'screenshot_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Analyze current screen state
  Future<ScreenAnalysis> analyzeScreen() async {
    logAction('Analyzing screen');

    final analysis = ScreenAnalysis(
      widgets: [],
      textElements: [],
      interactiveElements: [],
    );

    try {
      // Find all text widgets
      final textFinder = find.byType(Text);
      for (final element in textFinder.evaluate()) {
        final text = (element.widget as Text).data ?? '';
        if (text.isNotEmpty) {
          analysis.textElements.add(text);
        }
      }

      // Find all buttons
      final buttonFinder = find.byType(ElevatedButton);
      analysis.interactiveElements.addAll(
        buttonFinder.evaluate().map((e) => 'Button found'),
      );

      recordDiscovery('Screen analysis complete: ${analysis.textElements.length} text elements, ${analysis.interactiveElements.length} interactive elements');
    } catch (e) {
      recordError('Screen analysis failed: $e');
    }

    return analysis;
  }
}

/// Screen analysis result
class ScreenAnalysis {
  final List<String> widgets;
  final List<String> textElements;
  final List<String> interactiveElements;
  final List<String> suggestions;

  ScreenAnalysis({
    required this.widgets,
    required this.textElements,
    required this.interactiveElements,
    this.suggestions = const [],
  });
}

