---
name: profile
description: "Implement app-owned profile data using the selected database adapter."
---

# User profiles

The app owns profile fields, validation, edit screens, and data ownership rules.
The kit's database package provides generic access; it does not define a shared
profile repository or universal subscription/usage schema.

1. Inspect the existing schema and authentication identity before adding fields.
2. Keep profile reads/writes in the feature repository, using the chosen database
   adapter where it fits. Define document paths explicitly.
3. Enforce ownership and allowed fields on the backend. A client-editable profile
   value must not grant paid access or increase quota.
4. Handle missing profiles, partial updates, offline state, and account switches.
   Cancel old-user subscriptions before attaching new ones.
5. Keep subscription access in the IAP policy and server-verified records.
   Copy only display information into the profile when the UI needs it.

Do not log profile contents or clear all preferences on profile reset.
Check that one account cannot read or change another account's records.

## Define the schema and write permissions first

Record the profile document path, account ID source, required fields, optional
fields, server-owned fields, and timestamps. Use the app's authenticated identity
to choose the current user's path; do not accept an arbitrary target user ID
from an editable form as authority to update that document.

Follow the default feature structure: presentation BLoC/screens, domain model
and repository interface, use cases, then the data repository/adapter. The
repository maps stored fields to the domain model and handles missing/older
fields. Widgets should not cast raw database maps.

Use partial updates for editable fields so saving a display name does not erase
other settings. Keep paid access, roles, quota, and moderation flags out of the
client-editable field set. Enforce this on the backend/rules as well as the UI.

Distinguish loading, a genuinely missing profile, read failure, and an existing
profile. A failed read must not trigger overwriting the document with defaults.
Define recovery for a missing document after successful signup. When switching
accounts, cancel the old subscription and clear its displayed data before the
new profile arrives.

For another portfolio app, reuse the database adapter and feature architecture;
choose its actual fields and ownership rules. Do not transplant a chat, media,
or subscription profile schema into a product that has different data.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_database](../../../../../packages/genrevibes_starter_kit/modules/database/genrevibes_database/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/database/genrevibes_database/lib/genrevibes_database.dart).
- [genrevibes_database_firestore](../../../../../packages/genrevibes_starter_kit/modules/database/genrevibes_database_firestore/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/database/genrevibes_database_firestore/lib/genrevibes_database_firestore.dart).
