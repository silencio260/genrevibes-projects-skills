# App docs template: docs/legal-pages.md

Copy this into the app's `docs/legal-pages.md` and fill it in when the pages are
published. Keep it accurate about what is *not* done — an agent reading this file
later treats it as the record of truth.

---

# Legal pages

Privacy policy and terms of use for <App name>, and where their links are
recorded. Maintained per
[legal-pages](../agents/skills/mobile-app-skills/skills/legal-pages/SKILL.md).

## Published URLs

| Page | URL | Host | Effective / version |
|---|---|---|---|
| Privacy policy | <url, or "not published"> | <Google Sites / Firebase Hosting> | <YYYY-MM-DD> |
| Terms of use | <url, or "not published"> | <Google Sites / Firebase Hosting> | <YYYY-MM-DD> |

## Where the links are recorded

| Destination | State |
|---|---|
| `env/release.json` › `privacy_policy_url` | <set / empty> |
| `env/release.json` › `terms_url` | <set / empty> |
| Other shipping flavors | <which, and whether set> |
| Play Console › App content › Privacy policy | <submitted / pending — user action> |
| Play Console › Data safety form | <matches policy / pending> |
| In-app settings or about screen | <renders both links / not verified> |

## What the policy currently discloses

Keep this short, and update it whenever the app's data handling changes, because
it is what makes a stale policy visible:

- Analytics providers: <list>
- Crash reporting: <provider>
- Session replay: <provider, rollout percent, and whether text/image masking is on>
- Ads: <mediator and networks, or "none">
- Accounts: <yes/no; deletion path if any>
- Permissions with privacy impact: <list, or "none">

## Open items

<Anything outstanding, e.g. an empty env URL, a pending Play Console submission,
or a disclosure that no longer matches the app.>
