---
name: runtime-setup
description: "Connect kit modules with bounded startup, deferred prompts, cleanup, and retry."
---

# Runtime setup

The app owns module instances and lifecycle. Reuse `GenRevibesStarterKit` and
`KitResourceScope`; do not write another startup manager.

1. Render loading/retry UI before waiting for network or SDK preparation.
2. Create a fresh scope for each startup attempt. Register module disposal and
   listener cancellation before awaiting initialization. After an await, check
   that the scope is still active before attaching more work.
3. Mark only essential modules required. Use
   `StarterModuleRegistration.enabled(isRequired: false, ...)` for optional
   startup integrations. IDs must match each module's `moduleId` and be unique.
4. Set `autoStartDeferred: false` for prompts. Call `startDeferred()` after a
   mounted app widget has rendered a frame. Deferred modules run in order and
   continue after a module fails or times out.
5. Read the `KitResult` from `initialize()`. A required failure opens recovery
   UI; optional failure leaves the app usable and visible in module health.
6. On retry, dispose the old scope and app registrations before replacing them.
   Disposal must be idempotent because both scope and coordinator may release a module.
7. Restore global hooks and cancel timers, subscriptions, and policy binders when
   the runtime closes. Ignore callbacks from an older startup attempt.

For consent, use the [consent skill](../gdpr-compliance/SKILL.md). For the shared
composition example, see [portfolio adoption](../../../../../packages/genrevibes_starter_kit/docs/portfolio-adoption.md).
The coordinator defaults to a 10-second module budget; override it for a
specific operation. A Dart timeout releases the wait, not necessarily native work.

Check required failure, optional failure, retry, and disposal by following the
actual code paths. Do not claim SDK UI was cancelled merely because a timeout fired.

## What to put in each startup file

| File | Responsibility |
|---|---|
| `app_env.dart` | Read build values; create typed provider configuration. No SDK initialization. |
| `app_bootstrap.dart` | Construct store/controllers/providers, connect policies, register startup modules. |
| `app_runtime.dart` | Hold the constructed instances and their resource scope. No hidden service lookup. |
| `runtime_registrar.dart` | Register those exact instances under app-facing interfaces in GetIt. |
| `main.dart` | Show loading/retry, prepare required services, publish successful runtime, start deferred work after a frame. |

See `makeRuntime`, `makeAppodealConsent`, and `startDeferredAfterFrame` in the
[complete integration functions](../../references/integration-examples.md).
Use `module.moduleId` in registration so the ID cannot drift from its implementation.

### Required, optional, deferred, and disabled

- **Required enabled:** awaited during initialize; its failure makes overall
  initialization fail. Use only where the normal app cannot operate without it.
- **Optional enabled:** awaited within its budget, but failure is recorded and
  later modules can proceed. Appropriate for an integration not needed to open the app.
- **Deferred:** runs in the later ordered sequence; cannot be required because
  required startup has already returned. Use for consent/UI-dependent work.
- **Disabled:** the factory is not invoked. Do not create SDK work earlier and
  assume a disabled registration undoes it.

The coordinator defaults to automatic deferred startup. Set
`autoStartDeferred: false` whenever the sequence might display UI, then trigger
it after the main app frame. `deferredStartupComplete` means the sequence has
finished attempting its work, not that every optional service succeeded.

### Handling a failed startup attempt

Keep an attempt number or equivalent ownership check. A timeout may leave the
underlying Future running. After every awaited composition step, verify the
scope is active before adding listeners or publishing instances. If the attempt
was replaced, dispose its results instead of registering them in the new app.

On failure, close the scope, restore global hooks, reset runtime-related app
registrations, and show a safe Retry message. Do not leave an older analytics
listener or notification binding attached. The next attempt gets a fresh scope.
A scope callback should close only the resource it owns, not another attempt's resource.

### Disposal order

The scope runs cleanup in reverse registration order, with a bounded wait for
each callback. Register owners before dependants: providers first, listeners
that use them afterward. Listener cancellation then runs before provider disposal.
The scope continues after a cleanup error. Module disposal must tolerate being
called again because the coordinator may also release registered modules.

Use the runtime scope for long-lived subscriptions. Use widget/BLoC disposal
for screen-owned state. A shared provider belongs to the runtime, not the route.

### Signs of incomplete wiring

A blank launch screen suggests work is still awaited before runApp. Duplicate
analytics after Retry suggests old listeners survived. A consent page before a
Navigator exists suggests deferred work started automatically. A healthy provider
with no feature behavior may mean it was initialized but never connected to app
state. Trace each of these connections rather than adding another initialization call.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_core](../../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_core/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_core/lib/genrevibes_core.dart).
- [genrevibes_starter_kit](../../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_starter_kit/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_starter_kit/lib/genrevibes_starter_kit.dart).
