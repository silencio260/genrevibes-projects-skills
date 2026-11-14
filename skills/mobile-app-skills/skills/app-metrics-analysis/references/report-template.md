# Report template

Save the report in the app repo, for example
`docs/dau-retention-analysis-<YYYY-MM-DD>.md`, and give the owner the
headline in chat. Write for the owner, in plain language; put IDs and query
details in the Sources section.

```markdown
# <App> <topic> analysis — <date>

## The answer
Two to four sentences: why the number is what it is, and the one thing that
matters most. Say how sure you are.

## Sources and windows
- Each source: project/app id, date range, timezone, filters, whether the last
  day is complete.
- What could not be read, and why.

## The numbers
| Metric | Value | Source | Window |

## Where users are lost
Ordered funnel from new users (`first_open`), with users, % of new, and loss
at each step. Name the largest leak.

## What was ruled out
Each candidate cause, the evidence against it, and the number.

## Reliability and crashes
Crash-free figures, top issues (do not add issue user counts), whether
"fatal" means a dead process.

## Monetization
Per app, complete days only: revenue, impressions, requests, fill, eCPM, CTR;
by network, ad type and country. Test Ads separated. Which networks are absent
and why.

## Why the tools disagree
Only if relevant: see the discrepancy playbook.

## Measurement gaps
Events that never fire, dark steps, unregistered parameters, misleading
event names. What each gap prevents you from answering.

## Changes made
Every dashboard or code change, where, and what it now reads.

## Next actions
Ranked, each with what it will let the owner measure or fix.

## Limits and re-check dates
What is inferred rather than measured; when to look again (cohorts filling,
Play lag, crawler and review windows).
```

## Samples

Read one of the [sample reports](sample-reports/) before writing: the
[13 Nov written report](sample-reports/dau-retention-analysis-2026-11-13.md)
for a saved document, the [14 Nov chat report](sample-reports/ad-network-retention-2026-11-14.md)
for answering several questions in one reply.

## How to state findings

- Tag causal claims: **measured** (a number shows it), **inferred** (consistent
  with the numbers, not shown), **unverified** (a hypothesis with a named test).
- Quote the number and its window every time.
- When a finding replaces an earlier one, say once, plainly, what changed.
- Do not call traffic invalid, a network misbehaving, or a metric broken from
  one aggregate figure.
