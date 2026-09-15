---
name: deep-linking
description: "Handle verified external links and route them through app access checks."
---

# Deep links

Use the app's selected link integration for Android App Links and iOS Universal
Links. Do not add Firebase Dynamic Links to new work; see the
[Firebase shutdown and migration guide](https://firebase.google.com/support/dynamic-links-faq).

1. Define accepted schemes, hosts, paths, and parameters. Parse into known app
   destinations; never navigate directly from an arbitrary URL string.
2. Configure platform association files and native declarations for the actual
   package/bundle IDs and domains. Follow current official platform setup.
3. Handle both initial and live links. Delay navigation until startup and
   required auth/onboarding are complete.
4. Apply resource ownership and feature-access checks after parsing. A link is
   not authorization to view an object.
5. Deduplicate repeated deliveries and provide a clear unsupported-link fallback.
6. Cancel subscriptions with their owner.

Outgoing store/share/support links use `genrevibes_app_links`; that is separate
from receiving incoming links. Check cold start, warm start, malformed links,
logged-out users, and missing content.

## Parse links into app-owned destinations

Create a parser at the app boundary that accepts only the intended scheme/host,
path shapes, and argument types. Its output should be a known destination with
validated IDs, not a raw route string. Keep resource access checks in the owning
feature/backend after parsing.

Connect the selected plugin's initial-link and live-link mechanisms once in the
runtime/navigation owner. Deduplicate deliveries according to the integration's
behavior; do not register listeners in every destination screen. Hold an intended
destination until the router and session are ready, then recheck current access.

Platform association files must identify the actual app identity and domain.
Inspect the existing Android manifest and iOS entitlements alongside the hosted
association configuration. Source edits alone do not prove the remote domain
serves the required files or that an installed OS verified them.

Handle unknown paths, malformed IDs, deleted content, and a logged-out user with
clear app states. If the user must sign in first, preserve the intended destination
through that flow without bypassing ownership checks afterward. Outgoing share
links should use the same documented URL contract.
