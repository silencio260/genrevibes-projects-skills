# Shared screenshot and promotion tooling

The implementation is `genrevibes_screenshot_tools`, at
`packages/genrevibes_starter_kit/modules/tooling/genrevibes_screenshot_tools` in
the host app. Read its README and public libraries before changing integration.
Lunaris is the first host, with registration under `tool/promotions/` and an
app guide at `docs/screenshot-tooling.md`. These are implemented APIs, not a
proposed package. Image exports still require the host's rendering checks.

## Ownership and setup

- Install the package in the host's `dev_dependencies`. Never import it from
  production `lib/`, add it to the runtime coordinator, or start native app
  bootstrap just to generate marketing assets.
- Register actual app widgets through `ScreenshotProject` and `ScreenshotScene`
  for raw/product captures. An explicitly selected photographic concept can use
  shared masters and editable layers instead; label that output as a promotional
  composite, not a capture or proof of shipped UI.
  The app owns scenes, supported/ready locale tags, localization delegates, theme,
  fonts, sample data, copy and optional artwork. Do not copy the app UI into a
  second screenshot-only implementation.
- The kit owns headless export, configurable sizes, editable compositions,
  bounded rendering, font-manifest loading, clean final-image delivery and the
  generic Play API uploader. It has no fixed portfolio language list or app brand.
- Inject offline repositories/state in prepare hooks and dispose them afterwards.
  Unexpected business actions should fail. Do not use real user accounts or live
  mining sessions, Firebase, ads, telemetry or notifications to prepare a scene.
- Use app-owned, truthful demonstration values. Freeze relevant state/clock
  inputs where the product supports it; inspect remaining dynamic content.
  An empty offline catalogue must not be described as a live game catalogue.

## Make AI designs inexpensive to translate

Image generation supplies text-free art: backgrounds, textures, illustrations,
decorative shapes or device artwork. Localizable words, captions, footnotes and
values that need regional formatting belong in editable layers. For real-widget
captures, phone content comes from the app's localized production widgets. For
an approved original-image concept, replace all localizable phone/callout text
over shared masters; invariant brands and demo numbers may remain baked in when
that is intentional. Keep marketing copy in source with review status.

`PromotionLayout` accepts `PromotionCopy`, `PromotionStyle`, brand and screen.
`PromotionStyle.backgroundArt` reuses one source image across languages.
`PromotionPhone` fits an actual screen viewport into the composition;
`EditablePromotionText` refuses copy that cannot fit at its readable minimum.
Apps may create another composition using these building blocks.

When asked to improve a design, update its editable composition or text-free
source art. Preserve the text layers. A flattened PNG does not retain them;
existing artwork may require a one-time reconstruction. If AI invents improved
app UI, implement the chosen changes in the app before calling its screenshot
a production capture. Explicit design concepts remain labelled as concepts.

Never regenerate the whole image separately for every language merely to change
its words. Re-render from the same source art, localized app UI and editable
copy. Reusable source assets/configuration belong in source/tooling; intermediate
outputs and backups do not belong in the final-image folders.

## Localization lessons and required review

Read the self-contained [portfolio Play Store localization workflow](play-store-localization.md)
for the user's folder convention, source-versus-delivery organization, generation
techniques, control geometry, actual icon/glyph centering, script/RTL handling,
listing JSON, concurrent locale workers and the approaches that failed. It
applies across apps without requiring the first host's files or history.

The API/setup guidance in this reference remains relevant to integration; the
portfolio guide defines the end-to-end asset workflow and acceptance criteria.

## Export and validate

The host entrypoint calls `registerScreenshotExports`. Run it with the explicit
headless command, for example:

```sh
flutter test tool/promotions/render.dart --dart-define=SCREENSHOT_LOCALES=en-US --dart-define=SCREENSHOT_SCENES=start,feature
```

`SCREENSHOT_LOCALES` filters exact registered tags, `SCREENSHOT_SCENES` filters
registered IDs, and `SCREENSHOT_REPLACE=true` explicitly replaces selected finals.
Do not use an app's scene IDs in another app without checking its registration.
The headless runner uses `flutter test`; the host's opt-in test/build rules still
apply. Implementation authorization alone does not override an exact-command rule.
Do not add golden baselines or unrelated tests as a side effect of exporting.

Verify fonts/glyphs, long translations, RTL, image loading and representative
screen fidelity before a large batch. Native WebViews, ads and system UI need a
separate supported capture path when included. Do not describe a headless image
as proof of device/native behavior. Keep linguistic review distinct from rendering.

The portfolio delivery convention is
`app_screenshots/<style-or-campaign>/<country_language-or-variant>/`, with
screenshots, feature graphics and requested listing JSON together. Register the
readable folder through the host locale directory mapping. The whole output root must be ignored
and untracked; no force-add on ordinary commit requests. Existing finals fail
unless replacement is explicit. Staging is temporary and outside the project;
no ZIPs, contact sheets, manifests, prompts, READMEs or hidden asset archives are
delivered unless the user explicitly requests them.

## Explicit store upload

`package:genrevibes_screenshot_tools/play_store.dart` and
`dart run genrevibes_screenshot_tools:play_store` implement main-listing uploads.
Read the package README for the source-plan schema. Use explicit app-to-Play
locale mappings; duplicate target slots fail. Do not invent Play locale codes
or assume a country selector changes the user's store listing. Country-targeted
custom listings are outside this uploader's current API.

The default CLI checks local files/copy only. `--remote-check` creates an edit,
uploads, validates, then discards it. `--apply` commits without requesting review;
`--submit-for-review` explicitly adds that request. External mutation/publication
requires user authorization for that action. Never run a remote check or upload
just to validate local code. Use separately configured Google credentials and
appropriate app permissions; never save credentials in plans or image folders.

Plans and editable listing-copy sources stay in source/tooling. If the user
requests final listing JSON with the images, keep that deliverable beside the
PNGs; working review notes and plans still stay outside delivery folders. Final
assets remain ignored.
Use reviewed translations and check current store requirements. The tool does
not translate content or mark drafts approved, upload binaries, or guarantee
Google review acceptance. An uncertain commit must be checked in Publishing
overview before retrying; do not automatically repeat remote mutations.
