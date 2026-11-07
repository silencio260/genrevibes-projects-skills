# Privacy policy template

Replace every `<PLACEHOLDER>`. Delete every section marked **Conditional** that
the app does not have, and delete any bullet describing data the app does not
collect. Verify each claim against the app as described in
[the skill](../SKILL.md#the-rule-that-matters-most-describe-the-app-that-exists).

Sections are numbered in the order below. Renumber after deleting.

---

# <App name> Privacy Policy

Effective <YYYY-MM-DD> · Version <YYYY-MM-DD>

This Privacy Policy explains how GENREVIBES TECHNOLOGIES INC ("we", "us",
"our") collects, uses, shares, and protects personal information when you use
the <App name> mobile app<, and the website at `<domain>`> (together,
"<Short name>"). It also explains your rights and how to use them.

Please read it together with our Terms of Use. If you do not agree with this
policy, please do not use <Short name>.

## In short

Five to eight plain-language bullets. Every line must also appear in the body.
Lead with whatever a user would most want corrected or reassured about. Useful
patterns from the reference pages:

- What the app is funded by, and what that means for ads.
- The most sensitive thing the app does *not* do (no contacts, no photos, no
  precise location, no wallet or payment details) — state it plainly.
- Whether recordings of app usage are made, and whether they are masked.
- Whether an account exists, and that it can be deleted in the app.
- Any identifier used for anti-abuse, and that it is hashed rather than stored raw.

## 1. Who is responsible for your information

GENREVIBES TECHNOLOGIES INC is the controller of the personal information
described in this policy.

GENREVIBES TECHNOLOGIES INC
Email: <support email>

## 2. Information we collect

### 2.1 Information you give us — **Conditional:** only if the app has input

<Account details, if the app has sign-in: what is collected, and that passwords
are handled by the auth provider and never stored by us in readable form.>

Preferences: <the settings the app stores, e.g. language, theme, notifications.>

Support and feedback: what you write to us through the in-app contact or
feedback forms. Your email address is included only if you choose to give it so
we can reply.

### 2.2 Information created as you use <Short name> — **Conditional**

<Only for apps with server-side records: account records, activity, balances,
referrals, or similar. A launcher with no backend has none of this; delete.>

### 2.3 Information collected automatically from your device

App and device identifiers: an app-generated install ID<, Firebase installation
IDs><, and your account ID, which links analytics, crash reports, and support
messages to your account>.

<Advertising ID: your device's advertising ID and similar ad-related signals
(see the advertising section).>

Device and app information: device model, operating system and version, app
version, language, time zone, screen size, network type, and similar technical
details.

Usage information: which screens and features you use, app opens, and events
such as <the app's own named events>.

Diagnostics: crash reports, error logs, and performance data.

<Session replays: recordings of how you move through the app's screens (see the
analytics section).>

Approximate location: our service providers and ad partners may infer your
approximate location (such as country or city) from your IP address. We do not
use GPS or collect your precise location.

> Delete the line above and write the truth instead if the app genuinely uses
> location. Do not claim location collection in an app that has no location
> permission.

### 2.4 Information from third parties — **Conditional**

<Store install referrer, ad partner reporting, or similar. Delete if none.>

### 2.5 What we do not collect

We do not collect <list what genuinely does not apply: your contacts, photos,
media files, microphone or camera input, precise location, government ID, or
bank or card details>.

> For a launcher, say explicitly whether the list of installed apps, the
> contents of notifications, or the home-screen layout leave the device. If
> they do not, say so — it is the single most reassuring line in the document.

## 3. How we use your information

Grouped by purpose, each with a short explanation:

To provide <Short name>: <the app's core function.>

To keep <Short name> secure: <anti-abuse, integrity checks, if any.>

<To show ads: serve ads, measure them, and limit how often they appear. Ads keep
<Short name> free.>

To understand and improve <Short name>: analyse how features are used, fix
crashes and bugs, and test changes.

To communicate with you: <account emails, in-app messages, support replies.>

To meet legal obligations: comply with the law, respond to lawful requests, and
establish or defend legal claims.

## 4. Legal bases (EEA, UK, and similar laws)

Where the GDPR, UK GDPR, or similar laws apply, we rely on these legal bases:

Performance of a contract: to run <the features described in our Terms>.

Legitimate interests: to keep <Short name> secure<, show non-personalised ads
that fund the free service,> and run analytics, crash reporting<, and session
replay> to improve the app. We have weighed these interests against your
rights. You can object at any time (see the rights section).

<Consent: for personalised advertising and the related use of your advertising
ID where the law requires consent. You can withdraw consent at any time in the
app.>

Legal obligation: where we must keep or disclose information by law.

## 5. Advertising — **Conditional:** only if the app shows ads

<Short name> shows <banner, interstitial, and rewarded video> ads through the
<mediation platform> platform, which chooses which ad network fills each ad
slot. To show and measure ads, it and these networks may collect your
advertising ID, IP address, device and app information, and information about
your interaction with ads. Each network uses this information under its own
privacy policy.

The ad networks we currently work with are: <the networks actually enabled for
this app>. This list may change. We will keep this page up to date.

Consent: where the law requires it (for example, in the EEA, the UK, and
Switzerland), the app shows a consent form before personalised ads. You can
change your choice later in <the app's actual settings path>.

Your advertising ID: you can reset or delete it in your Android settings
(Settings › Privacy › Ads, or Settings › Google › Ads, depending on your
device). After you delete it, ads are no longer personalised using it.

## 6. Analytics, crash reporting, and session replay

<Firebase Analytics> and <Mixpanel>: record app usage events, linked to <the
identifier actually used, e.g. an install ID> (not your email address). They
help us see which features people use and where problems happen.

