import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_orbit/core/common/enums/child_routes.dart';
import 'package:task_orbit/core/common/layout/shell_actions_notifier.dart';
import 'package:task_orbit/core/common/widgets/custom_app_bar.dart';

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
  final _shellActions = ShellActionsNotifier();

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

  bool _shouldShowBackButton(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    return ChildRoutes.isChildRoute(location);
  }

  void _onBackPressed(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/agenda');
    }
  }

  @override
  void dispose() {
    _shellActions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);
    final bool showBackButton = _shouldShowBackButton(context);

    return ListenableBuilder(
      listenable: _shellActions,
      builder: (context, _) {
        return Scaffold(
          appBar: CustomAppBar(
            title: _getTitle(selectedIndex),
            onBack: showBackButton ? () => _onBackPressed(context) : null,
            actions: _shellActions.actions.isNotEmpty
                ? _shellActions.actions
                : null,
          ),
          backgroundColor: Colors.white,
          body: ShellActionsScope(
            notifier: _shellActions,
            child: widget.child,
          ),
          floatingActionButton: _shellActions.fab,
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
      },
    );
  }
}

/// InheritedWidget that gives child pages access to [ShellActionsNotifier].
class ShellActionsScope extends InheritedWidget {
  final ShellActionsNotifier notifier;

  const ShellActionsScope({
    super.key,
    required this.notifier,
    required super.child,
  });

  static ShellActionsNotifier of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ShellActionsScope>();
    assert(scope != null, 'No ShellActionsScope found in widget tree');
    return scope!.notifier;
  }

  @override
  bool updateShouldNotify(ShellActionsScope oldWidget) =>
      notifier != oldWidget.notifier;
}
