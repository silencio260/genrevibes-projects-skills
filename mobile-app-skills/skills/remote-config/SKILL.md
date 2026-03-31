---
name: Remote Config
description: Firebase Remote Config for feature flags, A/B testing, and force update
---

# Remote Config

## Overview

Remote Config uses Firebase Remote Config via the starter kit for feature flags, A/B testing, force update checks, and dynamic configuration.

## Implementation

```dart
final configRepo = StarterKit.sl<RemoteConfigRepository>();

// Fetch latest values
await configRepo.fetchAndActivate();

// Read values
final bool featureEnabled = configRepo.getBool('new_feature_enabled');
final String apiUrl = configRepo.getString('api_base_url');
final int minVersion = configRepo.getInt('min_app_version');
```

### Force Update Check

```dart
final minVersion = configRepo.getInt('min_app_version');
final currentVersion = /* get from package_info */;
if (currentVersion < minVersion) {
  showForceUpdateDialog();
}
```

## Interaction Map

- **Content Locking** → Feature flags for premium features
- **Ads** → Dynamic ad frequency settings
- **Paywall** → A/B test paywall designs
- **Splash** → Force update check on launch

## Checklist

- [ ] Remote Config defaults set in Firebase Console
- [ ] `fetchAndActivate()` called on app launch
- [ ] Feature flags used for gradual rollouts
- [ ] Force update version check implemented
