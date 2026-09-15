---
name: crashlytics
description: "Connect kit crash reporting to Firebase Crashlytics and app error hooks."
---

# Crash reporting

Use `CrashCoordinator` from `genrevibes_crash` and `CrashlyticsReporter` plus
`CrashHooks` from the Crashlytics adapter. This does not require ads or purchases.

1. Initialize Firebase before the reporter. Supply
   `CrashReportingConfig(collectionEnabled: ...)` from the app's build policy.
2. Install framework/platform hooks once. Route uncaught zone errors to the
   active coordinator; keep Flutter binding creation and app startup in the
   same zone when using a guarded zone.
3. If the app uses BLoC, route observer errors as nonfatal reports without also
   reporting the same error from another listener.
4. Preserve and restore previous global hooks when a runtime is replaced.
   Register cleanup before any later startup work can fail.
5. Follow the installed adapter's platform setup for Android and iOS targets.
   Verify symbol handling against the actual release toolchain; do not paste
   old Gradle versions or assume an Android setup covers iOS.

Expected network/cancelled outcomes belong in feature error handling. Keep the
original stack for unexpected failures and avoid credentials or user content
in report metadata. A reporting failure must not replace the original error.

Report device verification separately. Do not trigger a deliberate crash or
publish a release merely to complete a source review.

## Connect error reporting at the app boundary

Initialize Firebase before constructing/initializing its crash adapter. Give
the runtime one crash reporter, and connect Flutter framework and uncaught
asynchronous error hooks once. Preserve any existing reporting chain deliberately;
do not overwrite a previous handler without deciding how its behavior survives.

A handled repository failure should become app failure state. Report it as an
unexpected error only when useful, with a stable operation name and stack where
available. User cancellation, permission denial, and no network are not all
fatal crashes. Avoid reporting the same exception from the adapter, repository,
BLoC, and global hook.

At startup, keep enough fallback logging to diagnose a crash adapter that cannot
initialize. The reporting SDK failing must not recursively report through itself
or block the app. On runtime retry, restore/remove hooks according to their owner
so they do not refer to a disposed reporter.

Use safe app/version/feature context. Never attach credentials, form contents,
full notification payloads, or private file paths. Verify hook wiring by reading
the active startup code. A deliberately triggered crash or a release/device
verification is a separate action; do not claim delivery was verified by static
inspection or trigger a crash without the user requesting it.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_crash](../../../../../packages/genrevibes_starter_kit/modules/crash/genrevibes_crash/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/crash/genrevibes_crash/lib/genrevibes_crash.dart).
- [genrevibes_crash_crashlytics](../../../../../packages/genrevibes_starter_kit/modules/crash/genrevibes_crash_crashlytics/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/crash/genrevibes_crash_crashlytics/lib/genrevibes_crash_crashlytics.dart).
