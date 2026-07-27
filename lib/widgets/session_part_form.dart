import 'package:flutter/material.dart';
import '../../models/session_part.dart';
import 'searchable_dropdown.dart';

class SessionPartWidgetController {
  final TextEditingController surahStartCtrl = TextEditingController();
  final TextEditingController ayaStartCtrl = TextEditingController();
  final TextEditingController surahEndCtrl = TextEditingController();
  final TextEditingController ayaEndCtrl = TextEditingController();
  String? evaluation = 'ممتاز';
  final TextEditingController notesCtrl = TextEditingController();
  bool isExtra = false;

  SessionPartData? getData() {
    final sStart = int.tryParse(surahStartCtrl.text);
    final aStart = int.tryParse(ayaStartCtrl.text);
    final sEnd = int.tryParse(surahEndCtrl.text);
    final aEnd = int.tryParse(ayaEndCtrl.text);
    if (sStart == null || aStart == null || sEnd == null || aEnd == null) return null;
    if (sStart <= 0 || aStart <= 0 || sEnd <= 0 || aEnd <= 0) return null;
    if (sStart == sEnd && aStart > aEnd) return null;
    return SessionPartData(
      suraStart: sStart,
      ayaStart: aStart,
      suraEnd: sEnd,
      ayaEnd: aEnd,
      evaluation: evaluation,
      notes: notesCtrl.text,
      isExtra: isExtra,
    );
  }

  void dispose() {
    surahStartCtrl.dispose();
    ayaStartCtrl.dispose();
    surahEndCtrl.dispose();
    ayaEndCtrl.dispose();
    notesCtrl.dispose();
  }
}

class SessionPartData {
  final int suraStart;
  final int ayaStart;
  final int suraEnd;
  final int ayaEnd;
  final String? evaluation;
  final String? notes;
  final bool isExtra;
  SessionPartData({
    required this.suraStart, required this.ayaStart,
    required this.suraEnd, required this.ayaEnd,
    this.evaluation, this.notes, required this.isExtra,
  });
}

class SessionPartWidget extends StatefulWidget {
  final SessionPartWidgetController controller;
  final SessionType partType;               // نوع الجزء (memorization, cumulative, review)
  final List<Map<String, dynamic>> surahs;  // تحتوي كل خريطة على sora, sora_name_ar, ayah_count
  final VoidCallback? onDelete;

  const SessionPartWidget({
    super.key,
    required this.controller,
    required this.partType,
    required this.surahs,
    this.onDelete,
  });

  @override
  State<SessionPartWidget> createState() => _SessionPartWidgetState();
}

class _SessionPartWidgetState extends State<SessionPartWidget> {
  String? _startAyahError;
  String? _endAyahError;

  bool _isAyahValid(int sura, int ayah) {
    final surah = widget.surahs.firstWhere((s) => s['sora'] == sura, orElse: () => {});
    if (surah.isEmpty) return false;
    final ayahCount = surah['ayah_count'] as int?;
    if (ayahCount == null) return true; // لا نستطيع التحقق
    return ayah >= 1 && ayah <= ayahCount;
  }

  void _validateStartAyah() {
    final sura = int.tryParse(widget.controller.surahStartCtrl.text);
    final ayah = int.tryParse(widget.controller.ayaStartCtrl.text);
    if (sura != null && ayah != null) {
      setState(() {
        _startAyahError = _isAyahValid(sura, ayah) ? null : 'الآية غير موجودة في هذه السورة';
      });
    }
  }

  void _validateEndAyah() {
    final sura = int.tryParse(widget.controller.surahEndCtrl.text);
    final ayah = int.tryParse(widget.controller.ayaEndCtrl.text);
    if (sura != null && ayah != null) {
      setState(() {
        _endAyahError = _isAyahValid(sura, ayah) ? null : 'الآية غير موجودة في هذه السورة';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.partType.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SearchableDropdown<Map<String, dynamic>>(
                    items: widget.surahs,
                    labelBuilder: (s) => '${s['sora_name_ar']} (${s['sora']})',
                    hint: 'من سورة',
                    onChanged: (val) {
                      widget.controller.surahStartCtrl.text = val?['sora'].toString() ?? '';
                      setState(() => _startAyahError = null);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.controller.ayaStartCtrl,
                    decoration: InputDecoration(
                      hintText: 'آية',
                      errorText: _startAyahError,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      _validateStartAyah();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SearchableDropdown<Map<String, dynamic>>(
                    items: widget.surahs,
                    labelBuilder: (s) => '${s['sora_name_ar']} (${s['sora']})',
                    hint: 'إلى سورة',
                    onChanged: (val) {
                      widget.controller.surahEndCtrl.text = val?['sora'].toString() ?? '';
                      setState(() => _endAyahError = null);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.controller.ayaEndCtrl,
                    decoration: InputDecoration(
                      hintText: 'آية',
                      errorText: _endAyahError,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      _validateEndAyah();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'ممتاز', label: Text('ممتاز', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'جيد جداً', label: Text('جيد جداً', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'جيد', label: Text('جيد', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'مقبول', label: Text('مقبول', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'ضعيف', label: Text('ضعيف', style: TextStyle(fontSize: 12))),
                ],
                selected: {widget.controller.evaluation ?? 'ممتاز'},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    widget.controller.evaluation = newSelection.first;
                  });
                },
                showSelectedIcon: false,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.controller.notesCtrl,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
            ),
          ],
        ),
      ),
    );
  }
}