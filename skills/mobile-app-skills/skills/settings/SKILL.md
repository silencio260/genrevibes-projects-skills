---
name: settings
description: "Build app settings from shared kit rows and app-owned state and callbacks."
---

# Settings

Use `SettingsList`, `SettingsTile`, `SettingsAction`, `SettingsToggle`, and
`SettingsInfo` from `genrevibes_settings`. The app supplies sections, labels,
state, and callbacks inside its existing screen or tab.

Connect only available features: purchases/restore, notifications, theme,
language, feedback, rating, sharing, and privacy options. Read each feature's
skill before wiring its callback. Disabled or unconfigured actions need a clear
explanation rather than a dead button.

Use `genrevibes_app_links` and its launcher adapter for store, support, and share
links. Supply each platform's URLs. Handle a missing configuration result.

Use [developer access](../developer-access/SKILL.md) for hidden entry and action
grants. Use [Kit Lab](../kit-lab/SKILL.md) for shared diagnostics. A debug flag
alone does not describe listed phones in release builds or restricted grants.

Do not reset all preferences from a generic Settings action. Reset only the
named feature's state. Keep premium simulation separate from real purchases.
Check that toggles follow real state, asynchronous failures remain visible,
and developer actions disappear or stop working when access is revoked.

## Build a screen from shared rows and real feature state

Keep the settings route in the app's existing feature folder. Its BLoC or
controller reads current app preferences and service state; `SettingsList` and
its rows render that state and call the supplied actions. The row widgets do not
initialize purchases, save preferences, or register runtime services for you.

Use this division when adding a row:

| Row | State/action owner |
|---|---|
| Theme or language toggle | App preference use case and current theme/locale state. |
| Restore purchases | Existing IAP provider, with busy and failure handling. |
| Notification controls | Permission/subscription state and the app's campaign service. |
| Contact/support | Shared feedback page or the configured app-links launcher. |
| Privacy choices | Existing consent provider's supported privacy-options flow. |
| Developer section | Shared access grants and the existing Kit Lab host. |

For a persisted toggle, disable conflicting changes while saving. Either update
after success or implement a deliberate optimistic update with rollback; do not
leave the switch showing a value that failed to save. The
[worked feature](../../references/feature-walkthrough.md) contains this complete
BLoC/repository/storage path.

For an asynchronous action, prevent repeated taps and present cancellation,
failure, and success accurately. Restore completing does not guarantee an active
subscription. A support URL launch failing does not mean a message was sent.

Keep destructive controls specific: “Reset onboarding” calls that controller's
reset; it must not clear identity, purchase state, or all preferences. Developer
rows should react to revoked access, and the action itself should check its grant
as well as hiding its entry point.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_settings](../../../../../packages/genrevibes_starter_kit/modules/settings/genrevibes_settings/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/settings/genrevibes_settings/lib/genrevibes_settings.dart).
- [genrevibes_app_links](../../../../../packages/genrevibes_starter_kit/modules/app_links/genrevibes_app_links/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/app_links/genrevibes_app_links/lib/genrevibes_app_links.dart).
- [genrevibes_app_links_launcher](../../../../../packages/genrevibes_starter_kit/modules/app_links/genrevibes_app_links_launcher/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/app_links/genrevibes_app_links_launcher/lib/genrevibes_app_links_launcher.dart).
