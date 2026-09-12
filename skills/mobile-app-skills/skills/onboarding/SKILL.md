---
name: onboarding
description: First-launch onboarding with the starter kit's OnboardingFlow — any number of pages, an optional native ad slot behind a remote switch, and ordered finish actions such as paywall then navigate. Read before building or changing onboarding in a GenRevibes app.
---

# Onboarding

## Overview

`genrevibes_onboarding` owns two things:

| Piece | Role |
|---|---|
| `OnboardingController` | The completion flag, through `genrevibes_storage`, with legacy-key adoption |
| `OnboardingFlow` | The configurable flow: pages, an optional ad slot, controls, and finish/skip actions |

`OnboardingView` still exists for the simplest case, but new work uses
`OnboardingFlow`. The package knows nothing about ads: the ad slot takes a
builder, and a GenRevibes app passes `AppodealNativeAdView` from
`genrevibes_ads_appodeal_native` (see the **ads** skill, "Native").

## Completion state

```dart
// Bootstrap. Seed the store with OnboardingKeys.legacyKeys, or every existing
// user is onboarded again on the release that adopts this.
final onboarding = OnboardingController(store: store);

// Splash:
Navigator.pushReplacementNamed(
  context,
  onboarding.isCompleted ? Routes.home : Routes.onboarding,
);
```

Unreadable state counts as "not onboarded": showing onboarding twice is better
than skipping it for a new user.

## OnboardingFlow

```dart
OnboardingFlow(
  pages: <OnboardingPage>[                       // any number
    OnboardingPage(
      title: 'Save stories instantly',
      description: 'One tap to keep a status.',
      artwork: (_) => Image.asset('assets/images/onboarding_1.png'),
    ),
    OnboardingPage(title: '…', description: '…', showAd: false), // no ad here
  ],
  controlsLayout: OnboardingControlsLayout.stacked, // row | stacked | fullWidthButton
  skipBehavior: OnboardingSkipBehavior.hidden,      // hidden | jumpToLastPage | finish
  adSlot: OnboardingAdSlot(
    builder: (context, pageIndex) => AppodealNativeAdView(
      provider: ads,
      placement: AppPlacements.onboardingNative,
      enabled: adAllowed,
    ),
    position: OnboardingAdPosition.bottom,          // or aboveControls
    oneAdPerPage: false,                            // one ad across pages
  ),
  labels: const OnboardingLabels(next: 'Next', skip: 'Skip', finish: 'Get started'),
  style: OnboardingFlowStyle(backgroundColor: Colors.white, activeIndicatorColor: brand),
  onPageChanged: (index) => analytics.track('onboarding_page_viewed', {'page_index': index}),
  finishActions: <OnboardingAction>[
    OnboardingAction(openPaywall, name: 'paywall', continueOnError: true,
        timeout: const Duration(seconds: 5)),
    OnboardingAction.markCompleted(onboarding),
    OnboardingAction.navigate(Routes.home),
  ],
)
```

- **Actions run in order, each awaited.** Paywall only, navigate only, both, or
  anything else is just the list. `OnboardingAction.when(condition, action)`
  makes a step conditional. A failing action stops the sequence unless
  `continueOnError`; `onActionError` reports it and the user can try again.
- **`skipActions`** run on skip with `OnboardingSkipBehavior.finish`; without
  them skip runs `finishActions`.
- **Layout.** Pick a `controlsLayout`, or replace the controls with
  `controlsBuilder` (it receives `OnboardingFlowControls`: index, count, busy,
  next, skip, finish, goTo) and the page with `pageBuilder`.
- It renders no `Scaffold`; put it in the route's own.

## Onboarding with a native ad

- **Remote switch.** `OnboardingPolicyKeys.adsEnabled` (`onboarding_ads_enabled`,
  default true, in `PortfolioRemoteConfigSchema`) decides whether onboarding
  carries an ad at all. Import the **Onboarding Group** from
  `remote_config_template.json`. Premium users get the plain flow.
- **Same gating as banners.** Pass `enabled` only when the app's own reasons
  allow an ad: deferred startup finished (consent), subscription state known
  and not premium, ads not disabled. The view adds the provider's reasons.
- **Layout.** The ad sits at the bottom with `controlsLayout: stacked` (dots
  above a centered Next), matching the portfolio design. Without an ad, use
  `row`.
- **Placement.** Add `AdPlacement(id: 'onboarding_native', format:
  AdFormat.native)` to the Appodeal configuration and to the app's placement
  list, and send `AppodealNativeAds.instance.adEvents(placement)` through the ad
  analytics listener.

## Interaction Map

- **Splash** decides onboarding or home from `OnboardingController.isCompleted`.
- **Paywall** is a finish action, not a special case.
- **Ads** supply the slot; **remote config** switches it; **IAP** removes it.
- **Analytics**: `onboarding_page_viewed` from `onPageChanged`,
  `onboarding_complete` when completion is recorded; native ads report
  `ad_show`, `custom_ad_click` and `ad_impression` like every other format.

## Checklist

- [ ] `OnboardingController` on a store seeded with `OnboardingKeys.legacyKeys`
- [ ] Splash reads `isCompleted`
- [ ] Onboarding screen built on `OnboardingFlow`, any page count
- [ ] Finish actions record completion and navigate; paywall step `continueOnError`
- [ ] Ad variant: native placement configured, `onboarding_ads_enabled` read, `enabled` gated like the banner, premium gets the plain flow
- [ ] Native events sent through the ad analytics listener
- [ ] Onboarding Group imported into Firebase Remote Config
