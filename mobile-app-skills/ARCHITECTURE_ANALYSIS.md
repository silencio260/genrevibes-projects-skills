# Comprehensive Software Engineering Analysis: TikTok Video Downloader Project

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture Pattern](#architecture-pattern)
3. [Technology Stack](#technology-stack)
4. [Dependency Injection](#dependency-injection)
5. [Project Structure](#project-structure)
6. [Core Components](#core-components)
7. [Feature Architecture](#feature-architecture)
8. [Best Practices & Conventions](#best-practices--conventions)
9. [Error Handling Strategy](#error-handling-strategy)
10. [Network Layer Architecture](#network-layer-architecture)
11. [State Management](#state-management)
12. [Configuration Management](#configuration-management)
13. [Starter Kit System](#starter-kit-system)
14. [Implementation Guidelines](#implementation-guidelines)
15. [Localization & Internationalization](#localization--internationalization)

---

## Project Overview

**Platform**: Flutter (Cross-platform mobile application)  
**Language**: Dart 3.7.0+  
**Architecture**: Clean Architecture with Feature-Based Organization  
**State Management**: BLoC (Business Logic Component) Pattern  
**Dependency Injection**: GetIt (Service Locator Pattern)

This project demonstrates a production-ready Flutter application following Clean Architecture principles, ensuring separation of concerns, testability, and maintainability.

---

## Architecture Pattern

### Clean Architecture Implementation

The project follows **Clean Architecture** (also known as Hexagonal Architecture) with clear separation into three main layers:

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (UI, BLoC, Widgets, Screens)          │
├─────────────────────────────────────────┤
│          DOMAIN LAYER                    │
│  (Entities, Use Cases, Repository       │
│   Interfaces, Business Logic)           │
├─────────────────────────────────────────┤
│           DATA LAYER                     │
│  (Models, Data Sources, Repository       │
│   Implementations, External APIs)        │
└─────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. **Presentation Layer** (`presentation/`)
- **Purpose**: Handles UI rendering and user interactions
- **Components**:
  - `screens/`: Full-screen UI components
  - `widgets/`: Reusable UI components
  - `bloc/`: State management (BLoC pattern)
    - `*_bloc.dart`: Business logic handler
    - `*_event.dart`: User actions/events
    - `*_state.dart`: UI state representations

#### 2. **Domain Layer** (`domain/`)
- **Purpose**: Contains business logic and rules (framework-independent)
- **Components**:
  - `entities/`: Pure business objects (no framework dependencies)
  - `repositories/`: Abstract repository interfaces
  - `usecases/`: Single-purpose business operations
  - `mappers.dart`: Domain mapping extensions

#### 3. **Data Layer** (`data/`)
- **Purpose**: Handles data retrieval and persistence
- **Components**:
  - `datasources/`: Data source implementations (remote, local)
  - `models/`: Data transfer objects (DTOs) with JSON serialization
  - `repositories/`: Repository implementations

### Dependency Rule

**Critical Principle**: Dependencies flow inward only!
- Presentation → Domain ← Data
- Domain has **zero dependencies** on Presentation or Data layers
- Data depends on Domain (implements Domain interfaces)
- Presentation depends on Domain (uses Domain entities and use cases)

---

## Technology Stack

### Core Framework & Language
- **Flutter SDK**: Latest stable (3.7.0+)
- **Dart**: 3.7.0+
- **Platform Support**: Android, iOS, Web, Windows, Linux, macOS

### State Management
- **flutter_bloc**: ^9.1.1 - BLoC pattern implementation
- **equatable**: ^2.0.7 - Value equality for state/event objects

### Dependency Injection
- **get_it**: ^9.2.0 - Service locator for dependency injection

### Functional Programming
- **dartz**: ^0.10.1 - Functional programming utilities (Either, Option)

### Networking
- **dio**: ^5.9.0 - HTTP client with interceptors
- **internet_connection_checker**: ^1.0.0+1 - Network connectivity checking

### Media & Storage
- **video_player**: ^2.10.1 - Video playback
- **chewie**: ^1.13.0 - Video player UI wrapper
- **video_thumbnail**: ^0.5.6 - Video thumbnail generation
- **path_provider**: ^2.1.5 - File system paths
- **permission_handler**: ^12.0.1 - Runtime permissions
- **gal**: ^2.3.2 - Gallery/media access
- **share_plus**: ^12.0.1 - Share functionality

### Utilities
- **shared_preferences**: ^2.5.4 - Local key-value storage
- **fluttertoast**: ^9.0.0 - Toast notifications
- **device_info_plus**: ^12.3.0 - Device information

### Business Logic Libraries
- **tiktok_scraper**: ^0.1.0 - TikTok video scraping

### Starter Kit Dependencies
- **firebase_core**: ^3.11.0
- **firebase_analytics**: ^11.4.2
- **firebase_crashlytics**: ^4.3.10
- **firebase_remote_config**: ^5.4.4
- **posthog_flutter**: ^5.5.0
- **google_mobile_ads**: ^6.0.0
- **purchases_flutter**: ^9.10.3 (RevenueCat)
- **in_app_review**: ^2.0.11
- **url_launcher**: ^6.3.1
- **uuid**: ^3.0.7

### Development Tools
- **flutter_lints**: ^5.0.0 - Linting rules
- **flutter_launcher_icons**: ^0.13.1 - App icon generation

---

## Dependency Injection

### GetIt Service Locator Pattern

The project uses **GetIt** as the dependency injection container. This follows the Service Locator pattern (not pure DI, but practical for Flutter).

### Container Structure

#### Main Container (`container_injector.dart`)
```dart
final sl = GetIt.instance;  // Service Locator singleton

void initApp() {
  initCore();           // Core dependencies
  initDownloader();     // Feature-specific dependencies
  // ... other feature initializations
}
```

#### Registration Types

1. **Lazy Singleton** (`registerLazySingleton`)
   - Created on first access
   - Single instance throughout app lifecycle
   - Used for: Repositories, Data Sources, Network clients

2. **Factory** (`registerFactory`)
   - New instance on every access
   - Used for: BLoCs (stateful, should be recreated)

### Dependency Registration Pattern

```dart
// 1. Data Sources (Lowest level)
sl.registerLazySingleton<TiktokVideoBaseRemoteDataSource>(
  () => TiktokVideoRemoteDataSource(dioHelper: sl()),
);

// 2. Repositories (Depends on Data Sources)
sl.registerLazySingleton<TiktokVideoBaseRepo>(
  () => TiktokVideoRepo(remoteDataSource: sl(), networkInfo: sl()),
);

// 3. Use Cases (Depends on Repositories)
sl.registerLazySingleton<GetVideoUseCase>(
  () => GetVideoUseCase(videoRepo: sl()),
);

// 4. BLoCs (Depends on Use Cases) - Factory for stateful instances
sl.registerFactory(
  () => DownloaderBloc(getVideoUseCase: sl(), saveVideoUseCase: sl()),
);
```

### Feature-Specific Injectors

Each feature has its own injector function:
- `initDownloader()` - TikTok downloader feature
- `initAds()` - Ads feature (in starter kit)
- `initAnalytics()` - Analytics feature (in starter kit)
- `initIap()` - In-App Purchases (in starter kit)

**Best Practice**: Keep feature dependencies isolated in their own injector functions.

---

## Project Structure

### Root Directory Layout

```
tiktok_video_downloader/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── bloc_observer.dart           # Global BLoC observer
│   ├── src/                         # Main source code
│   │   ├── config/                  # App configuration
│   │   ├── core/                    # Core/shared components
│   │   ├── features/                # Feature modules
│   │   ├── container_injector.dart  # DI container setup
│   │   └── my_app.dart              # Root widget
│   └── starter_kit/                 # Reusable starter kit
├── android/                         # Android platform code
├── ios/                            # iOS platform code
├── web/                            # Web platform code
├── windows/                        # Windows platform code
├── linux/                          # Linux platform code
├── macos/                          # macOS platform code
├── assets/                         # Static assets
├── test/                           # Unit/widget tests
├── pubspec.yaml                    # Dependencies
└── analysis_options.yaml           # Linting rules
```

### Core Directory Structure (`lib/src/core/`)

```
core/
├── api/                            # API configuration
│   ├── interceptors.dart          # Dio interceptors
│   ├── response_code.dart         # HTTP response codes
│   └── response_message.dart      # Response messages
├── error/                          # Error handling
│   ├── error_handler.dart         # Error handler implementation
│   └── failure.dart               # Failure classes (domain errors)
├── helpers/                        # Utility helpers
│   ├── dio_helper.dart            # Dio wrapper
│   ├── dir_helper.dart            # Directory operations
│   └── permissions_helper.dart    # Permission handling
├── network/                        # Network utilities
│   └── network_info.dart          # Connectivity checker
├── usecase/                        # Base use case
│   └── base_usecase.dart          # Abstract use case
├── utils/                          # App-wide utilities
│   ├── app_assets.dart            # Asset paths
│   ├── app_colors.dart            # Color constants
│   ├── app_constants.dart         # App constants
│   ├── app_enums.dart             # Enumerations
│   ├── app_strings.dart           # String constants
│   ├── font_manager.dart          # Font definitions
│   └── styles_manager.dart        # Text styles
└── widgets/                        # Reusable widgets
    ├── build_toast.dart
    ├── center_indicator.dart
    └── custom_elevated_btn.dart
```

### Config Directory (`lib/src/config/`)

```
config/
├── routes_manager.dart            # Route definitions & navigation
└── theme_manager.dart             # Theme configuration
```

### Feature Directory Structure (`lib/src/features/`)

Each feature follows this structure:

```
features/
└── {feature_name}/
    ├── {feature_name}_injector.dart  # Feature DI setup
    ├── data/
    │   ├── datasources/
    │   │   └── remote/              # Remote data sources
    │   ├── models/                  # Data models (DTOs)
    │   └── repositories/            # Repository implementations
    ├── domain/
    │   ├── entities/                # Domain entities
    │   ├── repositories/            # Repository interfaces
    │   ├── usecases/                # Use cases
    │   └── mappers.dart             # Domain mappers
    └── presentation/
        ├── bloc/                    # BLoC state management
        │   └── {feature}_bloc/
        │       ├── {feature}_bloc.dart
        │       ├── {feature}_event.dart
        │       └── {feature}_state.dart
        ├── screens/                 # Full-screen widgets
        └── widgets/                 # Feature-specific widgets
```

---

## Core Components

### 1. Base Use Case (`core/usecase/base_usecase.dart`)

**Purpose**: Abstract base class for all use cases

```dart
abstract class BaseUseCase<Output, Input> {
  Future<Either<Failure, Output>> call(Input params);
}
```

**Characteristics**:
- Uses `dartz` `Either<Failure, Output>` for functional error handling
- Generic types: `Output` (success result), `Input` (parameters)
- `NoParams` singleton for use cases without parameters

**Usage Pattern**:
```dart
class GetVideoUseCase extends BaseUseCase<TikTokVideo, String> {
  final TiktokVideoBaseRepo videoRepo;
  
  GetVideoUseCase({required this.videoRepo});
  
  @override
  Future<Either<Failure, TikTokVideo>> call(String params) async {
    return await videoRepo.getVideo(params);
  }
}
```

### 2. Failure Classes (`core/error/failure.dart`)

**Purpose**: Domain-level error representation

**Failure Types**:
- `BadRequestFailure` (400)
- `ServerFailure` (500)
- `NotFoundFailure` (404)
- `NoInternetConnectionFailure`
- `UnexpectedFailure`
- `ConnectTimeOutFailure`
- `CancelRequestFailure`
- `TooManyRequestsFailure` (429)
- `NotSubscribedFailure` (403)

**Characteristics**:
- Extends `Equatable` for value equality
- Immutable with `const` constructors
- Messages from `ResponseMessage` constants

### 3. Error Handler (`core/error/error_handler.dart`)

**Purpose**: Centralized error handling and conversion

**Responsibilities**:
- Converts exceptions to `Failure` objects
- Handles `DioException` types
- Maps HTTP status codes to appropriate failures
- Handles `SocketException` (network issues)

**Pattern**:
```dart
try {
  // Operation
} catch (error) {
  return Left(ErrorHandler.handle(error).failure);
}
```

### 4. Network Info (`core/network/network_info.dart`)

**Purpose**: Abstract network connectivity checking

**Implementation**:
- Abstract interface: `NetworkInfo`
- Implementation: `NetworkInfoImpl` using `InternetConnectionChecker`
- Used in repositories to check connectivity before API calls

### 5. Dio Helper (`core/helpers/dio_helper.dart`)

**Purpose**: Wrapper around Dio HTTP client

**Features**:
- Pre-configured headers (User-Agent, Accept, etc.)
- Timeout configuration (30 seconds)
- Interceptor setup (Logging, App interceptors)
- Download method with progress callback
- Special handling for TikTok CDN links

### 6. App Interceptors (`core/api/interceptors.dart`)

**Purpose**: Request/response/error logging

**Features**:
- Logs all HTTP requests
- Logs all HTTP responses
- Logs all HTTP errors
- Uses `debugPrint` for Flutter debugging

---

## Feature Architecture

### Complete Feature Example: TikTok Downloader

#### 1. Domain Layer

**Entities** (`domain/entities/`):
```dart
// Pure business objects - no framework dependencies
class TikTokVideo extends Equatable {
  final int code;
  final String msg;
  final double processedTime;
  final VideoData? videoData;
  // ... constructors, props
}
```

**Repository Interface** (`domain/repositories/`):
```dart
abstract class TiktokVideoBaseRepo {
  Future<Either<Failure, TikTokVideo>> getVideo(String videoLink);
  Future<Either<Failure, String>> saveVideo({...});
}
```

**Use Cases** (`domain/usecases/`):
```dart
class GetVideoUseCase extends BaseUseCase<TikTokVideo, String> {
  // Implementation
}

class SaveVideoUseCase extends BaseUseCase<String, SaveVideoParams> {
  // Implementation
}
```

**Mappers** (`domain/mappers.dart`):
```dart
extension TiktokVideoExtension on TiktokVideoModel {
  TikTokVideo toDomain() => TikTokVideo(...);
}
```

#### 2. Data Layer

**Models** (`data/models/`):
```dart
class TiktokVideoModel extends TikTokVideo {
  // Extends domain entity
  // Includes JSON serialization
  factory TiktokVideoModel.fromJson(Map<String, dynamic> json) {...}
}
```

**Data Source** (`data/datasources/remote/`):
```dart
abstract class TiktokVideoBaseRemoteDataSource {
  Future<TiktokVideoModel> getVideo(String videoLink);
  Future<String> saveVideo({...});
}

class TiktokVideoRemoteDataSource implements TiktokVideoBaseRemoteDataSource {
  // Implementation using external APIs
}
```

**Repository Implementation** (`data/repositories/`):
```dart
class TiktokVideoRepo implements TiktokVideoBaseRepo {
  final TiktokVideoBaseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  @override
  Future<Either<Failure, TikTokVideo>> getVideo(String videoLink) async {
    if (!await networkInfo.isConnected) {
      return const Left(NoInternetConnectionFailure());
    }
    try {
      final TiktokVideoModel video = await remoteDataSource.getVideo(videoLink);
      return Right(video.toDomain());  // Convert to domain entity
    } catch (error) {
      return Left(ErrorHandler.handle(error).failure);
    }
  }
}
```

#### 3. Presentation Layer

**BLoC** (`presentation/bloc/downloader_bloc/`):
```dart
class DownloaderBloc extends Bloc<DownloaderEvent, DownloaderState> {
  final GetVideoUseCase getVideoUseCase;
  final SaveVideoUseCase saveVideoUseCase;
  
  DownloaderBloc({required this.getVideoUseCase, required this.saveVideoUseCase})
      : super(DownloaderInitial()) {
    on<DownloaderGetVideo>(_getVideo);
    on<DownloaderSaveVideo>(_saveVideo);
    // ... other handlers
  }
  
  Future<void> _getVideo(
    DownloaderGetVideo event,
    Emitter<DownloaderState> emit,
  ) async {
    emit(const DownloaderGetVideoLoading());
    final result = await getVideoUseCase(event.videoLink);
    result.fold(
      (failure) => emit(DownloaderGetVideoFailure(failure.message)),
      (video) => emit(DownloaderGetVideoSuccess(video)),
    );
  }
}
```

**Events** (`downloader_event.dart`):
```dart
abstract class DownloaderEvent extends Equatable {
  const DownloaderEvent();
}

class DownloaderGetVideo extends DownloaderEvent {
  final String videoLink;
  // ... props
}
```

**States** (`downloader_state.dart`):
```dart
abstract class DownloaderState extends Equatable {
  const DownloaderState();
}

class DownloaderGetVideoLoading extends DownloaderState {}
class DownloaderGetVideoSuccess extends DownloaderState {
  final TikTokVideo tikTokVideo;
  // ... props
}
class DownloaderGetVideoFailure extends DownloaderState {
  final String message;
  // ... props
}
```

**Screens** (`presentation/screens/`):
```dart
class DownloaderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloaderBloc, DownloaderState>(
      builder: (context, state) {
        // Handle different states
        if (state is DownloaderGetVideoLoading) {
          return LoadingWidget();
        } else if (state is DownloaderGetVideoSuccess) {
          return VideoPreviewWidget(video: state.tikTokVideo);
        }
        // ... other states
      },
    );
  }
}
```

---

## Best Practices & Conventions

### 1. Naming Conventions

- **Files**: snake_case (`downloader_bloc.dart`)
- **Classes**: PascalCase (`DownloaderBloc`)
- **Variables/Functions**: camelCase (`getVideoUseCase`)
- **Constants**: camelCase with static (`AppStrings.downloadSuccess`)
- **Private Members**: Leading underscore (`_getVideo`)

### 2. File Organization

- **One class per file** (except for BLoC part files)
- **Part files** for BLoC events/states:
  ```dart
  // downloader_bloc.dart
  part 'downloader_event.dart';
  part 'downloader_state.dart';
  ```

### 3. Dependency Injection Conventions

- **Abstract interfaces** end with `Base` suffix:
  - `TiktokVideoBaseRepo`
  - `TiktokVideoBaseRemoteDataSource`
- **Implementations** use descriptive names:
  - `TiktokVideoRepo`
  - `TiktokVideoRemoteDataSource`

### 4. Error Handling Pattern

**Always use Either pattern**:
```dart
Future<Either<Failure, Output>> someOperation() async {
  try {
    // Success path
    return Right(result);
  } catch (error) {
    // Error path
    return Left(ErrorHandler.handle(error).failure);
  }
}
```

**In BLoC**:
```dart
final result = await useCase(params);
result.fold(
  (failure) => emit(ErrorState(failure.message)),
  (success) => emit(SuccessState(success)),
);
```

### 5. State Management Best Practices

- **Immutable states** using `Equatable`
- **Separate events** for different user actions
- **Granular states** for different UI scenarios
- **Loading states** before async operations
- **Error states** with user-friendly messages

### 6. Repository Pattern

- **Check network connectivity** before remote calls
- **Convert models to entities** before returning
- **Handle errors** and convert to `Failure`
- **Return `Either<Failure, T>`** for functional error handling

### 7. Use Case Pattern

- **Single responsibility** - one use case, one operation
- **No business logic in BLoC** - all logic in use cases
- **Use `NoParams`** for parameterless use cases
- **Extend `BaseUseCase<Output, Input>`**

### 8. Entity vs Model Pattern

- **Entities** (`domain/entities/`): Pure Dart classes, no JSON, framework-agnostic
- **Models** (`data/models/`): Extend entities, include JSON serialization, framework-specific

**Mapping Pattern**:
```dart
// Model extends Entity
class TiktokVideoModel extends TikTokVideo {
  // JSON serialization
}

// Extension for conversion
extension TiktokVideoExtension on TiktokVideoModel {
  TikTokVideo toDomain() => TikTokVideo(...);
}
```

---

## Error Handling Strategy

### Error Flow

```
Exception/Error
    ↓
ErrorHandler.handle()
    ↓
Failure (Domain Error)
    ↓
Either<Failure, Success>
    ↓
BLoC State (Error State)
    ↓
UI Error Display
```

### Error Types

1. **Network Errors**: `NoInternetConnectionFailure`, `ConnectTimeOutFailure`
2. **HTTP Errors**: `BadRequestFailure`, `NotFoundFailure`, `ServerFailure`
3. **Business Logic Errors**: `NotSubscribedFailure`, `TooManyRequestsFailure`
4. **Unexpected Errors**: `UnexpectedFailure`

### Error Handling in Repositories

```dart
@override
Future<Either<Failure, TikTokVideo>> getVideo(String videoLink) async {
  // 1. Check connectivity
  if (!await networkInfo.isConnected) {
    return const Left(NoInternetConnectionFailure());
  }
  
  try {
    // 2. Call data source
    final TiktokVideoModel video = await remoteDataSource.getVideo(videoLink);
    
    // 3. Convert to domain entity
    return Right(video.toDomain());
  } catch (error) {
    // 4. Handle and convert error
    return Left(ErrorHandler.handle(error).failure);
  }
}
```

---

## Network Layer Architecture

### Dio Configuration

**Base Configuration** (`DioHelper`):
- User-Agent header (mobile browser simulation)
- Accept headers
- 30-second timeouts (connect/receive)
- Status code validation (200-299)

**Interceptors**:
1. **LogInterceptor**: Logs all requests/responses/errors
2. **AppInterceptors**: Custom request/response/error logging

**Download Method**:
- Progress callback support
- Special headers for TikTok CDN links
- Referer and Origin headers for TikTok requests

### Network Info Abstraction

```dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;
  // Implementation
}
```

**Usage**: Always check connectivity before making API calls.

---

## State Management

### BLoC Pattern Implementation

**Components**:
1. **BLoC**: Business logic handler
2. **Events**: User actions/triggers
3. **States**: UI state representations

### BLoC Lifecycle

```dart
class DownloaderBloc extends Bloc<DownloaderEvent, DownloaderState> {
  DownloaderBloc({required this.getVideoUseCase})
      : super(DownloaderInitial()) {
    // Register event handlers
    on<DownloaderGetVideo>(_getVideo);
    
    // Initial operations
    add(LoadOldDownloads());
  }
}
```

### State Emission Pattern

```dart
Future<void> _getVideo(
  DownloaderGetVideo event,
  Emitter<DownloaderState> emit,
) async {
  // 1. Emit loading state
  emit(const DownloaderGetVideoLoading());
  
  // 2. Call use case
  final result = await getVideoUseCase(event.videoLink);
  
  // 3. Handle result
  result.fold(
    (failure) => emit(DownloaderGetVideoFailure(failure.message)),
    (success) => emit(DownloaderGetVideoSuccess(success)),
  );
}
```

### BLoC Observer

**Global Observer** (`bloc_observer.dart`):
- Logs BLoC creation
- Logs state changes
- Logs errors
- Logs BLoC disposal

**Usage**:
```dart
void main() {
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}
```

---

## Configuration Management

### Routes Manager (`config/routes_manager.dart`)

**Pattern**:
```dart
class Routes {
  static const String splash = "/splash";
  static const String downloader = "/downloader";
  // ... other routes
}

class AppRouter {
  static Route? getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      // ... other routes
    }
  }
}
```

**Usage**:
```dart
MaterialApp(
  initialRoute: Routes.splash,
  onGenerateRoute: AppRouter.getRoute,
)
```

### Theme Manager (`config/theme_manager.dart`)

**Features**:
- Centralized theme configuration
- Status bar styling
- Text theme configuration
- Button theme configuration
- Input decoration theme

### App Constants (`core/utils/`)

- **AppStrings**: All user-facing strings
- **AppColors**: Color constants
- **AppConstants**: App-wide constants
- **AppEnums**: Enumerations
- **FontManager**: Font weights and sizes
- **StylesManager**: Text style generators

---

## Starter Kit System

### Purpose

The `starter_kit/` directory contains reusable, production-ready features that can be integrated into any Flutter app following the same architecture.

### Features Included

1. **IAP (In-App Purchases)**
   - RevenueCat integration
   - Subscription management
   - Purchase restoration
   - Clean Architecture implementation

2. **Ads**
   - AdMob integration
   - Interstitial ads
   - Rewarded ads
   - Banner ads
   - BLoC-based state management

3. **Analytics**
   - Firebase Analytics
   - PostHog integration
   - Unified event logging
   - Ad revenue tracking

4. **Services**
   - Remote Config (Firebase)
   - GDPR compliance
   - App Rating (in-app review)
   - Feedback system

5. **UI Templates**
   - Onboarding screens
   - Settings screens

### Starter Kit Structure

```
starter_kit/
├── core/                    # Shared starter kit core
├── features/                # Feature modules
│   ├── ads/
│   ├── analytics/
│   ├── iap/
│   ├── onboarding/
│   ├── services/
│   └── settings/
├── starter_kit.dart         # Main entry point
└── README.md               # Documentation
```

### Integration Pattern

Each starter kit feature follows the same Clean Architecture pattern:
- Domain layer (entities, repositories, use cases)
- Data layer (models, data sources, repository implementations)
- Presentation layer (BLoC, UI)
- Feature-specific injector

---

## Implementation Guidelines

### For New Engineers: How to Build Features in This Style

#### Step 1: Create Feature Structure

```
features/
└── your_feature/
    ├── your_feature_injector.dart
    ├── data/
    │   ├── datasources/
    │   │   └── remote/
    │   │       └── your_feature_remote_data_source.dart
    │   ├── models/
    │   │   └── your_feature_model.dart
    │   └── repositories/
    │       └── your_feature_repo.dart
    ├── domain/
    │   ├── entities/
    │   │   └── your_feature_entity.dart
    │   ├── repositories/
    │   │   └── your_feature_base_repo.dart
    │   ├── usecases/
    │   │   └── get_your_feature_usecase.dart
    │   └── mappers.dart
    └── presentation/
        ├── bloc/
        │   └── your_feature_bloc/
        │       ├── your_feature_bloc.dart
        │       ├── your_feature_event.dart
        │       └── your_feature_state.dart
        ├── screens/
        │   └── your_feature_screen.dart
        └── widgets/
            └── your_feature_widget.dart
```

#### Step 2: Implement Domain Layer First

1. **Create Entity** (`domain/entities/`):
```dart
class YourFeatureEntity extends Equatable {
  final String id;
  final String name;
  
  const YourFeatureEntity({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}
```

2. **Create Repository Interface** (`domain/repositories/`):
```dart
abstract class YourFeatureBaseRepo {
  Future<Either<Failure, YourFeatureEntity>> getFeature(String id);
}
```

3. **Create Use Case** (`domain/usecases/`):
```dart
class GetYourFeatureUseCase extends BaseUseCase<YourFeatureEntity, String> {
  final YourFeatureBaseRepo repo;
  
  GetYourFeatureUseCase({required this.repo});
  
  @override
  Future<Either<Failure, YourFeatureEntity>> call(String params) async {
    return await repo.getFeature(params);
  }
}
```

4. **Create Mapper** (`domain/mappers.dart`):
```dart
extension YourFeatureExtension on YourFeatureModel {
  YourFeatureEntity toDomain() => YourFeatureEntity(
    id: id,
    name: name,
  );
}
```

#### Step 3: Implement Data Layer

1. **Create Model** (`data/models/`):
```dart
class YourFeatureModel extends YourFeatureEntity {
  const YourFeatureModel({required super.id, required super.name});
  
  factory YourFeatureModel.fromJson(Map<String, dynamic> json) {
    return YourFeatureModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
```

2. **Create Data Source** (`data/datasources/remote/`):
```dart
abstract class YourFeatureBaseRemoteDataSource {
  Future<YourFeatureModel> getFeature(String id);
}

class YourFeatureRemoteDataSource implements YourFeatureBaseRemoteDataSource {
  final DioHelper dioHelper;
  
  YourFeatureRemoteDataSource({required this.dioHelper});
  
  @override
  Future<YourFeatureModel> getFeature(String id) async {
    final response = await dioHelper.get(path: '/feature/$id');
    return YourFeatureModel.fromJson(response.data);
  }
}
```

3. **Create Repository Implementation** (`data/repositories/`):
```dart
class YourFeatureRepo implements YourFeatureBaseRepo {
  final YourFeatureBaseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  YourFeatureRepo({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, YourFeatureEntity>> getFeature(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NoInternetConnectionFailure());
    }
    try {
      final model = await remoteDataSource.getFeature(id);
      return Right(model.toDomain());
    } catch (error) {
      return Left(ErrorHandler.handle(error).failure);
    }
  }
}
```

#### Step 4: Implement Presentation Layer

1. **Create Events** (`presentation/bloc/your_feature_bloc/your_feature_event.dart`):
```dart
part of 'your_feature_bloc.dart';

abstract class YourFeatureEvent extends Equatable {
  const YourFeatureEvent();
}

class GetYourFeature extends YourFeatureEvent {
  final String id;
  
  const GetYourFeature(this.id);
  
  @override
  List<Object?> get props => [id];
}
```

2. **Create States** (`presentation/bloc/your_feature_bloc/your_feature_state.dart`):
```dart
part of 'your_feature_bloc.dart';

abstract class YourFeatureState extends Equatable {
  const YourFeatureState();
}

class YourFeatureInitial extends YourFeatureState {
  @override
  List<Object?> get props => [];
}

class YourFeatureLoading extends YourFeatureState {
  @override
  List<Object?> get props => [];
}

class YourFeatureSuccess extends YourFeatureState {
  final YourFeatureEntity feature;
  
  const YourFeatureSuccess(this.feature);
  
  @override
  List<Object?> get props => [feature];
}

class YourFeatureFailure extends YourFeatureState {
  final String message;
  
  const YourFeatureFailure(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

3. **Create BLoC** (`presentation/bloc/your_feature_bloc/your_feature_bloc.dart`):
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/your_feature_entity.dart';
import '../../../../domain/usecases/get_your_feature_usecase.dart';

part 'your_feature_event.dart';
part 'your_feature_state.dart';

class YourFeatureBloc extends Bloc<YourFeatureEvent, YourFeatureState> {
  final GetYourFeatureUseCase getYourFeatureUseCase;
  
  YourFeatureBloc({required this.getYourFeatureUseCase})
      : super(YourFeatureInitial()) {
    on<GetYourFeature>(_getFeature);
  }
  
  Future<void> _getFeature(
    GetYourFeature event,
    Emitter<YourFeatureState> emit,
  ) async {
    emit(const YourFeatureLoading());
    final result = await getYourFeatureUseCase(event.id);
    result.fold(
      (failure) => emit(YourFeatureFailure(failure.message)),
      (feature) => emit(YourFeatureSuccess(feature)),
    );
  }
}
```

4. **Create Screen** (`presentation/screens/your_feature_screen.dart`):
```dart
class YourFeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YourFeatureBloc, YourFeatureState>(
      builder: (context, state) {
        if (state is YourFeatureLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is YourFeatureSuccess) {
          return Text(state.feature.name);
        } else if (state is YourFeatureFailure) {
          return Text('Error: ${state.message}');
        }
        return SizedBox.shrink();
      },
    );
  }
}
```

#### Step 5: Set Up Dependency Injection

1. **Create Feature Injector** (`your_feature_injector.dart`):
```dart
import '../../container_injector.dart';
import 'data/datasources/remote/your_feature_remote_data_source.dart';
import 'data/repositories/your_feature_repo.dart';
import 'domain/repositories/your_feature_base_repo.dart';
import 'domain/usecases/get_your_feature_usecase.dart';
import 'presentation/bloc/your_feature_bloc/your_feature_bloc.dart';

void initYourFeature() {
  // Data source
  sl.registerLazySingleton<YourFeatureBaseRemoteDataSource>(
    () => YourFeatureRemoteDataSource(dioHelper: sl()),
  );
  
  // Repository
  sl.registerLazySingleton<YourFeatureBaseRepo>(
    () => YourFeatureRepo(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Use case
  sl.registerLazySingleton<GetYourFeatureUseCase>(
    () => GetYourFeatureUseCase(repo: sl()),
  );
  
  // BLoC (factory for stateful instances)
  sl.registerFactory(
    () => YourFeatureBloc(getYourFeatureUseCase: sl()),
  );
}
```

2. **Register in Main Container** (`container_injector.dart`):
```dart
void initApp() {
  initCore();
  initDownloader();
  initYourFeature();  // Add your feature
}
```

3. **Provide BLoC in App** (`my_app.dart`):
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<DownloaderBloc>()),
        BlocProvider(create: (context) => sl<YourFeatureBloc>()),  // Add your BLoC
      ],
      child: MaterialApp(...),
    );
  }
}
```

#### Step 6: Add Routes

1. **Add Route Constant** (`config/routes_manager.dart`):
```dart
class Routes {
  // ... existing routes
  static const String yourFeature = "/yourFeature";
}
```

2. **Add Route Handler**:
```dart
class AppRouter {
  static Route? getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      // ... existing cases
      case Routes.yourFeature:
        return MaterialPageRoute(
          builder: (context) => const YourFeatureScreen(),
        );
    }
  }
}
```

### Checklist for New Features

- [ ] Domain layer complete (entities, repository interface, use cases, mappers)
- [ ] Data layer complete (models, data source, repository implementation)
- [ ] Presentation layer complete (BLoC, events, states, screens, widgets)
- [ ] Dependency injection set up (feature injector, registered in main container)
- [ ] BLoC provided in app (MultiBlocProvider)
- [ ] Routes configured (route constant, route handler)
- [ ] Error handling implemented (Either pattern, error states)
- [ ] Network connectivity checked in repository
- [ ] Loading states implemented
- [ ] Success states implemented
- [ ] Failure states implemented
- [ ] Code follows naming conventions
- [ ] Code follows file organization conventions

---

## Localization & Internationalization

### Overview

To support multiple languages and enable easy language switching, **all user-facing text must be centralized in dedicated text classes**. This practice ensures maintainability, consistency, and seamless localization implementation.

### Core Principle

**Never hardcode strings directly in UI code.** All text should be extracted into dedicated classes organized by feature or purpose.

### Text Organization Pattern

#### 1. App-Wide Strings (`core/utils/app_strings.dart`)

**Purpose**: Shared strings used across multiple features

```dart
class AppStrings {
  // App-wide strings
  static const String appName = "Tiktok downloader";
  static const String download = "Download";
  static const String downloading = "Downloading";
  static const String downloads = "Downloads";
  static const String downloadSuccess = "Download success";
  static const String downloadFall = "Download failed";
  static const String permissionsRequired = 
      "Permissions is required, Please accept permissions and try again";
  
  // Error messages
  static const String videoLinkRequired = "Video link is Required";
  
  // Navigation
  static const String oldDownloads = "Old Downloads";
}
```

#### 2. Feature-Specific Text Classes

**Pattern**: Each feature should have its own text class for all strings used within that feature.

**Location**: `features/{feature_name}/presentation/l10n/{feature_name}_strings.dart`

**Example Structure**:
```dart
// features/tiktok_downloader/presentation/l10n/downloader_strings.dart
class DownloaderStrings {
  // Screen titles
  static const String screenTitle = "Downloader";
  static const String downloadsScreenTitle = "My Downloads";
  
  // Input fields
  static const String videoLinkHint = "Paste link here...";
  static const String videoLinkLabel = "Video link";
  
  // Buttons
  static const String downloadButton = "Download";
  static const String retryButton = "Retry download";
  static const String playButton = "Play";
  
  // Messages
  static const String downloadSuccessMessage = "Video downloaded successfully!";
  static const String downloadErrorMessage = "Failed to download video";
  static const String invalidLinkMessage = "Please enter a valid TikTok link";
  
  // Empty states
  static const String noDownloadsTitle = "No Downloads Yet";
  static const String noDownloadsMessage = 
      "Downloaded videos will appear here";
  
  // Loading states
  static const String fetchingVideo = "Fetching video information...";
  static const String downloadingVideo = "Downloading video...";
}
```

#### 3. Error Message Classes

**Pattern**: Centralize error messages in the core error handling system

```dart
// core/api/response_message.dart
class Authorized {
  static const String badRequest = "Bad request";
  static const String internalServerError = "Internal server error";
  static const String notFound = "Not found";
  static const String noInternetConnection = "No internet connection";
  static const String unexpected = "Unexpected error occurred";
  static const String connectTimeOut = "Connection timeout";
  static const String cancel = "Request cancelled";
  static const String tooManyRequests = "Too many requests. Please try again later.";
  static const String notSubscribed = "Access denied. Subscription required.";
}
```

### Implementation Best Practices

#### 1. **Always Use Text Classes in UI**

**❌ Bad Practice:**
```dart
Text("Download")  // Hardcoded string
Text("Video downloaded successfully!")
```

**✅ Good Practice:**
```dart
Text(AppStrings.download)
Text(DownloaderStrings.downloadSuccessMessage)
```

#### 2. **Organize by Feature**

Each feature should have its own strings class containing:
- Screen titles
- Button labels
- Input field labels and hints
- Success/error messages
- Empty state messages
- Loading state messages
- Any other user-facing text

#### 3. **Use Descriptive Names**

**Naming Convention**: `{context}_{purpose}`

```dart
class DownloaderStrings {
  // Context: Button, Purpose: Download
  static const String downloadButton = "Download";
  
  // Context: Message, Purpose: Success
  static const String downloadSuccessMessage = "Download successful";
  
  // Context: Screen, Purpose: Title
  static const String downloadsScreenTitle = "Downloads";
}
```

#### 4. **Group Related Strings**

Organize strings logically within the class:

```dart
class DownloaderStrings {
  // ========== Screen Titles ==========
  static const String screenTitle = "Downloader";
  static const String downloadsScreenTitle = "Downloads";
  
  // ========== Input Fields ==========
  static const String videoLinkLabel = "Video link";
  static const String videoLinkHint = "Paste link here...";
  
  // ========== Buttons ==========
  static const String downloadButton = "Download";
  static const String retryButton = "Retry";
  static const String playButton = "Play";
  
  // ========== Messages ==========
  static const String downloadSuccessMessage = "Download successful";
  static const String downloadErrorMessage = "Download failed";
  
  // ========== Empty States ==========
  static const String noDownloadsTitle = "No Downloads";
  static const String noDownloadsMessage = "Downloaded videos will appear here";
}
```

### Localization Implementation Strategy

#### Step 1: Create Localization Structure

```
lib/
├── l10n/                          # Localization files
│   ├── app_en.arb                 # English translations
│   ├── app_es.arb                 # Spanish translations
│   ├── app_fr.arb                 # French translations
│   └── ...
└── src/
    └── features/
        └── tiktok_downloader/
            └── presentation/
                └── l10n/
                    ├── downloader_en.arb
                    ├── downloader_es.arb
                    └── ...
```

#### Step 2: Convert Text Classes to Localized Classes

**Before (Static Strings)**:
```dart
class DownloaderStrings {
  static const String downloadButton = "Download";
}
```

**After (Localized)**:
```dart
class DownloaderStrings {
  final String downloadButton;
  
  DownloaderStrings({
    required this.downloadButton,
  });
  
  // Factory for current locale
  factory DownloaderStrings.of(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DownloaderStrings(
      downloadButton: l10n.downloaderDownloadButton,
    );
  }
}
```

#### Step 3: Use in UI

```dart
class DownloaderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = DownloaderStrings.of(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(strings.screenTitle)),
      body: ElevatedButton(
        onPressed: () {},
        child: Text(strings.downloadButton),
      ),
    );
  }
}
```

### Migration Path for Existing Code

#### Phase 1: Extract Strings to Classes

1. Create feature-specific string classes
2. Move all hardcoded strings to these classes
3. Update UI code to use string classes
4. Keep static strings initially (no localization yet)

#### Phase 2: Add Localization Support

1. Add `flutter_localizations` dependency
2. Create `.arb` files for each language
3. Generate localization files using `flutter gen-l10n`
4. Convert static string classes to localized classes
5. Update UI to use localized strings

### Flutter Localization Setup

#### 1. Add Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
```

#### 2. Configure Localization (`pubspec.yaml`)

```yaml
flutter:
  generate: true

l10n:
  arb-dir: lib/l10n
  template-arb-file: app_en.arb
  output-localization-file: app_localizations.dart
```

#### 3. Create ARB Files

**`lib/l10n/app_en.arb`**:
```json
{
  "@@locale": "en",
  "appName": "Tiktok downloader",
  "@appName": {
    "description": "The application name"
  },
  "downloaderDownloadButton": "Download",
  "@downloaderDownloadButton": {
    "description": "Download button text"
  }
}
```

**`lib/l10n/app_es.arb`**:
```json
{
  "@@locale": "es",
  "appName": "Descargador de Tiktok",
  "downloaderDownloadButton": "Descargar"
}
```

#### 4. Initialize in App

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
      ],
      // ... rest of app
    );
  }
}
```

### Language Switching Implementation

#### 1. Create Locale Manager (`core/utils/locale_manager.dart`)

```dart
class LocaleManager {
  static const String _localeKey = 'selected_locale';
  
  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
  
