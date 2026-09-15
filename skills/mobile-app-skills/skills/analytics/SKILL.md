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
2. Apply the app's collection policy explicitly. Firebase collection settings
   can persist, so do not assume a new build reset an earlier disabled setting.
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

Use Kit Lab's delivery observer to inspect dispatch/results. Provider dashboards
can lag; distinguish local dispatch, provider acceptance, and remote reporting.
Check current SDK diagnostics for provider delivery problems instead of adding
blanket keep rules or another event listener.

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

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_analytics](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/lib/genrevibes_analytics.dart).
- [genrevibes_analytics_firebase](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_firebase/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_firebase/lib/genrevibes_analytics_firebase.dart).
- [genrevibes_analytics_mixpanel](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_mixpanel/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_mixpanel/lib/genrevibes_analytics_mixpanel.dart).
- [genrevibes_analytics_posthog](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_posthog/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_posthog/lib/genrevibes_analytics_posthog.dart).
