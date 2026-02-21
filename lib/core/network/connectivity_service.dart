import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provides a reactive stream of internet connectivity status.
/// Used by repositories to decide online/offline data strategy.
class ConnectivityService {
  final Connectivity _connectivity;
  late final StreamController<bool> _controller;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _controller = StreamController<bool>.broadcast();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(_isConnected(results));
    });
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Check current connectivity (one-shot)
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
