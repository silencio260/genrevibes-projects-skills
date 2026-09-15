---
name: auth
description: "Connect neutral kit authentication and a selected adapter to app identity flows."
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
