# Launch journey: first-launch funnel from events

Every portfolio app measures the path from a cold start to its home screen
with the starter kit's `LaunchJourney` (`genrevibes_analytics_firebase`). It
answers "where do new installs stop?" from plain events, without trusting
GA4's screen-context totals. Lunaris was the first app; its event list is in
its `docs/analytics-events.md`.

## What it records

| Piece | Events / parameters | Use |
|---|---|---|
| Launch count | `launch_number` on every event | Separate first, second and later launches. Reinstall restarts at 1. Installs onboarded before the journey existed start at 3. |
| Prefixed copies | `l1_<event>`, `l2_<event>` before home on launches 1–2 | A GA4 funnel on `l1_*` is a first-launch funnel with no filtering. Revenue (`ad_impression`, `value`/`currency`) is never copied. |
| Steps | `app_launch`, configured screen steps, `no_internet_shown`, `home_reached`, app steps; all with `ms_since_launch` | Order and duration of each startup stage. |
| Leaving | `splash_abandoned`, `journey_left_app` / `journey_resumed` (`away_ms`), `previous_launch_abandoned` (`step_reached`, `previous_ms`) | A leave is the last step with no `home_reached`; left-then-resumed is an interruption. |

Events sent before analytics exists are held and flushed in order. Google's
test devices send nothing ([Google test devices](google-test-devices.md)).

## Adding it to an app

Follow the wiring in the `genrevibes_analytics_firebase` README. In short:

1. Describe the app's path once (Lunaris: `lib/features/analytics/launch_journey.dart`):

   ```dart
   const appLaunchJourney = LaunchJourneyConfig(
     homeScreen: 'tab_home',          // the screen_view that ends the path
     screenSteps: {                   // screen_view name → step event
       'splash': 'splash_shown',
       'language_select': 'language_select_shown',
       'welcome': 'welcome_shown',
     },
   );
   ```

2. `LaunchJourney.instance.start(appLaunchJourney)` in `main()` right after
   the binding initializes.
3. `attach(send:, store:, alreadyOnboarded:)` once the analytics pipeline is
   built; `attachDirectToFirebase(store:)` when startup fails before it.
4. Route the app's single `track` method through `deliver`, and call
   `screenShown` from the screen tracker, including before the runtime is
   registered (the splash).
5. Optional: `stepOnce` for startup stages (Firebase ready, runtime ready,
   consent, launch-ad decision and load, account check), `launchAdShown` /
   `splashFinished` from the splash ad, and `splashCapReached` if the app caps
   its splash.
6. Add the app's events to its analytics doc and register `launch_number`,
   `ms_since_launch` and `step_reached` as GA4 custom dimensions.

Keep event names identical across apps for shared steps (`splash_shown`,
`language_select_shown`, `home_reached`, `startup_runtime_ready`,
`launch_ad_decision`, `account_check_finished`) so funnels compare.

## Rules

- Don't send `screen_view` through `deliver`; GA4 reserves it and the steps
  already cover the path's screens.
- Don't add new revenue events without checking they stay uncopied.
- One `LaunchJourney.instance` per process. Tests use
  `LaunchJourney.forTesting` with `MemoryKeyValueStore`.
- GA4 has a 500-distinct-event limit per app: `l1_`/`l2_` copies double the
  names used before home, so keep pre-home events few and stable.

## Reading it

- First-launch funnel: GA4 Exploration › Funnel on `l1_app_launch` →
  `l1_splash_shown` → `l1_language_select_shown` → … → `l1_home_reached`,
  open funnel off.
- Where people quit: `previous_launch_abandoned` by `step_reached`, plus
  `splash_abandoned` with `during_launch_ad`.
- Slow stages: `ms_since_launch` on each step by device and country.
- At a few dozen installs a day, report counts, not percentages.
