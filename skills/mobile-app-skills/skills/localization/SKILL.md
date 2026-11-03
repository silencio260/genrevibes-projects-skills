---
name: localization
description: "Plan and implement portfolio app localization, language and country selection, regional/script variants, app-owned translations, shared kit behavior, and localized store assets."
---

# Localization

Use the app's existing localization system. A static string class alone does
not provide locale switching, plural rules, or translated formatting.

For portfolio planning or expansion, read the
[40-language / 58-locale catalogue](references/portfolio-locales.md) and
[implementation and translation plan](references/portfolio-rollout.md).
These record the user's portfolio target, exact variants, independent country
selection, source-reviewed Lunaris migration and staged delivery. They supersede
the earlier smaller language-count recommendations. For a narrow string fix,
keep the scope narrow and preserve useful existing translations.

## Portfolio ownership and readiness

- Reusable locale matching, preference state/persistence, device-following,
  region selection and picker structure belong in the starter kit. The shared
  package availability depends on the app's installed kit revision. Inspect the
  current inventory and API before importing or implementing it; a dated rollout
  plan is not evidence that an implementation is present or absent today.
- Each host app supplies its strings, generated delegates, language/locale
  options, country names/options, default/fallback policy, labels, fonts,
  backend/profile adapter and store copy/assets. Do not embed Lunaris's product
  strings or the portfolio's fixed language list inside the kit.
- The full target is 40 languages and 58 initial locale options. Track drafts,
  script/delegate/formatting gaps and review status; expose only ready options.
  Roll out in batches without silently dropping unfinished target languages.
- Language and Country/region are independent settings. Preserve full BCP 47
  tags, explicit device/manual modes and script identity; never force a user's
  language from their country or collapse all variants to `languageCode`.
- Regional variants can share reviewed same-language/same-script text. Verify
  regional wording and formatting; preserve distinct Chinese and Punjabi scripts.
  Country choices can extend beyond the catalogue without another translation.
- App locales and Google Play listing languages are different catalogues. Map
  them explicitly and record unsupported store slots; do not invent country
  locale codes in Play or claim a language count guarantees maximum downloads.

## Use the current translation resources

- Add user-facing text to the current translation resources. If the app uses
  Flutter ARB files, preserve placeholder metadata and plural/select messages.
- Pass localized labels into kit UI instead of editing shared English defaults
  for one app. Keep backend IDs and analytics names unchanged.
- Preserve language selection and fallback behavior. Use locale-aware dates,
  numbers, and prices; keep store-supplied prices intact.
- Before expanding locale options, inspect saved values, backend allowlists,
  profile defaults and native/framework locale data. Migrate existing choices
  compatibly; adding an ARB does not make backend writes or pickers accept it.
- Check longer translations, right-to-left layout where supported, and text scaling.
- Server-written text: give system messages a `kind` + `params` and word them
  from app strings; give admin-written content an optional per-language
  `i18n.{language}.{title, body}` map resolved at build time (full tag, then
  language-script, then language). Keep the English fields for older app
  versions. Lunaris: `inbox_text.dart`, `core/l10n/localized_copy.dart`.
- Plurals: write counted nouns as ICU plurals and draft ru/uk/pl/ar with all
  their CLDR categories; `=1/other` alone is wrong for them. Give count
  placeholders `"format": "decimalPattern"`.
- List the app's locales for the OS language settings: Android
  `res/xml/locales_config.xml` + `android:localeConfig`, iOS
  `CFBundleLocalizations`. They ship with a store build, not a code patch.
- Never bundle script fonts. Use device fonts, and download only a script the
  device can't draw, for the active locale, at runtime. The device font renders
  until the download lands. Follow [script fonts](references/script-fonts.md).
- Use the current app folder layout; do not create a separate `lib/src` tree
  for localization or force a BLoC just to store a locale.

Report which labels remain untranslated. Do not claim a feature is localized
because its English strings moved into constants.

Use the plan's translation workflow: source inventory/glossary, draft production,
ICU/placeholder checks, real linguistic review, in-app visual checks, then locale
exposure. Mark machine/AI drafts honestly. Source changes invalidate affected
translations; do not overwrite reviewed text or fabricate reviewer approval.

For an editorial pass, record the exact reviewed keys per resource, changed
keys, source/text digests, reviewer method and validation performed. Separate a
scoped AI review from full-corpus review, human fluent-speaker approval and device
checks. Check that record before regenerating any existing messages. In Lunaris,
use `lib/l10n/translation_status.json`, the dated `editorial_review_*.json`
manifests and the linked report in `docs/`; unlisted keys retain their previous
review status. Check ambiguous source words in context (mine, rate, ref, streak,
pending, and No), and preserve remaining-versus-total counts in every ICU branch.
For account forms, describe the characters the validator actually accepts;
"letters" alone can imply unsupported scripts. Check the local and server
validators together, and let translated errors wrap instead of clipping them.
For feature availability and resource-use claims, compare the source copy with
the current caller/backend behavior before reproducing the claim in translations.

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

Reconcile app-owned scheduled notifications and other cached localized content
when the effective language changes. Keep ownership, schedule times and IDs;
avoid duplicate notifications. Translate remote content through an explicit
app/backend schema rather than assuming ARBs translate server-authored text.

For store descriptions, screenshots and feature graphics, follow
[app promotions](../app-promotions/SKILL.md). Translate the screen content and
headline, use only supported listing mappings, keep final screenshots beside
their feature graphic, and keep the entire screenshot output folder Git-ignored.
Planning/source documents belong in source/docs, not image delivery folders.
Read the complete [portfolio Play Store localization workflow](../app-promotions/references/play-store-localization.md)
before expanding a store campaign. It defines the user's
`app_screenshots/<style-or-campaign>/<country_language-or-variant>/` convention,
shared-art/editable-text generation, listing JSON, parallel workers and final
checks. Inherited translations need contextual review;
button fit does not prove centering, and catalog coverage does not prove fluent
wording or ASO performance. Keep listing-copy approval separate from screenshot
review and record the actual app-to-store locale mapping.

Report implemented behavior, locale readiness, remaining review/framework work,
and actual validation separately. A plan does not establish that translations
or shared kit APIs have shipped. Tests, builds, publication and deployment keep
their existing repository authorization rules.