<Firebase Crashlytics>: collects crash and error reports, linked to the same
identifier, so we can fix bugs.

<Session replay (<provider>): sessions may be recorded as a visual replay of
the app's screens, so we can see where the app is confusing or broken.>

> Then state the masking posture from the live Remote Config values. If
> `session_replay_mask_text` and `session_replay_mask_images` are `false`, say:
> "Recordings include the text and images shown on screen." If they are `true`,
> say text and images are masked. Either way, say that sign-in fields are never
> recorded in readable form if the app has any. Never describe recordings as
> masked without checking.

Analytics and crash reporting are part of how we provide and maintain
<Short name>, so they are not switched off by the ad consent choice. If you want
us to stop using your information for analytics<or session replay>, contact us
(see the contact section). We will honour your objection unless the law allows
us to continue.

## 7. Notifications and emails — **Conditional**

<Notifications: say whether they are scheduled locally on the device or sent
through a push provider. If local, say that no push service receives your
information to send them, and that they can be turned off in Settings or in
Android notification settings.>

<Emails: which account emails are sent, by which provider. State plainly if no
marketing emails are sent.>

## 8. What other users can see — **Conditional**

<Only for apps with social features, leaderboards, or referrals. Delete for a
single-player or single-device app.>

## 9. How we share information

We do not sell your personal information for money. We share it only as
described below.

Service providers that process data for us:

<Each provider by legal name and what it does for the app, e.g. Google Firebase
(Google LLC): analytics, crash reporting, and remote configuration.>

<Advertising partners: the mediator and the networks listed above. They act
under their own privacy policies.>

Legal reasons: when we believe in good faith that disclosure is required by law,
court order, or a lawful request from public authorities, or is needed to protect
the rights, property, or safety of our users, the public, or us.

Business transfers: if we are involved in a merger, acquisition, financing, or
sale of assets, your information may be transferred as part of that deal. It
will stay protected by this policy or a policy at least as protective, and we
will tell you before it is governed by a different policy.

With your consent: in any other case where you ask us to share it.

## 10. International transfers

We and our service providers process information in the United States and in
other countries where they or their sub-processors operate. <Name any region
that a user would not expect, as the reference policy names China and Russia for
certain ad networks.> These countries may not have data protection laws
equivalent to those in your country. Where the law requires it, we rely on
safeguards such as the European Commission's Standard Contractual Clauses, the
UK International Data Transfer Addendum, or an adequacy decision. You can ask us
for more information about these safeguards.

## 11. Your rights and choices

### Choices in the app

<The real settings paths: language, notifications, ad privacy choices, account
deletion. Only list what exists.>

### Your privacy rights

Depending on where you live, you may have the right to:

access the personal information we hold about you and get a copy, including in a
portable format;

correct inaccurate information;

delete your information;

restrict or object to certain uses, including uses based on legitimate interests;

withdraw consent at any time, which does not affect processing that already took
place;

not be discriminated against for using your rights.

To use these rights, contact us at <support email><or through the in-app support
path>. We may need to verify that the request comes from <the account holder>.
We respond within the time the law requires, normally within one month. You may
also use an authorised agent where the law allows it.

EEA, UK, and Switzerland: you have the right to lodge a complaint with your local
data protection authority. We would appreciate the chance to address your concern
first.

California and other US states: in the past 12 months we have collected the
categories of information described above: identifiers, internet and app
activity, approximate geolocation inferred from IP address<, and inferences used
for fraud prevention>. We do not sell personal information for money. <However,
when ad networks use your advertising ID to personalise ads, that may count as
"selling" or "sharing" for cross-context behavioural advertising under
California and some other state laws. You can opt out by deleting or resetting
your advertising ID in your Android settings, or by contacting us.> We do not
knowingly sell or share the personal information of anyone under 16. We do not
use sensitive personal information to infer characteristics about you.

Brazil: under the LGPD, you have the rights listed above, plus the right to
information about the entities we share data with and about the consequences of
refusing consent.

## 12. Deleting your account — **Conditional:** only if accounts exist

<What deletion removes immediately, what minimal record is kept and why, and how
to request deletion without app access. Be specific; a vague deletion section is
the one users complain about.>

## 13. How long we keep information

<One line per category with an actual period. The reference policy uses: server
logs about 30 days, crash reports about 90 days, session replays about 30 days,
analytics for the provider's configured retention, support messages as long as
needed.>

We may keep information for longer where the law requires it or where it is
needed to establish, exercise, or defend legal claims.

## 14. Security

We protect your information with measures that include <the measures the app
actually uses: encryption in transit, security rules, device verification,
hashing of identifiers, role-based access>. No method of transmission or storage
is completely secure, so we cannot guarantee absolute security.

## 15. Children

<Short name> is not directed to children. You must be at least <13 or 16, and
match the store listing's content rating> years old to use <Short name>, or
older if the law where you live sets a higher age for consenting to the
processing of your personal information. We do not knowingly collect personal
information from children below these ages. If you believe a child has created
an account, contact us and we will delete it.

## 16. Our website — **Conditional**

<Only if the app has a website or the policy itself is hosted somewhere worth
naming. Say what the host receives, whether analytics or advertising cookies are
used, and where the other legal page is hosted.>

## 17. Changes to this policy

We may update this policy as <Short name> changes or as the law requires. We will
post the updated version on this page and change the effective date. If we make
significant changes, we will tell you in the app before they take effect, and ask
for your consent where the law requires it.

## 18. Contact us

For questions about this policy or your information, contact:

GENREVIBES TECHNOLOGIES INC
Email: <support email>
<In the app: the actual support path>

---

Terms of Use · © GENREVIBES TECHNOLOGIES INC
