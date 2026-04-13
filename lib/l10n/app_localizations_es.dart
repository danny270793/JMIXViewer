// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'JMIX Viewer';

  @override
  String get splashLoading => 'Cargando…';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get loginBody =>
      'Conéctate a Foodie con credenciales de cliente OAuth2. La app solicita un token de acceso y lo envía como Authorization: Bearer en las llamadas a la API.';

  @override
  String get connectToFoodie => 'Conectar a Foodie';

  @override
  String connectionFailed(String error) {
    return 'Error de conexión: $error';
  }

  @override
  String get homeTitle => 'JMIX Viewer';

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get connectedToFoodie => 'Conectado a Foodie';

  @override
  String get signedInBody =>
      'Has iniciado sesión. El token de acceso está activo para las llamadas a la API.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get themeOption => 'Tema';

  @override
  String get themeSubtitle =>
      'Elige si la app sigue tu dispositivo o usa siempre un aspecto claro u oscuro.';

  @override
  String get themeSheetTitle => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystemDesc =>
      'Igual que el modo claro u oscuro del dispositivo';

  @override
  String get themeLightDesc => 'Usar siempre apariencia clara';

  @override
  String get themeDarkDesc => 'Usar siempre apariencia oscura';

  @override
  String get signOut => 'Cerrar sesión';
}
