# Case study: ads by version, new-version funnel, ratings and retention, 14 November 2026

A second analysis of Gravity Rolling Launcher, run in a separate chat the day
after the [first case study](case-study-gravity-2026-11.md) and a few hours
after version 1.0.2 reached 100% of Play users. It reused the first study's
saved explorations and memory, and added new methods for version splits,
same-day data, consent state and ratings. IDs are the same as in the first
study.

## The request

The owner asked six questions in one message:

1. AdMob has started earning, but only on app open, not through Appodeal. Why?
2. Are AdMob impressions only on the old versions, or the new one too?
3. Why are AdMob and Meta (FAN) still not bidding in Appodeal?
4. Does the new version still leak users between the splash and the tutorial?
5. Why so few ratings for these numbers — are people saying yes and not rating?
6. What is retention like, especially on the new version?

## How the data was reached

1. **Memory and code first.** Read the saved notes from the first study, then
   the code: the ad provider routing (`LauncherAds._providerFor`), the live ad
   unit ids in `env/release.json`, the app version in `pubspec.yaml` and git
   history (when each AdMob unit went live), and the rating prompt
   (`lib/core/rating/rating_prompt.dart`) with its store provider.
2. **CLI.** The GA4 analytics-scoped credential from the day before had
   **expired** ("default credentials were not found"). The agent gave the owner
   the `gcloud auth application-default login …analytics.readonly` command to
   run, and did not wait: it carried on in the browser in parallel.
3. **Browser.** It checked the built-in browser first (the pane was not open,
   no tabs), confirmed Claude in Chrome was connected
   (`list_connected_browsers`), and did all dashboard work in Chrome without
   asking for site access.
4. Sources read: AdMob (apps, ad units, Reports → AdMob Network), Play Console
   (dashboard, Ratings, Statistics), Appodeal (Monetization split by network),
   GA4 (saved funnel exploration, cohort exploration, Reports → Events with App
   version, custom definitions).

## Findings, question by question

### 1. AdMob earns only on app open — by design

`LauncherAds._providerFor` sends `AdFormat.appOpen` to a direct
`AdMobAdProvider` and every other format to Appodeal. The only live AdMob unit
in `env/release.json` is `app_open_ad_id`; banner, interstitial, native and
rewarded are still `REPLACE_WITH_PROD_*` placeholders, which is harmless
because Appodeal serves those formats.

| Source | eCPM | Impressions |
|---|---|---|
| Direct AdMob App Open, last 30 days | $1.86 | 16 |
| Direct AdMob App Open, today (1.0.2) | $2.51 | 3 |
| Whole Appodeal stack, 7–14 Nov | $0.1278 | 577 |

Direct AdMob cleared 15–20× more per impression than Appodeal on the same
users. Its **show rate was 7.3%** over 30 days: fills loaded and mostly
discarded, the cheapest revenue win found.

### 2. AdMob by version

AdMob Network report with **App version** and **Ad unit** as dimensions:

- Last 30 days: one row, 1.0.1 App Open: 231 requests, 94.8% match rate,
  16 impressions, $0.03.
- Today: 1.0.2: 7 requests, 3 impressions, $0.01, 42.9% show rate. 1.0.1:
  38 requests, 2 impressions, 5.3% show rate.
- No 1.0.0 row ever. No Appodeal-created AdMob unit had a single request.

So AdMob served only the old version until that day, and the new one too from
then. Today's 1.0.2 rows were small enough to include the owner's own device.

### 3. AdMob and Meta in Appodeal

Appodeal, 7–14 Nov, split by network: AppLovin, AppLovin Max, Vungle, InMobi,
BidMachine, Meta, Test Ads, Service Messages. **No AdMob row.** AppLovin Max
recovered by itself (613 requests and 0 impressions on 13 Nov; 29 impressions
on 14 Nov). Week: $0.074, eCPM $0.1278, CTR 21.7%.

Why the consent fix had not landed: in GA4, on 1.0.2 that day,
`consent_resolved` fired for **18 of 18 users with `state = unknown`**
("not determined yet"); `obtained` and `notRequired` never appeared.
`ConsentGate` runs with `failOpen: true` and an 8-second timeout, so the
failure was silent. The GDPR message published the day before had not reached
a single measured session. Test: re-read `consent_resolved` → Consent state
the next day; the fix works only when `obtained`/`notRequired` appear.

Meta: 2 impressions on 10 Nov, none since; app review still "In review".

