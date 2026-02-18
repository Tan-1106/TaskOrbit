import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShellLayout extends StatefulWidget {
  final Widget child;

  const AppShellLayout({
    super.key,
    required this.child,
  });

  @override
  State<AppShellLayout> createState() => _AppShellLayoutState();
}

class _AppShellLayoutState extends State<AppShellLayout> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/agenda')) return 0;
    if (location.startsWith('/pomodoro')) return 1;
    if (location.startsWith('/profile')) return 2;

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/agenda');
        break;
      case 1:
        context.go('/pomodoro');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  String _getTitle(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return 'Agenda';
      case 1:
        return 'Pomodoro';
      case 2:
        return 'Profile';
      default:
        return 'Task Orbit';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(selectedIndex)),
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
