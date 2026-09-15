---
name: tracking-retention
description: "Reuse retention history, milestones, and targeting rules from genrevibes_engagement."
---

# Retention and targeting

Use `RetentionTracker`, `EngagementSnapshot`, and `UserTargetingPolicy` from
`genrevibes_engagement`. Replace copied trackers instead of keeping two counters.

1. Initialize storage with `EngagementKeys.legacyKeys` through
   `MigratingKeyValueStore` when adopting existing history.
2. Create the tracker with the store and an `EngagementObserver`. Use
   `AnalyticsEngagementObserver` when sending shared events to the pipeline.
3. Call `recordAppOpen` once for a logical launch. Wire `recordSession` according
   to the app's session lifecycle; initialization alone does not record either.
   `recordAppOpen` already adds the initial session; do not count it again on launch.
4. Derive targeting from the current snapshot with `UserTargetingPolicy`.
   Keep thresholds/defaults in the shared policy, app-specific offers in the app.
5. Cancel lifecycle listeners on shutdown and avoid counting startup retries as
   extra launches.

The shared tracker reports retention milestones once per install. Preserve its
stored flags so upgrades do not replay them. Onboarding completion has its own
controller; do not infer it from retention counts.

Check retained installs, repeated opens, session resumes, and upgrades from old
keys. Inspect emitted events without claiming a local history is a portfolio-wide
retention percentage.

## Record actual use without counting it twice

Construct one `RetentionTracker` with the shared migrated store and initialize
it before consumers inspect its history. The runtime owns this tracker; screens
should not each construct one. Record a real app open at the app's chosen launch
boundary. `recordAppOpen` already records a session, so do not call
`recordSession` beside it for the same launch.

Define what later counts as a session for this product, including any background
duration threshold. Apply that rule in one lifecycle owner. Widget rebuilds and
route changes are not automatically new sessions.

Use the stored history for the kit's milestone/eligibility rules. App features
can consume the resulting eligibility, but should not maintain competing open
counters for rating, onboarding, and notification campaigns. Onboarding has its
own completion flag and must not be inferred from a retention count.

During adoption, map the old key names and types before the first tracker read.
Check first install, existing history, a repeated lifecycle event, and a changed
calendar date. A failed persistence operation must be visible diagnostically;
it must not stop the user entering the app. Keep local retention history separate
from a claim that an analytics provider received the corresponding event.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_engagement](../../../../../packages/genrevibes_starter_kit/modules/engagement/genrevibes_engagement/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/engagement/genrevibes_engagement/lib/genrevibes_engagement.dart).
- [genrevibes_analytics](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/lib/genrevibes_analytics.dart).
