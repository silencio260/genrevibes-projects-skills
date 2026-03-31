---
name: Starter Kit Integration
description: How to integrate and configure the GenRevibes Starter Kit package into any Flutter project
---

# Starter Kit Integration

## Overview

The Starter Kit is a **standalone Flutter package** (`packages/starter_kit/`) providing production-ready, modular features that plug into any Clean Architecture Flutter app. It uses its own `GetIt` service locator internally and exposes a single `StarterKit` facade class.

## Prerequisites

- Flutter 3.7.0+
- Firebase project configured (for Analytics, Crashlytics, Remote Config)
- `env/` configuration files set up (see `skills/env-config/SKILL.md`)

## Installation

### 1. Add Path Dependency

```yaml
# pubspec.yaml
dependencies:
  starter_kit:
    path: packages/starter_kit
```

### 2. Run pub get

```bash
flutter pub get
```

All transitive dependencies (Firebase, AdMob, RevenueCat, OneSignal, PostHog, etc.) are resolved automatically.

## Initialization

In `main.dart`, initialize **before** `runApp`:

```dart
import 'package:starter_kit/starter_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await StarterKit.initialize(
    supportEmail: 'support@yourapp.com',
    // Optional overrides:
    // feedbackNestApiKey: 'YOUR_KEY',
    // adsDataSource: MyCustomAdsDataSource(),
    // analyticsDataSources: [MyMixpanelDataSource()],
    // postHogDataSource: PostHogRemoteDataSourceImpl(),
    // authRepository: MyCustomAuthRepository(),
    // userProfileRepository: MyCustomUserProfileRepository(),
    // iapRepository: MyCustomIapRepository(),
  );

  // Start retention tracking
  final analytics = StarterKit.sl<AnalyticsService>();
  await UserTargetingManager.startTracking(analytics);

  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}
```

## Available Features

| Feature | Access Pattern | Skill File |
|---|---|---|
| **IAP** | `StarterKit.iapBloc` | `skills/iap/SKILL.md` |
| **Ads** | `StarterKit.adsBloc` | `skills/ads/SKILL.md` |
| **Analytics** | `StarterKit.analyticsBloc` | `skills/analytics/SKILL.md` |
| **PostHog** | `StarterKit.postHog` | `skills/analytics/SKILL.md` |
| **Retention** | `StarterKit.retentionTracker` | `skills/tracking-retention/SKILL.md` |
| **Remote Config** | `StarterKit.sl<RemoteConfigRepository>()` | `skills/remote-config/SKILL.md` |
| **GDPR** | `StarterKit.sl<GdprRepository>()` | `skills/gdpr-compliance/SKILL.md` |
| **App Rating** | `StarterKit.sl<AppRatingRepository>()` | `skills/app-rating/SKILL.md` |
| **Feedback** | `StarterKit.sl<FeedbackRepository>()` | `skills/feedback/SKILL.md` |
| **Push Notifications** | `StarterKit.sl<PushNotificationsRepository>()` | `skills/push-notifications/SKILL.md` |

## UI Templates

### Onboarding

```dart
StarterKit.onboarding(
  pages: [...],
  onComplete: () => Navigator.pushReplacementNamed(context, '/home'),
  onSkip: () => Navigator.pushReplacementNamed(context, '/home'),
);
```

### Settings

```dart
StarterKit.settings(
  template: SettingsTemplateType.grouped,
  sections: [...],
);
```

### Banner Ads

```dart
StarterKit.bannerAd(adUnitId: 'ca-app-pub-...');
```

### Native Ads

```dart
StarterKit.nativeAd(adUnitId: 'ca-app-pub-...');
```

### PostHog Wrapper

```dart
StarterKit.postHogWrapper(
  apiKey: 'phc_...',
  child: MyApp(),
);
```

### Double Tap to Exit

```dart
StarterKit.doubleTapToExit(child: HomeScreen());
```

## Swapping Providers

The starter kit is designed to be provider-agnostic. You can swap any default implementation:

```dart
// Custom ads provider (e.g., AppLovin instead of AdMob)
await StarterKit.initialize(
  adsDataSource: MyAppLovinDataSource(),
);

// Custom analytics (e.g., Mixpanel instead of Firebase)
await StarterKit.initialize(
  analyticsDataSources: [MyMixpanelDataSource()],
);
```

## DI Wiring Between App and Starter Kit

The starter kit uses its own `GetIt` instance (`StarterKit.sl`). Your app uses the main `sl` from `container_injector.dart`. They are **separate** — do not register app dependencies in the starter kit or vice versa.

To pass starter kit blocs to your widget tree, provide them in `my_app.dart`:

```dart
MultiBlocProvider(
  providers: [
    // App blocs
    BlocProvider(create: (_) => sl<YourFeatureBloc>()),
    // Starter kit blocs
    BlocProvider.value(value: StarterKit.iapBloc),
    BlocProvider.value(value: StarterKit.adsBloc),
    BlocProvider.value(value: StarterKit.analyticsBloc),
  ],
  child: MaterialApp(...),
);
```

## Checklist

- [ ] `starter_kit` added as path dependency in `pubspec.yaml`
- [ ] `StarterKit.initialize()` called in `main.dart` before `runApp`
- [ ] Firebase initialized before StarterKit
- [ ] Starter kit blocs provided in `MultiBlocProvider`
- [ ] Retention tracking started via `UserTargetingManager.startTracking()`
- [ ] Env keys configured for all required services
- [ ] Android/iOS platform configs set for native SDKs (Firebase, AdMob, OneSignal)
