import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';

/// Represents the current auth user. Swap with Firebase User when integrating.
class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
}

/// Auth service interface. Implement with Firebase Auth (Google, Apple, Facebook, email).
abstract class AuthService {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser?> signInWithApple();
  Future<AuthUser?> signInWithFacebook();
  Future<AuthUser?> signInWithEmail({required String email, required String password});
  Future<AuthUser?> createUserWithEmail({required String email, required String password});
  Future<void> signOut();
}

/// Mock implementation for Phase 2. Replace with Firebase Auth implementation.
class MockAuthService implements AuthService {
  MockAuthService() {
    _controller.add(_user);
  }

  AuthUser? _user;
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  AuthUser? get currentUser => _user;

  void _emit() => _controller.add(_user);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    AppLogger.info('Mock: signInWithGoogle');
    _user = AuthUser(uid: 'mock-google-1', email: 'user@gmail.com', displayName: 'Demo User');
    _emit();
    return _user;
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    AppLogger.info('Mock: signInWithApple');
    _user = AuthUser(uid: 'mock-apple-1', email: 'user@icloud.com', displayName: 'Demo User');
    _emit();
    return _user;
  }

  @override
  Future<AuthUser?> signInWithFacebook() async {
    AppLogger.info('Mock: signInWithFacebook');
    _user = AuthUser(uid: 'mock-fb-1', email: 'user@facebook.com', displayName: 'Demo User');
    _emit();
    return _user;
  }

  @override
  Future<AuthUser?> signInWithEmail({required String email, required String password}) async {
    AppLogger.info('Mock: signInWithEmail');
    _user = AuthUser(uid: 'mock-email-1', email: email, displayName: email.split('@').first);
    _emit();
    return _user;
  }

  @override
  Future<AuthUser?> createUserWithEmail({required String email, required String password}) async {
    AppLogger.info('Mock: createUserWithEmail');
    _user = AuthUser(uid: 'mock-email-1', email: email, displayName: email.split('@').first);
    _emit();
    return _user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _emit();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => MockAuthService());

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).value;
});
