import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/prefs/shared_prefs.dart';

const _keyOnboardingComplete = 'onboarding_complete';

abstract class OnboardingRepository {
  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete();
}

class SharedPrefsOnboardingRepository implements OnboardingRepository {
  SharedPrefsOnboardingRepository(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  @override
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_keyOnboardingComplete, true);
  }
}

final onboardingRepositoryProvider = FutureProvider<OnboardingRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SharedPrefsOnboardingRepository(prefs);
});

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final repo = await ref.watch(onboardingRepositoryProvider.future);
  return repo.isOnboardingComplete();
});
