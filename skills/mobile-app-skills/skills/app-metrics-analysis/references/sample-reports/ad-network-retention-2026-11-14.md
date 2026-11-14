> Sample report. The final chat answer of the second Gravity analysis, kept verbatim. The owner liked this format: one numbered section per question asked, numbers with windows, caveats stated, next actions ranked. Context: `case study`.

# Ad network and retention analysis — 2026-11-14

First, a structural fact that explains several of your questions at once: **1.0.2 went live on Play at 100% rollout about 11 hours ago.** So "the new version" has one partial day of data, 21 first-opens, and no D1 figure can exist before tomorrow.

---

## 1. AdMob earns only on app open — that's by design, not a fault

`LauncherAds._providerFor` routes `AdFormat.appOpen` to a **direct `AdMobAdProvider`** and sends every other format to Appodeal. And `app_open_ad_id` (`ca-app-pub-4210665095499726/3713578282`) is the **only live AdMob unit** in `env/release.json` — banner, interstitial, native and rewarded are all still `REPLACE_WITH_PROD_*` placeholders. That's harmless, because Appodeal serves those formats, but it does mean app open is the only place AdMob can earn directly.

The interesting part is the price:

| Source | eCPM | Impressions |
|---|---|---|
| Direct AdMob App Open (30d) | **$1.86** | 16 |
| Direct AdMob App Open (today, 1.0.2) | **$2.51** | 3 |
| Whole Appodeal stack (Nov 7–14) | **$0.1278** | 577 |

Direct AdMob clears **15–20× more per impression** than everything Appodeal serves, on the same users. The one soft spot: show rate on that unit is **7.3%** over 30 days — you load app-open fills and discard almost all of them. That is the cheapest available revenue win in the whole account.

## 2. Which versions are serving AdMob impressions

AdMob Network report, broken down by ad unit × app version:

- **Last 30 days:** exactly one row — **1.0.1**, "Launcher and Mini Apps - App Open", 231 requests, 94.8% match rate, 16 impressions, $0.03.
- **Today:** **1.0.2** — 7 requests, 3 impressions, $0.01, 42.9% show rate; **1.0.1** — 38 requests, 2 impressions, 5.3% show rate.
- **No 1.0.0 row has ever appeared**, so the version before 1.0.1 has no direct AdMob at all.

So: it was old-version-only until today, and the new version is now serving too. Today's 1.0.2 numbers are small enough that some of them may be your own device.

## 3. Why AdMob and FAN still aren't bidding in Appodeal

**AdMob: still zero requests.** Appodeal Nov 7–14 split by network lists AppLovin, AppLovin Max, Vungle, InMobi, BidMachine, Meta, Test Ads and Service Messages — **no AdMob row at all**. (One thing did fix itself: AppLovin Max went from 613 requests / 0 impressions on Nov 13 to 29 impressions today.)

**I found why the UMP fix hasn't landed yet.** On 1.0.2 today, `consent_resolved` fires for **18 of 18 users with `state = unknown`** — the enum value meaning "not determined yet". `obtained` and `notRequired` never appear. `ConsentGate` has `failOpen: true` and an 8s timeout, so the failure is completely silent. The GDPR message you published today had not taken effect for a single session measured. Google withholds demand without a consent status, which is exactly the zero-request signature.

Check `consent_resolved` → Consent state again tomorrow. The fix is working only when `obtained`/`notRequired` start showing up.

**Meta/FAN: 2 impressions on Nov 10, nothing since.** Your app review is still "In review" (<72h per Meta). Nothing more to do there but wait.

One instrumentation bug found while checking this: `can_request_ads` and `form_available` are sent as Dart **bools** from `AppAnalytics.consentResolved` (`app_events.dart:119`), and GA4 shows **(not set)** for both while the sibling `state` (a String) populates fine. Firebase params must be String/int/double.

## 4. Does the new version still leak from splash to tutorial?

