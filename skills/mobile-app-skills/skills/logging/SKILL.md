---
name: logging
description: "Connect structured kit logs and the shared Kit Lab recorder."
---

# Logging

Use `KitLogger` for kit code and the app's existing logger at app boundaries.
`StarterLog` is not a current shared kit API.

- Include the module, operation, normalized outcome, and useful timing/context.
- Keep original errors/stacks for unexpected failures without dumping private payloads.
- Never log passcodes, credentials, raw device IDs, tokens, form text, or chat content.
- If Kit Lab history is wanted, pass one `RecordingKitLogger` to the coordinator,
  compatible providers, and host. Creating a recorder only inside Lab captures
  none of the earlier module logs.
- Choose release retention explicitly. A console logger and an in-memory Lab
  buffer are separate destinations.
- Dispose the recorder with the runtime; late callbacks must not revive it.

Logs help diagnose a failure; they do not replace handling it. Check that a
representative module event reaches the intended destination once.

## Share one recorder across the runtime

Create `RecordingKitLogger` before constructing providers if startup history
should appear in Lab. Its `forwardTo` destination can preserve the app's existing
logging output while the recorder keeps its bounded in-memory history. Pass the
same logger to each compatible provider and the Lab host. Creating a separate
recorder when Lab opens cannot recover previous events.

Use an operation name and safe context to make messages useful. For example,
identify a failed remote refresh or reminder ID and duration; do not dump the
entire remote response or notification payload. Keep log severity tied to the
outcome so expected cancellation does not look like a fatal failure.

Avoid duplicate reporting chains: if the repository already reports an unexpected
exception, the screen should render its failure without reporting it again.
If a logger destination fails, do not recursively send that failure back through
the same failing destination.

During runtime retry, dispose the old recorder/listeners with their owner and
construct the new runtime's recorder deliberately. The Lab host must point to
the current instance. In the handover, distinguish a local log entry from
confirmed delivery to any remote logging or crash-reporting service.

## Package references

Read the public API and setup for the packages used by this task:

- [genrevibes_core](../../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_core/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/foundation/genrevibes_core/lib/genrevibes_core.dart).
- [genrevibes_devtools](../../../../../packages/genrevibes_starter_kit/modules/devtools/genrevibes_devtools/README.md); [public exports](../../../../../packages/genrevibes_starter_kit/modules/devtools/genrevibes_devtools/lib/genrevibes_devtools.dart).
