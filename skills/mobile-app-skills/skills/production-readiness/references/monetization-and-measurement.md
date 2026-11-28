# Monetization and measurement checks

Check the app's chosen providers, including alternatives to Firebase, Mixpanel,
AdMob, Appodeal and Meta/FAN. Inspect the installed adapter/SDK versions and the
current accounts. Do not copy another app's credentials, rollout or network preset.
Keep source wiring, packaged SDKs, runtime callbacks and live reporting separate.

## Monetization architecture and demand

- Map each earning opportunity to its trigger, format, provider, placement/unit,
  eligibility and frequency policy. Identify which formats have real UI callers.
  A rewarded API without an offer earns nothing from rewarded usage; it is not
  automatically a missing product requirement. Apply the same reasoning to IAP.
- Trace loading/preloading, SDK startup order, readiness, no-fill, load/show timeout,
  background/resume, covered routes, ad clicks and cache expiry. Check whether an
  opportunity window includes consent, initialization and loading, and distinguish
  a deliberate UX/revenue tradeoff from a proven implementation bug.
- Check test/live inventory selection, sample versus production IDs, owner test
  devices and release flags. Do not request live ads, click them or alter inventory
  mode merely to inspect code; use a separately authorized diagnostic path.
- Trace consent required/not-required/prior-answer/failure/timeout paths and privacy
  options for every independent provider. Preserve real SDK signals. An app can
  continue initializing after a failed consent attempt without fabricating consent;
  establish how the specific SDK permits or withholds requests before judging it.
- Review accidental-click spacing, full-screen overlap, pacing and placement context.
  Prefer current store/provider rules over remembered universal limits. Do not increase
  frequency to address low revenue without data about the current opportunities.

For Appodeal with direct AdMob App Open, keep these paths distinct:

| Path | Evidence needed beyond the app code |
|---|---|
| Direct AdMob unit | Correct app/unit, approval/store association, request/fill/display and paid callback. |
| AdMob mediated by Appodeal | Packaged compatible adapter plus current account/Sync, per-format line items and actual requests/results. |
| Meta/FAN mediated by Appodeal | Correct developer-app identity/credential link, placement mapping, header bidding and required bridge, eligibility and current request/fill evidence. |
| Other mediated demand | Applicable account or Appodeal-supplied account, packaged adapter, enabled format and request results. |

Direct AdMob earnings do not prove AdMob participates in Appodeal auctions.
An installed Meta adapter does not prove FAN bids or wins. Absence of wins alone
does not prove no requests or no bids. For the installed integration, verify the
documented bridge path; Meta demand may participate through BidMachine.
Distinguish requested, eligible, bid/no-bid, won and filled when the tools expose them.

Check app-ads.txt discovery/verification, store/package association, network review,
business/app verification, per-format enablement and reporting-account linkage where
required. Treat a dated setup record as historical evidence until current state is
read. Do not invent a missing integration because mediated unit IDs live remotely
rather than in Dart. Never enable a larger adapter preset solely to improve a score.

Use [ads](../../ads/SKILL.md),
[Appodeal account setup](../../appodeal-browser-setup/SKILL.md),
[consent](../../gdpr-compliance/SKILL.md) and the applicable network references.

## Revenue ownership and reconciliation

- Trace one displayed impression through the winning SDK callback, adapter, app
  event, every analytics sink, dashboard and any acquisition/conversion import.
  Count subscriptions and identify the single owner for each emission.
- Separate request, load, impression, paid/revenue, click, dismissal and earned
  reward outcomes. Do not use `ad_loaded` as an impression or a button press as a sale.
- Check currency, units/micros conversion, format, placement, source/network,
  precision, event time and version/environment attribution. Do not replace missing
  paid values with zero or fabricate revenue in app code.
- If an existing adapter estimates from predicted eCPM, retain its estimate marker
  and quantify estimated versus SDK-reported coverage. Review late-report handling,
  duplicates and lost callbacks after backgrounding/process death. An SDK-reported
  value can itself be estimated; it is not necessarily finalized payable earnings.
- Check automatic AdMob/Firebase revenue collection alongside manually emitted
  `ad_impression` events. Review the actual account links and provider ownership.
  Report double counting as conditional until overlapping paths are established;
  do not blindly unlink accounts or delete all manual mediated-network revenue.
- Compare the same app/version, time window, timezone, currency and live/test
  inventory across reports. Explain known processing lag/invalid-traffic adjustments.
  Reconcile network earnings, analytics totals and exported conversion values before
  treating the data as reliable LTV/ROAS inputs. Do not promise exact dashboard equality.
- Inspect request/no-fill/show-failure observability. A low impression count cannot
  identify demand, readiness, pacing or eligibility without those denominators.

