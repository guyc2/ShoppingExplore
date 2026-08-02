---
tags: [module, authentication, clean-architecture, mvvm]
aliases: [Authentication Module, Auth Feature]
---
# Authentication Module

> [!info]
> Governs user authentication, current session state, and user identity across ShoppingExplore.

## Architecture & Layers

```mermaid
graph LR
    subgraph Domain [Domain Layer - lib/features/auth/domain]
        UserEntity[User Entity]
        AuthRepo[AuthRepository Interface]
        LoginUC[LoginUseCase]
        RegisterUC[RegisterUseCase]
        LogoutUC[LogoutUseCase]
        GetUC[GetCurrentUserUseCase]
    end

    subgraph Data [Data Layer - lib/features/auth/data]
        UserDto[UserDto]
        LocalDS[AuthLocalDataSource]
        AuthRepoImpl[AuthRepositoryImpl]
    end

    subgraph Presentation [Presentation Layer - lib/features/auth/presentation]
        AuthCtrl[AuthController - ChangeNotifier]
        LoginView[LoginView - Dialog Modal]
        AuthBtn[AuthUserButton - App Bar Widget]
    end

    AuthRepoImpl -->|Implements| AuthRepo
    AuthRepoImpl --> LocalDS
    AuthCtrl --> LoginUC
    AuthCtrl --> RegisterUC
    AuthCtrl --> LogoutUC
    AuthCtrl --> GetUC
    LoginView --> AuthCtrl
    AuthBtn --> AuthCtrl
```

## Key Components

1. **Domain Entities & UseCases**:
   - **`User`**: Immutable entity containing `id`, `email`, `displayName`, and `createdAt`.
   - **`AuthRepository`**: Pure Dart contract for authentication operations returning typed `Result<T>`.
   - **UseCases**: Single-responsibility actions (`LoginUseCase`, `RegisterUseCase`, `LogoutUseCase`, `GetCurrentUserUseCase`).

2. **Data Source & Repository Implementation**:
   - **`AuthLocalDataSource`**: Provides local/in-memory user authentication and session caching.
   - **`AuthRepositoryImpl`**: Implements domain repository contract with centralized `AppLogger` telemetry and typed `Failure` mapping.

3. **Presentation & State**:
   - **`AuthController`**: `ChangeNotifier` managing `AuthState` (`AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthError`).
   - **`LoginView`**: Material 3 modal dialog allowing login and registration.
   - **`AuthUserButton`**: Responsive header button displaying current user avatar or sign-in prompt.
