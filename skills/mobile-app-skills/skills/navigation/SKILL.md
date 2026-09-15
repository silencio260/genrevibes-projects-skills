---
name: navigation
description: "Connect kit screens and external actions to the app router."
---

# Navigation

Keep the app's existing router. Named routes, a declarative router, and direct
Navigator calls can all host kit UI; kit adoption does not require replacing them.

- Supply app destinations/callbacks to kit features. The kit must not import
  the app's route table.
- Validate route arguments before constructing a screen. Handle missing or
  invalid destinations without a cast failure.
- After asynchronous work, check mounted/current ownership before navigating.
  Prevent repeated callbacks from opening the same page twice.
- Hold notification/deep-link destinations until startup and required
  authentication/onboarding are ready. Apply access checks to external entries too.
- Use [exit prompt](../exit-prompt/SKILL.md) for root Back behavior and
  [system UI](../immersive-ui/SKILL.md) only when changing system-bar behavior.

Check Back, cancelled flows, cold external entry, and repeated taps.
Do not force a reset-to-home navigation stack on every completed kit action.

## Register feature routes with their dependencies

The [worked example](../../references/feature-walkthrough.md) includes a complete
route factory. It constructs a screen-owned BLoC with `BlocProvider(create: ...)`
and triggers its initial load once. Use `BlocProvider.value` only when passing
an existing BLoC whose lifetime belongs elsewhere; the receiving route must not
close that shared instance.

For a new portfolio app, follow the route organization shown in the architecture
guide. In an existing app, keep its working router and express the same ownership
rules using that router's APIs. Route arguments should be typed/validated before
screen construction; provide a safe unknown-route result.

Represent pending external destinations as app data, not a stale BuildContext.
When startup and access gates complete, resolve that destination against the
current session. A notification arriving twice or a repeated finish callback
must not stack duplicate screens.

Opening a paywall, feedback form, or developer page should return to the caller
unless the product explicitly changes the navigation stack. Check mounted state
after awaited work, and keep navigation out of reusable repository code.