For purchases/subscriptions, when offered, inspect product/entitlement mapping,
store validation, pending/cancelled outcomes, restore, renewal, expiry, refund,
offline access and duplicate callbacks. Do not test by making real purchases or
changing production products without the relevant authorization.
Use [IAP](../../iap/SKILL.md), [paywalls](../../paywall/SKILL.md) and
[content access](../../content-locking/SKILL.md).

## Product events, funnels and retention

- Inventory the events actually emitted, not just constants or a developer catalogue.
  Follow their success/failure trigger, payload, identity, sink and initialization.
  Keep provider-owned automatic lifecycle events distinct from custom events.
- Check coverage of the actual acquisition-to-value journey: first open, onboarding
  steps/completion, permissions, first core attempt/result, return use, monetization
  and failure/remediation. Avoid a universal event list unrelated to the product.
- Check lifecycle meaning. An `app_opened` event emitted once during process startup
  is not automatically an event for every foreground session. Main-tab selection
  is not comprehensive screen tracking. Account for automatic SDK events where present.
- Examine native services, receivers and worker isolates that run without Flutter.
  Verify durable outcome capture, later drain, event time and deduplication. Replaying
  a finished task into UI state is not analytics backfill if the emitter only reports
  transitions observed during the current runtime. Inspect retries and migration too.
- Inspect startup races, disabled/failed sinks, event buffering, retries and flush.
  An SDK accepting an event locally is not remote ingestion; lack of app-owned retry
  does not prove loss when the vendor SDK already persists accepted events.
- Check anonymous/identified identity, reinstall/reset behavior, event-to-replay
  correlation and development traffic. Shared projects require reliable segmentation;
  do not silently create new projects as an audit fix.
- Distinguish insufficient diagnostic coverage from absent baseline retention.
  Firebase can supply automatic engagement/retention even when custom funnel events
  are missing. Do not infer D1/D7, DAU, churn or campaign quality from code alone.
- For observed metrics, state dates, sample size, app versions and cohort definition:
  acquisition source, country, new versus returning, exact-day versus rolling
  retention, timezone and delayed data. Avoid causal conclusions from aggregates.

Use [analytics](../../analytics/SKILL.md),
[typed app events](../../analytics-extension-layer/SKILL.md),
[retention](../../tracking-retention/SKILL.md),
[rating](../../app-rating/SKILL.md) and the selected notification skills.

## Session replay

- Inspect token/project, supported SDK/platform, root wrapper, initialization order,
  stable identity and actual SDK recording status. Keep requested policy, applied
  startup configuration and currently recording state separate.
- Verify rollout bucket stability, percent/master switch, developer overrides,
  sampling ownership, app background/resume and teardown. Prevent accidental double
  sampling; do not assume an enabled policy means the recorder successfully started.
- Check targeted masking for text inputs/passwords, cookies/auth screens, passcodes,
  feedback, logs, URLs and user media. Include modal routes/platform views that can
  live outside a masked subtree. Verify on actual replay output when authorized.
- Record the app's selected rollout and global masks without treating 100% rollout
  or ordinary unmasked UI as an automatic defect. Check data handling and applicable
  disclosures against current provider/store requirements.
- Describe replay's practical diagnostic limits. Fully masked browser/player regions
  may preserve privacy while hiding the content needed to explain a failure; use
  safe product events for those outcomes rather than removing sensitive masks.
- Inspect cellular/Wi-Fi upload policy, upload interval, local queue quota, device
  performance and paid usage. Measure overhead on representative devices; do not
  invent a cost/battery regression or reduce the owner's rollout without a request.
- Verify remote-off, foreground restart, identity correlation, stricter mask changes,
  SDK command failure and published privacy disclosures. Distinguish local policy
  sources from what users can currently read.

Use [session replay](../../session-replay/SKILL.md).

## Firebase and other operational services

- Verify native/Dart app registration and project/stream consistency for the intended
  package/build. Check analytics collection state, DebugView/ingestion, reporting links
  and development segregation. Do not dump client configs or admin credentials.
- Check Crashlytics initialization/hooks, handled versus fatal classification,
  environment controls and symbols/mapping uploads. Confirm a controlled report
  from the candidate when authorized; a configured hook is not delivery evidence.
- For Remote Config, distinguish bundled, cached, fetched and effective values.
  Check validators, defaults, activation, fetch cadence and propagation to the feature.
  Do not call a kill switch fleet-immediate if devices refresh only at startup or
  after a cache interval. Read before proposing an upload; never overwrite live
  conditions/keys as an incidental audit step.
- For App Check, verify provider/environment/certificate setup and backend validation
  with a request from the intended distribution channel. Successful Firebase startup
  does not establish Play Integrity or protected-backend operation.
- For databases, storage, functions and notification providers, inspect authorization,
  rules, quotas, delivery/failure reporting and actual use where selected. Do not flag
  unused Firebase products as missing mandatory services.

Use [Firebase infrastructure](../../firebase-infrastructure/SKILL.md),
[crash reporting](../../crashlytics/SKILL.md) and
[Remote Config](../../remote-config/SKILL.md).
