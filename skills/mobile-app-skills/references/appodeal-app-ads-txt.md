# app-ads.txt authorization for Appodeal mediation

Appodeal mediates most networks through its own seller relationships. Only the
networks connected with the publisher's credentials -- usually AdMob and Meta --
need the publisher's own identity authorized, and that authorization is
app-ads.txt. Publish it. It raises programmatic demand and price, and Meta's
own prerequisite list requires it.

## What it does not do, and the mistake to avoid

**app-ads.txt cannot stop a network from requesting.** The SDK sends requests
before any buyer evaluates authorization. A network showing **zero network
requests** is therefore never an app-ads.txt problem, no matter how wrong the
file is -- it is missing from the waterfall, has no ad units, or its adapter is
not initialising. Reach for this file only when a network *is* requesting and
not winning, or is winning at an implausibly low price.

Read the two signals apart before concluding anything:

| Observation | Means |
|---|---|
| 0 network requests | Not in the auction. Configuration, not authorization. |
| Requests, no impressions | In the auction and losing, or declining to bid. |
| Requests, wins, tiny eCPM | Bidding, discounted. Price problem. |

On Gravity Rolling Launcher this distinction was the whole answer and it was
got wrong first: AdMob showed **zero requests** while its own dashboard had the
app **Ready, ad serving enabled, Google Play linked, 41 active ad units**, so
AdMob was healthy and app-ads.txt was irrelevant to it. Meta meanwhile had
3 requests, 2 impressions and a 100% competitive factor -- it was bidding and
winning whenever invited, just rarely invited. Neither was blocked by the file.

## Diagnose it in three readings

1. **Mediation Setup > Ad Networks, "Default Account" column.** Networks that
   show the owner's email are on their own account; the rest say
   "Appodeal account". The non-bidding networks will be the former.
2. **Analytics > Monetization, Split: By Ad Network, Table View with
   Network (Monetization).** Apply the table above. Zero requests sends you to
   the waterfall and ad-unit configuration, not here. Also check the network's
   own dashboard before blaming mediation -- AdMob will show the app's approval
   status, whether ad serving is enabled and how many ad units are active.
3. **Mediation Setup > App-ads.txt.** Appodeal's generated file ships with
   literal placeholders on exactly the two lines that matter:

       google.com, Publisher_ID, DIRECT, f08c47fec0942fa0
       facebook.com,Business_ID,RESELLER,c3e20eee3f780d68

   Every other line already carries real ids.

## Finding the ids without asking the owner

- **AdMob publisher id** is derivable from the app id already in the env file.
  `admob_app_id_android` has the form `ca-app-pub-<16 digits>~<10 digits>`; the
  publisher id is `pub-<those same 16 digits>`. No dashboard visit needed.
- **Meta business id** is at `business.facebook.com/settings/info`, printed as
  "Business portfolio ID" and repeated in that page's `business_id=` URL
  parameter. Appodeal does **not** store it — its Meta account settings hold
  only the email.

`RESELLER` is correct for Meta when monetizing through a mediation partner,
which is why Appodeal's template uses it rather than `DIRECT`.

## Never publish a partial file

app-ads.txt is an allowlist. A file containing only the AdMob and Meta lines
**de-authorizes** every Appodeal-mediated network that was working, which is
strictly worse than publishing nothing. Always start from Appodeal's complete
generated list and change only the placeholder lines.

Copy it with the dashboard's **Copy to Clipboard** button and read the
clipboard (`pbpaste > file` on macOS). The **Download** button fires but the
file does not reach the filesystem when the browser is being driven
automatically. Blank lines in the copied text are an artifact of the HTML view
and are safe to strip; the IAB spec ignores them.

## Where it can be hosted

The file must be served at the **root of the host**, and that host must match
the Website field in the store listing. These do not work:

- **Blogspot** 301-redirects `/app-ads.txt` to `/ads.txt`, a different file.
- **Google Sites** (`sites.google.com/...`) cannot serve a file at a root the
  publisher controls.
- **GitHub Pages project sites** serve at `username.github.io/repo/`, a
  subpath. Only a user site (`username.github.io`) is at a root.

**Firebase Hosting is the path of least resistance**, because every Firebase
project already has a site at `<project-id>.web.app` and the CLI is usually
already authenticated. Add to `firebase.json`:

```json
"hosting": {
  "public": "hosting",
  "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
  "headers": [
    { "source": "/app-ads.txt",
      "headers": [{ "key": "Content-Type", "value": "text/plain; charset=utf-8" }] }
  ]
}
```

Two hazards:

- **Deploy with `firebase deploy --only hosting`.** Portfolio apps keep a
  `remoteconfig` block in the same `firebase.json`, and a bare `firebase deploy`
  pushes `config/remote_config.json` to production Remote Config as a side
  effect, local edits included.
- **Give the site a root page.** A Hosting site with only `app-ads.txt` returns
  404 at `/`. Pointing a store listing's Website at a 404 is bad for users and
  invites a policy flag, so ship a small `index.html` with the app name,
  the store link and the privacy/terms URLs. Add `.firebase/` to `.gitignore`.

## Then wait, and expect Meta to lag

Set Play Console > Store settings > **Store listing contact details > Website**
to the hosting URL. That field publishes immediately rather than entering
review. Google and Meta then have to crawl: 24-48 hours, sometimes a week.

AdMob usually returns first. Meta additionally requires business verification,
a reviewed store listing and the Basic-settings URLs — see
[Linking Meta Audience Network to Appodeal](meta-audience-network-appodeal.md).
An unverified portfolio will not serve no matter how correct the file is.

## Do not blame the high-fill network

The network that looks like it is hoarding inventory at a near-zero eCPM is
usually just the last bidder standing. Before concluding anything, split the
same date range **by country**: if even tier-1 impressions clear at cents, the
problem is demand starvation, not that network. Other things that depress the
clearing price far more than mediation settings:

- **No premium demand**, which is this whole file.
- **A few hundred impressions a week**, too little for any network's pricing
  model to calibrate on.
- **A CTR far above 1-3%.** On a launcher that puts a full-screen ad over a
  surface people are already tapping, 20-39% reads as accidental clicks and
  every buyer discounts for it.
- **"Test Ads" in the network split.** They win at 100% competitive factor and
  pay nothing. In release builds this comes from device-level test registration,
  not an app flag, when the dashboard Test mode is "Use SDK settings".

## Recorded values, Gravity Rolling Launcher, 13 November 2026

| Item | Value |
|---|---|
| Appodeal account line | `appodeal.com, 263546, DIRECT` |
| AdMob | `google.com, pub-4210665095499726, DIRECT, f08c47fec0942fa0` |
| Meta | `facebook.com, 2572933263011560, RESELLER, c3e20eee3f780d68` |
| Hosted at | `https://rolling-icon-gravity-launcher.web.app/app-ads.txt` |
| Replaced Play website | `https://silencionii.blogspot.com/` |
| File size | 2,516 lines after stripping blank lines |
| AdMob app status | Ready, ad serving enabled, 41 active units |
| AdMob requests via Appodeal | **zero** -- cause still unidentified |

The publisher id was confirmed against AdMob's own snippet at Apps >
Set up app-ads.txt, which prints the exact line to publish. Use that to check a
derived id rather than trusting the derivation alone.

These are that app's identifiers, recorded as a worked example. Never reuse
them in another app.
