---
name: analytics-extension-layer
description: "Add typed app-specific analytics methods on top of the shared pipeline."
---

# App analytics methods

Keep product event names and typed methods in the app. Keep shared delivery,
identity, and provider mappings in the kit.

1. Find the existing event catalogue and analytics wrapper before adding one.
2. Add a named method for the product action with only the required properties.
3. Inject the existing `AnalyticsPipeline` or app analytics interface. A wrapper
   does not need inheritance or a new global singleton.
4. Record an event where the outcome becomes known. Do not record completion
   from both the button and its asynchronous result listener.
5. Keep stable event names during refactors. Document deliberate renames and
   affected dashboards. Use explicit metadata for model/provider mappings;
   do not guess a provider from a model-name prefix.
6. Do not send prompts, messages, form text, or personal identifiers as generic
   metadata. Record counts, named actions, and normalized outcomes instead.

Read [analytics](../analytics/SKILL.md) for sink wiring. Adding a typed wrapper
does not initialize sinks or automatically produce purchase/retention events.

## Design an app event method

Create one service in the app's analytics area and inject the shared pipeline.
Expose methods named after completed product actions, such as
`downloadSaved(mediaType: ...)`, rather than accepting arbitrary event names
from every screen. Keep the SDK-independent mapping in this service.

For each method, document the trigger, event name, allowed properties, and
whether failure affects the feature. Ordinary event delivery must not turn a
successful user action into an error. Do not put arbitrary maps from a server
or notification directly into event properties.

When adopting this in another app:

1. Reuse kit event types for shared ads, purchases, and retention operations.
2. List that app's additional product actions and their property types.
3. Add methods for those actions and register the service once with GetIt.
4. Call the method from the owner of the successful action, usually the BLoC or
   application service. Avoid emitting from a widget's build method.
5. Add the app's events to the developer catalogue with the same spelling and
   descriptions. A catalogue entry documents an event; it does not emit it.

Preserve existing dashboard names unless a migration is intended. If renaming,
record the old/new names and the date/version at which reporting changes.
Do not permanently emit both just to avoid making that decision.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_analytics](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/lib/genrevibes_analytics.dart).
