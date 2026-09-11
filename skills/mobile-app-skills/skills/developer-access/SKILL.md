---
name: developer-access
description: Developer tools and test ads on store builds for your own phones — hashed developer device lists (hardcoded, env, remote config), a hidden passcode unlock with lockout, and the ads test-mode switch that follows both. Read before adding any "dev menu in production", test-device list, or debug unlock to a GenRevibes app.
---

# Developer Access

## Overview

A development build always has the developer tools and serves test ads. A
**store build** grants the same to a phone in one of two ways:

1. **Listed developer device** — the phone's hash is on any of three lists.
2. **Passcode** — a hidden gesture opens a prompt; the right passcode unlocks
   until the app closes.

Whatever grants access also switches that phone to **test ads**, so a developer
experimenting in production can never tap a live ad. Everything lives in the
kit (`genrevibes_developer_access`, `genrevibes_remote_policy`,
`genrevibes_devtools`, `genrevibes_ads`), so every app behaves identically.

## Non-negotiable: lists hold hashes, never device IDs

Every list ships to strangers. Hardcoded and env values are compiled into the
binary; remote config is downloaded by every install. A raw device identifier in
any of them is published.

`DeveloperDeviceHash.of(id)` is a salted SHA-256 of the identifier. The device
hashes its own identifier and compares. The identifiers are random UUIDs, so a
hash can be neither reversed nor produced by another phone. The salt is
portfolio-wide, so one hash covers a phone in every app.

## Which identifier, and why

| Identifier | Used? | Why |
|---|---|---|
| Android **app set ID** (developer scope) | **Yes** | Google documents it for "analytics or fraud prevention". Shared by every app from one Play developer account on a device, so the hash is portfolio-wide. The user cannot reset it. It changes only after 13 months unused, when the last app from the account is uninstalled, or on factory reset. |
| iOS **identifierForVendor** | **Yes** | The iOS counterpart: vendor-scoped, needs no tracking prompt. |
| Advertising ID (AAID / IDFA) | **No** | Play Ads policy: "must only be used for advertising and user analytics". Unlocking dev tools is neither. Users can also delete it (apps then get zeros), and iOS needs ATT consent. |
| Kit install ID | No | Changes on every reinstall. |
| AdMob hashed test device ID | No | Printed to logcat only; the app has no official way to read its own. |

The Android app set ID is read by the kit's own plugin in
`genrevibes_device_identity_platform`. It is `DeviceIdentity.vendorId`, the value
bootstrap passes to `developerAccess.setDeviceId`.

**A sideloaded install has an app-scoped ID**, so its hash differs from the
Play-installed app's. Copy the hash from the build the phone will actually run.

## The three lists

