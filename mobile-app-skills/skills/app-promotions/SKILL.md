---
name: App Promotions
description: Generate and optionally implement promotional assets for any mobile app type, including raw app screenshots, store-ready promotional screenshots, feature graphics, social assets, icons, notification icons, and meaningful visual variation packs.
---

# App Promotions

## Overview

Create platform-ready promotional assets for any mobile app while preserving the user's intent, feature truth, and future branding flexibility. Infer the app category, generate raw app screens and store-ready promo assets, create meaningful variations, and avoid repeated back-and-forth by using structured defaults, reference analysis, reusable prompt recipes, and strict quality gates.

Branded assets are opt-in. By default, generated images must use feature-led generic copy and must not include the app name, app logo, company name, developer name, or legal/trademarked brand marks in the image.

If the user specifically wants **app icon concepts** rather than broader promotional campaigns, use the dedicated **App Icon Generation** skill. Keep this skill focused on screenshots, promo screenshots, feature graphics, social assets, and implementation of already-chosen icon outputs.

## Default Output Location

Write generated assets to an `app promotional assets/` folder at the workspace root unless the user gives another destination. If the user names a destination, use that exact destination. Use campaign subfolders to keep outputs easy to compare:

```text
app promotional assets/
  <campaign-name>/
    raw-screenshots/finals/1080x1920/
    promo-screenshots/finals/1052x592/
    feature-graphic/finals/1024x500/
    social-assets/
    variations/<profile-or-feature>/finals/
    preview-contact-sheets/
    prompts/asset-direction.md
    prompts/asset-manifest.md
    references/
```

Keep source screenshots, downloaded references, prompts, generated finals, contact sheets, and manifests separate. Never overwrite a prior generation without asking unless replacing a clearly broken asset inside the same requested iteration.

## Intake

Collect or infer:

- Target platform: `android`, `ios`, or `both`.
- Asset types: raw screenshots, promo screenshots, Play Store feature graphic/banner, App Store assets, social assets, app icon, adaptive icon, notification icon, OneSignal icon, mockups, or variation packs.
- Brand inputs: colors, fonts, visual tone, store category, screenshots folder, or app/package identifiers. Treat app names, logos, company names, developer names, and trademarks as opt-in image content only.
- Reference inputs: a folder of examples, specific images, or Play Store/App Store links whose style should be studied.
- Implementation intent: generate only by default. Implement into the project only when the user explicitly says to implement and names the chosen assets.

If dimensions or store policy compliance matter, verify current official Google Play, Android, Apple, or OneSignal documentation before final export because store requirements can change.

## App-Type Detection

Before generating assets, infer the app profile from the user's brief, screenshots, package name, UI folders, store references, existing assets, and feature list. If multiple profiles fit, choose the closest primary profile and note secondary influences in `prompts/asset-direction.md`.

Common profiles:

- `launcher`: home screen, themes, app library, widgets, search, privacy, clock/tools.
- `utility`: core task flow, result screen, settings, trust/safety, before/after.
- `ai-chat`: chat, prompt templates, image generation, history, pro modes.
- `media`: browse, player/viewer, library, editing or saving flows.
- `social`: feed, creation, messaging, profile, discovery.
- `finance`: dashboard, transactions, budgets, reports, trust screens.
- `education`: lesson, practice, progress, quiz, certificate.
- `health`: tracking, plans, progress, reminders, privacy-sensitive screens.
- `ecommerce`: browse, detail, cart/checkout, recommendations, profile.
- `productivity`: dashboard, calendar/tasks, automation, reports, collaboration.
- `game`: gameplay, progression, characters/items, rewards, modes.
- `generic-mobile-app`: use when no stronger profile is available.

Use the profile to choose screen concepts, visual tone, feature coverage, prompt style, and variation packs. Do not use one generic visual style for every app.

## Brand-Safe Generation

Default to anonymous, feature-led assets:

- Do not include the app name, app logo, company name, developer name, or legal/trademarked brand marks inside generated images by default.
- Do not include competitor names, competitor logos, platform logos, or official trademarked app/service icons unless the user explicitly requests them and they are safe for the intended use.
- Use generic feature copy such as `Smart Search`, `Private Vault`, `Minimal Themes`, `Track Progress`, `Create Faster`, or `Stay Organized`.
- Use brand colors, visual tone, and product category cues when available, but keep identity text and logos out of the image unless the user says branding is final and wants branded assets.
- If branding appears accidentally in generated output, regenerate or edit it out before delivering.

## Generation Rules

