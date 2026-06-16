---
name: App Icon Generation
description: Generate mobile app icon concepts as simple, high-quality full-image PNG assets across different app categories, with contact sheets, reference analysis, rejection-aware iteration, and app-icon-specific quality gates.
---

# App Icon Generation

## Overview

Generate reusable mobile app icon concepts for different projects as **full-image raster assets**, not flat placeholder marks by default.

This skill exists for requests like:

- `generate app icons`
- `logo replacement`
- `launcher icon concepts`
- `Play Store icon`
- `mobile app icon variations`
- `make icon assets for this app`

Use this skill when the user wants app-icon concepts. Keep `App Promotions` for broader screenshot, feature graphic, and store campaign work.

## Default Output

Write outputs to:

```text
app promotional assets/app-icon-concepts/<project-or-campaign-name>/
  finals/
  contact-sheets/
  prompts/
```

Default deliverables:

- `10` curated individual `1024x1024` PNG concepts
- `1` PNG contact sheet

Generate only by default. Do not implement icons into Android/iOS resources unless the user explicitly chooses a final variant and asks to apply it.

## Grounding Pass

Before prompting:

1. Inspect existing app assets, app name, package metadata, screenshots, and prior promotional asset folders.
2. If the user provided references or store links, analyze them first.
3. If prior generated outputs were deleted and the folder is mostly empty, treat deletion as rejection signal.
4. Infer the app category from the repo when possible:
   - launcher
   - utility
   - ai-chat
   - media
   - social
   - finance
   - education
   - health
   - ecommerce
   - productivity
   - game
   - generic-mobile-app

Ask only when the category or target style cannot be reasonably inferred.

## Design Rules

Preferred default:

- full raster PNG artwork
- simple enough to become a real launcher/store icon
- one strong subject large in frame
- readable at small size
- high contrast and clean silhouette

Good subjects:

- glossy phone
- launcher home-screen card
- home glyph plus screen panel
- widget card
- dock surface
- app-drawer/category hub
- wallpaper stack

If a phone or home-screen surface is visible, mini app icons must use **real generic pictograms**, not blank colored boxes. Good generic pictograms include:

- weather
- camera
- settings
- mail
- music
- maps
- gallery
- chat
- clock
- calendar
- compass
- video

Use generic pictograms only. Avoid:

- copyrighted third-party app logos
- recognizable brand marks
- readable app names
- competitor identities

PNG only unless the user explicitly asks for source/vector files.

## Negative Rules

Avoid these failure modes:

- flat SVG/logo-mark drafts when the user asked for app-icon images
- generic colored boxes where mini app icons should be
- complex promo screenshots that are too busy for launcher-size readability
- tiny UI details that disappear at small icon size
- fake readable text inside the icon
- recognizable third-party brand logos
- repeated near-duplicate compositions presented as distinct concepts

If the user says a direction is wrong, encode the rejection into the next prompts before regenerating.

Examples of rejection notes to carry forward:

- `too much logo aesthetic`
- `too busy for app icon`
- `too much flat icon look`
- `generic colored boxes`
- `full screenshot but not simple enough`
- `not enough variation`

## Prompt Rules

Every concept prompt should share these constraints:

- square app icon image
- simple, premium, high-quality raster render
- suitable as an actual launcher/store icon
- no text
- no brand logos
- no copyrighted app icons
- strong central subject
- clean lighting and readable silhouette

When a launcher/home-screen concept is involved, explicitly require:

```text
Mini app icons must contain real generic pictograms such as weather, camera, settings, mail, music, maps, gallery, chat, clock, calendar, compass, or video.
Do not use blank colored squares or placeholder app tiles.
```

## Default Variation Set

Unless the user asks for a narrower set, generate 10 meaningful concepts with distinct composition:

1. upright phone
2. tilted phone
3. close-cropped phone
4. floating home-screen card
5. glass launcher surface
6. home glyph plus screen panel
7. widget-forward composition
8. dock-forward composition
9. wallpaper-card / layered surface
10. app-drawer or category-hub composition

Adapt the subject mix to the app category. For example:

- `launcher`: phone, dock, home-screen card, widget panel, app drawer, wallpaper stack
- `utility`: single device + tool dashboard, one key result card, one control panel
- `ai-chat`: one hero chat surface, assistant cards, prompt tiles, gallery/history card

## Quality Gate

Before delivery:

1. Normalize each kept concept to `1024x1024` PNG.
2. Create a contact sheet.
3. Inspect the sheet and any suspicious individual outputs.
4. Reject and regenerate concepts that:
   - look flat or logo-only
   - use generic placeholder boxes
   - are too busy
   - include real brand marks
   - include garbled visible text
   - feel too similar to another concept in the same batch

Deliver only the curated final set.

## Delivery

Report:

- output folder path
- individual PNG count
- contact sheet path
- any caveat if a kept image is still only a direction draft and needs cleanup before store production

Do not automatically implement the chosen icon into platform resources. Wait for explicit approval and selected filenames.