| List | Where | Format | Use for |
|---|---|---|---|
| Hardcoded | `AppDeveloperDevices.hashes` in `app_env.dart` | `const <String>[...]` | The developer's own phones, permanently |
| Env | `developer_device_hashes` in `env/*.json` | Comma-separated string | Per-build lists (e.g. a tester's phone in `special_dev.json`) |
| Remote | `developer_device_hashes` in Remote Config (**Developer Access Group** in `remote_config_template.json`) | JSON array | Adding/removing a phone **without a release** — applies on the next fetch |

Malformed entries are ignored individually; one typo never voids a list.

**Getting a phone's hash:** unlock with the passcode (or run a dev build), then
Settings → Developer Options → **Copy Developer Device Hash**, or Starter Kit
Lab → **Developer access** → Copy device hash.

## Passcode unlock

- **Gesture:** 7 taps within 3 seconds on the Settings title
  (`DeveloperUnlockGesture`). Silent — no dialog, no hint — when access is
  already granted or entry is locked out.
- **Passcode:** `developer_passcode` in the env file. Portfolio env files set
  `"7722"`. A blank or missing value falls back to
  `DeveloperAccessDefaults.passcode` (`1234567`).
- **Grant lasts until the app process ends.** Never persisted — a phone left
  unlocked does not stay unlocked. A phone that should always have access goes
  on a list.
- **Lockout:** 3 wrong attempts lock entry permanently. Only two things clear
  it: launching a **development build** on the phone, or **reinstalling**. The
  failure count is tied to Android's first-install time (`InstallMarker`), so
  Auto Backup restoring shared preferences into a reinstall does not bring the
  lockout back.
- **Never logged:** the passcode, attempts, and device identifiers are never
  logged, stored, or reported. Storage holds only a wrong-attempt count and its
  install marker.
- **Limitation:** like every define, the passcode is inside the binary. It stops
  casual discovery, not someone decompiling the APK; the lockout stops guessing.

## Test ads follow access

`DeveloperAccess.servesTestAds == isGranted`, always. What that does depends on
the ad provider's `AdTestModeProvider`:

- **Appodeal (portfolio standard):** test mode is taken when the SDK
  initializes, in the deferred ads module after consent's network round trip.
  Access settled by then starts the SDK in test mode, and every mediated
  network serves test ads. That normally covers a development build, a
  hardcoded or env hash, and a remote hash activated on an earlier run.
  **Access that changes after that withholds all ads until relaunch:** nothing
  loads, nothing shows, and the banner view renders nothing. A phone never sees
  a live ad after it is recognised, and gets test ads from its next launch.
- **So on Appodeal the passcode hides ads but never shows test ads.** The grant
  lasts one session and cannot survive the relaunch. A phone that needs test
  ads in a store build goes on a list.
- **AdMob adapter (`genrevibes_ads_admob`):** switches at runtime between the
  app's units and Google's sample units, discarding inventory loaded in the
  other mode. Its banner widgets rebuild on `developerAccess.changes` and pass
  `unit.withTestUnitId()`.
- Every ad adapter must implement `AdTestModeProvider`, and must never show
  live inventory after a mode change it cannot apply.

## Wiring

```dart
// Bootstrap, after the store and identity resolver exist, BEFORE the ad provider.
final developerAccess = DeveloperAccessController(
  store: store,
  config: env.developerAccess, // isDevelopmentBuild, hardcoded, env list, passcode
  installMarker: await InstallMarker.read()
      .timeout(const Duration(seconds: 2), onTimeout: () => null),
  logger: logger,
);
await developerAccess.initialize();

final ads = AppodealAdProvider(
  configuration: env.appodeal, // the app's real key in every build
  testMode: developerAccess.current.servesTestAds, // taken at SDK initialization
);

// After identity.resolve():
developerAccess.setDeviceId(identity.vendorId);

// After remote config is initialized, before refresh():
await DeveloperAccessRemotePolicyBinder.forCoordinator(
  remoteConfig,
  controller: developerAccess,
).initialize();

void follow(DeveloperAccess access) {
  // Bind by pattern: `is` cannot narrow an AdProvider to an unrelated interface.
  if (ads case final AdTestModeProvider testable) {
    unawaited(testable.setTestMode(access.servesTestAds));
  }
  unawaited(analytics.setUserProperties({'developer_access': access.reason.name}));
}
follow(developerAccess.current);
developerAccess.changes.listen(follow);
```

UI:

- Wrap the Settings title in `DeveloperUnlockGesture`.
- Show the developer section with a `StreamBuilder` on `developerAccess.changes`
  when `isGranted`, never on a build flag.
- Add a "Copy Developer Device Hash" row to that section.
- Pass `developerAccess` to `DevToolsHost`.
- Gate any debug override (such as dev premium) on `isGranted`, not on
  `kDebugMode`.

The `developer_access` user property (`none`, `developmentBuild`,
`listedDevice`, `passcode`) lets a developer's own sessions be filtered out of
production analytics.

## Verify

1. Store build, unlisted phone: Settings shows no developer section; ads are live.
2. Tap the Settings title 7 times → passcode prompt. Enter the passcode → the
   developer section appears, and on Appodeal every ad disappears for the rest
   of the session.
3. Copy Developer Device Hash → add it to `developer_device_hashes` in Remote
   Config → publish → relaunch until Starter Kit Lab → Developer access shows
   `Listed developer device · remote`. Relaunch once more: the ads module shows
   `sdkTestMode: true`, and the ads on screen are test ads.
4. Three wrong passcodes on another phone → the gesture does nothing; a dev
   build launch or reinstall restores it.

## Checklist

- [ ] No raw device ID anywhere — hardcoded, env, and remote lists hold `DeveloperDeviceHash` values
- [ ] Android vendor ID is the app set ID (`genrevibes_device_identity_platform` ≥ 0.1.0-dev.2), not `Build.ID` or the advertising ID
- [ ] `DeveloperAccessController` initialized before the ad provider; `setDeviceId(vendorId)` after identity resolves
- [ ] `DeveloperAccessRemotePolicyBinder` initialized before `remoteConfig.refresh()`
- [ ] `developer_device_hashes` (JSON, `[]`) in Remote Config — Developer Access Group imported
- [ ] `developer_passcode` and `developer_device_hashes` present in every `env/*.json`
- [ ] Ads follow access: provider `testMode` + `setTestMode` listener; on Appodeal, a mid-session change verified to hide ads until relaunch
- [ ] Developer section and debug overrides gated on `isGranted`, not build flags
- [ ] Passcode never logged; grant is session-only; lockout verified on device
