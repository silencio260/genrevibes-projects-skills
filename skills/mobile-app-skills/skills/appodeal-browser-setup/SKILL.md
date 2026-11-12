---
name: appodeal-browser-setup
description: "Create an app's AdMob, Appodeal and Meta Audience Network (FAN) entries in the owner's own browser, link Meta to Appodeal, and wire Appodeal plus AdMob App Open into the app."
---

# Appodeal setup in the owner's browser

Use this skill when the owner asks for any of these:

- "Integrate ads with Appodeal mediation, FAN and AdMob bidding"
- "Add AdMob App Open ads" alongside Appodeal
- "Create whatever is missing, using my browser", for AdMob, Appodeal or Meta
- "Sync Appodeal and Facebook/Meta"

This skill covers the owner's instructions for this kind of request, the checks to run
before touching a dashboard, and which steps belong to the owner. The
detailed material lives in other files; read the ones the task needs:

| Need | Read |
|---|---|
| Click-by-click dashboard steps and browser-tool tips | [browser runbook](references/browser-runbook.md) |
| Meta app → property → placements → Appodeal link (order is critical) | [Meta Audience Network with Appodeal](../../references/meta-audience-network-appodeal.md) |
| Which Appodeal adapters ship, and when | [portfolio network defaults](../../references/appodeal-network-defaults.md) |
| Native host checklist (Gradle memory, Meta Infer rule, myTarget floor, minSdk…) | [ads](../ads/SKILL.md#native-host-setup-for-appodeal) |
| Apps still on the old starter kit (`google_mobile_ads ^5`, no `genrevibes_ads` modules) | [legacy kit code](references/legacy-kit-code.md) |
| Test ads in debug, live in release except on test devices; App Open plus Appodeal preloaded on the splash (7 s cap) | [App Open in the app](#app-open-in-the-app-test-ads-test-devices-and-the-splash) |

## Mistakes that must never happen again

These happened on PDF Reader on 8 November 2026. Each one cost a redo, and the
first left a Meta property that can never be deleted. Treat every item as a hard rule.

1. **Working from a stale copy of this repository.** The local `agents`
   checkout was 65 commits behind GitHub. The newer commits already contained
   the [Meta reference](../../references/meta-audience-network-appodeal.md) that
   forbids the exact mistake below. Before any dashboard work, run
   `git -C agents fetch` and `git -C agents status -sb`. If the checkout is
   behind, read the newer versions of the ads skill, the Meta reference and
   this skill first, with `git -C agents show origin/main:<path>` or by pulling
   when the owner allows it.
2. **Creating the Meta property without a developer app.** The agent clicked
   *Create property* on Monetization Manager's home page. Meta then created
   app id `3806862216133719`, which has no developers.facebook.com page and no
   App Secret, so Appodeal could never use it. **Gate:** before clicking
   *Create property*, the current URL must contain `app_id=<id>`, and
   `https://developers.facebook.com/apps/<id>/settings/basic/` must open that
   app's settings, showing an *App secret* field. If either check fails, stop.
3. **Explaining away evidence that the save failed.** After the owner "saved"
   the Meta App Secret in Appodeal, the App Id field was empty on reload. The
   agent compared it with another app (Lunaris) whose fields were also empty
   and concluded that "Appodeal hides saved values". Lunaris simply had no Meta
   setup. An empty field after Save means the save failed. Never decide what is
   normal by comparing with an app you haven't confirmed is configured.
4. **Treating a later step's success as proof.** Appodeal let the agent create
   three Meta bidding ad units even though the App ID and Secret were never
   saved. A step that succeeds is not proof that an earlier step worked. Check
   each step's own result: the App Id field holds the ID after reload, the App
   ID has a developer page, and placement codes start with that App ID.
5. **Skipping the native host checklist.** The first PDF Reader build declared
   the `meta` adapter without the `io.bidmachine:ads.networks.meta_audience`
   bridge and without the `-dontwarn com.facebook.infer.annotation.**` rule,
   which would break release R8. Work through every item of the
   [native host checklist](../ads/SKILL.md#native-host-setup-for-appodeal)
   before reporting the code as done.
6. **Reporting work as done before checking it.** The agent reported the Meta
   sync as complete. Before reporting it, run
   [verifying an app is done properly](../../references/meta-audience-network-appodeal.md#verifying-an-app-is-done-properly)
   and report any check that failed or couldn't be run.

## The owner's instructions

These come from the PDF Reader request of 8 November 2026. Apply them unless
the owner says otherwise.

1. Appodeal mediates Banner, Interstitial and Rewarded ads. Meta (FAN) and
   AdMob compete inside it as bidders.
2. App Open ads come from AdMob directly, not from Appodeal. Appodeal has no
   App Open format.
3. The agent creates every missing dashboard entry in the owner's own Chrome:
   - an AdMob app and an App Open ad unit
   - an Appodeal app (this provides the app key)
   - a Meta developer app, then a Monetization Manager property under it, with
     an Android app and placements
4. The agent links Meta to Appodeal: Meta App ID, App Secret (pasted by the
   owner), and one bidding ad unit per ad type.
5. The agent does **not** link Appodeal to AdMob. The owner does that later
   with Appodeal's AdMob Sync browser extension. Do not create AdMob bidding
   units for Appodeal and do not run AdMob Sync.
6. The global rules still apply. Do not build, install or run the app. Run only
   `flutter analyze` on the touched files. Never uninstall, clear, force-stop or
   disable an app on the owner's phone.
7. At the end, report every ID created, in the table under
   [Final report](#final-report), plus anything left for the owner.

"Use my browser" means Claude in Chrome, the extension that drives the owner's
real Chrome with their sign-ins. It does not mean the built-in browser pane.

## Ask before starting

Ask these in one question round. They decide what gets created.

| Question | Why it matters |
|---|---|
| Android only, or Android and iOS? | Each platform is a separate app in AdMob, Appodeal and the Meta property. |
| Which app name should the dashboards use? | The launcher label, `MaterialApp.title` and Firebase name often differ. Offer the names you found. |
| Is the app published on Google Play? | If it is not, create the apps without a store link. Meta's App name field then stays empty and the property shows "Missing app URL" until release. |

Read the package name yourself from `applicationId` in
`android/app/build.gradle(.kts)`. Some apps compute it, for example by adding an
`.integration` suffix for device tests. Use the base value.

## Checks before creating anything

1. **Existing ad code.** Search for an existing setup so you don't duplicate it:
   ```bash
   grep -rniE "appodeal|google_mobile_ads|AppOpen|APPLICATION_ID" pubspec.yaml lib packages/*/pubspec.yaml packages/*/lib android/app/src/main ios/Runner
   ```
   Check which starter kit the app uses. A kit with `modules/ads/genrevibes_ads*`
   follows the [ads skill](../ads/SKILL.md). An older kit with `google_mobile_ads ^5`
   and an `AdsBloc` follows [legacy kit code](references/legacy-kit-code.md).
2. **Sign-ins.** Open each dashboard and confirm the owner is signed in:
   AdMob, Appodeal, Meta Monetization Manager and developers.facebook.com. Never
   type a password or create an account. If a sign-in page appears, ask the
   owner to sign in.
3. **Entries that already exist.** In each dashboard, search for the package name and
   for similar app names. On PDF Reader the owner said "none of this has been created",
   but AdMob and Appodeal both already had an entry for the package. When you
   find one, ask whether to reuse it (and rename it) or create a new one.
   Appodeal may reject a duplicate package, so reusing is usually right.
4. **Meta business portfolio.** Confirm which business the property belongs to
   (Vibes Studios on PDF Reader).
5. **Meta account in Appodeal.** Under Appodeal Mediation Setup > Ad Networks,
   *Meta Audience Network* must list an account showing "Reporting enabled". If
   none is listed, stop and ask the owner to link it.

## Steps that belong to the owner

| Situation | What the agent does |
|---|---|
| Any click that accepts terms or policies. Examples: creating a Meta developer app accepts the Meta Platform Terms; "Create property" accepts the Audience Network Policy and Terms. | Ask in chat and wait for a clear yes. The approval covers only that click. |
| Meta asks for the account password (when creating an app or revealing an App Secret) | Stop. The owner types it. Never use password-manager autofill. |
| The Meta App Secret | Never read, copy or type it. Enter the Meta App ID in Appodeal, then ask the owner to paste the secret and press Save. Check the result yourself (see the runbook). |
| Appodeal ↔ AdMob link | Out of scope. The owner uses the extension. |

## Order of work

1. AdMob: create or reuse the app, then create an **App open** ad unit with
   *Partner bidding* left unchecked.
2. Appodeal: create or reuse the app, then read its app key.
3. Meta: create the **developer app first**, then go from that app to
   Monetization Manager and create the property, Android app and placements
   there. This is required; see the warning below.
4. Appodeal ↔ Meta: enter the App ID, have the owner paste the App Secret,
   confirm the save, then add one In-App Header Bidding ad unit per format.
5. App code: dependencies, Gradle adapters, manifest App ID, Dart wiring. Then
   run `flutter analyze`.

> **Warning: never start from Monetization Manager's own "Create property"
> button.** It creates an Audience Network app ID that has no page on
> developers.facebook.com and therefore no App Secret. Appodeal cannot save
> that ID, and Meta cannot delete the property. This happened on Gravity
> Rolling Launcher (7 Nov 2026) and again on PDF Reader (8 Nov 2026). Before
> creating a property, check that the Monetization Manager URL contains
> `app_id=<the developer app's id>`.

## App Open in the app: test ads, test devices and the splash

The owner's rules, from the PDF Reader request of 10 November 2026:

- **Debug builds always get test ads** from both AdMob and Appodeal.
- **Release builds get live ads, except on the owner's test devices**, which
  get test ads in every build. The owner's phones are always test devices.
- **Load ads on the splash.** Start the AdMob App Open load and Appodeal's
  auction together, wait on the splash for them, and never hold the user
  there longer than **7 seconds** in total. Show the App Open ad from the
  splash, then continue.

PDF Reader is the reference: `lib/shared/ads/ads_service.dart`,
`lib/shared/ads/app_open_ad_manager.dart`, `lib/shared/ads/ad_ids.dart`,
`android/.../AdTestDevice.kt` and
`lib/features/onboarding/presentation/splash_screen.dart`.

### Test devices

A test-device id is the upper-case MD5 of the app's `ANDROID_ID`. Google
Mobile Ads prints it in logcat as
`Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("…"))`
(only after a live request), and UMP prints the same value as
`addTestDeviceHashedId("…")` on every consent check.

- `ANDROID_ID` is per app signing key on Android 8+. The same phone has one id
  for debug builds and another for release builds, and a different id for
  every other app. Do not copy an id from another app's log line: on PDF Reader
  the first `setTestDeviceIds` line in logcat belonged to a wallpaper app.
  Filter logcat by the app's own process (`adb logcat -d --pid=<pid>`).
- The app reads its own id through a small method channel (`AdTestDevice.kt`,
  channel `pdf_editor/ads`, method `testDeviceId`) and logs
  `Ads: test-device id <id> (listed|not listed)` at start-up, in release
  builds too, so the release id can be copied once and added.
- Keep the ids in `AdIds.testDeviceIds`, with the phone model and which
  signing key each one is for. Remote Config `ad_test_device_ids`
  (comma-separated) adds more without an app update; it applies from the
  launch after the fetch.
- At start-up: `testAds = !kReleaseMode || listed`. Call
  `MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: …))`
  **before** either SDK requests anything, so AdMob demand inside Appodeal is
  covered too, then `Appodeal.setTesting(testAds)`, and give the App Open
  manager Google's test unit (`ca-app-pub-3940256099942544/9257395921`)
  whenever `testAds` is true. The live unit, or the Remote Config
  `app_open_ad_id` override, is used only when `testAds` is false.
- **The advertising ID (GAID on Android, IDFA on iOS) is not the in-code
  id.** When the owner says "configure my IDFA/advertising ID", do both:
  list the phone's upper-case MD5 of ANDROID_ID in the app (above), and ask
  the owner to add the advertising ID under AdMob › Settings › Test devices
  (owner's browser step). The console entry covers every app and build on that
  phone for AdMob demand, but not Appodeal's other networks, so the in-code
  list is still required. The phone shows its advertising ID under Settings ›
  Google › All services › Ads.

#### Starter-kit apps (DeveloperAdSwitches)

Apps built on the GenRevibes starter kit keep the kit's developer switches and
add the owner's test phones on top (Lunaris Network is the reference:
`lib/features/ads/ad_test_device.dart`, wired in `lib/bootstrap/app_bootstrap.dart`):

- `AdTestDevice.resolve` reads ANDROID_ID through the app's existing device
  channel, hashes it, and merges three lists: the `hardcoded` map in code
  (`ID: phone, signing key`), the `test_device_ids` build define, and Remote
  Config `ad_test_device_ids` (registered in the app's schema). It prints
  `Ads: test-device id <id> (listed|not listed)` in every build.
- Test mode for both providers, at construction and on every developer-access
  or switch change:
  `AppEnv.testAdsForBuild || adTestDevice.isListed || developerAdSwitches.servesTestAds`.
  `testAdsForBuild` is true for debug and `development_mode` builds unless the
  run passes `ads_live_diagnostics`, so a remembered "Real ads" switch on the
  phone can never put a debug build on live inventory.
- Pass every listed id as `GenRevibesAdMobConfiguration.testDeviceIds`; the
  AdMob adapter sets `RequestConfiguration` before `MobileAds.initialize`.
- **First launch:** when the owner wants the App Open ad on a new install's
  very first splash, start the kit's deferred modules (consent, AdMob, Appodeal)
  right away instead of after the language picker, and gate it on
  `splash_ad_on_first_launch` (code default `true`; a fresh install has no
  cached Remote Config, so the default decides that launch).
- **Consent outside the EEA:** Appodeal's consent step can fail with "no
  form configured" and leave the kit's `ConsentGate` degraded with
  `canRequestAds` false. Do not require `ModuleState.ready` for the launch ad;
  fall back to `ConsentInformation.instance.canRequestAds()` from Google UMP,
  which allows ads where consent isn't required and blocks them where it is.

### Start-up order

1. Run `AdsService.initialize` straight after `runApp` without awaiting it.
2. Set the test devices, then start `MobileAds.instance.initialize()` and
   `Appodeal.initialize` **at the same time**. Do not start AdMob inside
   Appodeal's `onInitializationFinished`: on PDF Reader that ordering put the
   App Open request about 8 seconds after launch, past the splash, so no
   launch ad ever showed.
3. Consent: call `ConsentInformation.instance.canRequestAds()`. When consent
   saved by an earlier launch already allows ads, load the App Open ad as soon
   as AdMob has initialized. Otherwise (first launch, or consent still
   needed), load it in Appodeal's `onInitializationFinished`, after Appodeal's
   consent form. This is Google's recommended pattern; never request before
   consent where consent is required.
4. Appodeal caches interstitials itself after `initialize`. Use
   `onInterstitialLoaded` / `onInterstitialFailedToLoad` only to tell the
   splash that the first auction has settled.

### Splash

- The kit's `SplashFlow` bounds `prepare` by `maxWait`. Set
  `maxWait: Duration(seconds: 7)` and, after the app's own launch work in
  `prepare`, await `AdsService.waitForLaunchAds()`, which completes when the
  App Open ad and the first Appodeal interstitial have each loaded or failed.
  A timeout there is normal and does not block navigation.
- In `onFinished`, if an App Open ad is ready, the app is resumed and policy
  allows it, show it over the splash and navigate only after it closes
  (`AdsService.showLaunchAppOpen()`). Never wait for an ad after the deadline,
  and never show a launch ad that arrives later over the home screen; keep it
  for the next return to the app.
- First launch: skip the wait and the launch ad so onboarding comes first.
  The ad still preloads for later.
- The App Open manager no longer shows anything by itself on cold start. Its
  foreground listener only handles returns to the app, with
  `skipNextResume()` around pickers, share sheets and ad clicks.

### Diagnosing "no App Open ads"

The manager logs every step as `App Open ad: …` (loading with the unit and
whether it is test or live, loaded, failed with code, shown, or not shown and
why: developer switch, Remote Config `should_show_app_open_ad`,
`min_app_open_ad` pacing, another full-screen ad, no ad ready). If none of
those lines appear, the load never started: check `ads_enabled`, the
developer ad switches, and that `AdsService.initialize` ran.

Also check UMP. On PDF Reader logcat showed `Publisher misconfiguration: …
no form(s) configured for the input app ID`: the AdMob app had no GDPR
message under **Privacy & messaging**. Users in the EEA/UK then get no consent
form, and AdMob serves them limited or no ads. The owner creates the message
in AdMob; it is a dashboard task, not code.

## Final report

| Where | What | ID |
|---|---|---|
| AdMob | App | `ca-app-pub-…~…` |
| AdMob | App Open unit | `ca-app-pub-…/…` |
| Appodeal | App key | 48 hex characters |
| Meta (business name) | Developer app / property | App ID `…`, property `…` |
| Meta | Interstitial / Rewarded / Banner (/ Native) placements | `<appId>_…` |
| Appodeal → Meta | Header-bidding units per ad type, App ID and Secret saved | ON |

After the table, list the changed files, the `flutter analyze` result, and the
pending items:

- **Placements in the app.** Where interstitials and rewarded ads show is a product decision. Ask the owner.
- **Appodeal ↔ AdMob sync.** The owner does this.
- **Meta "Missing app URL".** It stays until the Play listing exists. Business verification and app-ads.txt are listed in the Meta reference.
- **Legal pages.** Meta needs a privacy policy, terms and data deletion URL on the developer app before it goes Live. If the app has no published pages yet, follow [legal-pages](../legal-pages/SKILL.md), which also sets those Meta fields and adds the in-app *Ad privacy choices* entry point.
- **New AdMob units.** They can take up to an hour to serve.
- **iOS.** Anything not set up for iOS, listed explicitly.
