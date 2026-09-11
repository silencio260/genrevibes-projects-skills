---
name: env-config
description: How to structure env files, IDE run configs, and use dart-define-from-file for environment-specific builds
---

# Environment & IDE Configuration

## Overview

Every GenRevibes project uses a **compile-time environment variable system** via `--dart-define-from-file`. This provides separate configs for Dev, Release, and Special Dev (Founders) builds without hardcoding secrets or toggling code.

## Architecture

```
project_root/
├── env/
│   ├── dev.json              # Development environment (debug flags)
│   ├── release.json          # Production environment (real ad IDs, analytics)
│   └── special_dev.json      # Founders/special builds (founders_version = true)
├── env.example.json           # Template for new team members (committed to git)
├── .run/                      # Android Studio run configurations
│   ├── Dev.run.xml
│   ├── Release.run.xml
│   └── Special Dev.run.xml
└── .vscode/                   # VS Code launch configurations
    └── launch.json
```

> **IMPORTANT**: The `env/` folder is `.gitignore`'d. Only `env.example.json` is committed.

## Environment Keys

| Key | Type | Purpose |
|---|---|---|
| `founders_version` | bool | Enables founders-only features |
| `special_version_mode` | bool | Enables special build mode |
| `development_mode` | bool | Enables debug logging, test ads |
| `firebase_api_key_android` | String | Firebase API key for Android |
| `firebase_api_key_ios` | String | Firebase API key for iOS |
| `appodeal_app_key_android` | String | Appodeal app key for Android. Required in every environment, development included: test mode still initializes against the real app. See the ads skill |
| `appodeal_app_key_ios` | String | Appodeal app key for iOS |
| `banner_ad_id`, `interstitial_ad_id`, `app_open_ad_id`, `rewarded_ad_id`, `native_ad_id` | String | AdMob ad unit IDs, only for an app serving AdMob directly through `genrevibes_ads_admob`. Appodeal has no ad unit IDs |
| `one_signal_app_id` | String | OneSignal push notifications app ID |
| `revenue_cat_api_key_android` | String | RevenueCat API key for Android |
| `posthog_api_key` | String | PostHog analytics API key |
| `feed_back_nest_api_key` | String | Feedback Nest API key |
| `disabled_firebase_analytics_in_debug_mode` | bool | Keeps development traffic out of Firebase Analytics. Optional, defaults to `false` |
| `developer_passcode` | String | Passcode for the hidden developer unlock in store builds. Portfolio env files use `"7722"`; blank or missing falls back to `1234567`. See the developer-access skill |
| `developer_device_hashes` | String | Comma-separated developer device **hashes** (never raw IDs — env values ship inside the binary). Listed phones get the developer tools and test ads. Usually `""` |

## Firebase Analytics Collection

Analytics is a core function of an application, not a consent-gated extra, so
it collects by default in every build and every environment. There is exactly
one way to turn it off:

```json
{ "development_mode": true, "disabled_firebase_analytics_in_debug_mode": true }
```

Both conditions are required. A release build ignores the flag entirely, so it
cannot be shipped to production by accident.

**Firebase persists this setting on the device.** `setAnalyticsCollectionEnabled(false)`
is written to `com.google.android.gms.measurement.prefs.xml` as
`measurement_enabled_from_api` and honoured on every later launch, including by
builds that never call it. It survives reinstall-in-place and it survives
deleting the code that set it. A single build that disabled collection will keep
every later build dark until something explicitly re-enables it, and the symptom
is silent: the sink initializes, reports healthy, accepts every event, and
Firebase drops them all with `Event not sent since app measurement is disabled`.

Because of that, collection state is **asserted on every launch, never assumed**:

- `AnalyticsPipeline` pushes its consent state onto every sink after
  initialization, so a stale on-disk `false` is corrected at startup.
- `FirebaseAnalyticsSink`'s `collectionEnabled` is a ceiling, not a switch. The
  pipeline may always turn collection off; it may only turn it on if
  configuration permits.

To confirm on a device:

```
adb shell setprop log.tag.FA VERBOSE
adb logcat -s FA | grep -i "measurement enabled\|measurement disabled"
```

## Ad IDs

Portfolio apps mediate through **Appodeal**. The env files hold the Appodeal
**app key** per platform (`appodeal_app_key_android`, `appodeal_app_key_ios`),
and the same real key goes in `dev.json`. There are no ad unit IDs and no test
IDs: test mode is a switch on the SDK, set from `DeveloperAccessController` for
every development build — see the ads skill, "Test Ads".