**On the first day's evidence, no — and the improvement is large.** 1.0.2 today, by user count:

| Step | Users |
|---|---|
| `first_open` | 21 |
| `launcher_entry_splash_started` | 18 |
| `launcher_entry_splash_completed` | **18** |
| onboarding shown / started | 18 |
| language confirmed, setup started | 15 |
| setup step completed | 13 |
| default requested → `launcher_set_default` | 8 |
| tutorial started → finished | 7 |

first_open → splash completed is **86%**, against **48.5% on 1.0.1 yesterday** (99 → 48 → 46 → 27 → 22) and 40.6% in the Oct 16–Nov 12 baseline. **Every user who started the splash finished it**, and `launcher_entry_splash_abandoned` did not fire once. Set-as-default is 38% of new users versus 11.6% before.

Caveat I'd hold to firmly: 21 users, one partial day, and early updaters are not a random sample. Re-run the saved funnel exploration with the App version breakdown in two or three days before treating this as fixed.

(Note on method: GA4 **Explorations have no same-day data** — running the funnel for today returns step 1 and zeros for everything after, which looks like total collapse and isn't. Standard reports do include today, so the table above came from Reports → Events with App version as a secondary dimension.)

## 5. Ratings: people are saying yes, the hand-off loses them

**101 users answered the rating card in the last 28 days** (125 events). Play has **2 ratings**, 5.000★.

The mechanism is in the code. On **Yes**, `RatingPrompt._openStoreForRating` calls `openStoreListing()` — it **launches the Play Store listing externally**. `requestReview()`, the native one-tap in-app review sheet, is never called from the production path; its only call site is the devtools bench page. So a user who says yes gets thrown out of your launcher onto a store page and has to find the stars themselves.

Then it gets worse: the instant the listing launches successfully, the app records `RatingOutcome.submitted`, which the coordinator treats as a permanent opt-out. **Those users are never asked again, whether or not they actually rated.** You get one shot per user and you're spending it on the weakest possible flow.

`InAppReviewStoreProvider.requestReview()` already falls back to `openStoreListing()` when the platform declines, so switching the Yes path is essentially a one-line change with the fallback built in.

Two things I could not settle:
- **The yes/no split isn't readable in GA4** — the card's `answer` param is not among the 14 registered custom dimensions. Mixpanel records all properties, so it's there; and `answer` is worth registering.
- **Play still shows only 2 installed devices through Nov 10**, all countries. If that's purely reporting lag (the explanation you landed on last time), fine. If it isn't, most of your ~250 users aren't Play installs at all and literally cannot leave a rating. Play's data now runs to Nov 10 and still shows 2, so this is worth one more look after Nov 16.

## 6. Retention

From a GA4 daily cohort exploration (Oct 17 – Nov 13, all 1.0.1):

- **Nov 12 cohort: 45 users → D1 12 (26.7%) → D2 7 (15.6%)**
- Nov 11 cohort: 10 users → D1 8, D2 5, D3 2
- Nov 8 cohort: 11 users → D1 0

So **D1 is roughly 25%**, up from the 15.2% on record from yesterday's audit. Weekly view: the Nov 8–13 cohort is 122 users with 17 returning in week 1.

**For 1.0.2 there is no retention number and cannot be one today** — the build is 11 hours old. The earliest honest D1 reading is tomorrow. What the first-day funnel does suggest is that the ceiling should be higher: D1 was capped by the 11.6% set-as-default rate, and 1.0.2 is currently converting 38% of new users to default launcher.

---

**What I'd do next, in order:** fix the rating flow to use `requestReview()` (biggest cheap win, you have ~100 willing users a month); re-check consent state tomorrow before spending more time on AdMob-in-Appodeal; look at the 7% app-open show rate, since that unit is the only one paying real money.

I've written all of this into memory. Nothing in the codebase was changed, and GA4 API access is still expired — if you run that `gcloud` command, future checks get much faster than driving the UI.