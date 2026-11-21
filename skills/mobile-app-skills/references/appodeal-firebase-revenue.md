# Appodeal revenue tracking with Firebase

Use this recipe when configuring or auditing Appodeal + Firebase revenue in a
portfolio app. The portfolio event name is **`ad_impression`**, including when
the Appodeal dashboard defaults to `custom_ad_impression`. Configure the native
adapter, each app's dashboard, and duplicate filtering together. Installing
FlutterFire or switching a dashboard checkbox alone is not a complete setup.

## Contents

- [Ownership](#ownership)
- [Native dependency and Firebase setup](#native-dependency-and-firebase-setup)
- [Appodeal dashboard](#appodeal-dashboard)
- [Shared revenue routing](#shared-revenue-routing)
- [Callback fallback and historical failure](#callback-fallback-and-historical-failure)
- [Verification and migration](#verification-and-migration)
- [Sources](#sources)

## Ownership

| Location | Responsibility |
|---|---|
| `genrevibes_ads_appodeal` in the starter kit | Ships Appodeal's Firebase service adapter from its Android plugin module. Every app using the package gets it; apps don't declare it. |
| `genrevibes_analytics_firebase` in the starter kit | Skips the app's own Appodeal `ad_impression` at Firebase **by default** (`defaultSdkManagedAdPlatforms`). |
| Each app's runtime/bootstrap | Initialize Firebase and Appodeal once. No revenue option to set. |
| Each app's Firebase configuration | Supply its own matching `google-services.json` and Flutter Firebase options. |
| Each Appodeal app's Attribution Settings | Enable Firebase Tracking and choose `ad_impression`. |
| Agents guidance | Apply and verify this recipe consistently across apps. |

Do not force Firebase SDKs into the provider-neutral `genrevibes_ads`
contract; the adapter lives in the Appodeal package only. Updating the kit gives
an app the adapter and the skip, but **not the dashboard setting**: until
Firebase Tracking is on in that app's Appodeal dashboard, the app reports no
Appodeal revenue to Firebase at all. Make the dashboard step part of the
release that first picks up this kit version.

**The app's own Firebase copy of Appodeal revenue is deprecated: redundant and
less accurate** than the adapter's. The predicted-eCPM estimate that filled
missing reports (it inflated Lunaris GA4 revenue about 50x in 1.0.5) is off by
default and deprecated. Mixpanel and other non-Firebase sinks still receive the
app's ad events with their `precision`.

## Native dependency and Firebase setup

The kit's `genrevibes_ads_appodeal/android/build.gradle.kts` declares, for the
dependency set published with `stack_appodeal_flutter` **4.3.1** (Android
Appodeal core **4.3.0**; the package now requires `>=4.3.1`):

```kotlin
implementation("com.appodeal.ads.sdk.adapters:firebase:23.2.0.0")
```

Apps must **not** also declare it; remove the line from an app's Gradle file
when it moves to this kit version. Upgrade the adapter in the kit together with
the Appodeal SDK.

This is Appodeal's **service adapter**, distinct from FlutterFire's
`firebase_analytics`, the AdMob demand adapter, and the Meta analytics adapter.
Appodeal's Flutter plugin brings core + IAB; its service adapters are selected
separately. Read the installed plugin's dependency list when upgrading instead
of carrying this pin across SDK generations.

Keep the Google Services plugin and this app's `android/app/google-services.json`.
Match the native project ID, Firebase app ID and Android application ID against
the Flutter options used at startup. Use the same Firebase app; do not create a
second Firebase project or duplicate initialization for Appodeal. Initialize
Firebase before the analytics pipeline and deferred Appodeal startup.

Check the resolved Firebase Analytics/Remote Config versions against existing
FlutterFire dependencies. A vendor-published adapter pin alone is not proof of
the host's resolved classpath or runtime compatibility. Retain the host's Maven
repository setup. Adding this dependency requires a new native build; a Dart
hot reload or Shorebird patch cannot add a missing native SDK.

For iOS adoption, use Appodeal's matching iOS Firebase service adapter and
Firebase configuration from the installed vendor release. Do not copy the
Android coordinate into a Podfile or report iOS configured from Android checks.

## Appodeal dashboard

Open **Apps → the actual app → Attribution Settings**:

1. Enable **Firebase Tracking**.
2. Set **Firebase Ad Revenue Event Name** to **`ad_impression`**.
3. Save, reopen the page, and verify both values persisted.
4. Leave **Firebase Config Keys** empty unless Appodeal specifically needs named
   Firebase Remote Config parameters for tests/settings. These are parameter
   names, not an API key, credentials, Firebase project ID, or a requirement for
   revenue forwarding. Do not copy the app's entire Remote Config schema there.
5. Leave Adjust/AppsFlyer/MMP selection as None when those services are not
   integrated. Firebase Tracking is configured separately. Do not enable Meta,
   Unity or AppsFlyer forwarding just because they appear on the same page.

After the SDK initializes with this setup, Appodeal forwards impression revenue
automatically. Do not call `FirebaseAnalytics.logEvent` or Appodeal's general
event-tracking function for every impression to duplicate the native route.
Use shown callbacks separately for `ad_show`, not as a source of paid amounts.

## Shared revenue routing

`FirebaseAnalyticsSink(logger: logger)` is enough: `sdkManagedAdPlatforms`
defaults to `{'appodeal'}`. Apps that don't use Appodeal never send
`ad_platform: appodeal`, so the default changes nothing for them. Pass a set
only to add a platform (`{'appodeal', 'admob'}` once an AdMob app is linked to
Firebase) or, in a rollback, `const {}`.

The sink skips the pipeline's `ad_impression` when `ad_platform` is exactly
`appodeal`, including predicted-eCPM fallback events. It keeps Firebase
collection and other events enabled. Other sinks, such as Mixpanel, still
receive the callback events and `precision`. Keep canonical event names: a
renamed manual event will not match this filter. Do not send an additional
`custom_ad_impression` with the same amount.

The filter does not suppress another SDK's own native Firebase events. Audit
linked AdMob automatic measurement and any MAX/other mediator Firebase
forwarding separately. Select one revenue owner per impression before summing
reports or importing conversion actions. Direct AdMob App Open is outside
Appodeal; preserve its separate reporting and check manual versus automatic
AdMob overlap. Never globally drop every provider's `ad_impression` as a fix.

## Callback fallback and historical failure

Lunaris's recorded October 2026 failure had Appodeal dashboard earnings and
`ad_show` events but no Firebase/Mixpanel paid events. The kit traced SDK 4.3
revenue callbacks waiting for analytics services, with startup
`InternalError: SdkConfigurationError`. Keep this as a diagnostic lead, not a
universal explanation for every missing revenue event. Complete Firebase's
native adapter and dashboard integration before adding more estimation logic;
ask Appodeal support if startup errors persist.

The existing `genrevibes_ads_appodeal` client reads the revenue channel directly
to tolerate plugin parser issues, logs SDK reports, and recognizes Android
banner-view type 64. The provider waits 15 seconds, then falls back to predicted
eCPM / 1,000 USD with `precision: predicted_ecpm` when available. On background
without a full-screen ad showing, it estimates waiting impressions immediately.
Test inventory is not estimated; native format has no predicted-eCPM fallback.

**The fallback is now deprecated and off by default**
(`GenRevibesAppodealConfiguration.estimateMissingRevenue: false`). With the
Firebase adapter installed, Appodeal's analytics services are ready, so real
reports reach the app; an impression without one gets no revenue rather than a
made-up value. Turn the estimate on only for a diagnostic, never for
reporting; it was always excluded from Firebase revenue by the sink default. The provider matches
waiting callbacks by format/order and suppresses late callbacks for two minutes
after an estimate; it does not reconcile by a unique impression ID. Late values
do not correct a previously sent estimate. Do not describe this as exact revenue,
guaranteed deduplication, or a measured match to payouts. Preserve `precision`
in Mixpanel and distinguish estimates in revenue analysis. SDK-reported revenue
can itself have estimated precision; the Appodeal dashboard remains the payout
reference. Never fabricate zero-fill revenue or infer actual serving from test ads.

## Verification and migration

1. Inspect host dependencies, runtime sink configuration, Firebase identifiers,
   and saved Appodeal dashboard values. Check all four independently.
2. Follow the host's build/run authorization rules. Build and install an updated
   Android app with the native adapter when authorized, then fully relaunch.
   If no build was run, report source/dashboard configuration as complete and
   device delivery as pending; do not claim live verification.
3. Use the owner's approved live-ads diagnostic mode and a real ad impression.
   Inspect initialization for service errors and kit logs for received SDK
   revenue. Test ads are not proof of production paid-event delivery.
4. Check Firebase DebugView in the matching project for native `ad_impression`
   and its value/currency and source fields. Check available formats separately.
   Distinguish `ad_show` counts from callbacks that actually contain paid data.
5. Confirm the pipeline logs a skipped manual Appodeal revenue event at Firebase
   and continues sending other app events. A successful local dispatch of a
   skipped event does not prove a native event reached Firebase. The native
   event bypasses the Dart pipeline observer, so it must be checked separately.
6. Verify Mixpanel continues receiving callback events with precision and
   placement context. Do not promise an unchanged one-to-one match between
   native SDK revenue and the kit's estimate fallback stream.
7. Reconcile across the same app/version, date range/timezone and formats after
   reporting delays. Check AdMob/mediator overlap and the conversion actions
   imported into Google Ads; do not optimize simultaneously on duplicate event
   names for the same revenue. Preserve historical data rather than deleting it.

When an app moves to this kit version: delete its own adapter Gradle line and
any `sdkManagedAdPlatforms: const {'appodeal'}` argument, and set the Appodeal
dashboard (above) before the release ships. Older builds without the native adapter retain their old
reporting behavior. If reverting to manual reporting, remove the platform from
the sink's managed set and disable the native revenue forwarding path together;
otherwise the rollback can lose revenue or count it twice.

## Sources

- [Appodeal Flutter plugin](https://github.com/appodeal/Appodeal-Flutter-Plugin)
  and the installed version's README for exact adapter coordinates.
- [Android service integration](https://docs.appodeal.com/android/get-started).
- [Firebase setup](https://docs.appodeal.com/android/services/firebase).
- [Revenue callbacks](https://docs.appodeal.com/android/advanced/ad-revenue-callback).
- [Appodeal tROAS guide](https://docs.appodeal.com/android/advanced/launching-troas):
  its example uses `custom_ad_impression`; the owner's portfolio setting is
  `ad_impression`. Configure/import the actual event instead of copying the example.
- [Firebase revenue measurement](https://firebase.google.com/docs/analytics/measure-ad-revenue).
