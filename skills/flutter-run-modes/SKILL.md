---
name: flutter-run-modes
description: "Pick the flutter run command for live Firebase, live data with local Cloud Functions, or fully local emulators, on a phone or the Android emulator."
---

# Flutter run modes

The app reads these defines in `lib/config/backend_config.dart`. Pick the
backend mode, then the device line.

Keep the app-specific commands, including its environment file and build mode,
at the top of the app's `README.md` and `docs/commands.md`. Follow
[command documentation](../mobile-app-skills/skills/command-documentation/SKILL.md)
when a recipe changes; the examples below explain backend routing, not every
app's complete environment configuration.

Agents: give these commands to the user to run; don't build, install or run the
app yourself.

## 1. Live Firebase (no local backend)

```bash
flutter run
```

## 2. Live data, local functions

Auth and Firestore stay on the live project; callables go to the functions
emulator on the Mac (port 5001), which reads and writes the real project.
Use it to test function changes before deploying.

Start the backend first:

```bash
cd backend/functions && npm run serve:live
```

Phone over Wi-Fi / hotspot:

```bash
flutter run --dart-define=USE_FUNCTIONS_EMULATOR=true --dart-define=EMULATOR_HOST=$(ipconfig getifaddr en0)
```

Phone over USB (run `npm run usb` in `backend/functions` first):

```bash
flutter run --dart-define=USE_FUNCTIONS_EMULATOR=true --dart-define=EMULATOR_HOST=127.0.0.1
```

Android emulator:

```bash
flutter run --dart-define=USE_FUNCTIONS_EMULATOR=true
```

## 3. Everything local (Auth, Firestore and Functions emulators)

No live data is touched. Start the backend first:

```bash
cd backend/functions && npm run serve
```

Phone over Wi-Fi / hotspot:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=EMULATOR_HOST=$(ipconfig getifaddr en0)
```

Phone over USB (run `npm run usb` in `backend/functions` first):

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=EMULATOR_HOST=127.0.0.1
```

Android emulator:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

## Notes

- `USE_FIREBASE_EMULATORS=true` already implies `USE_FUNCTIONS_EMULATOR`; don't
  pass both.
- Wi-Fi: the phone and the Mac must be on the same network. The Mac's address
  changes whenever it reconnects to a hotspot; rerunning the command re-reads
  `en0`.
- USB: rerun `npm run usb` after every reconnect (it `adb reverse`s ports 9099,
  8080 and 5001).
- Without `EMULATOR_HOST` the app uses `10.0.2.2`, the Android emulator's alias
  for the Mac, which a real phone can't reach.
- Use a debug build (the `flutter run` default): only debug builds use the App
  Check debug provider. If the backend has `ENFORCE_APP_CHECK=true`, register
  the token it logs in Firebase console › App Check › Manage debug tokens.
