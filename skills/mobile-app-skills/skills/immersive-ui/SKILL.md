---
name: immersive-ui
description: "Configure edge-to-edge layout and optional kit navigation-bar controls."
---

# System bars and edge-to-edge layout

Use the app's chosen layout. Edge-to-edge backgrounds do not require hiding
system bars, and kit adoption does not require an immersive design.

- Let backgrounds reach the edges where intended. Protect interactive content
  with appropriate SafeArea or MediaQuery insets; avoid applying the inset twice.
- Match system icon brightness to the actual background. Do not set `extendBody`
  or disable contrast protection on every screen without checking the layout.
- For apps choosing kit navigation-bar control, use `NavigationBarController`,
  `NavigationBarScope`, its navigator observer, and `NavigationBarVisibility`
  for route exceptions. Keep one controller.
- Connect developer mode only when the app wants that shared control. Pass the
  same controller to Kit Lab.
- Inspect SDK overlay exclusions before changing native activity behavior.
  Do not hide navigation on purchase or sign-in screens indiscriminately.
- Provide app Back controls on pushed pages, and inspect gesture/three-button
  navigation, keyboard, rotation, and display cutouts.

Dispose the controller with the runtime. Read the installed package's platform
behavior rather than promising identical results on every Android/iOS version.

## Assign one owner to system-bar behavior

Keep app-wide policy in the runtime/controller and route exceptions in the
supported visibility wrapper/observer. Do not scatter competing `SystemChrome`
changes across every screen's init/build callbacks. If a screen temporarily
changes policy, ensure leaving it restores the intended previous state.

Inspect each layout separately: background coverage, top controls, bottom actions,
keyboard inset, and system icon contrast. A full-bleed background can extend
under a system bar while the button row stays within safe insets. Avoid wrapping
the same content in multiple layers that each add keyboard or bottom padding.

Native purchase, sign-in, and ad screens have their own lifecycle and platform
constraints. Follow the installed controller/adapter's exclusions and do not
assume a route wrapper controls every native overlay. Give Kit Lab the current
controller so a developer toggle reflects the running app's policy.

Report which layouts were inspected and which device modes still need checking.
Gesture navigation, three-button navigation, rotation, and keyboard visibility
can expose different problems; code inspection alone does not verify all of them.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_system_ui](../../../../../packages/genrevibes_starter_kit/modules/system_ui/genrevibes_system_ui/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/system_ui/genrevibes_system_ui/lib/genrevibes_system_ui.dart).
