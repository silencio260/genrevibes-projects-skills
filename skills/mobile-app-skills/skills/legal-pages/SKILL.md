---
name: legal-pages
description: "Write, publish, and record an app's privacy policy and terms of use, and keep the links in env, docs, and the store listing."
---

# Privacy policy and terms of use

Every portfolio app ships a privacy policy and terms of use at stable public
URLs. Google Play requires a reachable privacy policy for any app that collects
data, and this portfolio always collects data: Firebase Analytics cannot be
turned off, Crashlytics reports crashes, and most apps add Mixpanel and session
replay. The policy is the disclosure that makes that collection lawful, so it
is release-blocking, not paperwork.

Use the house style in
[privacy policy template](references/privacy-policy-template.md) and
[terms of use template](references/terms-of-use-template.md). Both are modelled
on the Lunaris Network pages, which are the current reference pair.

## The rule that matters most: describe the app that exists

Write the policy from the app's actual integrations, never by copying another
app's page and changing the name. An older portfolio page claimed location
collection and AI processing, and listed RevenueCat, Adapty, and OneSignal, in
an app that had none of them. An over-broad policy is its own compliance
problem: it tells Play and the user that the app collects data it never touches,
and it contradicts the Data safety form.

Before writing, read the app and confirm each claim:

| Claim in the policy | Verify against |
|---|---|
| Analytics and replay providers | `pubspec.yaml` dependencies and the sinks actually added to `AnalyticsPipeline` |
| Whether replay runs, and what it shows | `session_replay_enabled`, `session_replay_percent`, `session_replay_mask_text`, `session_replay_mask_images` in the live Firebase template |
| Ad networks | The configured mediation and its enabled demand, not the mediator's full catalogue |
| Push and notifications | Whether a push provider exists, or notifications are local only |
| Accounts, sign-in, deletion | Whether the app has auth at all |
| Permissions and device data | The platform manifests and the permissions skill |
| Contact address | The app's own support address, not another app's |

State the replay masking posture truthfully. This portfolio defaults replay
content to unmasked with remote controls, so when `session_replay_mask_text` or
`session_replay_mask_images` is `false`, the policy must say recordings include
on-screen text and images. Do not describe recordings as masked because the kit
once defaulted that way; read the published values. See
[session-replay](../session-replay/SKILL.md) and
[remote-config](../remote-config/SKILL.md).

Analytics is never consent-gated in this portfolio. Disclose collection as a
condition of use and do not offer an analytics opt-out the app does not have.
Ad consent is separate and belongs in the advertising section; see
[gdpr-compliance](../gdpr-compliance/SKILL.md).

An app with no accounts drops whole sections. A launcher with no sign-in has no
account records, no deletion flow, and nothing other users can see, so remove
those sections rather than leaving them as empty promises. The templates mark
which sections are conditional.

## House style

Both pages share one shape, and agents keep it:

- Title is `<App name> Privacy Policy` or `<App name> Terms of use`.
- First line is `Effective YYYY-MM-DD · Version YYYY-MM-DD`.
- An opening paragraph naming `GENREVIBES TECHNOLOGIES INC ("we", "us", "our")`,
  the app, and any website that is part of the service.
- An `In short` block of plain-language bullets before the numbered sections.
  It is a summary, so every line in it must also appear in the body.
- Numbered sections, sentence-case headings, short paragraphs, British spelling.
- A footer that cross-links the other page and the copyright line.
- A contact section with the company, the support email, and the in-app path.

Write for a reader, not a lawyer. These pages say what the app does in ordinary
words; that is why they are usable as a store disclosure. This skill does not
certify legal compliance, and an agent never invents a legal position the user
has not taken.

## Publishing on Google Sites

