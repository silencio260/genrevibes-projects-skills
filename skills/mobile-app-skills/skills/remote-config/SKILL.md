---
name: remote-config
description: Firebase Remote Config for feature flags, A/B testing, and force update. Read before wiring remote config into an app — initialize() does not fetch, and an app missing the refresh() call has frozen config with no symptom.
---

# Remote Config

## Overview

Remote Config uses Firebase Remote Config via the starter kit for feature flags, A/B testing, force update checks, and dynamic configuration.

Two calls, and they are not interchangeable: `initialize()` registers defaults
and reads previously activated values, `refresh()` fetches. **Read
"Non-negotiable: something must call `refresh()`" below before wiring this into
any app** — the failure mode is silent and was live in Story Saver until
2026-09-10.

## Canonical Template

When the user asks for a "remote config temp", "remote config template", or a Firebase Remote Config starter template, use:

```text
agents/skills/mobile-app-skills/skills/remote-config/remote_config_template.json
```

This file is the canonical Firebase Remote Config template for GenRevibes apps. It is based on a Firebase Console export and includes the standard ad timing and app-open ad flags used by the starter kit, plus the **Session Replay Group** — `session_replay_enabled`, `session_replay_percent`, `session_replay_mask_text` and `session_replay_mask_images`, read by `SessionReplayPolicyKeys` in `genrevibes_remote_policy`. Copy it into the target app workflow as `remote_config_template.json`, then adjust app-specific values before importing or publishing in Firebase Remote Config.

The defaults in the template match the keys' bundled defaults on purpose. A key whose console value differs from the code default is a value someone chose; a key that matches is indistinguishable from one nobody ever set, and the Starter Kit Lab's per-key origin is the only way to tell them apart. Importing this template is what makes the replay rollout adjustable at all — until the keys exist in the console there is nothing to turn down.

Keep parameter keys stable unless the app code and starter kit readers are updated together.

## Non-negotiable: something must call `refresh()`

**`initialize()` does not fetch. An app that never calls `refresh()` has frozen
remote config, and nothing anywhere says so.**

This is the single easiest gap to leave open, because every symptom of it looks
like something else:

- On a device that fetched once months ago, every key is stuck at whatever was
  activated then. Changing a value in the Firebase Console appears to do
  nothing, and the obvious conclusion — "the key name is wrong", "the value did
  not publish" — is wrong.
- On a **fresh install, every key sits at its bundled default forever.** No
  rollout percentage, no kill switch, no ad pacing change ever reaches a new
  user. This is the expensive one: the users you most want to configure are the
  ones who never get configured.
- Module health reports `ready`, because initialization genuinely succeeded.
  Nothing is broken. Nothing is logged. There is no failure to find.

`RemoteConfigCoordinator.initialize()` only registers defaults and reads what a
previous run activated. `refresh()` is the only thing that calls
`fetchAndActivate()`.

### The wiring

```dart
// Startup path: initialize before anything reads a value.
await remoteConfig.initialize();

// ... compose the modules that read config ...

// Then fetch, unawaited. A fetch is a network round trip and must never sit
// between launch and the first frame; the binders are already listening, so
// whatever arrives is applied when it arrives.
unawaited(remoteConfig.refresh());
```

Order matters both ways:

- `initialize()` **is** awaited, and belongs before any consumer is built. A
  value read before initialization is the bundled default, and anything a
  provider SDK fixes at setup time — session-replay masking, for instance —
  cannot be corrected afterwards. Bound it with a timeout: it is on the
  critical path.
- `refresh()` is **never** awaited on the startup path. Its results reach
  features through `coordinator.changes` and the policy binders, not through
  the return value.

Firebase throttles fetches itself
(`PortfolioRemoteConfigSettings.minimumFetchInterval`, 12 hours in release), so
calling `refresh()` on every launch costs nothing on most of them. Do not add
throttling of your own on top.

### Verifying it, in ten seconds

Remote config that is never fetched cannot be caught by a test — the
coordinator behaves correctly either way. Check it by inspection:

```bash
grep -rn "\.refresh()" lib/bootstrap/
```

No hit means the gap is open. Then confirm on device: **Starter Kit Lab →
Remote config** shows a per-key origin. If every key reads `defaultValue` on a
device that has been online, nothing is fetching. `remote` is what a working
app shows.

## Implementation

```dart
final remoteConfig = sl<RemoteConfigCoordinator>();

// Read the current snapshot. Typed, validated, and safe before any fetch:
// an invalid or missing value falls back to the key's bundled default.
final snapshot = remoteConfig.current;
final bool featureEnabled = snapshot.read(AppKeys.newFeatureEnabled);
final int minVersion = snapshot.read(AppKeys.minAppVersion);

// React to later fetches rather than re-reading on a timer.
remoteConfig.changes.listen(applySnapshot);
```

Prefer a **policy binder** (`AdsRemotePolicyBinder`,
`SessionReplayRemotePolicyBinder`) over reading keys at call sites: the binder
applies the current snapshot at startup and follows every change after, so a
value that lands mid-session takes effect without a relaunch.

### Force Update Check

```dart
final minVersion = configRepo.getInt('min_app_version');
final currentVersion = /* get from package_info */;
if (currentVersion < minVersion) {
  showForceUpdateDialog();
}
```

## Interaction Map

- **Content Locking** → Feature flags for premium features
- **Ads** → Dynamic ad frequency settings
- **Paywall** → A/B test paywall designs
- **Splash** → Force update check on launch

## Checklist

- [ ] Remote Config defaults set in Firebase Console
- [ ] `remote_config_template.json` used as the starting Firebase Remote Config template
- [ ] Session Replay Group imported, if the app records replay — the rollout cannot be turned down until the keys exist in the console
- [ ] **`refresh()` is called on the startup path, unawaited** — `grep -rn "\.refresh()" lib/bootstrap/` returns a hit
- [ ] **`initialize()` is awaited before any consumer is composed**, and bounded by a timeout
- [ ] Verified on device: Starter Kit Lab → Remote config shows keys with origin `remote`, not `defaultValue`
- [ ] Every remote value reaches its feature through `changes` or a policy binder, not a one-time read
- [ ] Feature flags used for gradual rollouts
- [ ] Force update version check implemented
