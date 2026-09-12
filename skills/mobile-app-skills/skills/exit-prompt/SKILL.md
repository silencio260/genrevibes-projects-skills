---
name: exit-prompt
description: What Android Back does on a GenRevibes app's root screen — the starter kit's ExitGuard with remote-configured styles (native ad sheet, ad dialog, features sheet, offer sheet, plain confirmation, double tap, none) for A/B testing. Read before changing how an app exits.
---

# Exit Prompt

## Overview

`genrevibes_exit_prompt` replaces `double_tap_to_exit` and hand-written exit
dialogs. `ExitGuard` wraps the root screen and, on Back, shows the style its
config resolves. The style comes from remote config, so each variant is an A/B
test arm in Firebase, not a release.

The package is ad-agnostic: an ad is an `ExitPromptAd` (a builder and the
height kept for it). A GenRevibes app passes `AppodealNativeAdView` (see
**ads**, "Native").

## Styles

| `exit_prompt_style` | Shows | Needs |
|---|---|---|
| `ad_sheet` | Bottom sheet: native ad above a full-width Exit bar | an ad |
| `ad_dialog` | Dialog: exit question, native ad, Exit and Cancel | an ad |
| `features_sheet` (default) | Tall sheet: feature carousel with Try Now buttons, the exit question, Exit and Cancel; no ad in portfolio apps | features |
| `offer_sheet` | Dark sheet: one offer (premium, or "set as default" for a browser), its button, Exit under it | an offer |
| `confirm_dialog` | Dialog: title, message, Exit and Cancel | — |
| `double_tap` | "Press back again to exit", then exit on a second Back | — |
| `none` | Back closes the app | — |

A style missing what it needs falls back to `confirm_dialog`: a premium user
never gets an ad style, and a premium user on `offer_sheet` gets no offer.

`exit_prompt_exit_button`: `standard` (readable, default) or `dimmed` (muted
grey, still labeled and working).

Pick per app type: `features_sheet` for apps with several features users miss
(tools, utilities), `offer_sheet` for apps with one strong upsell, `ad_sheet`
or `ad_dialog` for content apps, `double_tap` for apps where interruptions hurt
(editors, games in progress).

## Wiring

```dart
// home screen
ExitGuard(
  config: (context) => HomeExitPrompt.config(
    context,
    openGallery: () => tabController.animateTo(2),
    openBusinessMode: () => switchBusinessMode(),
  ),
  onShown: (style) => AnalyticsService.track('exit_prompt_shown', {'style': style.wireName}),
  onResult: (result) => AnalyticsService.track('exit_prompt_action', {
    'style': result.style.wireName,
    'action': result.action.name,
    if (result.targetId case final target?) 'target': target,
  }),
  child: rootScreen,
)
```

`HomeExitPrompt.config` (app-owned, `features/home/presentation/widgets/`)
reads `ExitPromptPolicyKeys.style` and `.exitButton`, and builds the ad, the
features, the offer, the labels and the theme. `config` runs on every Back, so
premium and remote config are always current.

## The ad

- **Only `ad_sheet` and `ad_dialog` carry an ad.** Pass `ad` only when the
  requested style `needsAd`; the default `features_sheet` is built without one.
- Placement `AdPlacement(id: 'exit_native', format: AdFormat.native)` in the
  Appodeal configuration and `AppPlacements.all`.
- Only for a user ads are allowed for: not premium, `SubscriptionManager().adsAllowed`,
  `ads_enabled`, and `AppodealNativeAds.instance.isSupported`. Otherwise `ad`
  is null and the style falls back.
- **Preload** after `deferredStartupComplete` when the style uses an ad
  (`ExitPromptStyle.needsAd`): `ads.load(AppPlacements.exitNative)`. Without it
  the first prompt shows the placeholder while a user is already leaving.
- `AppodealNativeAdView` with `placeholder: AppodealNativeAdPlaceholder(style:)`
  and `preloadNext: true`; `ExitPromptAd.height` is the style's
  `resolvedHeight`, so nothing moves when the ad loads.
- Native events reach analytics through `AppodealNativeAds.instance.attributedAdEvents`,
  which attributes each callback to the placement whose view showed it.

## Ad policy

**Why the default has no ad.** Google Play's ads policy lists as disruptive
"Ads that are triggered by the home button or other features explicitly
designed for exiting the app", with the example "The user attempts to exit the
app and navigate to the home screen, but instead, the expected flow is
interrupted by an ad." Back on the root screen is how a user exits. That rule
applies whichever network serves the ad, and a Play violation lands on the
developer account. `ad_sheet` and `ad_dialog` stay available for deliberate
tests, at that risk.

AdMob's implementation guidance: "Take extreme care when using AdMob ads in
cases where your users might be more prone to accidental clicks." A user
leaving the app taps quickly, and the ad sits where their thumb is going.

- `standard` is the portfolio default. `dimmed` makes Exit look unavailable so
  taps go to the ad or Cancel. That raises clicks that do not convert, which
  networks treat as invalid traffic. Test it on a small share, watch
  `custom_ad_click` against installs from that placement, and end the test at
  the first policy notice.
- Keep the sheet's ad and Exit bar visually separate, and never label Exit
  anything misleading.

## Analytics

| Event | When | Parameters |
|---|---|---|
| `exit_prompt_shown` | A prompt or the double-tap hint shows | `style` |
| `exit_prompt_action` | The user chooses | `style`, `action` (`exit`, `stay`, `feature`, `offer`), `target` |

Compare arms by `exit_prompt_action` exit rate, `feature`/`offer` rate, and
native `ad_show` / `custom_ad_click` on `exit_native`, alongside retention.

## Verify

Starter Kit Lab → **Exit prompt** previews every style with the app's own
content and either Exit button, and reports the result instead of closing the
app. Then change `exit_prompt_style` in Firebase and press Back on home.

## Checklist

- [ ] Root screen wrapped in `ExitGuard`; `double_tap_to_exit` removed
- [ ] Default `exit_prompt_style` is `features_sheet`, without an ad; ad styles only as deliberate tests
- [ ] `exit_native` placement configured; ad preloaded after startup
- [ ] Ad only for non-premium users with ads allowed; styles fall back otherwise
- [ ] `exit_prompt_shown` / `exit_prompt_action` tracked and in the analytics catalogue
- [ ] Exit Prompt Group imported into Firebase Remote Config
- [ ] `exitPrompt` passed to `DevToolsHost`
