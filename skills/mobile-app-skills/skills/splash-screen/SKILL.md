---
name: splash-screen
description: "Build the splash screen: minimal, just the app logo, name and a loading bar, on the kit splash flow with bounded launch and optional launch ads."
---

# Splash screen

Use `SplashFlow` and `SplashLoadingView` for launch presentation. The app owns
startup and destination selection; see [runtime setup](../runtime-setup/SKILL.md).

For translated apps or apps with language selection, follow the
[default first-use order](../onboarding/SKILL.md#default-first-use-order):
splash → language selector → onboarding → available paywall → main app, unless
the owner specifies otherwise. Returning completed installs keep their normal
splash-to-app route; adding translations does not reset completion.

## Default look: logo, name and a loading bar

Unless the owner asks for something else, keep the splash minimal: the app
logo, the app name under it, and a loading bar. Add nothing else: no tagline
block, illustration, glow, halo, particles, gradient ring or animated shapes
around the logo. On PDF Reader (Nov 2026) the owner asked for a red glow behind
the logo to be removed.

Story Saver (`lib/features/splash/presentation/screens/splash_screen.dart`) is
the reference. It passes its parts to the kit's `SplashLoadingView`:

- `logo`: the launcher artwork `assets/images/app-logo.png` (512 px), drawn at
  120 × 120 and clipped to a radius of 32.
- `title`: the app name, bold, 32 pt, in the app's accent colour.
- `SplashLoadingStyle`: a soft vertical gradient from the accent tint to the
  page colour (`0xFFD7F0DE` → white), with `progressColor` set to the accent.
- `SplashLabels`: `loading: 'Loading'`, which shows as the label above the bar,
  and `adDisclosure: 'This action can contain ads'`. The disclosure appears only
  when a launch ad is expected.
- `minDuration: Duration(seconds: 2)`, so the splash never flashes past.

`SplashLoadingView` centres the logo and name a little above the middle, then
puts the label, a rounded progress bar and the ad disclosure near the bottom.
Its bar follows the real `SplashProgress`. An app without the kit splash should
build the same layout and use a determinate bar sized to its real startup work.

Match the app's theme. A dark app uses its dark background and its own accent;
it does not copy Story Saver's light green. Give the native launch screen
(Android `launch_background.xml`, `windowSplashScreenBackground` on API 31+, and
iOS `LaunchScreen.storyboard`) the same background colour, so there is no white
flash before Flutter draws. Keep the logo animation, if any, to a short fade or
scale-in, and skip it when `MediaQuery.disableAnimationsOf` is true.

## Bounded launch and launch ads

- Supply bounded `prepare`, optional `resolveAd`, and `onFinished` callbacks.
  Show recovery when required startup fails. A splash deadline is not proof
  that the app is ready or that native work stopped.
- If the app uses launch ads, resolve the selected provider and format through
  `SplashAdRegistry`. Unknown providers and unsupported formats skip the ad.
- Wait for the consent attempt/deadline and known ad eligibility before a load.
  A consent failure must not become another permanent gate.
- Use `SplashAdRequest.canRequest` to recheck eligibility before load and show.
  Include premium, developer switches, global/splash switches, and app-specific rules.
- Keep dedicated launch placements separate from ordinary interstitial pacing
  when the product uses launch ads. Do not show another interstitial on Home entry.
- Use the configured `maxWait` for the flow; avoid unbounded stream waits in
  preparation. Navigate once and only while the widget is mounted.
- Apps with Appodeal plus a direct AdMob App Open ad (PDF Reader): start both
  SDKs together, wait for both in `prepare` under a 7-second `maxWait`, and
  show the App Open ad from `onFinished`. Follow
  [App Open in the app](../appodeal-browser-setup/SKILL.md#app-open-in-the-app-test-ads-test-devices-and-the-splash).

A remote key can select only a provider already integrated in the binary. Read
current network/store placement rules when introducing or changing launch ads.
Do not assume every supported full-screen format is suitable at launch.
Story Saver's folder-access gate is app-specific.

Check no-ad launch, required failure, timeout, backgrounding, premium changes,
and unavailable providers. Record `SplashOutcome` accurately.

## Keep preparation results separate from the animation

The app startup owner constructs and initializes the runtime. `SplashFlow`
presents that work and any configured launch ad. A completed animation must not
be used as evidence that required dependencies are available.

Define the destination from real state: required initialization outcome,
onboarding completion, and any app-specific gate. If preparation fails, expose
a retry route/state that disposes the failed attempt before constructing another.
A late completion from that failed attempt must not navigate over the new one.

For a launch ad, resolve the placement through the existing registry and policy.
Check eligibility before loading and again before showing because purchases,
consent completion/deadline, or developer switches may change while loading.
Skip unsupported or unavailable ads and continue according to the bounded flow.
Do not introduce a second endless “ad ready” wait after the splash deadline.

Use one navigation owner. Guard repeated completion callbacks and check the
screen is still mounted. If a native ad is already being displayed, respect its
lifecycle rather than navigating unrelated UI underneath it due to an arbitrary
short timer. Report whether launch proceeded without an ad, showed one, timed
out, or failed required preparation; these are different outcomes.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_splash](../../../../../packages/genrevibes_starter_kit/modules/splash/genrevibes_splash/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/splash/genrevibes_splash/lib/genrevibes_splash.dart).
- [genrevibes_remote_policy](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/lib/genrevibes_remote_policy.dart).
