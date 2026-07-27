import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/session.dart';
import '../models/session_part.dart';
import '../models/student_profile.dart';
import '../core/exceptions.dart';
import '../core/constants.dart';
import 'isar_service.dart';
import 'quran_database_service.dart';
import '../models/session_submission.dart';

class SessionService {
  final _uuid = const Uuid();

  Future<Session> submitFullSession(SessionSubmission submission) async {
    final isar = await IsarService.isar;
    final db = QuranDatabaseService();

    // 1. التثبت من وجود جلسة سابقة بنفس اليوم
    final existing = await isar.collection<Session>()
        .filter()
        .studentSupabaseIdEqualTo(submission.studentSupabaseId)
        .sessionDateEqualTo(submission.sessionDate)
        .findFirst();
    if (existing != null) {
      throw DatabaseException('توجد جلسة سابقة لنفس الطالب في هذا اليوم');
    }

    // 2. التثبت من البروفايل
    final profile = await isar.collection<StudentProfile>()
        .filter()
        .userSupabaseIdEqualTo(submission.studentSupabaseId)
        .findFirst();
    if (profile == null) throw DatabaseException('ملف الطالب غير موجود');

    // 3. حساب المطلوبات والتراكمي قبل دخول الـ Write Transaction
    final requiredCumulative = await _calculateRequiredCumulative(
      submission.studentSupabaseId, submission.sessionDate,
    );

    // 4. تجهيز صفحات الأجزاء من SQLite مسبقاً (لعدم قفل Isar Transaction)
    double newBasePages = 0, newExtraPages = 0;
    double cumulativeBasePages = 0, cumulativeExtraPages = 0;
    double reviewBasePages = 0, reviewExtraPages = 0;

    final List<Map<String, dynamic>> preparedParts = [];

    for (var partData in submission.parts) {
      final pages = await db.calculatePages(
        partData.suraStart, partData.ayaStart,
        partData.suraEnd, partData.ayaEnd,
      );

      preparedParts.add({
        'data': partData,
        'pages': pages,
      });

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
        case SessionType.unknown:
          break;
      }
    }

    // 5. حساب النقاط كاملة مسبقاً
    double total = AppConstants.baseAttendancePoints;
    if (submission.earlyAttendance) total += AppConstants.earlyAttendanceBonus;
    if (submission.onTimeDeparture) total += AppConstants.onTimeDepartureBonus;
    if (submission.earlyRecitation) total += AppConstants.earlyRecitationBonus;

    final newTarget = profile.newPagesTarget.toDouble();
    double newAchieved = newBasePages;
    if (newTarget > 0) {
      double completionRatio = (newAchieved / newTarget).clamp(0.0, 1.0);
      total += completionRatio * AppConstants.completionNewPoints;
      double extraNew = (newAchieved + newExtraPages) - newTarget;
      if (extraNew > 0) {
        total += (AppConstants.extraNewPointsPer5 / 5.0) * extraNew;
      }
    }

    final reviewTarget = profile.reviewPagesTarget.toDouble();
    double totalCumulative = cumulativeBasePages + cumulativeExtraPages;
    double totalReview = reviewBasePages + reviewExtraPages;
    double combinedAchieved = totalCumulative + totalReview;
    double combinedRequired = requiredCumulative + reviewTarget;

    if (combinedRequired > 0) {
      double combinedRatio = (combinedAchieved / combinedRequired).clamp(0.0, 1.0);
      total += combinedRatio * AppConstants.completionCumulativeReviewPoints;
    }
    
    // بونص الزيادة للمراجعة والتراكمي
    double reviewExtraOnly = totalReview - reviewTarget;
    if (reviewExtraOnly > 0) {
      total += (AppConstants.extraReviewPointsPer50 / 50.0) * reviewExtraOnly;
    }

    // 6. الحفظ داخل Transaction واحدة سريعة جداً
    late Session finalSession;

    await isar.writeTxn(() async {
      finalSession = Session()
        ..supabaseId = _uuid.v4()
        ..studentSupabaseId = submission.studentSupabaseId
        ..groupSupabaseId = submission.groupSupabaseId
        ..teacherSupabaseId = submission.teacherSupabaseId
        ..sessionDate = submission.sessionDate
        ..earlyAttendance = submission.earlyAttendance
        ..onTimeDeparture = submission.onTimeDeparture
        ..earlyRecitation = submission.earlyRecitation
        ..cumulativeDone = submission.cumulativeDone
        ..totalPoints = total
        ..isSynced = false
        ..createdAt = DateTime.now();

      final sessionId = await isar.collection<Session>().put(finalSession);

      for (var item in preparedParts) {
        final partData = item['data'] as SessionPartSubmission; // أو النوع المستعمل لديك
        final pages = item['pages'] as double;

        final part = SessionPart()
          ..sessionLocalId = sessionId
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

        await isar.collection<SessionPart>().put(part);
      }
    });

    return finalSession;
  }

  Future<double> _calculateRequiredCumulative(String studentSupabaseId, DateTime beforeDate) async {
    final isar = await IsarService.isar;
    final dateOnly = DateTime(beforeDate.year, beforeDate.month, beforeDate.day);

    final lastSessions = await isar.collection<Session>()
        .filter()
        .studentSupabaseIdEqualTo(studentSupabaseId)
        .sessionDateLessThan(dateOnly)
        .sortBySessionDateDesc()
        .limit(2)
        .findAll();

    if (lastSessions.isEmpty) return 0.0;

    final sessionIds = lastSessions.map((s) => s.id).toList();
    final parts = await isar.collection<SessionPart>()
        .filter()
        .anyOf(sessionIds, (q, int id) => q.sessionLocalIdEqualTo(id))
        .typeEqualTo(SessionType.memorization)
        .findAll();

    return parts.fold<double>(0, (sum, p) => sum + p.pagesCount);
  }

  Future<List<Session>> getUnsyncedSessions() async {
    final isar = await IsarService.isar;
    return isar.collection<Session>()
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  Future<String> getSuggestedCumulative(String studentSupabaseId) async {
    final isar = await IsarService.isar;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastSessions = await isar.collection<Session>()
        .filter()
        .studentSupabaseIdEqualTo(studentSupabaseId)
        .sessionDateLessThan(today)
        .sortBySessionDateDesc()
        .limit(2)
        .findAll();

    if (lastSessions.isEmpty) return 'لا يوجد بيانات لجلسات سابقة';

    final sessionIds = lastSessions.map((s) => s.id).toList();
    final newParts = await isar.collection<SessionPart>()
        .filter()
        .anyOf(sessionIds, (q, int id) => q.sessionLocalIdEqualTo(id))
        .typeEqualTo(SessionType.memorization)
        .findAll();

    if (newParts.isEmpty) return 'لم يأخذ حفظاً جديداً في الجلستين السابقتين';

    final db = QuranDatabaseService();
    final surahs = await db.getSurahs();
    Map<int, String> surahNames = {};
    for (var s in surahs) {
      surahNames[s['sora'] as int] = s['sora_name_ar'] as String;
    }

    // تحديد البداية والنهاية الدقيقة
    var firstPart = newParts.first;
    var lastPart = newParts.last;

    final nameStart = surahNames[firstPart.suraStart] ?? 'سورة ${firstPart.suraStart}';
    final nameEnd = surahNames[lastPart.suraEnd] ?? 'سورة ${lastPart.suraEnd}';
    
    return 'من $nameStart آية ${firstPart.ayaStart} إلى $nameEnd آية ${lastPart.ayaEnd}';
  }
}