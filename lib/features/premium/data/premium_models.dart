/// Subscription status for premium access.
enum SubscriptionStatus {
  unknown,
  notSubscribed,
  subscribed,
  inTrial,
  expired,
}

/// A purchasable package (monthly, annual, lifetime, trial).
class PremiumPackage {
  const PremiumPackage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    this.trialDays,
    this.isBestValue = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String price;
  final int? trialDays;
  final bool isBestValue;
}

/// Paywall offering: list of packages and metadata.
class PremiumOffering {
  const PremiumOffering({
    required this.id,
    required this.packages,
    this.paywallTitle,
    this.paywallSubtitle,
  });

  final String id;
  final List<PremiumPackage> packages;
  final String? paywallTitle;
  final String? paywallSubtitle;
}
