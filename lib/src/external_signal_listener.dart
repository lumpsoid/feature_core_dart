/// {@template external_signal_listener}
/// Abstract class for listening to external signals (streams, platform
/// channels, push notifications, etc.) and translating them into actions
/// dispatched into the feature's reducer.
///
/// Lifecycle mirrors the view:
/// - [onAttach] is called when the view mounts; start subscriptions here.
/// - [onDetach] is called when the view disposes; cancel subscriptions here.
///
/// Implementations should be stateless except for the subscription handles
/// they manage internally.
///
/// Type parameters:
/// - [A] Action — the action type accepted by the feature's reducer.
/// {@endtemplate}
abstract class ExternalSignalListener<A> {
  /// {@macro external_signal_listener}
  const ExternalSignalListener();

  /// Called when the view attaches.
  ///
  /// Use [dispatch] to forward incoming signals as actions into the reducer.
  /// Await any async setup (e.g. subscribing to a stream) before returning.
  Future<void> onAttach(void Function(A) dispatch);

  /// Called when the view detaches.
  ///
  /// Cancel subscriptions and release resources before returning.
  Future<void> onDetach();
}
