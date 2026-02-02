import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'experts_models.dart';

abstract class ExpertsRepository {
  Future<List<Expert>> getExperts();
  Future<Expert?> getExpert(String id);
  Future<String> submitQuestion(String expertId, String body);
  Future<List<ExpertQuestion>> getMyQuestions();
  Future<List<LiveRoom>> getLiveRooms();
  Future<LiveRoom?> getLiveRoom(String id);
}

class MockExpertsRepository implements ExpertsRepository {
  final List<Expert> _experts = [
    const Expert(
      id: 'e1',
      displayName: 'Dr. Sarah',
      bio: 'Relationship therapist, 15 years.',
      specialty: 'Communication & conflict',
    ),
    const Expert(
      id: 'e2',
      displayName: 'Coach Mike',
      bio: 'Couples coach and mediator.',
      specialty: 'Conflict repair',
    ),
  ];
  final List<ExpertQuestion> _questions = [];
  final List<LiveRoom> _rooms = [];

  MockExpertsRepository() {
    final now = DateTime.now();
    _rooms.addAll([
      LiveRoom(
        id: 'r1',
        expertId: 'e1',
        title: 'Q&A: Difficult conversations',
        scheduledAt: now.add(const Duration(hours: 2)),
        isLive: false,
      ),
      LiveRoom(
        id: 'r2',
        expertId: 'e2',
        title: 'Live: Conflict repair tips',
        scheduledAt: now,
        isLive: true,
      ),
    ]);
  }

  @override
  Future<List<Expert>> getExperts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_experts);
  }

  @override
  Future<Expert?> getExpert(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _experts.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> submitQuestion(String expertId, String body) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final id = 'q-${DateTime.now().millisecondsSinceEpoch}';
    _questions.add(ExpertQuestion(
      id: id,
      expertId: expertId,
      body: body,
      createdAt: DateTime.now(),
    ));
    return id;
  }

  @override
  Future<List<ExpertQuestion>> getMyQuestions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_questions);
  }

  @override
  Future<List<LiveRoom>> getLiveRooms() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_rooms);
  }

  @override
  Future<LiveRoom?> getLiveRoom(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}

final expertsRepositoryProvider = Provider<ExpertsRepository>((ref) {
  return MockExpertsRepository();
});

final expertsListProvider = FutureProvider<List<Expert>>((ref) {
  return ref.watch(expertsRepositoryProvider).getExperts();
});

final expertDetailProvider = FutureProvider.family<Expert?, String>((ref, id) {
  return ref.watch(expertsRepositoryProvider).getExpert(id);
});

final myQuestionsProvider = FutureProvider<List<ExpertQuestion>>((ref) {
  return ref.watch(expertsRepositoryProvider).getMyQuestions();
});

final liveRoomsProvider = FutureProvider<List<LiveRoom>>((ref) {
  return ref.watch(expertsRepositoryProvider).getLiveRooms();
});

final liveRoomProvider = FutureProvider.family<LiveRoom?, String>((ref, id) {
  return ref.watch(expertsRepositoryProvider).getLiveRoom(id);
});
