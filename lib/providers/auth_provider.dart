import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Session, AuthState;
import '../services/auth_service.dart';
import '../services/isar_service.dart';
import '../models/local_user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthState?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.onAuthStateChange;
});

final currentUserProvider = FutureProvider<LocalUser?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState?.session?.user == null) return null;

  final supabaseUser = authState!.session!.user;
  final isar = await IsarService.isar;
  return isar.collection<LocalUser>().filter().supabaseIdEqualTo(supabaseUser.id).findFirst();
});

final authProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  AuthService get _authService => _ref.read(authServiceProvider);

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
  }

  Future<void> signOut() async => _authService.signOut();

  Session? get currentSession => _authService.currentSession;
}