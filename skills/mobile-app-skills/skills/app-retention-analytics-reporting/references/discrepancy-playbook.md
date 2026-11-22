# Discrepancy playbook

Firebase, Mixpanel, Appodeal and Play usually report different "users" for the
same day. They are mostly measuring different things, not disagreeing. Work
through this list before calling any of them wrong.

## What each tool counts

| Tool | "Users" means | Starts counting | Notes |
|---|---|---|---|
| Firebase / GA4 | Devices with any event, including automatic ones | SDK init | Automatic: `first_open`, `session_start`, `user_engagement`, `screen_view`, `app_remove`, `app_exception` |
| Mixpanel (Flutter) | Distinct ids with at least one event **the app sent** | First tracked event | Auto-tracks nothing; no session event unless the app sends one |
| Appodeal | Users with an ad SDK session | After consent and ad SDK init | Skipped for premium users; zero for screens where ads never initialise |
| Play Console | Devices with the app installed | Install | Lags 2–3 days; small numbers hidden below a threshold |
| Crashlytics | Devices that reported a crash or "fatal" error | First report | "Fatal" is whatever the app's hook flags fatal |

So "GA4 active users" vs "Mixpanel DAU" is not a comparison. Compare one
event that the app sends to both.

## Checklist

1. **Same day?** Read each tool's reporting timezone. Gravity's GA4 was on a
   fixed GMT+01:00 and Mixpanel on US/Pacific: a 9-hour offset, so the two
   "12 November"s overlapped for 15 hours. A ratio that differs between events
   (72% for one, 83% for another) points to a clock offset rather than lost
   events, because events cluster at different hours.
2. **Same event?** Pick an event the app sends to both sinks. Never an
   automatic Firebase event.
3. **Same complete day?** Exclude today; Appodeal revenue also settles late.
4. **Same history?** Check when each project was created. Gravity's Mixpanel
   project started 7 November, so any longer comparison was void.
5. **Same pipeline?** Confirm in code that one pipeline feeds both sinks, with
   the same identity and the same consent rule. If so, routing, identity and
   consent are ruled out.
6. **Same app?** Filter Appodeal and AdMob to the app; account totals include
   other apps.
7. **Same build?** Debug builds that share the release keys pollute live
   dashboards (Appodeal Test Ads rows).
8. **Same denominator?** New users (`first_open`) for retention and funnels;
   active users only for activity.

## Aligning timezones (a change: needs a yes)

- Mixpanel: Project settings → Overview → Timezone. Only named zones exist.
- GA4: Admin → Property settings → Reporting time zone. Prefer the DST-aware
  named zone for the property's country (for the UK, "United Kingdom Time")
  over a fixed offset.
- Neither change is retroactive: past days are re-bucketed, so expect a
  one-off discontinuity on the change date. Tell the owner.

## Measured example: Gravity, 12 November 2026

| Event | GA4 users | Mixpanel uniques |
|---|---|---|
| `onboarding_page_viewed` | 43 | 31 |
| `workspace_page_changed` | 35 | 29 |

GA4 active users that day: 97; Appodeal active users: 46. Causes: 9-hour
timezone offset, Firebase automatic events, Mixpanel created on 7 November,
and Appodeal counting only ad SDK sessions. Both tools were moved to UK time.

## Other numbers that are not what they look like

- **Event totals are not users.** `app_launched` (Gravity: 853 events, 52
  users) counted launches of *other* apps through the launcher.
- **Package broadcasts are not installs.** `app_install_event` counted other
  apps being installed on the phone.
- **Day-0 events are not D1.** `retention_day_0_returned` fires on day zero.
- **Custom session counters** that increment on every resume overcount: coming
  back from an ad, a system dialog or another app is a "session".
- **A lazily created event** may fire later than its name suggests. Gravity's
  `onboarding_started` fired on the first swipe because its `BlocProvider` was
  lazy, so it matched `onboarding_page_viewed` exactly.
- **Crash-free users** sinks when non-terminating errors are flagged fatal.
- **A same-day Exploration is empty past step 1.** Explorations process with
  a delay; standard reports include today.
- **(not set) on a parameter you know is sent** usually means it was sent as
  a boolean, or it is not registered as a custom dimension.
- **Direct network vs mediation eCPM** are different inventories: Gravity's
  direct AdMob App Open cleared $1.86–2.51 while all of Appodeal cleared
  $0.13. Compare like formats before calling one stack better.
- **Prompt answers vs store ratings:** 101 users answered the rating card,
  Play had 2 ratings. The hand-off to the store, not the users, lost them.
- **A falling daily total is not a retention rate.** 54 → 42 users is a 22%
  drop in volume, not 78% D1 retention; cohorts need joined identities.
