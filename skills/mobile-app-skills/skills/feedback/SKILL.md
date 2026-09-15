---
name: feedback
description: "Reuse the kit feedback and contact forms with a selected delivery provider."
---

# Feedback and contact forms

Use `openFeedbackPage` from `genrevibes_feedback_ui` with the existing
`FeedbackProvider`. FeedbackNest is an adapter choice, not a form implementation
for each app to copy.

- Use `FeedbackKind.contact` for required email; feedback permits optional email.
- Supply `FeedbackPageTheme` and labels from the app's design/localization.
  `SettingsPageStyle` is a Story Saver class, not a kit API.
- Supply a screenshot picker only when wanted. The host supplies attachment
  bytes; the neutral UI has no image-picker dependency.
- Configure count and size limits. The default per-attachment limit is 10 MB;
  the FeedbackNest adapter also caps each attachment at 10 MB.
- Keep the default bounded submission or configure `submissionTimeout`.
  Timeout releases busy state and keeps input/attachments. Delivery is unconfirmed,
  so retry can duplicate a message already received by the server.
- FeedbackNest rejects nonempty metadata with its current SDK. Do not suggest
  adding metadata unless the selected provider supports it.
- If using PostHog, wrap the complete route through `protectContent` with
  `PostHogMaskWidget`. Never track email, message text, or attachment content.

The page scrolls and handles keyboard space. Do not wrap it in a second layer
of keyboard-inset padding. Reuse its validation, busy state, and success/error UI.
See the [composition recipe](../../../../../packages/genrevibes_starter_kit/docs/portfolio-adoption.md).

Check contact validation, repeated taps, picker cancellation, attachment limits,
timeout, retry, and keyboard layout. These are feedback/contact forms; the kit
has no general form designer.

## Reuse the complete form

The [analyzer-checked integration example](../../references/examples/integrations/shared_features.dart)
contains `openContact`, including labels left at their defaults, contact mode,
attachment limits, timeout, and optional PostHog protection. Use its imports only
for capabilities installed in the target app. An app without PostHog should not
add that dependency merely to open a form.

Construct and initialize the selected delivery provider in the runtime. Register
it once, then have the settings/contact action call `openFeedbackPage` with that
instance. The shared page owns field validation, submission busy state, error
presentation, and preserving the draft during failure. The app owns its entry
point, theme, translations, picker, and post-success action.

### Add screenshot selection

Supply a picker callback using the signature exported by the UI package. It
must return the selected bytes/attachment information or the package's expected
cancellation result. Handle picker failures without discarding typed form input.
Select limits that the delivery adapter accepts; allowing a larger file in UI
does not increase a server limit. Do not add gallery permissions when the chosen
platform picker does not need them.

### Submission outcomes

| Outcome | App behavior |
|---|---|
| Confirmed success | Allow the shared success flow; run any supplied success action once. |
| Validation failure | Keep input visible and let the user correct it. |
| Delivery error | Keep the draft and show a useful retry message. |
| Timeout | Release busy state; delivery is unknown and a retry may duplicate it. |
| User leaves the route | Do not use its disposed context from a late callback. |

A contact form and a general business form have different responsibilities.
Reuse this page for feedback/contact. For a booking or account form, keep the
feature's fields and use cases in the app and reuse applicable UI components;
do not pretend the kit supplies a universal form builder.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_feedback](../../../../../packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedback/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedback/lib/genrevibes_feedback.dart).
- [genrevibes_feedback_ui](../../../../../packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedback_ui/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedback_ui/lib/genrevibes_feedback_ui.dart).
- [genrevibes_feedbacknest](../../../../../packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedbacknest/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/feedback/genrevibes_feedbacknest/lib/genrevibes_feedbacknest.dart).
