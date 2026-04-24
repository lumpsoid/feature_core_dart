import 'package:feature_core/src/typedefs.dart';

/// Bridges the controller to the view's state read/write callbacks.
/// Detached by default; attach on view mount, detach on view dispose.
class ViewStateBinder<S> {
  StateGetter<S>? _getter;
  StateUpdater<S>? _updater;

  /// Attaches the getter and updater callbacks to this binder.
  ///
  /// The [getter] returns the current state from the view, and the [updater]
  /// pushes a new state to the view. After attaching, [state] and [update]
  /// become functional. This should be called when the view is mounted.
  void attach(StateGetter<S> getter, StateUpdater<S> updater) {
    _getter = getter;
    _updater = updater;
  }

  /// Detaches the binder from the view, clearing the stored callbacks.
  ///
  /// After detaching, [state] will throw a [StateError] and [update] will
  /// be a no-op. This should be called when the view is disposed.
  void detach() {
    _getter = null;
    _updater = null;
  }

  /// Returns the current state. Throws if not attached.
  S get state {
    final getter = _getter;
    if (getter == null) throw StateError('ViewStateBinder is not attached.');
    return getter();
  }

  /// Pushes a new state to the view. No-ops if detached.
  void update(S next) => _updater?.call(next);
}
