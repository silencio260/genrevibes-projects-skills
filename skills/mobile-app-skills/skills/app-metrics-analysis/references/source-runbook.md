# Source runbook

How to reach and read each source, recorded during the Gravity Rolling
Launcher analysis of 13–14 November 2026. Dashboards change; if a screen does
not match, take a screenshot and adapt. Follow the
[site access rules](../SKILL.md#site-access-dont-ask-go): open and read
without asking; changes need a yes.

Placeholders: `<project>` Firebase project id, `<package>` Android
applicationId, `<property>` GA4 property id, `<account>` GA4 account id.
Gravity's values are given as examples.

## Driving the browsers

- **Built-in browser** (`mcp__Claude_Browser__*`): use `get_page_text` or
  `read_page` to read; screenshots only to find something to click.
- **Claude in Chrome** (`mcp__claude-in-chrome__*`): load the tools in one
  ToolSearch call (`tabs_context_mcp, tabs_create_mcp, tabs_close_mcp,
  navigate, computer, find, get_page_text, read_page, form_input,
  browser_batch, javascript_tool`). Call `tabs_context_mcp` first, work in your
  own tab, close it at the end.
- Batch navigate → wait → read with `browser_batch`. Screenshots at
  `scale: 0.55`–`0.6`; click coordinates are always in the full-size frame
  (divide the scaled coordinate by the scale).
- Prefer `find` refs to coordinates for buttons and inputs.
- Firebase, GA4 and Appodeal pages load slowly: wait 6–10 s before reading.
- After anything that can reflow a form (a checkbox that raises a banner, an
  error that clears), take a fresh screenshot before the next click.
- On React forms that look up a value as you type (Meta's Google Play URL
  field), typing character by character can trigger a lookup on a partial
  value and leave a stale error. Clear the field and set the whole value at
  once with `form_input`.
- A file download button may not reach the filesystem from an automated
  browser. Use the page's Copy to Clipboard and `pbpaste`.

## CLI and API access

Check first; it is faster and exact.

```bash
for c in firebase gcloud bq curl jq; do command -v $c >/dev/null && echo "$c ok" || echo "$c MISSING"; done
firebase login:list
gcloud auth list
```

- **Firebase project facts:** the Firebase Management API needs a quota
  project header, or it fails with `SERVICE_DISABLED`:
  ```bash
  TOKEN=$(gcloud auth print-access-token)
  curl -s -H "Authorization: Bearer $TOKEN" -H "x-goog-user-project: <project>" \
    "https://firebase.googleapis.com/v1beta1/projects/<project>/analyticsDetails"
  ```
  This returns the GA4 property id (Gravity: `560168056`, account `162888556`).
- **GA4 Data API:** the plain gcloud token fails with
  `ACCESS_TOKEN_SCOPE_INSUFFICIENT`. The owner must run once:
  ```bash
  gcloud auth application-default login --scopes=openid,https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/analytics.readonly
  ```
  Then query `analyticsdata.googleapis.com/v1beta/properties/<property>:runReport`
  with `gcloud auth application-default print-access-token`. If the owner
  prefers not to, use the browser.
- **BigQuery:** `bq --project_id=<project> ls`. An empty list means no
  Analytics export, so there is no raw event table and unregistered event
  parameters cannot be recovered.
- **Remote config (live):** `firebase remoteconfig:get --project <project> -o <file>`.
  Read-only. Never run a bare `firebase deploy` in a repo whose `firebase.json`
  has a `remoteconfig` block; it pushes the template to production.
- **Mixpanel / Appodeal:** the app's client token cannot read data. Read the
  dashboards in the browser rather than asking for service-account secrets.

## Firebase console

- Overview: `https://console.firebase.google.com/project/<project>/overview`.
  Holds the **Day 1 retention** card, DAU and revenue. Read the card's own
  chart window: Gravity's 15.2% D1 was for 4–10 Nov, not the latest cohort.
- Analytics dashboard:
  `…/project/<project>/analytics/app/android:<package>/overview`. Scroll for
  active users (1/7/30 day), new vs returning, engagement, cohort table.
- Events: `…/analytics/app/android:<package>/events`. Event count and users
  per event for the selected range. These are totals, not a funnel.

## Crashlytics

`…/project/<project>/crashlytics/app/android:<package>/issues`

- Read crash-free users and sessions, then every issue's events and users.
  Issue user counts overlap; never add them up.
- Open the top issue and read the stack. Check whether it is **really fatal**:
  find the app's crash hook (for example `crash_hooks.dart`) and see which
  sources it reports with `fatal: true`. Errors through
  `PlatformDispatcher.onError` or a guarded zone do not end a Flutter process.
- For network errors, test the host from the shell (`dig +short <host>`,
  `curl -sI https://<host>`). Gravity's top "crash" was a dead vendor domain.

## GA4 (analytics.google.com)

- Explore: `https://analytics.google.com/analytics/web/#/analysis/a<account>p<property>`
- Custom definitions:
  `…/#/a<account>p<property>/admin/customdefinitions/hub`. Check this early.
  "0 of 0" means no event parameter is reportable.
- Property settings (reporting timezone):
  `…/#/a<account>p<property>/admin/property/settings`.

**Path exploration** (does the app get past launch?):
1. Explore → Path exploration → Start over.
2. Starting point → Event name → search `first_open` → select.
3. Values: remove Event count, add **Active users**.
4. Expand the next nodes (`session_start`, `screen_view`, …).

**Closed funnel** (where users are lost):
1. New tab → Funnel exploration → Settings → Steps (pencil).
2. Step 1 condition `first_open`; add a step per key event in order.
3. Keep it **closed** and use "indirectly followed by" unless you need strict
   adjacency.
4. Apply. Breakdown: Variables → Dimensions → + → import `App version` → drag
   to Breakdown. Repeat with country or source as needed.
5. To insert a step, open a step's menu → add step after.
6. Rename the exploration (for example "First-run funnel 2026-11-13") so the
   owner can find it.

**Cohort retention:** Explore → scroll the template carousel → Cohort
exploration → set granularity to **Daily**. Rows are install days; columns are
D1, D2, …

**Same-day and per-version counts:** Explorations have no same-day data.
Use Reports → Engagement → Events, date **Today**, search the event names,
secondary dimension **App version**, rows per page 250. That gives every
event by version in one table, enough to hand-build a first-day funnel. Swap
the secondary dimension for a registered parameter (for example Consent
state) to read its values.

**Like-for-like day count:** Free form exploration, date range one complete
day, rows Event name, metric Active users, show 50 rows.

**Registering a custom dimension** (a change: needs a yes): Custom definitions
→ Create custom dimension → name, scope Event, pick the event parameter →
Save. Then reload the list and confirm it appears. Not retroactive. Custom
metrics (for example a `ms` duration, unit Milliseconds) are on the Custom
metrics tab. The free tier allows 50 event-scoped dimensions.

## Google Play Console

- Developer home: `https://play.google.com/console/developers`.
- Statistics:
  `https://play.google.com/console/u/0/developers/<devId>/app/<appId>/statistics?metrics=INSTALL_BASE_ACTIVE_DEVICES_COUNT&dimension=NONE&tab=APP_STATISTICS&date_range=last_30_days`
- Store settings (website, email): `…/app/<appId>/store-settings`.
- Statistics with metric, dimension and range in the URL, for example
  `…/statistics?metrics=ACTIVE_USERS-ALL-UNIQUE-PER_INTERVAL-DAY&dimension=COUNTRY&dimensionValues=OVERALL&dateRange=2026_10_17-2026_11_13&tab=APP_STATISTICS`.
  Other metrics: metric selector → Acquisition → devices.
- Ratings: left navigation → Ratings (count and average for the period).
- Dashboard: `…/app/<appId>/app-dashboard?timespan=thirtyDays`.
- **Play statistics lag about 2–3 days.** Check the chart's last date before
  comparing with Firebase. Remove auto-applied dimensions (country) that narrow
  the total. Crash rate, ANR and rating show "–" below the reporting threshold.

## Mixpanel

- Projects: `https://mixpanel.com/projects`. Gravity: project `4081621`.
- Insights: `https://mixpanel.com/project/<id>/view/<viewId>/app/insights`.
  Metric → search the event → fixed date range of one complete day →
  granularity Day. Add a second event to see whether the ratio to GA4 holds.
- Project settings (timezone, creation date):
  `https://mixpanel.com/project/<id>/app/settings/project/` → Overview.
  Mixpanel offers only named IANA zones (no fixed GMT offsets).
- Funnels with Time to Convert → Median and breakdown by Distinct ID give
  per-user timing (see the [ad CTR investigation](../../ad-ctr-investigation/SKILL.md)).

## Appodeal

- Apps: `https://app.appodeal.com/apps` (the app id is in `apps/<id>/edit`;
  Gravity `789242`).
- Monetization analytics: Analytics → Monetization. Filter App, set dates,
  Split by → Network, add Network as a table dimension. Remove the date grouping
  to aggregate rows by network. The state lives in the URL, for example:
  ```
  https://app.appodeal.com/analytics/monetization?q=(f~(USER~!<userId>~~DATE~(from~*<from>~to~*<to>)APP~!<appId>)g~!(id~DATE~timeBucket~DAY)AD*_NETWORK~~tg~!(id~COUNTRY)~m~!impressions~requests~fillrate~display*_rate~ctr~ad*_revenue~ecpm~~e~~r~_F)~
  ```
- Read: impressions, **network requests**, fill, competitive factor, CTR,
  eCPM, revenue. A network with **zero requests** is not being asked; one with
  requests but no impressions is losing or failing.
- Today's revenue is not settled ($0.00 everywhere); use complete days.
- Separate **Test Ads** and **Service Messages** rows. Debug builds that share
  the release app key show up as Test Ads.
- Never use account totals for one app.
- Mediation setup → Ad Networks
  (`https://app.appodeal.com/integrations/mediation_ad_networks`): which
  networks run on the owner's own account (AdMob, Meta) vs Appodeal's.
- App-ads.txt: `https://app.appodeal.com/integrations/app_ads_txt`. Its
  AdMob and Meta lines ship as placeholders (`Publisher_ID`, `Business_ID`)
  that must be filled in.
- The overview analytics page sometimes returns 500; the Monetization page
  still works.

## AdMob

- Apps: `https://apps.admob.com/v2/apps/list` (status, ad serving, store link,
  ad units).
- Privacy & messaging → GDPR: `https://apps.admob.com/v2/privacymessaging/gdpr`.
  **Each app needs its own published message.** Without one, Google's UMP
  fails with "no form(s) configured for the input app ID" (code 3) on every
  launch, for every user, and Google demand is withheld.
- Reports: `https://apps.admob.com/v2/reports` → the ready-made **AdMob
  Network** report. Add **App version** and **Ad unit** as dimensions (search
  the dimension list; close the picker between additions). Date range: Last
  30 days, then "Today so far". Read requests, match rate, impressions, show
  rate, eCPM, earnings per row. A low **show rate** means fills are loaded
  and discarded.
- Publisher id for app-ads.txt: from the AdMob app id
  `ca-app-pub-<16 digits>~<10 digits>` → `pub-<same 16 digits>`.
- On "Select your apps", set the privacy URL **before** ticking the app; the
  banner that appears on ticking shifts every row.

## Meta Audience Network

- Developer app: `https://developers.facebook.com/apps/<appId>/settings/basic/`
  (privacy policy URL, terms, data deletion, category) and
  `…/dashboard/` (published or not). An unpublished app serves almost nothing.
- **Monetization Manager → Issues** is the authoritative list of what blocks
  monetization: `https://business.facebook.com/pub/issues?business_id=<businessId>`.
  Read this before anything else on Meta.
- Property: `https://business.facebook.com/pub/property/?business_id=<businessId>&property_id=<propertyId>`.
  "Add app URL" opens a wizard: App details (Google Play URL) → Payout account
  → Verification (app-ads.txt or email) → SDK integration.
- Payouts: `https://business.facebook.com/pub/payouts/overview?business_id=<businessId>`.
- Business portfolio id: `https://business.facebook.com/settings/info`.
- Business verification is a separate track from serving ads and rejects free
  hosting domains (blogspot.com, web.app) as "common website domains".
- Old URLs (`/monetization_manager/…`, `/an/…`) now 404. Reach Monetization
  Manager from the developer app's Audience Network use case → "Go to
  Monetization Manager".

## app-ads.txt checks

```bash
U=https://<developer-website>/app-ads.txt
curl -sS -o /tmp/aat.txt -D - -L "$U" | head -20   # 200, text/plain
file /tmp/aat.txt; head -c 3 /tmp/aat.txt | xxd     # ASCII, no BOM
grep -c $'\r' /tmp/aat.txt                          # 0 = Unix endings
grep -in '^google\.com, pub-' /tmp/aat.txt | head -3
grep -in '^facebook\.com' /tmp/aat.txt
grep -v '^#' /tmp/aat.txt | grep -v '^[[:space:]]*$' | sort | uniq -d   # duplicates
```

The file must sit at the root of the **developer website on the store
listing**; confirm that website from the live listing page. A host that
redirects `/app-ads.txt` (Blogspot sends it to `/ads.txt`) cannot be used.

## Device log

When an ad network has zero requests or consent misbehaves, ask the owner to
run the release build (or a Shorebird preview of it) and read:

```bash
adb logcat -d | grep -iE "appodeal|consent|UMP|FormError|AppLovinSdk|DynamiteModule"
```

Look for consent errors, adapter initialisation, `Has User Consent` values,
and per-format load failures. Reading logs is fine; never clear or stop apps.
