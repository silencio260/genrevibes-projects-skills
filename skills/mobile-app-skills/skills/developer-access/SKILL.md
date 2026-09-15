---
name: developer-access
description: "Reuse the kit developer unlock, device lists, action permissions, and ad test-mode controls."
---

# Developer access

Reuse `DeveloperAccessController`, `DeveloperUnlockGesture`, and
`DeveloperAdSwitches`. Apps configure shared behavior instead of writing another unlock.

## App choices

| Option | Effect |
|---|---|
| Omit overrides | Keep kit passcode, device handling, diagnostics, and premium simulation. |
| `enabled: false` | Disable kit developer access, including development-build grants. |
| `allowPasscode: false` | Disable passcode entry; retain listed-device access. |
| `passcode` | Replace the shared fallback. Blank keeps `DeveloperAccessDefaults.passcode`. |
| `actions` | Limit actions for all grants. |
| `passcodeActions` | Further limit passcode sessions, such as diagnostics only. |

Use `allows(DeveloperAction.diagnostics)` for developer UI and
`allows(DeveloperAction.premiumSimulation)` for simulated premium. Recheck on
access changes. `isGranted` alone does not authorize every action.

## Connect it

1. Initialize the controller with the app's store and config before ads.
   Supply the platform install marker if available for reinstall/lockout handling.
2. Resolve vendor identity and pass `vendorId` to `setDeviceId`. Lists contain
   `DeveloperDeviceHash` values, never raw IDs. Android app-set IDs and iOS vendor
   IDs can change; copy the hash from the installation actually being used.
   Do not promise one permanent identifier across all installs or distribution channels.
3. If using remote config, initialize `DeveloperAccessRemotePolicyBinder` before
   refresh and dispose it with the runtime. Env lists are comma-separated;
   remote lists are JSON arrays.
4. Wrap the chosen Settings target with `DeveloperUnlockGesture`. Use the app's
   colors through `DeveloperPasscodeTheme`. For PostHog, supply `protectContent`
   with `PostHogMaskWidget` so the passcode route is masked.
5. Pass the controller to `DevToolsHost`; follow [Kit Lab](../kit-lab/SKILL.md).
6. Load the shared ad switches once. Apply `allows(format)` at every load/show
   and inline view. Cancel their listeners and dispose the switches at shutdown.

The default gesture is seven taps. The default wrong-attempt limit is three.
A passcode grant lasts for the process; `lockSession()` revokes that grant
without removing a listed phone. Preserve kit lockout handling. Never log passcodes.
The shared passcode is compiled into the app; it is not backend authorization.

## Ad test mode

Pass initial test mode to the ad provider and follow access changes through
`AdTestModeProvider.setTestMode`. Development runs must remain on test inventory,
including when the app simulates an unlisted store-build phone.

Appodeal fixes test mode at SDK initialization. A later incompatible change
withholds inventory until relaunch. A passcode entered after SDK startup can
therefore hide ads for that session; list the phone for test mode on future
launches. Do not claim a session-only passcode survives relaunch.

Check disabled access, listed phones, passcode lockout, diagnostics-only grants,
and immediate revocation of simulated premium.

## Configuration examples and their meaning

The [integration file](../../references/integration-examples.md) includes
`makeDeveloperAccess` with complete imports. It limits passcode sessions to
diagnostics. To retain all kit defaults, omit `passcodeActions`; do not copy
that restriction automatically into every app.

```dart
// Config arguments, not a complete controller construction:
// Default behavior: only isDevelopmentBuild is required.
DeveloperAccessConfig(isDevelopmentBuild: isDevelopmentBuild);

// Listed phones still work, but passcode entry is disabled.
DeveloperAccessConfig(isDevelopmentBuild: isDevelopmentBuild, allowPasscode: false);

// No kit developer access, even in development builds.
DeveloperAccessConfig(isDevelopmentBuild: isDevelopmentBuild, enabled: false);
```

In these fragments `isDevelopmentBuild` is the app's computed build policy.
An environment flag has no effect unless the app reads it into this config.
The default passcode is `1234567`; a blank override preserves it. Defaults allow
both diagnostics and premium simulation. `actions` restricts every grant;
`passcodeActions` only narrows passcode sessions within that allowed set.

### Device recognition and lockout

The controller compares hashes from hardcoded, environment, and remote lists.
Pass the resolved vendor identity into `setDeviceId`; do not hash an advertising
ID as the access identity. Copy the displayed device hash from the installation
being registered, because sideload/store scope and reinstall behavior can differ.
Env lists use comma-separated hashes; remote configuration uses a JSON list.

Initialize with the available platform install marker so restored preferences
can be distinguished from a new install for lockout handling. The kit owns wrong
attempts, session grants, and lockout reset logic. Do not make a second counter
in Settings. Do not persist a successful passcode grant as a permanent premium flag.

### Connect every consumer

| Consumer | Check/input |
|---|---|
| Lab entry and developer pages | `allows(DeveloperAction.diagnostics)`; keep built-in page guards. |
| Simulated premium | `allows(DeveloperAction.premiumSimulation)` each time access is derived. |
| Ad provider at construction | Initial test mode from access/build policy. |
| Later ad-mode changes | `AdTestModeProvider.setTestMode`; preserve Appodeal relaunch limitation. |
| Inline/load/show placement | Shared `DeveloperAdSwitches.allows(format)` plus other ad eligibility. |
| Hidden entry | `DeveloperUnlockGesture` and its theme/mask hooks. |

Listen for access changes so already-visible UI updates and simulated premium
is revoked immediately. Register listener cancellation with the runtime scope.
A valid listed phone can retain its grant after `lockSession()` because that
method ends the passcode session, not the device registration.

### Manual behavior checks

Use an unlisted store-like installation for the gesture; a development build
may already be granted, so tapping does nothing. Keep test ads on during that
simulation. Check three wrong attempts, a correct attempt, diagnostics-only
access, locking the session, and removal from a remote list after refresh.
Do not interpret “Lab opens” as proof that premium simulation is authorized.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_developer_access](../../../../../packages/genrevibes_starter_kit/modules/devtools/genrevibes_developer_access/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/devtools/genrevibes_developer_access/lib/genrevibes_developer_access.dart).
- [genrevibes_device_identity](../../../../../packages/genrevibes_starter_kit/modules/device_identity/genrevibes_device_identity/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/device_identity/genrevibes_device_identity/lib/genrevibes_device_identity.dart).
- [genrevibes_remote_policy](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/lib/genrevibes_remote_policy.dart).
