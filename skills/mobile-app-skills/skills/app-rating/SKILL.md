---
name: app-rating
description: "Get as many store reviews as store rules allow: when to ask, the two ask channels, eligibility timing, saved prompt state, and compliance limits."
---

# App rating

Every portfolio app asks for store reviews, and it asks at every good moment that
store rules allow. More reviews means a better store ranking and more installs.
The limit is compliance, not how polite we want to be: an app that breaks the
review rules can lose its reviews or be removed from the store.

Use `RatingCoordinator` for eligibility and saved prompt state, and
`InAppReviewStoreProvider` for the store sheet and the listing link. The app
supplies its good moments, the card UI and the timing values below.

Lunaris Network (`lib/features/rating/lunaris_rating.dart`) is the reference
implementation. Copy its shape.

## Store rules (never break these)

Google Play (in-app review guidelines and the ratings and reviews policy):

- Ask no question before or while showing the review request. "Do you like the
  app?", "Would you give us 5 stars?" and star pickers all count.
- No review gating. Never send only happy users to the store, and never send
  unhappy users to feedback instead. The same button goes to the same place for
  everyone.
- Offer nothing for a review: no coins, boosts, premium days, removed ads or
  unlocked features. Don't hint at a reward either.
- Don't open the in-app review sheet from a button. Its quota can make the
  button do nothing. A button opens the Play listing instead.
- Don't change the sheet, cover it, or show an ad over it.

**The portfolio review card knowingly breaks two of these.** Its title asks
"Are you enjoying your experience?", and its **Yes** button requests the store
sheet. The owner chose this pattern and accepts the risk: Play can remove
reviews, reject an update or give the app a policy strike. Keep the rest. **Not
now** and **Don't ask again** only close the card. Never send a negative answer to
feedback, and never offer a reward.

App Store (guideline 5.6.1):

