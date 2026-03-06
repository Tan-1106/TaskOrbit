import 'package:flutter/material.dart';

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
