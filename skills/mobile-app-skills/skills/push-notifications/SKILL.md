---
name: push-notifications
description: "Connect OneSignal or another push provider with identity, permission, and tap routing."
---

# Push notifications

Use `PushNotificationProvider`; OneSignal uses `OneSignalPushProvider` and
`GenRevibesOneSignalConfiguration`. Add the adapter only if the app needs push.

1. Configure the app ID and native push setup for the selected platforms.
2. Initialize once. Request permission at an appropriate user action using the
   app's permission flow, not an unconditional launch prompt.
3. Connect user identity and reset it on logout/account change. Send only the
   tags the app needs; do not copy another app's segmentation automatically.
4. Distinguish OS permission, provider opt-in, subscription ID presence, and
   token presence. A single “enabled” boolean cannot explain every state.
5. Route interactions through the app router after startup and any auth/onboarding
   checks. Validate payload destinations; do not navigate to arbitrary strings.
6. Cancel listeners at shutdown. Track IDs and named actions without logging
   notification text, tokens, or full payloads.

Use [local notifications](../local-notifications/SKILL.md) for reminders and
in-app generated notices. Adding push does not require a second local scheduler.
Check denied permission, provider opt-out, logout, and cold/warm tap routing.

## Wire delivery, identity, and navigation independently

Configure the chosen platform push capabilities and vendor project before
constructing the adapter. Keep its initialization in runtime setup, identity
updates in the app session owner, and tap navigation in the router integration.
Installing the package completes none of those connections automatically.

When showing notification settings, distinguish OS permission from provider
subscription/opt-in. For example, a user may grant system permission while the
provider remains opted out. Surface the relevant recovery action rather than
turning every status into a request for OS permission.

On a tap, accept only known action types and validated arguments. Keep an intended
destination pending while startup, auth, or onboarding is incomplete. Recheck
access after those gates, then navigate once. Do not attach a tap listener on
every settings-screen build. Log the notification ID/action rather than its body
or full payload.

Associate provider identity with the current account only after the app knows
that identity. On logout/account change, reset the old association and handle
failure visibly in diagnostics. Avoid copying Story Saver tags into a different
app: define the target app's segmentation and remove stale tags where its vendor
API and product policy require it.

A local reminder and a remotely delivered push may open the same destination,
but they have different delivery owners. Reuse the router destination mapping;
keep their scheduling/subscription state separate.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_notifications](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications/lib/genrevibes_notifications.dart).
- [genrevibes_notifications_onesignal](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications_onesignal/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications_onesignal/lib/genrevibes_notifications_onesignal.dart).
