---
name: gdpr-compliance
description: "Connect regional consent prompts and privacy controls using the kit consent providers."
---

# Consent and privacy controls

Use `ConsentGate` with the selected provider. Appodeal uses
`AppodealConsentProvider`; a direct AdMob integration can use the UMP adapter.

1. Register consent before ads in deferred startup, after a visible frame.
2. For the portfolio continue-on-error behavior, use an eight-second budget on
   the consent provider, gate, and module registration, with `failOpen: true`.
3. Let the SDK determine whether a form is required. Do not force a form on every
   user or infer region from language, locale, or a hand-written country list.
4. If consent fails or times out, let ads initialization and the app continue.
   Preserve the real consent snapshot. Do not mark consent granted or not required
   to unblock startup, and do not add another app wait on `canRequestAds`.
5. Keep the SDK's actual consent signals intact. SDK decisions and ad fill still
   affect whether an ad appears; the app's timeout does not guarantee inventory.
6. Expose `showPrivacyOptions()` when `snapshot.privacyOptionsRequired` is true.
   Use debug preview/reset only for deliberate diagnostics, never normal startup.

Native forms can remain visible after a Dart timeout. Handle that limitation
without repeatedly opening forms or blocking the app's recovery path.

Consent in this portfolio covers ads only. Analytics is never consent-gated:
collection is a condition of using the app, disclosed in its privacy policy,
and Firebase Analytics cannot be turned off at all. Do not extend an ad
consent answer to `AnalyticsPipeline` or session replay, and never add an
analytics opt-out — see the portfolio rule in
[analytics](../analytics/SKILL.md#portfolio-rule-analytics-is-never-consent-gated). Describe actual SDKs,
permissions, storage, and recording in privacy documentation; this skill does
not certify legal compliance.

Check required, not-required, failed, and timed-out paths. Keep their states
separate in diagnostics.

## Exact setup and state handling

The example `makeAppodealConsent` in
[integration examples](../../references/integration-examples.md) passes
`timeout: Duration(seconds: 8)` to both `AppodealConsentProvider` and `ConsentGate`,
and `failOpen: true` to the gate. `makeRuntime` also gives the deferred consent
registration eight seconds. The gate initializes its provider; do not separately
register both as unrelated startup steps.

Use the app key for the actual platform. With Appodeal mediation, check the
native AdMob app identifier and configured consent messages where that demand
integration requires them. A sample identifier from another app cannot locate
this app's consent configuration.

| SDK result | App behavior |
|---|---|
| Form required | Give the SDK its normal opportunity to present the form before ads start. |
| Not required | Do not show a custom replacement form; continue. |
| Prior usable answer | Preserve it and let the SDK decide whether it needs updating. |
| Request/form failure | Record degraded/failure information; release startup after the attempt. |
| Timeout | Release startup; do not pretend the SDK form was dismissed or consent was granted. |

`failOpen` describes what the app does when the attempt fails. It does not change
the user's answer. Do not write a fabricated granted/notRequired snapshot or
clear the SDK's consent preferences to force ads to load.

### Settings privacy entry

Read `gate.snapshot.privacyOptionsRequired`. Show the privacy-options action
when required and call `gate.showPrivacyOptions()`. Handle its returned result
without rerunning the entire bootstrap. Follow snapshot changes if the settings
screen is already visible.

### Debugging a missing form

First inspect module health, the platform key, native app identifier, and SDK
regional/form status. A missing form outside applicable regions is expected.
The Lab preview is a deliberate diagnostic path; it is not the normal startup
path. A preview can write real SDK consent state, so record what was previewed
and reset only when intentionally testing again. Never force EEA debug settings
for all production users.

Do not promise that continuing initialization guarantees an ad. This removes an
app-created indefinite wait; it does not bypass SDK inventory decisions.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_consent](../../../../../packages/genrevibes_starter_kit/modules/consent/genrevibes_consent/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/consent/genrevibes_consent/lib/genrevibes_consent.dart).
- [genrevibes_consent_appodeal](../../../../../packages/genrevibes_starter_kit/modules/consent/genrevibes_consent_appodeal/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/consent/genrevibes_consent_appodeal/lib/genrevibes_consent_appodeal.dart).
- [genrevibes_consent_ump](../../../../../packages/genrevibes_starter_kit/modules/consent/genrevibes_consent_ump/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/consent/genrevibes_consent_ump/lib/genrevibes_consent_ump.dart).
