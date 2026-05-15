/// {@template updater}
/// Pure reducer as an abstract class.
///
/// Implementors hold no mutable state; [update] maps
/// (currentState, action) → (nextState, shellEffects?).
///
/// Type parameters:
/// - [S]  State
/// - [A]  Action
/// - [E] ShellEffect
/// {@endtemplate}
abstract class Updater<S, A, E> {
  /// {@macro updater}
  const Updater();

  /// Computes the next state and optional shell effects from the current state
  /// and an action.
  ///
  /// Implementors must treat this as a pure function: it should not cause side
  /// effects, and any effects intended for the shell are returned in the list
  /// of effects.
  ///
  /// Returns a tuple `(nextState, effects?)`, where `nextState` is the
  /// resulting state, and `shellEffects` is an optional list of effects to be
  /// processed by the shell.
  (S, List<E>?) update(S state, A action);
}
