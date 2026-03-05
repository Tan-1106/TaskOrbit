import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_orbit/core/common/enums/child_routes.dart';
import 'package:task_orbit/core/common/layout/shell_actions_notifier.dart';
import 'package:task_orbit/core/common/widgets/custom_app_bar.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

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
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/agenda')) return 0;
    if (location.startsWith('/pomodoro')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/agenda');
      case 1:
        context.go('/pomodoro');
      case 2:
        context.go('/profile');
    }
  }

  String _getTitle(BuildContext context, int selectedIndex) {
    final l10n = AppLocalizations.of(context)!;

    switch (selectedIndex) {
      case 0:
        return l10n.navAgenda;
      case 1:
        return l10n.navPomodoro;
      case 2:
        return l10n.navProfile;
      default:
        return l10n.shellTitleDefault;
    }
  }

  bool _shouldShowBackButton(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
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
    final l10n = AppLocalizations.of(context)!;
    final selectedIndex = _calculateSelectedIndex(context);
    final showBackButton = _shouldShowBackButton(context);

    return ListenableBuilder(
      listenable: _shellActions,
      builder: (context, _) {
        return Scaffold(
          appBar: CustomAppBar(
            title: _getTitle(context, selectedIndex),
            onBack: showBackButton ? () => _onBackPressed(context) : null,
            actions: _shellActions.actions.isNotEmpty ? _shellActions.actions : null,
          ),
          body: ShellActionsScope(
            notifier: _shellActions,
            child: widget.child,
          ),
          floatingActionButton: _shellActions.fab,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => _onItemTapped(index, context),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today),
                label: l10n.navAgenda,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.timer),
                label: l10n.navPomodoro,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: l10n.navProfile,
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        );
      },
    );
  }
}

/// Gives child pages access to [ShellActionsNotifier].
class ShellActionsScope extends InheritedWidget {
  final ShellActionsNotifier notifier;

  const ShellActionsScope({
    super.key,
    required this.notifier,
    required super.child,
  });

  static ShellActionsNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShellActionsScope>();
    assert(scope != null, 'No ShellActionsScope found in widget tree');
    return scope!.notifier;
  }

  @override
  bool updateShouldNotify(ShellActionsScope oldWidget) => notifier != oldWidget.notifier;
}
