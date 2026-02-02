import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'community_models.dart';

abstract class CommunityRepository {
  Future<List<ForumRoom>> getRooms();
  Future<List<ForumThread>> getThreads(String roomId);
  Future<ForumThread?> getThread(String id);
  Future<List<ForumPost>> getPosts(String threadId);
  Future<void> saveThread(String threadId, bool save);
  Future<void> reportThread(String threadId, String reason);
  Future<void> react(String threadIdOrPostId, ReactionType type, bool isThread);
  Future<List<ForumThread>> getSavedThreads();
}

class MockCommunityRepository implements CommunityRepository {
  final List<ForumRoom> _rooms = [
    const ForumRoom(id: '1', title: 'Communication', description: 'Tips and support', threadCount: 12),
    const ForumRoom(id: '2', title: 'Conflict', description: 'Working through conflict', threadCount: 8),
    const ForumRoom(id: '3', title: 'Celebration', description: 'Wins and gratitude', threadCount: 15),
  ];
  final List<ForumThread> _threads = [];
  final List<String> _savedIds = [];

  MockCommunityRepository() {
    final now = DateTime.now();
    _threads.addAll([
      ForumThread(
        id: 't1',
        roomId: '1',
        title: 'How do you start difficult conversations?',
        body: 'Looking for advice on bringing up tough topics without escalating.',
        authorId: 'anon-1',
        createdAt: now.subtract(const Duration(days: 1)),
        reactionCount: 5,
        replyCount: 3,
        isSaved: false,
      ),
      ForumThread(
        id: 't2',
        roomId: '1',
        title: 'Weekly check-in ideas',
        body: 'What questions do you ask each other?',
        authorId: 'anon-2',
        createdAt: now.subtract(const Duration(days: 2)),
        reactionCount: 12,
        replyCount: 7,
        isSaved: true,
      ),
    ]);
    _savedIds.add('t2');
  }

  @override
  Future<List<ForumRoom>> getRooms() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_rooms);
  }

  @override
  Future<List<ForumThread>> getThreads(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _threads.where((t) => t.roomId == roomId).toList();
  }

  @override
  Future<ForumThread?> getThread(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final t = _threads.firstWhere((t) => t.id == id);
      return ForumThread(
        id: t.id,
        roomId: t.roomId,
        title: t.title,
        body: t.body,
        authorId: t.authorId,
        createdAt: t.createdAt,
        reactionCount: t.reactionCount,
        replyCount: t.replyCount,
        isSaved: _savedIds.contains(t.id),
        isModerated: t.isModerated,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ForumPost>> getPosts(String threadId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ForumPost(
        id: 'p1',
        threadId: threadId,
        body: 'We use "I feel" statements and take turns without interrupting.',
        authorId: 'anon-3',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        reactionCount: 2,
      ),
    ];
  }

  @override
  Future<void> saveThread(String threadId, bool save) async {
    if (save) {
      _savedIds.add(threadId);
    } else {
      _savedIds.remove(threadId);
    }
  }

  @override
  Future<void> reportThread(String threadId, String reason) async {}

  @override
  Future<void> react(String threadIdOrPostId, ReactionType type, bool isThread) async {}

  @override
  Future<List<ForumThread>> getSavedThreads() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _threads.where((t) => _savedIds.contains(t.id)).toList();
  }
}

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return MockCommunityRepository();
});

final forumRoomsProvider = FutureProvider<List<ForumRoom>>((ref) {
  return ref.watch(communityRepositoryProvider).getRooms();
});

final forumThreadsProvider = FutureProvider.family<List<ForumThread>, String>((ref, roomId) {
  return ref.watch(communityRepositoryProvider).getThreads(roomId);
});

final forumThreadDetailProvider = FutureProvider.family<ForumThread?, String>((ref, id) {
  return ref.watch(communityRepositoryProvider).getThread(id);
});

final forumPostsProvider = FutureProvider.family<List<ForumPost>, String>((ref, threadId) {
  return ref.watch(communityRepositoryProvider).getPosts(threadId);
});

final savedThreadsProvider = FutureProvider<List<ForumThread>>((ref) {
  return ref.watch(communityRepositoryProvider).getSavedThreads();
});
