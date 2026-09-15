---
name: image-generation
description: "Implement an app feature for image generation, results, and history through its backend."
---

# Image-generation feature

This skill implements the product feature. For creating development artwork or
icons, use [app icon generation](../app-icon-generation/SKILL.md) or
[app promotions](../app-promotions/SKILL.md).

- Inspect the app's backend, job model, and supported generation options.
  Do not assume a specific Cloud Function filename already exists.
- Keep provider credentials and quota enforcement on the backend.
- Define pending, running, completed, cancelled, and failed states. Use job/request
  IDs for retry and reconnect without starting duplicate paid work.
- Save results with account ownership and a defined retention policy. Handle
  expired URLs and downloads separately from generation failure.
- Reuse kit auth, purchase access, and analytics where selected. Keep generation
  models, history, and UI in the app.
- Track durations/counts/outcomes without sending prompts or generated content
  to unrelated analytics. Mask sensitive content when recording screens.

Add variations, styles, or history only when required by the feature request.
Check duplicate taps, timeout, reconnect, quota exhaustion, and result expiry.

## Treat generation as a job with a separate result

Define the backend job ID, authenticated owner, accepted parameters, status,
result references, and failure code. The feature repository maps those records
to domain models; use cases create/resume/cancel jobs; the BLoC renders progress
and result state. Keep vendor-specific response parsing in the data layer.

Creating a job, generating an image, downloading it, and saving it to the user's
chosen location are separate operations. Preserve a successful generation when
a later download fails so Retry does not start another paid job. Request a local
save permission only when the chosen platform operation needs it.

If the request times out, first determine whether the server accepted a job.
Use the established request ID and backend deduplication/resume contract. Do not
blindly create a new job on every timeout. Explain whether cancellation stops
only local waiting or also the server's generation work.

Resolve expired result URLs through the backend's supported mechanism. Persist
stable result IDs rather than assuming a temporary URL lasts forever. Enforce
account ownership and retention on the backend, and keep history queries scoped
to the current account. Reuse the app's image/cache component for presentation.
