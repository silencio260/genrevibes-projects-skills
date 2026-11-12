---
name: ad-ctr-investigation
description: "Investigate a high ad click-through rate: split clicks by network and format in Appodeal, time each click in Mixpanel, check the app's placements, and research the network before blaming the app or the network."
---

# Investigating a high ad click-through rate

Follow this before saying an app's click-through rate (CTR) is too high, before
calling it invalid traffic, and before changing ad placements because of it.
Do the steps in order: split the clicks, time them, read the app's placements,
research the network, then conclude.

CTR is clicks divided by impressions. Full-screen formats (interstitial,
rewarded, app open) normally have a far higher CTR than banner and native, so
one CTR blended across formats tells you very little.

## Why this skill exists

In November 2026 an agent told the user that Gravity Rolling Launcher's CTR,
quoted as 26%, came from native ads growing into the spot users were tapping,
and called it an invalid-traffic risk. It had not split the clicks. When it did:

- 26% was a single day. The week was 13.1%.
- Native ads had 149 impressions and 0 clicks. Banners had 2 clicks.
  Interstitials had 35 of the 37 clicks.
- Most interstitial clicks came 8 to 51 seconds after the ad appeared, which
  points to the ad creatives, not to accidental taps.

The layout explanation was wrong. Reason from the split and the timing, not
from one number.

## 1. Split the clicks by network and ad type (Appodeal)

Open the Appodeal dashboard: Analytics → Reports
(`https://app.appodeal.com/analytics/reports`).

1. **Filters:** set the date range. Add App = the app being checked.
2. **Split:** click the **+ at the right end of the SPLIT row**. A search box
   opens. Type `network` and select **Network (Monetization)**. Click + again,
   type `ad type` and select **Ad Type**.
   - It is a select menu, not drag-and-drop. Clicking an item in the left
     DIMENSIONS panel does not add it.
   - In a narrow window the + is off-screen to the right. Widen the window.
3. **Measures:** Impressions, Clicks, CTR, eCPM. **Remove Total Revenue.** The
   network split is incompatible with it. Appodeal shows "Breakdown is
   incompatible with certain metrics" and a "Remove all conflicting metrics
   (Total Revenue)" link. While Total Revenue stays, the split is not applied.
4. **Rows:** the table shows 20 rows and folds the rest away. Raise the limit
   with `topLimit~50` in the URL.

The report state is stored in the URL. With the IDs filled in, this opens the
split directly:

```
https://app.appodeal.com/analytics/reports?q=(f~(USER~!<USER_ID>~~DATE~(from~*<YYYY-MM-DD>~to~*<YYYY-MM-DD>)APP~!<APP_ID>)g~!AD*_NETWORK~AD*_TYPE~~m~!impressions~clicks~ctr~ecpm~~view~table~fv~*~topLimit~50~showOthers~_F)~
```

- `<APP_ID>` is the number in the app's settings URL, `apps/<APP_ID>/edit`
  (Apps → click the app). Gravity Rolling Launcher is `789242`.
- `<USER_ID>` is the account number Appodeal puts in every report URL
  (`USER~!263546` for this account).
- The grouping is written `g~!AD*_NETWORK~AD*_TYPE~` (`*_` is an escaped
  underscore). Other forms, such as `(id~NETWORK)` or
  `(id~AD_NETWORK~display~name)`, are silently removed when the page loads.
- A dimension's ID is the element id of its `<li>` in the DIMENSIONS list
  (Network (Monetization) is `AD_NETWORK`, Ad Type is `AD_TYPE`).

Read the table:

- Leave out the **Test Ads** and **Service Messages** rows; they have no clicks
  and earn nothing. Debug builds use the same Appodeal app key as release
  (`env/dev.json` and `env/release.json`), so the developer's own test sessions
  appear here as Test Ads. Subtract them before quoting impression totals.
- Work out CTR per format, and find the network and format that hold the clicks.
- Do not quote one day as the period's CTR. Do not use account-wide totals
  (every app together) for a single app.

## 2. Time each click (Mixpanel)

Firebase and GA4 cannot answer this. Their standard reports have no per-event
times, and GA4 User Explorer shows minutes only. Mixpanel stores each event's
exact time.

Event names come from the app's ad event mapping. In Gravity Rolling Launcher
it is `_trackAdEvent` in `lib/bootstrap/app_runtime.dart`; check the same
mapping in other apps before relying on the names.

| Event | Ad SDK callback | Meaning |
|---|---|---|
| `ad_load` | loaded | Inventory loaded |
| `ad_show` | impression | The ad appeared on screen |
| `custom_ad_click` | clicked | The user clicked the ad |
| `ad_dismiss` | dismissed | The ad closed |
| `ad_impression` | paid | Revenue report. Despite the name, not an impression count |

Each event carries `ad_format`, `ad_source`, `ad_placement`, `ad_unit_name`
and `ad_platform`.

In the app's Mixpanel project, open Funnels:

1. Step 1: `ad_show`, filtered to `ad_format` is the format holding the clicks
   (usually `interstitial`).
2. Step 2: `custom_ad_click`.
3. Window: **5 minutes**. The default 7 days pairs a click with an ad the user
   saw hours earlier.
