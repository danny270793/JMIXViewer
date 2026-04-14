import 'package:flutter/widgets.dart';

import '../logging/app_logger.dart';

/// Logs each [Navigator] transition in debug mode (route type + from/to paths).
final class NavigationLogObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.logNavigation(
      'push',
      _describeRoute(previousRoute),
      _describeRoute(route),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppLogger.logNavigation(
      'pop',
      _describeRoute(route),
      _describeRoute(previousRoute),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppLogger.logNavigation(
      'replace',
      _describeRoute(oldRoute),
      _describeRoute(newRoute),
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    AppLogger.logNavigation(
      'remove',
      _describeRoute(route),
      _describeRoute(previousRoute),
    );
  }

  static String _describeRoute(Route<dynamic>? route) {
    if (route == null) return '∅';
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;
    final args = route.settings.arguments;
    if (args != null) return args.toString();
    return route.runtimeType.toString();
  }
}
