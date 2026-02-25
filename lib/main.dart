import 'package:flutter/material.dart';
import 'ui/dashboard/dashboard_screen.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/theme/theme_manager.dart';
import 'package:stepflow/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  FlutterForegroundTask.initCommunicationPort();
  runApp(const MyApp());
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
            scaffoldBackgroundColor: const Color(0xFFF8F9FA), // 아주 연한 그레이 (Soft Pastel)
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF8F9FA),
              foregroundColor: Color(0xFF212529),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF212529)),
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6EDABC), // 민트 블루
              surface: Colors.white,
              onSurface: Color(0xFF212529),
            ),
            textTheme: GoogleFonts.nanumGothicTextTheme(ThemeData.light().textTheme),
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              margin: EdgeInsets.zero,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6EDABC),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1B1D1F),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1B1D1F),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF5AB69C),
              surface: Color(0xFF2A2D30),
              onSurface: Colors.white,
            ),
            textTheme: GoogleFonts.nanumGothicTextTheme(ThemeData.dark().textTheme),
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              margin: EdgeInsets.zero,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5AB69C),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          home: const WithForegroundTask(child: DashboardScreenWrapper()),
        );
      },
    );
  }
}

class DashboardScreenWrapper extends StatelessWidget {
  const DashboardScreenWrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DashboardScreen();
  }
}
