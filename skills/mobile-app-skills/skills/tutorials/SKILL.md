---
name: tutorials
description: "Build reusable in-app tutorials, feature walkthroughs, coach marks and spotlight guides with the starter kit; keep product instructions and actions in the app."
---

# In-app tutorials

Use the public tutorial API in `genrevibes_onboarding`. It is reusable for any
app feature, independently of the app's introductory onboarding. Do not copy a
spotlight painter, touch barrier, tutorial controller or progress store into
an app when the shared implementation covers the behavior.

Read the [package guide and API example](../../../../../packages/genrevibes_starter_kit/modules/onboarding/genrevibes_onboarding/README.md#in-app-tutorials)
when implementing a tutorial. The [complete two-tutorial example](../../../../../packages/genrevibes_starter_kit/modules/onboarding/genrevibes_onboarding/example/tutorial_example.dart)
shows an editor guide and a search guide with separate progress, real actions,
route-return advancement, replay and translated-label injection points.
For introduction pages, use the existing [onboarding skill](../onboarding/SKILL.md).

## Ownership and setup

- The kit owns `TutorialController`, `TutorialProgress`,
  `TutorialProgressStore`, `KeyValueTutorialProgressStore`, `TutorialStep`,
  `TutorialTarget`, `TutorialLabels` and `TutorialOverlay`.
- The app owns tutorial IDs, step IDs, order, text/translations, target keys,
  launch timing, gestures, navigation, successful-action events and which
  tutorial can be visible on a surface. A tutorial is optional product guidance,
  not another required portfolio startup integration.
- Keep onboarding completion separate. `OnboardingController.isCompleted`
  says the introduction finished; `TutorialController.isCompleted` belongs
  to one named guide. Neither retention counts nor another app boolean should
  substitute for the tutorial's saved completion.
- Construct one controller for each tutorial ID in the runtime or owning screen.
  Reuse that exact instance for UI, replay and prompt suppression. The controller
  is a `ChangeNotifier`, not a `StarterModule`; call `initialize()` yourself and
  dispose it only in the scope that created it. A screen borrowing a runtime
  controller removes its listeners and may call `stop()` when leaving; it must
  not dispose that shared controller.

Use `KeyValueTutorialProgressStore(store: existingKitKeyValueStore)` for saved
state. It does not import SharedPreferences or any vendor adapter. Multiple
controllers can share this store because each tutorial ID has a separate key.
Use `MemoryTutorialProgressStore` for previews so replaying a developer example
cannot overwrite real completion. Scope each controller/ID to one owner;
separate controller instances writing the same ID are not coordinated.

Choose stable, nonempty `tutorialId` and unique `stepIds` before writing screens.
Saved steps use IDs, not indexes. Reordering preserves the current instruction;
removing an unfinished current step resumes at the new first step. Completed
and skipped tutorials remain completed when their step list changes. To
intentionally introduce a new guide, use a new tutorial ID; replay is an explicit
user action, not a side effect of rebuilding translated content.

## Initialization, resume and replay

1. Await `controller.initialize()` and inspect its `KitResult`. A failed read
   leaves it uninitialized. Show localized recovery UI and retry; do not present
   unreadable completion as successfully loaded state.
2. At the app's chosen moment, await `start()`. It resumes the saved step and
   keeps completed/skipped guides inactive. No overlay appears from initialize
   alone. A failed start write leaves it inactive and can be retried.
3. Listen to the controller for step/busy/error changes. Place `TutorialOverlay`
   last in a bounded `Stack` above the relevant content. Its `steps` must have
   exactly the controller's IDs in the same order. Rebuild text from the active
   localization object; do not capture translations in a runtime singleton.
4. `next()`, `previous()` and `goTo(id)` save before updating the visible step.
   `complete()` and `skip()` also save before ending the active session. Failures
   leave the old step/outcome available for retry. UI controls are disabled while
   saving or awaiting a card action; direct callers must inspect returned results.
5. Use `reset()` to save a fresh first step without starting UI, or `replay()` to
   reset and activate. Both can explicitly recover an unreadable snapshot without
   first initializing it. They affect only this tutorial. `stop()` leaves its
   saved checkpoint unfinished; `start()` resumes it later.

The controller prevents overlapping writes. Repeated `advanceFrom(id)` events
while busy or on another step are ignored. If an app event must eventually
advance a step (for example a pager arrival during a save), reconcile the current
app state when the controller is no longer busy. Do not advance from build().

## Targets, interactions and real actions

Attach a `GlobalKey` to each visible target, then use
`TutorialTarget.key(key)`. Custom `TutorialTarget.resolver` callbacks return bounds
in the overlay's local coordinates. Targets update after layout and during
existing scroll/animation frames; no fixed-delay geometry timer is needed.
An absent, detached or offscreen target has no spotlight hole. The card and its
escape controls remain available. The app should navigate/scroll to a required
target or supply a recovery instruction with the same step ID.

Choose each step's touch policy deliberately:

| `TutorialInteraction` | Effect behind the card |
|---|---|
| `blocked` | All background touches blocked; a resolved target can still be highlighted. |
| `targetOnly` | Only the highlighted target receives touches. |
| `anywhere` | Background stays interactive, suitable for swiping, typing or trying a canvas. |

With no `onPrimary`, the primary card control uses Next, or Finish on the last
step. With a custom `onPrimary`, the app owns advancement. Open the real feature,
wait for a meaningful result or route return, then call
`advanceFrom(expectedStepId)`. Both tapping a spotlighted target and tapping the
card action should use the same app operation. Do not treat the card tap itself
as proof that a permission, export or external launch succeeded. `showNext` adds
an optional Next action alongside a custom action for users who prefer to move on.

The kit never requests permissions, opens native dialogs, launches apps, or
chooses routes itself. Keep these with existing app services. Do not time out an
interactive native flow and advance behind a still-visible dialog. Use `enabled:
false` or `pause()` while another surface owns interaction; `pause()` hides UI
while `active.value` stays true. Call `resume()` when appropriate.

`onFinish`/`onSkip` override the shared default completion. If supplied, the host
must perform its required navigation/work and then call `complete()` or `skip()`
explicitly. This allows a guide to finish on the correct app page. A callback
returning alone does not mark completion. Give `onError` localized action-error
handling, and/or observe `controller.lastError` for storage errors; do not show
raw diagnostic `KitError.message` as product copy.

Use `TutorialCardPlacement` for top/bottom/center positioning; automatic placement
chooses the opposite half from a target. Card content scrolls inside safe bounds,
accounts for the keyboard and uses wrapping controls. `cardBuilder` customizes
content while retaining shared geometry, controls and touch behavior.
`decorationBuilder` supplies noninteractive, decorative hints. Respect reduced
motion in app-supplied animation and keep instructional text outside images.

## Migration and competing prompts

Adopt actual historical keys through the store's per-ID `TutorialLegacyKeys`
map. Supply `completedKey`, optional `stepKey`, and `firstStepId`. Migration
writes one snapshot before reporting success. Existing completed users do not
replay the guide. New snapshots take precedence over legacy keys, which remain
for rollback. Reset writes an unfinished snapshot instead of deleting it, so
legacy completion cannot be adopted again after a user asks to replay.

The shared controller exposes `active` as `ValueListenable<bool>`. Apps connect
it to their own ads, rating, notification explanations and other competing UI.
The kit does not add SDK dependencies or assume every app wants the launcher's
suppression policy. Pause retains an active session; stop, completion and skip
release it. When several tutorials exist, the host chooses one visible guide and
stops/pauses the previous one without erasing its checkpoint.

Check stable-ID migration, unknown steps, failed reads/writes, duplicate taps,
late route returns, Back/skip/replay, disposal during an action, missing targets,
keyboard/small-screen/large-text/RTL layouts and reduced motion. Follow the
repository's opt-in rules for tests, builds and device runs. Distinguish static
checks from verified live UI behavior.
