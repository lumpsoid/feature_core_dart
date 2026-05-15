import 'dart:async';

import 'package:feature_core/src/external_signal/external_signal_listener.dart';
import 'package:feature_core/src/external_signal/external_signal_registrat.dart';
import 'package:feature_core/src/shell_effect_handler.dart';
import 'package:feature_core/src/state_holder.dart';
import 'package:feature_core/src/updater.dart';

/// {@template feature_controller}
/// Generic controller base for MVI feature modules.
///
/// Subclasses only need to:
/// 1. Pass the feature's [Updater] and a [EffectHandler] to `super`.
/// 2. Expose a typed constructor that builds those two objects.
/// 3. Optionally supply [_externalSignalRegistrat] for external event sources.
///
/// Type parameters:
/// - [S]  State
/// - [A]  Action
/// - [E] ShellEffect
/// {@endtemplate}
abstract base class FeatureController<S, A, E> {
  /// {@macro feature_controller}
  FeatureController({
    required StateHolder<S> stateHolder,
    required Updater<S, A, E> updater,
    required EffectHandler<E, A> shellHandler,
    ExternalSignalRegistrat<A>? externalSignalRegistrat,
  }) : _stateHolder = stateHolder,
       _updater = updater,
       _shellHandler = shellHandler,
       _externalSignalRegistrat = externalSignalRegistrat;

  final Updater<S, A, E> _updater;
  final EffectHandler<E, A> _shellHandler;
  final ExternalSignalRegistrat<A>? _externalSignalRegistrat;
  final StateHolder<S> _stateHolder;

  /// Attaches the controller to a view.
  void onAttach() {
    if (_externalSignalRegistrat != null) {
      _externalSignalRegistrat.onAttach(dispatch);
    }
  }

  /// Detaches the controller from the view.
  ///
  /// Calls [ExternalSignalListener.onDetach] on all signal listeners, and
  /// detaches the view state binder and side effector, clearing any resources
  /// tied to the view.
  void onDetach() {
    if (_externalSignalRegistrat != null) {
      _externalSignalRegistrat.onDetach();
    }
  }

  /// Fire-and-forget dispatch — used by UI event handlers.
  ///
  /// Sends an [action] to the feature without waiting for its completion.
  void dispatch(A action) => unawaited(dispatchAsync(action));

  /// Awaitable dispatch
  ///
  /// Processes the [action] through the [_updater], updates the state, and
  /// runs any resulting shell effects via the [_shellHandler]. The returned
  /// [Future] completes after the action and all shell effects have been
  /// handled.
  Future<void> dispatchAsync(A action) async {
    final (next, shellEffects) = _updater.update(_stateHolder.state, action);
    _stateHolder.update(next);
    if (shellEffects != null) {
      for (final effect in shellEffects) {
        await _shellHandler.run(
          effect,
          dispatch: dispatch,
        );
      }
    }
  }
}
