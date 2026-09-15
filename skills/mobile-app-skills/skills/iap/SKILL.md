---
name: iap
description: "Connect purchases, restores, entitlement updates, and feature access through the kit IAP interfaces."
---

# Purchases and subscriptions

Use `IapProvider` with the chosen adapter. RevenueCat uses
`RevenueCatIapProvider` and `RevenueCatConfiguration`. Supply public SDK keys
for each supported platform, product IDs, offerings, and exact entitlement IDs.

1. Create one provider and initialize it through app startup.
2. Read its entitlement snapshot and subscribe once to `entitlementChanges`.
   Store one authoritative snapshot for the app's access decisions.
3. Define feature rules with `EntitlementAccessPolicy` and
   `FeatureEntitlementRule`. Do not equate any purchase with every premium feature.
4. Let the app choose anonymous or signed-in purchase identity. Connect login
   and logout explicitly; Firebase identity is not linked automatically.
5. Keep developer simulation separate from actual entitlements and require
   `DeveloperAction.premiumSimulation` whenever applying it.
6. Preserve distinct purchased, restored, cancelled, pending, and failure outcomes.
   A restore failure must reach the UI; a cancelled paywall is not a purchase.
7. Prevent concurrent purchase/restore actions, restore UI controls on failure,
   and cancel entitlement listeners on shutdown.

Use [paywall](../paywall/SKILL.md) for hosted or app-owned presentation.
Subscription state belongs in app state management; the kit does not supply an
app-specific IAP BLoC. Keep unknown/loading state distinct from known free state
when deciding whether to request ads.

Use actual provider amounts/currency for revenue. A completion event without
price data must omit revenue rather than report zero USD. Backend-paid access
must be verified by the backend, not a client developer switch.

Check purchase, cancellation, pending payment, restore, account switching, and
entitlement changes. State which flows still need a store sandbox/device.

## Exact provider operations

| Operation | Result |
|---|---|
| `getProducts(productIds: ..., placementId: ...)` | `KitResult<List<IapProduct>>`; empty IDs can select the current offering. |
| `purchase(productId)` | `KitResult<PurchaseResult>`. |
| `presentPaywall(requiredEntitlementId: ..., placementId: ...)` | Same purchase result; requires hosted UI support. |
| `getEntitlements(forceRefresh: ...)` | `KitResult<EntitlementSnapshot>`. |
| `restorePurchases()` | `KitResult<EntitlementSnapshot>`, not a PurchaseResult. |
| `identify(appUserId)` / `resetIdentity()` | New entitlement snapshot for the resulting customer identity. |
| `entitlementChanges` | Live snapshots; attach once and dispose the subscription. |

See complete typed functions in [integration examples](../../references/integration-examples.md).
The app supplies the actual entitlement ID; a blank string is not a safe default.

### Setup across app files

Create `RevenueCatConfiguration` from platform SDK keys in app_env. Construct
`RevenueCatIapProvider` in bootstrap; supply `RevenueCatUiAdapter` only when the
app uses hosted paywalls/customer center. Register the existing provider under
IapProvider. The app data source calls this interface, its repository maps
KitResult to app Failure/results, and its BLoC drives busy/result UI.

Keep one holder for the current entitlement snapshot. Subscribe to changes and
fetch the initial state. Guard results by runtime/account identity so a late
refresh for the previous account cannot overwrite the new account's access.
If the app already has a subscription manager, update it instead of creating
another independently cached premium flag.

### Interpret both levels of result

An outer KitFailure is a provider/configuration/network failure. An outer
KitSuccess can still contain `cancelled`, `pending`, or `notPurchased`.
`purchased` and `restored` are positive outcomes, but feature access still comes
from the entitlement snapshot and its policy. Show cancellation as cancellation,
not an error and not a success toast. Pending payment stays pending until later
provider state grants access.

A restore returns a snapshot directly. Apply it through the same holder and
explain whether the required entitlement is present. Do not report successful
restoration when the provider returned a failure or when no access was found.

### Product access and analytics

Use `FeatureEntitlementRule(featureId: ..., anyOf: {...})` for each product rule.
One entitlement can unlock several features; another can unlock only exports.
Do not reduce that mapping to “has any active entitlement.” Developer simulation
is a separate input permitted by the action grant, never a rewritten purchase record.

Use provider purchase data for revenue. A paywall completion without price data
can emit an outcome event with no amount. Renewals often happen outside the app;
do not claim a button listener captures them. Retain the app's event contract
when replacing old wrappers.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_iap](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap/lib/genrevibes_iap.dart).
- [genrevibes_iap_revenuecat](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap_revenuecat/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap_revenuecat/lib/genrevibes_iap_revenuecat.dart).
