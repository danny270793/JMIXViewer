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
}
