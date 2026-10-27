# Portfolio localization plan

Target: **40 languages and 58 language/region/script options**, listed in the
[locale catalogue](portfolio-locales.md). Start with Lunaris, then use the same
shared implementation across the portfolio. This document plans the work;
implementation and translation are still pending.

The starter kit provides language and region selection, saved preferences and
locale matching. Each app provides its translations, supported options, labels,
fonts, backend integration and store materials.

## Observed Lunaris and kit baseline

Inspected on 25 October 2026. App paths below are relative to
`lunaris_network_app/`; backend paths are relative to the host repository root.
Recheck these findings before implementation.

| Area | Current state and required change |
|---|---|
| Strings | `lib/l10n/app_en.arb` has 518 message keys. The six other ARBs have matching keys; their wording still needs review. Keep Flutter `gen-l10n` and `l10n.yaml`. |
| Locale state | `lib/core/l10n/l10n.dart` owns `LocaleController`, the seven-language list, `appStrings`, and the local key `lunaris.locale.picked_language`. Move reusable behavior to the kit; keep resources and options in the app. |
| Startup | `lib/my_app.dart`, `lib/main.dart`, and `lib/bootstrap/app_bootstrap.dart` need the same controller and compatible delegates, including recovery screens. |
| Settings | `lib/features/settings/presentation/dialogs/language_dialog.dart` shows seven languages. `settings_screen.dart` saves remotely before changing language locally. Add searchable language/variant and separate country settings with offline saving. |
| Profile | Update `UserPrefs` in `lib/features/mining/domain/entities/lunaris_user.dart`, its mapper, repository and preference-saving flow together. Preserve existing saved choices. |
| Backend | `backend/firestore.rules:validPrefs` accepts only seven language codes and three preference fields. `backend/functions/src/services/user-service.ts` defaults new profiles to English. Expand acceptance compatibly before clients send new fields/tags. |
| Formatting | `lib/core/utils/formatters.dart` uses the translated message locale. Add independent regional formatting while preserving LUN precision and identifiers. |
| Notifications | `lib/features/notifications/lunaris_notifications.dart` stores text when scheduled and does not include locale in its schedule key. Refresh pending text when the effective language changes. |
| Fonts | `lib/core/utils/styles_manager.dart` and `lib/config/theme_manager.dart` use Geist/Geist Mono. Script fallbacks come from device fonts, plus an on-demand download for a missing script (`lib/core/l10n/locale_fonts.dart`); none are bundled. See [script fonts](script-fonts.md). |
| Kit | At commit `49b110cf454106087af9aa4d24b1d023d884f355`, shared storage and settings components exist; a modular localization controller/picker package does not. |

The inspected Flutter delegates and `intl` 0.20.2 lack Oromo and Xhosa support.
Resolve their widget translations and date/number data before enabling them.
Check Arabic-script Punjabi separately: support for `pa` alone does not prove
support for its script or direction.

## Ownership and proposed shared contract

Create `modules/localization/genrevibes_localization` using the kit's existing
package conventions. Reuse `KeyValueStore`, `KitResult` and settings components.
Keep the dependency graph small and use the app's existing state management.

| Starter kit | Current app |
|---|---|
| Parse full locale tags and match compatible fallbacks | Translation files, generated delegates, enabled language/variant list |
| Manage device/manual choices and local persistence | App default, old-value mappings, profile adapter and backend fields |
| Provide searchable language/variant and country pickers | Native names, translated labels, country options, theme and routes |
| Resolve translation locale, formatting locale and direction | Fonts, product-specific formatters and translated kit-component labels |
| Notify consumers when preferences change | Refresh notifications, remote content and analytics |

The shared configuration needs an app-provided locale catalogue, country list,
default, same-script fallback mappings and storage namespace. Each locale option
needs its full tag, display names, direction and readiness. Shared state needs
selected modes/values, effective translation and formatting locales, fallback
reason and persistence status.

Keep product strings, the fixed 40-language list, Firebase and app-generated
`AppLocalizations` out of the kit. Build translated kit labels from the current
app's localization object whenever language changes. Custom framework delegates
may be shared; app product translations remain app-owned.

