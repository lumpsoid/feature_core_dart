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
abstract class ShellEffectHandler<SE, A, E> {
  const ShellEffectHandler();

  Future<void> run(
    SE effect, {
    required void Function(A) dispatch,
    required void Function(E) pushEffect,
  });
}
