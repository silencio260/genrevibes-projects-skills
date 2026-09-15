# GenRevibes portfolio architecture and the Story Saver reference app

This guide has two jobs: describe Story Saver as it currently works, and define
the architecture and shared integrations for new GenRevibes portfolio apps.
Story Saver demonstrates the architecture; its media features, credentials, and
product settings are not requirements for every app. Read this before creating
a portfolio app, adding a feature, or changing kit integration. The
[complete reading-preferences example](references/feature-walkthrough.md) follows
these rules and includes every source file needed for that example.

**Portfolio baseline:** every new portfolio app includes Kit Lab, the developer
section, feedback/contact forms, rating, the Android exit prompt, ads, retention,
analytics, onboarding, IAP, remote config, and session replay integration. These
are part of the app brief even when the user only names the product's main feature.
See [the baseline](#11-guaranteed-portfolio-integrations) for what each includes.

Three kinds of statements appear below:

- **Portfolio requirement:** behavior or architecture new portfolio apps must include.
- **Shared default / app choice:** reuse the kit's default unless the product needs
  an explicit override; choose provider credentials and product content per app.
- **Story Saver today:** a source-backed description, including compatibility
  code that is still active. It is not an instruction to reproduce every exception.

The kit is modular so adapters and extra capabilities can vary. That does not
make the portfolio baseline optional. A narrow maintenance task in an existing
app still keeps its requested scope; it does not trigger an unrelated migration.

## Contents

- [App/kit boundaries and packages](#1-the-app-and-kit-have-different-jobs)
- [Repository layout](#2-repository-layout)
- [Feature layers](#3-the-default-app-architecture) and [worked action](#4-follow-one-action-through-the-app)
- [Dependency ownership](#5-dependency-registration-and-ownership) and [startup](#6-startup-order)
- [Shared behavior](#7-shared-behavior-versus-product-settings), [errors](#8-errors-and-upgrades), and [conventions](#9-names-structured-data-and-networking)
- [Reading instructions](#10-how-to-use-these-instructions)
- [Guaranteed integrations](#11-guaranteed-portfolio-integrations)
- [How integrations work together](#12-connect-the-baseline-as-one-running-system)
- [Shared constants and app configuration](#13-constants-defaults-and-configuration)
- [Story Saver as implemented](#14-story-saver-today)
- [Other likely portfolio integrations](#15-extending-the-portfolio-baseline)
- [Creating the next app](#16-apply-this-template-to-a-new-portfolio-app)

## 1. The app and kit have different jobs

The **app** is the product installed by the user. It owns screens, navigation,
feature rules, user-facing text, and the choice of services. The **starter kit**
is shared code used by several products. It owns reusable operations such as
permission requests, feedback forms, purchase adapters, and developer tools.

A **contract** is an interface such as `KeyValueStore` or `IapProvider`. An
**adapter** implements that interface using a particular service, such as
SharedPreferences or RevenueCat. The app chooses the adapter at startup. Feature
code depends on the contract so the service can change without rewriting every screen.

A **module** implements the kit's `StarterModule` lifecycle: initialize, health,
health changes, and dispose. Not every kit object is a module. For example,
`KeyValueStore` has storage methods but no initialize/dispose contract. Do not
invent lifecycle calls on it.

### Package dependency direction

```text
App bootstrap -> selected adapter -> capability contract -> genrevibes_core
App bootstrap -> optional genrevibes_starter_kit coordinator -> genrevibes_core
App UI        -> shared UI package -> its capability contracts
```

`genrevibes_core` supplies results, errors, lifecycle, health, clocks, resource
scopes, and logging contracts. A capability package supplies its feature's
interfaces/models/policy; an adapter maps those to a vendor SDK. Shared UI uses
the public capability API. Contracts must not import adapters or expose vendor
types. The coordinator starts the modules the app supplies; it neither chooses
providers nor owns app BLoCs or GetIt.

Declare imported packages directly in the app pubspec and resolve transitive kit
packages through the current path overrides. The repository root is not the
package path. An absent adapter avoids its SDK dependencies; a runtime-disabled
adapter that remains in the dependency graph still contributes build dependencies.
Switching providers at runtime requires deliberately including both adapters.
Analytics can use multiple sinks concurrently.

Use the [kit inventory](../../../packages/genrevibes_starter_kit/README.md) and
[checked compatibility](references/kit-compatibility.md) for current package paths
and platform floors. Kit modularity permits reuse outside this portfolio; new
portfolio apps compose the full baseline described here.

## 2. Repository layout

```text
app/
├── AGENTS.md                          # Points to the shared operating rules
├── agents/                            # Separate Git repository for skills
│   ├── AGENTS.md
│   └── skills/mobile-app-skills/
├── packages/genrevibes_starter_kit/    # Separate Git repository for shared code
│   ├── docs/
│   └── modules/
│       ├── foundation/genrevibes_core/
│       ├── foundation/genrevibes_starter_kit/
│       ├── storage/genrevibes_storage/
│       ├── storage/genrevibes_storage_shared_preferences/
│       └── ...selected capability packages...
├── lib/
│   ├── main.dart                      # Starts Flutter; visible loading/retry
│   ├── my_app.dart                    # Theme, router, top-level providers
│   ├── bloc_observer.dart             # App BLoC diagnostics
│   ├── container_injector.dart         # App GetIt instance; calls feature injectors
│   ├── bootstrap/
│   │   ├── app_env.dart                # Typed build settings and provider config
│   │   ├── app_bootstrap.dart          # Constructs and connects kit instances
│   │   ├── app_runtime.dart            # Holds those instances and their ownership
│   │   └── runtime_registrar.dart      # Registers those instances in app GetIt
│   ├── config/
│   │   ├── routes.dart                # Route names, if split from the router
│   │   ├── routes_manager.dart         # Route arguments and screen construction
│   │   └── theme_manager.dart          # App themes
│   ├── core/
│   │   ├── error/                     # App Failure types and error translation
│   │   ├── usecase/                   # BaseUseCase, NoParams
│   │   ├── api/                       # Endpoint definitions, when the app has HTTP APIs
│   │   ├── network/                   # HTTP client/interceptors, when needed
│   │   └── utils/                     # App-wide values/helpers
│   └── features/<feature>/
│       ├── <feature>_injector.dart
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/<feature>_bloc/
│           ├── screens/
│           └── widgets/
├── android/ and ios/                  # Native host configuration
├── env/                              # Local build values; not shared secrets storage
└── pubspec.yaml                      # App dependencies and path overrides
```

This is the default layout for new portfolio apps. Story Saver already follows
it, although some older filenames and legacy folders remain. Follow their actual
callers when editing them; a file's historical name may not describe its current
provider. Do not repeat those old names in a new feature.

Keep app folders directly under `lib`; do not create an app `lib/src` tree.
Shared Dart packages may use private `lib/src`. Import a kit package's public
library, for example `package:genrevibes_storage/genrevibes_storage.dart`.
Never import its private file to avoid adding a proper public API.

## 3. The default app architecture

Use BLoC for feature events/state, GetIt for dependency registration, and the
existing `Either<Failure, T>` repository/use-case convention in this app and
new portfolio apps following this structure. The kit itself does not depend on
those choices. When adopting the kit in an existing portfolio app with another
architecture, preserve that architecture unless its migration is requested.

| Layer | What belongs here | What does not belong here |
|---|---|---|
| Screen/widget | Render state; collect input; send an event; navigate from outcomes | SDK initialization, HTTP calls, preference reads |
| BLoC | Busy/error/data state; coordinate user actions through use cases | Native SDK configuration or another global service locator |
| Use case | One named product operation; combine domain rules when needed | Widget contexts, vendor SDK objects |
| Repository interface | The operations and domain results the feature needs | RevenueCat/Firebase/SharedPreferences implementation types |
| Repository implementation | Call the data source; map transport data and failures | Screen navigation or showing snackbars |
| Data source | Call kit contracts, HTTP clients, database, or platform wrappers | Decide UI state or invent product access rules |
| Bootstrap | Construct shared instances; set policies; connect listeners | Feature widget trees and app-specific content models |

Entities express feature data without Flutter or provider types. Models represent
stored/network formats when conversion is needed. A boolean preference does not
need a model class simply to fill a folder. A feedback action using the kit's
complete form also does not need another handwritten form BLoC and repository.
Use layers to separate real responsibilities, not to duplicate a shared operation.

## 4. Follow one action through the app

Example: the reader enables “Keep screen awake” in reading settings.

1. The screen adds a `KeepAwakeChanged(true)` event.
2. The BLoC marks the save busy and calls `SaveKeepAwake(true)`.
3. The use case calls the repository interface.
4. The repository implementation calls a data source using `KeyValueStore`.
5. The kit adapter writes the value using SharedPreferences and returns `KitResult`.
6. The repository translates that result to the app's `Either<Failure, bool>`.
7. The BLoC emits saved state or a failure, preserving the last confirmed value.
8. The screen rebuilds. It never needs to know which persistence plugin was used.

This example stores the preference; an actual reader would separately apply it
to its screen-awake integration. The example does not claim to implement that
platform feature. See the [worked files](references/feature-walkthrough.md).

## 5. Dependency registration and ownership

**Construction** creates an object. **Registration** lets other app code find
that object. **Initialization** asks it to become ready. These are separate steps.
Registering a provider in GetIt does not initialize its SDK.

Story Saver constructs providers in `bootstrap/app_bootstrap.dart`, holds them
in `AppRuntime`, and registers those exact instances in `runtime_registrar.dart`.
`initAppDependencies()` then registers feature repositories, use cases, and BLoCs.
Do not construct another provider in a feature injector or a Kit Lab page.

| Registration | Use |
|---|---|
| `registerSingleton<T>(existingInstance)` | Runtime-owned provider/controller already constructed at startup |
| `registerLazySingleton<T>(() => ...)` | Stateless/shared feature repository or use case |
| `registerFactory<FeatureBloc>(() => ...)` | A new BLoC for each owning screen/provider |

`BlocProvider(create: ...)` owns the BLoC it creates and closes it.
`BlocProvider.value(value: existingBloc)` borrows a BLoC; its original owner must
close it. Do not provide a factory-created BLoC with `.value` and assume Flutter
will close it. Do not close a shared runtime provider from a screen's dispose.

Use constructor injection inside features. Resolve dependencies at an injector,
route, or top-level provider boundary rather than calling GetIt inside every method.
On startup retry, close the old runtime/listeners and reset its app registrations
before publishing the new ones. Old asynchronous results must not update the new runtime.

## 6. Startup order

The visible app shell starts first. Required preparation then determines whether
normal UI can open. Optional services can fail without making the whole app unusable.

1. Create the Flutter binding and show loading/retry UI.
2. Construct a resource scope for this attempt. Configure required platform services.
3. Create the shared store and its explicit legacy-key mappings.
4. Create controllers/providers and record their cleanup ownership immediately.
5. Load local/cached settings before SDKs that fix those settings at initialization.
6. Initialize required modules; inspect their returned results.
7. Register the runtime in app GetIt, then the feature dependencies.
8. Render the main app. After a frame, start deferred services/prompts.
9. Consent gets its bounded attempt before ads. Failure/timeout releases startup
   without fabricating consent. The SDK still controls its actual consent signals.
10. Keep listeners and policy binders attached for live changes, then dispose them
    with the runtime. See [runtime details](skills/runtime-setup/SKILL.md).

In Story Saver, Firebase has a 20-second preparation budget and the whole
preparation attempt has 60 seconds. Module and consent budgets are separate.
These are current app settings, not a reason to put every app behind Firebase.

## 7. Shared behavior versus product settings

| Feature | Reuse from kit | Supply in app |
|---|---|---|
| Feedback/contact | Form, validation, busy state, attachments, submission adapter | Labels, colors, credential, optional picker, route masking |
| Developer section/Lab | Unlock, device lists, action checks, pages, switches | Enabled/actions/passcode overrides; running instances; catalogue |
| Purchases | Provider, outcomes, entitlement-policy evaluator | Platform keys, actual entitlement IDs, which feature each unlocks |
| Permissions | Check/request flow and throttling | Permission kinds, reason text, native declarations, resource-specific grants |
| Notifications | Scheduler/provider and campaign coordination | Channels, timezone, destination mapping, saved campaign definitions |
| Remote control/replay | Typed schema, binders, rollout/controller | Selected providers, app keys, rollout decisions, sensitive routes |
| Onboarding/rating | Saved state and shared flow/policy | Pages, timing choices, store links, navigation |

Developer defaults remain reusable. Apps can override or disable them without
writing another unlock system. Real purchase state and developer simulation
remain separate. Story Saver's WhatsApp folder access, `Pro` entitlement,
replay overrides, and routes are examples, not automatic settings for another app.

## 8. Errors and upgrades

The kit returns `KitResult`; this app uses `Either` across feature boundaries.
Translate once in the repository. Keep missing data, user cancellation, permission
denial, pending payment, timeout, and provider failure distinct.

A timeout stops waiting; it does not prove a native dialog or server request
stopped. A retry must not duplicate a purchase or silently discard entered form data.
Preserve original causes for diagnostics without showing credentials in UI errors.

When adopting a kit feature, map existing saved keys before initializing it.
Do not clear storage to make new code work. Record changes to data meaning and
rollback behavior. Remove the replaced listener/provider only after its callers
have moved; running both can duplicate events and side effects.

## 9. Names, structured data, and networking

Follow the [working conventions](references/working-conventions.md) for naming,
entity/model conversion, network boundaries, and code generation. The reading
example uses a bool; the conventions explain how the same structure grows to
features with remote records, lists, cancellation, and stored formats.

## 10. How to use these instructions

For a new feature, read this guide, the [feature walkthrough](references/feature-walkthrough.md),
and that feature's skill. For a narrow edit, read only the relevant sections.
A linked API file helps verify a signature; it does not replace the steps in the skill.

Examples name their app-supplied inputs. Full example files include imports.
A model should be able to explain who owns each object, where it is registered,
how failures reach the UI, and what closes it before implementing the feature.
Report source/analyzer checks separately from native device behavior. Do not
claim the documentation has been proven on a model generation that was not used.

## 11. Guaranteed portfolio integrations

Include every row below when creating a new portfolio app, unless the user
explicitly changes that app's baseline. Installing a package is only the first
step: connect its runtime, settings/action entry points, policy consumers,
diagnostics, and cleanup. Read each linked skill when implementing that integration.

**Included in the product** and **required to finish startup** are different.
For example, feedback is a guaranteed feature, but a feedback service outage
should not prevent opening the app. Similarly, replay integration is guaranteed;
actual recording follows rollout, masking, master-switch, and collection policy.
Platform-specific UI applies on supported platforms: Android root-exit behavior
does not become an iOS exit button.

| Guaranteed feature | Shared implementation to reuse | Each app supplies |
|---|---|---|
| [Kit Lab](skills/kit-lab/SKILL.md) | `StarterKitLabScreen`, `DevToolsHost`, health, inspectors and live controls | Existing runtime instances, actual analytics catalogue, known storage groups, exit preview and product diagnostics |
| [Developer section](skills/developer-access/SKILL.md) | `DeveloperAccessController`, `DeveloperUnlockGesture`, passcode UI, device hashing, `DeveloperAdSwitches` | Settings entry, theme, device lists and any explicit action/passcode overrides; product-specific developer actions |
| [Feedback/contact forms](skills/feedback/SKILL.md) | `openFeedbackPage`, shared validation/submission UI, `FeedbackProvider`, selected delivery adapter | App labels/theme, delivery key, optional attachment picker, replay protection, entry points |
| [Rating](skills/app-rating/SKILL.md) | `RatingCoordinator`, persisted eligibility, store-review contract/adapter | Successful-use milestone, prompt presentation, store links, feedback action, ad suppression |
| [Exit prompt](skills/exit-prompt/SKILL.md) | `ExitGuard`, `ExitPromptConfig`, modal/sheet behavior and fallback | Android root placement, current remote policy, app feature/offer content, navigation/exit callbacks, Lab preview |
| [Ads](skills/ads/SKILL.md) | `AdProvider`, `AdPolicyController`, adapter views, shared pacing and developer switches | Platform keys, placements/formats, product eligibility, inline UI, native setup and event wiring |
| [Retention](skills/tracking-retention/SKILL.md) | `RetentionTracker`, `EngagementSnapshot`, `UserTargetingPolicy`, persisted milestones | One launch/session owner, analytics observer, app offers/actions consuming eligibility |
| [Analytics](skills/analytics/SKILL.md) | `AnalyticsPipeline`, selected sinks, delivery observation | Collection/identity configuration, product events/catalogue and shared event listeners |
| [Onboarding](skills/onboarding/SKILL.md) | `OnboardingController`, `OnboardingFlow`, persisted completion, finish actions | Pages/artwork/copy, skip behavior, destination, any permission/paywall/ad actions |
| [IAP/paywall](skills/iap/SKILL.md) | `IapProvider`, selected adapter/UI, `EntitlementAccessPolicy` | Platform keys, product/entitlement IDs, one access-state owner, feature rules, purchase/restore entry points |
| [Remote config](skills/remote-config/SKILL.md) | `RemoteConfigCoordinator`, `PortfolioRemoteConfigSchema`, shared policy binders | Selected provider, additional app keys, explicit overrides, refresh ownership and consumers |
| [Session replay](skills/session-replay/SKILL.md) | `SessionReplayController`, recorder adapter, remote binder, Lab controls | Provider configuration, rollout/collection choice, sensitive routes and any explicit build overrides |

Supporting infrastructure includes the shared store, resource scope, identity
for developer recognition/diagnostics, logging, ad-consent integration, and the
app's settings/router/theme. Reuse the relevant kit implementation for each.
Story Saver also connects crash reporting, push, local notifications, links,
permissions, splash and system UI; section 15 explains adopting these as needed.

For provider selection, Story Saver is a concrete working composition:
Appodeal ads/consent, RevenueCat purchases and hosted UI, Firebase + PostHog
analytics, Firebase remote config, PostHog replay, FeedbackNest forms, and an
in-app-review store adapter. Read the current adapter constraints before using
that recipe on another platform. Retain an explicit provider choice supplied for
another app; the shared feature remains required when its provider changes.

## 12. Connect the baseline as one running system

The app's bootstrap is the place that knows which capabilities work together.
Keep neutral contracts independent, then connect their events and policies here.
The diagram describes shared relationships, not a serial startup sequence:

```text
Shared store -> identity / developer access / retention / rating / onboarding
Remote config -> ad policy / replay policy / developer lists / UI policy readers
IAP snapshots -> app access policy -> feature locks / ads / upgrade UI
Developer access -> Lab guard / developer section / simulation / ad test mode
Ad consent -> deferred ad initialization -> placement load/show eligibility
Shared feature observers + product events -> analytics -> selected sinks
Replay plan -> recorder SDK setup -> attached recorder + protected routes
All running capabilities -> DevToolsHost -> Lab controls and diagnostics
```

### Developer section and Lab

Initialize developer access and saved ad switches before choosing the ad SDK's
initial test mode. Feed the resolved vendor identity into the controller; the
controller handles hashing and grant rules. Apply remote developer lists through
`DeveloperAccessRemotePolicyBinder`. Use the shared unlock gesture at the app's
Settings entry, with its theme and content-protection hooks.

The developer section exposes app actions; Lab inspects and controls the shared
runtime. Both use the same access controller. Check diagnostics permission for
pages and premium-simulation permission for simulated access. Subscribe to grant
changes so already-open pages, inline ads, and simulated premium react to revocation.
Do not create an independent passcode counter, unlock preference, or premium record.

Pass live providers, the remote schema, event catalogue, logger and delivery
observer into `DevToolsHost`. A Lab control must change the object used by the
app. For example, toggling native ads must affect native slots, not just the
switch widget. Log retention in release is a separate configuration decision;
Story Saver only retains its recording buffers in development.

### Purchases, ads, consent, and product access

Attach one listener to `IapProvider.entitlementChanges` and fetch initial access.
Keep actual entitlement snapshots in one app-owned holder. Use
`EntitlementAccessPolicy` to map exact entitlement IDs to product features.
Derive developer simulation separately through the current action grant.

Feed effective access into ad policy and every inline/load/show consumer.
Unknown purchase state must not become known-free access. On a premium grant,
discard already loaded inventory and remove visible eligible ad slots. The same
provider serves onboarding, home, viewer, splash, and any deliberately configured
exit ad placement; these screens do not initialize additional SDKs.

Consent gets a bounded deferred attempt before the ads module. A timeout ends
the app's wait without inventing consent. Product analytics has its own explicit
collection policy; do not accidentally make it follow advertising consent.
Keep cancellation, pending payment, failure and a successful entitlement refresh
distinct in purchase UI. Connect restore to that same access holder.

### Feedback, rating, settings, and exit UI

Build Settings using shared rows/sections where useful, plus app-owned state and
callbacks. Feedback/contact actions open the complete shared page with the runtime
provider. Contact mode requires email; feedback mode permits it to be optional.
The page owns validation and submission state. The app supplies theme, text,
attachment selection and route protection. A booking, profile or chat form remains
an app feature; the feedback package is not a universal form engine.

At an app-chosen successful milestone, ask the rating coordinator whether a
prompt is eligible. Preserve snooze/opt-out/history; opening a screen must not
create another rating counter. Suppress conflicting ads while the prompt is open
and release suppression on every outcome. A store request being accepted does
not prove a rating was displayed or submitted. Keep the store and feedback actions
explicit and follow the rating skill for their routing.

Place `ExitGuard` at the Android navigation root. Supply current policy when Back
is handled so changes in access and remote settings take effect. Populate shared
modal/sheet styles with the destination app's features, offers and labels. Missing
content uses the shared fallback. Nested routes keep ordinary Back behavior. Lab
uses the same configuration for previews but must not invoke the real app exit.
An exit prompt is guaranteed; an ad-bearing exit style is a separate product choice.

### Analytics and retention

Use one pipeline for selected sinks and one app service for product event methods.
Provide the real catalogue to Lab. Connect purchase, ad, rating, retention and
notification observers once at their owning boundary. Rebuilding widgets must not
attach duplicate observers or emit another app open.

Initialize the retention tracker with the shared store and an
`AnalyticsEngagementObserver` when routing its events into analytics.
`recordAppOpen` includes the initial session; do not immediately call
`recordSession` for that same launch. Define subsequent session boundaries in
one lifecycle owner. Persist milestone history across upgrades. Retention,
onboarding completion, and rating eligibility have different meanings and keys.

Preserve these current Story Saver ad event meanings when extending its analytics:

| Provider callback | App event | Meaning |
|---|---|---|
| Impression | `ad_show` | An ad was shown, including when no paid data arrives. |
| Paid callback with revenue | `ad_impression` | Actual reported value/currency, with provider/network metadata where available. |
| Click | `custom_ad_click` | Custom click event; do not substitute the reserved Firebase name. |
| Loaded / dismissed | `ad_loaded` / `ad_dismissed` | Provider lifecycle outcomes, distinct from a paid impression. |

The mapping lives in Story Saver's bootstrap. Other apps should define and keep
an equally explicit shared event contract, use the kit's event APIs, and add
product events such as export completed or document opened. Do not invent paid
amounts or assume a local dispatch proves remote reporting.

### Remote config and session replay

Build the shared portfolio schema and add only the app's extra keys/overrides.
Initialize cached/default policy before SDK setup that depends on it. Connect
`AdsRemotePolicyBinder`, `SessionReplayRemotePolicyBinder`, and
`DeveloperAccessRemotePolicyBinder` to their live consumers, then refresh without
blocking usable UI. Onboarding, splash and exit policies also need actual readers;
a remote key does nothing merely by being present in the schema.

Capture the replay controller's plan, configure the SDK using that plan, and
attach the recorder with the same configured plan. Keep requested policy, last
successful command and actual SDK status separate in Lab. Mask changes can require
restart; follow the controller's handling rather than claiming a live flag changed
an already configured SDK. Protect feedback and passcode routes independently.

Keep replay integration in new apps even when rollout is 0%. The shared default
is 0% with text/images masked; Story Saver explicitly overrides it to 100% with
global text/image masking off. Preserve Story Saver's deliberate configuration
when maintaining it, but do not silently copy that override into the next app.

### Onboarding and launch

The startup shell handles preparation/retry. Product splash presentation and
onboarding come afterward. Use the runtime's `OnboardingController` for initial
routing, completion actions, and Lab reset. Pages, artwork, copy, permission
explanations and destinations are app-owned; completion persistence is shared.

Use `OnboardingFlow` finish actions to express the chosen order of completion,
optional paywall/actions and navigation. Handle failed persistence explicitly.
An interactive paywall must not be abandoned by an arbitrary timer navigating
behind its native UI. Ad slots consume the existing provider/policy and the
onboarding remote switch. Reserve space only where the configured slot is supported.

## 13. Constants, defaults, and configuration

Every portfolio app has the same kinds of configuration, but their values do not
all match. Reuse shared key/default definitions rather than copying them into a
new `AppConstants` class. Keep app identity and product-specific constants together
in typed app configuration. A value is configured only when a reader passes it
to the actual consumer.

| Kind | Source of truth / examples | Rule for another app |
|---|---|---|
| Module IDs | Provider `moduleId`; Story Saver groups its IDs in `AppModules` | Registration IDs must match modules; use public APIs, not guessed strings. |
| Shared persistence keys | `DeviceIdentityKeys`, `EngagementKeys`, `OnboardingKeys`, `RatingKeys`, `DeveloperAccessKeys` | Reuse kit keys and map only real legacy keys; do not rename shared saved formats. |
| Shared remote policy | `PortfolioRemoteConfigSchema`, `AdsPolicyKeys`, `OnboardingPolicyKeys`, `SplashAdPolicyKeys`, `ExitPromptPolicyKeys` | Retain baseline groups; add typed app keys with defaults and consumers. |
| Developer defaults | `DeveloperAccessDefaults`, `DeveloperAccessConfig`, shared unlock UI | Preserve shared fallback behavior unless explicitly overridden; the current gesture is seven taps and wrong-attempt limit is three. |
| Replay defaults | Shared `SessionReplayPolicy` / schema defaults | Start from shared rollout/masking defaults; document any product override. |
| App identity/links | App name, bundle/application IDs, `AppLinksConfig`, support/store/privacy/terms links | Populate destination-app values; Story Saver's package and store URLs are not portfolio constants. |
| Provider configuration | Platform SDK keys, project IDs, selected adapter configuration | Same integration roles, different accounts/keys as appropriate; never treat blank templates as configured. |
| Purchase rules | Product/entitlement IDs, `FeatureEntitlementRule` | Define exact access mapping. Story Saver defaults its premium entitlement to `Pro`; other apps need their actual IDs. |
| Placements and destinations | `AdPlacement` IDs/formats, routes, notification actions | Name real surfaces in that app. A reader/editor need not have Story Saver's viewer or Business WhatsApp routes. |
| Text/theme/assets | App-wide strings, feature labels, theme, onboarding artwork | Preserve common behavior while applying the app's brand and content. |
| Product persistence | Auto-save preference, recent documents, cached records | App-owned keys/formats; migrate deliberately instead of clearing shared storage. |

Read [environment keys](references/environment-keys.md) for existing spellings
and platform readers. In particular, an absent `premium_entitlement_id` lets
Story Saver use `Pro`; an explicitly empty value does not. The current Story
Saver RevenueCat reader only supplies Android configuration. A new iOS app must
add and wire the iOS key, not assume copying its env file provides one.

Preserve published spellings such as `time_before_first_rewared_ad` and
`feed_back_nest_api_key`. Before renaming a key, identify all readers, stored values,
templates and remote conditions. Use the kit definitions rather than maintaining
another numerical default table that drifts when packages change.

## 14. Story Saver today

This section records the inspected source on 15 September 2026 against the kit
revision in [compatibility](references/kit-compatibility.md). It describes source
wiring, not a device-validation result. Recheck callers when these files change.

### Runtime and provider map

All app paths in this section are relative to the host root. The links assume
this agents checkout is under the host's `agents` directory.

| Area | Current source and composition |
|---|---|
| Entry/recovery | [main.dart](../../../lib/main.dart): first-frame loading UI, 60-second preparation attempt, 20-second Firebase budget, GetIt reset on failure, deferred start after the main app frame |
| Composition | [app_bootstrap.dart](../../../lib/bootstrap/app_bootstrap.dart): shared store, providers, listeners, remote binders, module registration and initialization |
| Runtime ownership | [app_runtime.dart](../../../lib/bootstrap/app_runtime.dart) holds the instances/scope; [runtime_registrar.dart](../../../lib/bootstrap/runtime_registrar.dart) publishes them; [container_injector.dart](../../../lib/container_injector.dart) registers app features |
| Ads/consent | Appodeal provider and consent gate; Appodeal banner/native views; placements and platform configuration in [app_env.dart](../../../lib/bootstrap/app_env.dart) |
| Purchases | RevenueCat with `RevenueCatUiAdapter`; [AppPurchasePolicy](../../../lib/features/monetization/domain/app_purchase_policy.dart) maps `Pro` by default; `SubscriptionManager` holds snapshots/effective access |
| Analytics/replay | Firebase + PostHog sinks, app analytics service/catalogue, PostHog recorder; app-specific replay overrides in `buildAppRemoteConfigSchema()` |
| Remote policy | Firebase adapter, shared schema, ads/replay/developer binders; remote refresh is launched without awaiting it near the end of bootstrap |
| Feedback/rating | FeedbackNest provider/shared form UI; rating coordinator with download trigger, app prompt and ad-suppression hook; in-app-review store provider |
| Developer UI | Settings unlock/section and [dev_tools_entry.dart](../../../lib/features/developer/dev_tools_entry.dart); Lab receives live instances and app storage/event catalogues |
| Exit UI | [HomeExitPrompt](../../../lib/features/home/presentation/widgets/home_exit_prompt.dart): shared config with app features, premium offer and remote style; default features sheet has no ad |
| Local state | `MigratingKeyValueStore` over SharedPreferences for adopted kit state; app-specific direct preference users remain |
| Other integrations | Crashlytics coordinator/hooks, device identity, retention, permission-handler provider, OneSignal, local notification scheduler, link/store actions, onboarding and navigation-bar controller |

Onboarding is the required registered startup module; most other modules are
optional for launch. Consent and ads are deferred in that order. Firebase is an
app preparation prerequisite outside that module list. Remote config and replay
preferences are initialized early so PostHog setup sees their cached/default
plan. Registration is therefore not the whole initialization story.

Retention `recordAppOpen()` is launched near the end of bootstrap. The current
root lifecycle listener tracks lifecycle events and refreshes notification timezone
on resume; it is not a complete example of a custom resumed-session counting policy.
The Lab currently calls the same schema-building function again for its schema
description; it reuses the actual remote coordinator. For a new composition,
passing the already-built schema instance makes shared configuration ownership explicit.

### App state and compatibility boundaries

[MyApp](../../../lib/my_app.dart) owns Analytics, IAP, Ads, Navigation, Onboarding,
Permissions, SavedMedia, Settings, Splash and Status BLoCs in its root
`MultiBlocProvider`. These instances survive ordinary route changes. Factory
registration controls construction; the owning `BlocProvider` controls lifetime.
Do not recreate these on every route while making a focused Story Saver change.
In a new app, put shared cross-screen state at the root and screen-specific BLoCs
at their route/provider boundary.

[SubscriptionManager](../../../lib/features/monetization/data/services/subscription_service.dart)
is an active singleton `ChangeNotifier`, not another purchase SDK. It receives
kit entitlements and combines actual premium state with authorized developer
simulation. Its ad eligibility also depends on loaded preference/access state
and the app's status-folder/onboarding conditions. Reuse those callers while
maintaining Story Saver; another app supplies its own readiness conditions.

Some names describe earlier implementations. For example,
`GoogleMobileAdsRemoteDataSource` now calls the runtime `AdProvider`, which is
Appodeal in this composition. Some data sources use GetIt internally or convert
`KitFailure` to thrown errors; their repositories then produce app `Either`.
Settings and subscription code still use direct SharedPreferences for app state.
These are current compatibility boundaries, not proof that every feature follows
the preferred constructor-injection/kit-result example exactly.

Feature `presentation/l10n/*_strings.dart` files currently hold English constants.
This organizes text but does not implement translated locales. Keep the current
string convention during narrow edits; use the localization skill when adding
actual locale resources, delegates, formatting and switching.

### The product-specific media path

Story Saver owns regular/Business WhatsApp access, status discovery/cache,
thumbnails, viewing, saved-gallery paging, saves/shares/deletion and auto-save.
These demonstrate where product code belongs; other apps replace this domain.

1. App permission UI requests a document-tree grant through
   [AppStoragePermission](../../../lib/features/permissions/data/datasources/app_storage_permission.dart).
   DocMan and the app's Android status-directory channel resolve readable folders.
   Gallery permission is a separate capability; neither grant proves the other.
2. `StatusBloc` calls `LoadStatusesUseCase`, then `StatusRepo`, then
   `StatusLocalDataSource` and its file-system engine. Progress snapshots reach
   the BLoC; mode/version guards prevent an old source load replacing a new one.
3. `StatusCollection`/`StatusMedia` feed the grid and viewer. The saved-media
   feature owns save operations and gallery state through its own use cases,
   repository, data sources and `SavedMediaBloc`.
4. Shared purchase/ad/rating/analytics integrations surround the product action.
   The kit supplies those reusable operations; the app decides which successful
   save is a milestone and which actions require premium access.

The background path is a separate lifecycle. `main.dart` exposes the annotated
WorkManager `callbackDispatcher`. In that background isolate, foreground bootstrap
and GetIt registrations have not run. [AutoSaveService](../../../lib/features/saved_media/data/services/auto_save_service.dart)
therefore creates its own notification scheduler; in the foreground it reuses
the runtime scheduler. “One instance” means one per owning runtime/isolate, not
one Dart object shared across independent isolates. Use this pattern only for
apps with background work, and define their own tasks, permissions and data access.

## 15. Extending the portfolio baseline

The baseline does not exhaust the likely app needs. Add these integrations when
the product requires them; retain the same contract/adapter/runtime boundaries.

| Additional need | Guidance and integration boundary |
|---|---|
| Account sign-in | [Auth](skills/auth/SKILL.md): selected neutral auth adapter; connect account changes to analytics, purchases and app data explicitly. |
| Profile/backend data | [Profile](skills/profile/SKILL.md), [Firebase infrastructure](skills/firebase-infrastructure/SKILL.md): app-owned records/rules and repository models over selected adapters. |
| Push and reminders | [Push](skills/push-notifications/SKILL.md), [local notifications](skills/local-notifications/SKILL.md): provider/scheduler plus permission, identity, channel/timezone, campaign and tap-routing ownership. |
| Device permissions | [Permissions](skills/permissions/SKILL.md): shared coordinator for generic requests; app-owned resource grants for specialized access. |
| External links | [Deep linking](skills/deep-linking/SKILL.md), [navigation](skills/navigation/SKILL.md): validate input and apply access checks before app routing. |
| Offline data | [Offline caching](skills/offline-caching/SKILL.md), [storage migration](skills/storage-migration/SKILL.md): feature cache/pagination policy over suitable storage, preserving formats and history. |
| AI/chat/generation | [Chat AI](skills/chat-ai/SKILL.md), [image generation](skills/image-generation/SKILL.md): app features/backend contracts, not assumed universal kit screens. |
| Metered access | [Content locking](skills/content-locking/SKILL.md), [quota](skills/quota-rate-limiting/SKILL.md): shared entitlement evaluation plus app/backend usage rules. |
| Launch presentation | [Splash](skills/splash-screen/SKILL.md): shared flow with app branding and explicitly configured launch actions/placements. |
| Crash and system UI | [Crashlytics](skills/crashlytics/SKILL.md), [logging](skills/logging/SKILL.md), [immersive UI](skills/immersive-ui/SKILL.md): connect selected reporters/hooks and platform controls to the same runtime. |

For example, a document app keeps Lab, developer controls, feedback/rating,
onboarding, monetization and telemetry, then adds document repositories, editor
BLoCs and export permissions. A chat app keeps that baseline and adds auth,
conversation storage, streaming, notification routing and backend quota. Neither
copies WhatsApp paths, media caches or Story Saver's premium feature conditions.

## 16. Apply this template to a new portfolio app

1. Establish app identity, target platforms, brand and main product workflows.
   Include section 11's baseline without requiring the user to name it again.
2. Prepare an integration map: capability, selected adapter/UI, app configuration,
   construction file, runtime owner, user entry point, policy/listeners, Lab fields
   and native setup. Missing credentials are configuration work, not a reason
   to silently remove a guaranteed feature or substitute a success-returning no-op.
3. Create the default folders and app types. Declare baseline packages plus chosen
   extensions and compatible adapters; do not install every alternative vendor.
4. Populate typed environment/app-link/purchase/placement configuration. Reuse
   shared key/default classes. Record deliberate overrides separately from kit defaults.
5. Compose storage, lifecycle, providers and cross-feature listeners. Separate
   guaranteed product features from startup-critical modules; render recovery
   for required failure and usable UI with diagnostics for optional service failure.
6. Connect Settings, developer unlock/section, Lab, feedback/contact, rating,
   onboarding, purchase/restore, Android root exit and the app's ad surfaces.
   Supply actual app content and destinations; empty demo controls are incomplete.
7. Connect analytics/retention, remote refresh and consumers, replay configuration
   and recorder status. Check that Lab controls act on those same instances.
8. Implement a product feature end to end through BLoC/use cases/repository/data.
   Use [the small example](references/feature-walkthrough.md) for structure and
   the Story Saver section for how a real product composes shared capabilities.
9. Inspect error, cancellation, repeated-action, state-lifetime and cleanup paths.
   Follow the repository's analyzer/test/build rules and relevant native checks.
10. Report baseline integration status, app-specific features, unresolved external
    configuration and actual validation. A first working product screen is a
    milestone; it does not by itself complete a new portfolio app's baseline.

For implementation use [create an app](projects/new/SKILL.md); for a focused
change use [adopt a feature](projects/refactor/SKILL.md). Preserve the current
source description and the reusable requirements when updating this guide.
