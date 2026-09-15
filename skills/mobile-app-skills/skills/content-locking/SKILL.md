---
name: content-locking
description: "Apply shared entitlement rules and app-owned quota or reward access to a feature."
---

# Feature access

Use `EntitlementAccessPolicy` with `FeatureEntitlementRule` for paid features.
Supply app-owned feature and entitlement IDs. Read the snapshot maintained by
[IAP](../iap/SKILL.md), not a second purchase cache.

Keep these decisions separate:

- Real purchase entitlements.
- Developer simulation, allowed only by the current developer action grant.
- Server-enforced quota or authorization.
- A specific completed rewarded-ad grant, if the product offers one.

Recheck access before the operation as well as when rendering its button.
Show the relevant paywall or quota explanation. Do not turn network errors into
“subscription required,” and do not let build flags bypass backend authorization.

App-specific founders offers and rewarded alternatives are optional product
choices. Do not add them to every app. See [quotas](../quota-rate-limiting/SKILL.md)
for paid or rate-limited backend operations.

Check expiry, account switch, pending purchase, and revoked developer access.

## Write the feature-to-entitlement mapping explicitly

The [integration example](../../references/integration-examples.md) constructs
an `EntitlementAccessPolicy` from an app-supplied ID. For a product with separate
ad-free and export purchases, define separate rules instead of checking a global
premium flag for both. Keep the rule definition near app monetization config.

At a feature entry, evaluate `policy.isUnlocked(featureId, snapshot)` using the
current snapshot. If the app deliberately allows developer simulation, combine
that result with a currently permitted simulation action; do not modify snapshot
entitlements. UI badges, ad eligibility, and operation checks must read the same
access source.

### Access changes while a page is open

A subscription can expire, an account can switch, or developer access can be
revoked. Rebuild the entry UI and recheck before starting the protected operation.
Define what happens to an operation already underway: allow it to finish, stop
it safely, or let the backend decide. Do not erase a user's output merely because
a visual badge changed.

### Quotas and rewarded access

A quota answers how much use remains. An entitlement answers what was purchased.
A rewarded grant applies to the specific operation/period the product defines.
Keep all three meanings explicit. A paid backend operation must verify them
server-side; a client's “unlocked” UI is not proof of authorization.

Distinguish unknown purchase state from known free state. Loading or network
failure should not be treated as proof the user needs to pay again. Use the
provider's available cached state and the app's defined recovery policy.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_iap](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap/lib/genrevibes_iap.dart).
