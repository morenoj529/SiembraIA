import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'providers.dart';

// ── Firebase auth state stream ───────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.read(authServiceProvider).authStateChanges,
);

// ── Current app user profile ─────────────────────────────────────────────────

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>(
  (ref) => CurrentUserNotifier(ref),
);

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  CurrentUserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref _ref;

  void _init() {
    _ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
      next.when(
        data: (user) async {
          if (user == null) {
            state = const AsyncValue.data(null);
          } else {
            try {
              final profile =
                  await _ref.read(authServiceProvider).getProfile(user.uid);
              state = AsyncValue.data(profile);
            } catch (e, st) {
              state = AsyncValue.error(e, st);
            }
          }
        },
        loading: () => state = const AsyncValue.loading(),
        error: (e, st) => state = AsyncValue.error(e, st),
      );
    }, fireImmediately: true);
  }

  Future<void> refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final profile =
          await _ref.read(authServiceProvider).getProfile(user.uid);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(UserModel user) async {
    await _ref.read(authServiceProvider).updateProfile(user);
    state = AsyncValue.data(user);
  }
}
