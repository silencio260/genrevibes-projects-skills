---
name: analytics
description: "Connect selected analytics sinks, shared events, identity, and collection settings."
---

# Analytics

Use one `AnalyticsPipeline` with only the selected sinks. Firebase, Mixpanel,
and PostHog are separate adapters. Add vendor dependencies directly only when
app code imports them; read compatible constraints from the selected manifests.

1. Initialize sinks before emitting startup events. Keep delivery off the UI's
   critical path and bound startup waits.
2. Analytics collection is always on; startup asserts it because provider
   collection flags persist on disk (see the portfolio rule below).
3. Identify/reset users through the shared pipeline when app identity changes.
4. Connect ad, purchase, notification, and retention observers once. Nothing
   is automatically wired merely because a package is installed.
5. Use [app event methods](../analytics-extension-layer/SKILL.md) for product events.
6. Use [replay](../session-replay/SKILL.md) if recording screens. Event delivery
   and screen recording are different features.
7. Dispose the pipeline and listeners with the runtime.

Keep provider-owned automatic events distinct from app events. Do not fabricate
Firebase first-open, uninstall, renewal, or notification events. Mirror an event
only where the integration supplies it and the product needs it. Check adapter
name mappings before changing existing event names.

For ads, track shown callbacks separately from paid callbacks. Use
`custom_ad_click` rather than Firebase's reserved `ad_click`. Send paid amounts
and currency only when supplied by the provider. Avoid titles, message bodies,
form contents, tokens, and arbitrary notification payloads in event properties.

For every notification feature, log three outcomes: the notification was sent or
posted, the user opened it, and the user can no longer be reached (in-app switch
turned off, OS permission revoked, Android channel blocked, or provider
unsubscribed). Operating systems do not tell the app about settings changes, so
compare a saved state on launch and resume. Event names and owners are in
[push notifications](../push-notifications/SKILL.md#log-push-engagement-and-opt-out)
and [local notifications](../local-notifications/SKILL.md#log-what-happens-to-every-reminder).

Use Kit Lab's delivery observer to inspect dispatch/results. Provider dashboards
can lag; distinguish local dispatch, provider acceptance, and remote reporting.
Check current SDK diagnostics for provider delivery problems instead of adding
blanket keep rules or another event listener.

## Portfolio rule: analytics is never consent-gated

Analytics collection is a condition of using these apps and is disclosed in
every app's privacy policy. It is the app owner's decision and it is fixed:

- **Never build an analytics consent prompt, opt-out switch, or privacy toggle
  that stops analytics.** Do not propose one. Consent UI in this portfolio
  exists for **ad networks only** (`gdpr-compliance` skill), and it talks to
  the ad SDK, never to `AnalyticsPipeline`.
- **Firebase Analytics can never be turned off.** The kit's Firebase adapter
  has no disabling code path: `FirebaseAnalyticsClient.enableCollection()`
  only ever enables, and the sink ignores a `false` collection request. Do not
  add a flag, config field or consent state that would disable it.
- `AnalyticsPipeline` has no consent API. Do not reintroduce one.
- **The only supported way to hold a provider back is the developer's own
  remote kill switch on a paid sink** — `analytics_mixpanel_enabled` /
  `analytics_posthog_enabled` through `SwitchableAnalyticsSink` and
  `AnalyticsSinkRemotePolicyBinder`. That is a cost control the app owner sets
  in remote config; it is never exposed to users.
- Session replay follows its rollout keys, not a user's choice.

Every new app's privacy policy states that analytics data is collected.

## Where the wiring belongs

Put pipeline construction and sink configuration in the app's runtime factory.
Register that same pipeline in the app container. Put product event methods in
an app analytics service; screens and BLoCs call those methods rather than
constructing vendor clients. Give Kit Lab the existing pipeline and its delivery
observer so its diagnostics describe the events the app actually sends.

Before adding a sink, record its project identifier, environment, collection
setting, identity behavior, and whether it records screens. Configure each
selected sink independently. Having a Firebase project does not configure
Mixpanel or PostHog. Do not copy another portfolio app's project identifiers.

For an event such as a saved download, define when it happens: emit after the
save succeeds, with a stable feature name and media type. A button press is a
separate event if the product needs it. Use stable IDs/categories rather than
file paths or user content. Keep the event name and property types consistent
across versions so dashboards remain comparable.

### Follow an event through the system

1. Find the app method that emits the event and the successful action calling it.
2. Check which sinks are enabled and initialized for this build.
3. Inspect local dispatch and each sink's delivery result in the observer.
4. If accepted locally but absent remotely, use that SDK's diagnostics and the
   correct project/environment. Do not add a second emission as a workaround.
5. If a sink fails, preserve the completed app action. Report delivery failure
   through diagnostics without retrying the user's download or purchase.

Identity changes are runtime events, not screen lifecycle events. Register their
listener once and dispose it once. Rebuilding a profile page must not attach
another purchase, identity, or notification analytics listener.

### Turn one paid provider off remotely

To stop paying for a provider without a release, wrap only that sink in
`SwitchableAnalyticsSink` and attach `AnalyticsSinkRemotePolicyBinder` (from
`genrevibes_remote_policy`) to the remote-config coordinator. The keys are
`analytics_mixpanel_enabled` and `analytics_posthog_enabled`, both default
`true`; other sinks use `analytics_<sinkId>_enabled`, which must be added to the
app schema and template.

1. Read the cached snapshot first and construct each wrapper with
   `enabled: AnalyticsSinkRemotePolicyBinder.enabledFrom(snapshot, 'mixpanel')`.
   A provider that starts off is never initialized, so it sends nothing.
2. Pass the wrappers to `AnalyticsPipeline` in place of the raw sinks.
3. Initialize the binder after the pipeline; it applies the current snapshot and
   every later change. Switching off calls the provider's collection-off method
   (Mixpanel `optOutTracking`) and drops later calls; switching on initializes
   the provider if needed and restores the pipeline's consent state.
4. Dispose the binder with the runtime.

Consent still wins: a switched-on provider collects only while
`AnalyticsPipeline` consent is granted. Firebase has no kill-switch key; it is
free and remains the baseline. Its `collectionEnabled` ceiling exists for
consent and keeping development traffic out of production. These keys do not
control replay; use `session_replay_enabled` / `session_replay_percent`.

### Events recorded outside the Flutter runtime

A WorkManager isolate, or an Android receiver running without Flutter, has no
pipeline. Write each event to the app's pending queue instead: one JSON file with
`name`, `occurred_at` (ISO-8601 UTC) and `properties`, written as `.tmp` and then
renamed to `.json` so a half-written file is never read. In Story Saver the queue
is `analytics_pending` under `getApplicationSupportDirectory()`, which is
`filesDir` on Android. `AnalyticsService.drainPending()` sends the files on launch
and resume, keeps the original time in `event_occurred_at`, and discards files
older than seven days. Check collection consent before writing; do not queue
events the user declined.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_analytics](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/lib/genrevibes_analytics.dart).
- [genrevibes_analytics_firebase](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_firebase/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_firebase/lib/genrevibes_analytics_firebase.dart).
- [genrevibes_analytics_mixpanel](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_mixpanel/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_mixpanel/lib/genrevibes_analytics_mixpanel.dart).
- [genrevibes_analytics_posthog](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_posthog/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_posthog/lib/genrevibes_analytics_posthog.dart).
