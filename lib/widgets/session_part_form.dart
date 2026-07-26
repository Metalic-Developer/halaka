import 'package:flutter/material.dart';
import 'searchable_dropdown.dart';

class SessionPartWidgetController {
  final TextEditingController surahStartCtrl = TextEditingController();
  final TextEditingController ayaStartCtrl = TextEditingController();
  final TextEditingController surahEndCtrl = TextEditingController();
  final TextEditingController ayaEndCtrl = TextEditingController();
  String? evaluation;
  final TextEditingController notesCtrl = TextEditingController();
  bool isExtra = false;

  SessionPartData? getData() {
    final sStart = int.tryParse(surahStartCtrl.text);
    final aStart = int.tryParse(ayaStartCtrl.text);
    final sEnd = int.tryParse(surahEndCtrl.text);
    final aEnd = int.tryParse(ayaEndCtrl.text);
    if (sStart == null || aStart == null || sEnd == null || aEnd == null) return null;
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
  final bool isExtra;
  final List<Map<String, dynamic>> surahs;
  final VoidCallback? onDelete;

  const SessionPartWidget({
    super.key,
    required this.controller,
    required this.isExtra,
    required this.surahs,
    this.onDelete,
  });

  @override
  State<SessionPartWidget> createState() => _SessionPartWidgetState();
}

class _SessionPartWidgetState extends State<SessionPartWidget> {
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
                Text(widget.isExtra ? 'تسميع منفصل' : 'أساسي',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    onChanged: (val) =>
                        widget.controller.surahStartCtrl.text = val?['sora'].toString() ?? '',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.controller.ayaStartCtrl,
                    decoration: const InputDecoration(hintText: 'آية'),
                    keyboardType: TextInputType.number,
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
                    onChanged: (val) =>
                        widget.controller.surahEndCtrl.text = val?['sora'].toString() ?? '',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.controller.ayaEndCtrl,
                    decoration: const InputDecoration(hintText: 'آية'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ممتاز', label: Text('ممتاز')),
                ButtonSegment(value: 'جيد جداً', label: Text('جيد جداً')),
                ButtonSegment(value: 'جيد', label: Text('جيد')),
                ButtonSegment(value: 'مقبول', label: Text('مقبول')),
                ButtonSegment(value: 'ضعيف', label: Text('ضعيف')),
              ],
              selected: widget.controller.evaluation != null
                  ? {widget.controller.evaluation!}
                  : <String>{},
              emptySelectionAllowed: true,
              onSelectionChanged: (newSelection) {
                setState(() {
                  widget.controller.evaluation = newSelection.firstOrNull;
                });
              },
              showSelectedIcon: false,
            ),
            const SizedBox(height: 8),
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