## Selection, resolution, and persistence

Provide separate **Language** and **Country/region** settings. Both support a
device/default option and a manual choice. Country selection never restricts
available languages. Country options come from the app and can cover more
countries than the translation catalogue.

Apply these rules:

1. A manual local choice stays selected until reset, including after device or
   profile changes. Persist device-following mode explicitly so profile sync
   cannot undo a user's reset.
2. An explicit profile choice can initialize a device with no local choice.
   A legacy profile default of `en` is not evidence of a manual English choice.
3. Match the exact locale, then configured same-language/same-script parents,
   then the app default. Preserve Chinese and Punjabi script distinctions.
4. Resolve regional formatting separately, using available data and an explicit
   fallback. Country selection does not change timezone or store-provided prices.
5. Save full tags such as `pt-BR` or `pa-Arab-PK`, modes, region and schema version
   under an app-specific key. Validate ISO country codes separately from locale
   regions such as `419`. Construct Flutter locales from their subtags.
6. Save locally before confirming success, then sync the app profile. A local
   write failure retains the previous confirmed choice; a remote failure leaves
   the local choice intact with pending/retry status. Older save responses must
   not overwrite newer selections.

Migrate the old local key and seven profile codes without guessing which regional
translation existing copy represents. Keep old clients/profile values readable.
Define account-switch behavior so pending profile updates stay with their owner.
Observe device locale changes through an owned lifecycle listener and dispose it.

Update profile models, serializers, preference use cases, creation defaults and
Firestore rules together. Accept released locale tags and legacy values, validate
new field shapes, and preserve owner-only preference writes. Backend acceptance
must be deployed before the client starts writing the new schema.

## Implementation sequence

| Step | Work | Done when |
|---|---|---|
| 1. Prepare | Confirm source strings, glossary, locale list, profile migration and store mapping. | Existing choices and required data changes are understood. |
| 2. Build the kit feature | Implement shared state, resolution, storage and selection UI. Update exports, adoption docs and the smoke example. | The app can supply all content and options through the public API. |
| 3. Integrate Lunaris | Migrate its existing seven languages, settings, profile saving, formatting and notifications. | Current translations and saved preferences still work, including offline and device-following modes. |
| 4. Prove script support | Check regional English/Portuguese, Arabic, Traditional Chinese, Arabic-script Punjabi, an Indic language, Oromo and Xhosa. | Delegates, fonts, direction, plurals and formatting work for the affected scripts. |
| 5. Translate | Produce and review the batches below, including regional differences. | Each enabled option has reviewed text and working UI. |
| 6. Localize the store | Prepare supported listing translations and one screenshot campaign. | Store codes, copy and images match the intended audience. |
| 7. Release and adopt | Release ready batches, measure results, then integrate other apps. | Each app uses the shared behavior with its own translations and options. |

Source preparation can run alongside kit development. Resolve script and framework
gaps early. Estimate cost and schedule after source word counts and a representative
translation/review pilot; 518 message keys alone do not provide that estimate.

## Translation production and review

| Batch | Languages | Work |
|---|---|---|
| A | English, Spanish, Portuguese, French, German, Italian, Dutch | Review existing translations and add the catalogue's regional differences. |
| B | Indonesian, Hindi, Arabic, Vietnamese, Turkish, Bengali, Urdu, Russian, Thai, Filipino, Japanese, Korean, Chinese | Add 13 languages and their required script/region variants. |
| C | Afrikaans, Amharic, Danish, Gujarati, Icelandic, Kannada, Kazakh, Malay, Malayalam, Marathi, Oromo, Polish, Punjabi, Swahili, Tamil, Telugu, Ukrainian, Uzbek, Xhosa, Zulu | Add the remaining 20 languages and variants. |

Within each batch, use audience data, reviewer availability and script readiness
to decide the order. All 40 languages remain in scope.

For each language or regional override:

1. Supply screen context, terminology, placeholders, plural rules and space limits.
2. Generate a translation draft. Preserve keys, placeholder types, ICU syntax,
   brand names, URLs and technical identifiers.
