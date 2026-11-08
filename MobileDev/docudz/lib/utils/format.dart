import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/gen/app_localizations.dart';

/// Locale-aware formatting. Arabic uses the Algerian locale (ar_DZ) so that
/// digits stay Western (0-9) and month names follow local usage.
class Fmt {
  Fmt(this.locale, this.l10n);

  factory Fmt.of(BuildContext context) => Fmt(Localizations.localeOf(context), AppLocalizations.of(context));

  final Locale locale;
  final AppLocalizations l10n;

  String get _intlLocale => switch (locale.languageCode) {
    'ar' => 'ar_DZ',
    'fr' => 'fr',
    _ => 'en',
  };

  // U+202F (narrow no-break space) is not in the bundled fonts; use U+00A0.
  String _clean(String s) => s.replaceAll('\u202F', '\u00A0');

  // Amounts use space grouping (6 000) in French and Arabic, as commonly
  // printed in Algeria; English keeps 6,000.
  String number(int n) => _clean(NumberFormat.decimalPattern(locale.languageCode == 'en' ? 'en' : 'fr').format(n));

  String money(int amount) => '${number(amount)}\u00A0${l10n.currency}';

  /// "+6 000 DA". In Arabic a left-to-right mark keeps the sign attached to
  /// the left of the number instead of drifting to its right.
  String plusMoney(int amount) => '${locale.languageCode == 'ar' ? '\u200E' : ''}+${money(amount)}';

  String shortDate(DateTime d) => _clean(DateFormat.MMMd(_intlLocale).format(d));

  String longDate(DateTime d) => _clean(DateFormat.yMMMd(_intlLocale).format(d));

  String weekday(int weekday) {
    // 2026-11-02 is a Monday.
    final date = DateTime(2026, 11, 1 + weekday);
    final name = DateFormat.EEEE(_intlLocale).format(date);
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }
}
