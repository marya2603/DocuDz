// Domain models for DocuDZ content (read-only, bundled with the app).
import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';

/// A string available in the three app languages (ar, fr, en).
class LocalizedText {
  const LocalizedText(this.values);

  factory LocalizedText.fromJson(Object? json) {
    if (json is Map) {
      return LocalizedText(json.map((k, v) => MapEntry(k as String, v as String)));
    }
    return const LocalizedText({});
  }

  final Map<String, String> values;

  String of(Locale locale) => values[locale.languageCode] ?? values['en'] ?? '';

  bool contains(String query) {
    final q = query.toLowerCase();
    return values.values.any((v) => v.toLowerCase().contains(q));
  }
}

LocalizedText? _optText(Object? json) => json == null ? null : LocalizedText.fromJson(json);

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.copies,
    required this.name,
    required this.issuedBy,
    required this.where,
    this.tip,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> j) => DocumentItem(
    id: j['id'] as String,
    copies: (j['copies'] as num?)?.toInt() ?? 1,
    name: LocalizedText.fromJson(j['name']),
    issuedBy: LocalizedText.fromJson(j['issuedBy']),
    where: LocalizedText.fromJson(j['where']),
    tip: _optText(j['tip']),
  );

  final String id;
  final int copies;
  final LocalizedText name;
  final LocalizedText issuedBy;
  final LocalizedText where;
  final LocalizedText? tip;
}

enum FeeCategory { stamp, fee, other }

class FeeItem {
  const FeeItem({
    required this.id,
    required this.category,
    required this.amount,
    required this.label,
    this.qty = 1,
    this.adjustable = false,
    this.optional = false,
    this.enabledByDefault = true,
    this.unit,
    this.note,
  });

  factory FeeItem.fromJson(Map<String, dynamic> j) => FeeItem(
    id: j['id'] as String,
    category: FeeCategory.values.byName(j['category'] as String),
    amount: (j['amount'] as num).toInt(),
    label: LocalizedText.fromJson(j['label']),
    qty: (j['qty'] as num?)?.toInt() ?? 1,
    adjustable: j['adjustable'] as bool? ?? false,
    optional: j['optional'] as bool? ?? false,
    enabledByDefault: j['enabled'] as bool? ?? true,
    unit: _optText(j['unit']),
    note: _optText(j['note']),
  );

  final String id;
  final FeeCategory category;

  /// Unit price in DZD.
  final int amount;
  final LocalizedText label;
  final int qty;
  final bool adjustable;
  final bool optional;
  final bool enabledByDefault;
  final LocalizedText? unit;
  final LocalizedText? note;

  bool get isOfficial => category != FeeCategory.other;
}

class ProcessStep {
  const ProcessStep({required this.title, required this.place, required this.detail, this.tip});

  factory ProcessStep.fromJson(Map<String, dynamic> j) => ProcessStep(
    title: LocalizedText.fromJson(j['title']),
    place: LocalizedText.fromJson(j['place']),
    detail: LocalizedText.fromJson(j['detail']),
    tip: _optText(j['tip']),
  );

  final LocalizedText title;
  final LocalizedText place;
  final LocalizedText detail;
  final LocalizedText? tip;
}

/// Opening time range on a given day, in minutes since midnight.
class TimeRange {
  const TimeRange(this.start, this.end);

  factory TimeRange.parse(String s) {
    final parts = s.split('-');
    return TimeRange(_minutes(parts[0]), _minutes(parts[1]));
  }

