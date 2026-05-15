import 'package:feature_core/src/external_signal/external_signal_registrat.dart';

/// {@template external_signal_listener}
/// Abstract class for listening to external signals (streams, platform
/// channels, push notifications, etc.) and translating them into actions
/// dispatched into the feature's reducer.
///
/// Lifecycle:
/// - [onAttach] is called when the view mounts; start subscriptions here.
///   A [CancellationToken] is provided - check it or race against
///   [CancellationToken.signal] to abort expensive setup early if the
///   controller detaches before attachment completes.
/// - [onDetach] is called when the view disposes **or** when attachment
///   was cancelled mid-flight. Always release resources here, even if
///   [onAttach] did not fully complete.
///
/// Implementations should be stateless except for the subscription handles
/// they manage internally.
///
/// Type parameters:
/// - [A] Action - the action type accepted by the feature's reducer.
/// {@endtemplate}
abstract class ExternalSignalListener<A> {
  /// {@macro external_signal_listener}
  const ExternalSignalListener();

  /// Called when the view attaches.
  ///
  /// [dispatch] forwards incoming signals as actions into the reducer.
  /// [cancellationToken] signals early abort - check
  /// [CancellationToken.isCancelled] or race against [CancellationToken.signal]
  /// before committing resources.
  ///
  /// [onDetach] will always be called after this, even if cancelled.
  Future<void> onAttach(
    void Function(A) dispatch,
    CancellationToken cancellationToken,
  );

  /// Called when the view detaches or when attachment was cancelled.
  ///
  /// Cancel subscriptions and release any resources acquired (even partially)
  /// during [onAttach].
  Future<void> onDetach();
}
