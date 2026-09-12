---
name: ads
description: Banner, interstitial, and rewarded ads through Appodeal mediation with the modular starter kit — app keys, network adapters, consent, test mode for development builds and developer devices, and ad revenue and click analytics. Read before touching ads in any GenRevibes app.
---

# Ads

## Overview

GenRevibes apps mediate ads through **Appodeal**, using the kit's
`genrevibes_ads_appodeal` adapter behind the provider-neutral `genrevibes_ads`
contract. Appodeal runs the auction across every network whose adapter is in
the build and enabled in the Appodeal dashboard. AdMob is one of those networks,
not the ad server.

| Package | Role |
|---|---|
| `genrevibes_ads` | Placements, formats, `AdProvider`, `AdCoordinator`, premium/suppression/frequency policy, `AdTestModeProvider` |
| `genrevibes_ads_appodeal` | `AppodealAdProvider` (interstitial, rewarded) and `AppodealBannerView` |
| `genrevibes_consent_appodeal` | `AppodealConsentProvider`, over Appodeal's UMP-based consent manager (IAB TCF v2) |
| `genrevibes_developer_access` | Which phones get test ads in a store build |

`genrevibes_ads_admob`, `genrevibes_ads_admob_ui` and `genrevibes_consent_ump`
stay in the kit for an app that serves AdMob directly. An app on Appodeal
depends on none of them and does not list `google_mobile_ads`.

## Prerequisites

- An Appodeal app per platform. Put the **app key** in every env file:
  `appodeal_app_key_android`, `appodeal_app_key_ios`. Development builds need
  the real key too, because test mode still initializes against the app.
- Networks enabled in the Appodeal dashboard.
- Consent messages (European regulations, and US state regulations) created
  and **published** in AdMob → Privacy & messaging, for the app whose App ID is
  in the manifest. Without them no consent form is ever shown, and the Appodeal
  dashboard reports "CMP not integrated yet".
- Placements: `default` always exists. Create any named placement in the
  dashboard before using its name in code.

## Native Setup

### Android

`android/build.gradle`:

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://artifactory.appodeal.com/appodeal" }
    }
}
```

`android/app/build.gradle`. The plugin ships Appodeal core and the IAB adapter
only, so every other network needs its adapter:

```groovy
dependencies {
    implementation "com.appodeal.ads.sdk.adapters:admob:24.7.0.0"
    implementation "com.appodeal.ads.sdk.adapters:applovin:13.5.1.0"
    // ... one line per network the dashboard uses
}
```

- Copy adapter versions from the README of the `stack_appodeal_flutter` version
  in `pubspec.lock`, and update them together with the plugin.
- Leave out Appodeal's analytics adapters (Adjust, AppsFlyer, Facebook,
  Firebase, Sentry): the app reports ad revenue itself.
- Every adapter adds app size. Trim the list to the networks the dashboard
  actually uses.
- **minSdk 24.**
- **Include the AdMob App ID in the manifest** whenever the AdMob adapter, or
  any adapter that brings the Google Mobile Ads SDK, is included. That SDK
  crashes at launch without one:

  ```xml
  <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="${admobAppId}"/>
  ```

  Use the app's **real** App ID in every build, development included.
  Appodeal's consent manager finds the app's consent messages under it, and
  Google's sample ID has none, so a development build could never show the
  form. Test ads come from Appodeal's test mode, not from the ID.
- **Allow cleartext traffic.** The plugin's manifest merges a network security
  config that permits it. If the app declares its own `networkSecurityConfig`,
  that config must permit cleartext too, or the manifest merge conflicts.

### iOS

Podfile sources. Naming any source replaces the default, so keep the CDN:

```ruby
source 'https://github.com/appodeal/CocoaPods.git'
source 'https://github.com/bidon-io/CocoaPods-Specs.git'
source 'https://cdn.cocoapods.org/'
```

Then add:

- the adapter pods from the plugin README;
- `GADApplicationIdentifier` and `SKAdNetworkItems` in `Info.plist`;
- `NSUserTrackingUsageDescription`, if the app asks for tracking.

iOS 13 or later is required, or 15 with the Firebase adapter.

## Composition

```dart
// app_env.dart
GenRevibesAppodealConfiguration get appodeal => GenRevibesAppodealConfiguration(
      appKey: defaultTargetPlatform == TargetPlatform.iOS
          ? appodealIosAppKey
          : appodealAndroidAppKey,
      placements: const <AppodealPlacement>[
        AppodealPlacement(placement: AppPlacements.banner),
        AppodealPlacement(placement: AppPlacements.interstitial),
      ],
      verboseLogging: isDevelopment,
    );

// bootstrap
final consent = ConsentGate(
  provider: AppodealConsentProvider(appKey: env.appodealAppKey, logger: logger),
);
final ads = AppodealAdProvider(
  configuration: env.appodeal,
  testMode: developerAccess.current.servesTestAds,
  logger: logger,
);

