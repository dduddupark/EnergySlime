import 'package:flutter/material.dart';
import 'ui/dashboard/dashboard_screen.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/theme/theme_manager.dart';
import 'package:stepflow/l10n/app_localizations.dart';

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
            scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate 100
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF1F5F9),
              foregroundColor: Color(0xFF0F172A),
              elevation: 0,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF38BDF8),
              surface: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              surface: Color(0xFF1E293B),
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
