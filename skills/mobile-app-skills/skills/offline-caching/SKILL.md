---
name: offline-caching
description: "Add feature-specific caching and offline behavior without duplicating kit storage."
---

# Offline data and caching

Inspect the feature's existing repository and storage before adding a cache.
Use kit key-value storage for small settings/state; keep structured app data in
the app's chosen database or file store.

1. Define what can be cached, its lifetime, size limit, and invalidation rule.
2. Decide whether the feature serves cached data first or only after a request
   fails. Label stale data when its age matters.
3. Bound requests and handle their actual errors. A connectivity precheck is
   only a hint and should not permanently block otherwise reachable services.
4. Separate caches by account and clear only the relevant data on logout.
5. For queued writes, define ordering, retry limits, and duplicate prevention.
   Do not blindly replay non-idempotent operations.
6. Preserve existing serialization IDs/fields during changes. Follow
   [storage migration](../storage-migration/SKILL.md) for kit key adoption.

Keep the app's existing code-generation approach. For manual Hive adapters,
maintain stable type/field IDs; choosing manual adapters is not permission to
change stored formats. Reuse the existing network-image component.
Check stale cache, empty cache, request failure, account switch, and storage limits.

## Define the cache contract in the repository

Write down the cache key, account scope, serialized version, freshness period,
maximum size, and deletion policy. Store small preferences with the kit store;
choose the existing app database/file layer for collections and large content.
A cache is an implementation detail of the data repository, not a second source
of truth that widgets read independently.

Choose one read sequence deliberately. A cache-first feature can show saved data
immediately and refresh; a network-first feature may use cached data only after
a request fails. In either case, distinguish empty, stale, refreshing, and failed
states in the BLoC. Do not erase usable cached content just because refresh failed.

For queued writes, persist an operation ID and define conflict handling before
adding automatic retry. A repeated request to create a paid job or send feedback
may perform the action twice unless the server supports deduplication. Retrying
a read and retrying a charge are different decisions.

During account changes, stop old reads/writes from updating the new account's
cache. During format changes, migrate existing serialized values explicitly;
changing a Hive type/field ID or JSON field meaning can break installed users.
Document whether an old app version can still read the updated cache.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_storage](../../../../../packages/genrevibes_starter_kit/modules/storage/genrevibes_storage/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/storage/genrevibes_storage/lib/genrevibes_storage.dart).
