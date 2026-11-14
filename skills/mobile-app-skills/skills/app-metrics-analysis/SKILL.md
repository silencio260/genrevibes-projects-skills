---
name: app-metrics-analysis
description: "Analyse a live app's numbers across Firebase/GA4, Crashlytics, Mixpanel, Appodeal, AdMob, Meta Audience Network, Google Play and the app's own tracked events: explain DAU, retention, funnel leaks, revenue and why the tools disagree, using the owner's signed-in browsers without asking for site access."
---

# App metrics analysis

Use this skill when the owner asks any of:

- "Why is my DAU / retention / revenue that number?"
- "Analyse my app using Firebase, Mixpanel, Appodeal, AdMob, Play…"
- "Why do Firebase, Mixpanel and Appodeal show different numbers?"
- "Who is winning my ad auctions / why is network X not bidding?"
- "Is my app tracking X?" or "what events should I add?"
- "Is network X serving on the new version?" or "does the new version still leak?"
- "Why so few ratings for my numbers?"

It covers how to reach the data, the order to analyse it in, how to tell a
real leak from a measurement artifact, and how to report it. The detail lives
in references; read the ones the task needs:

| Need | Read |
|---|---|
| URLs, clicks and gotchas for each dashboard, plus CLI/API access | [source runbook](references/source-runbook.md) |
| Why two tools give different numbers, and how to compare them fairly | [discrepancy playbook](references/discrepancy-playbook.md) |
| Report layout and how to state findings | [report template](references/report-template.md) |
| Two finished reports the owner liked, to copy the tone and structure from | [written report, 13 Nov](references/sample-reports/dau-retention-analysis-2026-11-13.md), [chat report, 14 Nov](references/sample-reports/ad-network-retention-2026-11-14.md) |
| The full recorded analysis this skill was built from: every step, number, wrong turn, correction and follow-up | [Gravity Rolling Launcher case study, Nov 2026](references/case-study-gravity-2026-11.md) |
| The follow-up analysis: ads by app version, new-version funnel on its first day, consent state, ratings, cohort retention | [second case study, 14 Nov 2026](references/case-study-gravity-2026-11-14-ads-versions.md) |

## Site access: don't ask, go

The owner is signed in to every dashboard this skill uses and has said that
asking for permission to open them wastes their time. So:

- **Never stop to ask "may I open X?"** Navigating to a dashboard and reading
  it needs no chat permission. Open what the analysis needs and keep going.
