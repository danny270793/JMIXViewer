import 'package:flutter/material.dart';

/// Bottom bar with previous/next and a center summary line.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous page',
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: 'Next page',
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
