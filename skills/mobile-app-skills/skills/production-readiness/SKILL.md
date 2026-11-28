---
name: production-readiness
description: "Audit a portfolio app for production or release readiness, including product flows, reliability, security, packaging, monetization, Firebase, Mixpanel, session replay, AdMob, Appodeal and Meta/FAN where applicable. Use for requests such as audit this app, is it production ready, can I release it, check monetization and analytics readiness, or compare readiness across named portfolio apps. Separate confirmed defects from configuration gaps and unverified runtime or live service behavior."
---

# Production readiness

Audit the actual app and its selected services. Produce an evidence-backed release
decision, prioritized findings and the checks needed to close them. Include
monetization and measurement in a full audit from the beginning.

Use this workflow across portfolio apps without copying another app's identifiers,
versions, feature requirements, rollout percentages, deadlines or device matrix.
Adapt the checks to the app's platform and architecture. A reusable portfolio skill
does not authorize scanning or modifying every sibling project.

## 1. Establish the scope and current state

1. Read the applicable host and nested `AGENTS.md` files and the existing command
   recipes. Check the agents repository's freshness as its instructions require.
   If fetching fails, record the limit; do not describe the cached branch as current.
2. Inspect Git status in the app and shared repositories. Audit the working tree,
   including relevant untracked changes, unless a specific commit or deployed
   version was requested. Preserve unrelated work and record the revision/scope.
3. Identify the requested release stage, supported platforms, minimum OS versions,
   core user journeys, monetization model and selected providers. Default to public
   production readiness when the user simply asks whether the app is ready.
4. Read relevant existing audits, release notes and setup records, then verify their
   claims against current source, artifacts or live state. Treat dated TODOs as
   leads to investigate, not proof that setup is still incomplete.
5. Map app identity across package/bundle IDs, signing configuration, backend
   project, analytics app/stream, network app and environment files. Check presence
   and consistency without printing credentials or entire private configs.

An audit request authorizes inspection, not incidental fixes, dependency upgrades,
dashboard changes, ad requests, purchases, publication or resets of the owner's
installed app. Continue independent work when one check is blocked. Do not ask for
permission already covered by the user's instructions.

## 2. Keep evidence dimensions separate

Use a compact table with the applicable components and these dimensions:

| Dimension | What establishes it |
|---|---|
| Source/configuration | Follow the actual call sites, adapters and environment values. |
| Packaged candidate | Inspect the exact release artifact, merged configuration and dependency graph. |
| Runtime | Observe the relevant action and result on a named build/device. |
| Live service | Verify the correct account/project, request or event ingestion, reporting and eligibility. |

Mark each dimension **verified**, **failed**, **unverified** or **not applicable**,
with the evidence and date where useful. One component can have verified source
wiring and failed live delivery at the same time. A local dispatch result does not
prove dashboard ingestion; a dashboard metric does not prove the newest build sent it.

- Tie artifact, device and dashboard evidence to package, version, build mode and
  environment. Record a candidate checksum where available.
- Separate a reproducible code defect, an observed runtime failure, a verified
  account/configuration gap, an unverified condition and an optional improvement.
- Do not convert a failed CLI, inaccessible page or DNS error into a claim that the
  service is down or misconfigured. Record the attempted read and its actual result.
- Do not infer production readiness from analysis success, test filenames, installed
  packages, a successful debug build, adapter declarations or historical screenshots.

## 3. Inspect flows and failure paths

Use [release and product checks](references/release-and-product.md) for the applicable
domains. Follow each important operation from UI intent through state, persistence,
native/backend work and the final user-visible result. Inspect shared kit behavior
and native code when the app delegates to them.

For every suspected defect:

1. Establish the entry condition and reachable sequence on the current code.
2. Read the guards, state transitions, exception paths, cleanup, retries and caller
   handling before claiming the outcome. Distinguish a rejected transition from a
   completed side effect: a guard may preserve the record while leaving an orphan file.
3. State the user/business impact and whether it is source-derived or reproduced.
4. Include a correction direction and an acceptance action with an observable result.
5. Recheck contrary evidence and narrow or withdraw the claim when necessary.

Look for invariants across interruption and upgrades: one owner per operation,
bounded work, truthful outcomes, recoverable persistence and no duplicated side
effects. A timeout releases a waiter; it does not necessarily cancel native work.
Check cleanup on thrown errors as carefully as on successful returns.

## 4. Audit monetization and measurement end to end

