import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/jmix/jmix_api_exception.dart';
import '../auth/foodie_session.dart';
import '../router/app_router.dart';

/// Obtains an access token via OAuth2 client credentials, then navigates home.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _submitting = false;

  Future<void> _connect() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await FoodieSession.instance.signInWithClientCredentials();
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
        SnackBar(content: Text('Connection failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
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
                'Welcome back',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect to Foodie using OAuth2 client credentials. '
                'The app requests an access token, then sends it as '
                'Authorization: Bearer on API calls.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
                    : const Text('Connect to Foodie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