- **Use the built-in browser first** (the desktop app's browser pane,
  `mcp__Claude_Browser__*`), if this agent has it. If a site is not signed in
  there, shows a sign-in page, or will not load, **switch to Claude in Chrome**
  (`mcp__claude-in-chrome__*`, the owner's real Chrome) without asking. If
  Chrome is the only browser available, use it from the start.
- Last recorded sign-in state (November 2026): Appodeal, Firebase, GA4, AdMob
  and Play Console were signed in in the built-in browser; Mixpanel was signed
  in only in Chrome; Meta was used in Chrome. On 14 November the built-in
  pane was closed, so the agent checked `list_connected_browsers` and used
  Chrome. Re-check rather than trust this.
- If the browser itself shows a **site-permission prompt** (the Chrome
  extension's per-site allow), that is a one-click allow that only the owner
  can give; the agent cannot grant it. Say in one line which site is waiting,
  and carry on with other sources meanwhile instead of stalling.
- If Chrome reports **"not connected"**, say so once, continue with every other
  source, and retry when the owner says it is back. Do not loop on retries.
- Never sign in, type a password, or take a one-time code for the owner.

**Reading is free; changing is not.** The no-ask rule covers opening and
reading. These still need the owner's yes in chat, every time: changing a
dashboard setting (timezone, custom dimensions, consent messages, store
listing), publishing, submitting a form or a review, deleting anything, and
anything involving money, payouts or credentials. Once the owner says yes to a
change, do it fully and verify it saved (reload and read it back).

Global rules still apply: do not build, install or run the app; never
uninstall, clear, force-stop or disable an app on the owner's phone. Reading
`adb logcat` from an app the owner installed is fine.

## Workflow

Do the phases in order. Each one changes how you read the next.

### 1. Read the app before the dashboards

The dashboards show what was sent; the code shows what *could* be sent. Before
opening any dashboard:

1. Find the analytics facade and event catalogue (for example
   `lib/core/analytics/app_events.dart`) and the pipeline that fans events out
   to the sinks (for example `AnalyticsPipeline` in `lib/bootstrap/app_runtime.dart`).
2. **List every helper and count its call sites.** A helper with zero call
   sites is an event that never fires. Gravity's `app_open` had none.
3. Find what is automatic in each tool. Firebase adds `first_open`,
   `session_start`, `user_engagement`, `screen_view`, `app_remove`,
   `app_exception`; the Mixpanel Flutter SDK adds nothing.
4. Check identity (same install id to every sink?), consent gating (analytics
   should not be consent-gated), kill switches, and the route observer (unnamed
   routes are usually not logged, so a `home:` widget may never produce a
   screen view).
5. Read the code path from launch to the product's key action (for a launcher:
   splash → onboarding → set default → tutorial). Note which steps emit an
   event and which are dark.
6. Read the live remote config (`firebase remoteconfig:get`) **and then check
   that the app actually reads each key you plan to cite.** Gravity declared
   `splash_ad_*` keys that nothing under `lib/` read.
7. Read the **ad routing**: which format goes to which network (Gravity sends
   App Open to AdMob directly and everything else to Appodeal), and which ad
   unit ids are live versus placeholders. "Network X only earns on format Y"
   is often by design.
8. For rating questions, read what **Yes** does: native in-app review sheet
   or a jump to the store listing, and whether opening the listing is recorded
   as "rated" and stops future asks.
9. Note the app version and, from Play, **when each version reached users**.
   A version that is hours old has no D1, and its early updaters are not a
   random sample.

### 2. Get access

1. Try CLI/API first for anything scriptable: see
   [source runbook → CLI and API](references/source-runbook.md#cli-and-api-access).
   GA4 needs an analytics-scoped credential the plain gcloud token lacks; there
   may be no BigQuery export; Mixpanel and Appodeal usually have no read
   credentials on the machine. The GA4 credential **expires**; if it is gone,
   give the owner the login command and carry on in the browser meanwhile.
2. Whatever the CLI cannot reach, read in the browser under the
   [site access rules](#site-access-dont-ask-go). Don't ask the owner to hand
   over API secrets when their signed-in browser already has the data.

### 3. Collect, with the window written down

For every number, record the **source, date range, timezone, app filter, and
whether the last day is complete.** Without these, numbers from two tools
cannot be compared. Typical set:

| Source | Collect |
|---|---|
| Firebase overview | DAU, 7/30-day actives, new vs returning, D1 retention card and *its* window, engagement time |
| GA4 events report | per-event event count and **unique users** for the funnel events |
| GA4 Explore | path exploration from `first_open`; closed funnel of the key steps, split by app version |
| Crashlytics | crash-free users and sessions, top issues with events and users, the stack of the top issue |
| Play Console | installs, installed audience, uninstalls, vitals, **ratings count**, version rollout dates; note the reporting lag |
| GA4 Reports → Events | same-day and per-version counts: date Today, secondary dimension App version |
| GA4 cohort exploration | daily cohorts with D1/D2/D3 by install day |
| Mixpanel | uniques per day for one app-sent event; project timezone; project creation date |
| Appodeal | per app: revenue, impressions, requests, fill, eCPM, CTR, split by network, ad type and country; Test Ads rows |
| AdMob | app status, ad serving, Privacy & messaging (consent messages per app); Reports → AdMob Network by **app version × ad unit**: requests, match rate, impressions, show rate, eCPM |
| Meta Monetization Manager | Issues page, property status, verification and review state |
| Device log | `adb logcat` from the release build on the owner's phone, when ad networks misbehave |

### 4. Analyse

1. **Get the denominator right.** Retention and funnels start from new users
   (`first_open`), not active users. Gravity had 199 active but 155 new; using
   199 inflated every leak.
2. **Build an ordered funnel**, not a list of event totals. Aggregate
   unique-user counts per event are not a funnel: users repeat steps, skip
   them, or were onboarded before the window. Use a GA4 closed funnel
   (`first_open` → each key step) and read the biggest step-to-step loss.
3. **Rule causes out with evidence before naming one.** For each candidate
   (crash, version, ads, consent, slow start), find the number that would prove
   or disprove it. A path exploration showing `first_open` → `session_start` →
   `screen_view` for 98.7% of users rules out "the app crashes on launch".
4. **Check whether an alarming metric is real.** Crashlytics "fatal" may be a
   flag the app's own crash hook sets, not a dead process. Check the arithmetic
   too: if 144 users hit an exception and 106 completed the next step out of
   198, at least 52 did both, so the exception did not stop them.
5. **Check the time shape.** If 7-day actives ≈ 30-day actives, the audience
   is days old and retention cohorts are mostly unfilled.
6. **Reconcile tools** with the [discrepancy playbook](references/discrepancy-playbook.md)
   before calling any of them wrong.
7. **For ads**, split by network × ad type × country before blaming a network
   (see also the [ad CTR investigation](../ad-ctr-investigation/SKILL.md)). A
   network with zero *requests* is not losing the auction; it is not in it.
   Look at the device log early: one log line settled what three dashboard
   theories had not.
8. **For a new version**, compare it with the old one on the same steps, using
   Reports → Events with App version (Explorations have no same-day data).
   Report it as a first-day signal, with the user count, until a full funnel
   and a D1 exist.
9. **A fix made in a dashboard is not live until a metric shows it.** Find
   the event that proves it (for consent: `consent_resolved` state turning
   from `unknown` to `obtained`/`notRequired`) and say when to re-read it.
10. **For ratings**, compare people who answered the in-app prompt with the
    store's rating count before blaming the app's quality.

### 5. Report

Use the [report template](references/report-template.md). Lead with the answer
in plain language, then the numbers with their windows, the leaks ranked by
size, what was ruled out and how, the measurement gaps, and the next actions.
Mark every causal claim as measured, inferred, or unverified.

### 6. Follow-ups the owner usually asks for

These came up in the recorded analysis, in this order. Be ready for them:

- "According to this URL my D1 is X%": open the URL and read exactly what it
  shows, including its window, before defending your own figure.
- "Was it so bad users couldn't continue?": answer with the arithmetic.
- "How do you know users saw an ad?": only claim exposure you measured.
- "What events would you add, and where?": name file, widget and condition for
  each, ranked by what it would let them answer.
- "Why do the tools disagree?": compare one app-sent event on one complete day.
- "Who is winning the bids and why is X not bidding?": network × country split,
  then account, consent, app-ads.txt, device log.
- "Is network X on the new version?": split its report by app version and ad
  unit.
- "Does the new version still leak?": same steps, per version, same day.
- "Why so few ratings?": prompt answers vs store ratings, then the Yes path.
- "Fix it / register them / align it": the change needs a yes; once given, do
  it and read it back.

## Rules learned the hard way

Each of these was a real mistake in the recorded analysis. Read the
[case study](references/case-study-gravity-2026-11.md#wrong-turns-and-corrections)
for the detail.

1. **Don't read a config value as user experience.** An "ad wall" was asserted
   from remote config keys that the app never read, and first-run users got no
   ad at all. Check the code path and the condition that gates it.
2. **Don't say a metric doesn't exist until you've looked at the card the
   owner is looking at.** The D1 retention card was on the Firebase overview.
3. **Compare date ranges before comparing totals.** Play's "2 installs" was
   the first two days of a curve whose later days had not been reported yet.
4. **One hypothesis at a time, each with a test.** AdMob's zero requests got
   three wrong explanations (app-ads.txt placeholders, account config, SDK
   version skew) before a device log showed the missing consent form.
5. **app-ads.txt cannot stop a network from requesting.** It affects whether
   buyers pay for the impression, not whether the SDK asks.
6. **A consent failure can be global.** A missing UMP form fails the account
   lookup for every user, EU or not.
7. **Help-centre wording is not the form.** Meta's "phone, email or domain"
   applied to one step; the business-details step still demanded an owned
   domain. Test the real form before advising.
8. **Ask the tool what blocks it.** Meta's Monetization Manager → Issues page
   listed the real blockers (missing app URL, unconfirmed email). Business
   verification, which consumed an hour, was not one of them.
9. **Before a click on a form, re-screenshot anything that may have reflowed.**
   A banner that appears after ticking a box shifts every row; coordinates from
   the old screenshot hit the wrong app.
10. **Registering a GA4 custom dimension is not retroactive.** Parameters sent
    before registration cannot be broken down later, and without BigQuery
    export they cannot be recovered.
11. **GA4 Explorations have no same-day data.** A funnel for "today" shows
    step 1 and zeros, which looks like a collapse. Use Reports → Events.
12. **Boolean event parameters arrive as (not set) in GA4.** Send
    `'true'`/`'false'` strings or ints.
13. **Don't quote retention for a version younger than a day,** and don't
    treat early updaters as representative.

## Leave the owner with

- The report, saved in the app repo (for example
  `docs/<topic>-analysis-<YYYY-MM-DD>.md`).
- Every change made in a dashboard, with where and what it now reads.
- What is still unverified, and the date to re-check it (cohorts filling,
  Play reporting lag, consent propagating, crawlers, app review).
