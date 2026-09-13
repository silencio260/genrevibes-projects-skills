# Agent Operating Rules

## Tests Are Opt-In

- Do not create new test files unless the user explicitly asks for tests.
- Do not run `flutter test`, builds, or other long validation suites unless the user explicitly asks for that command.
- Run `flutter analyze` when useful; it does not require a separate user request.
- For the opt-in tests, builds, and long validation suites above, state the exact command and wait for the user to ask for it.
- For quick sanity checks, prefer static inspection and small targeted reads over running project-wide commands.
