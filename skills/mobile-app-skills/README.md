# Mobile app skills

Read only the skills relevant to the task. Start with [architecture](ARCHITECTURE_ANALYSIS.md)
and [kit compatibility](references/kit-compatibility.md) when changing integration.

## Portfolio baseline

New portfolio apps include Kit Lab, the developer section, feedback/contact
forms, rating, Android root exit prompt, ads, retention, analytics, onboarding,
IAP, remote config and session replay integration. Analytics is never
consent-gated and Firebase Analytics is never disableable; consent forms are
for ad networks only (see
[analytics](skills/analytics/SKILL.md#portfolio-rule-analytics-is-never-consent-gated)). The user's main feature brief
does not need to repeat these. Choose providers and product configuration per app;
keep collection/rollout and platform behavior explicit. See the
[baseline and integration map](ARCHITECTURE_ANALYSIS.md#11-guaranteed-portfolio-integrations).
For narrow changes to an existing app, preserve the requested scope.

Every app maintains its command recipes in its own `README.md` and
`docs/commands.md`, with Flutter run and build commands at the top. Follow
[command documentation](skills/command-documentation/SKILL.md) whenever creating
an app or changing its run/build, release, environment or tooling commands.

The portfolio localization target is
[40 languages and 58 initial locale options](skills/localization/references/portfolio-locales.md),
with independent language/country selection. Follow the
[shared-kit and app translation rollout plan](skills/localization/references/portfolio-rollout.md).
Shared behavior belongs in the kit; every app owns its actual strings, enabled
options and store assets. Package availability depends on the installed kit
revision; inspect current APIs rather than treating the dated rollout baseline
as the current inventory. Expose locales only after their readiness checks pass.

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
| [ads](skills/ads/SKILL.md) | Configure staged portfolio Appodeal network defaults and connect ad placements with premium, consent, test-mode, and pacing rules. |
| [ad-ctr-investigation](skills/ad-ctr-investigation/SKILL.md) | Investigate a high ad click-through rate: split clicks by network and format, time each click, and research the network before blaming placements or calling it invalid traffic. |
| [appodeal-browser-setup](skills/appodeal-browser-setup/SKILL.md) | Create an app's AdMob, Appodeal and Meta (FAN) entries in the owner's browser, link Meta to Appodeal, and wire Appodeal plus AdMob App Open into the app. |
| [analytics](skills/analytics/SKILL.md) | Connect selected analytics sinks, shared events, identity, and collection settings. |
| [analytics-extension-layer](skills/analytics-extension-layer/SKILL.md) | Add typed app-specific analytics methods on top of the shared pipeline. |
| [android-mediation-optimization](skills/android-mediation-optimization/SKILL.md) | Improve release DEX scores by auditing Appodeal/bridge consumer rules while preserving enabled networks. |
| [android-release-build-experiment](skills/android-release-build-experiment/SKILL.md) | Diagnose Android release build/startup failures, known R8 constructor issues, and the recorded partial shrinking experiment. |
| [android-signing](skills/android-signing/SKILL.md) | Configure Android release signing while preserving the app existing signing identity. |
| [app-icon-generation](skills/app-icon-generation/SKILL.md) | Create app icon concepts and compare them at launcher size. |
| [app-promotions](skills/app-promotions/SKILL.md) | Create and translate promotional screenshots, feature graphics and Play listing JSON; follow the [portfolio workflow](skills/app-promotions/references/play-store-localization.md) and clean locale-folder structure. |
| [app-rating](skills/app-rating/SKILL.md) | Ask for store reviews at every compliant moment: store sheet and Android review card in turn, portfolio timing, and store rules (no gating, no rewards). |
| [app-rename](skills/app-rename/SKILL.md) | Change a Flutter app display name or explicitly requested platform identity. |
| [auth](skills/auth/SKILL.md) | Connect neutral kit authentication and a selected adapter to app identity flows. |
| [branding](skills/branding/SKILL.md) | Apply chosen app icons, logos, and notification assets to platform resources. |
| [command-documentation](skills/command-documentation/SKILL.md) | Keep app README and docs command recipes complete and aligned, with Flutter run/build commands first. |
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
| [legal-pages](skills/legal-pages/SKILL.md) | Write, publish and record the app privacy policy and terms of use, and keep their links in env, docs and the store listing. |
| [local-notifications](skills/local-notifications/SKILL.md) | Schedule local notifications and daily campaigns; handle taps, timezones, campaign ownership, and post/open/opt-out analytics. |
| [localization](skills/localization/SKILL.md) | Plan and implement the 40-language portfolio target, regional/script variants, shared locale behavior, app-owned strings and localized store assets. |
| [logging](skills/logging/SKILL.md) | Connect structured kit logs and the shared Kit Lab recorder. |
| [navigation](skills/navigation/SKILL.md) | Connect kit screens and external actions to the app router. |
| [offline-caching](skills/offline-caching/SKILL.md) | Add feature-specific caching and offline behavior without duplicating kit storage. |
| [onboarding](skills/onboarding/SKILL.md) | Build onboarding as illustrated pages (one real illustration per page, found online or generated), with completion state and optional actions. |
| [tutorials](skills/tutorials/SKILL.md) | Build reusable in-app tutorials, feature walkthroughs and spotlight guides with independent progress and app-owned content/actions. |
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
| [splash-screen](skills/splash-screen/SKILL.md) | Build a minimal splash (logo, name, loading bar) on the kit splash flow, with bounded launch and optional launch ads. |
| [storage-migration](skills/storage-migration/SKILL.md) | Preserve saved state when replacing copied app code with kit modules. |
| [theming](skills/theming/SKILL.md) | Apply the app theme to shared kit UI without copying another app brand. |
| [tracking-retention](skills/tracking-retention/SKILL.md) | Reuse retention history, milestones, and targeting rules from genrevibes_engagement. |
| [starter-kit](starter-kit/SKILL.md) | Select and connect modular GenRevibes packages in a Flutter app. |

## Other guidance

- [Appodeal release optimization](references/android-appodeal-release-optimization.md):
  six version-scoped rule overrides, reflection protections, packaged-score gate,
  measured Lunaris results and remaining verification limits.
- [Portfolio Appodeal network defaults](references/appodeal-network-defaults.md):
  start with BidMachine/Bidon, verify test and live serving, then enable the
  17-adapter preset and five bridges; leave nine adapters for manual activation.
- [Android debug build performance](references/android-debug-build-performance.md):
  recorded daemon, cache, memory and repository settings, shared SDK/bridge
  handling, release shrinking and Shorebird toolchain compatibility.
- [Live ads in debug](references/live-ads-debugging.md): the live diagnostic
  Flutter command, current USB/wireless device selection and SDK mode verification.
- [Commit policy](../commit-policy/SKILL.md)
- [Firebase Gen 2 HTTP auth](../firebase-functions-v2-auth/SKILL.md)
- [Environment keys](references/environment-keys.md)

When updating skills, preserve useful detail and make the wording readable.
Include the steps, real files/APIs, dependencies, results, and ownership needed
to perform the task. Correct obsolete instructions against source. Keep
requirements, defaults, and app choices distinct; do not shorten a guide by
removing information its reader needs. Link substantial examples from the
relevant skill so they remain easy to find.
