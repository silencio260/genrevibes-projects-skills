# Checked kit revision

Reviewed on 14 September 2026 against local kit commit `c1f264086a00d957cf4959a5df9c1c195a88a789`.
The kit working tree was clean when recorded. This records source compatibility;
it does not claim the commit is published or that a fresh clone/device build passed.

These instructions expect the agents repository at `agents` and the kit at
`packages/genrevibes_starter_kit` in the host app. Adjust integration links when
adopting another checkout layout. Do not rename a working folder merely to match this one.

- [Kit package inventory](../../../../packages/genrevibes_starter_kit/README.md)
- [Declared toolchain/platform compatibility](../../../../packages/genrevibes_starter_kit/docs/compatibility-matrix.md)
- [Shared adoption recipes](../../../../packages/genrevibes_starter_kit/docs/portfolio-adoption.md)
- [Complete smoke app dependencies](../../../../packages/genrevibes_starter_kit/examples/genrevibes_smoke_app/pubspec.yaml)
- [Smoke app source](../../../../packages/genrevibes_starter_kit/examples/genrevibes_smoke_app/lib/main.dart)

Read the selected packages' manifests and public exports at the actual pinned
revision. Do not copy a single old Flutter floor or vendor version across all
packages. This revision reference should change when the recipes are reviewed
against another revision, not merely when a git pointer moves.

The smoke app demonstrates composition with many adapters; it is not a list of
packages every app needs. The adoption guide contains partial snippets with
app-supplied values. Follow the relevant skill for lifecycle and error handling.
