import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/isar_service.dart';
import '../core/exceptions.dart';
import '../models/user.dart'; // استيراد النموذج المحلي

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.onAuthStateChange.map((state) => state.session?.user);
});

// ✅ المزود الجديد: يجلب بيانات المستخدم الكاملة من Isar
final currentUserProvider = FutureProvider<User?>((ref) async {
  final supabaseUser = ref.watch(authStateProvider).value;
  if (supabaseUser == null) return null;
  final isar = await IsarService.isar;
  return isar.users.filter().supabaseIdEqualTo(supabaseUser.id).findFirst();
});

final authProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  AuthService get _authService => _ref.read(authServiceProvider);

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
    // يمكن هنا تنزيل بيانات المستخدم إلى Isar بعد الدخول
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Session? get currentSession => _authService.currentSession;
}