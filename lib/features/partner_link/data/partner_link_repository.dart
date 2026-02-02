import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/prefs/shared_prefs.dart';

const _keyPartnerLinked = 'partner_linked';
const _keyPendingInviteId = 'pending_invite_id';

/// Represents partner link state. Extend with real API when backend exists.
class PartnerLinkState {
  const PartnerLinkState({
    this.isLinked = false,
    this.pendingInviteId,
    this.partnerDisplayName,
  });

  final bool isLinked;
  final String? pendingInviteId;
  final String? partnerDisplayName;
}

abstract class PartnerLinkRepository {
  Future<bool> isPartnerLinked();
  Future<void> setPartnerLinked({String? partnerId, String? displayName});
  Future<String?> getPendingInviteId();
  Future<void> setPendingInviteId(String? id);
}

class SharedPrefsPartnerLinkRepository implements PartnerLinkRepository {
  SharedPrefsPartnerLinkRepository(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<bool> isPartnerLinked() async {
    return _prefs.getBool(_keyPartnerLinked) ?? false;
  }

  @override
  Future<void> setPartnerLinked({String? partnerId, String? displayName}) async {
    await _prefs.setBool(_keyPartnerLinked, true);
  }

  @override
  Future<String?> getPendingInviteId() async {
    return _prefs.getString(_keyPendingInviteId);
  }

  @override
  Future<void> setPendingInviteId(String? id) async {
    if (id == null) {
      await _prefs.remove(_keyPendingInviteId);
    } else {
      await _prefs.setString(_keyPendingInviteId, id);
    }
  }
}

final partnerLinkRepositoryProvider = FutureProvider<PartnerLinkRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SharedPrefsPartnerLinkRepository(prefs);
});

final partnerLinkStateProvider = FutureProvider<PartnerLinkState>((ref) async {
  final repo = await ref.watch(partnerLinkRepositoryProvider.future);
  final isLinked = await repo.isPartnerLinked();
  final pendingInviteId = await repo.getPendingInviteId();
  return PartnerLinkState(isLinked: isLinked, pendingInviteId: pendingInviteId);
});
