import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/session.dart';
import '../models/session_part.dart';
import '../models/student_profile.dart';
import '../core/exceptions.dart';
import 'isar_service.dart';
import 'quran_database_service.dart';
import 'session_submission.dart';

class SessionService {
  final _uuid = const Uuid();

  Future<Session> submitFullSession(SessionSubmission submission) async {
    final isar = await IsarService.isar;
    final db = QuranDatabaseService();

    // ✅ منع التكرار
    final existing = await isar.sessions.filter()
        .studentSupabaseIdEqualTo(submission.studentSupabaseId)
        .and()
        .sessionDateEqualTo(submission.sessionDate)
        .findFirst();
    if (existing != null) {
      throw DatabaseException('توجد جلسة سابقة لنفس الطالب في هذا اليوم');
    }

    final profile = await isar.studentProfiles
        .where()
        .userSupabaseIdEqualTo(submission.studentSupabaseId)
        .findFirst();
    if (profile == null) throw DatabaseException('ملف الطالب غير موجود');

    // ✅ حساب التراكمي المطلوب من آخر جلستين
    final requiredCumulative = await _calculateRequiredCumulative(
      submission.studentSupabaseId, submission.sessionDate);

    Session? session;

    await isar.writeTxn(() async {
      session = Session()
        ..supabaseId = _uuid.v4()
        ..studentSupabaseId = submission.studentSupabaseId
        ..groupSupabaseId = submission.groupSupabaseId
        ..teacherSupabaseId = submission.teacherSupabaseId
        ..sessionDate = submission.sessionDate
        ..earlyAttendance = submission.earlyAttendance
        ..onTimeDeparture = submission.onTimeDeparture
        ..earlyRecitation = submission.earlyRecitation
        ..cumulativeDone = submission.cumulativeDone
        ..totalPoints = 0.0
        ..isSynced = false
        ..createdAt = DateTime.now();
      await isar.sessions.put(session!);

      double newBasePages = 0, newExtraPages = 0;
      double cumulativeBasePages = 0, cumulativeExtraPages = 0;
      double reviewBasePages = 0, reviewExtraPages = 0;

      for (var partData in submission.parts) {
        final pages = await db.calculatePages(
          partData.suraStart, partData.ayaStart,
          partData.suraEnd, partData.ayaEnd,
        );

        final part = SessionPart()
          ..sessionLocalId = session!.id
          ..supabaseId = _uuid.v4()
          ..type = partData.type
          ..suraStart = partData.suraStart
          ..ayaStart = partData.ayaStart
          ..suraEnd = partData.suraEnd
          ..ayaEnd = partData.ayaEnd
          ..pagesCount = pages
          ..isExtra = partData.isExtra
          ..evaluation = partData.evaluation
          ..notes = partData.notes
          ..isSynced = false;

        await isar.sessionParts.put(part);

        // تجميع الصفحات
        switch (partData.type) {
          case SessionType.memorization:
            if (partData.isExtra) {
              newExtraPages += pages;
            } else {
              newBasePages += pages;
            }
            break;
          case SessionType.cumulative:
            if (partData.isExtra) {
              cumulativeExtraPages += pages;
            } else {
              cumulativeBasePages += pages;
            }
            break;
          case SessionType.review:
            if (partData.isExtra) {
              reviewExtraPages += pages;
            } else {
              reviewBasePages += pages;
            }
            break;
        }
      }

      // ✅ حساب النقاط مطابقة للـ Blueprint
      double total = 2.0; // نقاط الحضور الأساسية
      if (submission.earlyAttendance) total += 2;
      if (submission.onTimeDeparture) total += 2;
      if (submission.earlyRecitation) total += 2;

      // الحفظ الجديد
      final newTarget = profile.newPagesTarget.toDouble();
      final newAchieved = newBasePages;
      if (newTarget > 0 && newAchieved >= newTarget) {
        total += 4;
        final extraNew = (newAchieved + newExtraPages) - newTarget;
        if (extraNew > 0) total += (6.0 / 5.0) * extraNew;
      }

      // التراكمي + المراجعة (معًا)
      final reviewTarget = profile.reviewPagesTarget.toDouble();
      final totalCumulative = cumulativeBasePages + cumulativeExtraPages;
      final totalReview = reviewBasePages + reviewExtraPages;
      final combinedAchieved = totalCumulative + totalReview;
      final combinedRequired = requiredCumulative + reviewTarget;

      if (combinedRequired > 0 && combinedAchieved >= combinedRequired) {
        total += 6;
        // الإضافي في المراجعة فقط
        final reviewExtraOnly = totalReview - reviewTarget;
        if (reviewExtraOnly > 0) total += (8.0 / 50.0) * reviewExtraOnly;
      }

      session!.totalPoints = total;
      await isar.sessions.put(session!);
    });

    return session!;
  }

  /// يحسب مجموع صفحات الحفظ الجديد (memorization + extra) من آخر جلستين فعليتين للطالب
  Future<double> _calculateRequiredCumulative(String studentSupabaseId, DateTime beforeDate) async {
    final isar = await IsarService.isar;
    final today = DateTime(beforeDate.year, beforeDate.month, beforeDate.day);

    final lastSessions = await isar.sessions.filter()
        .studentSupabaseIdEqualTo(studentSupabaseId)
        .and()
        .sessionDateLessThan(today)
        .sortBySessionDateDesc()
        .limit(2)
        .findAll();

    if (lastSessions.isEmpty) return 0.0;

    final sessionIds = lastSessions.map((s) => s.id).toList();
    final parts = await isar.sessionParts.filter()
        .anyOf(sessionIds, (q, int id) => q.sessionLocalIdEqualTo(id))
        .and()
        .typeEqualTo(SessionType.memorization)   // أي نوع memorization (أساسي أو إضافي)
        .findAll();

    return parts.fold<double>(0, (sum, p) => sum + p.pagesCount);
  }

  // باقي الدوال كما هي (getUnsyncedSessions, getSuggestedCumulative...)
  Future<List<Session>> getUnsyncedSessions() async {
    final isar = await IsarService.isar;
    return isar.sessions.where().isSyncedEqualTo(false).findAll();
  }

  Future<String> getSuggestedCumulative(String studentSupabaseId) async {
    // يمكن تركها كما هي أو تحسينها
    return '';
  }
}