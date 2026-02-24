// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Energy Slime';

  @override
  String get noDataMsg =>
      'No step data available.\nPlease link to Samsung Health or Google Fit.';

  @override
  String get connect => 'Connect';

  @override
  String get todayRecord => 'Today\'s Record';

  @override
  String get calories => 'Calories';

  @override
  String get activeTime => 'Active Time';

  @override
  String steps(String steps) {
    return '$steps Steps';
  }

  @override
  String get stepsUnit => 'Steps';

  @override
  String progressSteps(String current, String target) {
    return '$current / $target Steps';
  }

  @override
  String get trackingSteps => 'Tracking steps...';

  @override
  String get testingTitle => 'Test: Set Step Count';

  @override
  String stepsSetMessage(int steps) {
    return 'Step count set to $steps steps!';
  }

  @override
  String get noHealthDataWarning =>
      'Unable to fetch data. Please sync Samsung Health or check permissions.';

  @override
  String get settings => 'Settings';

  @override
  String get myInfo => 'My Profile';

  @override
  String get checkHistory => 'History';

  @override
  String get historySubtitle => 'Check your daily steps and slime growth.';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get darkTheme => 'Use Dark Theme';

  @override
  String get darkThemeSubtitle => 'Sets the app background to a dark color.';

  @override
  String get goalFullText => '10,000 steps basis (Full)';

  @override
  String get kcalInfoText => 'The number below the date is kcal burned';

  @override
  String slimeSpeechHungry(int remaining) {
    return 'I\'m too hungry to move...\n($remaining steps left)';
  }

  @override
  String get slimeSpeechActive => 'Almost there!\nI\'m feeling lighter!';

  @override
  String get slimeSpeechParty =>
      'Today is the best!\nI\'m now an invincible slime!';

  @override
  String stepUnit(int count) {
    return '$count Steps';
  }
}
