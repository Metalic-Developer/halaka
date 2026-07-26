import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:isar/isar.dart';
import '../models/quran_metadata.dart';
import 'isar_service.dart';

class QuranService {
  Future<Isar> get _isar => IsarService.isar;

  /// تحميل بيانات القرآن من ملف CSV وإدراجها في Isar (مرة واحدة فقط)
  Future<void> loadQuranDataFromAsset() async {
    final isar = await _isar;
    // تحقق إذا كانت البيانات موجودة مسبقًا
    final count = await isar.quranMetadatas.count();
    if (count > 0) return;

    // قراءة الملف
    final csvString = await rootBundle.loadString('assets/hafsData_v18.csv');
    final rows = const CsvToListConverter(eol: '\n').convert(csvString);

    // تجاهل الصف الأول (العناوين)
    final dataRows = rows.skip(1);

    final entities = <QuranMetadata>[];
    for (final row in dataRows) {
      if (row.length < 9) continue; // أقل عدد أعمدة مطلوبة
      entities.add(QuranMetadata()
        ..sora = int.parse(row[2].toString())    // عمود sora (index 2)
        ..ayaNo = int.parse(row[8].toString())   // عمود aya_no (index 8)
        ..page = int.parse(row[5].toString())    // عمود page (index 5)
        ..jozz = int.parse(row[1].toString())    // عمود jozz (index 1)
        ..soraNameAr = row[4].toString()         // sora_name_ar (index 4)
      );
    }

    await isar.writeTxn(() async {
      await isar.quranMetadatas.putAll(entities);
    });
  }

  Future<List<Map<String, dynamic>>> getSurahs() async {
    final isar = await _isar;
    final all = await isar.quranMetadatas.where().findAll();
    final seen = <int>{};
    final surahs = <Map<String, dynamic>>[];
    for (var aya in all) {
      if (!seen.contains(aya.sora)) {
        seen.add(aya.sora);
        surahs.add({'sora': aya.sora, 'name': aya.soraNameAr ?? ''});
      }
    }
    surahs.sort((a, b) => (a['sora'] as int).compareTo(b['sora'] as int));
    return surahs;
  }

  Future<double> calculatePages(int suraStart, int ayaStart, int suraEnd, int ayaEnd) async {
    final pages = await getPages(suraStart, ayaStart, suraEnd, ayaEnd);
    if (pages.isEmpty) return 0;
    return (pages.last - pages.first + 1).toDouble();
  }

  Future<List<int>> getPages(int suraStart, int ayaStart, int suraEnd, int ayaEnd) async {
    final isar = await _isar;
    final result = await isar.quranMetadatas
        .where()
        .soraBetween(suraStart, suraEnd)
        .filter()
        .and()
        .group((q) => q
            .soraEqualTo(suraStart)
            .and()
            .ayaNoGreaterThan(ayaStart - 1)
        )
        .or()
        .group((q) => q
            .soraEqualTo(suraEnd)
            .and()
            .ayaNoLessThan(ayaEnd + 1)
        )
        .or()
        .soraGreaterThan(suraStart, include: false)
        .and()
        .soraLessThan(suraEnd, include: false)
        .sortByPage()
        .pageProperty()
        .findAll();
    return result;
  }
}