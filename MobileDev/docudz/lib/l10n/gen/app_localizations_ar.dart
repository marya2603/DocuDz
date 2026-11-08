// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'DocuDZ';

  @override
  String get tagline => 'ملفك جاهز، وبالك مرتاح';

  @override
  String get greeting => 'مرحباً';

  @override
  String get homeHeadline => 'أي ملف تحضّر اليوم؟';

  @override
  String get searchHint => 'ابحث عن خدمة أو وثيقة';

  @override
  String get offlineReady => 'يعمل دون إنترنت';

  @override
  String get continueTitle => 'تابع من حيث توقفت';

  @override
  String nextDocument(String document) {
    return 'التالي: $document';
  }

  @override
  String get continueAction => 'متابعة';

  @override
  String get servicesTitle => 'الخدمات';

  @override
  String docsProgress(int done, int total) {
    return '$done/$total وثائق';
  }

  @override
  String docsReadyOf(int done, int total) {
    return '$done من $total وثائق جاهزة';
  }

  @override
  String verifiedShort(String date) {
    return 'تم التحقق $date';
  }

  @override
  String lastVerified(String date) {
    return 'آخر تحقق: $date';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCosts => 'التكاليف';

  @override
  String get navOffices => 'المكاتب';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get notOfficialTitle => 'ليست خدمة رسمية';

  @override
  String get notOfficialBody =>
      'DocuDZ مساعد مستقل، لا يتبع أي إدارة ولا يودع أي ملف نيابة عنك. تأكد دائماً من الشباك المعني.';

  @override
  String get notOfficialFooter => 'مساعد مستقل. ليست خدمة رسمية.';

  @override
  String get quickSteps => 'الخطوات';

  @override
  String get quickCosts => 'التكاليف';

  @override
  String get quickOffice => 'المكتب';

  @override
  String get requiredDocuments => 'الوثائق المطلوبة';

  @override
  String remainingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تبقّت $count وثيقة',
      many: 'تبقّت $count وثيقة',
      few: 'تبقّت $count وثائق',
      two: 'تبقّت وثيقتان',
      one: 'تبقّت وثيقة',
      zero: 'اكتملت الوثائق',
    );
    return '$_temp0';
  }

  @override
  String copies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نسخة',
      many: '$count نسخة',
      few: '$count نسخ',
      two: 'نسختان',
      one: 'نسخة واحدة',
    );
    return '$_temp0';
  }

  @override
  String issuedBy(String place) {
    return 'تُستخرج من: $place';
  }

  @override
  String get statusReady => 'جاهزة';

  @override
  String get statusToGet => 'ناقصة';

  @override
  String get reportError => 'الإبلاغ عن خطأ';

  @override
  String get reportErrorHint => 'لاحظت معلومة قديمة؟ أخبرنا، فهذا يفيد الجميع.';

  @override
  String get allSetTitle => 'كل شيء جاهز!';

  @override
  String get allSetBody => 'ملفك مكتمل. راجع الخطوات قبل الذهاب.';

  @override
  String get sheetWhere => 'أين تُستخرج';

  @override
  String get sheetCopies => 'عدد النسخ';

  @override
  String get sheetTip => 'معلومة مفيدة';

  @override
  String get markGathered => 'تأشير كجاهزة';

  @override
  String get markMissing => 'تأشير كناقصة';

  @override
  String checkboxSemantics(String document, String status) {
    return '$document، $status';
  }

  @override
  String get costsTitle => 'حاسبة الطوابع والرسوم';

  @override
  String get costsSubtitle => 'اعرف بالضبط ما تحتاجه قبل الذهاب.';

  @override
  String get sectionStampsFees => 'الطوابع والرسوم الرسمية';

  @override
  String get sectionOther => 'مصاريف أخرى';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get totalToBring => 'المبلغ الإجمالي';

  @override
  String get feesMayChange => 'قد تتغير الرسوم، راجع تاريخ آخر تحقق.';

  @override
  String get free => 'مجاني';

  @override
  String get optional => 'اختياري';

  @override
  String qtyTimes(int qty, String price) {
    return '$qty × $price';
  }

  @override
  String get decrease => 'إنقاص';

  @override
  String get increase => 'زيادة';

  @override
  String get stampsTip => 'تُباع الطوابع الجبائية في مكاتب البريد وقباضات الضرائب، ونادراً ما تُباع في الشباك نفسه.';

  @override
  String get currency => 'د.ج';

  @override
  String get stepsTitle => 'خطوة بخطوة';

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطوة',
      many: '$count خطوة',
      few: '$count خطوات',
      two: 'خطوتان',
      one: 'خطوة واحدة',
    );
    return '$_temp0';
  }

  @override
  String visitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count زيارة تقريباً',
      many: '$count زيارة تقريباً',
      few: '$count زيارات تقريباً',
      two: 'زيارتان تقريباً',
      one: 'زيارة واحدة تقريباً',
    );
    return '$_temp0';
  }

  @override
  String stepLabel(int n) {
    return 'الخطوة $n';
  }

  @override
  String get tipAvoidTrip => 'نصيحة لتجنب تنقل إضافي';

  @override
  String get officeTitle => 'معلومات المكتب';

  @override
  String get wilaya => 'الولاية';

  @override
  String get openNow => 'مفتوح الآن';

  @override
  String closesAt(String time) {
    return 'يغلق على $time';
  }

  @override
  String get closedNow => 'مغلق الآن';

  @override
  String opensAt(String time) {
    return 'يفتح على $time';
  }

  @override
  String get closedToday => 'مغلق اليوم';

  @override
  String get openingHours => 'أيام وساعات العمل';

  @override
  String get today => 'اليوم';

  @override
  String get closed => 'مغلق';

  @override
  String get address => 'العنوان';

  @override
  String get openInMaps => 'افتح في الخرائط';

  @override
  String get mapOfflineCaption => 'معاينة الخريطة غير محفوظة دون إنترنت';

  @override
  String get mapsSnack => 'يفتح تطبيق الخرائط إن كان مثبتاً.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get languageHint => 'يتغير التطبيق كله فوراً، بما في ذلك الاتجاه من اليمين إلى اليسار.';

  @override
  String get contentSection => 'المحتوى';

  @override
  String get lastContentUpdate => 'آخر تحديث للمحتوى';

  @override
  String contentVersion(String version) {
    return 'إصدار المحتوى $version';
  }

  @override
  String get checkForUpdates => 'البحث عن تحديثات';

  @override
  String get upToDate => 'قوائمك محدّثة.';

  @override
  String get trustSection => 'الثقة والخصوصية';

  @override
  String get privacyTitle => 'بياناتك تبقى في هاتفك';

  @override
  String get privacyBody => 'لا يُحفظ إلا تأشيراتك واللغة. لا حساب ولا تتبع.';

  @override
  String get premiumTitle => 'DocuDZ بريميوم';

  @override
  String premiumPrice(String currency) {
    return '500 $currency / سنة';
  }

  @override
  String get premiumFeatures => 'دون إعلانات، عدة ملفات شخصية، تذكيرات';

  @override
  String get comingLater => 'قريباً';

  @override
  String get about => 'حول التطبيق';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get madeBy => 'من إنجاز DRIS Fadia و NEFRAOUI Marya، ENSIA';

  @override
  String get onboardingTitle => 'اختر لغتك';

  @override
  String get onboardingBody => 'حضّر ملفاتك الإدارية دون إنترنت، خطوة واضحة تلو الأخرى.';

  @override
  String get continueButton => 'متابعة';

  @override
  String searchNoResults(String query) {
    return 'لا توجد نتائج لـ «$query»';
  }

  @override
  String get searchNoResultsHint => 'جرّب «جواز السفر» أو «شهادة الميلاد».';

  @override
  String get searchDocuments => 'وثائق مطابقة';

  @override
  String get reportTitle => 'الإبلاغ عن خطأ';

  @override
  String reportSubtitle(String service, String date) {
    return '$service، آخر تحقق $date';
  }

  @override
  String get reportWhat => 'ما الخطأ الذي لاحظته؟';

  @override
  String get reportMissingDoc => 'وثيقة ناقصة';

  @override
  String get reportWrongFee => 'رسم خاطئ';

  @override
  String get reportWrongOffice => 'مكتب أو مواعيد خاطئة';

  @override
  String get reportOther => 'أخرى';

  @override
  String get reportDetailsHint => 'صف التصحيح المطلوب (اختياري)';

  @override
  String get reportSend => 'إرسال البلاغ';

  @override
  String get reportOfflineNote => 'لا حاجة للإنترنت الآن: يُحفظ البلاغ ويُرسل عند عودة الاتصال.';

  @override
  String get reportThanks => 'شكراً! تم حفظ بلاغك.';

  @override
  String get sampleData => 'بيانات تجريبية (معاينة التصميم)';

  @override
  String get langArDesc => 'العربية، من اليمين إلى اليسار';

  @override
  String get langFrDesc => 'الفرنسية';

  @override
  String get langEnDesc => 'الإنجليزية';

  @override
  String get appVersion => '1.0.0 (نسخة تجريبية)';

  @override
  String get officeKindLabel => 'مكان الإيداع';

  @override
  String get onbFeat1 => 'قوائم تعمل دون إنترنت';

  @override
  String get onbFeat2 => 'حساب تكلفة الطوابع آلياً';

  @override
  String get onbFeat3 => 'المكتب الصحيح وأيام وساعات العمل';
}
