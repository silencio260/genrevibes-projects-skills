# Portfolio workflow for translated Play Store assets

Use this guide for any portfolio app's localized screenshots, feature graphics,
and store-listing copy. It is self-contained; no Lunaris checkout or conversation
history is required. The app owns its brand, facts, translations, locale batch
and chosen visual style. The shared kit owns reusable rendering and upload tools.

Read only the sections needed for the request:

- [Folder structure and cleanup](#folder-structure-and-cleanup)
- [Generation techniques](#generation-techniques)
- [Editable layout and alignment](#editable-layout-and-alignment)
- [Translation and listing copy](#translation-and-listing-copy)
- [Parallel language generation](#parallel-language-generation)
- [Validation and delivery](#validation-and-delivery)
- [Approaches that failed](#approaches-that-failed)

## Establish the campaign scope

Confirm or infer from the request the approved reference/style, selected screens,
target languages/variants, listing fields, output destination and protected files.
Continue an agreed batch; do not silently expand 20 languages to the full app
catalog or replace the user's chosen reference. A portfolio language target is
not an instruction to translate every listing on every run.

Distinguish actual app captures from promotional composites. A headless render
can use real app widgets without an emulator, but that does not establish native
WebView, system UI or device behavior. Generated concept UI is not proof that
the product has implemented the pictured design. Preserve truthful feature,
pricing and reward claims in every translation.

## Folder structure and cleanup

For multilingual Play Store campaigns, the user's preferred structure inside
each app is:

```text
app_screenshots/
  <style-or-campaign-name>/
    <country_language-or-variant>/
      01-<screen-name>.png
      02-<screen-name>.png
      ...
      google-play-feature-graphic-1024x500.png
      app-details.json
```

Examples of the locale-folder convention are `United-States_English`,
`France_French`, `Brazil_Portuguese`, `Latin-America_Spanish` and `Global_Arabic`.
Use readable names and preserve script/region distinctions where needed. Maintain
the exact app/Play locale codes separately in source; never infer them by parsing
the folder label. A regional folder does not restrict distribution to that country.

These are portfolio defaults; honor a destination the user explicitly chooses:

- Put a locale's individual screenshots, feature graphic and requested listing
  JSON directly together. No extra `screenshots/`, `feature-graphics/` or metadata
  subfolder inside that locale. The app's own root already identifies the app.
- Name the campaign by its style or purpose, and keep distinct requested designs
  in distinct campaign folders. Use stable numbered screenshot filenames in
  upload order. Keep the same scene filenames across languages.
- Include `app-details.json` for a listing-copy deliverable. Do not add unsolicited
  copy to an image-only request. Share an identical app icon once at the agreed
  location rather than duplicating it into every language folder.
- Ignore the entire `app_screenshots/` tree. Check both ignore rules and tracked
  files; an ignore rule does not untrack files already in Git. Ordinary commit
  requests do not authorize force-adding the output tree.
- Preview boards/contact sheets exist only for review before individual finals.
  Delete task-created previews and superseded temporary concepts after final
  verification unless the user requested them as deliverables.
- Do not deliver prompts, extraction files, working text files, ZIPs, README files,
  validation reports, upload plans, duplicate reference copies or hidden backups
  in the image folders. Requested final listing JSON is a deliverable, not clutter.
- Preserve user-designated original samples and approved sets. Do not delete
  unrelated inputs or application assets when removing task-created intermediates.
- Apply the same cleanup to task-created preview/supporting material in an app's
  `templates/` folder; do not retain a second delivery archive there.

Editable sources have a different purpose from delivery files. Keep reusable
masters, geometry, translations, mapping and render entrypoints in source/tooling
outside the final-image folders. A suitable new-host layout is:

```text
tool/promotions/<campaign>/
  masters/                  # shared artwork without replaceable lettering
  layout.json               # IDs, panels/quads, typography, buttons and icons
  translations/             # screenshot text keyed by stable ID/source phrase
  listing-copy/             # title, descriptions and source review status
  locales.json              # app tag, folder name and supported Play slot
  render.dart               # app-owned registration using the shared renderer
```

This is an illustrative source layout, not a fixed API or a migration requirement.
Reuse an app's equivalent existing paths. Reusable source files remain after
delivery; disposable extraction dumps, review boards and temporary staging do not.

## Generation techniques

### Real app screenshots

Use the actual localized production widgets, app theme/fonts and offline demo
state through the shared `ScreenshotProject` / `ScreenshotScene` APIs. Freeze
relevant clocks and data, load assets and fonts before capture, and dispose demo
repositories and timers afterward. Do not start real accounts, ads, telemetry or
live business operations merely to generate store materials.

This method worked for editable captures and product evidence. It does not
automatically recreate a supplied photographic mockup: a generic Flutter phone,
one reused background and simplified cards can lose the approved composition.
Keep the real-capture capability even if that particular marketing rebuild fails.

### New AI-assisted promotional designs

Ask image generation for reusable art with replaceable text areas left blank:
backgrounds, photographic devices, illustration, glass objects, textures and
lighting. Author headlines, captions, footnotes, app labels, buttons and callouts
as editable layers. Keep the app's actual content/claims separate from decoration.

For buttons, prefer blank surfaces and editable icons from the outset. Avoid
embedding an icon at a position that only balances the English label. Maintain
the same scene-specific artwork and geometry across all translated variants.
The final PNG is flattened; the master plus layout and text catalogs are the
editable source used for regeneration.

### Existing flattened reference images

When preserving an approved image-based design, author a shared master once:

1. Inspect every original scene, including phone UI, enlarged foreground cards,
   background lettering and feature graphics. Inventory all localizable regions.
2. Remove replaceable words while preserving devices, scene objects, perspective,
   button surfaces, materials, lighting and callout composition. OCR can suggest
   regions; it is not the final layout or a complete text inventory.
3. Preserve invariant brands/demo values only when intentional. Numbers that need
   regional formatting must remain editable. Inspect for residual English,
   altered numbers, removed icons and displaced active-tab indicators.
4. Reconstruct genuine container/control planes, font styles and text layers.
   Compare a representative reconstruction to the approved reference before
   expanding the batch. Similar colors or successful export are insufficient.
5. Render every locale from the same sources. Do not regenerate the bitmap per
   language merely to insert translated words.

A one-off image-generator translation/edit may be appropriate when explicitly
chosen, but it produces another raster image. Do not describe it as the reusable
layer system. Record protected historical exceptions rather than claiming all
retained assets were produced through one technique.

## Editable layout and alignment

Use the shared `genrevibes_screenshot_tools` implementation; read the host's
installed API before changing it. The [tooling reference](screenshot-tooling.md)
describes integration. Do not copy a second generic renderer into each app.

Check the app's pinned starter-kit revision and package inventory first. The
usual package location is
`packages/genrevibes_starter_kit/modules/tooling/genrevibes_screenshot_tools`,
installed through the host's `dev_dependencies`. If absent, follow
[kit package selection](../../../starter-kit/SKILL.md) and
[compatibility guidance](../../../references/kit-compatibility.md) to identify the
smallest adoption step within the request's scope. Do not import unavailable APIs
or silently replace the approved design with a generic fallback. If access or a
required revision is unavailable, state the specific missing dependency and
prepare the source/layout work that can proceed independently.

Author text inside available containers, not inside English letter outlines:

- For a button, define its full inner plane with safe margins inside the border
  and rounded ends. Project that plane onto the actual control's four corners.
  A horizontal OCR substring rectangle is wrong for a sloping button.
- Fit the visible icon and translated label as one group, with an explicit gap.
  Center the group horizontally and its actual glyph ink vertically. Measure the
  icon's visible aspect-preserving ink; a transparent square introduces an
  optical offset even when allocation-based arithmetic says “centered.”
- When replacing a baked icon, remove/mask it once and paint the editable icon
  with the label. Inspect locally sampled fill restoration for seams and ghosts.
  Drawing a second icon over an intact original is not a fix.
- Reserve the actual icon width and gap before fitting the label. Maintain
  readable minimum sizes. Use available safe space, then natural concise wording,
  then size reduction; do not force long translations into tiny English boxes.
- Derive navigation text space from neighboring controls. Arbitrarily widening
  every label causes overlap, even when each label fits its own box.
- Use coherent heading/caption anchors and line separation. For RTL, successive
  headings need a common physical right edge, not different English word widths.
- Keep glyph aspect ratios during projection. Verify the final perspective;
  correct local math cannot validate an incorrectly authored quadrilateral.

The prepared renderer supports `PromotionTextLayer.leadingIcon`, `iconSize`,
`iconGap`, horizontal alignment and
`verticalAlignment: PromotionTextVerticalAlignment.center`.
`PreparedLayeredPromotion.localInkBounds` and `localIconBounds` expose actual
placement for containment, separation and centering checks. Prepare after fonts
load in a real asynchronous hook and reuse the same layer instances and strings
for capture. Leading-icon groups require the prepared path in this implementation.

The renderer has no device fonts: download every target script font into the
tool's ignored cache before capture (never into the app bundle; see
[script fonts](../../localization/references/script-fonts.md)). Verify the selected CJK regional forms,
Indic marks, Arabic joins, accents and descenders. Correct shaping does not solve
bidirectional numbers. Keep signed quantities, fractions, percentages and units
in their intended order inside RTL text; use directional isolation where needed.
Keep number/percent spacing nonbreaking when appropriate to prevent orphan `%`.
Mirror directional icons where their meaning requires it, not the whole brand art.

## Translation and listing copy

### Text sources and review

Maintain a source inventory/glossary across app UI, screenshot copy and store
descriptions. They can be separate catalogs; do not imply edits propagate between
them unless a real integration does that. Include every visible duplicate, such
as a label on the phone and the same label enlarged in a floating card.

Reuse existing translations as candidates, preserving placeholders and plural
metadata. Review contextual meaning: “left” can mean remaining time, “rate” can
mean reward rate rather than fee, and mining is not a possessive pronoun. Check
singular/day labels, units, proper names, compact button wording and consistency
of address. Do not translate backend IDs, routes or analytics identifiers.

Track AI draft/review, fluent-speaker approval, rendered visual review and release
status separately. Complete keys and valid fonts do not prove natural language;
agent review is not native-speaker certification. A screenshot reviewer does not
automatically approve the long store description.

### Store JSON and locale mapping

For each selected supported listing, supply `app-details.json` with:

| Field | Meaning |
|---|---|
| `language` | Exact supported Google Play listing slot, not a folder-derived guess. |
| `title` | Localized app title. |
| `shortDescription` | Localized short description. |
| `fullDescription` | Localized long description with intended paragraph breaks. |

Keep source glossary/review notes and any upload plan outside final folders.
Write valid UTF-8 JSON with real accents, correctly escaped strings and intentional
newlines. Inspect actual text, not only whether JSON parses. Preserve material
product qualifications and do not translate future features into current promises.

Map app tag → readable folder → supported Play slot explicitly. For example,
`id-ID` can map to `Indonesia_Indonesian` and Play `id`; `pt-BR` to
`Brazil_Portuguese` and `pt-BR`. Verify current supported slots and variants;
different app tags can target the same store slot and must not silently overwrite
one another. A country's app setting and a folder flag do not control Play's
listing selection. Country-targeted custom listings are a separate operation.

Check nonempty fields and the current platform limits. The existing campaign
validator uses title/short/full limits of 30/80/4000 UTF-16 units; document that
local counting rule and verify current official requirements before publication.
Local checks are not remote acceptance. Do not truncate translations blindly to
meet limits or assume localized wording provides measured keyword performance.

Refresh copy JSON independently of image composition where possible. Never run
an older/rejected visual renderer merely to update metadata if it also overwrites
approved PNGs. Preserve listing JSON when the request changes only screenshots,
and verify unchanged content when that is part of the agreed scope.

More translated listings do not guarantee optimum ASO or maximum downloads.
Choose the requested batch, review local wording, and measure acquisition and
conversion after publication before reporting a performance improvement.

## Parallel language generation

When the user requests separate language agents, give each requested locale its
own worker and disjoint output folder. Run generation concurrently up to the
actual session limit, then fill freed slots with remaining locales. Do not
hard-code three workers as a portfolio rule or claim all languages ran at once.

Finish shared master/layout/renderer edits before workers start. A worker needs
the exact app directory, source/catalog, output folder, supported locale tag,
approved entrypoint/filters, expected files and review criteria. Keep workers
from making concurrent incompatible edits to shared geometry or the same catalog.

Separate the common template-authoring job from language generation and review.
Assigning language agents only to review words while one process exports all
languages sequentially does not fulfill a request for parallel generation. Each
language worker should perform its export and report actual completion/errors.

Avoid recompiling the whole host with different compile-time locale defines for
every worker when the host supports runtime filters. Warm a shared compiled host,
then use process environment filters with identical compilation settings. Runtime
filter support must be implemented/verified in that entrypoint; it is not implied
by the generic options API. Disjoint staging/output paths remain necessary.
Watch compiler/memory contention rather than assuming more processes are faster.

Respect host command-approval rules and existing user authorization; do not ask
again for a command already authorized in the agreed scope. Actual uploads keep
their separate authorization boundary. Report queued, reviewing copy, rendering,
files published and visual checks as different states. A created agent or running
compiler is not a completed screenshot set.

## Validation and delivery

Before scaling, check the reference composition, long target-language text and
each selected script/direction. Include Indic and RTL samples when those scripts
are in the requested batch; do not generate unrelated languages just for review.
Protect designated originals/approved sets with hashes
where unchanged files are required. Derive expected scene/button counts from
this campaign, not a previous app's fixed eight screenshots or nine buttons.

For each locale, verify:

1. All requested words are translated, including phone UI, foreground callouts
   and the feature graphic. No hidden English fallback or leftover raster text.
2. Fonts render correctly; phrases are meaningful; units/numeric signs retain
   their intended order; line wrapping does not orphan punctuation or units.
3. Visible button icon/label groups are centered and padded, contain no overlap,
   follow the correct plane and show no mask seams or duplicated symbols.
4. Headings, navigation, badges and small labels have correct anchors and spacing.
   Inspect all affected controls at full resolution; contact sheets alone miss
   small alignment errors. Fit checks alone miss bad composition and geometry.
5. The complete expected final filename set exists in the correct locale folder,
   with the right scene order and matching listing language. Check dimensions,
   color/transparency format and file-size limits for the actual target.
6. Listing JSON parses, contains valid fields/mapping, meets configured/current
   limits and has independent language/editorial status.
7. Protected originals, unrelated locales and unchanged copy remain unchanged.
   Keep staging isolated; do not mark a partially published worker complete.

For the established phone-portrait campaign, 1080×1920 RGB PNG screenshots and a
1024×500 RGB feature graphic worked. They are campaign examples; verify current
requirements for other form factors instead of applying them universally.

After verification, remove task-created previews, staging and superseded working
outputs; check the folder structure and Git ignore state. Preserve editable
masters/catalogs and requested originals. Report the location, locale/file counts,
capture/composite method, validation performed and any remaining language review.

The shared uploader handles main-listing copy, phone screenshots and the feature
graphic. Local validation does not upload. Remote check creates a temporary edit;
apply and submit-for-review are distinct actions. Use credentials outside Git and
only perform authorized remote operations. Do not claim published, accepted or
ASO-improved results from local exports, nor release an app binary as a side effect.

## Approaches that failed

| Do not repeat | Why it failed / what to do instead |
|---|---|
| Rebuild an approved photographic reference with one generic phone/background | Loses realism, per-scene objects and floating-card composition. Compare against the actual reference before scaling. |
| Generate each translated bitmap independently and call it reusable | Gives flattened edits with repeated model work. Author shared art and editable text once for batch localization. |
| Use OCR letter bounds as control bounds | English-shaped regions do not describe button padding or translation space. Author the physical container plane. |
| Widen text to one side or keep a fixed embedded icon | Produces unbalanced language-dependent buttons. Center actual visible icon and label ink as one group. |
| Center allocation squares or line boxes only | Transparent icon padding and glyph ascents hide optical offsets. Measure visible ink and verify the rendered result. |
| Use Latin defaults, ignore bidi signs or retain different English RTL anchors | Produces poor script positioning, reversed signs and inconsistent headings. Load script fonts into the renderer and author direction/alignment explicitly. |
| Make every navigation box wider independently | Adjacent labels overlap. Bound by neighboring controls and use concise natural labels. |
| Treat ARB reuse, complete keys or technical export as approval | Contextual mistranslations and visual defects passed those checks. Review language, design and placement separately. |
| Call reviewers parallel generators, or spawn cold compilers indiscriminately | Misrepresents work and can increase contention. Run disjoint actual exports within capacity and reuse a compiled host where supported. |
| Store prompts/previews/ZIPs or nested screenshots folders with finals | Makes the user's assets hard to navigate. Keep the requested flat locale deliverables and source/tooling separate. |
| Treat folder countries/app locales as automatic Play targeting | Can overwrite or misroute listings. Use explicit supported store mappings. |
| Claim native approval, publication or download uplift from generated files | Those need separate review, authorized remote results and measurements. Report only established outcomes. |
