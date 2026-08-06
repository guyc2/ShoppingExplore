---
tags: [map-of-content, index, architecture, process]
aliases: [Index, System Map]
---
# ShoppingExplore — System Documentation Map

Overview of the **ShoppingExplore** cross-platform mobile application architecture, module map, and feature relationships.

## System Overview
ShoppingExplore is structured around Clean Architecture and Layered MVVM principles in Flutter. The application separates shared technical foundation components ([[core|Core Infrastructure]]) from feature-specific domain modules (such as [[catalog|Catalog Module]], [[auth|Authentication Module]], and [[shopping_list|Shopping List Module]]). All features follow a strict [[workflow|Sprint Execution Workflow]].

> [!IMPORTANT] Mandatory Bilingual Localization Policy
> Every feature, UI component, additional development, and update MUST support both Hebrew (`'he'`, with full RTL layout directionality) and English (`'en'`) using ARB translations in `lib/l10n/`.

## Top-Level System Architecture


```mermaid
graph TD
    AppEntry[App Main / Entry Point (inferred)] --> CatalogModule[Catalog Module]
    AppEntry --> AuthModule[Authentication Module]
    AppEntry --> ShoppingListModule[Shopping List Module]

    CatalogModule --> CoreModule[Core Infrastructure Module]
    AuthModule --> CoreModule
    ShoppingListModule --> CoreModule
    ShoppingListModule --> AuthModule

    subgraph Auth [Authentication Feature]
        AuthUI[Presentation Layer] --> AuthLogic[Domain Layer]
        AuthData[Data Layer] --> AuthLogic
    end

    subgraph ShoppingList [Shopping List Feature]
        ListUI[Presentation Layer] --> ListLogic[Domain Layer]
        ListData[Data Layer] --> ListLogic
    end

    subgraph Core [Core Infrastructure]
        CoreNet[Network Client]
        CoreTheme[Theme & Tokens]
        CoreError[Error Handling]
    end

    AuthData --> CoreNet
    AuthUI --> CoreTheme
    ListData --> CoreNet
    ListUI --> CoreTheme
```

## Module Notes Directory
- [[core|Core Infrastructure]] — Shared network client, theme tokens, error definitions, localization (`l10n`, RTL support), image storage services (`image_picker`, `path_provider`), and utility helpers.
- [[auth|Authentication Module]] — User authentication domain entities, login/registration usecases, local/remote data sources seeded with Debug User **Guy C**, Account & Profile modal with live statistics, and UI view controllers wired at the composition root (`app.dart`).
- [[catalog|Catalog Module]] — Product catalog business entities, data sources, repositories, and UI view controllers.
- [[shopping_list|Shopping List Module]] — Stylish multi-list dashboard with greeting banner, responsive card grid (`ShoppingListCard`), Shopping Cart brand icon, `CreateShoppingListModal`, `ShoppingListDetailView` with metadata header and 2-section Active Shopping Mode checklist, real-time reactive sync streams (`watchShoppingLists`, `watchShoppingList`) with automatic live sync, collaborative sharing, item assignment, product suggestion images (camera/gallery integration via local storage), and CRUD use cases.
- [[workflow|Development & Sprint Workflow]] — Mandatory architecture and maintenance governance, sprint planning, multi-agent code reviews, testing subagent rules, and execution gates.

## Feature Implementation Plans
- [[plans/advanced_shopping_list_plan|Advanced Shopping List Plan]] — Implementation plan for the Advanced Shopping List feature framework including Sprint 4 Collaborative Sharing & Authentication.
- [[plans/next_phase_collaborative_shopping_plan|Next Phase Collaborative Shopping Plan]] — Roadmap for Real-Time Collaborative Shopping, Personal Profile Editing, Persistent Auth ("Remember Me"), Two-Section List Layout, and Multi-User Location Presence.

