---
name: permissions
description: "Request and recheck app permissions through the kit permission coordinator."
---

# Permissions

Use `PermissionCoordinator` with `PermissionHandlerProvider` and the app's
store. Reuse its request/check flow, stored throttling, and `needsSettings` result.

1. Select only permissions used by a real feature. Add the relevant native
   declarations and purpose text for each target platform.
2. Explain the feature need at the user action, then request permission.
3. Handle granted, denied, limited, unsupported, and settings-required results
   according to the selected permission's API. Do not treat all denials alike.
4. On app resume, call `check` to reflect changes in phone settings. Do not
   automatically call `request` and display another prompt.
5. Recheck before using a protected resource. Keep the UI usable when denied.
6. Dispose observers/listeners with the owning runtime or screen.

A gallery permission is not an Android document-tree grant. Story Saver's
WhatsApp folder selection remains app-owned. Do not copy it into unrelated apps.

Check first request, denial, settings return, and platform support. Review the
installed plugin's platform requirements when adding a new permission.

## Connect a feature to permission state

The [integration source](../../references/examples/integrations/shared_features.dart)
shows `requestFeaturePermissions` and `recheckFeaturePermissions`. Supply the
permission kinds actually needed by the operation. Construct one coordinator
with the shared store so its remembered request policy survives screen changes.

Keep the permission's purpose in the feature UI: for example, explain why a
user-selected export needs a capability immediately before requesting it.
A launch-time request for every permission creates prompts before there is a
reason and makes denial recovery harder.

1. The screen dispatches the requested feature action to its BLoC/service.
2. That owner asks the coordinator for the necessary permissions.
3. Inspect the result and the statuses for those permissions; a successful API
   call alone does not mean access was granted.
4. Execute the protected operation only when the available access is sufficient.
5. Otherwise explain the available alternative or settings action. Do not repeat
   a system prompt the platform will no longer show.
6. On resume, check existing state and update UI. Request again only as part of
   a deliberate user action and the coordinator's supported flow.

Native setup is part of this feature. Read the installed handler adapter/plugin
instructions for the target platform and permission. Keep purpose strings tied
to what the app really does. A manifest entry alone does not obtain a grant, and
a runtime request cannot compensate for missing platform configuration.

For limited access, use only the resources actually granted. For unsupported
capabilities, hide/disable the unavailable operation with an explanation. Do not
send every user to settings for failures settings cannot fix.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_permissions](../../../../../packages/genrevibes_starter_kit/modules/permissions/genrevibes_permissions/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/permissions/genrevibes_permissions/lib/genrevibes_permissions.dart).
- [genrevibes_permissions_handler](../../../../../packages/genrevibes_starter_kit/modules/permissions/genrevibes_permissions_handler/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/permissions/genrevibes_permissions_handler/lib/genrevibes_permissions_handler.dart).
- [genrevibes_storage](../../../../../packages/genrevibes_starter_kit/modules/storage/genrevibes_storage/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/storage/genrevibes_storage/lib/genrevibes_storage.dart).