Instrumentation bug found here: `can_request_ads` and `form_available` were
sent as Dart `bool`s from `AppAnalytics.consentResolved`, and GA4 showed
**(not set)** for both, while the String `state` populated. Firebase event
parameters must be String, int or double.

### 4. New-version funnel

GA4 Explorations have **no same-day data**: the saved funnel run for "today"
showed step 1 and zeros after it, which looks like a total collapse and is
not. The agent built the funnel from **Reports → Events, date Today, secondary
dimension App version, 250 rows**: user counts per event, per version.

| 1.0.2, 14 Nov | Users |
|---|---|
| `first_open` | 21 |
| `launcher_entry_splash_started` | 18 |
| `launcher_entry_splash_completed` | 18 |
| onboarding shown / started | 18 |
| language confirmed, setup started | 15 |
| `setup_step_completed` | 13 |
| default requested → `launcher_set_default` | 8 |
| tutorial started → finished | 7 |

`first_open` → splash completed: **86%**, against 48.5% on 1.0.1 on 13 Nov
(99 → 48 → 46 → 27 → 22, from the saved exploration for yesterday) and 40.6%
in the 16 Oct–12 Nov baseline. `launcher_entry_splash_abandoned` never fired.
Set-as-default: 38% of new users against 11.6% before.

Stated limit: 21 users, one partial day, and early updaters are not a random
sample. Re-run the saved funnel with the App version breakdown in two or three
days.

### 5. Ratings

GA4 `rating_prompt_answered`: **125 events from 101 users** in 28 days. Play
Console → Ratings: **2 ratings, 5.0★**.

The code explains it. On Yes, `RatingPrompt._openStoreForRating` calls
`openStoreListing()`, which sends the user out of the launcher to the Play
listing. `requestReview()`, the native in-app review sheet, is called only from
a devtools page. And as soon as the listing opens, the app records
`RatingOutcome.submitted`, which the coordinator treats as a permanent
opt-out: the user is never asked again, rated or not.
`InAppReviewStoreProvider.requestReview()` already falls back to the listing
when the platform declines, so the fix is a one-line switch of the Yes path.

Unsettled: the card's `answer` parameter is not a registered GA4 dimension, so
the yes/no split could not be read in GA4 (Mixpanel has it). Play still showed
2 installed devices through 10 Nov; if that is not just lag, most users are not
Play installs and cannot rate.

### 6. Retention

GA4 cohort exploration, daily granularity, 17 Oct–13 Nov (all 1.0.1):

| Cohort | Users | D1 | D2 | D3 |
|---|---|---|---|---|
| 12 Nov | 45 | 12 (26.7%) | 7 (15.6%) | — |
| 11 Nov | 10 | 8 | 5 | 2 |
| 8 Nov | 11 | 0 | — | — |

D1 about 25%, up from the 15.2% card the day before. Weekly: the 8–13 Nov
cohort had 122 users, 17 returning in week 1. **1.0.2 had no retention figure
and could not have one**: it was 11 hours old. The earliest honest D1 was the
next day. The higher set-as-default rate suggested a higher ceiling.

## What was reported

In priority order: switch the rating Yes path to `requestReview()` (about 100
willing users a month); re-check consent state the next day before more AdMob
work; look at the 7% App Open show rate, since it is the only unit paying real
money. Nothing in the code was changed; findings were saved to memory.

## Review: what was good and what was weak

Good: it answered every question in its own section, said plainly when a
number could not exist yet (1.0.2 retention), refused to read a same-day
Exploration as a collapse, gave a concrete test for the consent fix, and
traced the ratings gap to a specific line of code with a one-line fix.

Weak: it raised again the idea that most users may not be Play installs,
which the first analysis had already settled as Play reporting lag (it did
label it as unresolved and gave a date to re-check). Its 1.0.2 funnel is
per-event user counts from a standard report, not an ordered funnel, and
some 1.0.2 AdMob rows may be the owner's own device. It changed no code, so
the rating and boolean-parameter fixes were left for the owner to approve.

## Methods this analysis added

- Split AdMob by **App version × Ad unit** to answer "which versions serve".
- Use **Reports → Events + App version** for same-day and per-version counts;
  Explorations lag a day.
- Read a **consent state event** to tell whether a consent fix is live.
- Compare **rating prompt answers with store ratings**, then read the Yes path
  in code.
- **Daily cohort exploration** for D1/D2 by install day.
- Check a new version's **rollout time** before talking about its retention.
- Start the browser work while the owner refreshes an expired CLI credential.
