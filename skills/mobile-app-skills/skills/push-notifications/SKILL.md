---
name: push-notifications
description: "Connect OneSignal or another push provider with identity, permission, tap routing, and open/opt-out analytics."
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
7. Log opens and every change in OS permission or provider subscription. See
   [log push engagement and opt-out](#log-push-engagement-and-opt-out).

Use [local notifications](../local-notifications/SKILL.md) for reminders and
in-app generated notices. Adding push does not require a second local scheduler.
Check denied permission, provider opt-out, logout, and cold/warm tap routing, and
confirm each one logs its analytics event.

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

## Log push engagement and opt-out

Push analytics answers two questions: did the user open the push, and can the app
still reach them? Give one runtime object ownership of every push event. Story
Saver's owner is
[PushAnalyticsTracker](../../../../../lib/features/analytics/data/services/push_analytics_tracker.dart).
Bootstrap creates and starts it before `kit.initialize()`, so a launch tap has a
listener, and disposes it with the runtime.

| Event | When | Properties |
|---|---|---|
| `push_received` | A push arrives while the app is in the foreground | `provider`, `notification_id`, `app_state` |
| `push_opened` | The user taps a push or one of its actions. A repeat of the same message and action is ignored (the last 100 are remembered). | `provider`, `notification_id`, `action_id` |
| `push_state_changed` | The first observation on an install (`observation: initial`), then every change | `provider`, `reason`, `observation`, `permission`, `has_permission`, `opted_in`, `deliverable`, `has_subscription_id`, `has_push_token` |
| `push_permission_changed` | The OS permission value changed | The `push_state_changed` properties plus `previous_permission` |
| `push_permission_revoked` | The app had permission and now has `denied` | The `push_state_changed` properties |
| `push_unsubscribed` / `push_subscribed` | Provider opt-in changed from true to false / from false to true | The `push_state_changed` properties |
| `push_state_check_failed` | Reading provider state failed or took longer than 5 seconds | `provider` |
| `push_state_persistence_failed` | Saving the last observed state failed | `provider` |

Follow these rules when adding or changing push analytics:

- **Refresh on startup and resume.** The provider's state stream does not fire
  when the user changes system settings while the app is closed. Call
  `refresh(reason: 'startup')` after the first app frame and `refresh()` (reason
  `resume`) on every resume.
- **Compare with the saved state.** The tracker saves the last snapshot under
  `storysaver.push.analytics_state.v1` and compares against it, so a change made
  while the process was dead is still logged. The initial snapshot is a baseline;
  it never counts as a revocation or an unsubscribe.
- **Store booleans only.** Save and log the permission name and booleans. Never
  store or log subscription IDs, push tokens, titles, bodies or payloads.
- **Process state in order.** Provider events are queued. A refresh result is
  dropped if a provider event arrived while it was running, so an older reading
  cannot overwrite a newer one.
- **Take send counts from the provider.** The Dart adapter cannot see a push
  delivered in the background without a tap. Use the push provider's delivery
  reporting for sent and delivered counts; do not invent a `push_received` for them.
- **Reminders are not pushes.** Story Saver's twice-daily reminders are local
  notifications with their own events; see
  [local notifications](../local-notifications/SKILL.md#log-what-happens-to-every-reminder).

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_notifications](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications/lib/genrevibes_notifications.dart).
- [genrevibes_notifications_onesignal](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications_onesignal/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications_onesignal/lib/genrevibes_notifications_onesignal.dart).
