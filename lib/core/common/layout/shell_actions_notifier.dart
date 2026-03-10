import 'package:flutter/material.dart';

class ShellActionsNotifier extends ChangeNotifier {
  List<Widget> _actions = [];
  Widget? _fab;

  List<Widget> get actions => _actions;

  Widget? get fab => _fab;

  // Updates the list of action widgets and notifies listeners to rebuild the UI.
  void setActions(List<Widget> actions) {
    _actions = actions;
    notifyListeners();
  }

  // Updates the FAB widget and notifies listeners to rebuild the UI.
  void setFab(Widget? fab) {
    _fab = fab;
    notifyListeners();
  }

  // Clears the actions and FAB, resetting them to their default state, and notifies listeners to rebuild the UI.
  void clear() {
    _actions = [];
    _fab = null;
    notifyListeners();
  }
}
