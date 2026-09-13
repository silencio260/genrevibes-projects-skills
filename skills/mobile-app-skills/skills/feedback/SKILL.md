---
name: feedback
description: User feedback and contact requests in GenRevibes apps — the starter kit's feedback page, sent through FeedbackNest. Read before adding or changing a feedback, bug or contact form.
---

# Feedback

## Overview

| Package | Role |
|---|---|
| `genrevibes_feedback` | `FeedbackProvider` contract, `FeedbackSubmission`, `FeedbackAttachment`, `FeedbackKind` (`feedback`, `contact`) |
| `genrevibes_feedbacknest` | FeedbackNest adapter, registered as a kit module in bootstrap |
| `genrevibes_feedback_ui` | `openFeedbackPage` / `FeedbackPage`: a full page with email, message, optional screenshots, validation, sending, success and failure |

Don't use `flutter_feedback_dialog`. Its dialog applies the keyboard's height
twice and cannot scroll, so the fields overflow and paint outside the card with
the keyboard open, and it is no longer maintained.

## Implementation

```dart
Future<bool> showContactUs(BuildContext context) => openFeedbackPage(
  context,
  provider: sl<FeedbackProvider>(),
  kind: FeedbackKind.contact,            // requires an email; feedback makes it optional
  theme: SettingsPageStyle.feedback,     // the Settings screen's colors
  pickScreenshot: pickScreenshot,        // omit to hide screenshots
  onSubmitted: (submission, result) => analytics.track('feedback_submitted', {
    'kind': submission.kind.name,
    'success': result.isSuccess,
    'attachments': submission.attachments.length,
  }),
);

Future<FeedbackAttachment?> pickScreenshot() async {
  final image = await ImagePicker().pickImage(
    source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
  if (image == null) return null;
  return FeedbackAttachment(
    filename: image.name,
    bytes: await image.readAsBytes(),
    mimeType: image.mimeType ?? 'image/jpeg',
  );
}
```

- **A page, never a sheet or dialog.** It opens like the app's other settings
  pages: app bar, back arrow, the same background, fields and buttons.
- **Appearance.** Pass the Settings screen's colors through
  `FeedbackPageTheme`. Keep them in one app-side style shared with the developer
  passcode page (`DeveloperPasscodeTheme`) — Story Saver's is
  `SettingsPageStyle` — so the pages cannot drift apart. Colors left null come
  from `ThemeData`.
- **Screenshots** come from the app, so the kit takes no image picker
  dependency. `image_picker` uses Android's photo picker, which needs no storage
  permission.
- **Wording** defaults per kind (`FeedbackPageLabels.forKind`); pass `labels`
  to localize or change it. Copy follows sentence case, with no "successfully".
- **Keyboard.** The page's scaffold makes room for the keyboard and the form
  scrolls. Never add `viewInsets` padding around it.
- **Sending** shows progress and Back waits until it ends; a failure keeps the
  user's text and shows the error; success shows a confirmation. The function
  returns whether it sent.
- **Metadata** such as app version can go in `metadata`; never personal data.

## Interaction Map

- **Settings**: Contact us opens the page with `FeedbackKind.contact`; Send
  feedback with `FeedbackKind.feedback`.
- **Rating**: a low rating routes to the feedback page
  (`genrevibes_app_rating` decides, the app shows it).
- **Analytics**: track attempts from `onSubmitted`.

## Checklist

- [ ] `FeedbackProvider` (FeedbackNest) registered in bootstrap; API key in env
- [ ] Contact and feedback open `openFeedbackPage` with the right `FeedbackKind`
- [ ] `theme` set from the app's shared settings style; the page looks like Settings
- [ ] Screenshot picker supplied (or deliberately omitted)
- [ ] No `flutter_feedback_dialog` dependency
- [ ] Verified with the keyboard open on a small phone: nothing overflows, the send button is reachable
