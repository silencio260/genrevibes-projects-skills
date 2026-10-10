# Test live ads in an Android debug run

Use this when the user wants real inventory while retaining Flutter debug tools.
The command below is the normal build-and-run path, not the prebuilt APK shortcut.
Documenting it does not authorize running a build; follow `agents/AGENTS.md` and
the user's current instructions.

## Select the current device

From the app root, list available Android devices:

```sh
adb devices -l
```

Use the exact ID in the first column for the intended phone whose status is
`device`. An `offline` or `unauthorized` entry is not ready to run. A USB device
uses its serial; a wireless device may use an IP and port or a discovery ID.

If the phone is not connected, use its current wireless debugging address and
port from Android's developer settings, or connect by USB. Wireless pairing may
be required first. The pairing port and connection port can differ. For a phone
configured for TCP ADB, use that connection's current address and port.

**Do not permanently hardcode `10.235.107.187:5555`.** That was the phone's
address during the recorded session; both IP and port can change. Refresh the
device ID when changing networks or reconnecting the phone.

## Run live diagnostics

Replace `CURRENT_DEVICE_ID` below with the selected device ID, then run:

```sh
device_id='CURRENT_DEVICE_ID'
flutter run --debug --dart-define-from-file=env/dev.json --dart-define=ads_live_diagnostics=true -d "$device_id"
```

The original session command, kept only as an example, was:

```sh
flutter run --debug --dart-define-from-file=env/dev.json --dart-define=ads_live_diagnostics=true -d 10.235.107.187:5555
```

Keep the app's real platform Appodeal app key in its existing development
configuration. Test inventory is an SDK mode; a fake key does not enable it.
Do not print credentials while inspecting configuration or launch arguments.

## Confirm the flag actually controls the SDK

In Story Saver, `lib/bootstrap/app_env.dart` reads `ads_live_diagnostics` through
`bool.fromEnvironment` (default false). `AppEnv.adTestModeFor` requests live
inventory when the app is in development and the flag is true. In
`lib/bootstrap/app_bootstrap.dart`, both the provider's initial `testMode` and
the later developer-access listener use that same method. This prevents a Lab
access change from silently restoring test mode during a live diagnostic run.

For another app, trace or implement this wiring before claiming the command
works. A Dart define with no reader has no effect. Preserve the app's premium,
consent, suppression, placement eligibility and format switches; the live flag
changes inventory mode, not whether every placement must show an ad.

Start a fresh app process when changing inventory mode so the SDK initializes
with the requested mode. Hot reload alone does not reinitialize it. Inspect
SDK/Lab initialization logs to confirm actual `testMode=false`; the launch
command or a creative's appearance alone is not proof. Distinguish requests,
successful loads and impression callbacks when diagnosing missing ads. A live
request can still receive no fill even when test inventory worked.

To return to the normal developer/test-mode policy, stop the live run and start
a fresh run without `--dart-define=ads_live_diagnostics=true`. Inspect the app's
developer-access policy rather than assuming every debug build defaults to test
mode. The override is ignored outside development in Story Saver.

For slow native builds after adding mediation, read
[Android debug build performance](android-debug-build-performance.md).
