import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../models/student_profile.dart';
import '../models/user.dart';
import '../services/isar_service.dart';
import '../services/session_service.dart';
import '../services/supabase_config.dart';

final sessionServiceProvider = Provider<SessionService>((ref) => SessionService());
final teacherProvider = Provider<TeacherController>((ref) => TeacherController(ref));

// حساب نسبة الحضور الأسبوعية بناءً على الأيام المنقضية
final studentAttendanceProvider = FutureProvider.family<double, ({String studentId, DateTime weekStart})>((ref, params) async {
  final isar = await IsarService.isar;
  final end = params.weekStart.add(const Duration(days: 6));
  final sessionsCount = await isar.sessions.filter()
      .studentSupabaseIdEqualTo(params.studentId)
      .and()
      .sessionDateBetween(params.weekStart, end)
      .count();
      
  int elapsedDays = DateTime.now().difference(params.weekStart).inDays + 1;
  if (elapsedDays > 5) elapsedDays = 5;
  if (elapsedDays <= 0) return 100.0;
  
  double attendance = (sessionsCount / elapsedDays) * 100.0;
  return attendance > 100.0 ? 100.0 : attendance;
});

class TeacherController {
  final Ref _ref;
  TeacherController(this._ref);

  SessionService get _sessionService => _ref.read(sessionServiceProvider);

  Future<List<User>> getGroupStudents(String groupSupabaseId) async {
    final isar = await IsarService.isar;
    return isar.users.filter()
        .roleEqualTo('student')
        .and()
        .groupSupabaseIdEqualTo(groupSupabaseId)
        .findAll();
  }

  Future<List<Session>> getStudentWeeklySessions(String studentSupabaseId, DateTime weekStart) async {
    final isar = await IsarService.isar;
    final end = weekStart.add(const Duration(days: 5));
    return isar.sessions.filter()
        .studentSupabaseIdEqualTo(studentSupabaseId)
        .and()
        .sessionDateBetween(weekStart, end)
        .findAll();
  }

  Future<Session> submitFullSession({
    required String studentSupabaseId,
    required String groupSupabaseId,
    required String teacherSupabaseId,
    required DateTime sessionDate,
    required List<Map<String, dynamic>> partsData,
    bool earlyAttendance = false,
    bool onTimeDeparture = false,
    bool earlyRecitation = false,
    bool cumulativeDone = false,
  }) {
    return _sessionService.submitFullSession(
      studentSupabaseId: studentSupabaseId,
      groupSupabaseId: groupSupabaseId,
      teacherSupabaseId: teacherSupabaseId,
      sessionDate: sessionDate,
      partsData: partsData,
      earlyAttendance: earlyAttendance,
      onTimeDeparture: onTimeDeparture,
      earlyRecitation: earlyRecitation,
      cumulativeDone: cumulativeDone,
    );
  }

  Future<StudentProfile?> getStudentProfile(String userSupabaseId) async {
    final isar = await IsarService.isar;
    final result = await isar.studentProfiles.filter().userSupabaseIdEqualTo(userSupabaseId).findAll();
    return result.isNotEmpty ? result.first : null;
  }

  // ✅ خوارزمية جلب التراكمي المقترح (تستدعي الخدمة أوفلاين)
  Future<String> getCumulativeSuggestion(String studentSupabaseId) async {
    return await _sessionService.getSuggestedCumulative(studentSupabaseId);
  }

  // ✅ دالة جديدة: تحديث ورد الطالب محلياً ومزامنته سحابياً
  Future<void> updateStudentTargets(String userSupabaseId, int newTarget, int reviewTarget) async {
    final isar = await IsarService.isar;
    await isar.writeTxn(() async {
      final profile = await isar.studentProfiles.filter().userSupabaseIdEqualTo(userSupabaseId).findFirst();
      if (profile != null) {
        profile.newPagesTarget = newTarget;
        profile.reviewPagesTarget = reviewTarget;
        profile.updatedAt = DateTime.now();
        await isar.studentProfiles.put(profile);
      } else {
        final newProfile = StudentProfile()
          ..userSupabaseId = userSupabaseId
          ..newPagesTarget = newTarget
          ..reviewPagesTarget = reviewTarget
          ..updatedAt = DateTime.now();
        await isar.studentProfiles.put(newProfile);
      }
    });

    try {
      await SupabaseConfig.client.from('student_profiles').upsert({
        'user_id': userSupabaseId,
        'new_pages_target': newTarget,
        'review_pages_target': reviewTarget,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}