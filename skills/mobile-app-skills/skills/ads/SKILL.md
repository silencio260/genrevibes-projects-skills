---
name: ads
description: "Connect ad placements and provider-specific views with premium, consent, test-mode, and pacing rules."
---

# Ads

Use `genrevibes_ads` for shared contracts and policy. Appodeal is the current
portfolio recipe; keep a different provider when the app deliberately uses one.

1. Declare app-owned `AdPlacement` IDs and supported formats. Add the chosen
   provider adapter, plus its UI package only where needed.
2. Read the adapter README and installed vendor plugin's native setup. Match
   network adapter versions to that plugin. Do not copy old Gradle versions.
3. With Appodeal, supply the real platform app key even for test builds. Configure
   only the networks used. If a network brings Google Mobile Ads, configure the
   app's AdMob App ID in the native app; it differs from an ad unit ID.
4. Follow [consent](../gdpr-compliance/SKILL.md): consent runs first, but failure
   or timeout lets ads initialization continue.
5. Follow [developer access](../developer-access/SKILL.md) for initial test mode
   and changes. Check provider health before requesting inventory.
6. Apply shared premium, suppression, pacing, and developer-switch rules before
   load and show. Inline views need the same eligibility as full-screen ads.
7. Cancel event listeners and dispose providers with the runtime.

## Appodeal views and events

Use `AppodealBannerView` for banners. Use `AppodealNativeAdView` from the native
adapter on supported Android devices; provide a suitable placeholder elsewhere.
Pass an app-owned `enabled` value that follows eligibility changes.

For native views, reserve `AppodealNativeAdStyle.resolvedHeight` only where the
app intends to show that slot. Keep action buttons separate from the ad. A
mounted native view retains its ad; rebuilding it can take another ad.

Listen once to `ads.events`. Native callbacks use one
`AppodealNativeAds.instance.attributedAdEvents(fallback: ...)` subscription,
not one subscription per placement. Otherwise callbacks can be counted repeatedly.
Use impression callbacks for shown counts, paid callbacks for actual revenue,
and click callbacks for clicks. Do not invent revenue when none is reported.

Launch and exit ads use [splash](../splash-screen/SKILL.md) and
[exit](../exit-prompt/SKILL.md) policies. Do not fall back to a different format
when the requested format is unsupported. Grant rewarded access only from the
successful reward result, not from opening or closing the ad.

Check no-fill, unsupported formats, mode changes, premium revocation/grant, and
all inline placements. Inspect current vendor/store requirements when changing
placement behavior. A technical format capability is not approval for every placement.

## Build the provider and placements

An `AdPlacement` is the app's stable name plus format, such as an interstitial
between media items. The Appodeal configuration maps it to a dashboard placement;
its default dashboard name is `default`. Appodeal uses an app key, not AdMob
unit IDs. The direct AdMob adapter has its own unit mapping and UI packages.

Construct the provider once in bootstrap after developer access is known locally.
Pass its initial test mode, logger, and all declared placements. Add consent
before ads in deferred registrations using the [runtime example](../../references/integration-examples.md).
The provider's module ID must match registration; using the object's `moduleId`
avoids a hardcoded mismatch.

### Native host setup for Appodeal

On Android, inspect the installed plugin's README and the app Gradle files.
The host supplies the Appodeal Maven repository and selected mediated-network
adapters. Keep their versions compatible with that plugin. When AdMob is present,
set `com.google.android.gms.ads.APPLICATION_ID` in the manifest. Inspect manifest
merging if the app already has its own network-security configuration; do not
replace it wholesale to silence a merge error.

On iOS, inspect the Podfile sources and selected adapter pods, plus
`GADApplicationIdentifier` and required SKAdNetwork entries where applicable.
Keep the normal CocoaPods source when adding vendor sources. Configure tracking
usage text only for an actual tracking request. Use the selected plugin's current
platform floors rather than old copied Gradle/Pod versions.

### Loading, displaying, and gating

| Step | Required decision |
|---|---|
| Before load | Startup attempt completed; provider operational; placement supported; product access permits ads. |
| Before show | Recheck premium, suppression, pacing, developer switch, and current foreground state. |
| Inline view rebuild | Follow access/switch changes so a visible banner/native disappears when no longer allowed. |
| Reward completion | Grant only the reported reward outcome; close/cancel is not a reward. |
| No fill/failure | Continue the user flow and record the actual result; do not loop shows or block navigation. |

A view can load internally, so disabling only a full-screen show button is not
an ad-free implementation. Apply the same app eligibility to banner/native
`enabled` and any preload job. Do not load inventory for a known premium user.

### Native event ownership

Use one `ads.events` subscription for provider events. Native UI has app-wide
callbacks; use one `attributedAdEvents(fallback: placement)` stream and let it
attribute events. One listener per placement repeats every callback. Keep actual
paid revenue separate from shown counts: some impressions have no paid data.
Report amount/currency only when supplied, and use `custom_ad_click` for the
custom Firebase-compatible click event.

### Diagnosing a missing ad

Inspect, in order: app eligibility, developer format switch, provider health,
requested versus SDK test mode, supported format, load result, and readiness.
Consent failure should not leave another app-level wait behind. Appodeal can
withhold inventory after a mid-session mode change until relaunch; that is not
ordinary no-fill. Use the Lab's live values before adding duplicate load calls.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_ads](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads/lib/genrevibes_ads.dart).
- [genrevibes_ads_appodeal](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads_appodeal/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads_appodeal/lib/genrevibes_ads_appodeal.dart).
- [genrevibes_ads_appodeal_native](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads_appodeal_native/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads_appodeal_native/lib/genrevibes_ads_appodeal_native.dart).
- [genrevibes_ads_admob](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads_admob/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads_admob/lib/genrevibes_ads_admob.dart).
- [genrevibes_ads_admob_ui](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads_admob_ui/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/ads/genrevibes_ads_admob_ui/lib/genrevibes_ads_admob_ui.dart).
