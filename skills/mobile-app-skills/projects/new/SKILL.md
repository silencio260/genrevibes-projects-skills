---
name: new
description: "Create a Flutter portfolio app with the guaranteed GenRevibes baseline and app-specific features."
---

# Create an app

1. Read the [portfolio baseline](../../ARCHITECTURE_ANALYSIS.md#11-guaranteed-portfolio-integrations),
   requested product features and target platforms. Include the baseline even
   when the user only names the main product feature. Reuse supplied identifiers
   and brand choices; ask only for values that are needed and unknown.
2. Create the Flutter project if it does not exist. Use the requested name and
   organization. Keep an existing project intact.
3. Use `lib/bootstrap`, `lib/config`, `lib/core`, and `lib/features` as needed.
   See [project structure](../../skills/project-structure/SKILL.md). Do not create
   empty layers or add dependencies for features the app does not use.
4. Connect the kit at a reviewed commit using [submodules](../../skills/git-submodules/SKILL.md).
   Follow [starter kit setup](../../starter-kit/SKILL.md) for package dependencies.
5. Follow [environment setup](../../skills/env-config/SKILL.md). Its templates live
   at `agents/skills/mobile-app-skills/templates`, relative to the app root.
6. Implement visible loading/retry and compose baseline and additional modules using
   [runtime setup](../../skills/runtime-setup/SKILL.md).
7. Connect one useful feature end to end, then complete the baseline and remaining
   product features. Use shared kit UI and supply the app's content. A first screen
   is an implementation milestone, not the finished portfolio app.
8. Add the repository instruction entry point described in the
   [skills index](../../README.md). Preserve any existing operating rules.

Check imports, configuration, cleanup, and navigation. Report missing native
configuration and device checks. Follow repository rules for analyzer, tests,
and builds; creating an app does not authorize publishing it.

Every new portfolio app includes Lab, the developer section, feedback/contact
forms, rating, Android root exit prompt, ads, retention, analytics, onboarding,
IAP, remote config and session replay integration unless the user explicitly
changes that app's baseline. Choose adapters and app configuration for each;
modular packages do not make these features optional. Replay recording still
follows collection/rollout policy, and platform-specific UI applies where supported.

The app uses the portfolio architecture below; neutral kit packages do not
themselves depend on BLoC or GetIt. Firebase is a provider choice; if selected,
configure its actual services before their adapters start.

## Concrete starting layout and registration order

Use the tree in [architecture](../../ARCHITECTURE_ANALYSIS.md). For a new app
following this portfolio, use BLoC, GetIt, and the existing Failure/use-case style.
Choose compatible versions from the current app/kit manifests rather than copying
an old dependency list. The kit can work with other architectures, but that is
not a reason to leave this portfolio's default unspecified.

A new project workflow has these distinct outputs:

1. Flutter host folders and app identifiers. If the user requested a new project,
   `flutter create --org <chosen-organization> <chosen-app-name>` creates them;
   replace the placeholders with actual agreed values.
2. Root instructions and shared agents/kit checkouts at known revisions.
3. A pubspec containing the baseline and selected extensions/adapters, without
   installing every alternative vendor SDK.
4. Environment examples plus local populated files. A copied blank template is
   not a configured Firebase or RevenueCat project.
5. Visible startup with explicit required/optional services and cleanup.
6. The app theme/router, baseline UI/actions and product features with registration
   and error UI, including a Lab connected to the live runtime.
7. Feature-specific native setup and clear remaining device checks.

### Work through the first feature

Use the [complete preference feature](../../references/feature-walkthrough.md)
as a structural example. Follow main → registration → route → screen → BLoC →
use case → repository → kit contract. It uses local storage so a first useful
screen does not depend on remote credentials.

Then complete the baseline and requested extensions using their specific skills. For example,
a feedback page reuses kit UI directly; it should not copy the preference feature's
layers just to wrap an already complete form. A custom downloader feature does
need its own state, data access, and domain operations.

### Before handing over

Report each baseline integration's status, which identifiers/configuration are
real, and which provider/native steps remain. Missing credentials do not justify
silently dropping a baseline feature. Distinguish a guaranteed product feature
from a service that is optional for launch. Confirm that required startup failure
has a Retry screen and optional integrations do not prevent the first feature
from opening. Do not report an empty scaffold as a working app.
