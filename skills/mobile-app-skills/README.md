# Mobile app skills

Read only the skills relevant to the task. Start with [architecture](ARCHITECTURE_ANALYSIS.md)
and [kit compatibility](references/kit-compatibility.md) when changing integration.

## Portfolio baseline

New portfolio apps include Kit Lab, the developer section, feedback/contact
forms, rating, Android root exit prompt, ads, retention, analytics, onboarding,
IAP, remote config and session replay integration. The user's main feature brief
does not need to repeat these. Choose providers and product configuration per app;
keep collection/rollout and platform behavior explicit. See the
[baseline and integration map](ARCHITECTURE_ANALYSIS.md#11-guaranteed-portfolio-integrations).
For narrow changes to an existing app, preserve the requested scope.

- [Create an app](projects/new/SKILL.md)
- [Adopt a feature in an existing app](projects/refactor/SKILL.md)
- [Upgrade the kit](projects/kit-upgrade/SKILL.md)
- [Replace a provider](projects/replace-provider/SKILL.md)
- [Select kit packages](starter-kit/SKILL.md)

## Start with the detail needed for the task

- [Architecture and ownership](ARCHITECTURE_ANALYSIS.md): portfolio requirements,
  shared integrations/constants, current Story Saver wiring, folder layout,
  BLoC/GetIt/Either pattern, startup and dependency lifetime.
- [Complete feature walkthrough](references/feature-walkthrough.md): twelve Dart
  files covering a preference from its screen through use cases to shared storage.
- [Shared integration examples](references/integration-examples.md): complete
  functions for consent/startup, developer access, forms, purchases, remote config,
  permissions, notifications, and Lab, with the caller's remaining responsibilities.
- [Working conventions](references/working-conventions.md): names, entities/models,
  networking, code generation, and a practical feature implementation sequence.

The example files explain wiring; they are not a replacement bootstrap to copy
wholesale. Follow the relevant feature skill for product decisions and native setup.

## Host repository entry point

A nested AGENTS.md does not automatically govern files outside its directory.
In a host app, keep a short root AGENTS.md that links to
`agents/AGENTS.md` and this index. Preserve existing root instructions.
If the host uses another checkout path, adjust these links.

Shared forms mean the kit's feedback/contact form. General forms remain app-owned.
Kit Lab and remote config provide shared developer controls; no separate control
panel implementation is needed for each app.

## Skills

| Skill | Use it for |
|---|---|
| [kit-upgrade](projects/kit-upgrade/SKILL.md) | Upgrade a pinned starter kit revision and migrate the affected app integrations. |
| [new](projects/new/SKILL.md) | Create a Flutter app using selected GenRevibes starter kit features. |
| [refactor](projects/refactor/SKILL.md) | Adopt starter kit features in an existing app without replacing unrelated architecture. |
| [replace-provider](projects/replace-provider/SKILL.md) | Replace a kit provider adapter while preserving the shared feature interface. |
| [ads](skills/ads/SKILL.md) | Connect ad placements and provider-specific views with premium, consent, test-mode, and pacing rules. |
| [analytics](skills/analytics/SKILL.md) | Connect selected analytics sinks, shared events, identity, and collection settings. |
| [analytics-extension-layer](skills/analytics-extension-layer/SKILL.md) | Add typed app-specific analytics methods on top of the shared pipeline. |
| [android-signing](skills/android-signing/SKILL.md) | Configure Android release signing while preserving the app existing signing identity. |
| [app-icon-generation](skills/app-icon-generation/SKILL.md) | Create app icon concepts and compare them at launcher size. |
| [app-promotions](skills/app-promotions/SKILL.md) | Create app promotional graphics using truthful screenshots and relevant style references. |
| [app-rating](skills/app-rating/SKILL.md) | Reuse rating eligibility, saved prompt state, and store/feedback routing. |
| [app-rename](skills/app-rename/SKILL.md) | Change a Flutter app display name or explicitly requested platform identity. |
| [auth](skills/auth/SKILL.md) | Connect neutral kit authentication and a selected adapter to app identity flows. |
| [branding](skills/branding/SKILL.md) | Apply chosen app icons, logos, and notification assets to platform resources. |
| [chat-ai](skills/chat-ai/SKILL.md) | Implement app-owned AI chat, streaming, history, and backend integration. |
| [content-locking](skills/content-locking/SKILL.md) | Apply shared entitlement rules and app-owned quota or reward access to a feature. |
| [crashlytics](skills/crashlytics/SKILL.md) | Connect kit crash reporting to Firebase Crashlytics and app error hooks. |
| [deep-linking](skills/deep-linking/SKILL.md) | Handle verified external links and route them through app access checks. |
| [developer-access](skills/developer-access/SKILL.md) | Reuse the kit developer unlock, device lists, action permissions, and ad test-mode controls. |
| [env-config](skills/env-config/SKILL.md) | Configure compile-time app settings and reusable IDE launch templates. |
| [error-handling](skills/error-handling/SKILL.md) | Translate kit and provider failures into useful app states without hiding errors. |
| [exit-prompt](skills/exit-prompt/SKILL.md) | Configure shared Android root-back behavior without duplicating exit dialogs. |
| [feedback](skills/feedback/SKILL.md) | Reuse the kit feedback and contact forms with a selected delivery provider. |
| [firebase-infrastructure](skills/firebase-infrastructure/SKILL.md) | Configure selected Firebase services and separate app backend data from kit adapters. |
| [gdpr-compliance](skills/gdpr-compliance/SKILL.md) | Connect regional consent prompts and privacy controls using the kit consent providers. |
| [git-submodules](skills/git-submodules/SKILL.md) | Inspect and update pinned agents and starter kit submodules without losing local changes. |
| [iap](skills/iap/SKILL.md) | Connect purchases, restores, entitlement updates, and feature access through the kit IAP interfaces. |
| [ide-optimization](skills/ide-optimization/SKILL.md) | Reduce irrelevant IDE indexing without hiding active source problems. |
| [image-generation](skills/image-generation/SKILL.md) | Implement an app feature for image generation, results, and history through its backend. |
| [immersive-ui](skills/immersive-ui/SKILL.md) | Configure edge-to-edge layout and optional kit navigation-bar controls. |
| [kit-lab](skills/kit-lab/SKILL.md) | Connect the shared developer section, Kit Lab, logs, module health, and controls. |
| [local-notifications](skills/local-notifications/SKILL.md) | Schedule local notifications and daily campaigns; handle taps, timezones, campaign ownership, and post/open/opt-out analytics. |
| [localization](skills/localization/SKILL.md) | Localize app and shared kit labels using the app existing translation system. |
| [logging](skills/logging/SKILL.md) | Connect structured kit logs and the shared Kit Lab recorder. |
| [navigation](skills/navigation/SKILL.md) | Connect kit screens and external actions to the app router. |
| [offline-caching](skills/offline-caching/SKILL.md) | Add feature-specific caching and offline behavior without duplicating kit storage. |
| [onboarding](skills/onboarding/SKILL.md) | Build a shared onboarding flow with app content, completion state, and optional actions. |
| [paywall](skills/paywall/SKILL.md) | Present hosted or app-owned paywalls using the existing IAP provider. |
| [permissions](skills/permissions/SKILL.md) | Request and recheck app permissions through the kit permission coordinator. |
| [profile](skills/profile/SKILL.md) | Implement app-owned profile data using the selected database adapter. |
| [project-structure](skills/project-structure/SKILL.md) | Organize Flutter app code while keeping shared kit packages separate. |
| [push-notifications](skills/push-notifications/SKILL.md) | Connect OneSignal or another push provider with identity, permission, tap routing, and open/opt-out analytics. |
| [quota-rate-limiting](skills/quota-rate-limiting/SKILL.md) | Implement app-owned usage limits with authoritative backend enforcement. |
| [remote-config](skills/remote-config/SKILL.md) | Connect typed remote configuration, refresh, shared policy binders, and Kit Lab controls. |
| [runtime-setup](skills/runtime-setup/SKILL.md) | Connect kit modules with bounded startup, deferred prompts, cleanup, and retry. |
| [session-replay](skills/session-replay/SKILL.md) | Configure shared replay rollout, masking, overrides, and SDK recording state. |
| [settings](skills/settings/SKILL.md) | Build app settings from shared kit rows and app-owned state and callbacks. |
| [shorebird](skills/shorebird/SKILL.md) | Prepare Shorebird releases and patches for an explicitly selected app version. |
| [splash-screen](skills/splash-screen/SKILL.md) | Use the kit splash flow for bounded launch presentation and optional launch ads. |
| [storage-migration](skills/storage-migration/SKILL.md) | Preserve saved state when replacing copied app code with kit modules. |
| [theming](skills/theming/SKILL.md) | Apply the app theme to shared kit UI without copying another app brand. |
| [tracking-retention](skills/tracking-retention/SKILL.md) | Reuse retention history, milestones, and targeting rules from genrevibes_engagement. |
| [starter-kit](starter-kit/SKILL.md) | Select and connect modular GenRevibes packages in a Flutter app. |

## Other guidance

- [Commit policy](../commit-policy/SKILL.md)
- [Firebase Gen 2 HTTP auth](../firebase-functions-v2-auth/SKILL.md)
- [Environment keys](references/environment-keys.md)

When updating skills, preserve useful detail and make the wording readable.
Include the steps, real files/APIs, dependencies, results, and ownership needed
to perform the task. Correct obsolete instructions against source. Keep
requirements, defaults, and app choices distinct; do not shorten a guide by
removing information its reader needs. Link substantial examples from the
relevant skill so they remain easy to find.
