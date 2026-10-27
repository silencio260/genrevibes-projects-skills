# Script fonts: device first, download on demand

Do not bundle script fonts in portfolio apps. Lunaris once shipped 16 Noto
files (56 MB, 47 MB of it CJK) to every user, whatever their language. That
bloats the download in exactly the markets with metered data. The app's
`assets/fonts/` folder should hold only a brand font, if any.

## Rule

1. Text renders with the device's fonts. Flutter falls back to system fonts
   for any glyph the UI font (Geist) lacks.
2. At startup, ask the platform which scripts its fonts can't draw.
3. Download only the **active locale's** script, and only when it is missing,
   from Google Fonts (`google_fonts`). The device font renders until the
   download lands. The file is cached on disk, so later launches don't
   download it again.
4. iOS ships fonts for every catalogue script, so it never probes or downloads.

## Reference implementation (Lunaris)

| Piece | Location |
| --- | --- |
| Probe | `MainActivity.kt` → `missingGlyphs` on the `lunaris/device` channel. It takes `{scriptId: sampleChar}` and returns the ids where `Paint().hasGlyph(sample)` is false. `hasGlyph` includes system fallback fonts (API 23+). |
| Script map, loader | `lib/core/l10n/locale_fonts.dart`: the `ScriptFont` enum (Google Fonts family + one probe character), `LocaleFonts.load()`, `localeFontFallbacks(locale, weight:)` |
| Startup | `app_bootstrap.dart` awaits `LocaleFonts.instance.load()` next to `LocaleController.load()`, so fallback lists are known before the first frame |
| Styles | `StylesManager.sans/mono` and `ThemeManager` pass the text weight to `localeFontFallbacks` |
| Screenshot tooling | `tool/promotions/font_setup.dart` calls `LocaleFonts.instance.downloadAll()` |

## Details that matter

- **Probe characters:** use one character per script, and pick one that tells
  regional sets apart: `ڑ` for Arabic (it covers Urdu and Shahmukhi letters),
  `あ` for Japanese, `한` for Korean, `汉` for Simplified Chinese, `漢` for
  Traditional. Latin- and Cyrillic-script languages (including Oromo, Xhosa
  and Zulu) need no entry.
- **Font family names are deterministic** (`GoogleFonts.getFont(...).fontFamily`).
  Put them in `fontFamilyFallback` as soon as a script is known to be missing,
  before the download finishes. The engine skips unregistered families. When
  `FontLoader` registers the font, `RenderParagraph.systemFontsDidChange`
  re-lays out the text, so no widget rebuild is needed.
- **Weights:** download only regular (400) and semibold (600). For weights of
  600 and above, put the 600 family first. Each static CJK weight is several MB,
  so don't download every weight.
- **Retries:** `google_fonts` rethrows load failures, and its
  `pendingFonts()` covers every pending font. Retry with capped backoff
  (Lunaris: `15 << attempt` seconds, at most 600, 8 tries per session). Don't
  retry on every widget build.
- **Han glyph forms:** `Text` passes `Localizations.localeOf(context)` to the
  engine, and system fallback picks the Japanese, Korean or Chinese variant
  from that locale. The old "put the right CJK font first" ordering isn't
  needed with device fonts.
- **Older native builds:** a Dart-only Shorebird patch can reach an install
  whose `MainActivity` lacks the probe. Treat `MissingPluginException` and
  timeouts as "the device has everything", never as "download everything".
  The native probe needs a full store release.
- **Screenshot and test renderers have no device fonts.** Tooling must
  download every script font into its ignored developer cache before
  capturing, with the same host-restricted client it uses for Geist. Otherwise
  non-Latin captures show tofu boxes.
- **Usernames in other scripts** rely on device fallback. Only the active
  locale's script is downloaded. Don't add every missing script to the
  fallback list, or one device lacking Ethiopic would download it for all
  its users.

## Verify

- Run `flutter analyze` on the touched files.
- On a device:
  - switch to ja, hi and ar and confirm glyphs, joins and marks render;
  - on a device or emulator image missing a script, confirm the device font
    appears first and the Noto font replaces it after the download;
  - confirm nothing is downloaded for Latin or Cyrillic locales;
  - check the APK/AAB size against the previous release.
