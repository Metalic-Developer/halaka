import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/session.dart';
import '../models/session_part.dart';
import '../models/student_profile.dart';
import '../core/exceptions.dart';
import 'isar_service.dart';
import 'quran_database_service.dart';

class SessionService {
  final _uuid = const Uuid();

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
  }) async {
    final isar = await IsarService.isar;
    final db = QuranDatabaseService();
    Session? session;

    await isar.writeTxn(() async {
      session = Session()
        ..supabaseId = _uuid.v4()
        ..studentSupabaseId = studentSupabaseId
        ..groupSupabaseId = groupSupabaseId
        ..teacherSupabaseId = teacherSupabaseId
        ..sessionDate = sessionDate
        ..earlyAttendance = earlyAttendance
        ..onTimeDeparture = onTimeDeparture
        ..earlyRecitation = earlyRecitation
        ..cumulativeDone = cumulativeDone
        ..totalPoints = 0.0
        ..isSynced = false
        ..createdAt = DateTime.now();
      await isar.sessions.put(session!);

      double newBasePages = 0, newExtraPages = 0;
      double reviewBasePages = 0, reviewExtraPages = 0;

      for (var data in partsData) {
        final pages = await db.calculatePages(
          data['suraStart'], data['ayaStart'],
          data['suraEnd'], data['ayaEnd'],
        );

        final part = SessionPart()
          ..sessionLocalId = session!.id
          ..supabaseId = _uuid.v4()
          ..type = data['type']
          ..suraStart = data['suraStart']
          ..ayaStart = data['ayaStart']
          ..suraEnd = data['suraEnd']
          ..ayaEnd = data['ayaEnd']
          ..pagesCount = pages
          ..isExtra = data['isExtra'] ?? false
          ..evaluation = data['evaluation']
          ..notes = data['notes']
          ..isSynced = false;

        await isar.sessionParts.put(part);

        if (data['type'] == 'new' || data['type'] == 'extra_new') {
          if (data['isExtra']) {
            newExtraPages += pages;
          } else {
            newBasePages += pages;
          }
        } else {
          if (data['isExtra']) {
            reviewExtraPages += pages;
          } else {
            reviewBasePages += pages;
          }
        }
      }

      final profile = await isar.studentProfiles
          .where()
          .userSupabaseIdEqualTo(studentSupabaseId)
          .findFirst();
      if (profile == null) throw DatabaseException('ملف الطالب غير موجود');

      double total = 0.0;
      if (earlyAttendance) total += 2;
      if (onTimeDeparture) total += 2;
      if (earlyRecitation) total += 2;

      final newTarget = profile.newPagesTarget.toDouble();
      if (newTarget > 0) {
        total += (newBasePages / newTarget) * 4;
        total += (newExtraPages / newTarget) * 6;
      }

      if (cumulativeDone) {
        final reviewTarget = profile.reviewPagesTarget.toDouble();
        if (reviewTarget > 0) {
          total += (reviewBasePages / reviewTarget) * 6;
          total += (reviewExtraPages / reviewTarget) * 8;
        }
      }

      session!.totalPoints = total;
      await isar.sessions.put(session!);
    });

    return session!;
  }

  Future<List<Session>> getUnsyncedSessions() async {
    final isar = await IsarService.isar;
    return isar.sessions.where().isSyncedEqualTo(false).findAll();
  }
}