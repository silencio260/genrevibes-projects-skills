# Shared-feature integration examples

[shared_features.dart](examples/integrations/shared_features.dart) contains
complete functions with imports. These functions demonstrate specific boundaries;
they are not a complete app bootstrap. Their arguments are named and typed so
there are no unexplained `sl`, `env`, or `config` variables.

| Function | When to call it | Caller supplies / still handles |
|---|---|---|
| `makeAppodealConsent` | During bootstrap | Actual platform app key, logger; consent is initialized by its module registration. |
| `makeRuntime` | During bootstrap | Already constructed modules/scope; call initialize and inspect its result. |
| `startDeferredAfterFrame` | After normal app UI is mounted | Successful required startup; dispose scope if UI/runtime is replaced. |
| `makeDeveloperAccess` | Before ads config settles | Shared store and actual build mode; initialize and register cleanup. |
| `openContact` | From Settings action | Initialized feedback provider; this example specifically masks with PostHog. |
| `makeAccessPolicy` | During composition | Exact nonempty entitlement ID from app product configuration. |
| `followEntitlements` | Once during composition | The app's one snapshot holder; get the initial snapshot and handle errors too. |
| `openPaywall` | On an app-chosen upsell action | Initialized IAP provider with hosted UI; busy state and all purchase outcomes. |
| `restorePurchases` | On explicit restore | Busy state, result handling, entitlement refresh into app state. |
| `makeRemoteConfig` | After Firebase setup | One schema; initialization, binder registration, refresh and cleanup. |
| Permission functions | User action / app resume | Initialized coordinator and actual feature's permission kinds. |
| `scheduleReadingReminder` | After permission and user opt-in | Initialized scheduler with timezone/native setup; persist user's choice/campaign. |
| `takePendingTap` | Once routes are ready | Validate and navigate; subscribe separately to live interactions. |
| `makeLabHost` | After runtime construction | Existing modules/logger; add a real event catalogue if the app uses analytics. |

## Result handling

An awaited `KitResult` can be failure even when no exception was thrown.
Use `fold(onSuccess: ..., onFailure: ...)` or an exhaustive pattern match.
Returning that result from these functions deliberately leaves app UI handling
with the caller. Do not drop it just because the example returns a Future.

For IAP, success contains `PurchaseResult.status`. Purchased, restored, pending,
cancelled, and notPurchased are different non-error outcomes. Provider failures
are carried by the outer KitFailure. Do not collapse these into one boolean.

## Owning the objects

Construction functions return objects; they do not register them with GetIt.
Register existing instances at the runtime boundary and pass them into features.
The scope owns module/listener cleanup. The store is not a StarterModule and has
no generic initialization/disposal call. The chosen storage adapter manages its
own low-level client behavior.

Do not call `makeRuntime` a second time to open Kit Lab. The Lab must inspect
the instances already serving the app. Do not attach a second entitlement listener
inside each paywall screen if the runtime already maintains app access state.

## Dependencies and adaptations

Each imported package must be a dependency of the destination app. Use its path
under the kit's `modules` directory and root overrides for transitive kit packages.
The file combines unrelated examples for validation; copy only the function and
imports needed for a particular app. Copying every import would defeat modular reuse.

The contact example uses PostHog. An app without PostHog removes that import and
mask wrapper; it still uses the same shared feedback page. The reminder example
uses example ID 4100 and payload `reading_home`; allocate an ID and route value
that do not collide with the destination app's existing notifications.
