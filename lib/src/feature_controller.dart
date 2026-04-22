import 'dart:async';

import 'package:feature_core/src/shell_effect_handler.dart';
import 'package:feature_core/src/side_effector.dart';
import 'package:feature_core/src/typedefs.dart';
import 'package:feature_core/src/view_state_binder.dart';

/// Generic controller base for MVI feature modules.
///
/// Subclasses only need to:
/// 1. Pass the feature's pure [UpdateFn] and a [ShellEffectHandler] to `super`.
/// 2. Expose a typed constructor that builds those two objects.
///
/// Type parameters:
/// - [S]  State
/// - [A]  Action
/// - [SE] ShellEffect
/// - [E]  UI Effect
abstract base class FeatureController<S, A, SE, E> {
  FeatureController({
    required UpdateFn<S, A, SE> update,
    required ShellEffectHandler<SE, A, E> shellHandler,
    ViewStateBinder<S>? viewBinding,
    SideEffector<E>? effectPusher,
  }) : _update = update,
       _shellHandler = shellHandler,
       _viewBinding = viewBinding ?? ViewStateBinder<S>(),
       _effectPusher = effectPusher ?? SideEffector<E>();

  final UpdateFn<S, A, SE> _update;
  final ShellEffectHandler<SE, A, E> _shellHandler;
  final ViewStateBinder<S> _viewBinding;
  final SideEffector<E> _effectPusher;

  // View lifecycle

  void onViewAttach({
    required StateGetter<S> getter,
    required StateUpdater<S> updater,
    required SideEffectPusher<E> pusher,
  }) {
    _viewBinding.attach(getter, updater);
    _effectPusher.attach(pusher);
  }

  void onViewDetach() {
    _viewBinding.detach();
    _effectPusher.detach();
  }

  // Dispatch

  /// Fire-and-forget dispatch — used by UI event handlers.
  void dispatch(A action) => unawaited(dispatchAsync(action));

  /// Awaitable dispatch — used in tests or when sequencing matters.
  Future<void> dispatchAsync(A action) async {
    final (next, shellEffects) = _update(_viewBinding.state, action);
    _viewBinding.update(next);
    if (shellEffects != null) {
      for (final effect in shellEffects) {
        await _shellHandler.run(
          effect,
          dispatch: dispatch,
          pushEffect: _effectPusher.push,
        );
      }
    }
  }
}
