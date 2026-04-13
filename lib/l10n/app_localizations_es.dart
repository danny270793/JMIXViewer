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

  @override
  String get languageOption => 'Idioma';

  @override
  String get languageSubtitle =>
      'Igual que el dispositivo o elige inglés o español para la interfaz.';

  @override
  String get languageSheetTitle => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageSystemDesc =>
      'Usar el idioma del dispositivo si la app lo admite';

  @override
  String get languageEnglishDesc => 'Mostrar siempre la interfaz en inglés';

  @override
  String get languageSpanishDesc => 'Mostrar siempre la interfaz en español';

  @override
  String get entityRecordEdit => 'Editar';

  @override
  String get entityRecordSave => 'Guardar';

  @override
  String get entityRecordCancel => 'Cancelar';

  @override
  String get entityRecordMissingId =>
      'No se puede guardar: este registro no tiene id.';

  @override
  String entityRecordFieldInvalid(String field) {
    return 'Valor no válido para «$field».';
  }

  @override
  String get entityRecordSaveSuccess => 'Registro actualizado.';

  @override
  String entityRecordSaveFailed(String error) {
    return 'Error al guardar: $error';
  }
}
