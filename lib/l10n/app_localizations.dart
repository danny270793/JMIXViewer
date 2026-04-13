import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'JMIX Viewer'**
  String get appTitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get splashLoading;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginBody.
  ///
  /// In en, this message translates to:
  /// **'Connect to Foodie using OAuth2 client credentials. The app requests an access token, then sends it as Authorization: Bearer on API calls.'**
  String get loginBody;

  /// No description provided for @connectToFoodie.
  ///
  /// In en, this message translates to:
  /// **'Connect to Foodie'**
  String get connectToFoodie;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: {error}'**
  String connectionFailed(String error);

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'JMIX Viewer'**
  String get homeTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @connectedToFoodie.
  ///
  /// In en, this message translates to:
  /// **'Connected to Foodie'**
  String get connectedToFoodie;

  /// No description provided for @signedInBody.
  ///
  /// In en, this message translates to:
  /// **'You are signed in. Access token is active for API calls.'**
  String get signedInBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @themeOption.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeOption;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how the app follows your device or uses a fixed light or dark look.'**
  String get themeSubtitle;

  /// No description provided for @themeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSheetTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Match your device light or dark mode'**
  String get themeSystemDesc;

  /// No description provided for @themeLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Always use light appearance'**
  String get themeLightDesc;

  /// No description provided for @themeDarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Always use dark appearance'**
  String get themeDarkDesc;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @languageOption.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageOption;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Match your device or choose English or Spanish for the interface.'**
  String get languageSubtitle;

  /// No description provided for @languageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSheetTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Use your device language when the app supports it'**
  String get languageSystemDesc;

  /// No description provided for @languageEnglishDesc.
  ///
  /// In en, this message translates to:
  /// **'Always show the interface in English'**
  String get languageEnglishDesc;

  /// No description provided for @languageSpanishDesc.
  ///
  /// In en, this message translates to:
  /// **'Always show the interface in Spanish'**
  String get languageSpanishDesc;

  /// No description provided for @entityRecordEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get entityRecordEdit;

  /// No description provided for @entityRecordSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get entityRecordSave;

  /// No description provided for @entityRecordCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get entityRecordCancel;

  /// No description provided for @entityRecordMissingId.
  ///
  /// In en, this message translates to:
  /// **'Cannot save: this record has no id.'**
  String get entityRecordMissingId;

  /// No description provided for @entityRecordFieldInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid value for “{field}”.'**
  String entityRecordFieldInvalid(String field);

  /// No description provided for @entityRecordSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record updated.'**
  String get entityRecordSaveSuccess;

  /// No description provided for @entityRecordSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String entityRecordSaveFailed(String error);

  /// No description provided for @entityRecordDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get entityRecordDeleteTooltip;

  /// No description provided for @entityRecordDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get entityRecordDeleteConfirmTitle;

  /// No description provided for @entityRecordDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. The record will be removed from the server.'**
  String get entityRecordDeleteConfirmMessage;

  /// No description provided for @entityRecordDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get entityRecordDeleteConfirmButton;

  /// No description provided for @entityRecordDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String entityRecordDeleteFailed(String error);

  /// No description provided for @homeEntityListSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort list'**
  String get homeEntityListSortTooltip;

  /// No description provided for @homeEntityListSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort list'**
  String get homeEntityListSortTitle;

  /// No description provided for @homeEntityListSortField.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get homeEntityListSortField;

  /// No description provided for @homeEntityListSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get homeEntityListSortOrder;

  /// No description provided for @homeEntityListSortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get homeEntityListSortAscending;

  /// No description provided for @homeEntityListSortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get homeEntityListSortDescending;

  /// No description provided for @homeEntityListSortDefaultOrder.
  ///
  /// In en, this message translates to:
  /// **'Default order'**
  String get homeEntityListSortDefaultOrder;

  /// No description provided for @homeEntityListSortApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get homeEntityListSortApply;

  /// No description provided for @homeEntityListSortLoadingFields.
  ///
  /// In en, this message translates to:
  /// **'Loading fields…'**
  String get homeEntityListSortLoadingFields;

  /// No description provided for @homeEntityListSortNoFields.
  ///
  /// In en, this message translates to:
  /// **'No fields available for sorting.'**
  String get homeEntityListSortNoFields;

  /// No description provided for @homeEntityListSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search list'**
  String get homeEntityListSearchTooltip;

  /// No description provided for @homeEntityListSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeEntityListSearchTitle;

  /// No description provided for @homeEntityListSearchField.
  ///
  /// In en, this message translates to:
  /// **'Search in field'**
  String get homeEntityListSearchField;

  /// No description provided for @homeEntityListSearchOperator.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get homeEntityListSearchOperator;

  /// No description provided for @homeEntityListSearchQueryHint.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get homeEntityListSearchQueryHint;

  /// No description provided for @homeEntityListSearchValueHintIn.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated values'**
  String get homeEntityListSearchValueHintIn;

  /// No description provided for @homeEntityListSearchValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a value for this condition.'**
  String get homeEntityListSearchValueRequired;

  /// No description provided for @homeEntityListSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get homeEntityListSearchClear;

  /// No description provided for @homeEntityListSearchApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get homeEntityListSearchApply;

  /// No description provided for @homeEntityListSearchLoadingFields.
  ///
  /// In en, this message translates to:
  /// **'Loading fields…'**
  String get homeEntityListSearchLoadingFields;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
