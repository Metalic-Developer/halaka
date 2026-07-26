import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/supabase_config.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/isar_service.dart';
import 'services/quran_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  await IsarService.isar; // تهيئة Isar

  // تهيئة قاعدة بيانات القرآن (تنسخ الملف من assets إذا لزم الأمر)
  await QuranDatabaseService().database;

  runApp(const ProviderScope(child: QuranHalaqaApp()));
}

class QuranHalaqaApp extends StatelessWidget {
  const QuranHalaqaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حلقة القرآن',
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}