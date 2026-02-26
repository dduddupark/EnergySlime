import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/dashboard/dashboard_screen.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/theme/theme_manager.dart';
import 'package:stepflow/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/splash/splash_screen.dart';

void main() {
  FlutterForegroundTask.initCommunicationPort();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, child) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F9F9), // 연한 민트 그레이
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF5F9F9),
              foregroundColor: Color(0xFF2F4F4F),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2F4F4F)),
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFA7D8DE), // 소프트 민트
              secondary: Color(0xFFF9E076), // 레몬 옐로우
              surface: Colors.white,
              onSurface: Color(0xFF2F4F4F), // 다크 슬레이트 그레이
            ),
            textTheme: GoogleFonts.nanumGothicTextTheme().copyWith(
              bodyMedium: GoogleFonts.nanumGothic(fontWeight: FontWeight.w500),
              bodyLarge: GoogleFonts.nanumGothic(fontWeight: FontWeight.w500),
              titleMedium: GoogleFonts.nanumGothic(fontWeight: FontWeight.w600),
              titleLarge: GoogleFonts.nanumGothic(fontWeight: FontWeight.bold),
            ).apply(
              bodyColor: const Color(0xFF2F4F4F),
              displayColor: const Color(0xFF2F4F4F),
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: const Color(0xFFA7D8DE).withOpacity(0.05), // 민트색 그림자
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
              margin: EdgeInsets.zero,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA7D8DE),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFFA7D8DE).withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1E2729), // 연한 민트톤이 가미된 다크 그레이
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E2729),
              foregroundColor: Color(0xFFF5F9F9),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFF5F9F9)),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7CB8BE), // 더 어두운 민트
              secondary: Color(0xFFE5CC5A), // 더 어두운 레몬
              surface: Color(0xFF283437), // 카드 표면 색상
              onSurface: Color(0xFFF5F9F9),
            ),
            textTheme: GoogleFonts.nanumGothicTextTheme().copyWith(
              bodyMedium: GoogleFonts.nanumGothic(fontWeight: FontWeight.w500),
              bodyLarge: GoogleFonts.nanumGothic(fontWeight: FontWeight.w500),
              titleMedium: GoogleFonts.nanumGothic(fontWeight: FontWeight.w600),
              titleLarge: GoogleFonts.nanumGothic(fontWeight: FontWeight.bold),
            ).apply(
              bodyColor: const Color(0xFFF5F9F9),
              displayColor: const Color(0xFFF5F9F9),
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: const Color(0xFFA7D8DE).withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
              margin: EdgeInsets.zero,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7CB8BE),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFFA7D8DE).withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class DashboardScreenWrapper extends StatelessWidget {
  const DashboardScreenWrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const WithForegroundTask(child: DashboardScreenWrapperInner());
  }
}

class DashboardScreenWrapperInner extends StatelessWidget {
  const DashboardScreenWrapperInner({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DashboardScreen();
  }
}
