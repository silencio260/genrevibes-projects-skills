---
name: app-rating
description: "Reuse rating eligibility, saved prompt state, and store/feedback routing."
---

# App rating

Use `RatingCoordinator` for eligibility and saved prompt state. Use
`InAppReviewStoreProvider` for supported store review actions. The app supplies
prompt UI, store identity, timing policy, and any feedback callback.

- Initialize the store with `RatingKeys.legacyKeys` when adopting existing users.
- Respect opt-out and snooze. Do not bypass them with a hand-written prompt timer.
- Read the package's `RatingOutcomeRouter` behavior before adopting it. The app
  must deliberately choose that flow and check current store rules for its use.
- Connect shared feedback through the [feedback skill](../feedback/SKILL.md).
- Suppress conflicting ads while a rating prompt is open and release suppression
  on every exit path.
- Pass the running coordinator to Kit Lab; do not create a second rating history.

A successful review request does not prove the store showed a dialog or the user
submitted a rating. Report those states accurately. Check opt-out, snooze,
missing store configuration, and upgraded prompt history.

## Connect eligibility, presentation, and store request

Initialize the shared coordinator using migrated rating state. At the app's
chosen successful user milestone, ask its eligibility policy before opening a
prompt. Keep the prompt's active state in one owner so multiple screens cannot
present it at once. Do not prompt simply because a widget rebuilt.

Define the outcomes before wiring buttons: dismiss/snooze, opt out, request a
store review, and any explicit feedback action. Record each through the shared
coordinator's API so future eligibility reflects what actually happened.
Release ad suppression in a finally/close path for every outcome, including an
exception while opening the store or feedback screen.

A platform review API may accept a request without showing UI. Do not record
“user rated five stars” from a successful API result or from a rating selected
inside the app. Check the selected store's current rules before implementing
rating-based routing; the existence of a kit router is not approval of a product
flow under those rules.

Reuse the live coordinator and store provider in developer previews. Previewing
should not accidentally consume a production prompt opportunity or pretend to
submit a real rating. State what the preview actually changes.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_app_rating](../../../../../packages/genrevibes_starter_kit/modules/app_rating/genrevibes_app_rating/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/app_rating/genrevibes_app_rating/lib/genrevibes_app_rating.dart).
- [genrevibes_app_rating_in_app_review](../../../../../packages/genrevibes_starter_kit/modules/app_rating/genrevibes_app_rating_in_app_review/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/app_rating/genrevibes_app_rating_in_app_review/lib/genrevibes_app_rating_in_app_review.dart).
