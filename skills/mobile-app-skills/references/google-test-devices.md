# Google test devices: keep robots out of analytics

Play's pre-launch report and the review checks install every release on
Firebase Test Lab phones and tap through the app. Those sessions are robots:
counted as users they inflate installs, break first-launch funnels and add
fake sign-ups. Every portfolio app keeps them out of analytics.

## How it works

| Part | Where | What it does |
|---|---|---|
| Detection | `genrevibes_analytics_firebase` Android plugin (`GenRevibesAnalyticsFirebasePlugin`) | Reads the `firebase.test.lab` system setting, which Test Lab sets to `"true"` on its devices. |
| Dart API | `GoogleTestDevice.check()` in the same package | Asks the plugin once per process and caches the answer. False on iOS, web, and when it can't be read. |
| Firebase | `FirebaseAnalyticsSink` | Automatic. At `initialize` it turns Firebase collection off on a test phone and then sends no events, user IDs or user properties. Everywhere else collection is forced on, as the analytics rule requires. |
| Paid sinks | Each app's runtime bootstrap | The app leaves Mixpanel, PostHog and replay out of the pipeline on a test phone. |

This is the one exception to "Firebase Analytics can never be turned off" in
the [analytics skill](../skills/analytics/SKILL.md). It is not a user choice
or a remote switch, and it must not grow into one.

## What each app does

Nothing for Firebase: depending on the kit's `genrevibes_analytics_firebase`
is enough, and the plugin registers itself. For paid sinks, add one check where
the pipeline is built:

```dart
import 'package:genrevibes_analytics_firebase/genrevibes_analytics_firebase.dart';

final robot = await GoogleTestDevice.check();
final mixpanelSink = AppEnv.mixpanelToken.isEmpty || robot
    ? null
    : SwitchableAnalyticsSink(MixpanelAnalyticsSink(/* ... */));
```

Events an app sends straight to `FirebaseAnalytics.instance` before the
pipeline exists (early launch steps, for example) are not covered by the sink.
Either queue them until the pipeline is ready, or call
`setAnalyticsCollectionEnabled(false)` first when `check()` is true. Lunaris
does the latter in `main.dart` `_prepare`.

Do not copy the detection into an app's `MainActivity`; use the kit's.

## Limits

- **`first_open` still arrives**, once per test phone: Firebase logs it natively
  before any Dart runs. Filter Test Lab traffic in GA4 by device model or
  exclude it in explorations when exact install counts matter.
- **Android only.** There is no iOS equivalent signal.
- **Only Test Lab is detected.** A human reviewer on an ordinary phone, other
  emulators and the developer's own phones still count. Internal phones are a
  separate concern (debug builds, `test_device_ids`).

## Verify

1. Unit: `flutter test` in `genrevibes_analytics_firebase` covers the on,
   off and failed-check paths with an injected `isGoogleTestDevice`.
2. Device, without Test Lab: on a debug build run
   `adb shell settings put system firebase.test.lab true`, cold-start the app,
   and confirm with `adb shell setprop debug.firebase.analytics.app <package>`
   that DebugView shows no new events and Mixpanel's live view shows nothing.
   Afterwards run `adb shell settings delete system firebase.test.lab` and
   confirm events return. Newer Android versions may refuse a non-standard
   system key from the shell; if `settings get system firebase.test.lab` does
   not print `true`, rely on steps 1 and 3.
3. Release: after the next upload, the pre-launch report's devices should not
   appear in GA4 or Mixpanel beyond `first_open`.