Read [monetization and measurement checks](references/monetization-and-measurement.md)
even when the user did not enumerate the SDKs. Apply only the selected providers.
Include ads, purchases when offered, event coverage, revenue ownership, retention,
replay, Firebase services, production configuration and account eligibility.

Discover available connectors/APIs/CLIs proactively. Prefer an applicable connector;
use the authorized browser when needed and available. Try a relevant read before
claiming data is inaccessible. Use current official provider documentation for
uncertain SDK behavior and time-sensitive store/network requirements. Do not
substitute search results for authenticated account state.

Preserve deliberate app choices. Read the existing [ads](../ads/SKILL.md),
[consent](../gdpr-compliance/SKILL.md), [analytics](../analytics/SKILL.md) and
[replay](../session-replay/SKILL.md) policies when reviewing those integrations.
In particular:

- Distinguish continue-on-error SDK initialization from permission to make a
  particular ad request. A `failOpen` flag alone does not establish a defect or a
  consent grant. Trace the app and SDK behavior, including independent providers.
- Do not turn the audit into an analytics consent/opt-out implementation. Preserve
  the portfolio's analytics policy and the app's selected replay rollout. Verify
  actual handling and disclosures; do not certify legal compliance from local policy.
- If a current official requirement conflicts with repository guidance, report the
  precise conflict and evidence. Do not silently change either policy or label an
  intentional timeout as a proven violation without establishing the request path.
- Do not recommend adding ad networks, reducing replay sampling, increasing ad
  frequency or adding IAP solely because another portfolio app uses them.

## 5. Run the checks already authorized

Start with targeted reads and available static checks. Use documented commands for
the app's own toolchain, environment, flavor and target. Record the exact command,
scope, exit status and relevant output; never print secrets.

Respect the repository's test/build rules and the user's existing authorization.
A generic audit does not override an explicit rule that reserves builds, test
suites or new test files for a separate request. Record the exact deferred command
and why it was not run; do not stop the entire audit or repeatedly ask to run it.
Conversely, do not ask again for a command the user already authorized.

When permitted and relevant, verify in this order:

1. Static analysis and focused source/configuration consistency checks.
2. Existing targeted tests and native lint for the affected behavior.
3. A signed release candidate and its actual artifact gates.
4. Device/emulator journeys and interruption/upgrade/accessibility cases.
5. Live event, crash, replay, backend and monetization results for that candidate.

Adapt this order to the available evidence. Never run `flutter clean`, delete caches,
disable checks, fabricate metadata or replace signing identity to make an audit pass.
Do not classify a missing local keystore as a global signing failure when the intended
CI/release machine supplies it. Source manifest checks do not verify a merged manifest.
Do not repeat broad checks after they pass unless new changes or uncertainty justify it.

## 6. Give a useful release decision

Lead with one verdict for the requested stage:

- **Ready for the requested stage:** applicable critical checks have current evidence;
  state any accepted limitations and who accepted them.
- **Not ready:** confirmed defects or verified unmet requirements prevent that stage.
- **Not yet verified:** evidence needed for approval is unavailable, without inventing
  a confirmed product failure. State which dimension prevents approval.

Distinguish suitability for internal testing from approval for public production.
Do not assign an arbitrary readiness percentage or use a checklist count as a score.

Present:

1. The verdict, scope and the most consequential reasons.
2. A component table covering product/release health and selected monetization,
   analytics, replay and backend services, with verified versus unverified states.
3. Prioritized findings: severity, evidence location, trigger, impact, confidence,
   correction direction and acceptance check. Keep hypotheses separate.
4. Checks that passed, commands not run and material access limits.
5. The shortest ordered path to the next release decision, separating app fixes,
   account work and verification. Avoid recommending features already implemented.

Use severity based on reachability and impact, not on the provider name. Reserve
high severity for credible crashes, data loss, costly unintended operations,
unusable core flows or substantiated release/security/compliance failures. Explain
business-measurement risk separately from a defect preventing the app from running.
Do not flag deferred CI as a release blocker under this repository's policy.

Return the findings in chat by default. Create or update an app audit document only
when the user requests a written report or an applicable project rule explicitly
requires one. Avoid creating a dated Markdown file for every observation or routine
edit. Keep reusable audit methodology in this skill, not copied into every app.

For a requested multi-app audit, use one row per app with its own revision,
environment, evidence limits and blockers. Do not transfer one app's live verification
or account approval to another. Do not delegate work unless the user or an applicable
instruction explicitly authorizes delegation.
