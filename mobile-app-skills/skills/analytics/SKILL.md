---
name: Analytics
description: Firebase Analytics, PostHog, Crashlytics, and unified event logging via starter kit
---

# Analytics

## Overview

Analytics provides unified event logging to Firebase Analytics and PostHog, plus Crashlytics for crash reporting. The starter kit handles all wiring — ad revenue is automatically tracked.

## Prerequisites

- Starter kit integrated
- `posthog_api_key` in env config
- Firebase project configured

## Implementation

### Log Events

```dart
// General event
StarterKit.analyticsBloc.add(const AnalyticsLogEvent(name: 'feature_used'));

// Event with parameters
StarterKit.analyticsBloc.add(AnalyticsLogEvent(
  name: 'button_clicked',
  parameters: {'button_name': 'subscribe', 'screen': 'home'},
));

// Retention event (auto-handled by tracking system)
StarterKit.analyticsBloc.add(AnalyticsLogRetention(name: 'app_opened'));
```

### PostHog

```dart
StarterKit.postHog?.capture(eventName: 'video_shared', properties: {'platform': 'tiktok'});
StarterKit.postHog?.identify(userId: 'user_123', userProperties: {'plan': 'premium'});
```

### Ad Revenue (Auto-Wired)

No extra code needed — when `AdsBloc` detects a paid event, it automatically logs to Firebase (`ad_impression`) and PostHog (`ad_revenue`).

## ProGuard / R8 (Android)

To prevent PostHog classes from being stripped during release builds, keep rules are required. While the `starter_kit` package provides these automatically via `consumerProguardFiles`, it is **highly recommended** to also include them in your app's `android/app/proguard-rules.pro` for redundancy and visibility.

1. Ensure `minifyEnabled true` is set in your app's `build.gradle`.
2. Add the following to your app's `proguard-rules.pro`:

```proguard
# PostHog Proguard Rules
-keep class com.posthog.flutter.** { *; }
-keep class com.posthog.** { *; }
```

## Interaction Map

- **Ads** → Ad revenue auto-tracked
- **Tracking** → Retention events flow through analytics
- **IAP** → Purchase events logged
- **All features** → Should log key user actions

## Checklist

- [ ] `AnalyticsBloc` provided in widget tree
- [ ] Key user actions logged as events
- [ ] PostHog wrapper initialized (if using)
- [ ] Firebase Analytics dashboard verified
- [ ] Crashlytics receiving crash reports
