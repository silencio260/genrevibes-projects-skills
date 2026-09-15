---
name: paywall
description: "Present hosted or app-owned paywalls using the existing IAP provider."
---

# Paywall

Configure purchases using [IAP](../iap/SKILL.md) first.

- For RevenueCat-hosted paywalls/customer center, add
  `genrevibes_iap_revenuecat_ui` and supply `RevenueCatUiAdapter` when constructing
  the provider. Use its [example](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap_revenuecat_ui/example/main.dart).
- For an app-owned paywall, use the same provider's products, purchase, and
  restore operations. Do not add hosted UI dependencies unnecessarily.

Show real localized product prices and the benefits of the feature being gated.
Include restore and a usable close/back action. Explain unavailable products
rather than showing a permanent spinner.

Return the actual paywall outcome to the caller. Refresh access from the shared
entitlement snapshot; do not unlock solely because the paywall closed. Keep
pending payment separate from success and show a restore error when it fails.

The app chooses when to show a paywall. Onboarding and Settings should call the
same integration. An optional paywall failure must not trap onboarding.
Record display/action events once without duplicating provider purchase events.

Check cancelled, pending, purchased, restored, missing products, and failure UI.

## Hosted and custom UI are different integrations

For hosted RevenueCat UI, construct the provider with `uiPresenter:
const RevenueCatUiAdapter(displayCloseButton: true)`. Then call the existing
provider's `presentPaywall`. Installing the UI package alone does not attach it
to the provider. A customer-center action also needs supported hosted UI.

For custom UI, call `getProducts`, render actual localized prices, let the user
select a product ID from those results, then call `purchase`. Do not hardcode a
price or send a display label where a product identifier is required.

### App screen behavior

1. Enter with a feature/placement reason, not an automatic purchase action.
2. Load products or open supported hosted UI. Handle missing offering/configuration.
3. Disable competing purchase/restore actions while one is active.
4. Interpret KitFailure and every PurchaseStatus as described by the IAP skill.
5. Update the shared entitlement holder, then re-evaluate the requested feature.
6. Return the actual outcome to the caller. Closing a page does not imply paid access.

A timeout on an interactive native paywall can end an app wait while the native
page remains open. Do not navigate a second route behind it or start another
purchase. Let the integration's actual close/result lifecycle drive navigation.
For a blocked optional onboarding paywall, use a defined recovery path without
marking it as a purchase.

### Verify the caller as well as the page

Settings restore, onboarding upsell, and locked-feature entry should use the
same purchase provider. Check that each caller handles cancellation and pending
payment correctly. Confirm the close button remains available and a failed
product load does not leave the entire app behind a spinner.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_iap](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap/lib/genrevibes_iap.dart).
- [genrevibes_iap_revenuecat_ui](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap_revenuecat_ui/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/iap/genrevibes_iap_revenuecat_ui/lib/genrevibes_iap_revenuecat_ui.dart).
