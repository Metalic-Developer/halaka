import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/supabase_config.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  await IsarService.isar; // تهيئة Isar
  // ❌ إزالة QuranDatabaseService من هنا – انتقل إلى SplashScreen
  runApp(const ProviderScope(child: QuranHalaqaApp()));
}

class QuranHalaqaApp extends StatelessWidget {
  const QuranHalaqaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حلقة القرآن',
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
      locale: const Locale('ar', 'SA'),
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}