- Use the available image generation or image editing tools for bitmap asset creation.
- Preserve product truth. Generated UI must reflect the real or requested feature set; do not invent unavailable features unless the user asks for conceptual mockups.
- Preserve real UI detail. Raw app screenshots must be high resolution, sharp, readable, and free of device frames, borders, shadows, hands, desks, backgrounds, promotional headlines, or decorative mockups.
- When the user asks for both raw and mockup screenshots, export raw screenshots first, then create mockup variants from those exact finals.
- If the user asks for promotional screenshots, generate store-ready feature cards with clear benefit copy, generated UI/mockups, safe margins, and no cropped text.
- If the user provides Play Store/App Store links or example folders, analyze visual patterns: composition, text density, background style, color palette, screenshot crop, device treatment, theme/style vocabulary, and platform conventions.
- Treat user-provided links and screenshots as style references unless explicitly told to paste them into final assets.
- Do not paste buggy or incomplete screenshots into final promotional images unless explicitly requested.
- If the user deletes generated images, treat deletion as rejection signal. Inspect what remains, update the direction notes, and avoid the rejected patterns in the next campaign.
- Avoid misleading store assets. Do not invent UI states that imply unavailable features unless the user confirms the feature exists.
- Use transparent PNG for icons that require transparency. Use PNG or JPEG for store screenshots according to platform requirements and visual quality.
- Keep source prompts, reference notes, approved patterns, rejected patterns, brand-safe copy rules, and generation notes in the campaign folder so later iterations can reuse the same direction.

## Universal Generation Pipeline

Use this pipeline unless the user asks for a narrower asset set:

1. **Asset direction:** Create or update `prompts/asset-direction.md` with app profile, feature list, references, approved patterns, rejected patterns, brand-safe copy rules, and planned outputs.
2. **Raw screenshots:** Generate pure in-app screens first. Use `1080x1920` as a common Android portrait export unless a different store/device target is requested.
3. **Promo screenshots:** Generate store-ready promotional screenshots. Use `1052x592` as a common landscape Play-style export when no exact target is requested.
4. **Feature graphic:** Generate a Google Play-style `1024x500` feature graphic when requested or useful for a Play campaign.
5. **Social assets:** Generate square/story variants only when useful or requested.
6. **Variation pack:** Generate a profile-specific variation pack when the app has themes, skins, modes, templates, content categories, personas, or visual styles.
7. **Contact sheets and manifests:** Export exact-size finals, create contact sheets, and write `prompts/asset-manifest.md` with filenames, sizes, copy, prompt notes, and references.

## Prompt Recipes

### Raw Screenshot Prompt

Use this structure for generated raw app screens:

```text
Use case: ui-mockup
Asset type: raw <platform> app screenshot, portrait 9:16.
Primary request: Generate a flat in-app screenshot for <feature/screen>. No phone mockup, no device frame, no border, no external background, no marketing text.
Subject: full-screen <app profile> UI showing <real feature details>.
Composition/framing: entire canvas is the app screen edge-to-edge; UI fills the full image.
Color palette: <brand/category palette without identity text/logos>.
Text: realistic UI labels only. No promotional headline. No app/company name unless explicitly requested.
Constraints: no hardware frame, no external background, no shadow, no border, clean readable UI, product-truthful features only.
Avoid: promotional poster layout, pasted screenshots, watermark, garbled text, cropped UI, brand/logo leakage.
```

### Promotional Screenshot Prompt

Use this structure for store-ready promo screenshots:

```text
Use case: ads-marketing
Asset type: store promotional screenshot, landscape 1052x592 unless another size is requested.
Primary request: Create a store-ready promotional screenshot for <feature>, using generated UI/mockups and feature-led copy.
Subject: generated <app profile> screen(s) showing <feature details>.
Composition/framing: strong headline, readable supporting copy, generated UI as hero, safe margins, no cropped text.
Color palette: <category-appropriate palette>.
Text (verbatim): "<feature-led headline>" and smaller text "<benefit copy>"
Constraints: no app name, no logo, no company/developer name by default; no competitor marks; product-truthful features only.
Avoid: generic filler visuals, buggy screenshots, brand leakage, watermark, garbled text, cropped UI.
```

## Variation Rules

Generate meaningful variations based on the app profile, not random duplicates:

- `launcher`: iOS-style theme, minimalistic themes, privacy, search, app library, widgets.
- `ai-chat`: chat, image generation, history, prompt templates, assistants/personas, pro modes.
- `utility`: core task flow, result screen, settings, trust/safety, before/after.
- `media`: browse, player/viewer, library, editor, saved/downloaded state.
- `social`: feed, creation, messaging, profile, discovery.
- `finance`: dashboard, transactions, budget, report, alerts/trust.
- `education`: lesson, practice, quiz, progress, certificate.
- `health`: tracking, plan, progress, reminders, privacy-sensitive screen.
- `ecommerce`: browse, detail, cart/checkout, recommendations, profile.
- `productivity`: dashboard, calendar/tasks, automation, reporting, collaboration.
- `game`: gameplay, progression, characters/items, rewards, modes.

