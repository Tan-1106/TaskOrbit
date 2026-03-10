enum ChildRoutes {
  taskDetail('/agenda/task-detail')
  ;

  final String path;

  const ChildRoutes(this.path);

  /// Checks if the given location matches any of the defined child routes, accounting for dynamic segments.
  static bool isChildRoute(String location) {
    final cleanLocation = location.split('?').first.split('#').first;

    for (final route in ChildRoutes.values) {
      // Direct match check
      if (cleanLocation == route.path) return true;

      // Convert route path to regex pattern
      final pattern = route.path.replaceAllMapped(
        RegExp(r':\w+'),
        (match) => r'[\w-]+',
      );

      // Check if the cleaned location matches the regex pattern for the route
      if (RegExp('^$pattern\$').hasMatch(cleanLocation)) return true;
    }

    return false;
  }
}
