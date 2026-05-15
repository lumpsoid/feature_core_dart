abstract class StateHolder<S> {
  S get state;
  void update(S next);

  void addListener(void Function(S) listener);
  void removeListener(void Function(S) listener);
}
