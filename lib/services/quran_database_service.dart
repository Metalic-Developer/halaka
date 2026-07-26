import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'quran.db');

    final file = File(dbPath);
    if (!await file.exists()) {
      await _copyDatabaseInBackground(dbPath);
    }

    return await openDatabase(dbPath, readOnly: true);
  }

  Future<void> _copyDatabaseInBackground(String dbPath) async {
    final data = await rootBundle.load('assets/quran.db');
    final bytes = data.buffer.asUint8List();
    // استخدام Isolate.run لعزل عملية الكتابة (Flutter 3.7+)
    await Isolate.run(() async {
      await File(dbPath).writeAsBytes(bytes);
    });
  }

  Future<List<Map<String, dynamic>>> getSurahs() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT sora, sora_name_ar FROM quran_index ORDER BY sora',
    );
    return result;
  }

  Future<List<int>> getPages(
    int suraStart, int ayaStart,
    int suraEnd, int ayaEnd,
  ) async {
    final db = await database;
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

  Future<double> calculatePages(
    int suraStart, int ayaStart,
    int suraEnd, int ayaEnd,
  ) async {
    final pages = await getPages(suraStart, ayaStart, suraEnd, ayaEnd);
    if (pages.isEmpty) return 0;
    return (pages.last - pages.first + 1).toDouble();
  }
}