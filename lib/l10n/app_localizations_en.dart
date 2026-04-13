// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'JMIX Viewer';

  @override
  String get splashLoading => 'Loading…';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginBody =>
      'Connect to Foodie using OAuth2 client credentials. The app requests an access token, then sends it as Authorization: Bearer on API calls.';

  @override
  String get connectToFoodie => 'Connect to Foodie';

  @override
  String connectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get homeTitle => 'JMIX Viewer';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get connectedToFoodie => 'Connected to Foodie';

  @override
  String get signedInBody =>
      'You are signed in. Access token is active for API calls.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeOption => 'Theme';

  @override
  String get themeSubtitle =>
      'Choose how the app follows your device or uses a fixed light or dark look.';

  @override
  String get themeSheetTitle => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystemDesc => 'Match your device light or dark mode';

  @override
  String get themeLightDesc => 'Always use light appearance';

  @override
  String get themeDarkDesc => 'Always use dark appearance';

  @override
  String get signOut => 'Sign out';

  @override
  String get languageOption => 'Language';

  @override
  String get languageSubtitle =>
      'Match your device or choose English or Spanish for the interface.';

  @override
  String get languageSheetTitle => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageSystemDesc =>
      'Use your device language when the app supports it';

  @override
  String get languageEnglishDesc => 'Always show the interface in English';

  @override
  String get languageSpanishDesc => 'Always show the interface in Spanish';

  @override
  String get entityRecordEdit => 'Edit';

  @override
  String get entityRecordSave => 'Save';

  @override
  String get entityRecordCancel => 'Cancel';

  @override
  String get entityRecordMissingId => 'Cannot save: this record has no id.';

  @override
  String entityRecordFieldInvalid(String field) {
    return 'Invalid value for “$field”.';
  }

  @override
  String get entityRecordSaveSuccess => 'Record updated.';

  @override
  String entityRecordSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get entityRecordDeleteTooltip => 'Delete record';

  @override
  String get entityRecordDeleteConfirmTitle => 'Delete this record?';

  @override
  String get entityRecordDeleteConfirmMessage =>
      'This cannot be undone. The record will be removed from the server.';

  @override
  String get entityRecordDeleteConfirmButton => 'Delete';

  @override
  String entityRecordDeleteFailed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get homeEntityListSortTooltip => 'Sort list';

  @override
  String get homeEntityListSortTitle => 'Sort list';

  @override
  String get homeEntityListSortField => 'Sort by';

  @override
  String get homeEntityListSortOrder => 'Order';

  @override
  String get homeEntityListSortAscending => 'Ascending';

  @override
  String get homeEntityListSortDescending => 'Descending';

  @override
  String get homeEntityListSortDefaultOrder => 'Default order';

  @override
  String get homeEntityListSortApply => 'Apply';

  @override
  String get homeEntityListSortLoadingFields => 'Loading fields…';

  @override
  String get homeEntityListSortNoFields => 'No fields available for sorting.';

  @override
  String get homeEntityListSearchTooltip => 'Search list';

  @override
  String get homeEntityListSearchTitle => 'Search';

  @override
  String get homeEntityListSearchField => 'Search in field';

  @override
  String get homeEntityListSearchOperator => 'Condition';

  @override
  String get homeEntityListSearchQueryHint => 'Value';

  @override
  String get homeEntityListSearchValueHintIn => 'Comma-separated values';

  @override
  String get homeEntityListSearchValueRequired =>
      'Enter a value for this condition.';

  @override
  String get homeEntityListSearchClear => 'Clear search';

  @override
  String get homeEntityListSearchApply => 'Apply';

  @override
  String get homeEntityListSearchLoadingFields => 'Loading fields…';
}
