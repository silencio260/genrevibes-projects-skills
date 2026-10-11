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

## Lunaris implementation

Lunaris did not read the flag at first. In a debug build developer access is
always granted, and `servesTestAds` follows access, so every debug run got test
inventory whatever was passed. It now follows the Story Saver wiring:

- `lib/bootstrap/app_env.dart` reads `ads_live_diagnostics` and exposes
  `AppEnv.adTestModeFor(access, liveOnThisDevice:)`. Live inventory when the
  build is in development (`kDebugMode || development_mode`) and the flag is
  true, or when the device switch below is on; otherwise `access.servesTestAds`.
- `lib/bootstrap/app_bootstrap.dart` uses it for the provider's initial
  `testMode`, the developer-access listener and the device switch's listener.

## Set the flag in the env file

Development env files (`env/dev.json`, `env/special_dev.json`) and the tracked
`env.example.json` carry `"ads_live_diagnostics": false`. Set it to `true` in the
env file for a live run, or keep it false and pass
`--dart-define=ads_live_diagnostics=true`. The command-line value wins:
flutter_tools adds `--dart-define-from-file` values first and `--dart-define`
values after them (`extractDartDefines` in `flutter_command.dart`), and the later
define of a key takes effect.

## Per-device switch in the developer section

A run flag needs a rebuild. For a developer phone that should see live ads across
runs, Lunaris adds **Settings › Developer › Live ads**:

- `lib/features/developer/live_ads_switch.dart`: `LiveAdsSwitch`, a
  `ValueNotifier<bool>` saved in the app's `KeyValueStore`
  (`lunaris.dev.live_ads`), loaded before the ad provider is constructed and
  registered in the runtime and GetIt.
- Changing it calls `setTestMode` with the new decision. The Appodeal provider
  then withholds inventory until the next launch (the SDK fixes its mode at
  start), so the row and its snackbar say to fully close and reopen the app.
- It only matters while developer access is granted; without access the app
  already serves live inventory.
- The starter kit's Kit Lab shows "test inventory / live inventory" from
  `servesTestAds` only, so it does not reflect either override. Check the SDK's
  initialization log for the real mode.

Do not tap live ads or replay them repeatedly from a developer device: ad
networks treat that as invalid traffic and can restrict the account. Turn the
switch off (or drop the flag) once the live check is done.

For slow native builds after adding mediation, read
[Android debug build performance](android-debug-build-performance.md).
