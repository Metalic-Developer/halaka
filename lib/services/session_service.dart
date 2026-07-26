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
    final isar = await IsarService.isar;
    final session = Session()
      // id سيتولد تلقائيًا (autoIncrement)
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

    await isar.writeTxn(() async {
      await isar.sessions.put(session);
    });
    return session;
  }

  Future<void> addSessionPart({
    required int sessionLocalId,     // int
    required String type,
    required int suraStart,
    required int ayaStart,
    required int suraEnd,
    required int ayaEnd,
    bool isExtra = false,
    String? evaluation,
    String? notes,
  }) async {
    final db = QuranDatabaseService();
    final pages = await db.calculatePages(suraStart, ayaStart, suraEnd, ayaEnd);
    final isar = await IsarService.isar;
    final part = SessionPart()
      ..sessionLocalId = sessionLocalId
      ..supabaseId = _uuid.v4()
      ..type = type
      ..suraStart = suraStart
      ..ayaStart = ayaStart
      ..suraEnd = suraEnd
      ..ayaEnd = ayaEnd
      ..pagesCount = pages
      ..isExtra = isExtra
      ..evaluation = evaluation
      ..notes = notes
      ..isSynced = false;

    await isar.writeTxn(() async {
      await isar.sessionParts.put(part);
    });
  }

  Future<void> calculateAndUpdateSessionPoints(int sessionLocalId) async { // int
    final isar = await IsarService.isar;
    final session = await isar.sessions.get(sessionLocalId);
    if (session == null) return;

    final parts = await isar.sessionParts
        .where()
        .sessionLocalIdEqualTo(sessionLocalId)
        .findAll();

    final profile = await isar.studentProfiles
        .where()
        .userSupabaseIdEqualTo(session.studentSupabaseId)
        .findFirst();
    if (profile == null) throw DatabaseException('ملف الطالب غير موجود');

    double total = 0.0;
    if (session.earlyAttendance) total += 2;
    if (session.onTimeDeparture) total += 2;
    if (session.earlyRecitation) total += 2;

    double newBasePages = 0, newExtraPages = 0;
    double reviewBasePages = 0, reviewExtraPages = 0;

    for (var part in parts) {
      if (part.type == 'new') {
        if (part.isExtra) {
          newExtraPages += part.pagesCount;
        } else {
          newBasePages += part.pagesCount;
        }
      } else if (part.type == 'review') {
        if (part.isExtra) {
          reviewExtraPages += part.pagesCount;
        } else {
          reviewBasePages += part.pagesCount;
        }
      }
    }

    final newTarget = profile.newPagesTarget.toDouble();
    if (newTarget > 0) {
      total += (newBasePages / newTarget) * 4;
      total += (newExtraPages / newTarget) * 6;
    }

    if (session.cumulativeDone) {
      final reviewTarget = profile.reviewPagesTarget.toDouble();
      if (reviewTarget > 0) {
        total += (reviewBasePages / reviewTarget) * 6;
        total += (reviewExtraPages / reviewTarget) * 8;
      }
    }

    await isar.writeTxn(() async {
      session.totalPoints = total;
      await isar.sessions.put(session);
    });
  }

  Future<List<Session>> getUnsyncedSessions() async {
    final isar = await IsarService.isar;
    return isar.sessions.where().isSyncedEqualTo(false).findAll();
  }
}