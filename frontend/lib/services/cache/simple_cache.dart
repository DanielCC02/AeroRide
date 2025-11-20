// lib/services/cache/simple_cache.dart
class SimpleCache<K, V> {
  final Duration ttl;
  final int maxEntries;

  SimpleCache({this.ttl = const Duration(minutes: 5), this.maxEntries = 200});

  final Map<K, _Entry<V>> _store = {};

  V? get(K key) {
    final e = _store[key];
    if (e == null) return null;
    if (DateTime.now().isAfter(e.expiresAt)) {
      _store.remove(key);
      return null;
    }
    return e.value;
  }

  void set(K key, V value) {
    if (_store.length >= maxEntries) {
      // Evict el primero (naive)
      _store.remove(_store.keys.first);
    }
    _store[key] = _Entry(value, DateTime.now().add(ttl));
  }

  void invalidate(K key) => _store.remove(key);
  void clear() => _store.clear();
}

class _Entry<V> {
  final V value;
  final DateTime expiresAt;
  _Entry(this.value, this.expiresAt);
}
