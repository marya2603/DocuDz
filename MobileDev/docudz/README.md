# DocuDZ: *All set, stress less*

Offline-first Android assistant that helps Algerians, mainly students and young
adults who just became independent, prepare administrative files
(**university registration, passport, driver's license, CNAS**) without extra
trips to the office.

> **Not an official service.** DocuDZ is an independent student project. It is not
> affiliated with any administration, submits nothing on the user's behalf, and
> uses no government logos, flags or emblems.
>
> **Sample content.** Every document, fee, office, address and opening hour in
> `assets/data/services.json` is *illustrative*, created for design purposes. It
> must be verified against official sources before any release.

Team: **DRIS Fadia, NEFRAOUI Marya**, ENSIA (National School of Artificial Intelligence, Algeria).
UI/UX submission, 12 November 2026.

---

## Run it

Prerequisites: Flutter **3.47** stable or newer (Dart 3.13), Android SDK, and an
Android device or emulator (Android 7.0+; designed for Android 10 on 2 GB RAM).

```bash
flutter pub get
flutter run
```

The first launch shows the language picker (Arabic, French, English); the
language can be changed at any time in **Settings**, which flips the whole app
to right-to-left for Arabic.

### Tests and screenshots

```bash
flutter analyze                         # clean
flutter test                            # 72 tests: behaviour, accessibility, screenshots
flutter test test/screenshots_test.dart # regenerates screenshots/<en|fr|ar>/*.png
```

Screenshots are rendered headlessly (no emulator) at 1080 x 2400 px
(412 x 915 dp at 2.625 dpr). The test loads the real bundled fonts and the
Material Icons font with `FontLoader` first, otherwise `flutter test` would
draw every glyph with the "Ahem" test font (black boxes). Any layout overflow
fails the test. `screenshots/anchors.json` stores element positions, used to
place the numbered callouts in the design PDF.

## The screens

| # | Screen | Features | Screenshot (EN) |
|---|--------|----------|-----------------|
| S1 | Home / service catalogue: greeting, search, continue card, 4 services with progress and "verified" stamps, offline chip, bottom navigation | F1 F2 F7 F8 | `screenshots/en/01_home.png` |
| S2 | Interactive checklist: progress header, Last verified date, ticked / unticked documents with copies and issuing office, detail sheet, Report an error | F2 F4 F7 | `02_checklist.png`, `02c_document_sheet.png` |
| S3 | Stamp & fee calculator: line items in DZD, optional items, quantities, subtotals, sticky TOTAL, "fees may change" note | F3 F7 | `03_costs.png` |
| S4 | Step-by-step process: timeline with "Tip to avoid an extra trip" callouts | F5 F4 | `04_steps.png` |
| S5 | Office information: wilaya selector, office, address, opening days, open now / closed today, offline map placeholder, Open in Maps | F6 F7 | `05_office.png`, `05b_office_closed.png` |
| S6 | Settings: language, Not an official service, last content update + Check for updates, privacy, Premium teaser (not in v1), About | F8 F7 | `06_settings.png` |
| + | Onboarding / language pick, all-set state, Report-an-error sheet, empty search, search results | | `07_*`, `02d_*`, `02e_*`, `08_*` |

Feature codes: F1 offline checklist per service · F2 tick-off with local progress ·
F3 stamp cost calculator · F4 where to get each document · F5 step-by-step
procedure · F6 office info per wilaya · F7 Last verified + Report an error ·
F8 language switch AR / FR / EN.

## Project structure

```
lib/
  main.dart                 start-up: date symbols, JSON catalogue, onboarding
  app.dart                  MaterialApp, locale, theme, localisation delegates
  theme/app_theme.dart      design tokens (colour, type, spacing, radius) + M3 theme
  l10n/app_{en,fr,ar}.arb   UI strings (ICU plurals incl. Arabic forms); gen/ is generated
  models/models.dart        Service, DocumentItem, FeeItem, ProcessStep, Office, ...
  data/                     ServicesRepository (JSON -> Catalog), ProgressStore
  state/app_state.dart      ChangeNotifier + InheritedNotifier (no extra package)
  utils/format.dart         locale-aware money, dates, weekdays (ar_DZ)
  screens/                  one file per screen
  widgets/                  reusable components (cards, tiles, stamps, sheets, ...)
assets/
  data/services.json        illustrative content in 3 languages
  fonts/                    Plus Jakarta Sans + IBM Plex Sans Arabic (OFL)
test/
  app_test.dart             behaviour + accessibility + 130% text-scale tests
  screenshots_test.dart     headless screenshot generation
  screenshot_harness.dart   font loading, phone frame, PNG capture, anchors
```

Dependencies are deliberately minimal: `flutter_localizations`, `intl`. No
network packages, no `google_fonts` (fonts are bundled), no state-management
package.

## Design rationale

**Users.** First-time applicants (18 to 25) handling a file alone: students
registering at university, young workers joining CNAS, anyone getting a first
passport or driver's license. Bilingual Arabic / French, often on an entry-level
Android phone with patchy data, and anxious about being sent back from the
counter.

**Tone: calm, trustworthy, reassuring.** The app should feel like a tidy folder,
not a government form: warm paper background, deep teal ink, one apricot accent,
generous spacing and short, kind microcopy ("All set!"). Trust is made visible:
a dated, dashed *Last verified* stamp on every list, *Report an error* one tap
away, and an explicit *Not an official service* notice.

**Design tokens** (all in `lib/theme/app_theme.dart`):

| Token | Value | Use |
|-------|-------|-----|
| Primary | `#0E5F58` deep teal (7.5:1 on white) | actions, headers, progress |
| Primary container | `#CFEAE4` mint | selected and ticked states |
| Accent | `#F4A259` apricot | progress fill, tips, logo tick (graphics only) |
| Secondary | `#9A4A0B` apricot ink (6.3:1) | tip titles |
| Surface | `#F7F5F0` paper, cards `#FFFFFF` | background, cards |
| Ink / muted | `#1A2423` (14.6:1) / `#4E5C5A` (6.4:1) | text |
| Success / warning / error | `#1F7A3E` / `#8A5A00` / `#B3261E` | ready, notices, closed |
| Type | Plus Jakarta Sans + IBM Plex Sans Arabic; 32/26/22/20/16/15/14 sp | nothing below 14 sp |
| Spacing | 8-pt grid (4, 8, 12, 16, 24, 32, 40), 16 dp page margin | |
| Radius | 8 chip, 12 button, 16 card, 24 hero, 28 sheet | |
| Elevation | flat cards (0 + 1 px hairline); only sheets and the nav bar float | |
| Icons | Material Symbols outlined / rounded, 24 dp | auto-mirrored in RTL |

**Accessibility.** Touch targets ≥ 48 dp (checked by `androidTapTargetGuideline`),
text ≥ 14 sp, WCAG AA contrast for every text pair, state never shown by colour
alone (checkbox + label + icon), semantic labels on checkboxes and progress, no
overflow at 130% system text size.

**Performance (2 GB RAM, < 30 MB).** No bitmap images in the UI (logo, map
placeholder, rings and stamps are `CustomPaint` vectors), static font weights
only, about 60 KB of content JSON, no implicit animations on progress, a cheap
ink ripple, fade page transitions and no theme cross-fade on language switch.

**RTL.** Only `EdgeInsetsDirectional`, `AlignmentDirectional` and start / end are
used; there is no hardcoded left / right. The wordmark, times and fractions such
as 3/8 stay left-to-right; amounts keep their sign with a bidi mark.

## Decisions and assumptions

- **Persistence:** v1 will seed a SQLite database (sqflite) from the bundled JSON
  and persist ticks and language there. This UI build keeps them in memory behind
  the `ProgressStore` interface, so the screens will not change.
- **Open in Maps / Report an error:** shown as UI; in v1 they hand off to the
  Maps app (`geo:` intent, e.g. via url_launcher) and queue reports for sending
  when online. No network code is included here.
- **Numbers:** Western digits (0-9) in all languages, as used in Algeria; space
  grouping in French and Arabic (6 000), commas in English (6,000). Currency
  label: DZD (EN), DA (FR), د.ج (AR).
- **Week:** office hours are listed Sunday first (Algerian working week).
- **Dark theme:** defined in the theme file, but v1 ships light only.
- **Fonts:** Plus Jakarta Sans (static weights instanced from the variable font)
  and IBM Plex Sans Arabic, both under the SIL Open Font License (licences in
  `assets/fonts/`).
