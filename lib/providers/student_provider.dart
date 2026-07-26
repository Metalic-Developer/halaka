import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../models/user.dart';
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

  Future<List<Session>> getWeeklySessions(String studentSupabaseId, DateTime weekStart) async {
    final isar = await IsarService.isar;
    final end = weekStart.add(const Duration(days: 5));
    return isar.sessions.filter()
        .studentSupabaseIdEqualTo(studentSupabaseId)
        .and()
        .sessionDateBetween(weekStart, end)
        .findAll();
  }

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard(String groupSupabaseId, DateTime weekStart) async {
    final isar = await IsarService.isar;
    final students = await isar.users.filter()
        .roleEqualTo('student')
        .and()
        .groupSupabaseIdEqualTo(groupSupabaseId)
        .findAll();

    final end = weekStart.add(const Duration(days: 5));
    final leaderboard = <Map<String, dynamic>>[];
    for (var student in students) {
      double total = 0;
      final sessions = await isar.sessions.filter()
          .studentSupabaseIdEqualTo(student.supabaseId)
          .and()
          .sessionDateBetween(weekStart, end)
          .findAll();
      for (var s in sessions) {
        total += s.totalPoints;
      }
      leaderboard.add({
        'name': student.fullName,
        'points': total,
      });
    }
    leaderboard.sort((a, b) => (b['points'] as double).compareTo(a['points']));
    return leaderboard;
  }
}