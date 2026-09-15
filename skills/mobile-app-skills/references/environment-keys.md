# Environment keys

The base templates match the current Story Saver reader names. Configure the
[portfolio baseline](../ARCHITECTURE_ANALYSIS.md#11-guaranteed-portfolio-integrations)
and any chosen extensions for a new portfolio app, using its selected adapters.
Its typed reader must pass each value on; another adapter may need different keys.
Blank SDK keys mean unconfigured. Do not use placeholder text as a real key.

| Key | Reader / purpose |
|---|---|
| `development_mode`, `founders_version`, `special_version_mode` | Story Saver `AppEnv.fromDefines` treats any as a development/internal build. They do not create a universal paid-access grant. |
| `appodeal_app_key_android`, `appodeal_app_key_ios` | Appodeal ads/consent platform keys, including development builds. |
| `one_signal_app_id` | OneSignal app configuration. |
| `revenue_cat_api_key_android` | Current Story Saver RevenueCat reader. |
| `posthog_api_key` | PostHog sink configuration. |
| `feed_back_nest_api_key` | FeedbackNest configuration; retain the existing spelling. |
| `disabled_firebase_analytics_in_debug_mode` | Story Saver Firebase collection ceiling in development builds. |
| `posthog_session_replay` | Story Saver development replay seed; not a universal rollout switch. |
| `developer_passcode` | Blank preserves the kit fallback; nonblank overrides it. |
| `developer_device_hashes` | Comma-separated hashes, never raw identifiers. |
| `developer_access_store_build` | Story Saver development-only access simulation; keep ad test mode enabled. |
| `privacy_policy_url`, `terms_url` | App link configuration. |
| `app_store_url` | Story Saver iOS store-link reader. |

`premium_entitlement_id` is deliberately omitted from blank templates: Story
Saver defaults to `Pro` when it is absent, but a supplied empty string overrides
that default. Add the app's exact entitlement ID when configuring purchases.

## Optional provider extensions

The following are supported by kit adapters but need a destination-app reader.
They are not silently enabled by the base template:

- iOS RevenueCat: read `revenue_cat_api_key_ios` and pass it to
  `RevenueCatConfiguration.iosApiKey`. Story Saver currently reads Android only.
- Mixpanel: choose a `mixpanel_token` reader and pass the token to the adapter.
- Direct AdMob: read placement unit IDs (`banner_ad_id`, `interstitial_ad_id`,
  `rewarded_ad_id`, `native_ad_id`, `app_open_ad_id`) only if that adapter is used.

Firebase platform settings come from the app's generated/native configuration;
blank `firebase_api_key_*` defines do not configure Firebase automatically.
Native AdMob App IDs also remain in the platform configuration.

For developer opt-out/action restrictions, use `DeveloperAccessConfig.enabled`,
`allowPasscode`, `actions`, and `passcodeActions`. Add env readers only if the app
needs to control those choices at build time. Never put server secrets in defines.