  static int _minutes(String hhmm) {
    final p = hhmm.trim().split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  final int start;
  final int end;

  static String format(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  String get startLabel => format(start);
  String get endLabel => format(end);

  bool contains(int minutes) => minutes >= start && minutes < end;
}

enum OpenState { openNow, closedNow, closedToday }

class Office {
  const Office({
    required this.wilaya,
    required this.lat,
    required this.lng,
    required this.name,
    required this.address,
    required this.hours,
  });

  static const _days = {
    'mon': DateTime.monday,
    'tue': DateTime.tuesday,
    'wed': DateTime.wednesday,
    'thu': DateTime.thursday,
    'fri': DateTime.friday,
    'sat': DateTime.saturday,
    'sun': DateTime.sunday,
  };

  factory Office.fromJson(Map<String, dynamic> j) {
    final raw = (j['hours'] as Map<String, dynamic>? ?? const {});
    return Office(
      wilaya: j['wilaya'] as String,
      lat: (j['lat'] as num).toDouble(),
      lng: (j['lng'] as num).toDouble(),
      name: LocalizedText.fromJson(j['name']),
      address: LocalizedText.fromJson(j['address']),
      hours: {for (final e in raw.entries) _days[e.key]!: TimeRange.parse(e.value as String)},
    );
  }

  final String wilaya;
  final double lat;
  final double lng;
  final LocalizedText name;
  final LocalizedText address;

  /// Keyed by [DateTime.weekday]. Missing day = closed.
  final Map<int, TimeRange> hours;

  OpenState stateAt(DateTime now) {
    final today = hours[now.weekday];
    if (today == null) return OpenState.closedToday;
    return today.contains(now.hour * 60 + now.minute) ? OpenState.openNow : OpenState.closedNow;
  }
}

class Wilaya {
  const Wilaya({required this.code, required this.name});

  factory Wilaya.fromJson(Map<String, dynamic> j) =>
      Wilaya(code: j['code'] as String, name: LocalizedText.fromJson(j['name']));

  final String code;
  final LocalizedText name;
}

enum ServiceIcon { school, passport, car, health }

class Service {
  const Service({
    required this.id,
    required this.icon,
    required this.tone,
    required this.lastVerified,
    required this.estimatedVisits,
    required this.title,
    required this.shortTitle,
    required this.subtitle,
    required this.officeKind,
    required this.documents,
    required this.fees,
    required this.steps,
    required this.offices,
  });

  factory Service.fromJson(Map<String, dynamic> j) => Service(
    id: j['id'] as String,
    icon: ServiceIcon.values.byName(j['icon'] as String),
    tone: ServiceTone.fromName(j['tone'] as String),
    lastVerified: DateTime.parse(j['lastVerified'] as String),
    estimatedVisits: (j['estimatedVisits'] as num?)?.toInt() ?? 1,
    title: LocalizedText.fromJson(j['title']),
    shortTitle: LocalizedText.fromJson(j['short'] ?? j['title']),
    subtitle: LocalizedText.fromJson(j['subtitle']),
    officeKind: LocalizedText.fromJson(j['officeKind']),
    documents: [for (final d in j['documents'] as List) DocumentItem.fromJson(d as Map<String, dynamic>)],
    fees: [for (final f in j['fees'] as List) FeeItem.fromJson(f as Map<String, dynamic>)],
    steps: [for (final s in j['steps'] as List) ProcessStep.fromJson(s as Map<String, dynamic>)],
    offices: [for (final o in j['offices'] as List) Office.fromJson(o as Map<String, dynamic>)],
  );

  final String id;
  final ServiceIcon icon;
  final ServiceTone tone;
  final DateTime lastVerified;
  final int estimatedVisits;
  final LocalizedText title;
  final LocalizedText shortTitle;
  final LocalizedText subtitle;
  final LocalizedText officeKind;
  final List<DocumentItem> documents;
  final List<FeeItem> fees;
  final List<ProcessStep> steps;
  final List<Office> offices;

  Office? officeIn(String wilayaCode) {
    for (final o in offices) {
      if (o.wilaya == wilayaCode) return o;
    }
    return offices.isEmpty ? null : offices.first;
  }
}

class ContentMeta {
  const ContentMeta({required this.version, required this.lastUpdate, required this.illustrative});

  factory ContentMeta.fromJson(Map<String, dynamic> j) => ContentMeta(
    version: j['contentVersion'] as String,
    lastUpdate: DateTime.parse(j['lastContentUpdate'] as String),
    illustrative: j['illustrative'] as bool? ?? false,
  );

  final String version;
  final DateTime lastUpdate;
  final bool illustrative;
}

/// Everything the app shows, loaded once at start-up.
class Catalog {
  const Catalog({required this.meta, required this.wilayas, required this.services});

  factory Catalog.fromJson(Map<String, dynamic> j) => Catalog(
    meta: ContentMeta.fromJson(j['meta'] as Map<String, dynamic>),
    wilayas: [for (final w in j['wilayas'] as List) Wilaya.fromJson(w as Map<String, dynamic>)],
    services: [for (final s in j['services'] as List) Service.fromJson(s as Map<String, dynamic>)],
  );

  final ContentMeta meta;
  final List<Wilaya> wilayas;
  final List<Service> services;

  Service service(String id) => services.firstWhere((s) => s.id == id);
}
