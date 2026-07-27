import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class QuranDatabaseService {
  static final QuranDatabaseService _instance = QuranDatabaseService._internal();
  factory QuranDatabaseService() => _instance;
  QuranDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // على الويب: لا نحاول فتح sqflite، سنعتمد على بيانات وهمية
    if (kIsWeb) {
      throw UnsupportedError('SQLite غير مدعوم على الويب. استخدم البيانات الوهمية.');
    }

    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'quran.db');

    // التحقق من وجود قاعدة البيانات ونسخها من الأصول إذا لزم الأمر
    final exists = await databaseExists(dbPath);
    if (!exists) {
      try {
        // قراءة الملف من assets
        final data = await rootBundle.load('assets/quran.db');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        // كتابته باستخدام واجهة sqflite المباشرة (بدون dart:io)
        await databaseFactory.writeDatabaseBytes(dbPath, Uint8List.fromList(bytes));
      } catch (e) {
        throw Exception('فشل نسخ قاعدة البيانات من assets: $e');
      }
    }

    // فتح قاعدة البيانات للقراءة فقط
    return await openDatabase(dbPath, readOnly: true);
  }

  // ---------- قائمة السور ----------
  Future<List<Map<String, dynamic>>> getSurahs() async {
    if (kIsWeb) {
      // بيانات وهمية لتجربة الويب
      return [
        {'sora': 1, 'sora_name_ar': 'الفاتحة', 'ayah_count': 7},
        {'sora': 2, 'sora_name_ar': 'البقرة', 'ayah_count': 286},
        {'sora': 3, 'sora_name_ar': 'آل عمران', 'ayah_count': 200},
        {'sora': 4, 'sora_name_ar': 'النساء', 'ayah_count': 176},
        {'sora': 5, 'sora_name_ar': 'المائدة', 'ayah_count': 120},
        {'sora': 114, 'sora_name_ar': 'الناس', 'ayah_count': 6},
      ];
    }

    final db = await database;
    return await db.rawQuery(
      'SELECT sora, sora_name_ar, '
      '(SELECT COUNT(*) FROM quran_index WHERE sora = qi.sora) as ayah_count '
      'FROM quran_index qi GROUP BY sora ORDER BY sora',
    );
  }

  // ---------- نطاق الصفحات ----------
  Future<List<int>> getPages(
    int suraStart, int ayaStart,
    int suraEnd, int ayaEnd,
  ) async {
    if (kIsWeb) {
      return [1]; // قيمة وهمية آمنة
    }

    final db = await database;
    if (suraStart == suraEnd) {
      final result = await db.rawQuery('''
        SELECT DISTINCT page FROM quran_index
        WHERE sora = ? AND aya_no >= ? AND aya_no <= ?
        ORDER BY page
      ''', [suraStart, ayaStart, ayaEnd]);
      return result.map<int>((row) => row['page'] as int).toList();
    } else {
      final result = await db.rawQuery('''
        SELECT DISTINCT page FROM quran_index
        WHERE 
          (sora = ? AND aya_no >= ?) OR
          (sora > ? AND sora < ?) OR
          (sora = ? AND aya_no <= ?)
        ORDER BY page
      ''', [suraStart, ayaStart, suraStart, suraEnd, suraEnd, ayaEnd]);
      return result.map<int>((row) => row['page'] as int).toList();
    }
  }

  // ---------- حساب عدد الصفحات ----------
  Future<double> calculatePages(
    int suraStart, int ayaStart,
    int suraEnd, int ayaEnd,
  ) async {
    final pages = await getPages(suraStart, ayaStart, suraEnd, ayaEnd);
    if (pages.isEmpty) return 0;
    return (pages.last - pages.first + 1).toDouble();
  }
}