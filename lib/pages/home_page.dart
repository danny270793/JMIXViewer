import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/foodie_session.dart';
import '../router/app_router.dart';

/// Shown after a successful Foodie / Jmix sign-in.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = FoodieSession.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('JMIX Viewer'),
        actions: [
          TextButton(
            onPressed: () {
              session.signOut();
              context.go(AppRoutes.login);
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Connected to Foodie',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You are signed in. Access token is active for API calls.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
