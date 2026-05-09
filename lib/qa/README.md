# QA Validation Tools

This directory contains quality assurance utilities for validating end-to-end system behavior.

## LearningLoopValidator

**Purpose**: Validates the complete learning loop from training session to topic unlock.

**What it validates**:
1. **Session Tracking** - XP awarded, mistakes recorded, sessions logged
2. **Review System** - Mistakes available for review, CTA shown, correct topics loaded
3. **Mastery Achievement** - Skill reaches "strong" (≥3 correct, 0 mistakes)
4. **Topic Unlock** - Mastery recognized, dependent topics unlock
5. **Path Update** - Unlocked topic appears in ProgressPathCard

### Usage

```dart
import 'package:poker_analyzer/qa/learning_loop_validator.dart';

void main() async {
  final validator = LearningLoopValidator();
  
  final result = await validator.validateLoop(
    initialTopic: 'preflop_basics',
    targetUnlock: 'advanced_preflop',
    sessionCount: 3,
  );
  
  if (result.isValid) {
    print('✓ Learning loop validated');
  } else {
    print('✗ Validation failed:');
    print(result.summary);
  }
}
```

### Running Tests

```bash
# Run validator tests
dart test test/qa/learning_loop_validator_test.dart

# All tests (31 tests)
dart test test/qa/
```

### ValidationResult API

```dart
class ValidationResult {
  bool isValid;              // True if no errors
  List<String> errors;       // Error messages
  Map<String, bool> stages;  // Stage pass/fail status
  Map<String, dynamic> metadata; // Run parameters
  
  String get summary;        // Formatted report
  bool get allStagesPassed;  // Convenience getter
  int get failedStageCount;  // Number of failed stages
}
```

### Stage Keys

- `session_tracking` - Session data recording
- `review_system` - Review CTA and topic loading
- `mastery` - Skill mastery achievement
- `unlock` - Topic unlock logic
- `path_update` - Progress path updates

### Design

- **Pure Dart** - No Flutter dependencies, runs with `dart test`
- **Simulation-based** - Uses mock helpers to test logic without real data
- **Modular** - Each stage validates independently
- **CI-friendly** - Structured output for automated testing

### Example Output

```
Learning Loop Validation:
  Valid: true
  Stages:
    ✓ session_tracking
    ✓ review_system
    ✓ mastery
    ✓ unlock
    ✓ path_update
```

### Notes

- Uses simulation helpers (mocks) to test without real service dependencies
- Validation is optimistic (assumes happy path) - primarily useful for structural validation
- For real-world validation, use integration tests with actual services
- Validator is reusable and can run concurrent validations