The **AdMob App ID** (the value with `~`) still belongs in native config when
Appodeal's AdMob adapter is in the build, because the Google Mobile Ads SDK it
brings crashes at launch without one: `com.google.android.gms.ads.APPLICATION_ID`
in `AndroidManifest.xml` and `GADApplicationIdentifier` in `Info.plist`. Use the
app's real App ID in every build, development included: Appodeal's consent
manager finds the app's consent messages under it. It is never an env key.

An app serving AdMob directly through `genrevibes_ads_admob` uses the ad unit
keys (`banner_ad_id` and the rest) instead, with the app's real units in every
env file; the adapter swaps them for Google's sample units at runtime.

## Reading Env Vars in Dart

```dart
// Use const String.fromEnvironment for compile-time access
class AppEnv {
  static const bool foundersVersion =
      bool.fromEnvironment('founders_version', defaultValue: false);
  static const bool specialVersionMode =
      bool.fromEnvironment('special_version_mode', defaultValue: false);
  static const bool developmentMode =
      bool.fromEnvironment('development_mode', defaultValue: false);
  static const String firebaseApiKeyAndroid =
      String.fromEnvironment('firebase_api_key_android');
  static const String cloudFunctionsBaseUrl =
      String.fromEnvironment('cloud_functions_base_url');
  // ... all other keys
}
```

## Centralized API Protocol

Every project MUST separate business-level endpoints from low-level network configuration:

- **Business Layer** (`lib/core/api/`): Use `api_endpoints.dart` to centralize all paths and dynamic URL construction logic. Use `api_response.dart` for uniform response modeling.
- **Infrastructure Layer** (`lib/core/network/`): Use for Dio interceptors, connectivity checkers, and low-level HTTP client setup.

**Example `lib/core/api/api_endpoints.dart`**:
```dart
import '../config/app_env.dart';

class ApiEndpoints {
  static const String baseUrl = AppEnv.cloudFunctionsBaseUrl;
  
  static const String transcribe = '$baseUrl/transcribe';
  static const String summarize = '$baseUrl/summarize';
  
  /// Helper for dynamic paths
  static String recordingDetail(String id) => '$baseUrl/recordings/$id';
}
```

## IDE Run Configurations

### Android Studio (`.run/` XMLs)

Each `.run.xml` file uses `--dart-define-from-file` to load the appropriate env file:

```xml
<component name="ProjectRunConfigurationManager">
  <configuration name="Dev" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="filePath" value="$PROJECT_DIR$/lib/main.dart" />
    <option name="additionalArgs" value="--dart-define-from-file=env/dev.json" />
  </configuration>
</component>
```

### VS Code (`launch.json`)

```json
{
  "name": "Dev",
  "request": "launch",
  "type": "dart",
  "program": "lib/main.dart",
  "args": ["--dart-define-from-file=env/dev.json"]
}
```

## Setup for New Projects

1. Copy `agents/templates/env/` → `your_project/env/`
2. Copy `agents/templates/.run/` → `your_project/.run/`
3. Copy `agents/templates/.vscode/` → `your_project/.vscode/`
4. Fill in real API keys in `env/dev.json` and `env/release.json`
5. Add `env/` to `.gitignore`
6. Commit `env.example.json` as reference

## Interaction Map

- **Ads and consent** → read `appodeal_app_key_android`, `appodeal_app_key_ios`
- **Push Notifications** → reads `one_signal_app_id`
- **IAP** → reads `revenue_cat_api_key_android`
- **Analytics** → reads `posthog_api_key`, `disabled_firebase_analytics_in_debug_mode`
- **Feedback** → reads `feed_back_nest_api_key`
- **Firebase** → reads `firebase_api_key_android`, `firebase_api_key_ios`
- **Content Locking / Paywall** → reads `founders_version`, `special_version_mode`
- **Developer access** → reads `developer_passcode`, `developer_device_hashes`

## Checklist

- [ ] `env/` folder created with `dev.json`, `release.json`, `special_dev.json`
- [ ] `env.example.json` committed to git
- [ ] `env/` added to `.gitignore`
- [ ] `.run/` configs created for Android Studio
- [ ] `.vscode/launch.json` created for VS Code
- [ ] `AppEnv` class created to read env vars via `String.fromEnvironment`
- [ ] All API keys filled in for dev environment
- [ ] Real Appodeal app keys in every env file, `dev.json` included — test mode is decided in code, never by the env file
- [ ] **AdMob App ID** in `AndroidManifest.xml` and `Info.plist` when Appodeal's AdMob adapter is in the build
