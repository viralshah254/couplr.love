import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'premium_models.dart';

/// Repository for subscription status and offerings.
/// Can be backed by RevenueCat or a mock for development.
abstract class PremiumRepository {
  Stream<SubscriptionStatus> get statusStream;
  Future<SubscriptionStatus> get status;
  Future<PremiumOffering?> get currentOffering;
  Future<void> purchasePackage(String packageId);
  Future<void> restorePurchases();
}

/// Mock implementation: in-memory status, fake offering with trial.
class MockPremiumRepository implements PremiumRepository {
  MockPremiumRepository();

  SubscriptionStatus _status = SubscriptionStatus.notSubscribed;
  static final _controller = StreamController<SubscriptionStatus>.broadcast();

  @override
  Stream<SubscriptionStatus> get statusStream => _controller.stream;

  @override
  Future<SubscriptionStatus> get status async => _status;

  @override
  Future<PremiumOffering?> get currentOffering async {
    return PremiumOffering(
      id: 'default',
      paywallTitle: 'Unlock Couplr Premium',
      paywallSubtitle: 'Better communication, deeper connection.',
      packages: [
        PremiumPackage(
          id: 'monthly',
          title: 'Monthly',
          subtitle: 'Billed monthly',
          price: '\$9.99/mo',
          isBestValue: false,
        ),
        PremiumPackage(
          id: 'annual',
          title: 'Annual',
          subtitle: 'Save 40%',
          price: '\$59.99/yr',
          trialDays: 7,
          isBestValue: true,
        ),
        PremiumPackage(
          id: 'lifetime',
          title: 'Lifetime',
          subtitle: 'One-time purchase',
          price: '\$149.99',
          isBestValue: false,
        ),
      ],
    );
  }

  @override
  Future<void> purchasePackage(String packageId) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _status = packageId == 'annual' ? SubscriptionStatus.inTrial : SubscriptionStatus.subscribed;
    _controller.add(_status);
  }

  @override
  Future<void> restorePurchases() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // Mock: no prior purchase
    _controller.add(_status);
  }
}

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return MockPremiumRepository();
});

final premiumStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  return ref.watch(premiumRepositoryProvider).statusStream;
});

final premiumStatusFutureProvider = FutureProvider<SubscriptionStatus>((ref) {
  return ref.watch(premiumRepositoryProvider).status;
});

final isPremiumProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(premiumStatusFutureProvider).when(
        data: (s) => AsyncValue.data(
          s == SubscriptionStatus.subscribed || s == SubscriptionStatus.inTrial,
        ),
        loading: () => const AsyncValue.loading(),
        error: (e, _) => AsyncValue.data(false),
      );
});

final currentOfferingProvider = FutureProvider<PremiumOffering?>((ref) {
  return ref.watch(premiumRepositoryProvider).currentOffering;
});
