/// Returns the current state snapshot.
typedef StateGetter<S> = S Function();

/// Pushes a new state snapshot to the view.
typedef StateUpdater<S> = void Function(S state);
