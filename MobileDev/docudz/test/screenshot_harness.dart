// Shared helpers for headless screenshot generation.
//
// GOTCHA: `flutter test` renders every unknown font with "Ahem" (black boxes).
// [loadAppFonts] registers the real bundled fonts (and Material Icons) from
// FontManifest.json with FontLoader before anything is pumped.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:docudz/data/progress_store.dart';
import 'package:docudz/data/services_repository.dart';
import 'package:docudz/models/models.dart';
import 'package:docudz/state/app_state.dart';
import 'package:docudz/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pixel 7-class phone: 1080 x 2400 px at 2.625 dpr (about 411 x 914 dp).
const Size kPhysicalSize = Size(1080, 2400);
const double kDpr = 2.625;
const double kStatusBar = 24;
const double kGestureBar = 16;

/// Thursday 12 Nov 2026, 10:30: offices are open.
final DateTime kDemoNow = DateTime(2026, 11, 12, 10, 30);

Future<void> loadAppFonts() async {
  final manifest = json.decode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  // Belt and braces: make sure Material Icons resolve even if the manifest
  // entry is prefixed differently in this SDK version.
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final icons = File('$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
    if (icons.existsSync()) {
      final bytes = icons.readAsBytesSync();
      await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.view(bytes.buffer)))).load();
    }
  }
}

/// Renders [finder]'s RepaintBoundary at the full device pixel ratio and
/// writes a PNG (goldens would only be captured at 1x logical size).
Future<void> savePng(WidgetTester tester, Finder finder, String path) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(finder);
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: kDpr);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Catalog loadCatalog() => ServicesRepository.parse(File('assets/data/services.json').readAsStringSync());

/// Demo progress used across screenshots.
Map<String, Set<String>> demoTicks() => {
  'university': {'u_bac', 'u_confirm', 'u_birth'},
  'passport': {'p_form', 'p_birth', 'p_photos', 'p_id', 'p_blood', 'p_military'},
  'license': {'l_birth'},
  'cnas': {'c_birth', 'c_id'},
};

AppState demoState(Catalog catalog, String lang, {DateTime? now, Map<String, Set<String>>? ticks}) => AppState(
  catalog: catalog,
  store: InMemoryProgressStore(seed: ticks ?? demoTicks(), initialLanguage: lang),
  locale: Locale(lang),
  clock: () => now ?? kDemoNow,
  lastServiceId: 'passport',
);

Future<void> setPhoneView(WidgetTester tester) async {
  tester.view.physicalSize = kPhysicalSize;
  tester.view.devicePixelRatio = kDpr;
  tester.view.padding = const FakeViewPadding(top: kStatusBar * kDpr, bottom: kGestureBar * kDpr);
  tester.view.viewPadding = const FakeViewPadding(top: kStatusBar * kDpr, bottom: kGestureBar * kDpr);
  addTearDown(tester.view.reset);
}

/// Wraps the app with a mock Android status bar and gesture handle so the
/// screenshots read as real phone screens.
class PhoneChrome extends StatelessWidget {
  const PhoneChrome({super.key, required this.child, required this.rtl, this.dark = false});

  final Widget child;
  final bool rtl;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.ink;
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: kStatusBar,
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Text(
                      '10:30',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: AppFonts.latin,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.signal_cellular_alt_rounded, size: 16, color: fg),
                    const SizedBox(width: 4),
                    Icon(Icons.wifi_off_rounded, size: 16, color: fg),
                    const SizedBox(width: 4),
                    Icon(Icons.battery_5_bar_rounded, size: 16, color: fg),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 108,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Collects element rectangles (logical px) for PDF annotations.
class AnchorRecorder {
  final Map<String, Map<String, List<double>>> data = {};

  void record(WidgetTester tester, String shot, List<String> keys) {
    final rects = <String, List<double>>{};
    for (final k in keys) {
      final f = find.byKey(ValueKey(k));
      if (f.evaluate().isEmpty) continue;
      final r = tester.getRect(f.first);
      rects[k] = [r.left, r.top, r.width, r.height].map((v) => double.parse(v.toStringAsFixed(1))).toList();
    }
    data[shot] = rects;
  }

  void write(String path) {
    final file = File(path)..createSync(recursive: true);
    final size = kPhysicalSize / kDpr;
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'logicalSize': [size.width, size.height],
        'dpr': kDpr,
        'shots': data,
      }),
    );
  }
}
