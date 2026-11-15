# Release and product checks

Select the checks that correspond to the app's actual features and platform.
Read the linked implementation skills when their details affect the judgment.
Derive OS/store requirements from current official sources and the candidate;
do not copy another audit's SDK targets, score floors or dates.

## Core journey and startup

- Trace first install, returning install, cold start, ordinary resume, external
  entry/deep link and upgrade. Verify that onboarding, tutorial, rating, update,
  default-app and permission prompts respect saved progress and do not compete.
- Check bounded bootstrap, optional provider failure, initialization races and
  recovery. Include time spent before the first Flutter frame and after the splash.
  Do not call configured timeout limits measured startup latency.
- Confirm that resume does not unintentionally restart onboarding or cold-start
  monetization. Verify any deliberately persistent loading overlay exits on failure.
- Follow one successful core action and its failure/cancellation alternatives.
  Check empty, unsupported, offline and permission-denied states with useful recovery.

Use [runtime setup](../../runtime-setup/SKILL.md),
[splash](../../splash-screen/SKILL.md), [onboarding](../../onboarding/SKILL.md),
[tutorials](../../tutorials/SKILL.md) and [deep linking](../../deep-linking/SKILL.md).

## Long-running work, state and storage

- Draw or list the reachable state transitions for asynchronous work. Check that
  preflight failures, retries, system interruptions and finalization can persist
  their intended states. Watch for repeated dispatch of a task whose failure was
  rejected by its state guard.
- Inspect pause, cancel, retry, removal and replacement while each phase is active.
  Verify one owner per operation, truthful return values, bounded backoff and
  cancellation of timers/subscriptions/processes on every completion path.
- Examine the gap between external side effects and local commit: file publication,
  uploads, payments, submissions and notifications. Use idempotency or reconciliation
  where interruption could create duplicates. A terminal-state guard alone does not
  undo an already completed side effect.
- Check process death, background restrictions, force-stop, reboot and package upgrade
  separately; their recovery contracts differ. Confirm required foreground-service
  types, start restrictions, notification handling and timeout cleanup on supported OSs.
- Verify active network constraints, not just the network at enqueue/start. Check
  offline transitions, metered data, stalled work and optional backend fallbacks.
- Review free-space checks for temporary plus final copies and unknown-size work;
  destination permission revocation, failed-copy cleanup and orphan reconciliation;
  record-only versus media deletion; unique names and concurrent publication.
- Inspect schema/configuration/credential migrations and interrupted migrations.
  Preserve user media and settings. Check versioned replacement of bundled assets
  or engines on existing installs; new-install success does not establish upgrade success.

Use [error handling](../../error-handling/SKILL.md),
[storage migration](../../storage-migration/SKILL.md),
[permissions](../../permissions/SKILL.md) and [offline caching](../../offline-caching/SKILL.md).

## Security, privacy and backend

- Check exported components, deep-link validation, permission scope, WebView trust
  behavior, TLS/cleartext policy and release/debug differences. Inspect the packaged
  configuration when available, including permissions introduced by dependencies.
- Trace credentials and sensitive content through storage, backup/device transfer,
  temporary materialization, logs, crash reports, analytics, replay and user exports.
  Check redaction and cleanup; do not copy private values into audit artifacts.
- Inspect backend authentication and authorization, client integrity validation,
  app/project/certificate matching, quotas, rate/cost limits and input validation.
  Client flags alone do not enforce a server-side limit or entitlement.
- Treat absent backend source as a scope limit; inspect authorized deployed settings
  and observable behavior where accessible. A public health endpoint does not prove
  an authenticated extraction, generation, payment or account request works.
- Compare the exact shipped SDKs/data paths with current published policy pages,
  in-app disclosures and store forms. Verify external destinations, not just local
  policy text. Distinguish technical evidence and policy concerns from legal certification.

Use [Firebase infrastructure](../../firebase-infrastructure/SKILL.md),
[environment configuration](../../env-config/SKILL.md),
[logging](../../logging/SKILL.md), [legal pages](../../legal-pages/SKILL.md) and
[quota enforcement](../../quota-rate-limiting/SKILL.md).

## Playback and other native features

- For media, verify supported formats/codecs, corrupt or missing files, seek/resume,
  audio focus, headset disconnection, Bluetooth actions, orientation and fullscreen.
  Check background/lock behavior against the actual product promise.
- For launchers, verify home-role assignment, package changes, icon/app inventory,
  workspace persistence and ordinary resume. For capture/generation/auth features,
  exercise their actual permissions, cancellations, limits and recovery instead.
- Check platform minimums, native bridges and lifecycle cleanup. A widget test with
  mocked channels cannot establish native behavior or vendor-device compatibility.

## UI, accessibility and performance

- Review small/large screens, insets/edge-to-edge, keyboard, text scaling, TalkBack,
  focus traversal, contrast, reduced motion and only the locales exposed by the app.
- Check that destructive actions and recovery messages state the actual consequence.
  Distinguish slow work from a frozen interface; handle progress and controls honestly.
- Match a representative device matrix to supported OSs, vendor behavior, low memory
  and the target audience. Do not require every possible device to approve a small change.
- Measure startup, jank, memory growth, background work, battery/network use and
  concurrency where relevant. Include ads/replay in the measurement. Distinguish a
  source-level performance risk from a measured regression or an arbitrary soak duration.

Use [immersive UI](../../immersive-ui/SKILL.md),
[localization](../../localization/SKILL.md) and [theming](../../theming/SKILL.md).

## Packaging, distribution and operations

- Verify version/build numbers, app IDs and intended signing identity for the actual
  distribution route. Check required environment values safely. Local signing-file
  absence is not a production failure if the release system securely supplies it.
- Inspect the signed candidate, supported ABIs/native libraries, merged manifest,
  release-only shrinking/reflection behavior, symbols/mappings and artifact size.
  Use the app's real gate thresholds; never edit scores or weaken checks to pass.
- Check current store warnings against the artifact/version they refer to. Do not
  claim source changes fixed a Play warning without a new packaged result.
- Resolve dependency compatibility and notices/source obligations from the actual
  graph and packaged components. A manually maintained dependency list can be incomplete.
- Check privacy/support/store links, listing identity, release monitoring and a
  practical rollout/recovery plan. Separate first-release setup from an update.
  A missing optional automation or deferred CI is not itself a release blocker.

Use [Android signing](../../android-signing/SKILL.md),
[release build diagnostics](../../android-release-build-experiment/SKILL.md),
[mediation optimization](../../android-mediation-optimization/SKILL.md),
[crash reporting](../../crashlytics/SKILL.md) and
[command documentation](../../command-documentation/SKILL.md).
