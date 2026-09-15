---
name: project-structure
description: "Organize Flutter app code while keeping shared kit packages separate."
---

# Project structure

For new portfolio apps, put `bootstrap`, `config`, `core`, and `features`
directly under `lib`. Create only folders needed by the app.

- `bootstrap`: module construction, lifecycle, and dependency registration.
- `config`: environment readers, routes, and theme setup.
- `core`: app-wide network setup, common errors, and shared app utilities.
- `features/<name>`: the feature's UI, domain rules, and data access as needed.

BLoC and GetIt are existing portfolio conventions, not kit requirements. Follow
an existing app's architecture during focused changes. Do not introduce empty
repositories/use cases or move every file merely to adopt a package.

Kit packages may use private `lib/src` files. App code imports their public
library, not private implementation files. Use the current app's package name
when crossing app feature boundaries; do not copy another app's imports.

Prefer handwritten code for small new models; use a generator when the task
justifies it rather than introducing one for routine boilerplate.

Keep endpoint definitions with app API code and HTTP clients/interceptors with
network code. Reuse existing generators when the app relies on them; new code
does not need a generator just to follow this layout.

## Full structure and a working feature

Read [architecture](../../ARCHITECTURE_ANALYSIS.md) for the complete tree and
[the worked feature](../../references/feature-walkthrough.md) before scaffolding.
For this app/new portfolio apps, BLoC + GetIt + repository/use-case boundaries
are the default. The kit being provider-neutral does not erase those app conventions.

### Choose a file by its responsibility

- Adding a screen event/state: `presentation/bloc/<feature>_bloc/`.
- Adding the operation called by that event: `domain/usecases/`.
- Defining what the feature can load/save: `domain/repositories/`.
- Calling a kit contract or API: `data/datasources/`.
- Converting data/errors to feature types: `data/repositories/`.
- Converting JSON/database fields: `data/models/`, if representation differs.
- Choosing SDK keys, provider type, or shared listeners: `lib/bootstrap/`.
- Providing a shared provider to app callers: `runtime_registrar.dart`.
- Registering feature BLoCs/use cases: the feature injector, called from the container.

Keep a reusable domain entity free of Flutter context, widgets, and vendor models.
Prefer explicit constructor parameters to a service lookup inside a class.
A screen may resolve its BLoC at the route/provider boundary; the BLoC receives
its use cases through its constructor.

### Adding a feature without breaking existing registration

1. Add the feature files and its injector.
2. Register data source, repository interface, and use cases as lazy singletons
   when they are shared and do not hold screen-specific state.
3. Register the BLoC as a factory. Let the owning BlocProvider close it.
4. Call the injector once from `initAppDependencies()` after runtime registration.
5. Add the route and validate its arguments before building the screen.
6. Confirm the provider is reused, the screen can be reopened with a fresh BLoC,
   and closing it does not dispose a runtime-owned provider.

Do not migrate unrelated legacy files merely to make the tree look uniform.
New code should follow the target structure while old callers move deliberately.

For naming, typed data, networking, and code-generation conventions, read
[working conventions](../../references/working-conventions.md).
