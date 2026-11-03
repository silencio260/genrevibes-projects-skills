# Agent Operating Rules

## App commands must be documented

- Every app must keep its run/build commands in its own root `README.md` and
  `docs/commands.md`. Put Flutter run commands first, Flutter build commands next,
  then release/patch, setup, checks and tooling commands. Keep these sections
  near the top, before architecture or feature descriptions.
- Document every build command the app uses, including environment files,
  defines, modes, targets/flavors, toolchain pins and required flags. When a
  command changes or is introduced, update both files in the same change.
- Also document maintained helper/tool commands, with their working directory,
  prerequisites, purpose, outputs and any upload or live-data effects. Keep
  secrets out of examples and distinguish templates from ready-to-run commands.
- Follow [command documentation](skills/mobile-app-skills/skills/command-documentation/SKILL.md).
  Documentation does not authorize executing a command; the rules below still apply.

## Tests Are Opt-In

- Do not create new test files unless the user explicitly asks for tests.
- Do not run `flutter test`, builds, or other long validation suites unless the user explicitly asks for that command.
- Run `flutter analyze` when useful; it does not require a separate user request.
- For the opt-in tests, builds, and long validation suites above, state the exact command and wait for the user to ask for it.
- For quick sanity checks, prefer static inspection and small targeted reads over running project-wide commands.

## Finding project guidance

- Use [mobile skills](skills/mobile-app-skills/README.md) for app and starter kit work.
- Read [commit policy](skills/commit-policy/SKILL.md) before history or publication actions.
- Keep the user's requested scope. Use shared kit code where it exists; preserve app choices.
- Write instructions in plain language: name the action, file/API, and condition.
  Separate requirements from defaults and app choices. Remove repeated rules and filler.
- Plain language does not mean less detail. Preserve useful procedures, examples,
  architecture, failure behavior, and project-specific constraints. Explain unfamiliar
  terms. Do not replace a working guide with a short summary.
- When revising a skill, compare its old guidance with the current source. Keep what
  still works, correct what changed, and remove claims that no longer apply. Include
  enough context for a human unfamiliar with the feature to follow the instructions.
- CI is a deferred TODO. Do not treat it as a blocker or repeat it in later audits unless asked.

## Required project files

Every app project has these at its root. When one is missing, create it as part
of the current task if it is in scope, or report it as missing.

- `docs/` — project documentation, tracked in Git: audits, plans, integration
  notes, release checklists. Name dated documents `<topic>-YYYY-MM-DD.md`.
  Documentation that applies to every app belongs in this agents repository,
  not in an app's `docs/`.
- `config/remote_config.json` — the app's Firebase Remote Config template,
  populated with that app's values, tracked in Git. It is the bundled default
  and the file uploaded to Firebase. Start a new one from
  [the shared template](skills/mobile-app-skills/skills/remote-config/remote_config_template.json).
  Uploading still requires the user's request; see
  [remote config](skills/mobile-app-skills/skills/remote-config/SKILL.md).
- `app_screenshots/` — raw app screenshots for store listings and promotions.
  It is listed in `.gitignore` (`/app_screenshots/`) and never committed; see
  [large media](skills/commit-policy/SKILL.md#large-media-screenshots-marketing-and-design-files).
