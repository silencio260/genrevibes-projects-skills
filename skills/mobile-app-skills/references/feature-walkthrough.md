# A complete feature: reading preferences

This example stores and displays one boolean preference. It demonstrates the
app structure without needing Firebase, ads, purchases, or a live service.
It does not implement a screen-awake plugin. The preference is named for a
possible reader feature so its app-owned meaning is clear.

## Files and reading order

All source files below are complete, with imports. Their relative imports resolve
inside the example. Start at main, then follow one save from the screen downward.

1. [main.dart](examples/reading_preferences/lib/main.dart): create the kit store,
   register dependencies, and render the app. The store is lazy; construction
   performs no network wait, so this example needs no asynchronous startup shell.
2. [container_injector.dart](examples/reading_preferences/lib/container_injector.dart):
   register the store instance and call the feature injector.
3. [feature injector](examples/reading_preferences/lib/features/reading_preferences/reading_preferences_injector.dart):
   register the data source, repository interface, use cases, and factory BLoC.
4. [router](examples/reading_preferences/lib/config/routes_manager.dart): resolve a
   new BLoC for the route and let `BlocProvider(create:)` own it.
5. [screen](examples/reading_preferences/lib/features/reading_preferences/presentation/screens/reading_preferences_screen.dart):
   render loaded/busy/error state and dispatch input events.
6. [BLoC, events, state](examples/reading_preferences/lib/features/reading_preferences/presentation/bloc/reading_preferences_bloc.dart):
   coordinate the operation and preserve the last confirmed value when saving fails.
7. [use cases](examples/reading_preferences/lib/features/reading_preferences/domain/usecases/reading_preferences_usecases.dart):
   name the read and save operations using the app's BaseUseCase convention.
8. [repository interface](examples/reading_preferences/lib/features/reading_preferences/domain/repositories/reading_preferences_repository.dart):
   describe the feature operations without importing the storage plugin.
9. [repository implementation](examples/reading_preferences/lib/features/reading_preferences/data/repositories/reading_preferences_repository_impl.dart):
   translate kit results to app results and safe user messages.
10. [data source](examples/reading_preferences/lib/features/reading_preferences/data/datasources/reading_preferences_local_data_source.dart):
    own the app key and call the kit's `KeyValueStore` contract.
11. [Failure](examples/reading_preferences/lib/core/error/failure.dart) and
    [BaseUseCase](examples/reading_preferences/lib/core/usecase/base_usecase.dart):
    self-contained versions of the app's small shared types.

The entity/models folders are absent because the value is a bool. Add an entity
when the feature has meaningful structured data; add a model when its stored or
network representation needs conversion. Do not add empty placeholder classes.
The demo keeps event/state classes together for reading; a larger feature may
split them into adjacent files as existing Story Saver BLoCs do.

## Dependencies in a destination app

Keep that app's compatible installed versions of `flutter_bloc`, `get_it`,
`dartz`, and `equatable`. Declare the three kit packages imported by the example:

```yaml
dependencies:
  genrevibes_core:
    path: packages/genrevibes_starter_kit/modules/foundation/genrevibes_core
  genrevibes_storage:
    path: packages/genrevibes_starter_kit/modules/storage/genrevibes_storage
  genrevibes_storage_shared_preferences:
    path: packages/genrevibes_starter_kit/modules/storage/genrevibes_storage_shared_preferences

dependency_overrides:
  genrevibes_core:
    path: packages/genrevibes_starter_kit/modules/foundation/genrevibes_core
  genrevibes_storage:
    path: packages/genrevibes_starter_kit/modules/storage/genrevibes_storage
```

This is a block to merge into the destination app's pubspec, not a complete
pubspec. Paths are relative to that app's root. Overrides are needed because
kit packages can declare their own versioned dependencies. An app importing
another package adds that package directly, even if it is already transitive.

The example has no separate pubspec in this agents folder. It can be analyzed
using the containing app's resolved dependencies. Running it is an explicit
example-app action, not part of ordinary documentation validation.

## Why each state exists

| Situation | State/UI behavior |
|---|---|
| Not loaded | `keepAwake == null`; no usable switch yet. |
| Missing stored key | Successful load of false, using the feature default. |
| Storage read failed | Error and Retry; not silently treated as a new user. |
| Saving | Keep the old value visible, disable repeated actions. |
| Save succeeded | Display the value returned by the successful operation. |
| Save failed | Keep the last confirmed value and show the error. |
| Screen closes while awaiting | Do not emit through a completed event handler. |

The BLoC uses one busy flag across read/write handlers to prevent overlap.
The store contract returns failures, but the repository also catches unexpected
throws at the boundary. In a real app, send that cause and stack to its existing
logger/crash path once; the sample keeps the UI safe and does not configure analytics.

## Applying the pattern to Story Saver

Use Story Saver's existing `sl`, `Failure`, and `BaseUseCase`; do not copy their
demo versions into the app. Add the feature injector to `initAppDependencies()`.
Its `KeyValueStore` is already registered by `registerRuntime()`, so omit the
example's store creation. Register the route in the existing router.

Localize the labels using the app's current text system and use its theme.
For a shared kit form, use its existing UI instead of building the example's
layers around a duplicated form. The pattern explains app-owned features; it
is not a requirement to wrap every kit method in an identical stack.

## Changing the storage implementation

The feature depends on `KeyValueStore`, not SharedPreferences. Replace the
instance registered under that interface to change the storage adapter. Keep
the key and type stable or add an explicit migration. The BLoC and screen need
no provider-specific changes.

To support an old app key, wrap the store with `MigratingKeyValueStore` mapping
`app.reading.keep_awake.v1` to the real old key. Do not invent a legacy key for
new installs. See [storage migration](../skills/storage-migration/SKILL.md).
