---
name: Ads
description: Banner, interstitial, rewarded, app open, and native ads via AdMob with starter kit
---

# Ads

## Overview

Ads are managed through the starter kit's `AdsBloc`. Supports Banner, Interstitial, Rewarded, App Open, and Native ad types via AdMob. Ad revenue is automatically tracked to Firebase Analytics and PostHog.

## Prerequisites

- Starter kit integrated
- AdMob account + ad unit IDs configured
- Ad IDs in env config (`AppEnv`): `banner_ad_id`, `interstitial_ad_id`, `app_open_ad_id`, `rewarded_ad_id`, `native_ad_id`
- **Mandatory**: AdMob App ID configured in `AndroidManifest.xml` and `Info.plist`. The app will crash on launch if this is missing.
    - Android Test App ID: `ca-app-pub-3940256099942544~3347511713`
    - iOS Test App ID: `ca-app-pub-3940256099942544~1458002511`

## Implementation

### Load & Show Interstitial

```dart
// Load
StarterKit.adsBloc.add(AdsLoadInterstitial(adUnitId: AppEnv.interstitialAdId));

// Show (after loaded)
StarterKit.adsBloc.add(const AdsShowInterstitial());
```

### Load & Show Rewarded

```dart
StarterKit.adsBloc.add(AdsLoadRewarded(adUnitId: AppEnv.rewardedAdId));
StarterKit.adsBloc.add(const AdsShowRewarded());
```

### Banner Ad Widget

```dart
StarterKit.bannerAd(adUnitId: AppEnv.bannerAdId)
```

### Native Ad Widget

```dart
StarterKit.nativeAd(adUnitId: AppEnv.nativeAdId)
```

### App Open Ad

```dart
StarterKit.adsBloc.add(AdsLoadAppOpen(adUnitId: AppEnv.appOpenAdId));
StarterKit.adsBloc.add(const AdsShowAppOpen());
```

### AdMob IDs Management
- **Test IDs**: During development, use Google's [Test Ad Unit IDs](https://developers.google.com/admob/android/test-ads#sample_ad_units).
- **Production IDs**: Ensure real AdMob IDs are injected via the `EnvConfig` for production builds.
- **Remote Config**: Ad IDs can also be dynamically managed via Remote Config for easier updates without app store releases.

### AdsBloc Usage
The `AdsBloc` is the central hub for all ad-related actions.

```dart
// Check if ads are enabled (hidden for premium)
final adsEnabled = context.read<AdsBloc>().state.isEnabled;

// Load an interstitial
context.read<AdsBloc>().add(AdsLoadInterstitial(adUnitId: AppEnv.interstitialAdId));

// Show an interstitial (e.g., after a chat session ends)
if (adsEnabled) {
  context.read<AdsBloc>().add(const AdsShowInterstitial());
}
```

### Disable Ads for Subscribers
The `starter_kit` handles this automatically if `IapBloc` and `AdsBloc` are correctly configured. When the `IapState` becomes `isActive`, the `AdsBloc` state is updated to `isEnabled: false`.

## Interaction Map

- **IAP** → Subscribers see no ads
- **Analytics** → Ad revenue auto-tracked (Firebase `ad_impression` + PostHog `ad_revenue`)
- **Tracking** → Adjust ad frequency by engagement level
- **Content Locking** → Show rewarded ads to unlock content

## Checklist

- [ ] Ad unit IDs in env config (test IDs for dev, real for release)
- [ ] `AdsBloc` provided in widget tree
- [ ] Interstitial ads load on appropriate screens
- [ ] Rewarded ads offered for content unlock
- [ ] Banner ads placed in layouts
- [ ] Ads disabled for subscribers
- [ ] AdMob app ID configured in `AndroidManifest.xml` and `Info.plist`
