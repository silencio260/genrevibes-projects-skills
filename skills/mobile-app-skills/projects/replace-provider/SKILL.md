---
name: replace-provider
description: "Replace a kit provider adapter while preserving the shared feature interface."
---

# Replace a provider

1. Identify the existing neutral contract and adapter. Compare the replacement's
   supported platforms, operations, callbacks, and native setup.
2. Add the replacement adapter and only its needed dependencies. Keep feature
   callers on the neutral interface where possible.
3. Change app composition, credentials, native configuration, and provider-specific
   UI. Read the [runtime skill](../../skills/runtime-setup/SKILL.md) before changing ownership.
4. Translate app-owned identities and stored values where the providers differ.
   Do not assume purchase accounts, consent signals, or notification tokens transfer.
5. Keep one active provider for each intended role. Remove old listeners and
   configuration when no longer used. Multiple analytics sinks can be intentional.
6. Check unsupported operations and failure results. Confirm that replacing a
   provider did not bypass premium rules, developer test mode, or user choices.

Use the adapter's README and public exports at the app's pinned revision.
A remote provider name cannot install a new SDK; ship its integration first.

## Compare capabilities before changing code

Use a table for the specific replacement:

| Question | Example consequence |
|---|---|
| Does it support the app's platforms? | An Android-native ad view needs an alternative/placeholder on iOS. |
| Does it support every operation? | A purchase adapter without hosted paywalls needs app-owned UI. |
| Are callbacks scoped per placement or app-wide? | Registering one app-wide listener per widget duplicates events. |
| Can settings change after SDK initialization? | Appodeal test-mode changes may require withholding inventory until relaunch. |
| Does identity migrate? | A new purchase provider may need a server/customer migration, not just a new key. |
| Does the result contain the same information? | Do not invent revenue or assume a missing entitlement snapshot means free. |

Keep the neutral feature interface while replacing only the selected adapter,
its configuration, and genuinely provider-specific views. If the interface lacks
a necessary behavior, document that gap instead of downcasting throughout the app.

### Replace without double initialization

Construct the replacement in bootstrap, register the same neutral type, and
connect its listeners once. Remove the previous instance and listener from the
runtime scope. A screen or Lab must receive the replacement from the runtime;
it must not create a second SDK instance. Review app native configuration after
removing the old dependency so stale manifest/Pod/Gradle entries are not left behind.
