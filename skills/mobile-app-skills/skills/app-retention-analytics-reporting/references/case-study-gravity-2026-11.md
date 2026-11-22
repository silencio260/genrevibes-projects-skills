# Case study: Gravity Rolling Launcher, 13–14 November 2026

The analysis this skill was built from, recorded so the next agent can see
what was asked, what was done, what was found, and where it went wrong.

App: **Rolling Icon: Gravity Launcher**, a Flutter Android home-screen
launcher. Package
`com.launcherwrld.gravity.rollingicons.launcher.gravity_rolling_icon_launcher`.
Firebase project `rolling-icon-gravity-launcher`, GA4 property `560168056`
(account `162888556`), Mixpanel project `4081621`, Appodeal app `789242`,
Meta developer app `1082967944790202`, Meta property `2184245778833229`,
business portfolio "Vibes Studios" `2572933263011560`.

## The request

> "I want an analysis done on app, check my firebase, mixpanel, appodeal etc.
> I want to know why my DAU and retention is and why it is that number."

Over the two days it widened into: where new users are lost, whether the
crashes stop people, why the tools disagree, why revenue is so low, who wins
the ad auctions, why AdMob and Meta do not bid, and what Meta needs before it
serves ads.

## How the data was reached

1. **Code first.** Read the analytics facade (`lib/core/analytics/app_events.dart`),
   the pipeline in `lib/bootstrap/app_runtime.dart`, the route observer, the
   default-launcher gate and the remote config. Counted call sites for every
   analytics helper.
2. **CLI.** `firebase` and `gcloud` were signed in. The Firebase Management
   API worked once the `x-goog-user-project` header was added and gave the GA4
   property. The GA4 Data API refused the token (no analytics scope). There
   was no BigQuery export. No Mixpanel or Appodeal read credentials existed.
   Live remote config was read with `firebase remoteconfig:get`.
