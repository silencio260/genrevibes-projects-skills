# Portfolio languages, locales, and country selection

Agreed portfolio target, recorded 25 October 2026: **40 base languages and 58
initial selectable locales**. The user's existing seven languages are included,
not added again. This supersedes the earlier 10/20-language recommendations as
the portfolio's full target. Roll out in reviewed batches; do not quietly remove
languages because they require extra framework or store work.

Contents: [catalogue](#initial-locale-catalogue), [country choice](#independent-country-selection),
[variant policy](#translation-and-variant-policy), [store mapping](#google-play-mapping),
[compatibility](#framework-and-script-readiness).

## Initial locale catalogue

Tags use BCP 47 spelling: language lowercase, script title case, region uppercase
or numeric. The app owns this catalogue, native/display names, enabled subset,
translation resources, fallback choices, and readiness. It is a portfolio target,
not a constant list to compile into the starter kit. "Existing" means Lunaris
currently has a base ARB resource; it does not mean these regional variants have
been translated or reviewed.

| # | Base language | Initial selectable locale tags | Existing Lunaris base |
|---|---|---|---|
| 1 | Afrikaans | `af-ZA` | No |
| 2 | Amharic | `am-ET` | No |
| 3 | Arabic | `ar` | No |
| 4 | Bengali | `bn-BD` | No |
| 5 | Chinese | `zh-Hans-CN`, `zh-Hant-TW`, `zh-Hant-HK` | No |
| 6 | Danish | `da-DK` | No |
| 7 | Dutch | `nl-NL` | Yes: `nl` |
| 8 | English | `en-US`, `en-GB`, `en-IN`, `en-NG`, `en-GH`, `en-CA` | Yes: `en` |
| 9 | Filipino | `fil-PH` | No |
| 10 | French | `fr-FR`, `fr-CA`, `fr-CI` | Yes: `fr` |
| 11 | German | `de-DE` | Yes: `de` |
| 12 | Gujarati | `gu-IN` | No |
| 13 | Hindi | `hi-IN` | No |
| 14 | Icelandic | `is-IS` | No |
| 15 | Indonesian | `id-ID` | No |
| 16 | Italian | `it-IT` | Yes: `it` |
| 17 | Japanese | `ja-JP` | No |
| 18 | Kannada | `kn-IN` | No |
| 19 | Kazakh | `kk-KZ` | No |
| 20 | Korean | `ko-KR` | No |
| 21 | Malay | `ms-MY` | No |
| 22 | Malayalam | `ml-IN` | No |
| 23 | Marathi | `mr-IN` | No |
| 24 | Oromo | `om-ET` | No |
| 25 | Polish | `pl-PL` | No |
| 26 | Portuguese | `pt-BR`, `pt-PT` | Yes: `pt` |
| 27 | Punjabi | `pa-Guru-IN`, `pa-Arab-PK` | No |
| 28 | Russian | `ru-RU` | No |
| 29 | Spanish | `es-ES`, `es-419`, `es-MX`, `es-CO`, `es-PE`, `es-AR` | Yes: `es` |
| 30 | Swahili | `sw-KE`, `sw-TZ`, `sw-UG` | No |
| 31 | Tamil | `ta-IN` | No |
| 32 | Telugu | `te-IN` | No |
| 33 | Thai | `th-TH` | No |
| 34 | Turkish | `tr-TR` | No |
| 35 | Ukrainian | `uk-UA` | No |
| 36 | Urdu | `ur-PK` | No |
| 37 | Uzbek | `uz-Latn-UZ` | No |
| 38 | Vietnamese | `vi-VN` | No |
| 39 | Xhosa | `xh-ZA` | No |
| 40 | Zulu | `zu-ZA` | No |

Use `GB` for United Kingdom; do not create a duplicate `en-UK` alongside `en-GB`.
`es-419` means Latin America, not a selectable country. `om` is Oromo; `or` is
Odia and must not be substituted. Chinese script variants and Punjabi script
variants are distinct writing-system deliverables even though each language is
counted once. Modern Standard Arabic is the initial shared Arabic option; this
does not restrict the user's country to Saudi Arabia.

The initial catalogue is extensible. Additional candidates include `bn-IN`,
`ta-LK`, `ur-IN`, `nl-BE`, `de-AT`, `de-CH`, `it-CH`, `ms-BN`, and country-specific
Arabic options. They are outside the initial 58 and require app demand, content
review, and a recorded catalogue revision before being called supported. Country
selection itself does not require adding a new translation variant.

## Independent country selection

Provide separate Language and Country/region settings, both with a device/default
option and manual override. A Nigerian user can choose French while retaining
Nigeria as the preferred region. Never restrict languages to the country's
majority language or use a flag as the only language identifier.

The host app supplies its country/territory options with stable ISO 3166-1
alpha-2 codes and translated display names. It may expose the full appropriate
country/territory dataset or its actual available markets; the shared kit must
not embed Lunaris's countries. A country picker can have many more entries than
the 58 translation locales. Keep a preferred formatting region distinct from
account location or other product-specific country fields.

Language selection determines text and script. Region can affect number/date
presentation through supported locale data without replacing the chosen
language. Return both effective translation and formatting locales from shared
resolution. Device language changes apply only in device-following mode; an
explicit manual language or region remains selected until reset by the user.
Country selection does not change timezone, force a currency, or change the
Google Play account country. Preserve store-supplied localized purchase prices.

## Translation and variant policy

Keep English as Lunaris's source template and keep all real translations in the
current app. Future portfolio apps retain their own chosen source language and
localization system. Use one reviewed base per language/script plus regional
wording where needed; do not translate identical English UI six times merely
to create six English options.

Allow region variants to inherit reviewed text from an explicitly recorded base
of the same language and script. Preserve full tag identity for selection,
formatting, persistence, and analytics even when several variants share text.
If the current generator cannot express the desired inheritance, produce complete
merged ARBs as an app-owned generation step, or keep complete reviewed ARBs;
verify the generated delegate's real fallback behavior before selecting a method.
Do not add a second translation framework solely to obtain inheritance.

Fallback order: exact reviewed locale; configured same-language/same-script
parent; configured same-script language default; app default. Never silently
convert Traditional Chinese to Simplified Chinese or Shahmukhi Punjabi to
Gurmukhi Punjabi. A missing compatible script resolves explicitly to the app's
fallback, with an accurate unsupported/fallback state, rather than claiming the
requested translation loaded. Do not label English copies as finished translations.

Native language names and translated country/script labels come from the app.
The kit takes these as input; reusable picker structure does not require kit-owned
copy. ARB names can use underscores (for example `app_pt_BR.arb` and
`app_zh_Hant_HK.arb`), while stored/transported tags use hyphens. Construct Flutter
locales from language/script/country subtags, never `Locale('pt-BR')`.

## Google Play mapping

App locale tags, country preferences, and Play listing language codes are separate
fields. Check the current Console language choices and official documentation
before creating a listing; an in-app tag does not prove a matching Play slot exists.
Use an explicit app-owned store mapping, not string truncation or guessed codes.

Examples of the mapping to validate:

| App locale family | Store listing approach |
|---|---|
| English | Direct published slots include `en-US`, `en-GB`, `en-IN`, `en-CA`; Nigeria/Ghana can share reviewed English assets or use country-targeted custom listings. Do not invent Play `en-NG` or `en-GH` slots. |
| Spanish | Published slots include `es-ES`, `es-419`, `es-US`; Mexico/Colombia/Peru/Argentina can use reviewed Latin American copy, with country-specific custom listings when justified. |
| French | Published slots include `fr-FR`, `fr-CA`; Côte d'Ivoire may need a country-targeted listing using a supported French slot. |
| Portuguese | Map separately to `pt-BR` and `pt-PT`. |
| Chinese | Map `zh-Hans-CN` to `zh-CN`, `zh-Hant-TW` to `zh-TW`, and `zh-Hant-HK` to `zh-HK`. |
| Swahili | Published listing language is `sw`; assess country-specific assets without duplicating identical translations. |
| Punjabi | Published listing language is `pa`; verify script suitability. Do not assume this covers `pa-Arab-PK`. |
| Oromo, Uzbek, Xhosa, Zulu | Not present in the published listing-language list checked on 25 October 2026. Verify the live Console and record direct-listing availability as unresolved; keep app translation targets. Do not relabel native text under an unrelated language code. |

Other app tags may map to a shorter Play code (for example `fil-PH` to `fil`,
`id-ID` to `id`, and `kk-KZ` to `kk`). Verify every row during the
store mapping phase. Unsupported direct-listing languages need an honest,
supported fallback listing; they do not cease to be app-localization targets.
Do not promise 58 independent Play listing slots or search coverage from 58 app
options. Country-targeted custom listings are separate marketing configuration.

## Framework and script readiness

On the installed Flutter checkout and `intl` 0.20.2 inspected on 25 October 2026,
`om` and `xh` are absent from Material, Cupertino, Widgets localization sets and
bundled `intl` date/number symbol data. `zu` is present. This is a concrete work
item, not permission to rename Oromo or Xhosa to another language. Recheck the
actual app/kit SDK when implementation begins.

Before enabling a locale, verify app strings, Material/Cupertino/Widgets strings,
formatting data, fonts, plural rules, direction, and relevant system pickers.
For missing framework languages, implement/reuse correctly reviewed custom
localizations and formatting data as needed, or retain an explicit readiness
blocker until those adapters exist. Flutter's guidance warns against presenting
an unrelated language subclass as a new translation because plural rules can be
wrong. Punjabi Arabic-script direction also needs explicit verification; a
language-only `pa` implementation is not evidence of RTL script support.

RTL scope includes Arabic, Urdu, and Shahmukhi Punjabi. Chinese, Ethiopic, Indic,
Arabic, Cyrillic, and Latin scripts all need readable font coverage: device
fonts first, with a runtime download only for a missing script. See
[script fonts](script-fonts.md).
Region additions do not automatically provide script coverage or native review.

## Primary references

- [Flutter internationalization](https://docs.flutter.dev/ui/internationalization): locale subtags, ARB messages, delegates, and generation.
- [Flutter Material localization support](https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html): supported languages and custom translations.
- [Play translations and listing languages](https://support.google.com/googleplay/android-developer/answer/9844778?hl=en): available codes and localized graphics.
- [Country-targeted custom listings](https://support.google.com/googleplay/android-developer/answer/9867158?hl=en): regional marketing configuration.
