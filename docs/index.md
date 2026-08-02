---
tags: [map-of-content, index, architecture, process]
aliases: [Index, System Map]
---
# ShoppingExplore — System Documentation Map

Overview of the **ShoppingExplore** cross-platform mobile application architecture, module map, and feature relationships.

## System Overview
ShoppingExplore is structured around Clean Architecture and Layered MVVM principles in Flutter. The application separates shared technical foundation components ([[core|Core Infrastructure]]) from feature-specific domain modules (such as [[catalog|Catalog Module]]). All features follow a strict [[workflow|Sprint Execution Workflow]].

## Top-Level System Architecture

```mermaid
graph TD
    AppEntry[App Main / Entry Point (inferred)] --> CatalogModule[Catalog Module]
    CatalogModule --> CoreModule[Core Infrastructure Module]

    subgraph Catalog [Catalog Feature]
        CatalogUI[Presentation Layer] --> CatalogLogic[Domain Layer]
        CatalogData[Data Layer] --> CatalogLogic
    end

    subgraph Core [Core Infrastructure]
        CoreNet[Network Client]
        CoreTheme[Theme & Tokens]
        CoreError[Error Handling]
    end

    CatalogData --> CoreNet
    CatalogUI --> CoreTheme
```

## Module Notes Directory
- [[core|Core Infrastructure]] — Shared network client, theme tokens, error definitions, and utility helpers.
- [[catalog|Catalog Module]] — Product catalog business entities, data sources, repositories, and UI view controllers.
- [[shopping_list|Shopping List Module]] — Advanced shopping list domain entities, rich item attributes, DTOs, and repository implementations.
- [[workflow|Development & Sprint Workflow]] — Mandatory architecture and maintenance governance, sprint planning, multi-agent code reviews, testing subagent rules, and execution gates.



## Feature Implementation Plans
- [[plans/advanced_shopping_list_plan|Advanced Shopping List Plan]] — Saved 3-sprint implementation plan for the Advanced Shopping List feature framework.
