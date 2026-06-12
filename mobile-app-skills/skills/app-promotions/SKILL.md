---
name: App Promotions
description: Generate and optionally implement promotional assets for mobile apps, including app icons, Android notification icons, OneSignal notification icons, Play Store and App Store listing graphics, raw high-resolution app screenshots, and optional mockup screenshot variants.
---

# App Promotions

## Overview

Create platform-ready promotional assets for a mobile app while preserving the user's intent: raw screenshots by default, mockups only when requested, and implementation only after the user explicitly chooses which generated assets to apply.

## Default Output Location

Write generated assets to an `app promotions/` folder at the workspace root unless the user gives another destination. Use campaign subfolders to keep outputs easy to compare:

```text
app promotions/
  store-refresh/
    android/
    ios/
    screenshots/raw/
    screenshots/mockups/
    source-examples/
```

Keep source screenshots, downloaded references, prompts, and generated finals separate. Never overwrite a prior generation without asking.

## Intake

Collect or infer:

- Target platform: `android`, `ios`, or `both`.
- Asset types: app icon, adaptive icon, notification icon, OneSignal icon, Play Store feature graphic/banner, App Store assets, raw screenshots, mockups, or both raw and mockup variants.
- Brand inputs: existing app icon, logo, colors, fonts, app name, tagline, store category, screenshots folder, or app/package identifiers.
- Reference inputs: a folder of examples, specific images, or Play Store/App Store links whose style should be studied.
- Implementation intent: generate only by default. Implement into the project only when the user explicitly says to implement and names the chosen assets.

If dimensions or store policy compliance matter, verify current official Google Play, Android, Apple, or OneSignal documentation before final export because store requirements can change.

## Generation Rules

- Use the available image generation or image editing tools for bitmap asset creation.
- Preserve real UI detail. App screenshots must be high resolution, sharp, readable, and free of device frames, shadows, hands, desks, backgrounds, or decorative mockups unless the user asks for mockups.
- When the user asks for both raw and mockup screenshots, export raw screenshots first, then create mockup variants from those exact finals.
- If the user provides Play Store/App Store links or example folders, analyze visual patterns: composition, text density, background style, color palette, screenshot crop, device treatment, and platform conventions.
- Avoid misleading store assets. Do not invent UI states that imply unavailable features unless the user confirms the feature exists.
- Use transparent PNG for icons that require transparency. Use PNG or JPEG for store screenshots according to platform requirements and visual quality.
- Keep source prompts or generation notes in the campaign folder so later iterations can reuse the same direction.

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

## Icon Workflow

1. Locate existing icon/logo assets in the app project before generating from scratch.
2. Generate multiple concepts when the user has not chosen a visual direction.
3. Export icons in the required sizes and transparency formats for the target platform.
4. For Android notification and OneSignal small icons, simplify the mark into a single-color white silhouette with transparent background. Test that it remains recognizable at small sizes.
5. Name files clearly by platform, type, size, and variant.

## Implementation Rules

Only implement assets into the app after the user explicitly says to implement and identifies the chosen generated files or variant.

Before implementation:

- Inspect the existing project asset structure and naming conventions.
- Make focused edits and report changed files.
- For Flutter projects, place assets according to existing Android/iOS resource patterns and update manifests, notification metadata, or pubspec entries only when required.
- For OneSignal, configure the default notification icon resource only if the project already uses OneSignal or the user asks to add/configure it.

After implementation, run the relevant formatting, analysis, tests, or build checks available in the project when feasible.
