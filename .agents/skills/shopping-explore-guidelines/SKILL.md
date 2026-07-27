---
name: shopping-explore-guidelines
description: Core architecture conventions, state management guidelines, API response patterns, and design tokens for the ShoppingExplore mobile app.
---

# ShoppingExplore Skill Guidelines

This skill provides guidelines and patterns for engineering features in the **ShoppingExplore** iOS & Android cross-platform application.

## 1. Domain Modeling Guidelines

- Domain entities must be pure Dart classes.
- Use value equality (`Equatable` or standard operator `==` overrides) so UI state diffing works efficiently.
- Every model that is parsed from API endpoints must have a corresponding DTO in `data/models/` with `fromJson` and `toJson` serialization methods.
- Keep mapping functions explicit: `Entity toDomain()` in DTOs and `DTO fromDomain(Entity entity)` for requests.

## 2. State Management Guidelines (Layered MVVM)

- Use a reactive, uni-directional state management approach (e.g. `ChangeNotifier` / `ValueNotifier` or `Riverpod` / `BLoC`).
- State objects must represent explicit states:
  - `InitialState`
  - `LoadingState`
  - `SuccessState<T>` (containing payload data)
  - `ErrorState` (containing user-displayable error string or failure type)
- Never mutate state properties directly; emit a new state instance.

## 3. Network & API Guidelines

- Centralize HTTP requests through `lib/core/network/api_client.dart`.
- All API calls must return a `Result<T, Failure>` or `Either<Failure, T>`.
- Use standard HTTP headers:
  - `Accept: application/json`
  - `Content-Type: application/json`
- Timeout configuration: Default timeout of 15 seconds for all network requests.

## 4. UI Design Tokens & Styling

- Primary Theme: Accessible modern palette defined in `lib/core/theme/app_theme.dart`.
- Spacing Scale: Standard 4pt grid system:
  - `xxs`: 4.0
  - `xs`: 8.0
  - `sm`: 12.0
  - `md`: 16.0
  - `lg`: 24.0
  - `xl`: 32.0
- Component Rules:
  - Buttons: Rounded corners (border radius: 12.0), min touch target height 48.0 for mobile accessibility.
  - Cards: Subtle shadow elevation (1.0 or 2.0), glassmorphism overlay options for featured items.
