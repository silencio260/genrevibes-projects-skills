---
name: storage-migration
description: "Preserve saved state when replacing copied app code with kit modules."
---

# Storage migration

Use `MigratingKeyValueStore` around the selected `KeyValueStore` adapter.

1. Inventory old key names, stored types, and meanings before changing readers.
2. Add explicit mappings from current namespaced keys to real legacy keys.
   Reuse module-provided mappings such as `OnboardingKeys.legacyKeys`,
   `EngagementKeys.legacyKeys`, and `RatingKeys.legacyKeys` where they match the app.
3. Keep one shared store instance. Give migrated reads to the modules before
   initialization, not after they have already written defaults.
4. Inspect how the migration handles an existing new key, missing old value,
   wrong type, and write failure. Do not cast arbitrary stored data blindly.
5. Preserve completion, identity, retention, rollout buckets, and developer settings.
   Do not use a preferences-wide clear as a migration or recovery action.
6. Leave `removeLegacyOnRead` false while rollback needs old keys. This preserves
   old values but does not mirror later writes back to them; document that limit.
7. Document any change to data meaning and how an older app version will read it.

The key-value layer does not migrate an app database schema or arbitrary files.
Handle those in the owning feature. Never put credentials into ordinary
preferences because a generic store exists.

Check new installs and upgrades with representative existing keys. Report device
checks still needed for backup/reinstall behavior.

## Write a migration record before changing readers

For each value being moved, record the following in the app's change notes:

| Field | Example of the information needed |
|---|---|
| Old key/type | The exact existing preference name and whether it stores bool, int, string, or list. |
| New key/type | The actual key the kit controller will read. |
| Meaning | Whether true still means completed/enabled, and whether a unit changed. |
| Precedence | What happens when both old and new keys exist. |
| Failure | How a read/type/write error is reported without replacing valid data. |
| Rollback | Whether the older version can read changes made by the new version. |

Construct the migrating store around the adapter in the runtime factory, before
constructing controllers. Pass that same store into onboarding, retention,
rating, developer access, and other migrated consumers. A migration installed
after initialization is too late: a controller may already have read a default.

Do not create fictional legacy mappings for a new app. Read the existing app's
constants and write sites to establish real keys. If a value changes type or
meaning, implement an explicit feature migration rather than assuming a renamed
key is sufficient.

The [worked feature](../../references/feature-walkthrough.md) shows how a missing
bool becomes a product default while a storage error remains a failure. Apply
that distinction during migration too: missing data and unreadable data are not
the same event. Do not delete legacy values on a failed destination write.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_storage](../../../../../packages/genrevibes_starter_kit/modules/storage/genrevibes_storage/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/storage/genrevibes_storage/lib/genrevibes_storage.dart).
- [genrevibes_storage_shared_preferences](../../../../../packages/genrevibes_starter_kit/modules/storage/genrevibes_storage_shared_preferences/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/storage/genrevibes_storage_shared_preferences/lib/genrevibes_storage_shared_preferences.dart).
