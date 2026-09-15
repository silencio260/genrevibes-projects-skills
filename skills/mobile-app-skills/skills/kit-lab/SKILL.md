---
name: kit-lab
description: "Connect the shared developer section, Kit Lab, logs, module health, and controls."
---

# Kit Lab and developer controls

1. Use `StarterKitLabScreen` from `genrevibes_devtools`.
2. Build one `DevToolsHost` with the running `kit` and a `DevAnalyticsCatalogue`
   matching the app's real events (an empty catalogue is valid without analytics).
   Pass available
   ads, consent, analytics, remote config, replay, purchases, local notifications,
   rating, onboarding, and navigation-bar controls. Do not initialize replacements
   just for the Lab.
3. Pass developer access. Keep the built-in guard enabled; both the hub and
   pushed pages require diagnostics access. Use `requireDeveloperAccess: false`
   only when the app deliberately supplies its own access guard.
4. Pass the same `RecordingKitLogger` to the coordinator, providers that accept
   a logger, and host. Pass the same `RecordingDeliveryObserver` to the analytics
   pipeline and host's `eventLog`. Dispose recorders with the runtime.
5. Choose whether release builds retain logs. Story Saver records buffers only
   in development; listed release devices still get live health and actions.
6. Build the remote schema once and pass it to the runtime and Lab. Bind controls
   using the shared policy binders; see [remote config](../remote-config/SKILL.md).
7. Keep product-specific developer actions in the app. Call shared module
   methods for shared resets; never clear every preference to reset one feature.

A missing host instance means “not connected.” A module can also be disabled,
waiting, ready, degraded, or failed. Use coordinator health, including timeouts,
rather than treating all missing providers as an app failure.

Check that revoking access closes or blocks already-open pages, each connected
control changes the real module, and unavailable logs are explained accurately.

## Required host fields and practical wiring

`DevToolsHost` requires the running `kit` and a `DevAnalyticsCatalogue`. Pass a
catalogue made from the same event names the app emits. If the app has no event
catalogue, an empty `DevAnalyticsCatalogue(events: [])` is valid; inventing demo
events would pollute diagnostics. See `makeLabHost` in
[integration examples](../../references/integration-examples.md).

| Host field | Supply |
|---|---|
| `kit` | The initialized runtime coordinator. |
| `catalogue` | App event names, parameters, and always-attached properties. |
| `developerAccess` | The running shared access controller. |
| `logger`, `eventLog` | The recorders already attached during bootstrap. |
| `remoteConfig`, `remoteConfigSchema` | The coordinator and the exact schema it uses. |
| `ads`, `adPolicy`, `adPlacements` | Running provider/policy and declared placements. |
| `iap`, `consent`, `feedback`, `rating`, `onboarding` | Existing module instances. |
| `localNotifications`, `push` | The selected scheduler/push provider, if adopted. |
| `permissions` | The provider expected by this host field; not an unrelated app permission BLoC. |
| `storageKeys` | Only known feature groups the Lab should expose. |

Open `StarterKitLabScreen(host: host)` from the guarded developer section.
Do not make the route itself create a logger after the events have already happened.
Use `RecordingKitLogger(forwardTo: existingLogger)` if console logging must
continue alongside the in-memory buffer. Dispose recorders with the runtime.

### What health states tell the developer

“Not connected” means the host did not receive an instance. “Disabled” means a
registered capability was intentionally not started. “Waiting” means a deferred
entry has not completed. “Degraded” can mean usable defaults with a provider
failure. “Failed” is a reported operation/module failure. Use those meanings in
UI and reports; do not label all of them “missing feature.”

### Controls must act on the live app

Change an ad switch and check that the actual placement listens to it. Change
remote config and check its binder applies the new snapshot. Query replay SDK
status rather than assuming its requested plan was applied. Reset onboarding
through its controller instead of clearing all preferences. Preview an exit
prompt without exiting the app. These checks distinguish a connected Lab from
a page of controls that only change their own local widgets.

Keep the default guard on pushed pages. Hiding the Settings entry alone is not
enough if a previously opened page or route remains accessible after revocation.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_devtools](../../../../../packages/genrevibes_starter_kit/modules/devtools/genrevibes_devtools/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/devtools/genrevibes_devtools/lib/genrevibes_devtools.dart).
- [genrevibes_developer_access](../../../../../packages/genrevibes_starter_kit/modules/devtools/genrevibes_developer_access/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/devtools/genrevibes_developer_access/lib/genrevibes_developer_access.dart).
