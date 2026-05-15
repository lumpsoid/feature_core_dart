import 'package:feature_core/src/state_holder.dart';

class TombstoneStateHolder<S> extends StateHolder<S> {
  TombstoneStateHolder(S initial) : _state = initial;

  S _state;
  final List<void Function(S)?> _listeners = [];
  int _notifyDepth = 0;
  bool _hasTombstones = false;

  @override
  S get state => _state;

  @override
  void update(S next) {
    _state = next;
    if (_listeners.isEmpty) return;
    _notify(next);
  }

  void _notify(S state) {
    _notifyDepth++;
    try {
      for (var i = 0; i < _listeners.length; i++) {
        _listeners[i]?.call(state);
      }
    } finally {
      _notifyDepth--;
      if (_notifyDepth == 0 && _hasTombstones) {
        _listeners.removeWhere((cb) => cb == null);
        _hasTombstones = false;
      }
    }
  }

  @override
  void addListener(void Function(S) listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(void Function(S) listener) {
    final idx = _listeners.indexOf(listener);
    if (idx == -1) return;
    if (_notifyDepth > 0) {
      _listeners[idx] = null;
      _hasTombstones = true;
    } else {
      _listeners.removeAt(idx);
    }
  }
}