// Both deferred, consent first: the form comes before the first ad request,
// and neither may hold the first frame.
StarterModuleRegistration.deferred(moduleId: AppModules.consent, create: () => consent),
StarterModuleRegistration.deferred(moduleId: AppModules.ads, create: () => ads),
```

### Full-screen

```dart
// After deferredStartupComplete, never for a premium user.
await ads.load(AppPlacements.interstitial);
if (ads.isReady(AppPlacements.interstitial)) {
  await coordinator.show(AppPlacements.interstitial); // policy applies
}
```

Auto-cache is off for interstitial and rewarded, so nothing loads until `load`
is called. A rewarded result carries `AdShowResult.reward` only when the video
was finished.

### Banner

```dart
AppodealBannerView(
  provider: ads,
  placement: AppPlacements.banner,
  enabled: startupComplete && !isPremium && !suppressed,
)
```

The view follows provider health by itself. It renders nothing before the SDK
initializes, or while a test-mode change waits for a relaunch. Banner callbacks
and revenue arrive on `ads.events`, not on the view.

## Test Ads (mandatory)

A live ad requested from a development build, or tapped on a developer's own
phone, is invalid traffic for every network in the auction.

- **Test mode follows `DeveloperAccessController`.** Every development build
  gets it, plus listed developer phones in store builds (see
  **developer-access**). Pass `AppodealAdProvider(testMode: …)` at construction
  and call `setTestMode` from the access listener, as with any
  `AdTestModeProvider`.
- **Appodeal takes test mode when the SDK initializes.** That happens in the
  deferred ads module, after consent's network round trip. By then bootstrap
  has normally applied everything local, so these start in test mode: a
  development build, or a hardcoded, env, or previously fetched remote hash.
- **A change after initialization withholds all ads until relaunch.** A phone
  never sees a live ad after it is recognised, and gets test ads from its next
  launch.
- **A passcode unlock hides ads but never produces test ads.** It lasts one
  session. A phone that needs test ads in a store build goes on a list.
- Env files hold the real app key everywhere. There are no test IDs to swap.
- **Verify** with Appodeal's logcat output (`verboseLogging`) and the ads
  module health in **Starter Kit Lab**: `testMode`, `sdkTestMode`,
  `servesInventory`.

## Consent

Use `AppodealConsentProvider` through `ConsentGate`. The Appodeal SDK also
requests consent by itself when it initializes. Resolving consent through the
gate first does two things:

- it keeps the form ahead of the first ad request;
- it gives Settings a privacy-options entry point:
  `ConsentGate.snapshot.privacyOptionsRequired`, then `showPrivacyOptions()`.

**Seeing the form from outside a regulated region.** Appodeal's consent manager
never passes debug settings to Google's User Messaging Platform, and Appodeal
and Google each geolocate the device on their own, so a VPN can convince one
and not the other. In a debug build, open Starter Kit Lab → Consent →
**Preview consent form (EEA)**. It calls the platform directly with the EEA
simulated. If it reports no form available, no consent message is published in
AdMob for the app. The preview stores a real answer; **Reset consent** clears
it.

**What the networks see.** The answer reaches Appodeal and its networks as IAB
strings (`IABTCF_TCString`, `IABTCF_gdprApplies`, `IABGPP_HDR_GppString`) in
the app's default shared preferences, which the SDKs read for themselves. The
app never passes them along. Starter Kit Lab → Consent → **Stored consent
signals** shows them. Outside a regulated region the consent update at the next
launch overwrites a preview's TC string.

Consent is never wired to analytics.

## Analytics Contract

Wire **one** listener on `ads.events`, in bootstrap. Appodeal reports banner and
full-screen callbacks per format rather than per view, so a listener per widget
counts every impression twice.

| Event | Trigger | Parameters |
|---|---|---|
| `ad_impression` | `AdEventType.paid` | `ad_platform`, `ad_source` (winning network), `ad_format`, `ad_unit_name`, `value`, `currency`, `value_micros` |
| `custom_ad_click` | `AdEventType.clicked` | `ad_type` (`banner`, `interstitial`, `rewarded`) |

`value` and `currency` on `ad_impression` are what Firebase counts as ad
revenue. The click event is `custom_ad_click`, never `ad_click`: Firebase
reserves that name, and `firebase_analytics` throws on it, so it would reach
every sink except Firebase. Filter developers' own sessions out with the `developer_access` user
property.

## Interaction Map

- **IAP**: premium users load and see no ads (`AdCoordinator.setPremium`).
- **Consent**: gathered before the ads module starts.
- **Developer access**: decides test mode.
- **Remote config**: interstitial pacing (`AdsPolicyKeys`).

## Checklist

- [ ] `appodeal_app_key_android` / `appodeal_app_key_ios` in every `env/*.json`
- [ ] Appodeal maven repository and network adapters in Gradle, with versions matching the plugin
- [ ] The app's real AdMob App ID in the manifest, in every build, when the AdMob adapter is included
- [ ] iOS: Podfile sources, adapter pods, `GADApplicationIdentifier`, `SKAdNetworkItems`
- [ ] No `google_mobile_ads`, `genrevibes_ads_admob*`, or `genrevibes_consent_ump` in the app
- [ ] `ConsentGate(AppodealConsentProvider)` and `AppodealAdProvider` registered as deferred modules, consent first
- [ ] `testMode` comes from `DeveloperAccessController`, and the `setTestMode` listener is wired
- [ ] Banner rendered through `AppodealBannerView` with an app-owned `enabled`
- [ ] One `ads.events` listener sends `ad_impression` (with `value`/`currency`) and `custom_ad_click`
- [ ] Development build shows `sdkTestMode: true` in Starter Kit Lab and test creatives on screen
- [ ] Appodeal dashboard networks enabled; consent messages published in AdMob → Privacy & messaging
- [ ] Consent form verified from an EEA location (VPN) on a fresh install
