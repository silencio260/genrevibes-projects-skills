---
name: app-rename
description: "Change a Flutter app display name or explicitly requested platform identity."
---

# Rename an app

A display name, Dart package name, Android application ID, and iOS bundle ID are
separate values. Change only the values the user requested.

For a display-name change, inspect Android application/activity labels and iOS
bundle display names, including localized resources. Preserve unrelated activity
aliases and feature names. No package rename or clean build is normally needed.

For an explicit identity change:

1. Establish the old/new identifiers and whether this is intentionally a new
   store identity. Do not infer a package rename from a branding request.
2. Update native namespaces, application/bundle IDs, classes, manifest references,
   providers/authorities, and app-owned imports where applicable.
3. Identify Firebase, push, OAuth, deep-link associations, store products, and ad
   registrations tied to the old identity. Report required service changes.
4. If using a rename tool, inspect its installed version/help and its exact diff.
   Tools may miss additional native classes or change unrelated labels.
5. Search active source/config for the old identifier and classify remaining hits.

Keep signing identity and existing store configuration unless changing them is
part of the task. Do not run builds or modify external registrations incidentally.
Use [branding](../branding/SKILL.md) for icons and [deep links](../deep-linking/SKILL.md)
for domain associations.

## Build a change map before replacing text

List the requested old/new values by category: visible name, Dart package name,
Android ID/namespace, and iOS bundle ID. If only the visible name changes, limit
the edit to relevant labels/localizations and user-facing resources. Avoid a
repository-wide string replacement that changes service IDs and imports.

For an explicitly requested identity change, trace each native declaration and
external registration tied to that identity. Include manifest authorities,
platform classes, Firebase options, OAuth callbacks, push configuration, domain
associations, and store/ad product registrations where present. A local rename
tool may update only a subset of those locations.

After editing, inspect remaining old-name matches and classify them: a historical
note can remain; an active package import or platform registration may need work.
Preserve unrelated app labels and files. Report external changes still needed
without claiming they were performed by the local rename.

Keep the existing signing arrangement unless the requested identity change also
requires a deliberate new store setup. A new display name alone does not require
a new signing key or application ID.
