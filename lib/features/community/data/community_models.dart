/// Anonymous forum room (topic).
class ForumRoom {
  const ForumRoom({
    required this.id,
    required this.title,
    this.description,
    this.threadCount = 0,
  });

  final String id;
  final String title;
  final String? description;
  final int threadCount;
}

/// A thread in a room: anonymous, with moderation/report/save.
class ForumThread {
  const ForumThread({
    required this.id,
    required this.roomId,
    required this.title,
    this.body,
    required this.authorId,
    required this.createdAt,
    this.reactionCount = 0,
    this.replyCount = 0,
    this.isSaved = false,
    this.isModerated = false,
  });

  final String id;
  final String roomId;
  final String title;
  final String? body;
  final String authorId;
  final DateTime createdAt;
  final int reactionCount;
  final int replyCount;
  final bool isSaved;
  final bool isModerated;
}

/// A post (reply) in a thread.
class ForumPost {
  const ForumPost({
    required this.id,
    required this.threadId,
    required this.body,
    required this.authorId,
    required this.createdAt,
    this.reactionCount = 0,
  });

  final String id;
  final String threadId;
  final String body;
  final String authorId;
  final DateTime createdAt;
  final int reactionCount;
}

/// Reaction type on thread or post.
enum ReactionType { like, support, thanks }
