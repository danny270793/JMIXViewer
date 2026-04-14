import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../api/jmix/jmix_api_exception.dart';
import '../config/foodie_jmix_config.dart';
import '../logging/app_logger.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../providers/home_providers.dart';
import '../router/app_router.dart';
import '../auth/foodie_session.dart';

/// Obtains an access token via OAuth2 client credentials, then navigates home.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _submitting = false;
  final _urlController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _urlController.text = FoodieJmixConfig.applicationBase;
      _clientIdController.text = FoodieJmixConfig.clientId;
      _clientSecretController.text = FoodieJmixConfig.clientSecret;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    AppLogger.logUserAction('login.connect');
    final l10n = AppLocalizations.of(context);
    final urlText = _urlController.text.trim();
    final clientId = _clientIdController.text.trim();
    final clientSecret = _clientSecretController.text.trim();

    final uri = Uri.tryParse(urlText);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginInvalidUrl)),
      );
      return;
    }
    if (clientId.isEmpty || clientSecret.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginFieldRequired)),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      FoodieSession.instance.configure(
        applicationBaseUri: uri,
        clientId: clientId,
        clientSecret: clientSecret,
      );
      resetJmixHomeCaches();
      ref.read(jmixSessionEpochProvider.notifier).state++;

      await ref.read(signInWithClientCredentialsUseCaseProvider)();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on JmixApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).connectionFailed('$e')),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.welcomeBack,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.loginApplicationUrl,
                  hintText: l10n.loginUrlHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _clientIdController,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.loginClientId,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _clientSecretController,
                obscureText: true,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_submitting) _connect();
                },
                decoration: InputDecoration(
                  labelText: l10n.loginClientSecret,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _submitting ? null : _connect,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.connectToFoodie),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
