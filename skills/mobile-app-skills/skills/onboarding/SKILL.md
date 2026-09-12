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
- **Whole screens, not a shared ad area.** Keep the default
  `OnboardingPresentation.screens`: every page is a complete screen with its own
  controls and its own ad, swiping in as a unit. A shared ad area that collapses
  on pages without an ad reads as something missing and makes for bad UX.
- **Edge-to-edge artwork.** Use `layout: OnboardingScreenLayout.edgeToEdge`
  with artwork that covers (`BoxFit.cover`). The artwork runs across the top
  under the status bar and takes the height the title, description, controls
  and ad leave: the top half of an ad screen, most of a screen without one.
  Set `artworkFadeHeight` (around 40) so it melts into the page above the
  title. Tall portrait artwork with `BoxFit.cover` gives the full-bleed photo
  look; square illustrations look better uncropped on a tinted background that
  fills the area.
- **Reserve the ad's space.** Set `OnboardingAdSlot.reservedHeight` to the
  ad's height (`AppodealNativeAdStyle.resolvedHeight`) and give the ad view
  `placeholder: AppodealNativeAdPlaceholder(style: style)`. Every ad screen is
  then laid out with the ad as part of its design from the first frame, shows
  a quiet text-free card until the ad loads, and nothing moves when it does.
  An ad added after the screen, pushing content aside, reads as an
  afterthought. Only choose the ad presentation where native ads render
  (`AppodealNativeAds.instance.isSupported`), or the reserved space stays empty.
- **Alternate screens.** Give every other page `showAd: false`, so it is a
  full-screen page and each ad screen gets a fresh ad. Set `preloadNext: true` on `AppodealNativeAdView` so the next
  ad loads during the full-screen page and appears at once.
- **Accidental clicks.** Keep a clear gap between Next and the ad. An ad right
  under a button users tap quickly draws accidental clicks, which networks
  penalize; watch for a high click rate with poor conversion.
- **Placement.** Add `AdPlacement(id: 'onboarding_native', format:
  AdFormat.native)` to the Appodeal configuration and to the app's placement
  list, and send `AppodealNativeAds.instance.attributedAdEvents(fallback: placement)` through the ad
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
