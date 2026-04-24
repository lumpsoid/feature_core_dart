import 'package:feature_core/src/typedefs.dart';

/// Bridges the controller to the view's side-effect callback.
/// Detached by default; attach on view mount, detach on view dispose.
class SideEffector<E> {
  SideEffectPusher<E>? _pusher;

  /// Attaches a [SideEffectPusher] to this effector.
  /// After attachment, calls to [push] will forward effects to the attached
  /// pusher.
  /// This should be called when the view is mounted.
  // ignore: use_setters_to_change_properties
  void attach(SideEffectPusher<E> pusher) => _pusher = pusher;

  /// Detaches the [SideEffectPusher] from this effector.
  /// After detachment, calls to [push] will no-op.
  /// This should be called when the view is disposed.
  void detach() => _pusher = null;

  /// Pushes a UI side-effect. No-ops if detached.
  Future<void> push(E effect) async => _pusher?.call(effect);
}
