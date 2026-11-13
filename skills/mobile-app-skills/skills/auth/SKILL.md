---
name: auth
description: "Connect neutral kit authentication and a selected adapter to app identity flows, including Firebase Google sign-in on Android (SHA-1s, release keep rule, diagnosis)."
---

# Authentication

Use `AuthProvider` and the chosen adapter. Firebase uses `FirebaseAuthProvider`
and requires host Firebase initialization first.

1. Select the requested sign-in methods. Federated requests carry tokens;
   acquire Google/Apple tokens through the app's selected sign-in integration.
2. Follow authentication changes and map the current identity into app state.
   Handle normalized `AuthFailureReason` values instead of vendor message strings.
3. Link credentials when converting an anonymous account. Signing into a separate
   account can otherwise orphan guest data; define any merge in the app/backend.
4. Handle reauthentication when deletion or another sensitive operation requires
   a recent login. Keep passwords and tokens out of analytics/replay/logs.
5. Connect purchase, analytics, and push identity changes explicitly. Reset them
   on logout and prevent older asynchronous results from restoring the old user.
6. Cancel listeners with the runtime.

Profiles and backend authorization belong to the app. Signing in does not
create a universal profile schema or automatically restore purchases.
Check cancellation, wrong credentials, account linking, logout, and account switch.

## Implement authentication as a feature and an identity source

Keep sign-in screens and BLoC in the auth feature, credential acquisition in its
data layer, and the selected neutral provider in the runtime. Register the
provider once. The app's identity/session owner subscribes to auth changes and
updates routing; a sign-in screen is not the owner of the whole app session.

Before implementing a method, establish which platform configuration and token
acquisition it needs. The kit's federated request accepts credentials from that
integration; it does not create a Google or Apple sign-in UI automatically.
Use the installed adapter's exported request types and normalized failure reasons.

## Google sign-in on Android with Firebase

The kit does not acquire Google tokens. The app adds `google_sign_in` (7.x
uses Android Credential Manager), gets an ID token, and hands it to Firebase
with `GoogleAuthProvider.credential(idToken: …)` or the kit's federated request.
A setup gap usually works in debug and fails only in release or Play installs,
so test Google sign-in on an installed **release** build, not just in a debug run.

### Setup checklist

1. **Enable Google in Firebase Authentication.** This creates the web OAuth
   client. The downloaded `android/app/google-services.json` must have an
   `oauth_client` entry with `"client_type": 3`; the google-services Gradle
   plugin turns it into the string resource `default_web_client_id`.
2. **Register every signing key's SHA-1 (and SHA-256)** in Firebase project
   settings → Android app: the debug keystore, the upload/release key, and the
   Play App Signing key (Play Console → Test and release → App integrity). Then
   download `google-services.json` again into `android/app/`. A key that is not
   registered fails only for builds signed with it. For example, Play installs
   fail when only the upload key is registered.
3. **Keep `default_web_client_id` through release resource shrinking.** Flutter
   release builds shrink resources by default. `google_sign_in_android` looks
   the string up by name (`getIdentifier()`), so the shrinker cannot see the use
   and removes it. Add it to `android/app/src/main/res/raw/keep.xml`. If the app
   already has that file, extend its comma-separated list; a second file with
   the same name would replace the first.

   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <!-- default_web_client_id: read by google_sign_in_android with getIdentifier().
        Without it, Google sign-in fails in release builds only. -->
   <resources xmlns:tools="http://schemas.android.com/tools"
       tools:keep="@string/default_web_client_id" />
   ```

   Passing `serverClientId:` to `GoogleSignIn.instance.initialize()` also avoids
   the lookup. Prefer the keep rule, because `google-services.json` then stays
   the single source of the client id. Add it to every app that uses
   `google_sign_in`; it costs nothing.
4. **Check the release bundle before uploading.** Build device APKs from the
   AAB with bundletool (see
   [android release build](../android-release-build-experiment/SKILL.md)), then
   run `aapt2 dump resources <base-master.apk> | grep default_web_client_id`. No
   output means sign-in is broken in that build.

### Implement the token request

- Call `GoogleSignIn.instance.initialize()` once and memoize the future. Then call
  `authenticate()` and read `account.authentication.idToken`. Treat a null token
  as an error, not a cancellation.
- Catch `GoogleSignInException`. Treat `canceled` as the user backing out, with
  no error message. Show a sign-in error for the other codes.
- Log `error.code.name` and `error.description` with `debugPrint`, which also
  prints in release builds. Credential Manager reports some setup failures as
  `canceled`, so without this log a broken release build leaves no trace. Never
  log tokens.
- On logout, also call the Google sign-out after Firebase sign-out, so the next
  Google sign-in shows the account picker again.

### Diagnose a failing release build

Read the app's logged line with `adb logcat -d | grep "Google sign-in"`.

| Logged code / symptom | Cause |
| --- | --- |
| `clientConfigurationError`, no `serverClientId`, before any account picker | `default_web_client_id` was removed by shrinking (step 3) or is missing from `google-services.json` (step 1) |
| Picker never appears and the result is `canceled`, or a "developer console is not set up correctly" error | The SHA-1 of the key that signed this install is not registered (step 2) |
| Works from a sideloaded release, fails from Play | The Play App Signing key's SHA-1 is not registered (step 2) |

The app's generic "check your connection" message is not evidence of a network
problem. Lines like `Unable to resolve host` logged while the app is in the
background come from Android blocking background network access, and are not the
cause. Lunaris Network (13 Nov 2026) hit exactly this: debug sign-in worked, and
release builds showed a network-style error until `default_web_client_id` was kept.

### Handle a change of account in order

1. Stop subscriptions and in-flight UI updates associated with the old account.
2. Update the app session and attach the new account's repositories/subscriptions.
3. Identify the new account in the selected purchases, analytics, and push
   integrations; handle each result rather than assuming all succeeded.
4. On logout, reset those identities and remove only account-owned cached data.
5. Use an account/session generation check for late asynchronous results so an
   old profile or entitlement result cannot replace the new account's state.

Account creation, profile creation, purchase identity, and authentication are
separate operations. If profile creation fails after sign-in, offer recovery
without repeatedly creating new authentication accounts. If converting a guest,
choose link-versus-merge behavior before implementing the button.

Deletion needs an explicit backend/data policy as well as authentication removal.
Use reauthentication when required, report partial failure, and do not claim all
user data was removed merely because the authentication account disappeared.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_auth](../../../../../packages/genrevibes_starter_kit/modules/auth/genrevibes_auth/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/auth/genrevibes_auth/lib/genrevibes_auth.dart).
- [genrevibes_auth_firebase](../../../../../packages/genrevibes_starter_kit/modules/auth/genrevibes_auth_firebase/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/auth/genrevibes_auth_firebase/lib/genrevibes_auth_firebase.dart).
