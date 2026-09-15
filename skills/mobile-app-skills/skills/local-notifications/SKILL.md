---
name: local-notifications
description: "Schedule local notifications and handle taps, timezones, and campaign ownership."
---

# Local notifications

Use the neutral scheduler contracts and `genrevibes_notifications_local`.
Remote push uses a separate [skill](../push-notifications/SKILL.md).

1. Supply channel IDs, small icon, platform initialization, and permission rationale.
   Read the selected adapter's setup, including scheduling permissions for the
   app's target OS versions. Request only permissions the schedule needs.
2. Supply a resolved IANA timezone for calendar schedules. Do not silently use
   UTC for a local-time reminder if resolution fails.
3. Map notification IDs/payloads to app destinations. Subscribe to live
   `interactions` once. After routes are ready, drain
   `LocalNotificationPendingInteractions.takePendingInteraction()` once.
4. Let navigation consume pending taps. Analytics must not consume them.
   The scheduler retains the most recent pending tap, not a durable queue.
5. On resume, resolve the timezone and call `updateTimeZone` through
   `LocalNotificationTimeZoneUpdater`. If lookup fails, keep the previous zone.
6. Persist campaign definitions in an app-owned source and refresh them on cold
   start. The adapter can reschedule daily requests held in the current process;
   that does not restore every campaign after process death.
7. Give each campaign separate `managedIds`. Cancel only those IDs when the
   campaign is disabled. Do not use `cancelAll()` for one feature.
8. Dispose listeners and scheduler with the runtime. Log IDs/actions, not message
   bodies or arbitrary payloads.

Check tap routing from cold and warm starts, onboarding/auth gates, changed
permissions, timezone changes, and independent campaign cancellation. Story
Saver's auto-save notices are immediate notifications, not a daily-campaign example.

## Give each reminder feature an owner

The [integration source](../../references/examples/integrations/shared_features.dart)
contains `scheduleReadingReminder` and `takePendingTap`. The reminder uses an
explicit ID and route payload. Adapt those values to the app's registered
campaign IDs and router; this is not a complete campaign persistence service.

Store the user's reminder choice, schedule, and campaign ID in the owning app
feature. Keep scheduling in a service/repository injected with the shared
scheduler. The screen edits that definition through its BLoC/use case; it should
not invent new IDs every time the switch changes.

| Change | Required work |
|---|---|
| Enable a reminder | Request permission in context, persist the intended definition, schedule, and report scheduling failure. |
| Edit its time | Replace that campaign's existing request using its stable ID. |
| Disable it | Cancel its managed IDs and save the disabled preference. |
| App restarts | Load definitions and reconcile the schedules the app still owns. |
| Timezone changes | Resolve the new zone and update the scheduler; reconcile persisted campaigns as needed. |

If scheduling fails after saving the preference, show that the reminder is not
confirmed scheduled. Do not display a success state based only on the saved
switch. Decide whether to retry/reconcile on the next launch, and keep that
behavior in the campaign service.

Register live tap handling once. A cold-start tap waits until the app router,
onboarding, and authentication are ready. Validate the payload as a known app
destination, then consume it once. Do not let analytics drain the pending tap
before navigation sees it. An unknown payload should lead to a safe fallback,
not an arbitrary route or external URL.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_notifications](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications/lib/genrevibes_notifications.dart).
- [genrevibes_notifications_local](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications_local/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications_local/lib/genrevibes_notifications_local.dart).
