import 'package:flutter_test/flutter_test.dart';

/// Base result class for agent operations
class AgentResult {
  final bool success;
  final List<String> actions;
  final List<String> discoveries;
  final List<String> errors;
  final Map<String, dynamic> observations;

  AgentResult({
    required this.success,
    required this.actions,
    this.discoveries = const [],
    this.errors = const [],
    this.observations = const {},
  });

  AgentResult copyWith({
    bool? success,
    List<String>? actions,
    List<String>? discoveries,
    List<String>? errors,
    Map<String, dynamic>? observations,
  }) {
    return AgentResult(
      success: success ?? this.success,
      actions: actions ?? this.actions,
      discoveries: discoveries ?? this.discoveries,
      errors: errors ?? this.errors,
      observations: observations ?? this.observations,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('AgentResult: ${success ? "SUCCESS" : "FAILED"}');
    buffer.writeln('Actions (${actions.length}):');
    for (final action in actions) {
      buffer.writeln('  - $action');
    }
    if (discoveries.isNotEmpty) {
      buffer.writeln('Discoveries (${discoveries.length}):');
      for (final discovery in discoveries) {
        buffer.writeln('  - $discovery');
      }
    }
    if (errors.isNotEmpty) {
      buffer.writeln('Errors (${errors.length}):');
      for (final error in errors) {
        buffer.writeln('  - $error');
      }
    }
    return buffer.toString();
  }
}

/// Test scenario definition
class TestScenario {
  final String name;
  final String description;
  final List<ScenarioStep> steps;
  final List<Assertion> assertions;

  const TestScenario({
    required this.name,
    this.description = '',
    this.steps = const [],
    this.assertions = const [],
  });
}

/// Individual step in a test scenario
class ScenarioStep {
  final String action;
  final Map<String, dynamic> params;
  final String? expectedOutcome;

  const ScenarioStep({
    required this.action,
    this.params = const {},
    this.expectedOutcome,
  });
}

/// Assertion to validate after scenario
class Assertion {
  final String description;
  final Future<bool> Function() validate;

  const Assertion({
    required this.description,
    required this.validate,
  });
}

/// Base class for all test agents
abstract class BaseAgent {
  final WidgetTester tester;
  final List<String> actionLog = [];
  final List<String> discoveries = [];
  final List<String> errors = [];

  BaseAgent(this.tester);

  /// Execute a test scenario
  Future<AgentResult> execute(TestScenario scenario);

  /// Validate an assertion
  Future<bool> validate(Assertion assertion);

  /// Log an action
  void logAction(String action) {
    actionLog.add('${DateTime.now().toIso8601String()}: $action');
  }

  /// Record a discovery
  void recordDiscovery(String discovery) {
    discoveries.add('${DateTime.now().toIso8601String()}: $discovery');
  }

  /// Record an error
  void recordError(String error) {
    errors.add('${DateTime.now().toIso8601String()}: $error');
  }

  /// Create result from current state
  AgentResult createResult({required bool success}) {
    return AgentResult(
      success: success,
      actions: List.from(actionLog),
      discoveries: List.from(discoveries),
      errors: List.from(errors),
    );
  }

  /// Reset agent state
  void reset() {
    actionLog.clear();
    discoveries.clear();
    errors.clear();
  }
}


