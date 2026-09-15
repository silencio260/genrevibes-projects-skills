---
name: onboarding
description: "Build a shared onboarding flow with app content, completion state, and optional actions."
---

# Onboarding

Use `OnboardingController` for persisted completion and `OnboardingFlow` for UI.
The app supplies pages, artwork, labels, layout, and destination.

1. Initialize the controller with a store that adopts real legacy keys. See
   [storage migration](../storage-migration/SKILL.md).
2. Route from `isCompleted`, not retention counts. Put the flow in the app's Scaffold.
3. Configure ordered `finishActions`: required completion/navigation and any
   deliberate optional actions. Decide whether skip runs the same actions.
4. Bound optional asynchronous actions and use `continueOnError` where failure
   should not trap onboarding. Do not give an interactive paywall an arbitrary
   short timeout that navigates behind its still-visible native UI.
5. For ads, supply an `OnboardingAdSlot` builder. The onboarding package does not
   own an ad SDK. Gate it with the same premium, startup, provider, and developer
   rules as other placements, plus the onboarding remote switch.
6. Reserve ad space only on supported ad pages. Supply a placeholder and keep
   controls away from ads. Page count, ad frequency, full-screen artwork, and
   controls layout are app choices.

Check repeated finish taps, optional failures, completion persistence, upgraded
installs, no-ad variants, and small-screen layout. Reuse the same controller in Kit Lab.

## Separate completion from page presentation

Construct the controller in the runtime with the shared migrated store. Reuse
that instance in initial routing, the onboarding flow, and Kit Lab. The app's
onboarding feature supplies its pages and navigation; it should not add another
completion preference alongside the controller.

Before building pages, define their purpose and the finish sequence. For example:
show product value, explain an optional permission at the relevant action, then
complete onboarding and enter the app. Choose whether a skipped flow records
completion and whether it also runs optional actions; implement that choice in
the flow configuration rather than unrelated callbacks on several buttons.

When persisting completion fails, handle that result explicitly. If the app
continues, acknowledge that a later launch may show onboarding again. Do not
silently label a failed save as persisted completion. Disable repeated finish
actions while the current sequence runs.

Permissions, purchases, and ads remain owned by their existing providers and
policies. An onboarding screen is another caller of those features. It must not
construct its own consent provider, purchase SDK, or ad policy. Optional actions
must have defined failure behavior so the user can reach the app.

For portfolio reuse, replace artwork, copy, page count, and the destination;
retain the shared completion and flow behavior. Check content with large text,
keyboard-free small screens, and unavailable ad slots. Do not reserve an empty
ad area on pages where no ad slot is configured.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_onboarding](../../../../../packages/genrevibes_starter_kit/modules/onboarding/genrevibes_onboarding/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/onboarding/genrevibes_onboarding/lib/genrevibes_onboarding.dart).
