# Appodeal bidding routes and network adapters

Use this guide when an enabled network has no requests, when only a few networks
appear in In-App Header Bidding, or when expanding an existing app's demand.

## Check the selected route before adding dependencies

1. Open the app's Mediation Groups. Record each enabled group's targeting and
   selected engine, including custom groups covering All Countries.
2. Inspect the group that matches the device's country/segment. The Default
   group is not an independent bidder. A matching custom engine configuration
   can route traffic away from the Default Appodeal group.
3. Check the units for each app-supported format. A unit restricted to MAX does
   not configure the same network for the Appodeal engine. A network marked ON
   can still have no units for that format.
4. Compare a fresh device session before and after an authorized route change.
   In Gravity Launcher, the AppLovin SDK logged `Mediation Provider: max` before
   disabling an All Countries MAX group and `Mediation Provider: Appodeal`
   afterward. Initialization alone is insufficient: also inspect requests,
   loaded ads and impression callbacks. Do not generalize one device session to
   the app's entire history.
5. Keep direct AdMob App Open separate from mediated AdMob. Revenue from App Open
   does not establish that AdMob receives Appodeal requests.

## Distinguish the account list, bidding units and waterfall units

The account list identifies available network connections, not active bidders.
Appodeal supports In-App Header Bidding, Automatic, Manual and eCPM Priority
together. Only bidding-capable units belong in In-App Header Bidding. Do not
move a waterfall unit there or mark a network as a bidder just because its name
contains `bid` or it supports bidding through a different mediator.

Inspect the actual New Ad Unit form for the selected account and format before
promising bidding. In Gravity's Appodeal account on 15 November 2026, AppLovin's
form offered a label, countries and default eCPM, but no header-bidding mode.
Existing AppLovin waterfall units were already present. Preserve them; do not
create duplicates or claim that adding a Bidon adapter enables AppLovin RTB.
AppLovin bidding support in AdMob/MAX does not prove the same capability in an
Appodeal account. Record any additional provider/account activation required.

When creation fails with `Cannot create line items for Appodeal accounts`,
the provider-managed account must provision the units, or the owner must link
an eligible own-network account and supply its real unit IDs. A generic New
button does not override this server restriction. Do not retry the same blocked
operation across every network or report the failed creation as saved.

Check blocked networks before enabling their adapters or units. The same app
showed Bigo pending approval, VK Ads failing restrictions, and Yandex requiring
a manual connection. These are distinct conditions. Do not work around disabled
controls, invent placement IDs, or report a support request as activation.

## Connect each SDK route explicitly

| Route | Android adapter family |
|---|---|
| Appodeal to a network | `com.appodeal.ads.sdk.adapters:<network>` |
| Appodeal to MAX to a network | `com.applovin.mediation:<network>-adapter` |
| Appodeal to BidMachine to an SDK network | `io.bidmachine:ads.networks.<network>` |
| Appodeal to Bidon to a network | `org.bidon:<network>-adapter` |

A direct network adapter does not replace that network's MAX, BidMachine or
Bidon bridge. Conversely, do not add every bridge for every engine when the app
does not use that route. Reuse the selected network SDK versions and add only
the route-specific integration code required by the intended demand.

Appodeal's Bidon adapter initializes Bidon and calls `registerDefaultAdapters()`.
The Bidon SDK alone does not include its network adapters. Include adapters for
the selected eligible networks before treating Bidon as configured. Do not add
another Bidon initialization in Dart or the Android activity.

For Appodeal Bidon adapter `0.14.0.0`, inspection also showed registration of
`com.appodeal.ads.adapters.bidonmediation.AdmobCustomAdapter`. Preserve that
custom Google route; do not automatically add a second `org.bidon:admob-adapter`
alongside it. Recheck the installed SDK when upgrading.

### Recorded Bidon pins for Appodeal Flutter 4.3.1

These coordinates were checked against the vendor's published POMs. They match
Gravity Launcher's selected network SDKs and Bidon 0.14.0; they are not a command
to enable every network in every portfolio app.

```kotlin
implementation("org.bidon:amazon-adapter:12.0.0.0")
implementation("org.bidon:applovin-adapter:13.6.3.0")
implementation("org.bidon:bidmachine-adapter:3.7.1.1")
implementation("org.bidon:dtexchange-adapter:8.4.6.0")
implementation("org.bidon:inmobi-adapter:11.3.0.0")
implementation("org.bidon:ironsource-adapter:9.4.4.0")
implementation("org.bidon:meta-adapter:6.21.0.0")
implementation("org.bidon:mintegral-adapter:17.1.61.0")
implementation("org.bidon:unityads-adapter:4.17.0.0")
implementation("org.bidon:vungle-adapter:7.7.4.0")
```

Route `org.bidon` to Appodeal's Maven repository when using its published copies,
and exclude that group from earlier Google/Maven Central probes. Verify the
resolved graph: adapters specify a Bidon SDK version range, and compatible pins
must not accidentally upgrade unrelated SDKs. Keep the app's approved myTarget
version above its Play Billing floor; do not restore an older SDK to satisfy a
bridge, force dependencies or exclude billing as a shortcut.

## Verify the change without overstating completion

- Verify each dashboard save by reloading the app, format and group. Capture the
  resulting unit label, supported mode, engine assignment and enabled state.
- Resolve the release dependency graph without compiling when permitted. Check
  missing artifacts, selected versions, duplicate classes, required repositories
  and consumer rules. Full builds, installs and device runs remain opt-in.
- Native adapters require a new native APK/AAB. A Dart-only Shorebird patch
  cannot deliver them. Until that build is installed, existing phone logs still
  describe the previous adapter set.
- After an authorized build/run, inspect missing-adapter/init errors and observe
  requests, ad loads and impressions. Test ads prove a test-serving path, not live
  bidding or revenue. A listed unit is configuration, not proof of a returned bid.
- Report SDK changes, saved dashboard changes, approval/credential blockers and
  runtime validation separately. Do not certify every bidder from one ad load.

## Vendor references

- [Appodeal mediation groups](https://docs.appodeal.com/networks-setup/mediation-groups/mediation-groups-intro)
- [Appodeal ad units and bidding](https://docs.appodeal.com/networks-setup/ad-units)
- [AppLovin account and zone setup](https://docs.appodeal.com/networks-setup/ad-networks/network-connection/applovin)
- [Bidon Android integration](https://docs.bidon.org/docs/sdk/android/integration)
- [Appodeal Android dependency example](https://github.com/appodeal/appodeal-android-sdk/blob/master/rewarded/build.gradle)
