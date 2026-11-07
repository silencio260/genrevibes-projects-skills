# Linking Meta Audience Network to Appodeal

Recorded 7 November 2026 from the Gravity Rolling Launcher integration. Meta is
the one portfolio network where the owner supplies the account rather than
Appodeal, so it needs per-app setup in two dashboards. Do this for every app
that ships the `meta` adapter. Read
[portfolio network defaults](appodeal-network-defaults.md) first; this reference
covers only the Meta half.

## Order matters, and getting it wrong cannot be repaired

**Create the Meta developer app first, then the Monetization Manager property
underneath it.** One app then supplies the App ID, the App Secret and the
placement prefix, which is the only arrangement Appodeal accepts.

The Gravity Rolling Launcher integration was done the other way: Monetization
Manager was reached through the "Go to Monetization Manager" link on an
unrelated app's Audience Network page, which minted a standalone Audience
Network app id. That id exists only inside Monetization Manager. It has no page
on developers.facebook.com, it is absent from Business Settings > Apps, and it
therefore has **no App Secret anywhere**. Appodeal will not save the App ID
without the Secret, so the property was unusable and the work had to be redone
against a new app. Meta cannot delete a property, so the dead one stays.

Appodeal's rule makes the requirement explicit: "If the first part of the
placement ID does not match the app ID, Meta Audience Network won't work."
Meta placement IDs are `<app id>_<placement id>`, so the App ID entered in
Appodeal must equal the part before the underscore. Unity's guide states the
same test from the other direction: take the placement ID and copy the part
before the underscore.

## Meta side

1. developers.facebook.com > **Create App**. Name it after the app; contact
   email defaults to the account owner.
2. Use case: **Advertise on your app with Meta Audience Network** (under the
   "Ads and monetization" filter). This is the step that binds Audience Network
   to the app from the start.
3. Business portfolio: the owner's portfolio, so the app sits with the others.
4. Requirements: normally "No requirements identified". Creating the app accepts
   the Meta Platform Terms and Developer Policies, and Meta asks for the
   account password to confirm.
5. From the new app: **Use cases > Customize > Audience Network > Go to
   Monetization Manager**. Confirm the opened URL carries `app_id=<new app id>`.
   If it does not, stop; the property will be orphaned.
6. **Create property**, named after the app. This accepts the Meta Audience
   Network Policy, Terms and platform policy.
7. **Add** the Android app to the property. Check the URL again for
   `app_id=<new app id>`.
8. App details: the **Google Play URL is optional** ("You can add the URL later
   if your app isn't live"), but **App name is read-only and derived from that
   URL**, so an unpublished app stays nameless and the property shows
   **"Missing app URL"** until the listing exists. Platform is fixed to Android.
9. Payout account: pre-filled from the business portfolio. A missing payout
   warning on one property is per-property, not account-wide.
10. Verification is skipped automatically for a new app.
11. SDK integration: set **Mediation platform = Appodeal**. The page then shows
    the **App ID** and a **Create placement** button.
12. Create one placement per format the app routes through Appodeal — normally
    Interstitial, Rewarded video, Native, Banner. App-open is **not** created
    here; that path uses the direct AdMob adapter, not Appodeal.
13. **Done**. Record the App ID and all placement IDs.

## Appodeal side

Per-app Meta settings live at **Apps > `<app>` > Ad Units**, not under Mediation
Setup. The ad-type tabs across the top (Interstitials, Banners, MREC, Videos,
Rewarded Videos, Native Ads) each hold their own ad units; the Meta account,
App Id and App Secret are shared across all of them.

1. Expand **Meta Audience Network** on any ad-type tab.
2. Settings: pick the Meta account, enter **Meta App Id** and **Meta App
   Secret**, then Save. **Both are mandatory** — saving the App Id alone fails
   with "must be filled" on the Secret and a toast reading "App network account
   cannot be updated."
3. The Secret comes from developers.facebook.com > the app > **App settings >
   Basic > App secret > Show**. Meta requires the account password to reveal it.
4. On each ad-type tab, **Add Ad Unit**: label it, leave Countries at All
   Countries, keep **Bidding = In-App Header Bidding**, and paste the matching
   **placement ID as the Code**. Mediation Engine stays Appodeal. Appodeal's
   docs are explicit that without In-App Header Bidding mode Meta ads do not
   work.
5. Repeat per format. Each tab shows "There is no Ad Units here" until its own
   unit exists.

## Verifying an app is done properly

- Appodeal **Apps > `<app>` > Ad Units**: Meta Audience Network toggled **ON**,
  App Id and App Secret populated, and one ad unit per shipped format with the
  placement ID as its Code.
- The App Id equals the text before the underscore in every placement Code.
- Appodeal **Apps > `<app>` > Mediation Groups > Default**: each ad type's unit
  sits in the **In-App Header Bidding** section, Enabled. Meta is bidding-only,
  so a Meta unit in Manual Priority, eCPM Priority or Automatic Priority is
  wrong. `$0.000` beside a unit only means no eCPM history yet.
- Meta Monetization Manager > Properties: exactly one property per app, with an
  Android app and the expected placement count, and no stray duplicate.
- Meta property page shows no **"Missing app URL"** once the app is published.
- The `meta` adapter and the `io.bidmachine:ads.networks.meta_audience` bridge
  are both declared in `android/app/build.gradle.kts`.

## What blocks serving even when the link is correct

Appodeal's [Meta Audience Network guide](https://docs.appodeal.com/networks-setup/ad-networks/network-connection/meta-audience)
lists prerequisites beyond the link itself. None of these are satisfied by the
dashboard wiring:

- **A live store listing.** Meta reviews each app ("usually less than 72
  hours") and the property needs the store URL. This is normally the real
  blocker, and it gates AdMob's "Add store" requirement at the same time.
- **Business verification** in Business Manager; an unverified portfolio shows
  as "Unverified business".
- **Privacy policy URL, user data deletion URL and Category** on the Meta app's
  Basic settings.
- **An app-ads.txt** carrying the Meta Business Manager ID, published on the
  developer site. Appodeal generates it at Mediation Setup > App-ads.txt with
  `Publisher_ID` and `Business_ID` placeholders that must be replaced.
- **BidMachine enabled with its adapter present**, and Appodeal SDK 2.10.3+.

Report these as pending rather than treating a completed link as live demand.

## Limits on what can be automated

- **Never enter the account password**, including a password manager's
  autofill, and never submit a password dialog. Meta asks for it when creating
  an app and again when revealing an App Secret; both are the owner's steps.
- **Never copy an App Secret** between dashboards. Set the App Id, then have
  the owner paste the Secret and save.
- A Monetization Manager **property cannot be deleted** — the row menu offers
  only View performance, Block lists and Duplicate, Edit property only renames,
  and the ad space menu only views or creates. Rename an orphan to mark it
  unused, or raise Meta support. Two properties can share a name, so always act
  on `property_id`, never on the displayed name.

## Recorded values, Gravity Rolling Launcher, 7 November 2026

| Item | Value |
|---|---|
| Meta app | `1082967944790202` |
| Property | `2184245778833229` |
| Interstitial | `1082967944790202_1082971228123207` |
| Rewarded video | `1082967944790202_1082971688123161` |
| Native | `1082967944790202_1082971978123132` |
| Banner | `1082967944790202_1082972251456438` |
| Orphaned property | `1459489200571121`, renamed "(OLD - unused)" |

These are that app's identifiers, recorded as a worked example. Never reuse
them in another app.
