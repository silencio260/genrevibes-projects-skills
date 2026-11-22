# Yandex eCPM floor waterfall in Appodeal

Use this guide when the owner asks for Yandex units at several price floors in
an Appodeal waterfall ("create Yandex units at $10, $5, $2 and $1 for every ad
type"). Done first for Gravity Rolling Launcher on 22 November 2026.

## How the floor actually works

Yandex takes part in Appodeal only through the waterfall. Appodeal's Yandex
unit form has no bidding toggle: a label, countries, **Default eCPM**, code and
mediation engine. Two separate settings make a floor tier:

| Setting | Where | What it does |
|---|---|---|
| **eCPM floor** (CPM strategy) | Yandex Partner, on the ad unit | The real floor. Yandex returns no ad below it. |
| **Default eCPM** | Appodeal, on the Yandex line item | Only the price Appodeal *expects*. It decides the line item's place in the waterfall; Yandex never sees it. |

So a tier needs **both**: its own Yandex unit with the eCPM floor strategy, and
its own Appodeal line item with that unit's code and a matching Default eCPM.
Several Appodeal line items that reuse one Yandex code with different Default
eCPMs do not enforce any floor: Yandex just answers the same request again,
lower down the waterfall.

Keep the original Yandex unit with "Maximum revenue" strategy and Default eCPM
$0 at the bottom of each waterfall as the catch-all. Do not delete it.

## Choose realistic floors first

Every tier sits above everything with a lower Default eCPM, so each request
tries it first. A tier that never fills only adds a failed request and delay to
every ad. Before creating anything, read the app's settled eCPMs in Appodeal or
AdMob and propose floors that bracket what it really clears at, then let the
owner choose.

Gravity cleared about $0.30 to $5 eCPM. The owner's example of $50, $25, $10,
$5 was replaced, with the owner's agreement, by **$10, $5, $2, $1**. Ask; do not
pick on the owner's behalf.

## Steps in Yandex Partner (partner.yandex.ru)

Per format (banner, native, interstitial, rewarded) and per floor:

1. Open the app: `https://partner.yandex.ru/v2/inapp/app/<page id>/` →
   **New ad unit** (`.../adunit/create`).
2. Pick the ad format.
3. **Name:** `<Format> floor $<amount>`, for example `Banner floor $10`.
4. **CPM strategy:** change *Maximum revenue* to **eCPM floor**. An
   **eCPM floor** field appears; enter the dollar amount.
5. Leave the format's other defaults (interstitial: video ads on; native:
   slider, media banners and video off; rewarded: currency "Reward", amount 1).
6. **Save.** The page confirms "The block (ID: R-M-<page id>-<n>) has been
   successfully created". Record that code with its format and floor.

The unit list shows the strategy as `eCPM / ₽10` even when the floor was
entered in dollars. Open the unit to check: the editor shows `$ 10`. The ₽ is a
display quirk of the list, not the saved currency.

Gravity's result (page id 20438868):

| Format | $10 | $5 | $2 | $1 |
|---|---|---|---|---|
| Banner | R-M-20438868-7 | -8 | -9 | -10 |
| Native | -11 | -12 | -13 | -14 |
| Interstitial | -15 | -16 | -17 | -18 |
| Rewarded | -19 | -20 | -21 | -22 |

## Steps in Appodeal (app.appodeal.com)

Line items live per ad type at:

```
https://app.appodeal.com/apps/<appodeal app id>/dcc/line_items?ad_type=<TYPE>
```

with `TYPE` = `BANNER`, `NATIVE`, `MERGED_INTERSTITIAL` or `REWARDED_VIDEO`.

1. Open the ad type's page and expand the **Yandex** row. Check the Yandex
   account, Page ID and AppMetrica fields are already filled; if not, the app
   is not connected to Yandex yet and this guide does not apply.
2. Click **Add Ad Unit**.
3. **Ad Unit label:** `Yandex <Format> floor $<amount>`.
4. **Countries:** All Countries (default).
5. **Default eCPM:** the same amount as the Yandex unit's floor.
6. **Code:** the unit's `R-M-...` code.
7. Leave **Add to configurations: Yes, Default only** and **Mediation Engine:
   Appodeal**.
8. **Create.** The new row appears in the Yandex Ad Units table, ON, with the
   Default eCPM shown.

Repeat for each floor, then for each ad type. When done, each ad type's table
shows the original Yandex unit at $0 plus one row per floor.

## Browser tips (Claude in Chrome)

- Neither form has stable coordinates: the Yandex create page sometimes loads
  scrolled, and a coordinate click then lands on the wrong control and the
  strategy silently stays *Maximum revenue*. Use `find` for element references
  and click those; refs only exist after a `find` or `read_page` call.
- The Yandex strategy dropdown's options change refs between formats (the
  "eCPM floor" option was `ref_148` for native and `ref_143` for rewarded, where
  `ref_140` was *Maximum revenue*). Always read the option's label in the
  `find` result before clicking it.
- Zoom into the form and check name, strategy and floor before every Save.
- A slow Yandex save can look like a failure; a "Leave site?" dialog on
  navigating away means the form is still open. Check the unit list before
  creating the same unit again, or it will be duplicated.
- Do not use `get_page_text` on the Yandex app page: the app-ads.txt block makes
  it larger than the tool's output limit.
- Appodeal may be signed out in Chrome even when another browser is signed in.
  The owner signs in; never type their password.

## Afterwards

- Watch fill per tier for a few days (Appodeal analytics, split by ad unit). A
  top tier with no fill only adds delay: switch its Appodeal line item OFF
  rather than deleting it, so it can be turned back on.
- The Yandex app page warns when the hosted app-ads.txt is missing Yandex's
  lines. Update the file; unauthorized inventory earns less.
- Record the codes and floors in the app's own notes so later edits match both
  dashboards.
