import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/session_part_form.dart';
import '../../core/strings.dart';

class SessionForm extends ConsumerStatefulWidget {
  final User student;
  const SessionForm({super.key, required this.student});

  @override
  ConsumerState<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends ConsumerState<SessionForm> {
  late final _newParts = <SessionPartWidgetController>[];
  final _reviewParts = <SessionPartWidgetController>[];
  bool _cumulativeDone = false;
  bool _earlyAttendance = false;
  bool _onTimeDeparture = false;
  bool _earlyRecitation = false;
  int? _sessionLocalId;   // int?

  @override
  void initState() {
    super.initState();
    _newParts.add(SessionPartWidgetController());
  }

  @override
  void dispose() {
    for (var c in _newParts) c.dispose();
    for (var c in _reviewParts) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final teacher = ref.read(authProvider).currentSession?.user;
    if (teacher == null) return;
    final session = await ref.read(teacherProvider).createSession(
      studentSupabaseId: widget.student.supabaseId,
      groupSupabaseId: widget.student.groupSupabaseId ?? '',
      teacherSupabaseId: teacher.id,
      sessionDate: DateTime.now(),
      earlyAttendance: _earlyAttendance,
      onTimeDeparture: _onTimeDeparture,
      earlyRecitation: _earlyRecitation,
      cumulativeDone: _cumulativeDone,
    );
    _sessionLocalId = session.id;   // id هو autoIncrement (int)

    for (var c in _newParts) {
      final data = c.getData();
      if (data != null) {
        await ref.read(teacherProvider).addSessionPart(
          sessionLocalId: session.id,   // int
          type: data.isExtra ? 'extra_new' : 'new',
          suraStart: data.suraStart,
          ayaStart: data.ayaStart,
          suraEnd: data.suraEnd,
          ayaEnd: data.ayaEnd,
          isExtra: data.isExtra,
          evaluation: data.evaluation,
          notes: data.notes,
        );
      }
    }

    for (var c in _reviewParts) {
      final data = c.getData();
      if (data != null) {
        await ref.read(teacherProvider).addSessionPart(
          sessionLocalId: session.id,   // int
          type: data.isExtra ? 'extra_review' : 'review',
          suraStart: data.suraStart,
          ayaStart: data.ayaStart,
          suraEnd: data.suraEnd,
          ayaEnd: data.ayaEnd,
          isExtra: data.isExtra,
          evaluation: data.evaluation,
          notes: data.notes,
        );
      }
    }

    await ref.read(teacherProvider).calculateSessionPoints(session.id); // int
    if (mounted) Navigator.pop(context);
  }

  // build كما هي
  @override
  Widget build(BuildContext context) {
    // ... نفس الكود السابق بدون تغيير
    return Scaffold(
      appBar: AppBar(title: Text('جلسة ${widget.student.fullName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: const Text(AppStrings.doneCumulative),
              value: _cumulativeDone,
              onChanged: (v) => setState(() => _cumulativeDone = v ?? false),
            ),
            Text(AppStrings.newMemorization, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._newParts.map((c) => SessionPartWidget(controller: c, isExtra: false)),
            TextButton.icon(
              onPressed: () => setState(() => _newParts.add(SessionPartWidgetController())),
              icon: const Icon(Icons.add),
              label: const Text('إضافة تسميع منفصل'),
            ),
            const Divider(),
            Text(AppStrings.review, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._reviewParts.map((c) => SessionPartWidget(controller: c, isExtra: false)),
            TextButton.icon(
              onPressed: () => setState(() => _reviewParts.add(SessionPartWidgetController())),
              icon: const Icon(Icons.add),
              label: const Text('إضافة مراجعة منفصلة'),
            ),
            const Divider(),
            CheckboxListTile(title: const Text(AppStrings.earlyAttendance), value: _earlyAttendance, onChanged: (v) => setState(() => _earlyAttendance = v ?? false)),
            CheckboxListTile(title: const Text(AppStrings.onTimeDeparture), value: _onTimeDeparture, onChanged: (v) => setState(() => _onTimeDeparture = v ?? false)),
            CheckboxListTile(title: const Text(AppStrings.earlyRecitation), value: _earlyRecitation, onChanged: (v) => setState(() => _earlyRecitation = v ?? false)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cumulativeDone ? _submit : null,
              child: const Text('حفظ الجلسة'),
            ),
          ],
        ),
      ),
    );
  }
}