  static Future<Locale?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null) {
      return Locale(code);
    }
    return null;
  }
}
```

#### 2. Use Locale Provider/State Management

```dart
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en')) {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final savedLocale = await LocaleManager.getLocale();
    if (savedLocale != null) {
      emit(savedLocale);
    }
  }
  
  Future<void> changeLocale(Locale locale) async {
    await LocaleManager.setLocale(locale);
    emit(locale);
  }
}
```

#### 3. Update App to Support Locale Changes

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocaleCubit(),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('es'),
              Locale('fr'),
            ],
            // ... rest of app
          );
        },
      ),
    );
  }
}
```

### Checklist for New Features

When implementing a new feature, ensure:

- [ ] All user-facing text is in a dedicated strings class
- [ ] Strings class is located in `features/{feature}/presentation/l10n/`
- [ ] No hardcoded strings in UI code
- [ ] Strings are organized logically (grouped by purpose)
- [ ] Descriptive naming convention is followed
- [ ] Error messages use centralized error message classes
- [ ] Feature strings class is ready for localization migration
- [ ] Strings class follows the same pattern as other features

### Benefits of This Approach

1. **Easy Localization**: All strings in one place makes translation straightforward
2. **Consistency**: Centralized strings ensure consistent messaging
3. **Maintainability**: Update text in one place, affects entire app
4. **Type Safety**: Compile-time checking for string references
5. **Refactoring**: Easy to find and update all usages
6. **Testing**: Can easily mock or test different language scenarios
7. **Scalability**: Simple to add new languages without code changes

