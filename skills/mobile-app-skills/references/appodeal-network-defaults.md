# Portfolio Appodeal network defaults

This is the owner's portfolio default, established on 11 October 2026 from
Story Saver's current Android setup. Apply it to new Appodeal integrations after
initial SDK configuration. Preserve a working existing app's enabled set rather
than resetting it to the initial stage. A deliberately selected different ad
provider keeps its own setup.

## Stage 1: configure and verify BidMachine and Bidon

Set up the Appodeal core/plugin, real platform app key, repository, consent,
placements, native views where applicable, developer inventory controls and
events. Initially declare only these two Appodeal network adapters in the host:

```groovy
// Recorded versions for stack_appodeal_flutter 4.2.0 only.
implementation "com.appodeal.ads.sdk.adapters:bidmachine:3.7.1.0"
implementation "com.appodeal.ads.sdk.adapters:bidon:0.14.0.0"
```

This describes host-declared adapters, not every SDK that their transitive
dependencies may bring. Keep the rest of the preset as commented declarations
during this stage. Match versions to the installed Appodeal plugin's integration
guide; do not downgrade a newer plugin to these historical versions.

Before enabling the remaining adapters, verify the initial configuration on a
device in **both test and live inventory modes**:

1. Confirm SDK initialization completes and the logs report the actual inventory
   mode. A dashboard toggle or a command-line flag alone is not confirmation.
2. In test mode, observe an ad load, display and impression callback for at least
   one configured format supported by this initial integration.
3. Start a fresh process in live mode and observe a real ad load, display and
   impression callback. Use the [live debug command](live-ads-debugging.md),
   replacing the device ID with the currently connected phone.
4. Record the format, load result, impression and missing-class/init errors for
   each run. Successful SDK initialization alone does not prove inventory works.

Ordinary no-fill is not proof of an implementation bug, but it also does not
fulfill the live-ad check. Keep this stage pending until live serving is observed;
do not label it verified or add the remaining networks to hide an unresolved
startup/mode problem. Device runs and builds remain opt-in under the host rules;
use the user's logs/results when the user performs the runs.

## Stage 2: enable the 17-adapter preset

After both inventory checks pass, enable the full set below by default. There
are **17 Appodeal network/mediation adapters total**, including the original
BidMachine and Bidon; add the other 15, not another copy of the original two.
AppLovin MAX is a mediation integration, not an additional independent network.

| Network/integration | Appodeal adapter name |
|---|---|
| AdMob | `admob` |
| Amazon Ads | `amazon` |
| AppLovin | `applovin` |
| AppLovin MAX | `applovin_max` |
| BidMachine | `bidmachine` |
| Bidon | `bidon` |
| Bigo Ads | `bigo_ads` |
| DT Exchange | `dt_exchange` |
| InMobi | `inmobi` |
| ironSource | `ironsource` |
| Meta Audience Network | `meta` |
| Mintegral | `mintegral` |
| myTarget | `my_target` |
| Start.io | `startio` |
| Unity Ads | `unity_ads` |
| Vungle | `vungle` |
| Yandex | `yandex` |

Inspect the app's Appodeal accounts, ad units, formats and mediation groups,
including MAX and LevelPlay tabs. This preset determines which SDK adapters
ship; it does not automatically connect credentials, approve the app, configure
units, enable every format in the dashboard or guarantee fill. Report any pending
dashboard/account steps for preset networks rather than silently removing them
from the portfolio default. Configure the real native AdMob app ID when its SDK
is present; an app ID is different from a placement/ad unit ID.

## Nine adapters stay commented out until manual activation

| Network/integration | Appodeal adapter name |
|---|---|
| Chartboost | `chartboost` |
| LevelPlay | `level_play` |
| MobileFuse | `mobilefuse` |
| Moloco | `moloco` |
| Ogury | `ogury` |
| PubMatic | `pubmatic` |
| Smaato | `smaato` |
| TaurusX | `taurusx` |
| Verve | `verve` |

These are manual opt-ins because account setup, app approval or other network
eligibility conditions may need to be met. Do not automatically enable them
when stage 2 passes. The owner chooses when to activate one after its actual
requirements are satisfied. Record the specific current dashboard reason when
known; do not assume every listed network has the same restriction. Keep each
dependency commented with a date and reason so it can be restored later.

## Recorded Android dependency block

This is the stage 2 block from Story Saver, compatible with
`stack_appodeal_flutter 4.2.0`. Use one dependency block for the selected stage;
do not append it alongside stage 1 or another generated all-network block.
For a different plugin version, retain the enabled/commented selection but
resolve every version and required bridge against that installed plugin's guide.

