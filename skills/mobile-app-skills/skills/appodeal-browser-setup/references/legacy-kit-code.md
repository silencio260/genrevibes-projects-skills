# Appodeal and AdMob App Open on the old starter kit

Use this file when the app's starter kit has no `modules/ads/genrevibes_ads*`
packages and instead depends on `google_mobile_ads ^5` with an `AdsBloc`, as
`packages/genrevibes_starter_kit` did in PDF Reader on 8 November 2026. Apps on
the current kit follow the [ads skill](../../ads/SKILL.md). Its
[native host checklist](../../ads/SKILL.md#native-host-setup-for-appodeal) and
[network defaults](../../../references/appodeal-network-defaults.md) apply to
both kits.

The working reference implementation lives in the PDF Reader app (Android only):

- `lib/shared/ads/ad_ids.dart`
- `lib/shared/ads/ads_service.dart`
- `lib/shared/ads/app_open_ad_manager.dart`
- `lib/shared/widgets/banner_ad_slot.dart`

## Match `google_mobile_ads` to Appodeal's AdMob adapter

Appodeal's AdMob adapter pulls in one specific Google Mobile Ads (GMA) Android
SDK. If the `google_mobile_ads` Flutter plugin was built against a different
major version, Gradle still picks the newer SDK, and the plugin can then crash
at runtime with `NoSuchMethodError`. The old kit's `^5` builds on GMA 23. The
AdMob adapter for Appodeal 4.3.0 needs GMA 25.

Check both versions on every integration:

```bash
# GMA version the adapter needs
curl -s https://artifactory.appodeal.com/appodeal/com/appodeal/ads/sdk/adapters/admob/<VER>/admob-<VER>.pom | grep -A1 play-services-ads
# GMA version each google_mobile_ads release is built on
curl -s https://raw.githubusercontent.com/googleads/googleads-mobile-flutter/main/packages/google_mobile_ads/CHANGELOG.md | head -80
```

Versions recorded for PDF Reader:

| Item | Version | Built on |
|---|---|---|
| `stack_appodeal_flutter` | 4.3.1 | Appodeal SDK 4.3.0 |
| AdMob adapter | `admob:25.2.0.0` | `play-services-ads 25.2.0` |
| `google_mobile_ads` (chosen) | 8.0.0 | GMA 25.1, needs Flutter ≥ 3.38.1 |
| `google_mobile_ads` 9.x | — | GMA 25.3 and later |

Pin the plugin in the host app. Use an override so the kit submodule stays untouched:

```yaml
dependencies:
  stack_appodeal_flutter: ^4.3.1
  google_mobile_ads: 8.0.0

dependency_overrides:
  # The old starter kit asks for ^5 (GMA 23), which clashes with Appodeal's AdMob adapter.
  google_mobile_ads: 8.0.0
```

Afterwards, run `flutter analyze` on the kit's `lib` as well. Its banner and
native widgets compile against the new major version.

## Android native setup

Since 4.1, the Appodeal Flutter plugin ships only `core` and `iab`. The host
app declares the network adapters. Take the versions from the installed
plugin's README (`~/.pub-cache/hosted/pub.dev/stack_appodeal_flutter-<ver>/README.md`),
then apply the [network defaults](../../../references/appodeal-network-defaults.md)
and the [native host checklist](../../ads/SKILL.md#native-host-setup-for-appodeal).
For example, an app shipping `meta` needs the Meta Infer `-dontwarn` rule and
the `io.bidmachine:ads.networks.meta_audience` bridge.

PDF Reader declared the following in `android/app/build.gradle.kts`. This is a minimal
FAN + AdMob set, before the portfolio preset was applied:

```kotlin
dependencies {
    implementation("com.appodeal.ads.sdk:core:4.3.0")
    implementation("com.appodeal.ads.sdk.adapters:admob:25.2.0.0")
    implementation("com.appodeal.ads.sdk.adapters:bidmachine:3.7.1.0") // Meta bids through BidMachine
    implementation("com.appodeal.ads.sdk.adapters:iab:1.8.1.0")
    implementation("com.appodeal.ads.sdk.adapters:meta:6.21.0.0")
}
```

The Appodeal Maven repository in `android/build.gradle.kts` is
`maven { url = uri("https://artifactory.appodeal.com/appodeal") }`. Route only
Appodeal's groups to it, as the ads checklist describes. `minSdk` must be at least 24.

**AdMob App ID in the manifest.** The old kit's own manifest declares the
Google test App ID `ca-app-pub-3940256099942544~3347511713`. The host must
override it, otherwise manifest merging fails or the test ID ships. The root
`<manifest>` needs `xmlns:tools="http://schemas.android.com/tools"`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"
    tools:replace="android:value"/>
```

## Dart wiring

**`ad_ids.dart`** holds the Appodeal app key, the AdMob App ID and the App Open
unit ID. When `!kReleaseMode`, it returns Google's test App Open unit
`ca-app-pub-3940256099942544/9257395921` so debug builds never request live ads.

**`ads_service.dart`** (Android only, through `isSupported`):

1. Calls `Appodeal.setTesting(!kReleaseMode)`, with verbose logging in debug.
2. Registers interstitial and rewarded callbacks that record whether a
   full-screen Appodeal ad is on screen.
3. Calls `Appodeal.initialize(appKey, [Banner, Interstitial, RewardedVideo])`.
4. In `onInitializationFinished`: sets `ready`, calls
   `MobileAds.instance.initialize()`, then starts the App Open manager.

App Open starts after Appodeal because Appodeal shows the consent form (Google
UMP) first, and AdMob reads the consent it stores. The service exposes
`showInterstitial()`, `showRewarded(onReward:)`, `skipNextAppOpen()` and the
`ready` notifier.

**`app_open_ad_manager.dart`:**

- Listens with `AppStateEventNotifier` and shows an ad when the app returns to the foreground.
- On cold start, it shows the ad only if it loads within about 5 seconds.
- It discards ads older than 4 hours.
- It never shows while an Appodeal full-screen ad is open.
- It reloads after an ad is dismissed or fails.
- `skipNextResume()` skips the next foreground event. The service calls it on
  an ad click. App code should call `AdsService.skipNextAppOpen()` before opening
  the file picker, share sheet or camera.

**Banner:** `AppodealBanner(adSize: AppodealBannerSize.BANNER)` inside a
`ValueListenableBuilder` on `AdsService.ready`. It renders `SizedBox.shrink()`
until ready and on unsupported platforms.

**`main.dart`:** call `AdsService.initialize()` after `runApp(...)` without
awaiting it, so ads and the consent form never delay the first frame.

Appodeal 4.3 Dart API names that are easy to get wrong:

- The error text is `ApdInitializationError.description`.
- The rewarded type is `AppodealAdType.RewardedVideo`.
- `canShow` and `show` return `Future<bool>`.
- Log levels are `Appodeal.LogLevelVerbose` and `Appodeal.LogLevelNone`.

## iOS

The PDF Reader setup is Android only. iOS needs:

- `GADApplicationIdentifier` in `Info.plist`; `google_mobile_ads` crashes at launch without it
- iOS 15 or later, and the Appodeal pods and sources in the `Podfile`
- iOS entries in all three dashboards
