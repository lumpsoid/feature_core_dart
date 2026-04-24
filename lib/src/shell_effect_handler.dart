/// {@template shell_effect_handler}
/// Abstract class that encapsulates all async shell-effect logic for a feature.
///
/// Subclasses hold the feature's external dependencies (repositories, services)
/// as constructor-injected fields and implement [run] as a switch over the
/// sealed [SE] hierarchy.
///
/// Type parameters:
/// - [SE] ShellEffect  — sealed class of async work requests
/// - [A]  Action       — actions dispatched back into the reducer
/// - [E]  Effect       — UI-only side-effects pushed to the view
/// {@endtemplate}
abstract class ShellEffectHandler<SE, A, E> {
  /// {@macro shell_effect_handler}
  const ShellEffectHandler();

  /// Processes the given [effect] asynchronously.
  ///
  /// The [dispatch] callback is used to dispatch actions to the reducer,
  /// and [pushEffect] is used to push UI-only side-effects to the view.
  ///
  /// Subclasses must implement this method to handle the different
  /// subtypes of [SE] (the sealed shell-effect hierarchy).
  Future<void> run(
    SE effect, {
    required void Function(A) dispatch,
    required void Function(E) pushEffect,
  });
}
