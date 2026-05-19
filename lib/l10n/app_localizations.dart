import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'CityBuilder'**
  String get appTitle;

  /// No description provided for @hudBudget.
  ///
  /// In de, this message translates to:
  /// **'Budget'**
  String get hudBudget;

  /// No description provided for @hudTick.
  ///
  /// In de, this message translates to:
  /// **'Runde'**
  String get hudTick;

  /// No description provided for @hudPopulation.
  ///
  /// In de, this message translates to:
  /// **'Einwohner'**
  String get hudPopulation;

  /// No description provided for @hudApproval.
  ///
  /// In de, this message translates to:
  /// **'Umfragewert'**
  String get hudApproval;

  /// No description provided for @zoneResidential.
  ///
  /// In de, this message translates to:
  /// **'Wohngebiet'**
  String get zoneResidential;

  /// No description provided for @zoneCommercial.
  ///
  /// In de, this message translates to:
  /// **'Gewerbe'**
  String get zoneCommercial;

  /// No description provided for @zoneIndustrial.
  ///
  /// In de, this message translates to:
  /// **'Industrie'**
  String get zoneIndustrial;

  /// No description provided for @terrainGrass.
  ///
  /// In de, this message translates to:
  /// **'Grasland'**
  String get terrainGrass;

  /// No description provided for @terrainWater.
  ///
  /// In de, this message translates to:
  /// **'Wasser'**
  String get terrainWater;

  /// No description provided for @terrainHill.
  ///
  /// In de, this message translates to:
  /// **'Hügel'**
  String get terrainHill;

  /// No description provided for @terrainForest.
  ///
  /// In de, this message translates to:
  /// **'Wald'**
  String get terrainForest;

  /// No description provided for @overlayPower.
  ///
  /// In de, this message translates to:
  /// **'Stromversorgung'**
  String get overlayPower;

  /// No description provided for @overlayWater.
  ///
  /// In de, this message translates to:
  /// **'Wasserversorgung'**
  String get overlayWater;

  /// No description provided for @overlayTraffic.
  ///
  /// In de, this message translates to:
  /// **'Verkehr'**
  String get overlayTraffic;

  /// No description provided for @overlayPollution.
  ///
  /// In de, this message translates to:
  /// **'Verschmutzung'**
  String get overlayPollution;

  /// No description provided for @overlayCrime.
  ///
  /// In de, this message translates to:
  /// **'Kriminalität'**
  String get overlayCrime;

  /// No description provided for @overlayLandValue.
  ///
  /// In de, this message translates to:
  /// **'Bodenwert'**
  String get overlayLandValue;

  /// No description provided for @overlayPopDensity.
  ///
  /// In de, this message translates to:
  /// **'Bevölkerungsdichte'**
  String get overlayPopDensity;

  /// No description provided for @menuNewGame.
  ///
  /// In de, this message translates to:
  /// **'Neues Spiel'**
  String get menuNewGame;

  /// No description provided for @menuLoad.
  ///
  /// In de, this message translates to:
  /// **'Laden'**
  String get menuLoad;

  /// No description provided for @menuSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get menuSave;

  /// No description provided for @menuSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get menuSettings;

  /// No description provided for @menuMainMenu.
  ///
  /// In de, this message translates to:
  /// **'Hauptmenü'**
  String get menuMainMenu;

  /// No description provided for @menuResume.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get menuResume;

  /// No description provided for @settingsLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get settingsLanguage;

  /// No description provided for @settingsMusicVolume.
  ///
  /// In de, this message translates to:
  /// **'Musik-Lautstärke'**
  String get settingsMusicVolume;

  /// No description provided for @settingsSfxVolume.
  ///
  /// In de, this message translates to:
  /// **'Effekte-Lautstärke'**
  String get settingsSfxVolume;

  /// No description provided for @settingsFontSize.
  ///
  /// In de, this message translates to:
  /// **'Schriftgröße'**
  String get settingsFontSize;

  /// No description provided for @settingsColorBlindMode.
  ///
  /// In de, this message translates to:
  /// **'Farbblindsicht'**
  String get settingsColorBlindMode;

  /// No description provided for @gameOver.
  ///
  /// In de, this message translates to:
  /// **'Spiel vorbei'**
  String get gameOver;

  /// No description provided for @gameOverBankrupt.
  ///
  /// In de, this message translates to:
  /// **'Insolvenz — kein Geld mehr'**
  String get gameOverBankrupt;

  /// No description provided for @gameOverApproval.
  ///
  /// In de, this message translates to:
  /// **'Abgewählt — Umfragewert zu niedrig'**
  String get gameOverApproval;

  /// No description provided for @techTreeTitle.
  ///
  /// In de, this message translates to:
  /// **'Tech Tree'**
  String get techTreeTitle;

  /// No description provided for @techResearch.
  ///
  /// In de, this message translates to:
  /// **'Erforschen'**
  String get techResearch;

  /// No description provided for @techLocked.
  ///
  /// In de, this message translates to:
  /// **'Gesperrt'**
  String get techLocked;

  /// No description provided for @techUnlocked.
  ///
  /// In de, this message translates to:
  /// **'Verfügbar'**
  String get techUnlocked;

  /// No description provided for @techResearched.
  ///
  /// In de, this message translates to:
  /// **'Erforscht'**
  String get techResearched;

  /// No description provided for @budgetIncome.
  ///
  /// In de, this message translates to:
  /// **'Einnahmen'**
  String get budgetIncome;

  /// No description provided for @budgetExpenses.
  ///
  /// In de, this message translates to:
  /// **'Ausgaben'**
  String get budgetExpenses;

  /// No description provided for @budgetBalance.
  ///
  /// In de, this message translates to:
  /// **'Bilanz'**
  String get budgetBalance;

  /// No description provided for @budgetTaxRates.
  ///
  /// In de, this message translates to:
  /// **'Steuersätze'**
  String get budgetTaxRates;

  /// No description provided for @spacePhaseTitle.
  ///
  /// In de, this message translates to:
  /// **'Weltraumzeitalter'**
  String get spacePhaseTitle;

  /// No description provided for @spaceMissionLaunch.
  ///
  /// In de, this message translates to:
  /// **'Mission starten'**
  String get spaceMissionLaunch;

  /// No description provided for @difficultyEasy.
  ///
  /// In de, this message translates to:
  /// **'Einfach'**
  String get difficultyEasy;

  /// No description provided for @difficultyNormal.
  ///
  /// In de, this message translates to:
  /// **'Normal'**
  String get difficultyNormal;

  /// No description provided for @difficultyHard.
  ///
  /// In de, this message translates to:
  /// **'Schwer'**
  String get difficultyHard;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
