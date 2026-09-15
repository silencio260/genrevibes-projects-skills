---
name: android-signing
description: "Configure Android release signing while preserving the app existing signing identity."
---

# Android signing

Inspect the current Gradle signing setup and store identity first. Do not replace
an existing key or silently fall back to debug signing for a release artifact.

- Reuse the intended upload/signing key. Keep the keystore and credentials out
  of Git; keep a blank `key.properties.example` if the project uses that format.
- Match the project's Groovy or Kotlin Gradle syntax. Validate required fields
  for release signing and fail clearly when they are absent.
- Keep keystore paths configurable. Do not copy another developer's home path.
- If a new key is needed, give the user a manual `keytool` command with their
  chosen path/alias. Do not generate it automatically or ask for passwords in chat.
- Distinguish an upload key from the app-signing key. Recovery depends on the
  store setup; inspect current official recovery guidance rather than claiming
  every lost upload key prevents all future updates.
- If credentials were exposed, stop exposing them and assess the actual key
  material involved. Do not rewrite history or rotate keys without authorization.

Check configuration without displaying secret values. Builds remain opt-in.
A valid Gradle file does not prove the artifact uses the intended certificate.

## Trace the release signing configuration

Read the app's Android Gradle file and the source of its signing properties.
Determine which signing configuration the release build type uses. Check that
all required fields are validated before a release artifact is produced and
that a missing properties file cannot silently select debug signing.

Inspect paths and field presence without printing passwords or keystore contents.
A blank example may document `storeFile`, `storePassword`, `keyAlias`, and
`keyPassword` if those are the fields the project actually reads. Resolve relative
paths using that Gradle project's rules rather than assuming they are relative
to the repository root.

For an existing published app, preserve its intended signing/update identity.
If the problem is a missing local upload key, establish the store's configured
key arrangement before suggesting replacement. A new local key is not
interchangeable with an existing app-signing certificate.

After source changes, report what the configuration now requires and what has
been inspected. Do not claim a release is signed correctly until an authorized
artifact check establishes its certificate. Do not build a release solely to
complete a documentation or static configuration task.
