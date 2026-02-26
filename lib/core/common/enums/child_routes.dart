enum ChildRoutes {
  taskDetail('/agenda/task-detail')
  ;

  final String path;

  const ChildRoutes(this.path);

  static bool isChildRoute(String location) {
    final cleanLocation = location.split('?').first.split('#').first;

    for (final route in ChildRoutes.values) {
      if (cleanLocation == route.path) return true;
      final pattern = route.path.replaceAllMapped(
        RegExp(r':\w+'),
        (match) => r'[\w-]+',
      );
      if (RegExp('^$pattern\$').hasMatch(cleanLocation)) return true;
    }

    return false;
  }
}
