---
name: exit-prompt
description: "Configure shared Android root-back behavior without duplicating exit dialogs."
---

# Exit prompt

Use `ExitGuard` around the root screen. The app supplies current config, labels,
features, offers, and callbacks; nested routes retain normal Back behavior.

- Read policy when Back is pressed so access and remote settings are current.
- Shared styles include features/offer sheets, confirmation, double tap, none,
  and ad variants. Missing required content falls back to confirmation.
- Keep the default readable exit action. Do not recommend dimming Exit to steer
  taps toward an ad or an offer.
- Add ads only when deliberately requested and compatible with current platform
  and network rules. The existence of an ad style is not a reason to enable it.
- If an ad style is used, load only when selected and eligible, reserve its space,
  and apply the common premium/developer/provider gates.
- Pass the app's exit configuration to Kit Lab for preview. Preview must report
  the action without closing the real app.

Use `onShown` and `onResult` once for analytics. Check rapid Back presses,
missing content, changed premium state, and navigation to a featured destination.
Do not force Android exit behavior onto iOS.

## Place the guard at the actual navigation root

Wrap the screen that owns Android root-back behavior, not every nested page.
A detail page should return to its parent normally. Supply current configuration
through the supported callback/state mechanism so changes in entitlements or
remote policy are reflected on the next Back action.

For each chosen style, provide the required content and callbacks. A feature
sheet needs destinations that exist in this app; an offer needs the intended
purchase flow; an ad variant needs an integrated eligible placement. Rely on the
shared fallback for missing content instead of showing an empty sheet.

Prevent concurrent prompts while one is active. When a user chooses a feature,
close the prompt and navigate once through the app router. When previewed from
Kit Lab, report the chosen action without invoking the real platform exit.
Keep analytics at the shared shown/result callbacks so every button does not
send duplicate outcome events.

When adapting another app, choose the style, copy, destinations, and platform
scope. Reuse the guard's behavior. Do not copy a media-saving app's offers or
Android exit behavior into unrelated products or iOS.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_exit_prompt](../../../../../packages/genrevibes_starter_kit/modules/exit_prompt/genrevibes_exit_prompt/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/exit_prompt/genrevibes_exit_prompt/lib/genrevibes_exit_prompt.dart).
- [genrevibes_remote_policy](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/remote_config/genrevibes_remote_policy/lib/genrevibes_remote_policy.dart).
