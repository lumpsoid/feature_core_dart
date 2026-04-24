/// Returns the current state snapshot.
typedef StateGetter<S> = S Function();

/// Pushes a new state snapshot to the view.
typedef StateUpdater<S> = void Function(S state);

/// Pushes a UI side-effect to the view.
typedef SideEffectPusher<E> = Future<void> Function(E effect);
