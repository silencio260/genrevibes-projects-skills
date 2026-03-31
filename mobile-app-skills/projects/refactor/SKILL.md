---
name: Refactor Existing Project
description: Step-by-step guide for refactoring an existing Flutter project to Clean Architecture + BLoC + Starter Kit
---

# Refactor Existing Project

## Overview

This skill provides a systematic approach to refactoring any existing Flutter project to match the GenRevibes Clean Architecture pattern with BLoC state management and Starter Kit integration.

## Phase 1: Audit Current Structure

1. **Inventory features** — List all screens and their functionality
2. **Identify data sources** — APIs, databases, local storage
3. **Map dependencies** — Third-party packages in `pubspec.yaml`
4. **Assess state management** — Current approach (setState, Provider, etc.)
5. **Check for hardcoded values** — Strings, colors, API keys

## Phase 2: Create Clean Architecture Folders

Create the target structure without moving code yet:

```
lib/
├── main.dart
├── bloc_observer.dart
└── src/
    ├── config/
    │   ├── routes_manager.dart
    │   └── theme_manager.dart
    ├── core/
    │   ├── api/
    │   │   ├── interceptors.dart
    │   │   ├── response_code.dart
    │   │   └── response_message.dart
    │   ├── error/
    │   │   ├── error_handler.dart
    │   │   └── failure.dart
    │   ├── helpers/
    │   │   └── dio_helper.dart
    │   ├── network/
    │   │   └── network_info.dart
    │   ├── usecase/
    │   │   └── base_usecase.dart
    │   ├── utils/
    │   │   ├── app_assets.dart
    │   │   ├── app_colors.dart
    │   │   ├── app_constants.dart
    │   │   ├── app_enums.dart
    │   │   ├── app_strings.dart
    │   │   ├── font_manager.dart
    │   │   └── styles_manager.dart
    │   └── widgets/
    ├── features/
    │   └── {each_feature}/
    │       ├── {feature}_injector.dart
    │       ├── data/
    │       │   ├── datasources/remote/
    │       │   ├── models/
    │       │   └── repositories/
    │       ├── domain/
    │       │   ├── entities/
    │       │   ├── repositories/
    │       │   ├── usecases/
    │       │   └── mappers.dart
    │       └── presentation/
    │           ├── bloc/{feature}_bloc/
    │           ├── screens/
    │           └── widgets/
    ├── container_injector.dart
    └── my_app.dart
```

## Phase 3: Set Up Core Infrastructure

1. **Copy core files** from template or create fresh:
   - `base_usecase.dart` with `Either<Failure, Output>`
   - `failure.dart` with all failure types
   - `error_handler.dart` for exception → Failure conversion
   - `network_info.dart` for connectivity
   - `dio_helper.dart` for HTTP client

2. **Set up DI container** in `container_injector.dart`
3. **Set up BLoC observer** in `bloc_observer.dart`

## Phase 4: Migrate Features One at a Time

For each feature (start with the simplest):

1. **Create domain layer first**:
   - Extract entities from existing models (remove framework dependencies)
   - Define repository interfaces
   - Create use cases (one per operation)
   - Add mappers

2. **Create data layer**:
   - Create models that extend entities (add JSON serialization)
   - Create data source abstractions and implementations
   - Implement repositories (with network check + error handling)

3. **Create presentation layer**:
   - Create BLoC with events and states
   - Refactor screens to use `BlocBuilder`/`BlocListener`
   - Extract reusable widgets

4. **Wire up DI**:
   - Create feature injector (`{feature}_injector.dart`)
   - Register in main container
   - Provide BLoC in `MultiBlocProvider`

5. **Add routes** in `routes_manager.dart`

## Phase 5: Integrate Starter Kit

1. Copy `packages/starter_kit/` into project
2. Add path dependency in `pubspec.yaml`
3. Initialize in `main.dart` (see `starter-kit/SKILL.md`)
4. Set up env files (copy from `agents/templates/env/`)
5. Set up IDE configs (copy from `agents/templates/.run/` and `.vscode/`)

## Phase 6: Extract Strings & Constants

1. Move hardcoded strings to `AppStrings` and feature string classes
2. Move colors to `AppColors`
3. Move text styles to `StylesManager`
4. Move API keys to env config

## Phase 7: Verify

- [ ] All features follow Clean Architecture layers
- [ ] All state management uses BLoC
- [ ] All DI uses GetIt with feature injectors
- [ ] All errors use Either<Failure, T> pattern
- [ ] All routes go through AppRouter
- [ ] Starter Kit initialized with required features
- [ ] No hardcoded strings, colors, or API keys
- [ ] Env configs for dev, release, special dev
- [ ] IDE run configs for all environments

## Common Pitfalls

- **Don't refactor everything at once** — migrate one feature at a time
- **Domain layer has zero framework dependencies** — no Flutter imports in entities
- **BLoCs are factories, not singletons** — register with `registerFactory`
- **Repositories, data sources, use cases are lazy singletons**
- **Always check network before remote calls**
- **Models extend entities** — entities are framework-agnostic
