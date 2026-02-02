import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefJournalVisibility = 'privacy_journal_visibility';
const String _prefAnalyticsEnabled = 'privacy_analytics_enabled';

/// Who can see shared journal entries.
enum JournalVisibility {
  onlyMe('Only me', 'Entries are visible only to you'),
  partner('Partner', 'Shared entries visible to your partner'),
  both('Both', 'Shared entries visible to both of you');

  const JournalVisibility(this.label, this.subtitle);
  final String label;
  final String subtitle;

  static JournalVisibility fromString(String? value) {
    switch (value) {
      case 'partner':
        return JournalVisibility.partner;
      case 'both':
        return JournalVisibility.both;
      default:
        return JournalVisibility.onlyMe;
    }
  }

  String get value {
    switch (this) {
      case JournalVisibility.partner:
        return 'partner';
      case JournalVisibility.both:
        return 'both';
      default:
        return 'only_me';
    }
  }
}

/// Loads and persists privacy preferences.
class PrivacyPreferencesRepository {
  PrivacyPreferencesRepository({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<JournalVisibility> getJournalVisibility() async {
    final prefs = await _getPrefs();
    return JournalVisibility.fromString(prefs.getString(_prefJournalVisibility));
  }

  Future<void> setJournalVisibility(JournalVisibility value) async {
    final prefs = await _getPrefs();
    await prefs.setString(_prefJournalVisibility, value.value);
  }

  Future<bool> getAnalyticsEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_prefAnalyticsEnabled) ?? true;
  }

  Future<void> setAnalyticsEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_prefAnalyticsEnabled, value);
  }
}

final privacyPreferencesRepositoryProvider = Provider<PrivacyPreferencesRepository>((ref) {
  return PrivacyPreferencesRepository();
});

final journalVisibilityProvider = FutureProvider<JournalVisibility>((ref) async {
  return ref.watch(privacyPreferencesRepositoryProvider).getJournalVisibility();
});

final analyticsEnabledProvider = FutureProvider<bool>((ref) async {
  return ref.watch(privacyPreferencesRepositoryProvider).getAnalyticsEnabled();
});