3. **Browser.** The agent offered three routes (grant a gcloud scope, hand
   over API keys, or read the dashboards in the owner's browser). The owner
   chose **"Use my browser"**, so all dashboard work went through **Claude in
   Chrome**. The built-in browser was not tried in this session; the skill's
   rule (built-in first, Chrome as fallback) comes from the owner's
   instruction afterwards and from earlier sessions, where Mixpanel was
   signed in only in Chrome.
4. **Chrome dropped once** (14 Nov, before the Meta audit): two calls returned
   "Claude in Chrome is not connected". The agent answered the owner's pending
   question from data already gathered and resumed when the owner said
   "retry chrome now".
5. **Device log.** The owner installed a Shorebird preview of the release
   build; the agent read `adb logcat`. This settled the AdMob question.

## Timeline: what the owner asked, what was done, what came out

| # | Owner asked | Done | Result |
|---|---|---|---|
| 1 | Analyse DAU and retention | Code audit, CLI probing | Four instrumentation gaps (below); no numbers reachable by CLI |
| 2 | "Use my browser" | Firebase overview, Crashlytics, Play Console, Appodeal, Mixpanel | First report: DAU 94, 7-day ≈ 30-day actives (users days old), crash-free users 20.16%, Play "2 installs", Appodeal balance $1.25 |
| 3 | "According to this URL my D1 retention is 15%" | Opened the overview | Agent had said retention "isn't a number yet"; the card showed **D1 15.2%** (window 4–10 Nov). Corrected |
| 4 | (Owner: Play reporting lags) | Compared chart end dates | Play's series ended 10 Nov at the foot of the same ramp Firebase showed from 8 Nov. "2 installs" was lag. Users are Play organic |
| 5 | "Was the exception so bad users couldn't continue?" | Arithmetic and code | No: 144 hit `app_exception`, 106 completed the splash, of 198, so ≥52 did both; 4.45 exceptions per user. Non-fatal errors flagged fatal by the app's hook |
| 6 | "Run the path exploration" | GA4 path exploration and closed funnel, split by version | Funnel below. 59% lost before the entry splash completes. Not a crash, not a version |
| 7 | "Change config" (to remove a supposed launch ad) | Re-read the gate code | Withdrawn: first-run users get no ad, and the cited remote config keys are not read by the app |
| 8 | "How do you confirm they saw an ad? Isn't it an App Open ad?" | Admitted the claim was inferred | Owner was right on both points |
| 9 | "Check status" (the splash `status` parameter) | GA4 custom definitions | **Zero custom dimensions registered**: no parameter was ever reportable; not retroactive |
| 10 | "Register them" | Registered `status`, `is_default`, `page`, then more | 14 dimensions + 1 metric in total by end of day |
| 11 | "Add more events… comprehensive view" / "what would they be and where?" / "add all" | Eight instrumentation changes | Events listed below; analyser clean |
| 12 | "What recommendations are left?" / "fix both" | Crash fatal flag (kit submodule) and route naming | Kit PR merged as `33c21ed`; named routes with `onGenerateInitialRoutes` |
| 13 | "Why do Firebase, Mixpanel and Appodeal differ?" / "compare them" | Same event, same complete day | 43 vs 31 and 35 vs 29; 9-hour timezone offset; Mixpanel created 7 Nov |
| 14 | "Align timezone" / "fix GA4 too" | Mixpanel → Europe/London; GA4 → United Kingdom Time | Both on UK time |
| 15 | "Revenue yesterday and today, who wins the bids?" | Appodeal monetization split by network, then country | AppLovin 72% of impressions at $0.0000; AdMob zero requests; whole account clears at ~$0.09 eCPM |
| 16 | "Why are AdMob and Meta not bidding?" | Mediation setup, app-ads.txt | app-ads.txt had placeholders for exactly those two. Hosted a filled file on Firebase Hosting, pointed the Play listing website at it. Later shown **not** to be the cause of zero requests |
| 17 | "Is it normal for AppLovin to take everything?" | Country split | AppLovin is not underpaying relative to others; it is the last bidder standing in a starved auction |
| 18 | "Are you sure app-ads.txt is the reason?" | Re-examined | Owner was right: app-ads.txt cannot stop requests |
| 19 | "Keep digging" | Ruled-out table; SDK version skew hypothesis | Hypothesis later disproved |
| 20 | "Check the device logs" | `adb logcat` on the release build | **UMP: no consent form configured for this AdMob app id.** Root cause |
| 21 | "Create it" | AdMob → Privacy & messaging → GDPR message, published | Fixed |
| 22 | "Most users aren't in the EU, why does consent matter?" | Explained | The account-level lookup fails for everyone; also: at 312 impressions a week, revenue is a user-volume problem |
| 23 | "Check my Meta account" / "fill and publish" | Developer app Basic settings | Privacy, terms, deletion URLs and category filled; app **published** |
| 24 | "Start it" (business verification) / "no domain" / "registered business, no domain" | Tested the real form | Meta rejects blogspot.com and web.app; an owned domain is required for business verification |
| 25 | "Do I need this verification to receive FAN impressions?" | Monetization Manager → Issues | **No.** Real blockers: missing app URL, unconfirmed account email. Payout fine |
| 26 | "Add it" | Added the Play URL to the property | Issue cleared; next gate app verification by app-ads.txt |
| 27 | "I submitted it, verify the app-ads.txt stuff" | Checked file, listing and wizard | **Verified**; app review **In review** (<72 h) |
| 28 | "Will I get impressions during review?" | Explained | Expect very few until approved |

## Data collected

**Audience (Firebase, 16 Oct–12 Nov):** 30-day actives 198, 7-day 197, DAU 94
(12 Nov), new users 155, returning 32, engaged sessions per user 1.2, average
engagement 6m 31s, D1 card 15.2% (4–10 Nov). Mixpanel past-week uniques 108;
daily 8, 0, 9, 54, 42 for 8–12 Nov.

**Events (Firebase, 28 days, users):** `first_open` 155, `onboarding_started`
100, `onboarding_default_requested` 62, `onboarding_completed` 60,
`launcher_tutorial_finished` 58, `launcher_set_default` 46, `app_remove` 71,
`app_exception` 144.

**Crashlytics (7–13 Nov):** crash-free users 20.16%, sessions 27%, 650 events,
114 users. Top issue: FeedbackNest telemetry POST to a domain that no longer
resolves, 412 events, all 114 users. Then Bloc emit-after-close (144 events),
picker null assertions, a missing cached icon file.

**Play Console:** installed audience 2 devices as of 10 Nov (reporting lag);
crash, ANR and rating below threshold.

**Appodeal, 12 Nov (settled):** $0.014, 118 impressions, 1,330 requests,
11.8% fill, $0.1156 eCPM, 22.9% CTR, 46 active users. AppLovin 85 impressions
$0.0000, InMobi 15 $0.30, Vungle 13 $0.59, BidMachine 5 $0.28. AdMob: no row.
13 Nov: AppLovin 108, AppLovin Max 0 impressions from 613 requests.
6–12 Nov: 312 impressions, 2,256 requests, 17.8% competitive factor, $0.0898
eCPM; **131 of 312 were Test Ads**; India 52 impressions at $0.0059, UK 4 at
$0.068.

**Meta:** 3 requests, 2 impressions in a week; developer app unpublished
until 14 Nov.

## The funnel (GA4 closed funnel, 16 Oct–12 Nov, saved as "First-run funnel 2026-11-13")

| Step | Users | % of new | Lost here |
|---|---|---|---|
| `first_open` | 155 | 100% | **92 (59.4%)** |
| `launcher_entry_splash_completed` | 63 | 40.6% | 6 (9.5%) |
| `onboarding_started` | 57 | 36.8% | 23 (40.4%) |
| `onboarding_default_requested` | 34 | 21.9% | 16 (47.1%) |
| `launcher_set_default` | 18 | 11.6% | — |

Path exploration: `first_open` 155 → `session_start` 154 → `screen_view` 153.
147 of 155 new users were on 1.0.1. The cause of the first loss was not
established; new events were added to measure it.

## Leaks reported to the owner

1. **Launch splash: 59% of new users leave** before it completes. Measured;
   cause open.
2. **Set-as-default: only 11.6% of new users** make it the default launcher,
   which caps D1 for a launcher.
3. **Crash-free users 20%** — mostly a reporting artifact (a dead vendor
   domain, flagged fatal) that buried the real UI errors.
4. **No Google demand**: AdMob sent zero requests because no consent form
   existed for the app.
5. **Meta nearly absent**: developer app unpublished, then missing app URL on
   the property.
6. **Low prices**: ~$0.09 eCPM account-wide, Test Ads polluting a week of data,
   13–25% CTR that buyers discount.

## Discrepancies explained

- Firebase vs Mixpanel: timezone (9 h), automatic events, Mixpanel's late
  start. Not routing, identity or consent.
- Firebase vs Appodeal: Appodeal counts ad SDK sessions only.
- Firebase vs Play: Play lag of 2–3 days.
- Firebase event totals vs users: `app_launched`, `app_install_event` and
  custom session counters measure other things.

## Measurement gaps found, and what was added

Found: `app_open` had no call sites; `launcher_set_default` only ever sent
`true`; Home, Onboarding and Setup all logged as route `/`; zero GA4 custom
dimensions; `onboarding_started` fired lazily on the first swipe; the stretch
from launch to the tutorial was dark; the repeating set-default prompt is not
logged (still open).

Added: `app_open`, `launcher_entry_splash_started`/`_abandoned`,
`app_first_frame`, `consent_started`/`_resolved`, `onboarding_language_shown`/
`_confirmed`, `setup_started`, `setup_step_viewed`/`_completed`/`_back`,
`launcher_tutorial_started`, `launcher_set_default(false, reason)`, a launch
clock (`ms`), named routes, and visibility-based onboarding events. These are
not comparable with data before 13 Nov.

## Hosting app-ads.txt: why Firebase Hosting

The owner asked whether GitHub Pages could host app-ads.txt. The file must be
at the **root** of the host named as the store listing's website, so a
GitHub project site (`<user>.github.io/<repo>/app-ads.txt`) fails; only a
user site (`<user>.github.io`) or a custom domain works. The owner then asked
about Firebase Hosting, which serves the app's own `<project>.web.app` at the
root with the right content type, needs no new account, and lives in the
same repo. It was chosen, with a minimal `index.html` so the site root
returns 200. Blogspot was ruled out because it redirects `/app-ads.txt` to
`/ads.txt`. Note: shared hosts like these work for app-ads.txt but are
refused by Meta business verification.

## Changes made in dashboards (each after the owner's yes)

- GA4: 14 custom dimensions and 1 custom metric; reporting timezone → United
  Kingdom Time; exploration "First-run funnel 2026-11-13" saved.
- Mixpanel: project timezone → Europe/London.
- Firebase Hosting: `app-ads.txt` at the site root (deployed with
  `firebase deploy --only hosting`).
- Play Console: store listing website → the Firebase Hosting site.
- AdMob: GDPR consent message created and published for the app.
- Meta: developer app settings filled and app published; Play URL added to the
  property; the owner submitted app verification, now Verified and In review.
- Kit: crash hooks report only `FlutterError` as fatal (PR merged).

## Wrong turns and corrections

Each of these was raised by the owner or by later evidence. They are the
reason for the rules in the skill.

1. **"Retention isn't a number yet."** The D1 card was on the overview the
   owner linked. Look at what the owner is looking at.
2. **"Play delivered 2 installs, so users aren't from Play."** The series was
   cut two days earlier than Firebase's. Compare date ranges first.
3. **"The exception is the obvious suspect for the drop."** Arithmetic showed
   users continued past it.
4. **"A 15-second two-ad wall blocks new users."** Inferred from remote config
   keys the app never reads; first-run users get no ad. The owner asked how it
   was confirmed, and it was not.
5. **"app-ads.txt placeholders stop AdMob and Meta bidding."** app-ads.txt
   cannot stop a request. The owner challenged it.
6. **"Google Mobile Ads version skew."** The device log showed the SDK loading
   fine.
7. **"Business verification alone blocks Audience Network"** and then
   **"a domain is not required for verification".** Both wrong: the form
   demanded an owned domain, and verification was not what blocked ads. The
   Issues page named the real blockers.
8. **UI slips:** a privacy URL briefly written to the wrong AdMob app after a
   banner shifted the rows (cancelled, nothing saved); phone digits typed into
   the website field after an error banner cleared (re-entered); a Play URL
   lookup stuck on a partial value (fixed by setting the whole value at once).

## Still open at the end

Several of these were picked up the next day; see the
[second case study](case-study-gravity-2026-11-14-ads-versions.md).

- Re-read retention from about 15 November, once the new events have data.
- Why 59% leave before the splash completes (new events now measure it).
- Logging each display of the recurring set-default prompt.
- Meta app review result; account email confirmation (owner only).
- Consent messages for other regulations (US states) and other languages.
- The owner's other apps on Meta still lack an app URL or app verification.
