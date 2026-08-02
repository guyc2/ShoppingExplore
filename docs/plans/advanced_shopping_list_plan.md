---
tags: [plan, shopping-list, sprints, architecture]
aliases: [Advanced Shopping List Plan, Initial Framework Plan]
---
# Advanced Shopping List — Initial Framework Implementation Plan

This document outlines the planned multi-sprint architecture and implementation for **ShoppingExplore**'s core product: an **Advanced Shopping List** capable of operating both as a simple checklist and a complex item manager with rich properties (images, links, priority, custom key-value attributes, and notes). It also includes support for user authentication via email, allowing users to log in and share their shopping lists with other users.

## Multi-Agent Execution & Quality Policy

In accordance with Section 6 of [[../.agents/AGENTS|AGENTS.md]]:
- 🧪 **Dedicated Testing Subagent**: In every Sprint, unit and widget tests are authored and validated by an independent Testing subagent.
- 🔍 **Peer Reviewer Subagent**: In every Sprint, code changes are audited by an independent Reviewer subagent using the `review-pr` skill.
- 🛑 **Strict Execution Gate**: At the end of every Sprint (after tests & PR review pass), execution **STOPS**. The agent presents the Sprint summary and waits for explicit user permission before starting the next Sprint.

---

## Planned Sprints Breakdown

### Sprint 1: Domain Entities & Data Layer Scaffold
- **Implementation**:
  - `ShoppingItem` domain entity (supporting `id`, `title`, `isCompleted`, `quantity`, `unit`, `priority`, `notes`, `imageUrls`, `linkUrls`, `attributes` map).
  - `ShoppingList` domain entity (supporting user ownership and shared email addresses).
  - `ShoppingListRepository` interface & DTO models (`ShoppingItemDto`, `ShoppingListDto`).
  - `ShoppingListLocalDataSource` and `ShoppingListRepositoryImpl`.
- 🧪 **Testing Subagent**: Authors unit tests for entity immutability, copyWith methods, and DTO JSON serialization.
- 🔍 **Reviewer Subagent**: Performs PR code review using `review-pr` skill.
- 🛑 **Execution Gate**: Present Sprint 1 results and wait for user approval to begin Sprint 2.

### Sprint 2: State Management & Business Logic (UseCases & ViewModels)
- **Implementation**:
  - Domain UseCases: `GetShoppingLists`, `CreateShoppingItem`, `ToggleItemCompletion`, `UpdateItemProperties`, `DeleteShoppingItem`.
  - `ShoppingListController` ViewModel managing state emissions (Loading, Loaded, Error).
  - Dual-mode logic (Quick check toggle for simple lists vs. full property edits for complex items).
- 🧪 **Testing Subagent**: Authors unit tests for UseCases and Controller state transitions.
- 🔍 **Reviewer Subagent**: Performs PR code review using `review-pr` skill.
- 🛑 **Execution Gate**: Present Sprint 2 results and wait for user approval to begin Sprint 3.

### Sprint 3: UI Presentation Layer & Rich Item Controls
- **Implementation**:
  - `ShoppingListView` supporting quick-add text input for simple items.
  - `ShoppingItemDetailView` allowing users to view and edit rich properties (image URLs, reference links, priority badges, custom metadata fields).
  - Reusable UI widgets: `ItemTileWidget`, `PropertyChipWidget`, `LinkCardWidget`.
- 🧪 **Testing Subagent**: Authors component widget tests.
- 🔍 **Reviewer Subagent**: Performs PR code review using `review-pr` skill.
- 🛑 **Execution Gate**: Present Sprint 3 results and wait for user approval to begin Sprint 4.

### Sprint 4: Authentication & List Sharing
- **Implementation**:
  - Email/Password authentication for users.
  - Integration with a remote data source for cloud synchronization.
  - Sharing functionality allowing users to share lists with other users via email address.
- 🧪 **Testing Subagent**: Authors unit tests for auth workflows and remote syncing.
- 🔍 **Reviewer Subagent**: Performs PR code review using `review-pr` skill.
- 🛑 **Execution Gate**: Present Sprint 4 final results for user review.

---

## Planned File Structure

```
lib/features/shopping_list/
├── domain/
│   ├── entities/          # ShoppingItem, ShoppingList, Priority
│   ├── repositories/      # ShoppingListRepository interface
│   └── usecases/          # GetShoppingLists, CreateShoppingItem, ToggleItemCompletion
├── data/
│   ├── datasources/      # ShoppingListLocalDataSource
│   ├── models/           # ShoppingItemDto, ShoppingListDto
│   └── repositories/     # ShoppingListRepositoryImpl
└── presentation/
    ├── controllers/      # ShoppingListController
    ├── views/            # ShoppingListView, ShoppingItemDetailView
    └── widgets/          # ItemTileWidget, PropertyChipWidget
```

> [!info] Status
> All 4 Sprints (Sprint 1 Domain/Data, Sprint 2 State/UseCases, Sprint 3 UI, and Sprint 4 Auth & Sharing) have been implemented, tested, reviewed, and verified.
