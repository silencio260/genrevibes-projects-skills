---
name: session-replay
description: "Configure shared replay rollout, masking, overrides, and SDK recording state."
---

# Session replay

Use `SessionReplayController` with the selected recorder adapter and shared
remote policy. Replay integration is part of the
[new portfolio app baseline](../../ARCHITECTURE_ANALYSIS.md#11-guaranteed-portfolio-integrations).
Actual screen recording follows the app's collection/rollout policy; do not turn
recording on merely because analytics is connected. Keep the controller, recorder
wiring and Lab controls in place when rollout is 0%.

1. Load stored policy/override state and the current remote snapshot.
2. Capture `controller.plan`, configure the SDK from that plan, then attach the
   recorder with the same `configuredPlan`.
3. Follow `SessionReplayRemotePolicyBinder` for remote changes. The master switch
   wins over a local force-on override.
4. Preserve the stable install bucket and explicit device overrides during
   upgrades. New shared defaults are 0% rollout and masked text/images.
5. Mask sensitive routes independently. PostHog integrations can pass
   `PostHogMaskWidget` through feedback and developer-unlock `protectContent`.
6. Dispose controller, binder, and recorder work with the runtime.

Kit Lab distinguishes the requested plan, last successful recording command,
and SDK status query. Do not label the requested plan as applied state.
Mask changes require a restart. A stricter pending mask stops recording until
restart; changing a remote mask flag does not rewrite an already configured SDK.

The app owns rollout and collection choices. Story Saver's explicit 100%
rollout and global mask overrides are not the defaults to copy into a new app.
Check off, force-on, remote master-off, mask changes, and SDK command failure.

## Keep configuration and recording state separate

There are three different questions: what policy requests, what configuration
was supplied when the SDK started, and whether recording is currently running.
A UI toggle can change the first without changing the other two. Display these
separately in developer diagnostics.

Follow this order in the runtime factory:

1. Initialize the controller's stored state and supply remote policy.
2. Read its plan once for SDK configuration, including text/image masking.
3. Start the selected SDK using that captured plan.
4. Attach its recorder to the controller with that same configured plan.
5. Attach the remote-policy binder and give Lab the live controller.
6. On cleanup, detach policy/listeners and dispose the runtime-owned objects.

A developer override belongs to the shared controller. Do not add a second
preference and directly call the SDK from a settings switch: that would bypass
rollout, the master switch, and the displayed state.

### Upgrade behavior to preserve

The install bucket keeps a device in the same rollout group across launches.
Preserve its key and meaning through storage migration. Keep an existing app's
explicit rollout choices separate from the kit's new-app defaults. Sensitive
forms still require route-level masking even if an app deliberately chooses
unmasked recording elsewhere.

If a new policy demands stricter masking than the running SDK has, stop recording
and indicate restart is required. Do not claim the screen is protected merely
because the requested plan now contains masking flags. If an SDK command fails,
show the failure and retain the last known applied state rather than displaying
the requested toggle as a successful command.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_analytics](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics/lib/genrevibes_analytics.dart).
- [genrevibes_analytics_posthog](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_posthog/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_posthog/lib/genrevibes_analytics_posthog.dart).
- [genrevibes_analytics_mixpanel_replay](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_mixpanel_replay/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/analytics/genrevibes_analytics_mixpanel_replay/lib/genrevibes_analytics_mixpanel_replay.dart).
- [genrevibes_remote_policy](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/lib/genrevibes_remote_policy.dart).