```groovy
implementation "com.appodeal.ads.sdk.adapters:admob:24.7.0.0"
implementation "com.appodeal.ads.sdk.adapters:amazon:11.3.0.0"
implementation "com.appodeal.ads.sdk.adapters:applovin:13.5.1.0"
implementation "com.appodeal.ads.sdk.adapters:applovin_max:13.5.1.1"
implementation "com.appodeal.ads.sdk.adapters:bidmachine:3.7.1.0"
implementation "com.appodeal.ads.sdk.adapters:bidon:0.14.0.0"
implementation "com.appodeal.ads.sdk.adapters:bigo_ads:5.6.2.0"
implementation "com.appodeal.ads.sdk.adapters:dt_exchange:8.4.1.0"
implementation "com.appodeal.ads.sdk.adapters:inmobi:11.1.0.0"
implementation "com.appodeal.ads.sdk.adapters:ironsource:9.1.0.0"
implementation "com.appodeal.ads.sdk.adapters:meta:6.21.0.0"
implementation "com.appodeal.ads.sdk.adapters:mintegral:17.1.61.0"
implementation "com.appodeal.ads.sdk.adapters:my_target:5.47.1.0"
implementation "com.appodeal.ads.sdk.adapters:startio:5.2.4.0"
implementation "com.appodeal.ads.sdk.adapters:unity_ads:4.17.0.0"
implementation "com.appodeal.ads.sdk.adapters:vungle:7.6.1.0"
implementation "com.appodeal.ads.sdk.adapters:yandex:7.17.0.0"

// Default off, 11 October 2026: owner enables manually after required
// account setup, approval or eligibility conditions are satisfied.
// implementation "com.appodeal.ads.sdk.adapters:chartboost:9.10.2.0"
// implementation "com.appodeal.ads.sdk.adapters:level_play:9.1.0.0"
// implementation "com.appodeal.ads.sdk.adapters:mobilefuse:1.9.3.0"
// implementation "com.appodeal.ads.sdk.adapters:moloco:4.3.1.0"
// implementation "com.appodeal.ads.sdk.adapters:ogury:6.2.0.0"
// implementation "com.appodeal.ads.sdk.adapters:pubmatic:4.10.0.0"
// implementation "com.appodeal.ads.sdk.adapters:smaato:22.7.2.0"
// implementation "com.appodeal.ads.sdk.adapters:taurusx:1.12.2.0"
// implementation "com.appodeal.ads.sdk.adapters:verve:3.7.1.0"

// MAX bridges for the recorded portfolio mediation setup.
implementation "com.applovin.mediation:bidmachine-adapter:3.7.1.0"
implementation "com.applovin.mediation:inmobi-adapter:11.1.0.0"
implementation "com.applovin.mediation:vungle-adapter:7.6.1.0"
// BidMachine header-bidding bridges for Meta and Mintegral.
implementation "io.bidmachine:ads.networks.meta_audience:6.21.0.1"
implementation "io.bidmachine:ads.networks.mintegral:17.1.61.1"
```

The five bridges make **22 enabled adapter declarations** in the recorded full
setup. They connect networks already listed above. Carry them with this stage 2
mediation recipe, configuring the relevant MAX units and native header bidding.
They are distinct integration code: direct Appodeal adapters do not replace
MAX or BidMachine bridges. In a different mediation topology, check which
bridges the SDK actually needs instead of adding unrelated alternatives.

Appodeal analytics/service adapters (Adjust, AppsFlyer, Facebook analytics,
Firebase and Sentry) remain omitted in this recipe; the app's shared analytics
and ad-revenue pipeline owns reporting. The Meta **ad-network adapter** above is
separate from the Facebook **analytics adapter**.

## Apply the build configuration with the preset

Use [Android build performance](android-debug-build-performance.md) for the
daemon/cache settings, 4 GB Gradle and 2 GB Kotlin heap caps on an 8 GB machine,
two-worker limit, single plugin declarations, repository filtering, SDK conflict
handling and the release checklist. Keep SDKs supplied transitively by the
plugin/adapter shared rather than adding standalone copies. Match the local
Flutter, Shorebird Flutter, Gradle, AGP and JDK versions before release.

The older 15-adapter release measurement in the
[release build guide](../skills/android-release-build-experiment/SKILL.md) is
historical evidence, not the current portfolio preset or proof that the expanded
17-plus-five configuration cannot run out of memory. Diagnose the actual failing
task, keep full release shrinking, and report the verification performed rather
than guaranteeing build speed or successful releases from configuration alone.
