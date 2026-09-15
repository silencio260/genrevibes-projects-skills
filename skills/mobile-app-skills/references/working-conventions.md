# Working conventions for portfolio app features

Use these conventions for Story Saver and new apps following its structure.
Preserve an existing app's working conventions when adopting a kit feature there.
Read the actual files before introducing a replacement abstraction.

## Names and file organization

Use snake_case for files, PascalCase for types, and camelCase for methods and
values. Keep names about the feature operation, not the vendor behind it:
a reading-preferences repository should not become a SharedPreferences service
in its domain interface.

Existing Story Saver interfaces may use names such as `SomethingBaseRepo` and
implementations such as `SomethingRepo`. Follow adjacent code when extending
those features. New examples use `SomethingRepository` and
`SomethingRepositoryImpl` to make the roles obvious. Both express the same
boundary; do not rename a working feature solely to match an example.

Keep substantial types in separate files. Larger BLoCs can use adjacent event
and state files with the project's existing part/import arrangement. The small
worked example keeps them together for reading. States should be immutable and
have meaningful equality, using the app's existing Equatable convention.

Keep files directly within the app's `lib/core`, `lib/config`, `lib/bootstrap`,
and `lib/features` structure. Private `lib/src` is appropriate inside kit packages,
but is not the default app folder layout.

## Entities and stored/network models

An entity expresses data the feature works with. For a saved document, that could
be its stable ID, title, and creation time. It belongs in `domain/entities` and
does not depend on a widget, HTTP response, or database document type.

A model maps an external format to that entity. It belongs in `data/models` and
handles field names, optional/older fields, timestamps, and serialization. Use
composition or the feature's existing inheritance pattern; do not require a
second object with identical fields when no conversion is needed.

When adding a field:

1. Inspect existing stored/server records and the API contract.
2. Decide whether the field is required, optional, or has a backward-compatible
   default. Missing data is not permission to invent a false business value.
3. Parse and validate the external representation in the model/data boundary.
4. Map to the entity before returning from the app repository.
5. Preserve existing serialized field/type IDs, or write an explicit migration.
6. Keep widgets working with typed feature data rather than raw maps.

A list endpoint also needs a pagination contract: cursor/page input, ordering,
end-of-list signal, and duplicate handling. Store that state in the owning BLoC
or repository as appropriate. Do not infer the end of results from a failed page
request or clear previous pages when the next page fails.

## HTTP and connectivity

Use the existing app HTTP client, interceptors, and endpoint configuration when
present. Story Saver's current `lib/core` does not contain every hypothetical
network helper shown in older guides. Do not import a nonexistent `DioHelper`
or create one unless the feature actually needs an app HTTP layer.

For a new HTTP feature, choose a client compatible with the app's dependencies.
Create/configure it at the dependency boundary, supply it to the data source,
and keep endpoint parsing out of screens. Define connect/receive budgets and
pass cancellation through where supported. Do not hardcode production server
URLs or credentials in each request method.

Attach authentication through the existing session mechanism. Refresh behavior
must avoid multiple concurrent refreshes and must not retry forever after invalid
credentials. Account changes must prevent old requests updating new-user state.
Keep response/body logging off for private content.

Connectivity status is a hint. Attempt the actual operation and handle its
result; a connectivity precheck should not permanently forbid a request that
could succeed. Decide whether reads can fall back to cache and how stale data is
shown. Retry side effects only with the operation's duplicate-prevention policy.

## Use cases and state changes

A use case represents one product operation and uses the app's
`BaseUseCase<Output, Input>` convention. Use `NoParams` for an operation without
input. Put product rules in use cases or domain services; keep loading flags,
selection state, and display coordination in BLoC.

Describe states that matter to the user: initial loading, usable data,
refreshing existing data, saving, and recoverable failure. Avoid replacing an
entire useful screen with a generic error when only one update failed. Preserve
the last confirmed data or implement an explicit optimistic update with rollback.

Choose concurrency by operation. A search may ignore stale results; a save may
serialize or reject repeated taps. Do not assume separate BLoC event handlers
run in a single ordered queue. Check ownership after awaited work before emitting
or navigating. The worked example uses one shared busy guard for read/write.

## Code generation

Prefer manual Dart types, registrations, and adapters for new work under these
conventions. Do not introduce build_runner or a generator merely to implement a
small model or injector. Keep an existing app's working generated code and its
required maintenance process when editing that feature.

If a large API/model surface makes generation necessary, explain the concrete
maintenance benefit and use the app's established approach where possible.
Do not manually edit generated outputs while leaving their source unchanged.
For manual Hive adapters, preserve type IDs and field IDs; “manual” does not
mean a stored format can be changed without migration.

## Implement one feature in order

1. Find the existing feature or choose its app folder; read the relevant kit skill.
2. Identify the shared operation already provided by the kit. Reuse complete
   kit UI when it fits instead of rebuilding its form or developer flow.
3. Define the app-owned data, repository operations, and failure meanings.
4. Implement use cases and the data-source/repository mapping.
5. Register existing runtime providers, then the feature's dependencies and BLoC.
6. Implement screen states and register the route with correct BLoC ownership.
7. Connect app text/theme, native setup, and lifecycle only where needed.
8. Inspect success, returned failure, thrown exception, cancellation, and late
   completion for the changed operation. Run analysis when useful. Tests/builds
   follow the repository's opt-in rules.
9. Report what changed and what was actually checked. Do not describe static
   source review as a successful native flow or deployed service verification.
