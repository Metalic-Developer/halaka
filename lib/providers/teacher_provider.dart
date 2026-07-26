import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/session.dart';
import '../models/session_part.dart';
import '../models/student_profile.dart';
import '../models/user.dart';
import '../services/isar_service.dart';
import '../services/session_service.dart';
import '../core/exceptions.dart';

final sessionServiceProvider = Provider<SessionService>((ref) => SessionService());

final teacherProvider = Provider<TeacherController>((ref) => TeacherController(ref));

class TeacherController {
  final Ref _ref;
  TeacherController(this._ref);

  SessionService get _sessionService => _ref.read(sessionServiceProvider);

  // جلب طلاب المجموعة الحالية (من Isar)
  Future<List<User>> getGroupStudents(String groupSupabaseId) async {
    final isar = await IsarService.isar;
    return isar.users
        .where()
        .roleEqualTo('student')
        .and()
        .groupSupabaseIdEqualTo(groupSupabaseId)
        .findAll();
  }

  // الحصول على جلسات الأسبوع لطالب
  Future<List<Session>> getStudentWeeklySessions(String studentSupabaseId, DateTime weekStart) async {
    final isar = await IsarService.isar;
    final end = weekStart.add(const Duration(days: 5));
    return isar.sessions
        .where()
        .studentSupabaseIdEqualTo(studentSupabaseId)
        .and()
        .sessionDateBetween(weekStart, end)
        .findAll();
  }

  // إنشاء جلسة جديدة (محلي)
  Future<Session> createSession({
    required String studentSupabaseId,
    required String groupSupabaseId,
    required String teacherSupabaseId,
    required DateTime sessionDate,
    bool earlyAttendance = false,
    bool onTimeDeparture = false,
    bool earlyRecitation = false,
    bool cumulativeDone = false,
  }) async {
    return await _sessionService.createSession(
      studentSupabaseId: studentSupabaseId,
      groupSupabaseId: groupSupabaseId,
      teacherSupabaseId: teacherSupabaseId,
      sessionDate: sessionDate,
      earlyAttendance: earlyAttendance,
      onTimeDeparture: onTimeDeparture,
      earlyRecitation: earlyRecitation,
      cumulativeDone: cumulativeDone,
    );
  }

  // إضافة جزء تسميع
  Future<void> addSessionPart({
    required int sessionLocalId,
    required String type,
    required int suraStart,
    required int ayaStart,
    required int suraEnd,
    required int ayaEnd,
    bool isExtra = false,
    String? evaluation,
    String? notes,
  }) async {
    await _sessionService.addSessionPart(
      sessionLocalId: sessionLocalId,
      type: type,
      suraStart: suraStart,
      ayaStart: ayaStart,
      suraEnd: suraEnd,
      ayaEnd: ayaEnd,
      isExtra: isExtra,
      evaluation: evaluation,
      notes: notes,
    );
  }

  // حساب النقاط بعد إضافة الأجزاء
  Future<void> calculateSessionPoints(int sessionLocalId) async {
    await _sessionService.calculateAndUpdateSessionPoints(sessionLocalId);
  }

  // الحصول على ورد الطالب
  Future<StudentProfile?> getStudentProfile(String userSupabaseId) async {
    final isar = await IsarService.isar;
    return isar.studentProfiles.where().userSupabaseIdEqualTo(userSupabaseId).findFirst();
  }
}