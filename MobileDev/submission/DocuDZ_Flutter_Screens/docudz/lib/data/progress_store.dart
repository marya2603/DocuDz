// Persistence for the only user data DocuDZ keeps: ticked documents and the
// chosen language. No account, no server.
//
// The UI depends on this interface only. v1 will ship a SQLite-backed
// implementation (two tiny tables: `ticks(service_id, doc_id)` and
// `prefs(key, value)`); the in-memory version below backs the UI prototype
// and the screenshot tests.
abstract class ProgressStore {
  Map<String, Set<String>> loadTicks();
  void saveTick(String serviceId, String docId, bool ticked);
  String? loadLanguage();
  void saveLanguage(String code);
}

class InMemoryProgressStore implements ProgressStore {
  InMemoryProgressStore({Map<String, Set<String>>? seed, String? initialLanguage})
    : _ticks = {
        for (final e in (seed ?? const {}).entries) e.key: {...e.value},
      },
      _language = initialLanguage;

  final Map<String, Set<String>> _ticks;
  String? _language;

  @override
  Map<String, Set<String>> loadTicks() => {
    for (final e in _ticks.entries) e.key: {...e.value},
  };

  @override
  void saveTick(String serviceId, String docId, bool ticked) {
    final set = _ticks.putIfAbsent(serviceId, () => <String>{});
    ticked ? set.add(docId) : set.remove(docId);
  }

  @override
  String? loadLanguage() => _language;

  @override
  void saveLanguage(String code) => _language = code;
}
