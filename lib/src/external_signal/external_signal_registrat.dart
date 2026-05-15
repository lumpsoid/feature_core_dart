import 'dart:async';

import 'package:feature_core/src/external_signal/external_signal_listener.dart';

/// {@template cancellation_token}
/// A read-only view of a cancellation signal.
///
/// Usage patterns:
///
/// **Await-based (recommended):**
/// ```dart
/// await Future.any([myHeavySetup(), token.signal]);
/// if (token.isCancelled) return; // bail before registering anything
/// ```
///
/// **Poll-based (inside loops):**
/// ```dart
/// for (final step in steps) {
///   if (token.isCancelled) return;
///   await step();
/// }
/// ```
/// {@endtemplate}
class CancellationToken {
  /// {@macro cancellation_token}
  CancellationToken() : _completer = Completer<void>();

  final Completer<void> _completer;

  /// Whether cancellation has been requested.
  bool get isCancelled => _completer.isCompleted;

  /// A [Future] that completes when cancellation is requested.
  ///
  /// Compose with [Future.any] to race your work against cancellation:
  /// ```dart
  /// await Future.any([doWork(), token.signal]);
  /// ```
  Future<void> get signal => _completer.future;

  /// Triggers cancellation. Safe to call multiple times.
  void _cancel() {
    if (!_completer.isCompleted) _completer.complete();
  }
}

enum _Phase { idle, attaching, attached, detaching }

class ExternalSignalRegistrat<A> {
  ExternalSignalRegistrat(
    List<ExternalSignalListener<A>> listeners, {
    void Function(ExternalSignalListener<A>, Object error, StackTrace)? onError,
  }) : _listeners = List.unmodifiable(listeners),
       _onError = onError;

  final List<ExternalSignalListener<A>> _listeners;
  final void Function(ExternalSignalListener<A>, Object, StackTrace)? _onError;

  _Phase _phase = _Phase.idle;

  // Per-cycle state — reset on every return to idle.
  final List<CancellationToken> _tokens = [];
  Completer<void>? _attachCompleter;
  Completer<void>? _detachCompleter;

  /// Starts a new attach cycle.
  ///
  /// If a detach wave is still draining from the previous cycle, attachment
  /// will begin only after it fully completes.
  /// No-op if already attaching or attached.
  void onAttach(void Function(A) dispatch) {
    if (_phase != _Phase.idle) return;

    _phase = _Phase.attaching;
    _attachCompleter = Completer<void>();
    unawaited(_runAttachWave(dispatch));
  }

  /// Cancels in-flight attachments and starts detaching all started listeners
  /// in the background.
  ///
  /// No-op if idle or already detaching.
  void onDetach() {
    if (_phase != _Phase.attaching && _phase != _Phase.attached) return;

    _phase = _Phase.detaching;
    _detachCompleter = Completer<void>();

    for (final token in _tokens) {
      token._cancel();
    }

    unawaited(_runDetachWave());
  }

  Future<void> _runAttachWave(void Function(A) dispatch) async {
    // If a previous detach wave is still draining, wait for it to finish
    // before starting the new attach cycle.
    if (_detachCompleter != null) {
      await _detachCompleter!.future;
    }

    await Future.wait(
      _listeners.map((l) => _attachOne(l, dispatch)),
    );

    if (_phase == _Phase.attaching) _phase = _Phase.attached;
    _attachCompleter!.complete();
  }

  Future<void> _runDetachWave() async {
    // Wait for the attach wave to drain before detaching.
    await _attachCompleter!.future;

    await Future.wait(
      _listeners.take(_tokens.length).map(_detachOne),
    );

    // Reset all per-cycle state — registrar is ready for the next cycle.
    _tokens.clear();
    _attachCompleter = null;
    _detachCompleter!.complete();
    _detachCompleter = null;
    _phase = _Phase.idle;
  }

  Future<void> _attachOne(
    ExternalSignalListener<A> listener,
    void Function(A) dispatch,
  ) async {
    final token = CancellationToken();
    _tokens.add(token);
    try {
      await listener.onAttach(dispatch, token);
    } on Exception catch (e, st) {
      _onError?.call(listener, e, st);
    }
  }

  Future<void> _detachOne(ExternalSignalListener<A> listener) async {
    try {
      await listener.onDetach();
    } on Exception catch (e, st) {
      _onError?.call(listener, e, st);
    }
  }
}