3. Review meaning, especially account access/deletion, rewards, purchases,
   notifications and permissions. Record the actual reviewer and method.
4. Inspect real screens for wording, clipping, fonts, direction, text scaling,
   accessibility, dates and numbers.
5. Enable the option after review. Record the source revision and recheck affected
   translations when source text changes.

Regional options may inherit reviewed text from a compatible language/script
base. Verify the generator's fallback behavior; use app-owned merged or complete
ARBs where necessary. Chinese and Punjabi scripts need separate treatment.
Reuse approved unchanged translations rather than regenerating them each release.

Track each option as planned, draft, reviewed, visually checked or enabled.
Track store assets and publication separately. Machine/AI output is a draft;
structural checks are not fluent-speaker approval. Keep translation status and
source files outside image delivery folders.

## Store listings and visual assets

Map app locales to actual Play Console listing languages using the
[catalogue's store mapping](portfolio-locales.md#google-play-mapping). App locale
options do not imply an equal number of Play listing slots. The published list
checked on 25 October 2026 omits Oromo, Uzbek, Xhosa and Zulu; verify the live
Console and record a supported fallback where direct listings are unavailable.
Use country-targeted custom listings when regional marketing needs different
copy or images. The app's country setting does not control its Play listing.

For each supported listing, translate the title, short/full descriptions,
screenshot headlines and visible app UI. Review local search wording and current
Console limits. Use one chosen visual campaign and reuse identical approved
assets across compatible variants. Text-free graphics and the app icon may be
shared. Verify any automatic Play translation service supports the Flutter
bundle; ARBs do not automatically become Android `strings.xml`.

Keep each locale's final screenshots, feature graphic and requested listing JSON
together under `app_screenshots/<style-or-campaign>/<country_language-or-variant>/`.
Map that readable folder explicitly to its app locale and supported Play slot.
Keep the whole screenshot folder Git-ignored. Remove previews and working files
after delivery; no nested `screenshots/` folder, prompts, reports, ZIPs or hidden
archives. Follow the self-contained
[portfolio Play Store localization workflow](../../app-promotions/references/play-store-localization.md).

Compare localized copy/images through Play experiments. Use acquisition,
conversion and retention by language/country to decide what to improve next.

## Acceptance and rollout

Before enabling a batch, verify:

- Every target locale is completed or has a recorded blocker.
- Existing preferences survive migration, restart, sign-in/out and device changes.
  Manual choices and reset-to-device work as specified.
- Offline saves, failed writes, pending profile sync and rapid changes behave
  correctly; backend rules accept valid new values and reject invalid writes.
- Strings, shared UI labels, fonts, direction, plurals and formatting update
  correctly across normal and recovery screens.
- Scheduled reminders update their language while preserving IDs, intended times
  and notification preferences. Remote announcements/help have an app-owned
  translation/fallback scheme; ARBs do not translate server-authored content.
- Store mappings, copy and images are accurate, and screenshot exports stay ignored.

Use the repository's existing validation rules. Tests and builds remain opt-in;
record the checks actually performed. Release and deployment follow existing
authorization. If a locale is withdrawn, retain the saved preference and resolve
a compatible fallback. Keep backward-compatible profile data during rollout.

For each later app, record the kit revision, enabled locales, translation source
revision, outstanding review/framework work, store assets and release status.
Lunaris is the first working example; each app still needs its own integration.

## First implementation work package

Agree the preference/profile contract, build the shared kit feature, and migrate
Lunaris's existing seven languages. Then complete the script checks and translation
batches, prepare store assets, and adopt the implementation across the portfolio.

## Primary references

- [Flutter internationalization](https://docs.flutter.dev/ui/internationalization)
- [Material localization support](https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html)
- [Play localization](https://support.google.com/googleplay/android-developer/answer/9844778?hl=en)
- [Country-targeted listings](https://support.google.com/googleplay/android-developer/answer/9867158?hl=en)
- [Store listing experiments](https://support.google.com/googleplay/android-developer/answer/12053285?hl=en)
