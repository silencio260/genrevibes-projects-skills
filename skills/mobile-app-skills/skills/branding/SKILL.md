---
name: branding
description: "Apply chosen app icons, logos, and notification assets to platform resources."
---

# Branding assets

Inspect the app's current assets and generator configuration. Preserve its brand;
do not copy the former chatbot's black orbital icon or another app's artwork.

1. Use the chosen source asset. For new concepts, follow
   [app icon generation](../app-icon-generation/SKILL.md).
2. Keep the full-size store/iOS icon separate from Android adaptive foreground
   and background layers. Inspect mask previews so the main mark is not clipped.
3. Read options supported by the installed icon generator. Do not use invented
   inset keys or assume a fixed padding percentage fits every mark.
4. Use a real alpha channel for transparent logos. Do not erase every black pixel
   to remove a background; black may be part of the mark.
5. If notifications use the mark, provide a simplified white silhouette with
   transparent background and the configured Android resource name/densities.
   Do not add OneSignal just to use its conventional icon filename.
6. Regenerate only affected resources and inspect the resulting platform files.
   Match current official store requirements for final export.

Apply selected assets when requested; concept generation alone does not choose
a new brand. Check launcher masks, notification appearance, and splash layout.
Build/device checks remain subject to repository rules.

## Trace the source asset to every generated resource

Locate the current generator configuration and the native resources it controls.
Record the selected master image and which outputs need updating: launcher,
adaptive foreground/background, notification icon, in-app logo, or splash image.
These outputs serve different purposes and need not use identical flattened art.

Use the installed generator's documented options, preserving unrelated resource
names and platform settings. Keep a reproducible source asset and configuration
so the next app update can regenerate the same resources. Do not hand-edit a
generated file while leaving its generator configured to overwrite it later.

Inspect generated assets under their expected masks and backgrounds. A white
notification silhouette should remain a silhouette with transparency; a full-color
launcher image is not a substitute. Check that native configuration references
the generated resource name actually present.

Summarize the source selected and resource groups changed. Distinguish static
asset inspection from a device launcher/notification check, and do not run a
build merely to complete the asset update.
