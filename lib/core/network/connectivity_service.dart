import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provides a reactive stream of connectivity status.
class ConnectivityService {
  final Connectivity _connectivity;
  late final StreamController<bool> _controller;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity() {
    _controller = StreamController<bool>.broadcast();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(_isConnected(results));
    });
  }

  Stream<bool> get onConnectivityChanged => _controller.stream;

  // Checks the current connectivity status and returns true if connected to any network.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  // Helper method to determine if any of the connectivity results indicate an active connection.
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) => r == ConnectivityResult.wifi || r == ConnectivityResult.mobile || r == ConnectivityResult.ethernet);
  }

  // Clean up resources by canceling the subscription and closing the stream controller.
  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
