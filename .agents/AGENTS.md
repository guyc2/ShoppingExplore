# ShoppingExplore — Workspace Rules & Development Guidelines

Welcome to **ShoppingExplore**, a cross-platform mobile application targeting iOS and Android built with **Flutter**.

This document outlines the mandatory architecture, coding standards, error handling, testing policies, and agent instructions for this repository.

---

## 1. Architectural Blueprint (Clean Architecture / Layered MVVM)

The project enforces a strict **Layered Architecture (MVVM / Clean Architecture)**. Each feature resides in `lib/features/<feature_name>/` and is divided into three distinct layers:

```
lib/
├── core/                        # Shared infrastructure & utilities
│   ├── error/                   # Failure types & exception handling
│   ├── network/                 # REST API client & interceptors
│   ├── theme/                   # Material 3 colors, typography, tokens
│   └── utils/                   # Extensions & helpers
└── features/
    └── <feature_name>/
        ├── domain/              # Pure Dart Business Logic (No Flutter dependencies)
        │   ├── entities/        # Core business data models
        │   ├── repositories/    # Abstract interfaces for data access
        │   └── usecases/        # Single-responsibility business actions
        ├── data/                # Data Access & External Services
        │   ├── datasources/     # Remote (REST API) & Local (SQLite/Prefs) sources
        │   ├── models/          # DTOs with JSON serialization (fromJson/toJson)
        │   └── repositories/    # Implementation of domain repository interfaces
        └── presentation/        # UI & State Management
            ├── controllers/     # ViewModels / Notifiers / BLoCs (State management)
            ├── views/           # Flutter Pages / Screens
            └── widgets/         # Component UI widgets
```

### Layer Rules & Boundaries (.NET Analogy)
1. **Presentation Layer (Views / ViewModels)**:
   - Views (Widgets) ONLY handle layout and user interactions.
   - ViewModels / Controllers hold UI state and process actions.
   - **Rule**: Views must NEVER call API endpoints or databases directly.
2. **Domain Layer (Core Logic / Services)**:
   - Contains entities, business logic, and repository interfaces.
   - **Rule**: Pure Dart code. ZERO `package:flutter` imports allowed in the domain layer.
3. **Data Layer (Repositories & Data Sources)**:
   - Implements domain repository interfaces. Handles serialization (DTO $\leftrightarrow$ Entity), HTTP requests, caching.

---

## 2. Coding & Quality Standards

### Null Safety & Immutability
- **Null Safety**: Require strict null safety (`Type?` only when value is truly optional).
- **Immutability**: Use `const` constructors wherever possible. Data models and state objects must be immutable.
- **Variable Declarations**: Default to `final` for variables and parameters unless re-assignment is required.

### Error Handling Policy
- **No Swallowed Exceptions**: Never use empty `catch` blocks or ignore errors silently.
- **Typed Failures**: Represent domain failures using an explicit hierarchy:
  - `NetworkFailure` (API/Connection issues)
  - `CacheFailure` (Local database/storage issues)
  - `ValidationFailure` (Invalid user input)
- **User Feedback**: Map failures to user-friendly messages in the presentation layer.

### Asynchronous Operations
- Always use `async` / `await` for Future operations.
- Handle loading, success, and error states explicitly in UI controllers.

---

## 3. UI/UX & Design Guidelines

- **Material 3 Design**: Utilize Flutter's Material 3 design system with customized `ThemeData` defined in `lib/core/theme/`.
- **Dynamic Layouts**: Build responsive UIs that adapt cleanly to various screen sizes (small phones to large tablets) using `LayoutBuilder`, `MediaQuery`, `Flexible`, and `Expanded`. Do NOT hardcode absolute pixel heights/widths for containers containing dynamic text.
- **Dark & Light Mode**: Support both dark and light themes using semantic theme colors (`Theme.of(context).colorScheme`). Avoid hardcoded hex colors (`Color(0xFF...)`) in feature widgets.
- **Typography & Fonts**: Use Google Fonts or clean system typography configured in `lib/core/theme/app_typography.dart`.

---

## 4. Agent Collaboration & Workflow Instructions

When generating or modifying code in this codebase, AI agents MUST follow these instructions:

1. **Static Analysis**: After modifying any Dart file, verify static analysis using `dart analyze` or `flutter analyze`. There must be **zero warnings and zero errors**.
2. **Modular Edits**: Keep widgets small, focused, and reusable. Limit single-file length to under 300 lines by breaking UI into child widgets.
3. **Testing**: Write unit tests for all UseCases and ViewModels under `test/features/<feature_name>/`.
4. **Git Commit Standards**: Use conventional commits:
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation updates
   - `refactor:` Code refactoring without behavioral change
   - `test:` Adding or updating tests
5. **Branching & GitFlow Policy**: NEVER develop or commit directly to the `main` branch. All development, refactoring, and sprint execution MUST occur on dedicated feature branches (e.g., `feature/<name>` or `feature/<name>-sprint-<number>`). Upon passing tests and PR code review, feature branches MUST be merged into the `develop` branch. Merging `develop` into `main` is strictly reserved for the user or explicit user instruction.

---

## 5. Mandatory Documentation Policy (Docs-Driven Development)

All developers and AI agents working on this project MUST strictly follow the documentation synchronization policy:

1. **Documentation Synchronization**: Any addition, modification, refactoring, or deletion of code, modules, files, or architecture MUST be immediately updated in `/docs/` (`docs/index.md` and module notes).
2. **Docs-First Reference**: Before starting work on any feature or change, agents MUST consult `/docs/` to ground their implementation in existing specifications, system dependencies, and module flows.
3. **Obsidian-Style Markdown**: Documentation in `/docs/` MUST be written using Obsidian-style markdown conventions, including YAML frontmatter (`tags: [...]`, `aliases: [...]`), wikilinks (`[[note|Display Text]]`), Obsidian callouts (`> [!info]`, `> [!warning]`), and fenced Mermaid diagrams (` ```mermaid `).

---

## 6. Sprint-Based Feature Planning & Multi-Agent Execution Gates

For every new feature or major enhancement, the following workflow is mandatory:

1. **Sprint Breakdown**:
   - Every feature plan MUST be broken into sequential, testable Sprints (steps).
   - Before finalizing the implementation plan, ask the user to confirm or specify the desired number of Sprints.
2. **Dedicated Test & Review Subagents**:
   - **Code Review**: Every Sprint implementation MUST be peer-reviewed by an independent Reviewer subagent using the `review-pr` skill. The Reviewer MUST always explicitly verify that centralized logging (`AppLogger`) and typed error handling (`Result`/`Failure`) are properly implemented without swallowed exceptions.
   - **Test Generation**: Tests MUST be written and verified by a dedicated Testing subagent to ensure unbiased coverage.
3. **Strict Execution Gates**:
   - Upon finishing a Sprint (code implementation + test coverage + review verification), execution MUST STOP.
   - The agent MUST present the Sprint summary to the user and wait for explicit permission before resuming to the next Sprint.
