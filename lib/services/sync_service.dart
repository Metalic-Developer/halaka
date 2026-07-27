import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';
import '../core/exceptions.dart';
import '../models/session.dart';
import '../models/session_part.dart';
import '../models/mosque.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../models/student_profile.dart';
import 'isar_service.dart';
import 'session_service.dart';
import 'connectivity_service.dart';

class SyncService {
  final SupabaseClient _client = SupabaseConfig.client;
  final SessionService _sessionService = SessionService();
  final ConnectivityService _connectivityService;

  SyncService(this._connectivityService) {
    _connectivityService.onConnectivityChanged.listen((hasConnection) {
      if (hasConnection) syncPendingSessions();
    });
  }

  Future<void> pullAllData() async {
    try {
      final isar = await IsarService.isar;

      // منع المسح إذا كانت هناك جلسات غير مرفوعة
      final unsynced = await _sessionService.getUnsyncedSessions();
      if (unsynced.isNotEmpty) {
        throw SyncException('توجد جلسات غير مزامنة. ارفعها للإنترنت أولاً قبل السحب.');
      }

      final userRows = await _client.from('users').select();
      final users = (userRows as List).map((r) => User()
        ..supabaseId = r['id'] as String
        ..email = r['email'] ?? ''
        ..fullName = r['full_name'] ?? ''
        ..role = r['role'] ?? ''
        ..groupSupabaseId = r['group_id'] as String?
        ..mosqueSupabaseId = r['mosque_id'] as String?
        ..createdAt = DateTime.tryParse(r['created_at'] ?? '')
      ).toList();

      final mosqueRows = await _client.from('mosques').select();
      final mosques = (mosqueRows as List).map((r) => Mosque()
        ..supabaseId = r['id'] as String
        ..name = r['name'] ?? ''
        ..createdAt = DateTime.tryParse(r['created_at'] ?? '')
      ).toList();

      final groupRows = await _client.from('groups').select();
      final groups = (groupRows as List).map((r) => Group()
        ..supabaseId = r['id'] as String
        ..mosqueSupabaseId = r['mosque_id'] as String
        ..name = r['name'] ?? ''
        ..createdAt = DateTime.tryParse(r['created_at'] ?? '')
      ).toList();

      final profiles = await _client.from('student_profiles').select();
      final studentProfiles = (profiles as List).map((r) => StudentProfile()
        ..userSupabaseId = r['user_id'] as String
        ..newPagesTarget = r['new_pages_target'] as int
        ..reviewPagesTarget = r['review_pages_target'] as int
        ..guardianSupabaseId = r['guardian_id'] as String?   // ✅ إضافة
        ..updatedAt = DateTime.tryParse(r['updated_at'] ?? '')
      ).toList();

      final sessionRows = await _client.from('sessions').select();
      final remoteSessions = (sessionRows as List).map((r) => Session()
        ..supabaseId = r['id']
        ..studentSupabaseId = r['student_id']
        ..groupSupabaseId = r['group_id']
        ..teacherSupabaseId = r['teacher_id']
        ..sessionDate = DateTime.parse(r['session_date'])
        ..earlyAttendance = r['early_attendance'] ?? false
        ..onTimeDeparture = r['on_time_departure'] ?? false
        ..earlyRecitation = r['early_recitation'] ?? false
        ..cumulativeDone = r['cumulative_done'] ?? false
        ..totalPoints = (r['total_points'] as num).toDouble()
        ..isSynced = true
        ..createdAt = DateTime.tryParse(r['created_at'] ?? '')
      ).toList();

      final partRows = await _client.from('session_parts').select();

      await isar.writeTxn(() async {
        // استخدام putAll مع clear لأنها عملية استبدال كاملة
        await isar.users.clear();
        await isar.users.putAll(users);
        await isar.mosques.clear();
        await isar.mosques.putAll(mosques);
        await isar.groups.clear();
        await isar.groups.putAll(groups);
        await isar.studentProfiles.clear();
        await isar.studentProfiles.putAll(studentProfiles);

        await isar.sessions.clear();
        await isar.sessions.putAll(remoteSessions);

        final sessionMap = { for (var s in remoteSessions) s.supabaseId: s.id };

        final remoteParts = (partRows as List).map((r) {
           final sId = r['session_id'];
           return SessionPart()
             ..sessionLocalId = sessionMap[sId] ?? -1
             ..supabaseId = r['id']
             ..type = r['type']                 // يخزّن كنص (int) في Isar لكننا سنحوّله لـ SessionType
             ..suraStart = r['sura_start']
             ..ayaStart = r['aya_start']
             ..suraEnd = r['sura_end']
             ..ayaEnd = r['aya_end']
             ..pagesCount = (r['pages_count'] as num).toDouble()
             ..isExtra = r['is_extra'] ?? false
             ..evaluation = r['evaluation']
             ..notes = r['notes']
             ..isSynced = true;
        }).where((p) => p.sessionLocalId != -1).toList();

        await isar.sessionParts.clear();
        await isar.sessionParts.putAll(remoteParts);
      });
    } catch (e) {
      throw SyncException('فشل سحب البيانات: $e');
    }
  }

  Future<void> syncPendingSessions() async {
    try {
      final unsynced = await _sessionService.getUnsyncedSessions();
      if (unsynced.isEmpty) return;

      final isar = await IsarService.isar;
      for (var session in unsynced) {
        final parts = await isar.sessionParts
            .where()
            .sessionLocalIdEqualTo(session.id)
            .findAll();

        final sessionData = {
          'id': session.supabaseId,
          'student_id': session.studentSupabaseId,
          'group_id': session.groupSupabaseId,
          'teacher_id': session.teacherSupabaseId,
          'session_date': session.sessionDate.toIso8601String().split('T')[0],
          'early_attendance': session.earlyAttendance,
          'on_time_departure': session.onTimeDeparture,
          'early_recitation': session.earlyRecitation,
          'cumulative_done': session.cumulativeDone,
          'total_points': session.totalPoints,
        };

        await _client.from('sessions').upsert(sessionData, onConflict: 'student_id, session_date');

        for (var part in parts) {
          await _client.from('session_parts').upsert({
            'id': part.supabaseId,
            'session_id': session.supabaseId,
            'type': part.type.name,             // تحويل enum إلى نص
            'sura_start': part.suraStart,
            'aya_start': part.ayaStart,
            'sura_end': part.suraEnd,
            'aya_end': part.ayaEnd,
            'pages_count': part.pagesCount,
            'is_extra': part.isExtra,
            'evaluation': part.evaluation,
            'notes': part.notes,
          });
        }

        await isar.writeTxn(() async {
          session.isSynced = true;
          await isar.sessions.put(session);
          for (var part in parts) {
            part.isSynced = true;
            await isar.sessionParts.put(part);
          }
        });
      }
    } catch (e) {
      throw SyncException('فشل رفع الجلسات: $e');
    }
  }
}