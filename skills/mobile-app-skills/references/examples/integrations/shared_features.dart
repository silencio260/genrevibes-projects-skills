// Small integration functions, not a replacement bootstrap for the whole app.
// Arguments are existing app-owned instances. See integration-examples.md.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genrevibes_ads/genrevibes_ads.dart';
import 'package:genrevibes_analytics_posthog/genrevibes_analytics_posthog.dart';
import 'package:genrevibes_consent/genrevibes_consent.dart';
import 'package:genrevibes_consent_appodeal/genrevibes_consent_appodeal.dart';
import 'package:genrevibes_core/genrevibes_core.dart';
import 'package:genrevibes_developer_access/genrevibes_developer_access.dart';
import 'package:genrevibes_devtools/genrevibes_devtools.dart';
import 'package:genrevibes_feedback/genrevibes_feedback.dart';
import 'package:genrevibes_feedback_ui/genrevibes_feedback_ui.dart';
import 'package:genrevibes_iap/genrevibes_iap.dart';
import 'package:genrevibes_notifications/genrevibes_notifications.dart';
import 'package:genrevibes_onboarding/genrevibes_onboarding.dart';
import 'package:genrevibes_permissions/genrevibes_permissions.dart';
import 'package:genrevibes_remote_config/genrevibes_remote_config.dart';
import 'package:genrevibes_remote_config_firebase/genrevibes_remote_config_firebase.dart';
import 'package:genrevibes_remote_policy/genrevibes_remote_policy.dart';
import 'package:genrevibes_starter_kit/genrevibes_starter_kit.dart';
import 'package:genrevibes_storage/genrevibes_storage.dart';

// Construct during bootstrap. Gate owns its provider; don't initialize it twice.
ConsentGate makeAppodealConsent(String platformAppKey, KitLogger logger) =>
    ConsentGate(
      provider: AppodealConsentProvider(
        appKey: platformAppKey,
        timeout: const Duration(seconds: 8),
        logger: logger,
      ),
      timeout: const Duration(seconds: 8),
      failOpen: true,
      logger: logger,
    );

// Caller owns the returned coordinator through resources. Pass ads already
// configured with the chosen placements and initial developer test mode.
GenRevibesStarterKit makeRuntime({
  required KitResourceScope resources,
  required OnboardingController onboarding,
  required ConsentGate consent,
  required AdProvider ads,
  required KitLogger logger,
}) {
  resources.addModule(onboarding);
  resources.addModule(consent);
  resources.addModule(ads);
  final kit = GenRevibesStarterKit(
    autoStartDeferred: false,
    logger: logger,
    modules: [
      StarterModuleRegistration.enabled(
        moduleId: onboarding.moduleId,
        create: () => onboarding,
      ),
      StarterModuleRegistration.deferred(
        moduleId: consent.moduleId,
        create: () => consent,
        timeout: const Duration(seconds: 8),
      ),
      StarterModuleRegistration.deferred(
        moduleId: ads.moduleId,
        create: () => ads,
      ),
    ],
  );
  resources.addModule(kit);
  return kit;
}

// Invoke from mounted app UI after required initialization succeeds.
void startDeferredAfterFrame(GenRevibesStarterKit kit, KitResourceScope scope) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!scope.isClosed) unawaited(kit.startDeferred());
  });
}

// Caller sets product-specific action scope; this variant permits diagnostics
// for passcode sessions while listed/development devices retain both actions.
DeveloperAccessController makeDeveloperAccess(
  KeyValueStore store,
  bool isDevelopmentBuild,
) => DeveloperAccessController(
  store: store,
  config: DeveloperAccessConfig(
    isDevelopmentBuild: isDevelopmentBuild,
    passcodeActions: {DeveloperAction.diagnostics},
  ),
);

// This function opens an existing initialized provider's UI. No extra form BLoC.
Future<bool> openContact(BuildContext context, FeedbackProvider feedback) =>
    openFeedbackPage(
      context,
      provider: feedback,
      kind: FeedbackKind.contact,
      maxScreenshots: 1,
      maxAttachmentBytes: 10 * 1024 * 1024,
      submissionTimeout: const Duration(seconds: 30),
      protectContent: (child) => PostHogMaskWidget(child: child),
    );

