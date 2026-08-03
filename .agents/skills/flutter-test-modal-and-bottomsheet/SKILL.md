---
name: flutter-test-modal-and-bottomsheet
description: Provides best practices and robust test patterns for Flutter bottom sheets, dialogs, rich text spans, and off-screen scrollable modal widgets. Use when writing widget tests for modals, popup menus, bottom sheets, or RichText components.
---

# Flutter Modal, BottomSheet & RichText Testing Skill

When testing Flutter interactive overlays, bottom sheets (`showModalBottomSheet`), dialogs, and multi-span `RichText` widgets, standard widget finders and tap actions can fail due to off-screen viewport hit-tests or nested text spans. Follow these patterns to ensure 100% reliable, flake-free widget tests.

---

## 1. Testing Modals & BottomSheets (Preventing Off-Screen Hit-Test Errors)

### Problem
When `showModalBottomSheet(isScrollControlled: true)` renders a tall modal in the default test viewport (800x600), elements at the bottom of the modal sheet (such as save buttons or choice chips) may be off-screen. Calling `tester.tap(find.text('Save'))` throws:
```
Warning: A call to tap() ... derived an Offset that would not hit test on the specified widget.
```

### Solution
Always ensure the target widget is visible in the viewport before tapping:
```dart
// 1. Open the modal
await tester.tap(find.text('Open Modal'));
await tester.pumpAndSettle();

// 2. Ensure the target widget is scrolled into view before tapping
final targetFinder = find.text('Save Changes');
await tester.ensureVisible(targetFinder);
await tester.pumpAndSettle();

// 3. Perform tap
await tester.tap(targetFinder);
await tester.pumpAndSettle();
```

If `ensureVisible` is insufficient for custom scrollable containers, use `dragUntilVisible`:
```dart
await tester.dragUntilVisible(
  find.text('Target Option'),
  find.byType(SingleChildScrollView),
  const Offset(0, -100),
);
await tester.pumpAndSettle();
```

---

## 2. Testing RichText and Multi-Span Strings

### Problem
In Flutter, `RichText` widgets composed of multiple `TextSpan` children (e.g., `'You shopping at Supermarket'`) are not matched by default using `find.textContaining('Supermarket')` because `TextSpan` is not a standalone `Widget`.

### Solution
Use `find.byWidgetPredicate` to inspect `RichText.text.toPlainText()`:
```dart
expect(
  find.byWidgetPredicate(
    (widget) => widget is RichText && widget.text.toPlainText().contains('Supermarket'),
  ),
  findsOneWidget,
);
```

---

## 3. Modal & Overlay Cleanup in Tests

Always finish modal test sequences with `await tester.pumpAndSettle()` after closing a dialog or modal sheet to allow exit animations to complete cleanly without leaking timers into subsequent tests.
