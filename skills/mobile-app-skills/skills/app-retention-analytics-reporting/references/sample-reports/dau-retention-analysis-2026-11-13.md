> Sample report. Written to the app repo as `docs/dau-retention-analysis-2026-11-13.md` at the end of the first Gravity analysis. The owner liked this format; use it as a model. Context: [case study](../case-study-gravity-2026-11.md).

# Rolling Icon DAU and retention analysis — 13 November 2026

## Conclusion

The observed audience is small and concentrated in a recent acquisition spike.
Aggregate onboarding counts indicate substantial loss before completion and
default-launcher adoption. Real Flutter errors also affect core interactions.
Crashlytics severity classification exaggerates actual process crashes, while
several custom event names and session counters are unsuitable as install or
day-based retention metrics. These findings explain plausible mechanisms, but
do not quantify each mechanism's causal contribution to D1 retention.

No app code, live configuration, campaigns or saved analytics reports were
changed for this analysis. Existing uncommitted work was preserved.

## Sources and windows

- Firebase project: `rolling-icon-gravity-launcher`; GA property `560168056`.
- Firebase overview, retention and events: 16 October–12 November 2026.
- Firebase headline DAU: 94 for the latest day shown, 12 November.
- Firebase D1 overview card: 15.2%; its displayed chart window was
  4–10 November. This is not the D1 rate of the 11 November spike.
- Crashlytics: last seven days, 7–13 November, with the current day incomplete.
- Mixpanel: Gravity Launcher App, project `4081621`, All Project Data.
- Appodeal: Gravity Rolling Launcher, app `789242`, 7–13 November.
- Play Console dashboard: many acquisition/vitals metrics unavailable during
  inspection. Its release install card is not a verified acquisition total.
- Local source: current workspace, including pre-existing uncommitted changes.
  Source behavior is not proof of behavior in the installed production binary.
- Shared guidance refresh was attempted but failed because GitHub DNS was
  unavailable. Local guidance was read; its checkout reported `main...origin/main`.

## Audience and activity

| Metric | Observed value |
|---|---:|
| Firebase 30-day active users | 198 |
| Firebase 7-day active users | 197 |
| Firebase latest complete-day active users | 94 |
| Firebase new users in selected 28 days | 155 |
| Firebase returning users in selected 28 days | 32 |
| Firebase average engagement per active user | 6m 31s |
| Firebase average engagement per session | 4m 13s |
| Firebase engaged sessions per active user | 1.2 |
| Mixpanel past-week unique users | 108 |

Mixpanel daily unique users in the inspected line report:

| Date | Users |
|---|---:|
| 6 November | 0 |
| 7 November | 0 |
| 8 November | 8 |
| 9 November | 0 |
| 10 November | 9 |
| 11 November | 54 |
| 12 November | 42 |
| 13 November, incomplete | 17 |

The 54-to-42 change is a 22.2% decrease in daily totals, not 77.8% D1
retention. The identities and acquisition dates must be joined to calculate
retention. Returning-user and new-user totals are not mutually exclusive sets.
Neither 32/155 nor 94/197 is a D1 retention calculation.

The near-equality of Firebase 7-day and 30-day audiences, together with the
recent spike visible in its new-user chart, means the headline audience has
little established history in the observed data. Changes in acquisition volume
can dominate DAU. Older users, new users and reactivated users must be separated
before attributing a daily change to retention.

## Activation and uninstall evidence

Firebase event report, same selected 28-day period:

| Event | Events | Unique users |
|---|---:|---:|
| first_open | 155 | 155 |
| onboarding_started | 142 | 100 |
| onboarding_default_requested | 164 | 62 |
| onboarding_completed | 70 | 60 |
| launcher_tutorial_finished | 66 | 58 |
| launcher_set_default | 52 | 46 |
| app_launched | 853 | 52 |
| app_remove | 73 | 71 |
| app_library_opened | 391 | 39 |
| pattern_mode_selected | 603 | 32 |
| mini_app_open | 205 | 38 |
| local_notification_posted | 3 | 3 |

Completion/start is 60%; default-set/request is approximately 74.2%.
These are aggregate ratios, not ordered cohort conversion rates. Upgrades,
prior onboarding, collection coverage, repeat events and different user sets
prevent treating them as a verified funnel. Still, the largest visible
activation gap is before completed setup. The final tutorial counts are much
closer to completed setup, suggesting the earlier flow deserves first attention.

The current source calls `launcherSetDefault(true)` after a successful role
check in setup. That event records an adoption action, not continuing default
status on later days. Measure D1/D7 separately for people who successfully
became default and those who did not.

`app_launched` means opening another app through the launcher. The 853 events
are not 853 launches of Rolling Icon. The 71 users with `app_remove` are strong
evidence of actual churn, but 71/155 is not a matched-cohort uninstall rate.

Current setup includes language, illustrated introduction, wallpaper, app
selection, pattern selection, preview and default selection, followed by the
tutorial. `_previewDone()` also requests a rating before the default step.
This is a plausible source of delay and interruption before adoption. Actual
step-by-step abandonment and an experiment are needed to establish causality.

