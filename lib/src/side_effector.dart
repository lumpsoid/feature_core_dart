import 'typedefs.dart';

/// Bridges the controller to the view's side-effect callback.
/// Detached by default; attach on view mount, detach on view dispose.
class SideEffector<E> {
  SideEffectPusher<E>? _pusher;

  void attach(SideEffectPusher<E> pusher) => _pusher = pusher;

  void detach() => _pusher = null;

  /// Pushes a UI side-effect. No-ops if detached.
  Future<void> push(E effect) async => _pusher?.call(effect);
}
