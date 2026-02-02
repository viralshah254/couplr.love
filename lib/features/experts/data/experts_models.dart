/// Expert profile (anonymous display).
class Expert {
  const Expert({
    required this.id,
    required this.displayName,
    this.bio,
    this.specialty,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? bio;
  final String? specialty;
  final String? avatarUrl;
}

/// User-submitted question for an expert.
class ExpertQuestion {
  const ExpertQuestion({
    required this.id,
    required this.expertId,
    required this.body,
    required this.createdAt,
    this.status = QuestionStatus.pending,
    this.response,
  });

  final String id;
  final String expertId;
  final String body;
  final DateTime createdAt;
  final QuestionStatus status;
  final String? response;
}

enum QuestionStatus { pending, answered, live }

/// Live room with an expert.
class LiveRoom {
  const LiveRoom({
    required this.id,
    required this.expertId,
    required this.title,
    this.scheduledAt,
    this.isLive = false,
  });

  final String id;
  final String expertId;
  final String title;
  final DateTime? scheduledAt;
  final bool isLive;
}
