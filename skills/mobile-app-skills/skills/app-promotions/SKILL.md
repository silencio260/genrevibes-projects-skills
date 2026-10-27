---
name: app-promotions
description: "Create, translate and organize app promotional assets, Play Store screenshots, feature graphics and listing copy across portfolio languages, using truthful imagery and clean final folders."
---

# App promotional assets

Inspect the requested platform, assets, app features, references, and destination.
Create only the requested asset set. Use the app's actual product and brand choices.

For reusable generation across languages, use the shared development-only
`genrevibes_screenshot_tools` package. Read the
[screenshot tooling workflow](references/screenshot-tooling.md) for host registration,
editable text, text-free AI artwork, headless export and explicit Play upload.
Do not recreate the renderer or uploader separately in each portfolio app.
For translated screenshots or Play Store listing campaigns, read the
[portfolio Play Store localization workflow](references/play-store-localization.md).
It is the reusable procedure for every app, including generation methods,
source/delivery folders, actual button geometry, RTL, listing JSON, language
review, parallel exports, failure modes and acceptance checks.

The user's default localized delivery structure is
`app_screenshots/<style-or-campaign>/<country_language-or-variant>/` inside the
app. Put numbered screenshots, the feature graphic and requested
`app-details.json` together directly. Keep the whole screenshot tree Git-ignored;
do not create another `screenshots/` subfolder. Sources remain in tooling;
task-created previews and supporting files are removed after final verification.

1. Separate real screenshots from generated concept UI. Capture/read supplied
   screenshots for product evidence; do not label generated mockups as captures.
2. Inspect representative local references before reusing their style. Treat kept
   files as evidence, not automatic approval. Record explicit user feedback.
3. For raw screenshots, keep the app screen intact without phone frames or promo
   headlines. For promotional graphics, use short readable copy and real feature
   claims. Do not invent unavailable UI or results.
4. Use [named style references](references/styles.md) when requested or supported
   by the brief. Keep app-specific subject matter out of unrelated apps.
5. For localized Play Store campaigns, use the portfolio structure above unless
   the user specifies another destination. For other promotional work, default
   to `app promotional assets/<campaign>`. Reuse an existing chosen destination.
   Keep each campaign's individual screenshots and feature graphics together directly
   in its folder, with no extra `screenshots/` subfolder. Follow the delivery
   and cleanup rules below. Do not overwrite approved assets while exploring
   another direction.
6. Check current official target dimensions/formats before calling exports
   store-ready. Do not reuse an old landscape size for every store/device.
7. Inspect finals for readable copy, uncropped text, correct branding, and accurate
   UI. For a set, use a temporary contact sheet and inspect any questionable
   individual images; the sheet is a review aid, not a retained deliverable.

Use available image tools for bitmap generation/editing. Use
[app icon generation](../app-icon-generation/SKILL.md) for icon concepts and
[branding](../branding/SKILL.md) to apply chosen resources.

Report filenames, sizes, and concept/capture/export status. Generating graphics
does not authorize uploading them to a store or changing the app's live assets.
Device captures, tests, and builds follow repository operating rules.

## Plan each asset around a real product claim

For each requested image, record its purpose, target placement, source screenshot,
headline, and output dimensions. Use the actual app UI for claims about features.
When a brief asks for a concept, label the result accordingly rather than
presenting invented screens as shipped behavior.

Keep screenshot content readable after fitting it into the composition. Do not
crop away the control or result that demonstrates the advertised feature. Use
short copy that fits the target size and does not promise capabilities the app
cannot perform.

Keep reusable masters, layout, catalogs, locale mapping and render entrypoints
in app source/tooling outside the delivery folders. Keep disposable review and
extraction material in a temporary location; preserve approved inputs through
iterations. Inspect a temporary contact
sheet for consistency of spacing, typography, and brand, then open individual
finals to check small text and screenshot detail.
Verify dimensions/formats against the current intended destination before calling
the files ready for upload.

Report which assets are real captures, promotional composites, or generated
concepts. Applying/uploading the final set is a separate action from producing
the files unless the user has already requested that action.

## Deliver final assets without folder clutter

For portfolio language/region campaigns, read the
[localization catalogue and store mapping](../localization/references/portfolio-locales.md#google-play-mapping)
and [translation rollout plan](../localization/references/portfolio-rollout.md#store-listings-and-visual-assets).
Localize actual app-screen text as well as headlines, reuse one chosen visual
direction, and map app variants to supported Play language slots or appropriate
country-targeted custom listings. Keep each locale's individual screenshots and
feature graphic together in its campaign/locale folder. Keep the entire app
screenshot folder Git-ignored; ordinary commit requests do not authorize
force-adding it. Locale mappings/review records belong in source/docs, not in
the final image folders.

The user's standing preference is to retain the actual individual screenshots,
final feature graphics, and final app icon. Keep distinct completed campaigns
in clearly named folders. Number screenshots in upload order and use a clear
feature-graphic filename in the same folder. Share one final app icon across
campaigns when it is identical rather than copying it into every set.

Preview boards are temporary images for reviewing a direction before generating
the individual screenshots and feature graphics. Show them when needed, then
delete task-created boards, contact sheets, launcher previews, and superseded
concepts once the requested finals are verified. If the user requests previews
or concepts as the deliverable, keep those available for that review stage.

Do not leave prompt/text files, manifests, research notes, README files, export
scripts, extracted captures, duplicate images, native generation masters, or ZIP
packages in the asset folders unless the user explicitly requests those outputs.
Store disposable working materials temporarily outside the project and remove
them when finished. Retain reusable generation sources in source/tooling; they
are required for future translations and are not delivery-folder clutter.
Do not substitute a hidden archive, backup folder, or an unrequested
ZIP for deletion. Written store copy is a separate deliverable only when asked
for; do not add it to an image-only request.

Apply the same rule to task-created material in the app's `templates/` folder:
remove review boards, generated reference copies, and supporting files after
delivery instead of keeping a second copy there. This does not apply to reusable
templates bundled with these skills or unrelated application templates.

For an existing-folder cleanup, inspect contents and references, then remove
supporting material within the user's authorized scope. When flattening a
`screenshots/` folder, check for filename collisions, move the individual images
beside the feature graphic, and remove the empty subfolder. Verify retained
images are unchanged and complete before deleting duplicates or intermediates.
Remove empty folders and stale links/configuration introduced by the task.
Preserve unrelated user inputs and source assets used by the running app or its
branding generators; the delivery rule does not authorize deleting those.

Report the finished asset location and any meaningful cleanup result in the
conversation rather than creating another summary file in the output folder.
