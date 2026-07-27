---
tags: [core, infrastructure, network, theme, error-handling, skills]
aliases: [Core, Infrastructure]
---
# Core Infrastructure

**Purpose** — Provides foundational shared capabilities including API network clients, Material 3 design tokens, typography, and unified domain failure definitions across the application. It establishes the technical baseline used by all domain feature modules.

**Key files** —
- [core/error/](../lib/core/error) — Defines standard domain failure classes and error handling models.
- [core/network/](../lib/core/network) — Houses the HTTP REST client wrapper and request interceptors (inferred).
- [core/theme/](../lib/core/theme) — Material 3 theme configuration, color tokens, and Google Fonts typography.
- [core/utils/](../lib/core/utils) — Shared extensions, formatters, and utility helpers (inferred).
- [.agents/skills/review-pr/](../.agents/skills/review-pr/SKILL.md) — PR review skill for security, migration risk, and test coverage auditing.

**Dependencies** — Used by feature modules like [[catalog|Catalog Module]]. Requires external packages defined in [pubspec.yaml](../pubspec.yaml) such as `google_fonts` and `cupertino_icons`.

**Flow** —
```mermaid
flowchart TD
    Feature[Feature Module UI / Controller] --> CoreError[Core Error Models]
    Feature --> CoreTheme[Core Theme Tokens]
    FeatureData[Feature Data Repository] --> CoreNet[Core Network Client]
    CoreNet --> RemoteAPI[External REST API (inferred)]
```

**Notes / gotchas** —
> [!info] Architectural Boundary & Skills
> Core infrastructure must remain independent of feature-specific business logic. Project skills (such as `review-pr`, `local-pc-environment`, `shopping-explore-guidelines`) are maintained under `.agents/skills/` and registered via `.agents/skills.json`.
