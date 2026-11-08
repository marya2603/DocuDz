// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DocuDZ';

  @override
  String get tagline => 'All set, stress less';

  @override
  String get greeting => 'Hello';

  @override
  String get homeHeadline => 'Which file are you preparing?';

  @override
  String get searchHint => 'Search a service or document';

  @override
  String get offlineReady => 'Offline ready';

  @override
  String get continueTitle => 'Continue where you left off';

  @override
  String nextDocument(String document) {
    return 'Next: $document';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get servicesTitle => 'Services';

  @override
  String docsProgress(int done, int total) {
    return '$done/$total documents';
  }

  @override
  String docsReadyOf(int done, int total) {
    return '$done of $total documents ready';
  }

  @override
  String verifiedShort(String date) {
    return 'Verified $date';
  }

  @override
  String lastVerified(String date) {
    return 'Last verified: $date';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navCosts => 'Costs';

  @override
  String get navOffices => 'Offices';

  @override
  String get navSettings => 'Settings';

  @override
  String get notOfficialTitle => 'Not an official service';

  @override
  String get notOfficialBody =>
      'DocuDZ is an independent assistant. It is not affiliated with any administration and never submits anything for you. Always confirm with the office.';

  @override
  String get notOfficialFooter => 'Independent assistant. Not an official service.';

  @override
  String get quickSteps => 'Steps';

  @override
  String get quickCosts => 'Costs';

  @override
  String get quickOffice => 'Office';

  @override
  String get requiredDocuments => 'Required documents';

  @override
  String remainingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
      zero: 'All gathered',
    );
    return '$_temp0';
  }

  @override
  String copies(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count copies', one: '1 copy');
    return '$_temp0';
  }

  @override
  String issuedBy(String place) {
    return 'Issued by: $place';
  }

  @override
  String get statusReady => 'Ready';

  @override
  String get statusToGet => 'To get';

  @override
  String get reportError => 'Report an error';

  @override
  String get reportErrorHint => 'Spotted something outdated? Tell us, it helps everyone.';

  @override
  String get allSetTitle => 'All set!';

  @override
  String get allSetBody => 'Your file is complete. Review the steps before you go.';

  @override
  String get sheetWhere => 'Where to get it';

  @override
  String get sheetCopies => 'Copies to bring';

  @override
  String get sheetTip => 'Good to know';

  @override
  String get markGathered => 'Mark as gathered';

  @override
  String get markMissing => 'Mark as not gathered';

  @override
  String checkboxSemantics(String document, String status) {
    return '$document, $status';
  }

  @override
  String get costsTitle => 'Stamp & fee calculator';

  @override
  String get costsSubtitle => 'Know exactly what to bring before you go.';

  @override
  String get sectionStampsFees => 'Stamps & official fees';

  @override
  String get sectionOther => 'Other costs';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get totalToBring => 'Total to bring';

  @override
  String get feesMayChange => 'Fees may change, check the last verified date.';

  @override
  String get free => 'Free';

  @override
  String get optional => 'Optional';

  @override
  String qtyTimes(int qty, String price) {
    return '$qty × $price';
  }

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get stampsTip => 'Fiscal stamps are sold at post offices and tax offices, rarely at the counter itself.';

  @override
  String get currency => 'DZD';

  @override
  String get stepsTitle => 'Step-by-step';

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count steps', one: '1 step');
    return '$_temp0';
  }

  @override
  String visitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'about $count office visits',
      one: 'about 1 office visit',
    );
    return '$_temp0';
  }

  @override
  String stepLabel(int n) {
    return 'Step $n';
  }

  @override
  String get tipAvoidTrip => 'Tip to avoid an extra trip';

  @override
  String get officeTitle => 'Office information';

  @override
  String get wilaya => 'Wilaya';

  @override
  String get openNow => 'Open now';

  @override
  String closesAt(String time) {
    return 'closes at $time';
  }

  @override
  String get closedNow => 'Closed now';

  @override
  String opensAt(String time) {
    return 'opens at $time';
  }

  @override
  String get closedToday => 'Closed today';

  @override
  String get openingHours => 'Opening days & hours';

  @override
  String get today => 'Today';

  @override
  String get closed => 'Closed';

  @override
  String get address => 'Address';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get mapOfflineCaption => 'Map preview is not stored offline';

  @override
  String get mapsSnack => 'Opens your Maps app when one is installed.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageHint => 'The whole app switches instantly, including right-to-left Arabic.';

  @override
  String get contentSection => 'Content';

  @override
  String get lastContentUpdate => 'Last content update';

  @override
  String contentVersion(String version) {
    return 'Content version $version';
  }

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get upToDate => 'Your checklists are up to date.';

  @override
  String get trustSection => 'Trust & privacy';

  @override
  String get privacyTitle => 'Your data stays on this phone';

  @override
  String get privacyBody => 'Only your ticks and your language are saved. No account, no tracking.';

  @override
  String get premiumTitle => 'DocuDZ Premium';

  @override
  String premiumPrice(String currency) {
    return '500 $currency / year';
  }

  @override
  String get premiumFeatures => 'Ad-free, several profiles, reminders';

  @override
  String get comingLater => 'Coming later';

  @override
  String get about => 'About';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get madeBy => 'Made by DRIS Fadia & NEFRAOUI Marya, ENSIA';

  @override
  String get onboardingTitle => 'Choose your language';

  @override
  String get onboardingBody => 'Prepare your administrative files offline, one clear step at a time.';

  @override
  String get continueButton => 'Continue';

  @override
  String searchNoResults(String query) {
    return 'No results for “$query”';
  }

  @override
  String get searchNoResultsHint => 'Try “passport” or “birth certificate”.';

  @override
  String get searchDocuments => 'Matching documents';

  @override
  String get reportTitle => 'Report an error';

  @override
  String reportSubtitle(String service, String date) {
    return '$service, last verified $date';
  }

  @override
  String get reportWhat => 'What looks wrong?';

  @override
  String get reportMissingDoc => 'Missing document';

  @override
  String get reportWrongFee => 'Wrong fee';

  @override
  String get reportWrongOffice => 'Wrong office or hours';

  @override
  String get reportOther => 'Other';

  @override
  String get reportDetailsHint => 'Describe what should be corrected (optional)';

  @override
  String get reportSend => 'Send report';

  @override
  String get reportOfflineNote => 'No connection needed: the report is queued and sent when you are back online.';

  @override
  String get reportThanks => 'Thanks! Your report is saved.';

  @override
  String get sampleData => 'Sample dataset (design preview)';

  @override
  String get langArDesc => 'Arabic, right-to-left layout';

  @override
  String get langFrDesc => 'French';

  @override
  String get langEnDesc => 'English';

  @override
  String get appVersion => '1.0.0 (MVP preview)';

  @override
  String get officeKindLabel => 'Where to submit';

  @override
  String get onbFeat1 => 'Checklists that work offline';

  @override
  String get onbFeat2 => 'Stamp costs added up for you';

  @override
  String get onbFeat3 => 'The right office, days and hours';
}