### Example: Complete Feature Implementation

```dart
// features/tiktok_downloader/presentation/l10n/downloader_strings.dart
class DownloaderStrings {
  // Screen titles
  static const String screenTitle = "Downloader";
  static const String downloadsScreenTitle = "Downloads";
  
  // Input fields
  static const String videoLinkLabel = "Video link";
  static const String videoLinkHint = "Paste link here...";
  
  // Buttons
  static const String downloadButton = "Download";
  static const String retryButton = "Retry download";
  static const String playButton = "Play";
  
  // Messages
  static const String downloadSuccessMessage = "Download successful";
  static const String downloadErrorMessage = "Download failed";
  
  // Empty states
  static const String noDownloadsTitle = "No Downloads";
  static const String noDownloadsMessage = 
      "Downloaded videos will appear here";
}

// Usage in UI
class DownloaderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DownloaderStrings.screenTitle),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: DownloaderStrings.videoLinkLabel,
              hintText: DownloaderStrings.videoLinkHint,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(DownloaderStrings.downloadButton),
          ),
        ],
      ),
    );
  }
}
```

---

## Summary: Key Architectural Principles

1. **Clean Architecture**: Strict layer separation, dependencies flow inward
2. **Dependency Injection**: GetIt service locator, feature-based injectors
3. **Functional Error Handling**: Either<Failure, Success> pattern
4. **BLoC State Management**: Event-driven, immutable states
5. **Repository Pattern**: Abstract interfaces, concrete implementations
6. **Use Case Pattern**: Single responsibility, business logic encapsulation
7. **Entity/Model Separation**: Domain entities vs data models
8. **Feature-Based Organization**: Self-contained feature modules
9. **Configuration Management**: Centralized routes, themes, constants
10. **Starter Kit System**: Reusable, production-ready features
11. **Localization Strategy**: Centralized text classes, feature-based organization, ready for i18n

---

## Conclusion

This project demonstrates a **production-ready, scalable Flutter architecture** that:

- ✅ Separates concerns clearly
- ✅ Is highly testable
- ✅ Is maintainable and extensible
- ✅ Follows SOLID principles
- ✅ Uses modern Flutter/Dart patterns
- ✅ Provides reusable components
- ✅ Handles errors gracefully
- ✅ Manages state predictably

Any new engineer following these guidelines can build features that seamlessly integrate with the existing codebase while maintaining architectural consistency and code quality.
