---
name: onboarding
description: "Build the onboarding screens: one real illustration image per page (found online or generated), title, copy and a call to action, plus completion state and optional actions."
---

# Onboarding

Use `OnboardingController` for persisted completion and `OnboardingFlow` for UI.
The app supplies pages, artwork, labels, layout, and destination.

When the owner asks for an onboarding screen, they mean illustrated pages: one
real illustration image per page, as described in
[default look](#default-look-one-illustration-per-page). Build anything else
only when they ask for it by name.

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

## Reset must replay immediately

A successful onboarding reset must take the user through the introductory flow
again immediately, including when reset is initiated inside Kit Lab. Do not just
clear a preference and wait for the next launch.

- Use the runtime's initialized `OnboardingController` for both the root gate and
  Kit Lab. Seed the root view from `isCompleted`, then listen to
  `completionChanges`; do not keep a one-time completion read as the routing
  authority.
- On a `false` notification, close pushed settings/developer/dialog routes that
  cover the root, switch the root to onboarding, and recreate its flow at page
  zero (for example with a reset-generation key). A reset while already incomplete
  must still restart the flow. Keep navigation in the host; the neutral kit must
  not choose an app route or own product content.
- The kit emits only after a successful persistence operation. A failed reset
  leaves the current completion and route intact; show the operation's failure.
  Completion emits `true` after saving. Let `OnboardingFlow.onFinished` finish
  all configured actions before replacing a visible flow with the app shell; a
  completion notification must not prematurely cancel later finish actions.
  Dispose the root subscription without disposing a borrowed runtime controller.
- Persist a current `false` when resetting. Do not remove the current completion
  key when a migration adapter can read a legacy `true`, or the next launch can
  silently restore completion. Preserve unrelated preferences and independent
  feature tutorial progress.
- Check reset from a nested Kit Lab page, reset while already incomplete, failed
  persistence, completion after replay, and reopening a store with a legacy
  completion. Follow the repository's opt-in rules for tests and device runs.

## Default look: one illustration per page

Unless the owner asks for something else, every onboarding page is one
illustration, the page dots, a short title, one line of copy and a full-width
button. Story Saver (`lib/features/onboarding/presentation/screens/onboarding_screen.dart`)
is the reference implementation.

### The illustrations

An illustration is a finished picture: a flat vector scene, usually with a
person doing the thing the page describes, plus a few objects that name the
feature (documents, photos, a phone, a cloud, a piggy bank). It is not a
composition of Material icons, glyphs in circles or shapes drawn with widgets.
The owner rejected exactly that on PDF Reader (Nov 2026): a page built from
icon tiles and painted cards looked cheap next to apps that use real artwork.

Story Saver's three pages show the target. Each is a square scene with a
transparent background: a person working at a laptop with files flowing down
from a cloud, a gallery scene, and a person feeding clocks into a piggy bank for
premium. Each has dark grey outlines, the app's green as the only accent colour,
a pale green blob behind the scene, and small props such as plants and lamps.
All three come from one set, so they share line weight, palette and proportions.

Get the artwork in this order:

1. **Look online first.** Search free illustration libraries whose style can be
   recoloured to the app's accent, such as Storyset, unDraw, DrawKit, Blush,
   ManyPixels and Open Peeps. Pick one style family and take every page from
   it; never mix sets. Read the licence before choosing. Some require
   attribution (Storyset's free tier does), and some forbid redistribution in
   an app. Record the source URL and licence in the app's `docs/`. Show the
   owner the candidates (links or previews) and get their go-ahead before you
   download anything.
2. **Otherwise, generate them.** Use an image-generation tool when the session
   has one. Ask for the same scene style, one subject per page, a transparent or
   plain background, and the app's accent colour. Without such a tool, write SVG
   for each scene and rasterise it, for example with `@resvg/resvg-js` and the
   app's own font. PDF Reader's three onboarding images were made this way.
   Keep the generator script and SVG sources in the app (for example
   `tool/onboarding_art/`), not only in a temporary folder, so the art can be
   revised later.

Whichever route you take:

- Recolour to the app's accent and match the app's theme. On a dark theme,
  check every outline and light fill against the background. In PDF Reader, a
  person's dark shoes vanished on the near-black page until they were made white.
- Make the images square or nearly square, with a transparent background, about
  1200–2000 px wide. Ship them as WebP or PNG under `assets/onboarding/` (Story
  Saver uses `assets/images/onboarding_N.webp` at about 100–150 KB each). Keep
  the full-size originals, as Story Saver does in `assets/images/originals/`.
- Register the folder in `pubspec.yaml`. Precache every page image in
  `didChangeDependencies` so a swipe never shows an empty page.
- Show the owner the finished set as images before wiring it in, and look at
  each one at phone size yourself.

### The page layout

Top to bottom, as Story Saver and the reference apps lay it out:

- **Skip** in grey text, about 16 pt, semi-bold. Put it at the top right, as
  PDF Reader does, or in one bottom row with the dots and Next
  (`OnboardingControlsLayout.row`), as Story Saver does without ads. Hide it on
  the last page.
- **The illustration**, filling the space left over with `BoxFit.contain`, with
  about 20 px side padding.
- **Page dots.** The current page is a wider pill in the accent colour. The
  others are small dots in a faint neutral colour (`Colors.black12` on light,
  a muted grey on dark).
- **Title.** Two to five words, bold, about 21–26 pt, centred.
- **Copy.** One sentence of about 6–15 words, grey, about 16 pt, line height
  1.4–1.5, centred.
- **Button.** Full width, about 56–60 px high, radius 12–15, filled with the
  accent colour, bold white label: "Next", and "Get Started" on the last page.
  Leave 24–50 px below it.

Story Saver's background is white, the title is black87 at 26 pt bold, the copy
is grey at 16 pt, and the button is 60 px high with a radius of 15. Copy the
structure and adapt the colours, using the app's theme and its logo colour for
the accent.

Write the pages around what the app does: page one welcomes the user and states
the main value, the middle pages show one key feature each, and the last page
can introduce premium when finishing opens the paywall. Three pages is the
default.

When native ads are on (see the ad rules above), Story Saver switches to
`OnboardingScreenLayout.edgeToEdge`. The illustration then sits on a soft
vertical accent-tint gradient (`0xFFD7F0DE` → `0xFFF3FAF5`) that runs under the
status bar and fades into the page (`artworkFadeHeight: 40`). Pages 1 and 3 hold
an ad, and page 2 is full screen.

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

## Hands-on feature tutorials

For instructions over the real app, use `TutorialController` and
`TutorialOverlay` from the same package. Follow the
[tutorials skill](../tutorials/SKILL.md) for targets, touch policies, app events,
independent saved progress, migration, skip and replay. Keep these named guides
separate from introductory `OnboardingController` completion. Apps supply
instructions, targets and actions; shared tutorial mechanics belong in the kit.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_onboarding](../../../../../packages/genrevibes_starter_kit/modules/onboarding/genrevibes_onboarding/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/onboarding/genrevibes_onboarding/lib/genrevibes_onboarding.dart).
