---
name: starter-kit
description: "Select and connect modular GenRevibes packages in a Flutter app."
---

# Starter kit

Read [architecture](../ARCHITECTURE_ANALYSIS.md) and the
[checked kit revision](../references/kit-compatibility.md) before changing integration code.

For a new portfolio app, include the complete
[guaranteed baseline](../ARCHITECTURE_ANALYSIS.md#11-guaranteed-portfolio-integrations).
Package selection means choosing adapters and additional capabilities around that
baseline; it does not mean omitting Lab, feedback, monetization or telemetry until
the user mentions them again. For adoption in an existing app, keep the requested
feature scope. A guaranteed feature can still be optional for successful startup.

1. Inspect the app's dependencies, startup code, routes, and existing providers.
2. Select the portfolio baseline plus the product's additional capabilities for
   new apps; select the scoped capability for a focused adoption. Find paths in the
   [kit README](../../../../packages/genrevibes_starter_kit/README.md).
3. Add each imported package as a direct dependency. Point it at its module
   directory, not the kit repository root. Resolve transitive kit packages with
   path overrides as shown in the kit's smoke example.
4. Read the selected adapter's native setup and its dependency constraints.
   Firebase, RevenueCat, Appodeal, and OneSignal are optional choices.
5. Create the shared controllers/providers once in app startup. Give the same
   instances to feature UI, policy binders, and Kit Lab.
6. Follow [runtime setup](../skills/runtime-setup/SKILL.md) for startup and cleanup.
   A UI-only package can be used without the runtime coordinator.
7. Supply app routes, text, credentials, product IDs, and feature rules. Reuse
   kit implementations for shared behavior; do not copy them into the app.

The kit has no global service locator or app BLoCs. Use the app's existing
state management and dependency injection.

For feature composition, use the [portfolio adoption guide](../../../../packages/genrevibes_starter_kit/docs/portfolio-adoption.md).
Check missing credentials and unsupported platforms explicitly. Do not describe
source inspection as a successful build or device check.

## Dependency example: add a shared contact form

The app needs the contract, UI, and chosen adapter. It does not need the entire
kit's provider list. Merge these entries into the app-root pubspec:

```yaml
dependencies:
  genrevibes_feedback:
    path: packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedback
  genrevibes_feedback_ui:
    path: packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedback_ui
  genrevibes_feedbacknest:
    path: packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedbacknest

dependency_overrides:
  genrevibes_core:
    path: packages/genrevibes_starter_kit/modules/foundation/genrevibes_core
  genrevibes_feedback:
    path: packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedback
```

The app can declare a direct dependency and an override for the same package:
the dependency expresses what app code imports; the override controls resolution
through transitive versioned kit dependencies. For another feature, inspect its
manifest and include its transitive kit dependencies rather than guessing.
Run `flutter pub get` after editing the destination app's manifest when dependency
resolution is part of the task. Do not change versions just to match an old example.

### What the setup actually changes

| File | Change |
|---|---|
| `pubspec.yaml` | Selected package paths and compatible overrides. |
| `bootstrap/app_env.dart` | Read FeedbackNest's key and create its configuration. |
| `bootstrap/app_bootstrap.dart` | Construct one provider; register it as optional if startup can proceed without support submission. |
| `bootstrap/app_runtime.dart` | Hold the `FeedbackProvider` instance if the app uses a runtime object. |
| `bootstrap/runtime_registrar.dart` | Register that instance under `FeedbackProvider`. |
| Settings action | Open `openFeedbackPage` with the existing provider, labels/theme, and optional mask/picker. |

Read [feedback](../skills/feedback/SKILL.md) for the full action and failure states.
The [integration functions](../references/integration-examples.md) have complete
imports and show which values the app supplies.

### Check whether shared code already exists

Before writing a controller or UI, look for the capability in the kit inventory
and read its public contract. If the kit implements the behavior, configure and
call it. If it only exposes a contract, select an adapter. If the feature's behavior
is product-specific, write it in the app. Propose a kit API change when several
apps need the missing behavior; do not hide copied implementations in each app.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_starter_kit](../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_starter_kit/README.md); [public exports](../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_starter_kit/lib/genrevibes_starter_kit.dart).
- [genrevibes_core](../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_core/README.md); [public exports](../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_core/lib/genrevibes_core.dart).
