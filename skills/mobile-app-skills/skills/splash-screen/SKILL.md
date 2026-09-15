---
name: splash-screen
description: "Use the kit splash flow for bounded launch presentation and optional launch ads."
---

# Splash screen

Use `SplashFlow` and `SplashLoadingView` for launch presentation. The app owns
startup and destination selection; see [runtime setup](../runtime-setup/SKILL.md).

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
