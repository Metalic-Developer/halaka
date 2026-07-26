import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../models/session.dart';
import '../models/student_profile.dart';
import '../services/isar_service.dart';

final studentProvider = Provider<StudentController>((ref) => StudentController(ref));

class StudentController {
  final Ref _ref;
  StudentController(this._ref);

  Future<StudentProfile?> getMyProfile(String userSupabaseId) async {
    final isar = await IsarService.isar;
    final result = await isar.studentProfiles.filter().userSupabaseIdEqualTo(userSupabaseId).findAll();
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard(String groupSupabaseId, DateTime weekStart) async {
    final isar = await IsarService.isar;
    final end = weekStart.add(const Duration(days: 5));

    final students = await isar.users.filter()
        .roleEqualTo('student')
        .and()
        .groupSupabaseIdEqualTo(groupSupabaseId)
        .findAll();

    if (students.isEmpty) return [];

    final allSessions = await isar.sessions.filter()
        .groupSupabaseIdEqualTo(groupSupabaseId)
        .and()
        .sessionDateBetween(weekStart, end)
        .findAll();

    final sessionsByStudent = groupBy(allSessions, (Session s) => s.studentSupabaseId);

    final leaderboard = students.map((student) {
      final studentSessions = sessionsByStudent[student.supabaseId] ?? [];
      final totalPoints = studentSessions.fold<double>(0.0, (sum, s) => sum + s.totalPoints);
      return {
        'name': student.fullName,
        'points': totalPoints,
      };
    }).toList();

    leaderboard.sort((a, b) => (b['points'] as double).compareTo(a['points'] as double));
    return leaderboard;
  }
}