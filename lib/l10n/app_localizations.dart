import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Energy Slime'**
  String get appTitle;

  /// No description provided for @noDataMsg.
  ///
  /// In en, this message translates to:
  /// **'No step data available.\nPlease link to Samsung Health or Google Fit.'**
  String get noDataMsg;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @todayRecord.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Record'**
  String get todayRecord;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @activeTime.
  ///
  /// In en, this message translates to:
  /// **'Active Time'**
  String get activeTime;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'{steps} Steps'**
  String steps(String steps);

  /// No description provided for @stepsUnit.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsUnit;

  /// No description provided for @progressSteps.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} Steps'**
  String progressSteps(String current, String target);

  /// No description provided for @trackingSteps.
  ///
  /// In en, this message translates to:
  /// **'Tracking steps...'**
  String get trackingSteps;

  /// No description provided for @testingTitle.
  ///
  /// In en, this message translates to:
  /// **'Test: Set Step Count'**
  String get testingTitle;

  /// No description provided for @stepsSetMessage.
  ///
  /// In en, this message translates to:
  /// **'Step count set to {steps} steps!'**
  String stepsSetMessage(int steps);

  /// No description provided for @noHealthDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch data. Please sync Samsung Health or check permissions.'**
  String get noHealthDataWarning;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myInfo.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myInfo;

  /// No description provided for @checkHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get checkHistory;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your daily steps and slime growth.'**
  String get historySubtitle;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Use Dark Theme'**
  String get darkTheme;

  /// No description provided for @darkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sets the app background to a dark color.'**
  String get darkThemeSubtitle;

  /// No description provided for @goalFullText.
  ///
  /// In en, this message translates to:
  /// **'10,000 steps basis (Full)'**
  String get goalFullText;

  /// No description provided for @kcalInfoText.
  ///
  /// In en, this message translates to:
  /// **'The number below the date is kcal burned'**
  String get kcalInfoText;

  /// No description provided for @slimeSpeechHungry.
  ///
  /// In en, this message translates to:
  /// **'I\'m too hungry to move...\n({remaining} steps left)'**
  String slimeSpeechHungry(int remaining);

  /// No description provided for @slimeSpeechActive.
  ///
  /// In en, this message translates to:
  /// **'Almost there!\nI\'m feeling lighter!'**
  String get slimeSpeechActive;

  /// No description provided for @slimeSpeechParty.
  ///
  /// In en, this message translates to:
  /// **'Today is the best!\nI\'m now an invincible slime!'**
  String get slimeSpeechParty;

  /// No description provided for @stepUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} Steps'**
  String stepUnit(int count);

  /// No description provided for @purchasedItem.
  ///
  /// In en, this message translates to:
  /// **'Purchased {itemName}!'**
  String purchasedItem(String itemName);

  /// No description provided for @notEnoughPoints.
  ///
  /// In en, this message translates to:
  /// **'Not enough points! Walk to collect water drops.'**
  String get notEnoughPoints;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @earnPointRule.
  ///
  /// In en, this message translates to:
  /// **'Earn 1 water drop per 100 steps!'**
  String get earnPointRule;

  /// No description provided for @unequipBtn.
  ///
  /// In en, this message translates to:
  /// **'Unequip'**
  String get unequipBtn;

  /// No description provided for @equipBtn.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get equipBtn;

  /// No description provided for @buyBtn.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buyBtn;

  /// No description provided for @purchaseHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchaseHistoryTitle;

  /// No description provided for @noPurchasedItems.
  ///
  /// In en, this message translates to:
  /// **'No purchased items yet.'**
  String get noPurchasedItems;

  /// No description provided for @categoryBg.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get categoryBg;

  /// No description provided for @categoryFace.
  ///
  /// In en, this message translates to:
  /// **'Face Deco'**
  String get categoryFace;

  /// No description provided for @categoryHead.
  ///
  /// In en, this message translates to:
  /// **'Hat'**
  String get categoryHead;

  /// No description provided for @statusEquipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get statusEquipped;

  /// No description provided for @statusStored.
  ///
  /// In en, this message translates to:
  /// **'Stored'**
  String get statusStored;

  /// No description provided for @add100Points.
  ///
  /// In en, this message translates to:
  /// **'Add 100 Points'**
  String get add100Points;

  /// No description provided for @add100PointsSuccess.
  ///
  /// In en, this message translates to:
  /// **'💧 Test: 100 points granted! 💧'**
  String get add100PointsSuccess;

  /// No description provided for @initStepData.
  ///
  /// In en, this message translates to:
  /// **'Initializing step data...'**
  String get initStepData;

  /// No description provided for @hat_red.
  ///
  /// In en, this message translates to:
  /// **'Red Cap'**
  String get hat_red;

  /// No description provided for @hat_crown.
  ///
  /// In en, this message translates to:
  /// **'Small Crown'**
  String get hat_crown;

  /// No description provided for @hat_straw.
  ///
  /// In en, this message translates to:
  /// **'Straw Hat'**
  String get hat_straw;

  /// No description provided for @hat_wizard.
  ///
  /// In en, this message translates to:
  /// **'Wizard Hat'**
  String get hat_wizard;

  /// No description provided for @hat_party.
  ///
  /// In en, this message translates to:
  /// **'Party Hat'**
  String get hat_party;

  /// No description provided for @face_glasses.
  ///
  /// In en, this message translates to:
  /// **'Sunglasses'**
  String get face_glasses;

  /// No description provided for @face_mustache.
  ///
  /// In en, this message translates to:
  /// **'Mustache'**
  String get face_mustache;

  /// No description provided for @face_blush.
  ///
  /// In en, this message translates to:
  /// **'Blush'**
  String get face_blush;

  /// No description provided for @face_mask.
  ///
  /// In en, this message translates to:
  /// **'Mask'**
  String get face_mask;

  /// No description provided for @bg_forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get bg_forest;

  /// No description provided for @bg_space.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get bg_space;

  /// No description provided for @bg_beach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get bg_beach;

  /// No description provided for @bg_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get bg_city;

  /// No description provided for @bg_snow.
  ///
  /// In en, this message translates to:
  /// **'Snowy Field'**
  String get bg_snow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
