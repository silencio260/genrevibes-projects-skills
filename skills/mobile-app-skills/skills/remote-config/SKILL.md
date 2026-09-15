---
name: remote-config
description: "Connect typed remote configuration, refresh, shared policy binders, and Kit Lab controls."
---

# Remote config

Use `RemoteConfigCoordinator` with the selected provider. Firebase is optional;
the kit also has a SharedPreferences adapter for local configuration.

1. Build one schema. `PortfolioRemoteConfigSchema.build()` supplies the shared
   keys; a smaller `RemoteConfigSchema` can include only the groups the app needs.
   Add app keys explicitly. Analytics-name overrides are opt-in.
2. Initialize defaults and cached values before consumers read them. Bound this
   wait in startup. Initialization does not perform a fresh fetch.
3. Connect the relevant shared policy binders and dispose them with the runtime.
4. Call `refresh()` after startup without holding the first frame. Handle/report
   its outcome. A successful initialization does not prove refresh was called.
5. Pass the same schema and coordinator to Kit Lab. Inspect value origins and
   fetch health; all-default values alone do not prove a fault.

The [Firebase template](remote_config_template.json) matches the shared default
schema at the [checked revision](../../references/kit-compatibility.md).
It includes keys for optional capabilities; remove unused groups when making an
app-specific template. A key cannot install a missing SDK or turn an unsupported
operation into a supported one.

Preserve existing production key spellings, including
`time_before_first_rewared_ad`. For an existing app, compare its remote values
and conditions before adopting the template. Do not replace live policy with
new defaults or publish a template unless requested.

New shared replay defaults are 0% rollout with text/images masked. Keep an
existing app's deliberate choices through `replayDefaults` and its app template.
See [replay](../session-replay/SKILL.md) for restart requirements.

Check that refresh is called and results reach consumers, including failed fetch
and invalid values. This wiring can be checked in code and tested when tests are
requested; grep alone is not proof of runtime behavior.

## Wire defaults, refresh, and consumers separately

The [integration source](../../references/examples/integrations/shared_features.dart)
contains `makeRemoteConfig` and `makeSharedSchema` with the actual constructor
names and imports. Keep this construction in the runtime factory. Register the
coordinator with GetIt for readers; do not create another Firebase adapter in a
settings screen.

For each remote key, record its type, default, valid range, consumer, and when
changes take effect. For example, an ad switch changes a policy read by placement
code; a replay mask can require SDK restart. The presence of a key in Firebase
is not proof that the app observes it.

| Stage | What the app must do |
|---|---|
| Construct | Give the provider and coordinator the same schema. |
| Initialize | Make defaults/cached values available before dependent policies read them. |
| Bind | Attach the relevant policy binder to the actual live consumer. |
| Refresh | Fetch after the initial screen and handle the result. |
| Inspect | Show origins and refresh health using the same coordinator in Lab. |
| Dispose | Remove binders before replacing the runtime and its providers. |

### Add an app-specific key

Choose a namespaced, stable name and define a typed key using the schema API.
Set a safe offline default and any supported validation. Include the key in the
app's schema and template, then implement the consumer. State whether a change
applies immediately, next navigation, or next launch. Handle missing and invalid
remote values through the defined default/validation behavior instead of casts
scattered through widgets.

For an existing app, compare its published conditions as well as default values.
Copying a template over a production configuration can erase regional or version
conditions. Prepare a proposed template change for review; do not publish it as
part of editing local skills or source.

On fetch failure, retain usable defaults/cached policy and expose the failure.
Do not block app navigation waiting indefinitely for fresh remote values.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_remote_config](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_config/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_config/lib/genrevibes_remote_config.dart).
- [genrevibes_remote_config_firebase](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_config_firebase/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_config_firebase/lib/genrevibes_remote_config_firebase.dart).
- [genrevibes_remote_config_shared_preferences](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_config_shared_preferences/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_config_shared_preferences/lib/genrevibes_remote_config_shared_preferences.dart).
- [genrevibes_remote_policy](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/lib/genrevibes_remote_policy.dart).