// Use only in a PostHog app. Otherwise remove its import and protectContent.
// No picker is supplied here, so screenshot selection is hidden.

EntitlementAccessPolicy makeAccessPolicy(String paidEntitlementId) =>
    EntitlementAccessPolicy([
      FeatureEntitlementRule(
        featureId: 'remove_ads',
        anyOf: {paidEntitlementId},
      ),
      FeatureEntitlementRule(featureId: 'exports', anyOf: {paidEntitlementId}),
    ]);

// Attach once during bootstrap. Call receive for the app's one snapshot holder.
// A successful purchase must still be checked by the feature's access policy.
void followEntitlements(
  IapProvider iap,
  KitResourceScope scope,
  void Function(EntitlementSnapshot) receive,
) {
  final subscription = iap.entitlementChanges.listen((snapshot) {
    if (!scope.isClosed) receive(snapshot);
  });
  scope.add(subscription.cancel);
}

// Caller disables competing actions, then handles every PurchaseStatus in UI.
Future<KitResult<PurchaseResult>> openPaywall(
  IapProvider iap,
  String entitlementId,
) => iap.presentPaywall(requiredEntitlementId: entitlementId);

// Return the result. Do not discard a restore failure or fabricate success.
Future<KitResult<EntitlementSnapshot>> restorePurchases(IapProvider iap) =>
    iap.restorePurchases();

// Firebase must already be initialized. One schema goes to provider, coordinator,
// and Lab; do not create a different set of defaults in each location.
RemoteConfigCoordinator makeRemoteConfig(
  RemoteConfigSchema schema,
  KitLogger logger,
) => RemoteConfigCoordinator(
  schema: schema,
  provider: GenRevibesFirebaseRemoteConfigProvider(
    schema: schema,
    logger: logger,
  ),
  logger: logger,
);
RemoteConfigSchema makeSharedSchema() => PortfolioRemoteConfigSchema.build();

// Request only from a user action. Resume code calls check instead.
Future<KitResult<PermissionFlowResult>> requestFeaturePermissions(
  PermissionCoordinator permissions,
  Iterable<PermissionKind> kinds,
) => permissions.request(kinds);
Future<KitResult<PermissionFlowResult>> recheckFeaturePermissions(
  PermissionCoordinator permissions,
  Iterable<PermissionKind> kinds,
) => permissions.check(kinds);

// The initialized scheduler owns platform work. Caller owns reminder choice
// and a persistent campaign definition if this must be restored after restart.
Future<KitResult<void>> scheduleReadingReminder(
  LocalNotificationScheduler scheduler,
) => scheduler.schedule(
  const LocalNotificationRequest(
    id: 4100,
    content: LocalNotificationContent(
      title: 'Time to read',
      body: 'Continue your reading.',
      payload: 'reading_home',
      channelId: 'reading_reminders',
      channelName: 'Reading reminders',
    ),
    schedule: LocalNotificationDaily(hour: 20, minute: 0),
  ),
);

// Call once when navigation is ready. Do not call from analytics.
LocalNotificationInteraction? takePendingTap(
  LocalNotificationScheduler scheduler,
) {
  if (scheduler case final LocalNotificationPendingInteractions pending) {
    return pending.takePendingInteraction();
  }
  return null;
}

// Host choices are explicit; more optional running instances can be supplied.
DevToolsHost makeLabHost({
  required GenRevibesStarterKit kit,
  required DeveloperAccessController access,
  required RecordingKitLogger logger,
  required OnboardingController onboarding,
  required LocalNotificationScheduler notifications,
}) => DevToolsHost(
  kit: kit,
  catalogue: const DevAnalyticsCatalogue(events: []),
  developerAccess: access,
  logger: logger,
  onboarding: onboarding,
  localNotifications: notifications,
);