- Ask only through the system review API (`in_app_review`'s `requestReview`).
  Custom review prompts are not allowed on iOS, so the review card is Android
  only.
- The system shows the sheet at most 3 times in 365 days and decides when.
- A Settings row that opens the App Store review page is fine, because the user
  asked for it.

**Story Saver's star dialog breaks the gating rule.** It sends 4–5 stars to the
store and lower scores to feedback, using `RatingOutcomeRouter`'s threshold.
Don't copy it, and don't use the router's score-based routing in a new app.
Move Story Saver to the pattern below.

## The two ask channels

1. **Store review sheet** (`StoreReviewProvider.requestReview`). It converts
   best because the user never leaves the app. The store rations it per user
   and declines without telling you. A successful request does not mean anything
   was shown.
2. **Review card** (Android only). This is your own dialog: a large decorative
   star (not a picker), the title "Are you enjoying your experience?", the line
   "Tap Yes to leave a quick rating", and these actions, in order:
   - **Don't ask again**, faded. It records `RatingOutcome.never`. It is left
     out of the first 5 cards; count cards with
     `recordTrigger('review_card_shown')`.
   - **Not now**, muted. It, or dismissing the dialog, records
     `RatingOutcome.maybeLater`, which snoozes the next ask.
   - **Yes**, a bold filled button in the accent color. It records
     `RatingOutcome.submitted`, then requests the store sheet. If the sheet is
     unavailable, or the request returns in under 800 ms (nothing was shown),
     it opens the Play listing instead. That way **Yes** never does nothing.

   The card always appears, so it reaches users whose sheet quota is used up.

Alternate the two on each eligible ask. Use the sheet first, then the card,
then the sheet again. Count asks with
`coordinator.recordTrigger('review_ask')`: odd numbers use the sheet and even
numbers use the card. When one channel can't run right now, use the other: on
iOS, when the sheet is unavailable, or when the card's screen is covered. When
a sheet request returns in under 800 ms it showed nothing, so show the card
right after it. That way every eligible day reaches the user.

Ask once a day, at a good moment, until the user taps **Yes** or **Don't ask
again**. **Not now** only waits until the next day.

Also give every app a Settings row, "Rate <App>", that opens the listing
directly with no eligibility check.

## When to ask

Ask right after a moment of success, never in the middle of a task, after an
error, or on first launch. Each app names its good moments, such as:

- a cycle started (Lunaris);
- a file saved or downloaded (Story Saver, video downloader);
- a document exported (PDF editor, resume builder);
- a connection made (VPN), a game finished, or a streak reached.

Call the rating service from every good moment, not just one. More moments mean
more eligible asks.

- **First ask.** On the 2nd good moment, call `evaluate(force: true)`. Force
  skips install age, app opens and the interval, but never an opt-out. Story
  Saver uses the 2nd download and Lunaris the 2nd started cycle.
- **Later asks.** Call `evaluate()` at every good moment with these portfolio
  timing values. The kit's defaults are much slower, so always pass yours:

| `RatingCriteria` | Kit default | Portfolio value |
| --- | --- | --- |
| `minimumAppOpens` | 5 | 3 |
| `minimumInstallAge` | 3 days | 1 day |
| `minimumIntervalBetweenPrompts` | 7 days | 1 day |
| `snooze` ("Not now") | 2 days | 1 day |

- Wait about 1.5 s after the moment so a closing ad or success snackbar settles.
- Check again that the app is in the foreground and that no dialog, sheet or
  paywall is open before showing the card.

## Wiring

- Create one `RatingCoordinator(criteria: ...)` with an ad suppression hook, and
  register it as a kit module. `present()` keeps ads off while the ask is open
  and starts the interval, even when the store shows nothing.
- Keep the policy in one app service, like `LunarisRating`. It records triggers,
  calls `evaluate`, picks the channel and records outcomes. It owns no
  `BuildContext`.
- The root screen of the signed-in app shows the card. It registers itself with
  the service in `initState`, unregisters in `dispose`, and reports whether it
  can show a dialog right now. This way cubits and blocs can report good moments
  without UI code.
- Guard against overlapping asks with a busy flag. Two good moments close
  together must not stack two prompts.
- Initialize the store with `RatingKeys.legacyKeys`, and map the app's old
  counters too, when adopting in an app that already saved rating state.
- Build the coordinator with an `OffsetKitClock` (real time until moved).
- Log each step of the rating service through the kit logger with module id
  `app_rating`: the good moment, why an ask was blocked, which channel ran, and
  the card answer. Then Kit Lab's Log page and logcat show what happened.
- Connect Kit Lab's Rating page to the live instances, never copies:
  `rating` (the coordinator), `storeReview`, `clock`, and `DevRatingTools`
  with the app's counter names, `askNow`, `previewPrompt` and
  `installSource` (`PackageInfo.installerStore`). The Lab page covers the
  root screen, so `askNow` must show the card over the Lab's own context.
  Lunaris's `lib/features/developer/dev_tools_entry.dart` shows the wiring.

The store never says whether a review was written. Never record "rated" or a
star count. **Rate now** and **Don't ask again** end the asking for good: asking
someone who already reviewed earns "keeps nagging me" reviews.

## Analytics

Track these two events with the app's analytics service, and add them to the
Kit Lab catalogue:

- `review_requested` with `channel`: `store_sheet` or `card`. For the store
  sheet this counts requests, not displays.
- `review_card_result` with `action`: `rate`, `later` or `never`.

Use `review_card_result.rate` and the store console's review count to judge
changes to the timing. A request count is not a review count.

## Testing

- **Android.** The store sheet only appears for an install from Google Play,
  such as the internal testing track or internal app sharing. On a build you
  installed yourself it never appears, but the card still does. Use Play's
  `FakeReviewManager` for unit tests of the native flow.
- **iOS.** Development builds show the sheet every time and TestFlight builds
  never do. Only App Store builds follow the real quota.
- **Kit Lab › Rating** is the test bench. It shows:
  - the decision and its block reason, when the time rules next allow an ask,
    and how many app opens are still missing;
  - the stored install date, last ask, opt-out and every counter;
  - who installed the build, with a warning when it wasn't the store.

  It can also:
  - **Ask now:** run the app's real ask, skipping the timing rules but not an
    opt-out. It records the ask and the answer like a real one;
  - **Preview the prompt:** show the card (with Don't ask again) without
    recording anything;
  - request the store sheet, open the listing, or count an app open;
  - move the rating clock forward 1 h, 1 d, 2 d or 7 d, then back to real
    time;
  - **Reset prompt history** (opt-out, last ask, app opens) or **Full reset**
    (also the counters, so the forced first ask happens again).

Report results honestly. "The review was requested" is not "the sheet appeared",
and the sheet appearing is not "the user rated".

## Checklist for a new or existing app

- [ ] There is a good-moment call at each success point in the app.
- [ ] The first ask is forced on the 2nd good moment.
- [ ] `RatingCriteria` uses the portfolio values, not the kit defaults.
- [ ] Asks alternate between the store sheet and the review card. The card is
      Android only.
- [ ] No star picker, no score-based routing and no reward. Not now and Don't
      ask again only close the card.
- [ ] Yes requests the store sheet and falls back to the listing.
- [ ] Don't ask again is hidden on the first 5 cards.
- [ ] Ads are suppressed while an ask is open.
- [ ] There is a Settings "Rate <App>" row that opens the listing.
- [ ] The card is translated into every app language.
- [ ] Both analytics events are in the catalogue.
- [ ] The native flow is tested on a Play-installed build.
- [ ] Kit Lab's Rating page has the store adapter, clock and `DevRatingTools`,
      and **Ask now** shows the app's real prompt.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_app_rating](../../../../../packages/genrevibes_starter_kit/modules/app_rating/genrevibes_app_rating/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/app_rating/genrevibes_app_rating/lib/genrevibes_app_rating.dart).
- [genrevibes_app_rating_in_app_review](../../../../../packages/genrevibes_starter_kit/modules/app_rating/genrevibes_app_rating_in_app_review/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/app_rating/genrevibes_app_rating_in_app_review/lib/genrevibes_app_rating_in_app_review.dart).
- Connect shared feedback through the [feedback skill](../feedback/SKILL.md),
  as its own Settings action. It is never a branch of the review ask.
