import 'package:flutter/material.dart';
import '../services/quran_database_service.dart';
import 'searchable_dropdown.dart';

// ... SessionPartWidgetController، SessionPartData كما هي بدون تغيير

class SessionPartWidget extends StatefulWidget {
  final SessionPartWidgetController controller;
  final bool isExtra;

  const SessionPartWidget({super.key, required this.controller, required this.isExtra});

  @override
  State<SessionPartWidget> createState() => _SessionPartWidgetState();
}

class _SessionPartWidgetState extends State<SessionPartWidget> {
  final QuranDatabaseService _quranDB = QuranDatabaseService();
  List<Map<String, dynamic>> surahs = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    surahs = await _quranDB.getSurahs();
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const LinearProgressIndicator();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(widget.isExtra ? 'تسميع منفصل' : 'أساسي'),
            Row(
              children: [
                Expanded(
                  child: SearchableDropdown<Map<String, dynamic>>(
                    items: surahs,
                    labelBuilder: (s) => '${s['sora_name_ar']} (${s['sora']})',
                    hint: 'من سورة',
                    onChanged: (val) => widget.controller.surahStartCtrl.text = val?['sora'].toString() ?? '',
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
                    items: surahs,
                    labelBuilder: (s) => '${s['sora_name_ar']} (${s['sora']})',
                    hint: 'إلى سورة',
                    onChanged: (val) => widget.controller.surahEndCtrl.text = val?['sora'].toString() ?? '',
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
            DropdownButtonFormField<String>(
              value: widget.controller.evaluation,
              decoration: const InputDecoration(labelText: 'التقييم'),
              items: const [
                DropdownMenuItem(value: 'ممتاز', child: Text('ممتاز')),
                DropdownMenuItem(value: 'جيد جداً', child: Text('جيد جداً')),
                DropdownMenuItem(value: 'جيد', child: Text('جيد')),
                DropdownMenuItem(value: 'مقبول', child: Text('مقبول')),
                DropdownMenuItem(value: 'ضعيف', child: Text('ضعيف')),
              ],
              onChanged: (v) => widget.controller.evaluation = v,
            ),
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