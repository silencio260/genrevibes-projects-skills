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
6. Load the shared ad switches once, before the ad provider is constructed.
   Apply `allows(format)` at every load/show and inline view. Cancel their
   listeners and dispose the switches at shutdown.

The default gesture is seven taps. The default wrong-attempt limit is three.
A passcode grant lasts for the process; `lockSession()` revokes that grant
without removing a listed phone. Preserve kit lockout handling. Never log passcodes.
The shared passcode is compiled into the app; it is not backend authorization.

## Ad test mode

Pass initial test mode to the ad provider and follow later changes through
`AdTestModeProvider.setTestMode`. Take both from `DeveloperAdSwitches.servesTestAds`:
developer access means test inventory unless the developer asked for live
inventory on this phone. Listen to developer access changes **and** the
switches' `changes`, so the Live ads switch and a Kit Lab access change both
reach the provider. Development runs stay on test inventory by default,
including when the app simulates an unlisted store-build phone; only the
developer's own Live ads switch or the
[`ads_live_diagnostics` flag](../../references/live-ads-debugging.md) moves a run
to live inventory.

### Developer ad switches (starter kit)

`DeveloperAdSwitches` (genrevibes_developer_access) holds a developer's ad
controls for their own phone. They are remembered on the device, and apply only
while developer access is granted, so ordinary users are never affected:

| Control | API | Kit Lab › Ads |
|---|---|---|
| One format off | `setEnabled(format, enabled)`, `isSwitchedOff`, `allows` | One switch per format |
| Every format off | `setAllEnabled(enabled)`, `allSwitchedOff` | "Ads" |
| Real instead of test inventory | `setLiveInventory(live)`, `liveInventory`, `servesTestAds`, `restartRequired` | "Real ads", plus "Running now" |

Labels say what the phone gets: a switch that is on means the ads are on (or
real), off means off (or test). Show the effective state, not just the stored
choice. A run that forces real ads (a build flag) is passed to the constructor
as `liveInventoryForced`; `liveInventory` then reads true and the "Real ads"
switch is shown on and disabled, so it never claims test ads during a live run.
`servedTestAdsAtLaunch` records the mode the SDK started with, and
`restartRequired` tells the control to say "restart the app to apply".

An app may show the same controls in its own Settings › Developer, but must
call these methods rather than keep its own copy, so Lab and Settings change one
setting. Lunaris shows "Ads" and "Real ads" in its black-and-white developer
card through `sl<DeveloperAdSwitches>()`. A live-inventory change applies on the next launch
for Appodeal; say so wherever the control appears, and remind the developer not
to tap live ads on their own phone.

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
| Ad provider at construction | Initial test mode from `DeveloperAdSwitches.servesTestAds` (and any app run flag). |
| Later ad-mode changes | `AdTestModeProvider.setTestMode` on access changes and switch changes; preserve Appodeal relaunch limitation. |
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