When a profile has themes, skins, templates, modes, content categories, personas, or visual styles, generate a variation pack that demonstrates those differences clearly. For example:

- Launcher iOS-style theme: use Android iOS-launcher visual language such as rounded icon grid, frosted widgets, app-library/control-center cues, and glass dock. Avoid generic wallpaper-only shots, Apple logos, official Apple service icons, competitor names, and exact iOS screenshots.
- Launcher minimal themes: create distinct variants such as `Pure Mono`, `Paper Light`, `Focus List`, `Soft Grid`, and `AMOLED Calm`, not repeated black screens.

## Common Asset Targets

Use these as common defaults when current official requirements are not being checked:

- Android launcher icon: adaptive icon foreground/background plus legacy PNG densities.
- Google Play icon: `512x512` PNG, no transparency.
- Google Play feature graphic/banner: `1024x500`.
- Android notification small icon: transparent-background white-only glyph, exported for density buckets and suitable for status bar rendering.
- OneSignal Android default notification icon: provide a white transparent small icon suitable for `ic_stat_onesignal_default` or the app's configured OneSignal small icon resource name.
- Notification large icon: app-branded square PNG when requested, usually based on the launcher mark and readable at small sizes.
- App Store icon: `1024x1024` PNG, no transparency.
- App screenshots: platform/device-specific dimensions. Prefer exporting at native or higher capture resolution and downscaling only at final packaging time.

## Screenshot Workflow

1. Use provided screenshot folders first. If screenshots are missing and the app can be run locally, capture fresh screenshots with the appropriate emulator/device workflow.
2. Clean screenshots without changing the product truth: crop only status/navigation bars when appropriate, correct scale, and ensure text is legible.
3. Produce raw store-ready screenshots without mockup frames by default.
4. Add marketing text overlays only if the user requests promotional screenshot graphics. Keep text clear, short, and safely inside platform crop areas.
5. Create mockups only when the user asks for mockups or both versions. Keep mockup output separate from raw screenshots.

For generated conceptual screenshots, raw screens still mean app screen only: no phone body, no external background, no border, no promotional headline, and no app/company identity by default.

## Reference and Rejection Handling

1. Save reference URLs, downloaded examples, user-provided screenshots, and style notes under `references/` or `prompts/asset-direction.md`.
2. Label each reference role: style inspiration, feature truth, edit target, or source screenshot.
3. If the user says a generation is wrong, record concrete rejected patterns such as `generic wallpaper`, `white ad-card layout`, `buggy pasted screenshots`, `missing theme variations`, or `brand/logo in image`.
4. If generated files are removed by the user, inspect what remains and treat missing/removed outputs as rejection unless the user says they were only cleaning.
5. Use rejection notes to change prompts before regenerating.

## Quality Gates

Before delivery:

- Confirm exported dimensions for every final.
- Create and inspect a contact sheet for each campaign.
- Inspect individual images when the contact sheet shows possible issues.
- Check raw screenshots for frames, borders, external backgrounds, marketing text, or app/company identity leakage.
- Check promo screenshots for readable text, strong feature message, safe margins, no cropped copy, no generic filler visuals, no competitor logos, and no brand leakage.
- Check generated UI for product truth and category fit.
- Regenerate or repair outputs with garbled text, wrong branding, cropped UI, buggy layout, or a visual style that conflicts with the references.

## Icon Workflow

1. Locate existing icon/logo assets in the app project before generating from scratch.
2. If the request is primarily for icon concept generation, hand off to the dedicated `App Icon Generation` skill and only return here for broader campaign assets or implementation.
3. Generate multiple concepts when the user has not chosen a visual direction.
4. Unlike screenshots and promo graphics, icons are inherently branded assets. Only generate or include app logos when the user asks for icon/logo work or confirms branding is locked.
5. Export icons in the required sizes and transparency formats for the target platform.
6. For Android notification and OneSignal small icons, simplify the mark into a single-color white silhouette with transparent background. Test that it remains recognizable at small sizes.
7. Name files clearly by platform, type, size, and variant.

## Implementation Rules

Only implement assets into the app after the user explicitly says to implement and identifies the chosen generated files or variant.

Before implementation:

- Inspect the existing project asset structure and naming conventions.
- Make focused edits and report changed files.
- For Flutter projects, place assets according to existing Android/iOS resource patterns and update manifests, notification metadata, or pubspec entries only when required.
- For OneSignal, configure the default notification icon resource only if the project already uses OneSignal or the user asks to add/configure it.

After implementation, run the relevant formatting, analysis, tests, or build checks available in the project when feasible.
