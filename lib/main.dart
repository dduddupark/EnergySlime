import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/dashboard/dashboard_screen.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/theme/theme_manager.dart';
import 'package:stepflow/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/splash/splash_screen.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_design_system.dart';

void main() {
  //그라운드 서비스(Foreground Task)와 메인 앱 간의 소통 통로(Port)를 준비하는 코드
  FlutterForegroundTask.initCommunicationPort();

  //ProviderScope(...): Riverpod을 사용하기 위해 필요한 부모 바구니입니다. 
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final designSystem = AppDesignSystem(
      cardRadius: 28.0,
      buttonRadius: 28.0,
      defaultPadding: 20.0,
      slateAlpha: AppColors.slateAlpha,
    );

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
            scaffoldBackgroundColor: AppColors.lightBackground,
            extensions: [designSystem],
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.lightBackground,
              foregroundColor: AppColors.darkSlateGray,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkSlateGray),
            ),
            colorScheme: const ColorScheme.light(
              primary: AppColors.lightPrimary,
              secondary: AppColors.lightSecondary,
              surface: Colors.white,
              onSurface: AppColors.darkSlateGray,
            ),
            textTheme: GoogleFonts.nanumGothicTextTheme().copyWith(
              bodyMedium: GoogleFonts.nanumGothic(fontWeight: FontWeight.w500),
              bodyLarge: GoogleFonts.nanumGothic(fontWeight: FontWeight.w500),
              titleMedium: GoogleFonts.nanumGothic(fontWeight: FontWeight.w600),
              titleLarge: GoogleFonts.nanumGothic(fontWeight: FontWeight.bold),
            ).apply(
              bodyColor: AppColors.darkSlateGray,
              displayColor: AppColors.darkSlateGray,
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: AppColors.lightPrimary.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(designSystem.cardRadius)),
              margin: EdgeInsets.zero,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.lightPrimary.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(designSystem.buttonRadius)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.darkBackground,
            extensions: [designSystem],
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.darkBackground,
              foregroundColor: AppColors.lightBackground,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.lightBackground),
            ),
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkPrimary,
              secondary: AppColors.darkSecondary,
              surface: AppColors.darkSurface,
              onSurface: AppColors.lightBackground,
            ),
            textTheme: GoogleFonts.nanumGothicTextTheme().copyWith(
              bodyMedium: GoogleFonts.nanumGothic(fontWeight: FontWeight.w500),
              bodyLarge: GoogleFonts.nanumGothic(fontWeight: FontWeight.w500),
              titleMedium: GoogleFonts.nanumGothic(fontWeight: FontWeight.w600),
              titleLarge: GoogleFonts.nanumGothic(fontWeight: FontWeight.bold),
            ).apply(
              bodyColor: AppColors.lightBackground,
              displayColor: AppColors.lightBackground,
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: AppColors.lightPrimary.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(designSystem.cardRadius)),
              margin: EdgeInsets.zero,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.lightPrimary.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(designSystem.buttonRadius)),
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
