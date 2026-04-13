import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeController.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData _lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }

  static ThemeData _darkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp.router(
          onGenerateTitle: (context) =>
              AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: themeController.themeMode,
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
        );
      },
    );
  }
}
