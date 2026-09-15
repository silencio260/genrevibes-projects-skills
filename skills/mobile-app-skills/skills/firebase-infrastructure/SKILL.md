---
name: firebase-infrastructure
description: "Configure selected Firebase services and separate app backend data from kit adapters."
---

# Firebase setup

Use Firebase only for the services the app selects. The kit does not require
Firebase for settings, onboarding, local storage, or every other feature.

1. Inspect the existing project IDs, platform app registrations, and generated
   configuration. Keep development and production targets distinct.
2. If configuration is missing, prepare the specific FlutterFire setup for the
   intended project/platforms. Do not create cloud projects or deploy as a side
   effect of editing app code.
3. Initialize Firebase once before Firebase-backed adapters. Keep visible startup
   and bounded failure/retry through [runtime setup](../runtime-setup/SKILL.md).
4. Use selected kit adapters for analytics, crash reporting, remote config, auth,
   and database access. Read each feature's skill; none is wired automatically.
5. Keep Firestore collections, Storage paths, Functions endpoints, and app models
   in the app/backend. There is no universal profile or chat schema to copy.
6. Enforce ownership and allowed fields in database/storage rules and handlers.
   Authentication alone must not allow access to every user's chat or profile.
7. Keep server credentials on the backend. Client configuration is not authority
   to modify entitlements or quota.

For backend API changes, inspect installed SDK versions and current official
Firebase documentation. Do not copy old Genkit imports or deploy commands from
another app. Use [HTTP auth diagnosis](../../../firebase-functions-v2-auth/SKILL.md)
when a Gen 2 HTTP function returns 401/403.

Check selected services, target IDs, startup ordering, and access-rule scope.
Report deployment and device checks separately.

## Record the selected service map

Before changing configuration, make a small table of the intended environment,
Firebase project ID, Android application ID, iOS bundle ID, and enabled services.
Compare it with the existing generated options and native configuration files.
Do not infer the production target from whichever account the local CLI selected.

For each chosen service, identify both sides of the integration: the runtime
adapter and the backend/project setup. Authentication needs enabled providers;
database access needs collections and rules; remote config needs a schema and
refresh wiring. One successful `Firebase.initializeApp` does not prove those
services are configured or authorized.

Keep backend functions, rules, indexes, and deployment configuration in their
existing app-owned folders. Inspect installed package versions and entry points
before changing imports. If the app has no backend feature in scope, do not
create a generic Functions/Genkit scaffold simply because another app has one.

For a backend read/write, trace authenticated identity to the selected record
path and permitted fields. Client-provided IDs and premium flags are inputs,
not trusted authority. Separate expected user failures from infrastructure
failures so the UI does not suggest buying a subscription to fix a server error.

Report local source/configuration changes separately from deployed state. A rules
file on disk does not prove production uses those rules. Deploy only when the
user's request authorizes it and the exact target/change is established.