The user's pages live in their Google Sites account, reachable in the browser
(see the session's browser guidance). Publishing is outward-facing: show the
user the drafted content and get a clear yes before pressing Publish.

1. Open `sites.google.com` in the browser. The account is normally already
   signed in. If it is not, ask the user to sign in rather than entering
   credentials.
2. Create the site, or open the existing one for this app. One site per
   document keeps the slugs clean.
3. Set the site title and the page heading to the title in the house style, then
   put the drafted content in the page body.
4. Publish, and set the web address slug to a readable, lowercase, hyphenated
   name, for example `gravity-rolling-launcher-privacy-policy`.
5. Verify the result from the published URL, not the editor. A published Google
   Sites page lazy-loads its body, so read `document.body.innerText` after the
   page settles and confirm the whole document is there and the dates are right.
6. Copy the published link. An unpublished site reports
   `Can't copy link for unpublished site`; that message means step 4 did not
   finish, and the link does not exist yet.

### Google Sites silently discards automated text

Typing into a Google Sites text box often does not persist. The editor shows
the text, reports "All changes saved in Drive", and then reverts to empty on
reload. Publishing in that state pushes a blank page live, which for a privacy
policy is worse than having none.

Treat the save indicator as unreliable and verify by reloading the editor:

1. After filling a text box, reload the editor URL and confirm the text is
   still there. Only then publish.
2. After publishing, read the published `/view/` URL and confirm the body and
   the section order. The page lazy-loads, so wait before reading
   `document.body.innerText`.
3. Type in chunks of a few thousand characters, not one large insert. Between
   chunks press select-all then Right to put the caret back at the end;
   without it a chunk can land at the top and scramble the document.
4. The header page-title field rejects automated input entirely and always
   reverts. Leave it to the user.

Persistence has been observed to stop working part-way through a session, on
new sites as well as existing ones, while structural edits (adding or deleting
a text box) keep saving. When text stops persisting, stop retrying: publish
nothing blank, hand the user the plain-text file and ask them to paste it, and
say plainly which pages are still empty.

Google Sites is the default because the user already keeps pages there. An app
that has its own website can serve the pages from it instead, as Lunaris serves
its privacy policy from Firebase Hosting while its terms sit on Google Sites. In
that case the policy must still be reachable at a stable public URL, and the
`Our website` section names the actual host.

## Record the links in all four places

A published page nobody references does not satisfy anything. After publishing,
put the links in every place that consumes them, and tell the user which of
these an agent cannot do for them.

1. **Environment files.** Set `privacy_policy_url` and `terms_url` in each
   `env/<flavor>.json` that ships. These feed the in-app links, and an empty
   value means the app shows no policy. See
   [env-config](../env-config/SKILL.md).
2. **App docs.** Record them in the app's `docs/legal-pages.md`, using the
   format in [the doc template](references/legal-pages-doc-template.md), and
   link that file from `docs/` alongside the other app documentation. This is
   the record that survives a new agent with no memory of the session.
3. **Play Console.** The privacy policy URL goes in App content › Privacy
   policy, and the same disclosures must match the Data safety form. An agent
   cannot sign in to the Play Console on the user's behalf: hand the user the
   URL and say exactly where it goes.
4. **In-app.** Confirm the settings or about screen renders both links from the
   env values once they are set.

Report the published URLs to the user in the reply, not only in a file.

## Keeping them current

The effective and version dates change whenever the content does. Update both
pages when the app's data handling changes: a new analytics or ad provider, a
change to replay rollout or masking, a new permission, an account or deletion
flow, or a new third-party service. A policy that describes last quarter's app
is worse than none, because it is a specific and false statement.

When a page changes materially, say so in the app before it takes effect, as
both templates promise in their `Changes` section.

## Current portfolio state

Observed in the user's Google Sites account, for agents picking up this work:

| Page | State |
|---|---|
| Lunaris Network Terms of use | Published at `sites.google.com/view/lunaris-network-terms-of-use`; the reference for the terms template |
| Lunaris Network Privacy Policy | Google Sites copy is an unpublished draft; the live policy is served from Firebase Hosting at `lunaris-network.web.app` |
| Simple Phone Launcher Privacy Policy | Unpublished draft, older generated boilerplate; superseded by these templates and not a model to copy |

Treat the Lunaris pair as the house style. Do not reuse the Simple Phone
Launcher page's provider list or its location and AI sections.
