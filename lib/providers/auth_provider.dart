import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/isar_service.dart';
import '../core/exceptions.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.onAuthStateChange.map((state) => state.session?.user);
});

// مزود حالة المصادقة مع بعض الدوال
final authProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  AuthService get _authService => _ref.read(authServiceProvider);

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
    // بعد تسجيل الدخول، اسحب بيانات المستخدم من Supabase إلى Isar
    // هذا يعتمد على أن syncService سيقوم بذلك أو يمكننا استدعاؤه
  }

  Future<void> signOut() async {
    await _authService.signOut();
    // مسح Isar اختياري
  }

  Session? get currentSession => _authService.currentSession;
}