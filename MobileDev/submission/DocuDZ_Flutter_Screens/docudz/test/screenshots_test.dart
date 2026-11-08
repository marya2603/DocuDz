// Generates the design screenshots headlessly (no emulator needed):
//
//   flutter test test/screenshots_test.dart
//
// Output: screenshots/<en|fr|ar>/NN_name.png (1080 x 2400, captured at the
// device pixel ratio, not the 1x golden size) and screenshots/anchors.json
// (element positions used for the PDF callouts). Any RenderFlex overflow or
// other framework exception fails the test.
import 'package:docudz/app.dart';
import 'package:docudz/models/models.dart';
import 'package:docudz/screens/checklist_screen.dart';
import 'package:docudz/screens/home_shell.dart';
import 'package:docudz/screens/onboarding_screen.dart';
import 'package:docudz/screens/process_screen.dart';
import 'package:docudz/state/app_state.dart';
import 'package:docudz/widgets/sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screenshot_harness.dart';

late Catalog catalog;
final anchors = AnchorRecorder();
const _root = ValueKey('screenshot-root');

typedef Setup = Future<void> Function(WidgetTester tester, GlobalKey<NavigatorState> nav);

Future<void> _shot(
  WidgetTester tester, {
  required String lang,
  required String name,
  Widget? home,
  AppState? state,
  Setup? setup,
  List<String> keys = const [],
}) async {
  await setPhoneView(tester);
  debugDisableShadows = false; // real elevation shadows in screenshots
  final nav = GlobalKey<NavigatorState>();
  final appState = state ?? demoState(catalog, lang);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _root,
      child: PhoneChrome(
        rtl: lang == 'ar',
        child: DocuDzApp(state: appState, navigatorKey: nav, home: home ?? const HomeShell()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (setup != null) {
    await setup(tester, nav);
    await tester.pumpAndSettle();
  }
  // Fail loudly on any layout overflow.
  expect(tester.takeException(), isNull);
  anchors.record(tester, '$lang/$name', keys);
  await savePng(tester, find.byKey(_root), 'screenshots/$lang/$name.png');
  debugDisableShadows = true; // restore the test-framework invariant
}

Future<void> _push(WidgetTester tester, GlobalKey<NavigatorState> nav, Widget page) async {
  nav.currentState!.push(MaterialPageRoute<void>(builder: (_) => page));
  await tester.pumpAndSettle();
}

Future<void> _scroll(WidgetTester tester, double dy) async {
  await tester.drag(find.byType(Scrollable).first, Offset(0, -dy));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    await loadAppFonts();
    catalog = loadCatalog();
  });

  tearDownAll(() => anchors.write('screenshots/anchors.json'));

  for (final lang in ['en', 'fr', 'ar']) {
    group(lang, () {
      testWidgets(
        '01 home',
        (t) => _shot(
          t,
          lang: lang,
          name: '01_home',
          keys: [
            'home.offline',
            'home.headline',
            'home.search',
            'home.continue',
            'home.servicesHeader',
            'home.card.university',
            'nav',
          ],
        ),
      );

      testWidgets(
        '01b home scrolled',
        (t) => _shot(
          t,
          lang: lang,
          name: '01b_home_scrolled',
          setup: (t, nav) => _scroll(t, 420),
          keys: ['home.card.passport', 'home.card.license', 'home.card.cnas', 'home.notice', 'nav'],
        ),
      );

      testWidgets(
        '02 checklist',
        (t) => _shot(
          t,
          lang: lang,
          name: '02_checklist',
          setup: (t, nav) => _push(t, nav, const ChecklistScreen(serviceId: 'passport')),
          keys: [
            'checklist.header',
            'checklist.verified',
            'checklist.quick',
            'checklist.tile.0',
            'checklist.tile.2',
            'checklist.tile.6',
            'checklist.flag',
          ],
        ),
      );

      testWidgets(
        '02b checklist scrolled',
        (t) => _shot(
          t,
          lang: lang,
          name: '02b_checklist_scrolled',
          setup: (t, nav) async {
            await _push(t, nav, const ChecklistScreen(serviceId: 'passport'));
            await _scroll(t, 900);
          },
          keys: ['checklist.tile.6', 'checklist.tile.7', 'checklist.tile.8', 'checklist.report'],
        ),
      );

      testWidgets(
        '02c document sheet',
        (t) => _shot(
          t,
          lang: lang,
          name: '02c_document_sheet',
          setup: (t, nav) async {
            await _push(t, nav, const ChecklistScreen(serviceId: 'passport'));
            final ctx = t.element(find.byType(ChecklistScreen));
            final s = catalog.service('passport');
            showDocumentSheet(ctx, s, s.documents.firstWhere((d) => d.id == 'p_stamp'));
          },
        ),
      );

      testWidgets(
        '02d checklist all set',
        (t) => _shot(
          t,
          lang: lang,
          name: '02d_checklist_allset',
          state: demoState(
            catalog,
            lang,
            ticks: {
              ...demoTicks(),
              'cnas': {for (final d in catalog.service('cnas').documents) d.id},
            },
          ),
          setup: (t, nav) => _push(t, nav, const ChecklistScreen(serviceId: 'cnas')),
          keys: ['checklist.allset'],
        ),
      );

      testWidgets(
        '02e report sheet',
        (t) => _shot(
          t,
          lang: lang,
          name: '02e_report_sheet',
          setup: (t, nav) async {
            await _push(t, nav, const ChecklistScreen(serviceId: 'passport'));
            showReportErrorSheet(t.element(find.byType(ChecklistScreen)), catalog.service('passport'));
          },
        ),
      );

      testWidgets(
        '03 costs',
        (t) => _shot(
          t,
          lang: lang,
          name: '03_costs',
          home: const HomeShell(initialIndex: 1),
          keys: ['costs.selector', 'costs.note', 'costs.official', 'costs.other', 'costs.total'],
        ),
      );

      testWidgets(
        '04 steps',
        (t) => _shot(
          t,
          lang: lang,
          name: '04_steps',
          setup: (t, nav) => _push(t, nav, const ProcessScreen(serviceId: 'passport')),
          keys: ['steps.header', 'steps.tile.0', 'steps.tile.1', 'steps.tile.2'],
        ),
      );

      testWidgets(
        '04b steps scrolled',
        (t) => _shot(
          t,
          lang: lang,
          name: '04b_steps_scrolled',
          setup: (t, nav) async {
            await _push(t, nav, const ProcessScreen(serviceId: 'passport'));
            await _scroll(t, 640);
          },
          keys: ['steps.tile.3', 'steps.tile.4', 'steps.tile.5'],
        ),
      );

      testWidgets(
        '05 office',
        (t) => _shot(
          t,
          lang: lang,
          name: '05_office',
          home: const HomeShell(initialIndex: 2),
          keys: ['office.selector', 'office.wilaya', 'office.map', 'office.status', 'office.maps', 'office.hours'],
        ),
      );

      testWidgets(
        '05b office closed today',
        (t) => _shot(
          t,
          lang: lang,
          name: '05b_office_closed',
          state: demoState(catalog, lang, now: DateTime(2026, 11, 13, 10, 30)), // Friday
          home: const HomeShell(initialIndex: 2),
          setup: (t, nav) => _scroll(t, 300),
          keys: ['office.status', 'office.hours'],
        ),
      );

      testWidgets(
        '06 settings',
        (t) => _shot(
          t,
          lang: lang,
          name: '06_settings',
          home: const HomeShell(initialIndex: 3),
          keys: ['settings.language', 'settings.notice', 'settings.content'],
        ),
      );

      testWidgets(
        '06b settings scrolled',
        (t) => _shot(
          t,
          lang: lang,
          name: '06b_settings_scrolled',
          home: const HomeShell(initialIndex: 3),
          setup: (t, nav) => _scroll(t, 700),
          keys: ['settings.content', 'settings.premium'],
        ),
      );

      testWidgets('07 onboarding', (t) => _shot(t, lang: lang, name: '07_onboarding', home: const OnboardingScreen()));

      testWidgets(
        '08 search empty',
        (t) => _shot(
          t,
          lang: lang,
          name: '08_search_empty',
          setup: (t, nav) async {
            await t.enterText(find.byKey(const ValueKey('home.search')), 'visa');
            FocusManager.instance.primaryFocus?.unfocus();
          },
          keys: ['home.empty'],
        ),
      );

      testWidgets(
        '08b search results',
        (t) => _shot(
          t,
          lang: lang,
          name: '08b_search_results',
          setup: (t, nav) async {
            final q = {'en': 'birth', 'fr': 'naissance', 'ar': 'الميلاد'}[lang]!;
            await t.enterText(find.byKey(const ValueKey('home.search')), q);
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
      );
    });
  }
}
