---
name: localization
description: "Localize app and shared kit labels using the app existing translation system."
---

# Localization

Use the app's existing localization system. A static string class alone does
not provide locale switching, plural rules, or translated formatting.

- Add user-facing text to the current translation resources. If the app uses
  Flutter ARB files, preserve placeholder metadata and plural/select messages.
- Pass localized labels into kit UI instead of editing shared English defaults
  for one app. Keep backend IDs and analytics names unchanged.
- Preserve language selection and fallback behavior. Use locale-aware dates,
  numbers, and prices; keep store-supplied prices intact.
- Check longer translations, right-to-left layout where supported, and text scaling.
- Use the current app folder layout; do not create a separate `lib/src` tree
  for localization or force a BLoC just to store a locale.

Report which labels remain untranslated. Do not claim a feature is localized
because its English strings moved into constants.

## Wire translations to the component's label API

Find the current translation resources and generation configuration. Add a key
for each new user-facing label, error, accessibility description, and action.
Use placeholder/plural metadata for dynamic text instead of joining English
fragments in Dart. Keep the existing fallback locale and supported locale list.

At the screen boundary, construct the kit's label configuration from the current
localization object and pass it to the shared component. Rebuild that mapping
when locale changes. Do not keep a singleton of translated labels captured at
startup if the app allows changing language while running.

Keep stable identifiers outside translation resources: product IDs, remote keys,
route names, event names, and database fields must not change with the locale.
Use store-provided localized purchase prices rather than formatting an assumed
currency from a raw product amount.

For a changed flow, list the resources updated and any fallback English text
that remains. Inspect long text and right-to-left behavior where the app supports
it, including icons whose direction has meaning. Translation generation commands
should follow the app's existing setup; do not introduce another localization
package merely for one kit screen.
