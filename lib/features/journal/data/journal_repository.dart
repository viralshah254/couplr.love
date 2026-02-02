import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_models.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getEntries(JournalFilter filter);
  Future<List<JournalEntry>> getEntriesByDate(DateTime date);
  Future<JournalEntry?> getEntry(String id);
  Future<List<DateTime>> getDatesWithEntries();
  Future<void> addEntry(JournalEntry entry);
  Future<void> deleteEntry(String id);
}

class MockJournalRepository implements JournalRepository {
  List<JournalEntry> _entries = [];

  MockJournalRepository() {
    final now = DateTime.now();
    _entries = [
      JournalEntry(
        id: '1',
        title: 'Weekend together',
        body: 'We went for a long walk and had coffee. Felt really connected.',
        createdAt: now.subtract(const Duration(days: 1)),
        isPrivate: false,
        hasPhoto: true,
        hasAudio: false,
        isEncrypted: true,
        authorId: 'user-1',
      ),
      JournalEntry(
        id: '2',
        title: 'Private note',
        body: 'Something I want to remember for myself only.',
        createdAt: now.subtract(const Duration(days: 2)),
        isPrivate: true,
        hasPhoto: false,
        hasAudio: false,
        isEncrypted: true,
        authorId: 'user-1',
      ),
      JournalEntry(
        id: '3',
        title: 'Gratitude moment',
        body: 'Grateful for the morning cuddle.',
        createdAt: now.subtract(const Duration(days: 3)),
        isPrivate: false,
        hasPhoto: false,
        hasAudio: true,
        isEncrypted: false,
        authorId: 'user-1',
      ),
      JournalEntry(
        id: '4',
        title: 'Date night',
        body: 'Cooked together and watched a movie. Best evening.',
        createdAt: now.subtract(const Duration(days: 5)),
        isPrivate: false,
        hasPhoto: true,
        hasAudio: false,
        isEncrypted: true,
        authorId: 'partner-1',
      ),
    ];
  }

  @override
  Future<List<JournalEntry>> getEntries(JournalFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = List<JournalEntry>.from(_entries);

    switch (filter.visibility) {
      case JournalVisibility.shared:
        list = list.where((e) => !e.isPrivate).toList();
        break;
      case JournalVisibility.private:
        list = list.where((e) => e.isPrivate).toList();
        break;
      case JournalVisibility.all:
        break;
    }

    if (filter.date != null) {
      final d = filter.date!;
      list = list.where((e) {
        return e.createdAt.year == d.year &&
            e.createdAt.month == d.month &&
            e.createdAt.day == d.day;
      }).toList();
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<JournalEntry>> getEntriesByDate(DateTime date) async {
    return getEntries(JournalFilter(date: date));
  }

  @override
  Future<JournalEntry?> getEntry(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DateTime>> getDatesWithEntries() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final dates = <DateTime>{};
    for (final e in _entries) {
      dates.add(DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day));
    }
    return dates.toList()..sort((a, b) => b.compareTo(a));
  }

  @override
  Future<void> addEntry(JournalEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _entries = [entry, ..._entries];
  }

  @override
  Future<void> deleteEntry(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _entries.removeWhere((e) => e.id == id);
  }
}

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return MockJournalRepository();
});

final journalFilterProvider = StateProvider<JournalFilter>((ref) {
  return const JournalFilter();
});

final journalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) {
  final filter = ref.watch(journalFilterProvider);
  return ref.watch(journalRepositoryProvider).getEntries(filter);
});

/// Selected entry id for two-pane layout (tablet). Null when narrow or nothing selected.
final selectedJournalEntryIdProvider = StateProvider<String?>((ref) => null);

final journalEntryDetailProvider =
    FutureProvider.family<JournalEntry?, String>((ref, id) {
  return ref.watch(journalRepositoryProvider).getEntry(id);
});

final journalDatesWithEntriesProvider = FutureProvider<List<DateTime>>((ref) {
  return ref.watch(journalRepositoryProvider).getDatesWithEntries();
});

final journalEntriesForDateProvider =
    FutureProvider.family<List<JournalEntry>, DateTime>((ref, date) {
  return ref.watch(journalRepositoryProvider).getEntries(JournalFilter(date: date));
});
