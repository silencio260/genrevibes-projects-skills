# Agent Operating Rules

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
