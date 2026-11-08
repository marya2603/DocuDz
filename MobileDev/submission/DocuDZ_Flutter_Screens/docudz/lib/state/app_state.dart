import 'package:flutter/widgets.dart';

import '../data/progress_store.dart';
import '../models/models.dart';

/// Single source of truth for UI state. Plain ChangeNotifier: no extra
/// state-management package needed for an app of this size.
class AppState extends ChangeNotifier {
  AppState({
    required this.catalog,
    required ProgressStore store,
    Locale? locale,
    DateTime Function()? clock,
    this.lastServiceId,
  }) : _store = store,
       _clock = clock ?? DateTime.now,
       _ticks = store.loadTicks(),
       _locale = locale ?? Locale(store.loadLanguage() ?? 'fr');

  static const supportedLocales = [Locale('ar'), Locale('fr'), Locale('en')];

  final Catalog catalog;
  final ProgressStore _store;
  final DateTime Function() _clock;
  final Map<String, Set<String>> _ticks;

  Locale _locale;
  Locale get locale => _locale;

  /// Service the user opened most recently ("Continue where you left off").
  String? lastServiceId;

  /// Calculator state (session only, not persisted).
  final Map<String, int> _feeQty = {};
  final Map<String, bool> _feeEnabled = {};

  /// Tab selections shared between Home quick-links and bottom navigation.
  String costsServiceId = 'passport';
  String officesServiceId = 'passport';
  String wilayaCode = '16';

  DateTime now() => _clock();

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    _store.saveLanguage(locale.languageCode);
    notifyListeners();
  }

  // ---- Checklist -----------------------------------------------------------
  bool isTicked(String serviceId, String docId) => _ticks[serviceId]?.contains(docId) ?? false;

  void toggle(String serviceId, String docId) => setTicked(serviceId, docId, !isTicked(serviceId, docId));

  void setTicked(String serviceId, String docId, bool value) {
    final set = _ticks.putIfAbsent(serviceId, () => <String>{});
    value ? set.add(docId) : set.remove(docId);
    _store.saveTick(serviceId, docId, value);
    lastServiceId = serviceId;
    notifyListeners();
  }

  int doneCount(Service s) => s.documents.where((d) => isTicked(s.id, d.id)).length;

  double progress(Service s) => s.documents.isEmpty ? 0 : doneCount(s) / s.documents.length;

  DocumentItem? nextMissing(Service s) {
    for (final d in s.documents) {
      if (!isTicked(s.id, d.id)) return d;
    }
    return null;
  }

  void openService(String serviceId) {
    lastServiceId = serviceId;
    costsServiceId = serviceId;
    officesServiceId = serviceId;
    notifyListeners();
  }

  // ---- Calculator ----------------------------------------------------------
  int qtyOf(FeeItem f) => _feeQty[f.id] ?? f.qty;
  bool enabledOf(FeeItem f) => !f.optional || (_feeEnabled[f.id] ?? f.enabledByDefault);

  void setQty(FeeItem f, int qty) {
    _feeQty[f.id] = qty.clamp(0, 99);
    notifyListeners();
  }

  void setEnabled(FeeItem f, bool enabled) {
    _feeEnabled[f.id] = enabled;
    notifyListeners();
  }

  int lineTotal(FeeItem f) => enabledOf(f) ? f.amount * qtyOf(f) : 0;

  int subtotal(Service s, {required bool official}) =>
      s.fees.where((f) => f.isOfficial == official).fold(0, (sum, f) => sum + lineTotal(f));

  int total(Service s) => s.fees.fold(0, (sum, f) => sum + lineTotal(f));

  void selectCostsService(String id) {
    costsServiceId = id;
    notifyListeners();
  }

  void selectOfficesService(String id) {
    officesServiceId = id;
    notifyListeners();
  }

  void selectWilaya(String code) {
    wilayaCode = code;
    notifyListeners();
  }
}

/// Exposes [AppState] to the widget tree and rebuilds dependents on change.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