## Reliability: real errors and misleading fatal classification

Crashlytics showed 650 crash-classified events, 114 affected users,
20.16% crash-free users and 27% crash-free sessions for its seven-day window.

| Issue | Events | Users |
|---|---:|---:|
| FeedbackNest telemetry POST / failed DNS lookup | 412 | 114 |
| Bloc emit after close, three variants | 144 | 45 |
| Missing cached icon file | 25 | 4 |
| Theme picker null assertion | 17 | 5 |
| Settings-background picker null assertion | 15 | 2 |
| Localization lookup null assertion | 13 | 2 |
| Gesture picker null assertion | 11 | 2 |
| Home text-color picker null assertion | 6 | 2 |
| Dock color picker null assertion | 4 | 2 |
| Wallpaper thumbnail connection timeout | 3 | 1 |

Issue-user counts overlap and must not be added. The issue list above accounts
for all 650 events. FeedbackNest contributes 63.4% of events; Bloc lifecycle
errors contribute 22.2%.

`lib/main.dart` reports uncaught zone errors with `fatal: true`. Shared
`CrashHooks` similarly labels framework/platform/zone exceptions fatal.
Consequently, an ordinary failed background request can degrade crash-free
metrics without killing Android's process. The displayed 79.84% affected
fraction is not evidence that Android force-closed for 79.84% of users.

The current shared FeedbackNest client already contains a child-zone guard for
the unawaited SDK telemetry request. Confirm the exact shipped kit revision and
new-release events before claiming that fix is deployed or effective. Existing
local Cubit guards also do not establish that the affected production release
contains them. Picker and cache errors still warrant investigation because
they directly affect visible launcher behavior.

## Appodeal and monetization

| Date | DAU | Impressions | Clicks | eCPM | Sessions/user |
|---|---:|---:|---:|---:|---:|
| 11 November | 42 | 47 | 12 | $0.2519 | 4.762 |
| 12 November | 46 | 118 | 27 | $0.0779 | 11.348 |
| 13 November, incomplete | 24 | 19 | 3 | $0.0000 | 0 |

12 November had approximately 2.57 Appodeal impressions per SDK-counted active
user. Aggregate impression volume alone does not establish excessive ad load;
format, placement and timing before activation matter. Account totals include
other apps and must not be used for this launcher. The selected retention and
revenue measures did not all appear in the rendered report, so no Appodeal D1,
D7 or total-revenue claim is made.

Firebase reported $5.10 ad revenue from 85 `ad_impression` events across 27
users over its selected 28 days. This is not directly comparable to a single
Appodeal day's figures; AdMob app-open inventory is also wired separately.
Revenue reconciliation requires matched dates, provider, ad format, test/live
status, actual/estimated revenue and callback coverage. No profitability or
paid-acquisition ROI conclusion is supported by this inspection.

## Measurement pitfalls found in source

- `app_install_event` is an Android package broadcast about apps on the phone:
  924 events from 41 users are not 924 installations of Rolling Icon.
- `app_launched` records an external app launch, not a new Rolling Icon user.
- `retention_day_0_returned` is emitted during day-zero opens; it is not D1.
- Runtime records another custom session on every paused-to-resumed transition,
  without a minimum background duration. Returning from another app, role
  selection or an ad can increase custom session counters. Firebase's automatic
  session definition is separate.
- The custom D1/D7 milestone events had one user each. They do not replace
  cohort retention reports; current resume tracking and milestone triggering
  need to be checked against the production revision.
- Firebase, Mixpanel and Appodeal have materially different coverage. Matching
  timezones, dates, release versions and collection settings remains necessary.
  The exact reason for every cross-provider difference was not established.

## Prioritized next actions

1. Verify production release provenance and resolve the visible Bloc lifecycle,
   picker/localization and icon-cache errors. Contain recoverable background
   failures and report them with appropriate severity.
2. Build an ordered first-open-to-completed-setup funnel, split by app version,
   acquisition source and country; measure each onboarding step separately.
3. Split D1/D7 by successful default adoption and compare the same install
   cohorts. Inspect the 11–12 November acquisition spike independently of older
   cohorts. Most spike users had not reached D7 at inspection time.
4. Experiment with a usable launcher preview earlier, fewer mandatory choices,
   and a rating request after successful everyday use. Preserve saved choices.
5. Compare pre-activation ad exposure against completion and D1. Do not infer
   invalid traffic or causality from aggregate CTR.
6. Standardize reporting on automatic `first_open`, unique users and explicit
   return events. Keep package broadcasts, external app launches and custom
   session ordinals out of acquisition/retention denominators.

## Limits

This was read-only dashboard and source inspection, not a randomized experiment
or a raw per-user cohort export. Acquisition-source quality, exact step
abandonment, production fix coverage and each cause's effect size remain
unverified. Play acquisition metrics were unavailable in the inspected view.
No build, test suite or release was run.

Primary metric references:

- https://firebase.google.com/docs/crashlytics/crash-free-metrics
- https://firebase.google.com/docs/crashlytics/flutter/customize-crash-reports
- https://support.google.com/analytics/answer/11004084
