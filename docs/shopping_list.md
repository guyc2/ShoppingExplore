---
tags: [feature, shopping-list, domain, data]
aliases: [Shopping List, Advanced Shopping List]
---
# Shopping List Module

**Purpose** — Encapsulates the core business logic, domain entities, and data access layer for the Advanced Shopping List feature. It supports both simple checklist items and complex items with rich properties (images, links, priority, notes, attributes).

**Key files** —
- [shopping_list/domain/entities/shopping_item.dart](../lib/features/shopping_list/domain/entities/shopping_item.dart) — Pure Dart entity representing a shopping item with rich attributes.
- [shopping_list/domain/entities/shopping_list.dart](../lib/features/shopping_list/domain/entities/shopping_list.dart) — Pure Dart entity representing a shopping list container.
- [shopping_list/domain/repositories/shopping_list_repository.dart](../lib/features/shopping_list/domain/repositories/shopping_list_repository.dart) — Abstract repository contract for shopping list operations.
- [shopping_list/data/models/shopping_item_dto.dart](../lib/features/shopping_list/data/models/shopping_item_dto.dart) — DTO model handling JSON serialization and entity conversion.
- [shopping_list/data/models/shopping_list_dto.dart](../lib/features/shopping_list/data/models/shopping_list_dto.dart) — DTO model for shopping list JSON serialization.
- [shopping_list/data/datasources/shopping_list_local_datasource.dart](../lib/features/shopping_list/data/datasources/shopping_list_local_datasource.dart) — Local data source interface and in-memory cache implementation.
- [shopping_list/data/repositories/shopping_list_repository_impl.dart](../lib/features/shopping_list/data/repositories/shopping_list_repository_impl.dart) — Concrete repository implementation mapping DTOs to Domain Entities.

**Dependencies** — Depends on [[core|Core Infrastructure]] (`Failure`, `Result`) for error handling.

**Flow** —
```mermaid
flowchart TD
    RepoImpl[ShoppingListRepositoryImpl] --> LocalDS[ShoppingListLocalDataSource]
    RepoImpl --> ItemDto[ShoppingItemDto]
    ItemDto --> ItemEntity[ShoppingItem Entity]
    RepoImpl --> ListDto[ShoppingListDto]
    ListDto --> ListEntity[ShoppingList Entity]
```

**Notes / gotchas** —
> [!info] Data Source Implementation
> Currently uses an in-memory local data source (`InMemoryShoppingListLocalDataSource`) for Sprint 1 framework scaffolding. Will be extended with local persistent storage in future iterations.
