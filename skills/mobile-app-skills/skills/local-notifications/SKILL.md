---
name: local-notifications
description: "Schedule local notifications and daily campaigns; handle taps, timezones, campaign ownership, and post/open/opt-out analytics."
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
9. Log each reminder the app posts, each open, and each way the user stops
   receiving reminders. See [log what happens to every reminder](#log-what-happens-to-every-reminder).

Check tap routing from cold and warm starts, onboarding/auth gates, changed
permissions, timezone changes, independent campaign cancellation, and the
analytics event for each of those. Story Saver's auto-save notices are immediate
notifications. Its [daily status reminders](#story-savers-daily-status-reminders)
are the daily-campaign example.

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

## Log what happens to every reminder

A reminder campaign needs analytics that answer three questions: was the reminder
posted, did the user open it, and has the user stopped receiving reminders? The
last question has several causes. Log each cause as its own event, because each
needs a different recovery: turning the in-app switch back on, allowing
notifications in system settings, or unblocking one Android channel.

| What happened | Event and main properties | Recorded by |
|---|---|---|
| Reminder posted | `local_notification_posted`: `notification_id`, `campaign_id`, `slot`, `occurrence_id`, `success` | Android: the native receiver, after `notify()` returns |
| Reminder due but not posted | `daily_reminder_skipped`: `hour`, `reason` (`notifications_disabled` or `outside_delivery_window`) | Android: the native receiver |
| Reminder opened | `local_notification_opened`: `notification_id` (11001 or 18001). Android also sends `campaign_id`, `slot`, `occurrence_id` | Android: `MainActivity` when it receives the reminder intent. iOS: `TrackedLocalNotifications` |
| User turned the in-app switch off or on | `daily_reminders_unsubscribed` / `daily_reminders_enabled`: `campaign_id` | `DailyReminderService.setEnabled`, only when the value changes |
| System notification permission changed | `notification_permission_changed`: `allowed`, `previous_allowed`, `reason` | Android: the native state check. iOS: `DailyReminderService` on launch and resume |
| Android reminder channel blocked or unblocked | `notification_channel_changed`: `allowed`, `previous_allowed`, `channel_id` | Android: the native state check |
| Setup failed | `daily_reminder_failed`: `stage` (`reconcile` from Dart, `receiver` from Kotlin) | `DailyReminderService` or the receiver |

`allowed: false` on a permission or channel event means the user revoked it.
Native Android events also carry `provider: local` and `platform: android`.

**Detect changes the OS does not report.** Neither Android nor iOS tells an app
when the user turns notifications off in system settings. Save the last observed
permission state (and, on Android, the channel state) and compare it on launch,
on resume, and when each Android alarm fires. The first observation on an install
is a baseline: save it without logging a change.

**Android posts without starting Flutter.** A Dart timer cannot post while the
app is closed, and the kit adapter keeps daily repeats only for the running
process (step 6). Story Saver therefore posts Android reminders from a
`BroadcastReceiver`, which has no analytics pipeline. It writes each event as one
JSON file with `name`, `occurred_at` (ISO-8601 UTC) and `properties` into
`filesDir/analytics_pending`, writing a `.tmp` file first and then renaming it.
On Android that is the directory `getApplicationSupportDirectory()` returns, so
`AnalyticsService.drainPending()` sends these files together with WorkManager's
queued events on the next launch, resume, or reminder open. Dashboards receive
them late; `event_occurred_at` keeps the real time.

**Apply analytics consent in native code.** The Dart service passes
`analytics_enabled` each time it configures the native side, and the receiver
writes no events when it is false. The receiver only knows the consent from the
last configure, so configure again on launch and resume.

**iOS has no per-post event.** iOS shows a scheduled local notification without
running the app, so there is no moment to log it. `local_notification_scheduled`
is logged whenever the schedule is applied (at least once per cold start); it is
not a send count. Measure iOS reminders with opens and permission state.

**Keep content out of events.** Log notification IDs, slot and campaign, not the
title or body.

## Story Saver's daily status reminders

Story Saver sends two reminders a day, around 11:00 and 18:00 in the device's
local time. They are on by default and the user can turn them off in Settings.
The notification IDs are 11001 (morning) and 18001 (evening). The campaign ID and
Android channel ID are both `daily_status_reminders`.

Links below point into the host app.

| Part | Source | Job |
|---|---|---|
| Owner | [daily_reminder_service.dart](../../../../../lib/features/notifications/daily_reminder_service.dart) | Saves the switch, checks permission, configures Android, schedules iOS, logs switch/permission/failure events, exposes `opens` and `takePendingOpen()` |
| Settings row | [daily_reminder_settings.dart](../../../../../lib/features/notifications/daily_reminder_settings.dart) | Switch, plus "Allow notifications" and "Retry" rows when reminders are blocked or setup failed |
| Text | [notification_strings.dart](../../../../../lib/features/notifications/notification_strings.dart) | Reminder copy, channel name and explanation dialog text |
| Android scheduler | [DailyReminderReceiver.kt](../../../../../android/app/src/main/kotlin/com/genrevibes/whatsappstorysaver/DailyReminderReceiver.kt) | Channel, inexact alarms, posting, open handling and native event files |
| Android bridge | [MainActivity.kt](../../../../../android/app/src/main/kotlin/com/genrevibes/whatsappstorysaver/MainActivity.kt) | `story_saver/daily_reminders` channel with `configure`, `state` and `takePendingOpen`; calls Dart's `opened` for taps while the app runs |
| Manifest | [AndroidManifest.xml](../../../../../android/app/src/main/AndroidManifest.xml) | `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, and the receiver for boot, app update, timezone and clock changes |
| Lifecycle | [main.dart](../../../../../lib/main.dart), [my_app.dart](../../../../../lib/my_app.dart) | `initialize()` after the first app frame; `refresh()` on every resume |
| Routing and prompt | [home_screen.dart](../../../../../lib/features/home/presentation/screens/home_screen.dart) | Opens the Statuses tab for a reminder tap; shows a one-time explanation dialog when reminders are on but notifications are not allowed |

### Android delivery rules

- Alarms use `setAndAllowWhileIdle`, which is inexact. The app needs no
  exact-alarm permission, and Doze can delay a reminder past the hour.
- Each slot has a three-hour window: 11:00–13:59 and 18:00–20:59. An alarm that
  fires outside it logs `daily_reminder_skipped` with `outside_delivery_window`
  instead of posting late, for example after the phone was off overnight.
- A slot posts at most once per local date.
- The receiver schedules tomorrow's alarm before posting, so a skipped post does
  not end the campaign.
- If reminders are configured inside a window and that slot has not posted today,
  the alarm is set for one second later. Enabling reminders or allowing
  notifications at 12:30 therefore posts the 11:00 reminder straight away.
- Boot, app update, timezone change and clock change re-run the schedule. The
  receiver does nothing until Flutter has configured it at least once.

### iOS

`DailyReminderService` resolves the IANA timezone (no UTC fallback), updates the
scheduler, and schedules two `LocalNotificationDaily` requests through the
tracked kit scheduler. When the switch or permission is off it cancels only IDs
11001 and 18001. A tap arrives through `interactions` and
`takePendingInteraction()` with payload `daily_status_reminders`.

### Opening a reminder

On Android, `DailyReminders.handleOpen` checks the intent's action, hour and
occurrence, ignores an occurrence it has already recorded, logs
`local_notification_opened`, and marks a pending open. On a cold start, Home calls
`takePendingOpen()` after its first frame. While the app is running, `onNewIntent`
calls Dart's `opened` method; the service emits on `opens` and drains the
analytics queue. Both paths select the Statuses tab and reload statuses.

### Check on a device

1. With reminders on and notifications allowed, confirm one reminder near 11:00
   and one near 18:00 local time. Reopen the app and confirm one
   `local_notification_posted` per slot.
2. Tap a reminder with the app closed, in the background and in the foreground.
   Each tap opens Statuses and logs one `local_notification_opened`.
3. Turn the Settings switch off and on. Confirm `daily_reminders_unsubscribed`,
   then `daily_reminders_enabled`, and no reminders while it is off.
4. Turn off the app's notifications in system settings and return to the app.
   Confirm `notification_permission_changed` with `allowed: false`. When a slot is
   due, confirm `daily_reminder_skipped` with `notifications_disabled`. On Android,
   block only the "Daily status reminders" channel and confirm
   `notification_channel_changed`.
5. Restart the phone and change its timezone. Reminders keep their local times.
6. Turn analytics collection off and confirm no reminder events are written.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_notifications](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications/lib/genrevibes_notifications.dart).
- [genrevibes_notifications_local](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications_local/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/notifications/genrevibes_notifications_local/lib/genrevibes_notifications_local.dart).