4. Change the measure from Conversion Rate to **Time to Convert → Median**.
5. Breakdown: **Distinct ID**. Each row is one user's median time from the ad
   appearing to the click.

What the times mean:

- **About 1–2 seconds or less:** the user's own tap, made to open a screen,
  landed on an ad that appeared at that moment. App side; see step 3.
- **Several seconds or longer:** the user interacted with the creative itself:
  a video end card, a playable asking for a tap, or a close button that appears
  late or is hidden. Creative or network side; see step 4.
- The times come from the app's own events. If click events were held back
  until the ad closed, every time would be inflated. Clicks recorded within a
  couple of seconds show events arrive while the ad is still open.

GA4 gives the same split as counts, without timing: Reports → Engagement →
Events, comparing `ad_show` with `custom_ad_click`. To break those down by
`ad_source` or `ad_format`, register the parameters as custom dimensions
(Admin → Custom definitions). GA4 only has data for them from the day they are
registered.

## 3. Check where the app shows ads

Gravity Rolling Launcher (look for the equivalents in other apps):

- **Full-screen on navigation:** `pushWithInterstitial` in
  `lib/core/ads/ad_navigation.dart` shows an interstitial the moment the user
  taps to open a screen, then navigates. `InterstitialExitBoundary` in
  `lib/core/ads/interstitial_exit_boundary.dart` shows one when the user goes
  back. Their placement IDs end in `_navigation` (settings, wallpaper, widget,
  pattern settings, mini app). Showing on the tap that opens a screen is what
  produces sub-two-second clicks.
- **Native and banner:** `LauncherInlineAd` or `LauncherNativeAdCard` with
  `reserveNativeSpace: false`, and an onboarding `OnboardingAdSlot` without
  `reservedHeight`, let an ad grow into place under a finger. Only pursue this
  when step 1 shows clicks on native or banner.

## 4. Research the network

For the network and format holding the clicks, search online:

- Publisher reports of forced clicks, delayed or hidden close buttons, and
  playables that count a tap as a click.
- The network's own publisher documentation on how it counts clicks on
  full-screen ads.
- Current Google Play Ads policy, Disruptive Ads section
  (support.google.com/googleplay/android-developer/answer/9857753). It lists
  "Ads that force the user to click-through by using a false dismiss button, or
  by making ads suddenly appear in areas of the app where the user usually taps
  for another function".

Name each source, and keep official documentation separate from forums and
vendor blogs.

## 5. Conclude and act

Report the network and format, the time-to-click result, and which side it
points to.

- **Creative or network side:** send Appodeal support the network × format
  table and the time-to-click numbers, and ask them to review those creatives.
  Weigh the network's eCPM: a network with a very high CTR and $0 eCPM adds
  traffic-quality risk without revenue.
- **App side:** stop showing full-screen ads on the tap that opens a screen;
  show them on exit or at a natural break. Give native and banner slots their
  space from the first frame.
- Do not call it invalid traffic, and do not change placements, on CTR alone.

## Recorded baseline: Gravity Rolling Launcher, 6–12 November 2026

Appodeal, app `789242`, split by network and ad type:

| Network | Format | Impressions | Clicks | CTR | eCPM |
|---|---|---|---|---|---|
| AppLovin | Interstitial | 43 | 29 | 67.4% | $0.0000 |
| AppLovin | Native | 39 | 0 | 0% | $0.0000 |
| AppLovin | Banner | 19 | 0 | 0% | $0.0000 |
| InMobi | Interstitial | 11 | 2 | 18.2% | $0.1636 |
| InMobi | Banner | 7 | 1 | 14.3% | $0.0000 |
| InMobi | Native | 1 | 0 | 0% | $0.0000 |
| Vungle | Interstitial | 5 | 4 | 80.0% | $1.6518 |
| Vungle | Banner | 6 | 1 | 16.7% | $0.0015 |
| Meta Audience Network | Banner and native | 2 | 0 | 0% | $0.0000 |
| BidMachine | Banner | 1 | 0 | 0% | $0.1510 |
| Test Ads | Native 105, banner 20, interstitial 6 | 131 | 0 | — | — |
| Service Messages | All | 12 | 0 | — | — |
| **Total** | | **277** | **37** | **13.4%** | **$0.0369** |

AdMob won no Appodeal impressions in this period.

Mixpanel, last 30 days, interstitials, 5-minute window: 23 users saw an
interstitial and 12 clicked one. Each clicking user's median seconds from ad
shown to click: 2, 2, 8, 11, 14, 15, 17, 17, 33, 39, 45, 51. Overall median:
11 seconds.

Result: the clicks are almost all interstitial, mostly AppLovin, and mostly
well after the ad appeared. That points to the creatives, not the launcher's
layout. The user's assessment is that this is how AppLovin interstitials
behave. Native and banner layout was not the cause.

## Tool access (as of November 2026)

- Appodeal, Firebase, GA4, AdMob and Play Console are signed in in the Claude
  desktop app's built-in browser.
- Mixpanel is signed in in the user's Chrome (Claude in Chrome), not in the
  built-in browser. Use Chrome, or ask the user to sign in. Do not sign in for
  the user.
