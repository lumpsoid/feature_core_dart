/// {@template shell_effect_handler}
/// Abstract class that encapsulates all async effect logic for a feature.
///
/// Subclasses hold the feature's external dependencies (repositories, services)
/// as constructor-injected fields and implement [run] as a switch over the
/// sealed [E] hierarchy.
///
/// Type parameters:
/// - [E]  Effect     — sealed class of async work requests
/// - [A]  Action     — actions dispatched back into the reducer
/// {@endtemplate}
abstract class EffectHandler<E, A> {
  /// {@macro shell_effect_handler}
  const EffectHandler();

  /// Processes the given [effect] asynchronously.
  ///
  /// The [dispatch] callback is used to dispatch actions to the reducer.
  Future<void> run(
    E effect, {
    required void Function(A) dispatch,
  });
}
