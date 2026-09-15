---
name: env-config
description: "Configure compile-time app settings and reusable IDE launch templates."
---

# Environment configuration

Use the app's existing typed environment reader. `--dart-define-from-file`
values are compiled into the app; they are not a server-secret store.

For a new app, templates are under
[templates/env](../../templates/env/env.example.json). From the app root:

```bash
mkdir -p env
cp agents/skills/mobile-app-skills/templates/env/dev.json.example env/dev.json
cp agents/skills/mobile-app-skills/templates/env/release.json.example env/release.json
cp agents/skills/mobile-app-skills/templates/env/special_dev.json.example env/special_dev.json
cp agents/skills/mobile-app-skills/templates/env/env.example.json env.example.json
```

Run copies only for missing files; merge existing configuration. Copy/merge the
`.run` and `.vscode` templates from the same templates directory if those IDEs
are used. Keep real values untracked; commit the blank example. See the
[key reference](../../references/environment-keys.md) before filling values.

- Add readers only for selected features. Blank credentials should leave an
  optional module unconfigured, not look like a real placeholder credential.
- Use real Appodeal app keys in development too; test inventory is a provider
  setting. Direct AdMob unit IDs belong only in apps using that adapter.
- Keep native app IDs and Firebase platform configuration separate from defines.
- Keep developer passcode blank to use the kit default, or supply an app override.
  Hash lists contain hashes only. Opt-out/action restrictions use
  `DeveloperAccessConfig`; do not invent environment keys with no reader.
- State analytics/replay collection choices explicitly. Do not infer an app's
  policy from another app's debug flag or Firebase's persisted state.
- Ensure the IDE profile points to the intended file and actual Flutter build mode.
  Do not run a release profile as an incidental configuration check.

The sample keys are a recipe. A key has no effect until the app reads it and
passes it to the relevant module. Preserve existing key names during migration.

## Trace every configuration value to its reader

For each selected feature, locate its `String.fromEnvironment` or typed reader,
its default, and the constructor receiving that value. Use the
[environment key reference](../../references/environment-keys.md) to distinguish
kit capability from wiring already present in Story Saver.

A blank string and an omitted key may behave differently. For example, do not
add a blank entitlement override if omission is how the app selects its intended
default. Read the actual fallback before creating a template entry. Remove keys
with no reader rather than claiming they configure a feature.

For an existing app, merge new fields into its existing files without printing
real values. Preserve production identifiers and explicit collection choices.
For a new app, copy only missing example files, fill selected client configuration
through the user's existing setup, and leave optional providers unconfigured
until their credentials exist.

Check that each IDE configuration passes the file through Flutter tool arguments,
not application arguments. Confirm the relative path is resolved from the app
root and that the selected profile's mode matches its label. Preparing a release
profile does not require running it.

Compile-time defines are readable client configuration. Keep server API secrets,
private signing credentials, and service-account keys out of these files and
out of screenshots/logs. Do not move them into defines to avoid a backend.
