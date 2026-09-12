---
name: splash-screen
description: Launch screen with a bounded loading bar, routing to onboarding or home, and the remote-configured full-screen ad after it — the starter kit's SplashFlow. Read before building or changing a splash screen or launch ads in a GenRevibes app.
---

# Splash Screen

## Overview

`genrevibes_splash` gives every app the same launch screen:

| Piece | Role |
|---|---|
| `SplashFlow` | Waits for the app's work, decides and loads the ad, holds a minimum time, shows the ad, then calls `onFinished` |
| `SplashLoadingView` | Logo and title, a progress line ("Loading 42%..."), a rounded bar, and "This action can contain ads" while an ad may follow |
| `SplashAdRequest` / `SplashOutcome` | The ad to load, and what became of it |

`maxWait` bounds everything together: a slow startup, a consent form or an ad
that does not fill never keeps a user on the splash.

## Implementation

```dart
Scaffold(
  body: SplashFlow(
    maxWait: Duration(seconds: config.read(SplashAdPolicyKeys.maxWaitSeconds)),
    minDuration: const Duration(seconds: 2),
    prepare: waitForDestination,      // SplashBloc: onboarding or home
    resolveAd: resolveSplashAd,       // null = no ad this launch
    adExpected: SplashAdPolicyKeys.formatOf(config) != null && !isPremium,
    onFinished: (outcome) {
      AnalyticsService.track('splash_ad_result', {
        'status': outcome.adStatus.name,
        if (outcome.placement case final p?) 'placement': p.id,
        'wait_ms': outcome.elapsed.inMilliseconds,
      });
      navigateToDestination();
    },
    builder: (context, progress) => SplashLoadingView(
      progress: progress,
      logo: Image.asset('assets/images/app-logo.png', width: 120),
      title: AppStrings.appName,
      style: const SplashLoadingStyle(progressColor: brand, titleStyle: ...),
    ),
  ),
)
```

```dart
Future<SplashAdRequest?> resolveSplashAd() async {
  final format = SplashAdPolicyKeys.formatOf(config);        // null for none
  if (format == null || !config.read(AdsPolicyKeys.adsEnabled)) return null;
  if (firstLaunch && !config.read(SplashAdPolicyKeys.onFirstLaunch)) return null;
  final placement = AppPlacements.splashFor(format);
  if (placement == null || !ads.supportedFormats.contains(format)) return null;
  await kit.deferredStartupComplete;                         // consent first
  await iapBloc.stream.firstWhere(entitlementsKnown);        // never a premium user
  if (isPremium || !SubscriptionManager().adsAllowed) return null;
  return SplashAdRequest(provider: ads, placement: placement);
}
```

Read every `BuildContext` value before the first `await`.

## The splash ad

| Key | Default | Meaning |
|---|---|---|
| `splash_ad_format` | `interstitial` | `interstitial`, `rewarded`, `app_open` or `none` |
| `splash_ad_max_wait_seconds` | `8` | Budget for startup, the decision and the load, 1–30 |
| `splash_ad_on_first_launch` | `true` | Whether the very first launch, before onboarding, gets it |

Import the **Splash Ad Group** from `remote_config_template.json`.

- **Own placements per format**: `splash_interstitial`, `splash_rewarded`, in
  the Appodeal configuration and `AppPlacements.all` (so premium discards
  them), but **not** in the placements given to `AdsRemotePolicyBinder`
  (`AppPlacements.paced`). `time_before_first_insta_ad` would otherwise block
  an ad meant for launch.
- **Appodeal has no app open format** (Flutter plugin 4.2.0), so `app_open`
  shows nothing on Appodeal. It works with a provider that serves
  `AdFormat.appOpen`, such as `genrevibes_ads_admob`.
- **Home requests no interstitial on open.** The splash ad is the launch ad;
  an interstitial right after it is an ad on top of an ad.
- A load that times out keeps going. Its ad stays cached and serves the next
  in-app interstitial.
- The ad shows only after 100% has been on screen, and only with the app in
  the foreground.

## Ad policy

Decide the default knowingly:

- AdMob, Disallowed interstitial implementations: "Do not place interstitial
  ads on app load and when exiting apps as interstitials should only be placed
  in between pages of app content." Mediation does not change this: when AdMob
  wins the auction, the ad is served against the AdMob account, which every
  portfolio app shares.
- App open ads are the format made for launch and loading screens. The loading
  screen plus "This action can contain ads" is Google's recommended pattern
  for them.
- AdMob rewarded ads "must only be served after a user affirmatively and
  unambiguously opts in", so `rewarded` on the splash is not allowed with
  AdMob demand.
- Story Saver ships `interstitial` by the owner's decision. At a policy
  notice, set `splash_ad_format` to `none`; no release is needed.

## Analytics

`splash_ad_result`: `status` (`notRequested`, `shown`, `timedOut`, `notReady`,
`blocked`, `failed`, `appInBackground`), `placement`, `wait_ms`. A high
`timedOut` share means `splash_ad_max_wait_seconds` is too short for the fill
time; a long `wait_ms` on `shown` costs retention.

## Interaction Map

- **Onboarding**: `prepare` decides onboarding or home.
- **Consent / ads**: `deferredStartupComplete` before any ad request.
- **IAP**: entitlements known before the ad; premium gets none.
- **Remote config**: format, wait and first launch.
- **Navigation bar**: hidden on the splash like every screen by default.

## Checklist

- [ ] Splash screen built on `SplashFlow` and `SplashLoadingView`
- [ ] `prepare` waits for the destination; `onFinished` navigates
- [ ] Splash placements configured on the provider and left out of the pacing binder
- [ ] Ad resolved after consent, with entitlements known, never for premium
- [ ] Home no longer requests an interstitial on open
- [ ] `splash_ad_result` tracked and in the analytics catalogue
- [ ] Splash Ad Group imported into Firebase Remote Config
