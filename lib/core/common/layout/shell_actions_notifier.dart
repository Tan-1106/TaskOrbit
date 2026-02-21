import 'package:flutter/material.dart';

/// Holds per-page shell customizations (actions, FAB) that child pages
/// can inject into the parent [AppShellLayout].
class ShellActionsNotifier extends ChangeNotifier {
  List<Widget> _actions = [];
  Widget? _fab;

  List<Widget> get actions => _actions;
  Widget? get fab => _fab;

  void setActions(List<Widget> actions) {
    _actions = actions;
    notifyListeners();
  }

  void setFab(Widget? fab) {
    _fab = fab;
    notifyListeners();
  }

  void clear() {
    _actions = [];
    _fab = null;
    notifyListeners();
  }
}
