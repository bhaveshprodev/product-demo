import 'dart:async';

/// Broadcasts "the session can no longer be recovered" from the network layer
/// to the presentation layer, which owns navigation.
///
/// Keeping this as a stream avoids a dependency cycle between `ApiClient` and
/// `AuthBloc`.
class SessionExpiryNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onExpired => _controller.stream;

  void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}
