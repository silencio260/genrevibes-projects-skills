---
name: GDPR Compliance
description: Consent dialogs, data handling, and privacy compliance via starter kit
---

# GDPR Compliance

## Overview

GDPR compliance handles consent dialogs and data privacy using the starter kit's `GdprRepository`.

## Implementation

```dart
final gdprRepo = StarterKit.sl<GdprRepository>();

// Check consent status
final hasConsent = await gdprRepo.hasUserConsented();

// Show consent dialog
await gdprRepo.showConsentDialog();

// Reset consent
await gdprRepo.resetConsent();
```

### Show on First Launch

```dart
// In splash/onboarding flow
if (!await gdprRepo.hasUserConsented()) {
  await gdprRepo.showConsentDialog();
}
```

## Interaction Map

- **Onboarding** → Show consent during onboarding
- **Ads** → Personalized vs non-personalized ads based on consent
- **Analytics** → Respect consent for tracking
- **Settings** → Privacy settings tile

## Checklist

- [ ] Consent dialog shown on first launch
- [ ] Consent status persisted
- [ ] Ads respect consent preference
- [ ] Settings includes privacy management
