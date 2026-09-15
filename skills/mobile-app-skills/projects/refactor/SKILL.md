---
name: refactor
description: "Adopt starter kit features in an existing app without replacing unrelated architecture."
---

# Update an existing app

1. Identify the feature being replaced, its provider, callers, stored keys, and
   observable behavior. Record which behavior must stay the same.
2. Follow [starter kit setup](../../starter-kit/SKILL.md) for only that feature.
   Keep the existing router, state management, and dependency injection unless
   changing them is part of the request.
3. Reuse the shared provider/controller. Add a thin translation at the app
   boundary only when the app uses different models or result types.
4. Replace callers, then remove the old integration once nothing uses it.
   Do not run old and new event listeners together.
5. Preserve saved state using [storage migration](../../skills/storage-migration/SKILL.md).
   Never clear all preferences to simplify an upgrade.
6. Connect failure handling and cleanup using [runtime setup](../../skills/runtime-setup/SKILL.md).
7. Check the changed feature before continuing to the next requested feature.
   Report checks actually performed and any behavior that still needs a device.

Do not impose a new folder structure across an app just to adopt a package.
For an app already using the modular kit, use [kit upgrade](../kit-upgrade/SKILL.md).

## Example: replace an old subscription wrapper

Start by reading its callers: settings, paywall, ad eligibility, feature locks,
and developer premium. Record where it stores purchase state and which events it emits.

1. Add the current neutral IAP and selected provider/UI packages.
2. Construct the provider once in bootstrap, using the app's real platform keys.
3. Register it under `IapProvider`. Keep the app's existing repository interface
   while translating the new KitResult at its data/repository boundary.
4. Replace old SDK calls with `getEntitlements`, `presentPaywall`, and
   `restorePurchases`. Keep every PurchaseStatus distinct.
5. Connect one entitlementChanges listener to the app's existing access state.
6. Move feature decisions to EntitlementAccessPolicy using the actual product IDs.
7. Keep developer simulation separate and check its current action grant.
8. Remove the old SDK listener only after all its callers are moved.

Read [IAP](../../skills/iap/SKILL.md) for signatures and result handling.
The same method applies to feedback, permissions, and analytics, but each has
its own state to preserve. Do not treat these as mechanical name replacements.

### Migration record

For each changed feature, record old caller → new call, old saved key → new key,
old callback → new listener, and the owner that cancels the listener. Include
unchanged product behavior such as when a paywall is shown. If no migration is
needed, say why: for example, the feature has no persisted state.

Do not delete the old implementation merely because the replacement file exists.
Search its imports and registrations, inspect native dependencies, and confirm
no active caller still depends on it.
