---
name: theming
description: "Apply the app theme to shared kit UI without copying another app brand."
---

# Theming

Use the app's existing ThemeData, ColorScheme, typography, and theme extensions.
Keep repeated design values together; do not add a second set of hardcoded colors
for kit pages.

- Pass app theme/labels through the kit component's supported configuration.
- Keep feedback and developer-passcode pages visually consistent with Settings.
  A shared app style is useful; Story Saver's class name is not a kit requirement.
- Follow current light/dark/system mode behavior and persist explicit user choice
  only when the app offers it.
- Check disabled, loading, error, and selected states, including readable text
  contrast and larger text sizes.
- Keep app-specific artwork/colors out of neutral kit packages.

Do not introduce dark mode, fonts, or a new design system just to use one kit
widget. Check both existing themes and the changed widget's small-screen layout.

## Map the app theme into shared components

Find the app's current theme builder, typography, spacing, and any theme
extensions before adding a kit page. Read the selected component's theme/config
fields and map those app values there. Keep this mapping in a small app-owned
style helper when several entry points share it.

A shared feedback or developer page should use the same surfaces, text hierarchy,
button treatment, and error colors as its surrounding settings screen. Do not
copy an entire kit widget into the app to change a color the API already exposes.
If a genuinely reusable styling option is missing, extend the shared API with
a sensible default and preserve existing callers.

For a persisted theme choice, store the user's selection separately from the
resolved platform brightness. “System” must remain system mode after a restart,
not become whichever brightness happened to be active when it was saved.
Follow the preference ownership pattern in the worked feature.

Inspect complete states: normal, disabled, busy, error, focused, and selected.
Check text scaling and both themes the app actually supports. A screenshot of
one light-mode idle screen does not establish that the component works in dark
mode or with a visible validation error.
