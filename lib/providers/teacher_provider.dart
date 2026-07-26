import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../models/student_profile.dart';
import '../models/user.dart';
import '../services/isar_service.dart';
import '../services/session_service.dart';

final sessionServiceProvider = Provider<SessionService>((ref) => SessionService());
final teacherProvider = Provider<TeacherController>((ref) => TeacherController(ref));

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
}