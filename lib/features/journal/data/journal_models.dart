/// A journal entry: shared or private, optional photos/audio, encryption.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    this.body,
    required this.createdAt,
    this.isPrivate = false,
    this.hasPhoto = false,
    this.photoUrl,
    this.hasAudio = false,
    this.audioUrl,
    this.isEncrypted = false,
    this.authorId,
  });

  final String id;
  final String title;
  final String? body;
  final DateTime createdAt;
  final bool isPrivate;
  final bool hasPhoto;
  final String? photoUrl;
  final bool hasAudio;
  final String? audioUrl;
  final bool isEncrypted;
  final String? authorId;

  String get preview => body != null && body!.length > 100
      ? '${body!.substring(0, 100)}...'
      : (body ?? '');
}

/// Filter for journal timeline: visibility and optional date.
class JournalFilter {
  const JournalFilter({
    this.visibility = JournalVisibility.all,
    this.date,
  });

  final JournalVisibility visibility;
  final DateTime? date;

  JournalFilter copyWith({JournalVisibility? visibility, DateTime? date}) {
    return JournalFilter(
      visibility: visibility ?? this.visibility,
      date: date ?? this.date,
    );
  }
}

enum JournalVisibility { all, shared, private }
