# -*- coding: utf-8 -*-
"""Builds submission/DocuDZ_UIUX_Design.pdf from the Flutter screenshots.

Usage (from the MobileDev folder):
    python design/build_design_pdf.py

Inputs : docudz/screenshots/<lang>/*.png + anchors.json (produced by
         `flutter test test/screenshots_test.dart`), bundled app fonts, and
         the Material Icons font shipped with the Flutter SDK.
Output : submission/DocuDZ_UIUX_Design.pdf (16:9, vector text, embedded fonts).
"""
import io
import json
import os
from pathlib import Path

import arabic_reshaper
from bidi.algorithm import get_display
from fontTools import subset as ft_subset
from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont as FTFont, newTable
from PIL import Image
from reportlab.lib.colors import Color, HexColor, white
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph

ROOT = Path(__file__).resolve().parents[1]
PROJ = ROOT / 'docudz'
SHOTS = PROJ / 'screenshots'
FONTS = PROJ / 'assets' / 'fonts'
OUT = ROOT / 'submission' / 'DocuDZ_UIUX_Design.pdf'
BUILD = ROOT / 'design' / '.build'
FLUTTER_ROOT = Path(os.environ.get('FLUTTER_ROOT', Path.home() / 'tools' / 'flutter'))
MATERIAL_FONTS = FLUTTER_ROOT / 'bin' / 'cache' / 'artifacts' / 'material_fonts'

W, H = 960, 540  # 16:9 points
M = 40  # page margin
TOTAL_PAGES = 17
DATE = '12 November 2026'
TESTS_TOTAL = 72  # 51 screenshot renders + 21 behaviour / accessibility tests (flutter test)
FOOTNOTE = 'Sample content for design purposes, to be verified against official sources before release.'

C = dict(
    primary='#0E5F58', primaryDark='#0A4A44', primaryContainer='#CFEAE4', mint='#BFE6DE',
    accent='#F4A259', secondary='#9A4A0B', secondaryContainer='#FFE3CC', paper='#F7F5F0',
    card='#FFFFFF', surfaceLow='#F2EFE8', surfaceHigh='#E6E1D8', ink='#1A2423', muted='#4E5C5A',
    outline='#7A8784', hairline='#DDD7CC', success='#1F7A3E', successContainer='#D6F0DC',
    warning='#8A5A00', warningContainer='#FFEBC2', error='#B3261E', errorContainer='#F9DEDC',
    indigo='#3442A0', indigoBg='#E2E5FA', apricotFg='#94470C', apricotBg='#FDE6CF',
    plum='#7A3B83', plumBg='#F0E2F2', tealBg='#D5EEE8',
)


def col(k, a=None):
    c = HexColor(C.get(k, k))
    return Color(c.red, c.green, c.blue, alpha=a) if a is not None else c


# --------------------------------------------------------------------------
# Fonts
# --------------------------------------------------------------------------
ICON_NAMES = [
    'school_outlined', 'flight_takeoff_outlined', 'directions_car_outlined', 'health_and_safety_outlined',
    'checklist_outlined', 'calculate_outlined', 'location_on_outlined', 'verified_outlined',
    'lightbulb_outlined', 'cloud_off_outlined', 'offline_pin_outlined', 'flag_outlined', 'lock_outlined',
    'schedule_outlined', 'description_outlined', 'format_list_numbered_outlined', 'translate_outlined',
    'accessibility_new_outlined', 'memory_outlined', 'bolt_outlined', 'check_circle_outlined',
    'groups_outlined', 'construction_outlined', 'directions_walk_outlined', 'map_outlined',
    'format_textdirection_r_to_l_outlined', 'touch_app_outlined', 'error_outline_outlined',
    'storage_outlined', 'home_outlined', 'settings_outlined', 'search_outlined', 'payments_outlined',
    'info_outlined', 'speed_outlined', 'visibility_outlined', 'event_outlined', 'rocket_launch_outlined',
    'arrow_forward_outlined', 'check_baseline', 'content_copy_outlined', 'update_outlined',
    'workspace_premium_outlined', 'text_fields_outlined', 'wifi_off_outlined', 'palette_outlined',
    'phone_android_outlined', 'sd_storage_outlined', 'translate_baseline',
]
ICONS = {}


def _otf_to_ttf(font):
    glyph_order = font.getGlyphOrder()
    glyph_set = font.getGlyphSet()
    glyf = newTable('glyf')
    glyf.glyphOrder = glyph_order
    glyf.glyphs = {}
    for name in glyph_order:
        pen = TTGlyphPen(glyph_set)
        glyph_set[name].draw(Cu2QuPen(pen, 1.0, reverse_direction=True))
        glyf.glyphs[name] = pen.glyph()
    font['loca'] = newTable('loca')
    font['glyf'] = glyf
    del font['CFF ']
    glyf.compile(font)
    hmtx = font['hmtx']
    for name, g in glyf.glyphs.items():
        if hasattr(g, 'xMin'):
            hmtx[name] = (hmtx[name][0], g.xMin)
    maxp = newTable('maxp')
    maxp.tableVersion = 0x00010000
    for attr in ('maxZones', 'maxTwilightPoints', 'maxStorage', 'maxFunctionDefs', 'maxInstructionDefs',
                 'maxStackElements', 'maxSizeOfInstructions', 'maxComponentElements'):
        setattr(maxp, attr, 1 if attr == 'maxZones' else 0)
    font['maxp'] = maxp
    post = font['post']
    post.formatType = 3.0
    font.sfntVersion = '\x00\x01\x00\x00'


def build_icon_font():
    """Subset Flutter's Material Icons (CFF) and convert to TrueType for reportlab."""
    BUILD.mkdir(parents=True, exist_ok=True)
    out = BUILD / 'MaterialIcons-subset.ttf'
    codepoints = {}
    for line in (MATERIAL_FONTS / 'codepoints').read_text().splitlines():
        name, cp = line.split()
        codepoints[name] = int(cp, 16)
    for n in ICON_NAMES:
        cp = codepoints.get(n) or codepoints.get(n.replace('_outlined', '_baseline'))
        if cp and cp <= 0xFFFF:
            ICONS[n.replace('_outlined', '').replace('_baseline', '')] = chr(cp)
    src = FTFont(str(MATERIAL_FONTS / 'materialicons-regular.otf'))
    opts = ft_subset.Options()
    opts.layout_features = []
    opts.name_IDs = ['*']
    opts.notdef_outline = True
    sub = ft_subset.Subsetter(opts)
    sub.populate(unicodes=[ord(ch) for ch in ICONS.values()])
    sub.subset(src)
    _otf_to_ttf(src)
    src.save(str(out))
    return out


def register_fonts():
    for name, file in [
        ('PJS', 'PlusJakartaSans-Regular'), ('PJS-M', 'PlusJakartaSans-Medium'),
        ('PJS-SB', 'PlusJakartaSans-SemiBold'), ('PJS-B', 'PlusJakartaSans-Bold'),
        ('PJS-XB', 'PlusJakartaSans-ExtraBold'), ('AR', 'IBMPlexSansArabic-Regular'),
        ('AR-SB', 'IBMPlexSansArabic-SemiBold'), ('AR-B', 'IBMPlexSansArabic-Bold'),
    ]:
        pdfmetrics.registerFont(TTFont(name, str(FONTS / f'{file}.ttf')))
    pdfmetrics.registerFontFamily('PJS', normal='PJS', bold='PJS-B', italic='PJS', boldItalic='PJS-B')
    pdfmetrics.registerFont(TTFont('MI', str(build_icon_font())))


def ar(text):
    """Shape + reorder Arabic for reportlab (which has no bidi/shaping)."""
    return get_display(arabic_reshaper.reshape(text))


# --------------------------------------------------------------------------
# Drawing helpers
# --------------------------------------------------------------------------
ANCH = json.loads((SHOTS / 'anchors.json').read_text(encoding='utf-8'))
LW, LH = ANCH['logicalSize']
DPR = ANCH['dpr']
_img_cache = {}


def shot_img(lang, name, width_px=760):
    key = (lang, name, width_px)
    if key not in _img_cache:
        im = Image.open(SHOTS / lang / f'{name}.png').convert('RGB')
        if width_px and im.width > width_px:
            im = im.resize((width_px, round(im.height * width_px / im.width)), Image.LANCZOS)
        buf = io.BytesIO()
        im.save(buf, 'JPEG', quality=90, optimize=True, subsampling=0)
        buf.seek(0)
        _img_cache[key] = ImageReader(buf)
    return _img_cache[key]


def crop_img(lang, name, rect, pad=8, scale=0.75):
    """Crop an element (logical rect) out of a full-res screenshot."""
    key = (lang, name, tuple(rect), pad, scale)
    if key not in _img_cache:
        im = Image.open(SHOTS / lang / f'{name}.png').convert('RGB')
        l, t, w, h = rect
        box = [round((l - pad) * DPR), round((t - pad) * DPR), round((l + w + pad) * DPR), round((t + h + pad) * DPR)]
        box = [max(0, box[0]), max(0, box[1]), min(im.width, box[2]), min(im.height, box[3])]
        im = im.crop(box)
        im = im.resize((round(im.width * scale), round(im.height * scale)), Image.LANCZOS)
        buf = io.BytesIO()
        im.save(buf, 'JPEG', quality=92, optimize=True, subsampling=0)
        buf.seek(0)
        _img_cache[key] = (ImageReader(buf), im.width / im.height)
    return _img_cache[key]


def anchor(lang, name, key):
    return ANCH['shots'][f'{lang}/{name}'][key]


def style(size=10, leading=None, color='ink', font='PJS', align=0):
    return ParagraphStyle('s', fontName=font, fontSize=size, leading=leading or size * 1.38,
                          textColor=col(color), alignment=align)


def para(c, text, x, y_top, w, st):
    p = Paragraph(text, st)
    _, h = p.wrap(w, 2000)
    p.drawOn(c, x, y_top - h)
    return h


def rrect(c, x, y, w, h, r, fill=None, stroke=None, lw=1, dash=None):
    c.saveState()
    if fill is not None:
        c.setFillColor(fill)
    if stroke is not None:
        c.setStrokeColor(stroke)
        c.setLineWidth(lw)
    if dash:
        c.setDash(*dash)
    c.roundRect(x, y, w, h, r, fill=1 if fill is not None else 0, stroke=1 if stroke is not None else 0)
    c.restoreState()


def icon(c, name, x, y, size=14, color='primary'):
    """Draws a Material icon glyph with its bottom-left at (x, y)."""
    c.saveState()
    c.setFillColor(col(color))
    c.setFont('MI', size)
    c.drawString(x, y, ICONS[name])
    c.restoreState()


def icon_badge(c, name, cx, cy, r=14, bg='primaryContainer', fg='primary'):
    c.saveState()
    c.setFillColor(col(bg))
    c.circle(cx, cy, r, fill=1, stroke=0)
    c.restoreState()
    s = r * 1.15
    icon(c, name, cx - s / 2, cy - s / 2 + s * 0.06, s, fg)


def brand_mark(c, x, y, s, on_dark=False):
    """Vector port of the in-app BrandMark (same geometry as lib/widgets/brand.dart)."""
    c.saveState()
    c.translate(x, y + s)
    c.scale(1, -1)
    c.setFillColor(white if on_dark else col('primary'))
    c.roundRect(0, 0, s, s, s * 0.28, fill=1, stroke=0)
    l, t, r, b, fold, rad = s * 0.27, s * 0.2, s * 0.73, s * 0.8, s * 0.14, s * 0.06
    p = c.beginPath()
    p.moveTo(l + rad, t)
    p.lineTo(r - fold, t)
    p.lineTo(r, t + fold)
    p.lineTo(r, b - rad)
    p.curveTo(r, b, r, b, r - rad, b)
    p.lineTo(l + rad, b)
    p.curveTo(l, b, l, b, l, b - rad)
    p.lineTo(l, t + rad)
    p.curveTo(l, t, l, t, l + rad, t)
    p.close()
    c.setFillColor(col('primary') if on_dark else white)
    c.drawPath(p, fill=1, stroke=0)
    p = c.beginPath()
    p.moveTo(r - fold, t)
    p.lineTo(r - fold, t + fold)
    p.lineTo(r, t + fold)
    p.close()
    c.setFillColor(col('primaryDark') if on_dark else col('primaryContainer'))
    c.drawPath(p, fill=1, stroke=0)
    c.setStrokeColor(col('mint') if on_dark else col('hairline'))
    c.setLineCap(1)
    c.setLineWidth(s * 0.045)
    c.line(l + s * 0.08, t + s * 0.16, r - fold - s * 0.04, t + s * 0.16)
    c.line(l + s * 0.08, t + s * 0.27, r - s * 0.08, t + s * 0.27)
    c.setStrokeColor(col('accent'))
    c.setLineWidth(s * 0.085)
    c.setLineJoin(1)
    p = c.beginPath()
    p.moveTo(l + s * 0.09, b - s * 0.2)
    p.lineTo(l + s * 0.19, b - s * 0.1)
    p.lineTo(r - s * 0.07, b - s * 0.3)
    c.drawPath(p, fill=0, stroke=1)
    c.restoreState()


def wordmark(c, x, y, size, on_dark=False):
    c.setFont('PJS-XB', size)
    c.setFillColor(white if on_dark else col('ink'))
    c.drawString(x, y, 'Docu')
    w = pdfmetrics.stringWidth('Docu', 'PJS-XB', size)
    c.setFillColor(col('accent') if on_dark else col('primary'))
    c.drawString(x + w, y, 'DZ')
    return w + pdfmetrics.stringWidth('DZ', 'PJS-XB', size)


def marker(c, x, y, n, r=8.5):
    c.saveState()
    c.setFillColor(white)
    c.circle(x, y, r + 1.6, fill=1, stroke=0)
    c.setFillColor(col('accent'))
    c.circle(x, y, r, fill=1, stroke=0)
    c.setFillColor(col('ink'))
    c.setFont('PJS-XB', r * 1.1)
    c.drawCentredString(x, y - r * 0.38, str(n))
    c.restoreState()


def phone(c, lang, name, x, y, h, markers=(), caption=None, caption_w=None):
    """Device frame with the screenshot clipped to rounded corners.
    markers: (n, key, fx, fy, dx, dy) with fx/fy fractions of the anchor rect."""
    pad = max(4.5, h * 0.016)
    sh = h - 2 * pad
    sw = sh * 1080 / 2400
    w = sw + 2 * pad
    r_out, r_in = h * 0.058, h * 0.045
    c.saveState()
    c.setFillColor(Color(0.1, 0.14, 0.14, alpha=0.10))
    c.roundRect(x + 2.5, y - 5, w, h, r_out, fill=1, stroke=0)
    c.setFillColor(col('ink'))
    c.roundRect(x, y, w, h, r_out, fill=1, stroke=0)
    p = c.beginPath()
    p.roundRect(x + pad, y + pad, sw, sh, r_in)
    c.clipPath(p, stroke=0, fill=0)
    c.drawImage(shot_img(lang, name), x + pad, y + pad, sw, sh)
    c.restoreState()
    s = sw / LW
    for m in markers:
        n, key, fx, fy, dx, dy = (list(m) + [0, 0, 0, 0])[:6]
        rect = anchor(lang, name, key) if key else [0, 0, 0, 0]
        lx = rect[0] + rect[2] * fx + dx
        ly = rect[1] + rect[3] * fy + dy
        marker(c, x + pad + lx * s, y + pad + sh - ly * s, n)
    if caption:
        cw = caption_w or w + 30
        para(c, caption, x + w / 2 - cw / 2, y - 12, cw, style(8.6, 11.5, 'muted', align=TA_CENTER))
    return w


def phone_width(h):
    pad = max(4.5, h * 0.016)
    return (h - 2 * pad) * 1080 / 2400 + 2 * pad


def page_bg(c, color='paper'):
    c.setFillColor(col(color))
    c.rect(0, 0, W, H, fill=1, stroke=0)


def header(c, n, section):
    page_bg(c)
    brand_mark(c, M, H - 34, 16)
    wordmark(c, M + 22, H - 29.5, 11)
    c.setFont('PJS-M', 9)
    c.setFillColor(col('muted'))
    c.drawString(M + 22 + pdfmetrics.stringWidth('DocuDZ', 'PJS-XB', 11) + 6, H - 29.5, '·  UI/UX design submission')
    c.setFont('PJS-B', 9)
    c.setFillColor(col('primary'))
    label = f'{section}   '
    c.drawRightString(W - M - 34, H - 29.5, label.upper())
    rrect(c, W - M - 30, H - 34, 30, 15, 7.5, fill=col('primary'))
    c.setFillColor(white)
    c.setFont('PJS-B', 8.5)
    c.drawCentredString(W - M - 15, H - 30, f'{n:02d}')


def footer(c, note=True):
    c.setStrokeColor(col('hairline'))
    c.setLineWidth(0.8)
    c.line(M, 30, W - M, 30)
    c.setFont('PJS', 7.6)
    c.setFillColor(col('muted'))
    if note:
        c.drawString(M, 18, '* ' + FOOTNOTE)
    c.drawRightString(W - M, 18, f'DRIS Fadia · NEFRAOUI Marya · ENSIA · {DATE}')


def title(c, kicker, text, y=H - 78, w=W - 2 * M, x=M, size=24):
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(x, y + size + 6, kicker.upper())
    return para(c, text, x, y + size + 2, w, style(size, size * 1.15, 'ink', 'PJS-XB'))


def tags(c, x, y, items, bg='primaryContainer', fg='primary', size=8.5):
    for t in items:
        tw = pdfmetrics.stringWidth(t, 'PJS-B', size) + 14
        rrect(c, x, y - 4, tw, size + 8, (size + 8) / 2, fill=col(bg))
        c.setFont('PJS-B', size)
        c.setFillColor(col(fg))
        c.drawString(x + 7, y + 0.5, t)
        x += tw + 5
    return x


def annotations(c, x, y_top, w, items, gap=9, size=9.6):
    y = y_top
    for n, head, body, ftags in items:
        marker(c, x + 9, y - 8, n)
        tag_str = ''.join(f'  <font name="PJS-B" size="7.8" color="{C["primary"]}">{t}</font>' for t in ftags)
        h = para(c, f'<font name="PJS-B" size="{size + 0.8}">{head}</font>{tag_str}<br/>{body}',
                 x + 26, y, w - 26, style(size, size * 1.36, 'muted'))
        y -= max(h, 18) + gap
    return y


def bullet_list(c, x, y_top, w, items, size=9.6, gap=5, icon_name=None, color='muted', dot='primary'):
    y = y_top
    for it in items:
        if icon_name:
            icon(c, icon_name, x, y - size - 1, size + 2, dot)
        else:
            c.setFillColor(col(dot))
            c.circle(x + 3, y - size * 0.62, 2.1, fill=1, stroke=0)
        h = para(c, it, x + (size + 6 if icon_name else 11), y, w - (size + 6 if icon_name else 11),
                 style(size, size * 1.38, color))
        y -= h + gap
    return y


def card(c, x, y, w, h, fill='card', stroke='hairline', r=14):
    rrect(c, x, y, w, h, r, fill=col(fill), stroke=col(stroke) if stroke else None, lw=0.8)


# --------------------------------------------------------------------------
# Content
# --------------------------------------------------------------------------
FEATURES = [
    ('F1', 'Offline checklist per service'),
    ('F2', 'Tick-off, progress saved locally'),
    ('F3', 'Stamp cost calculator (DZD)'),
    ('F4', 'Where to get each document'),
    ('F5', 'Step-by-step procedure + tips'),
    ('F6', 'Office info per wilaya'),
    ('F7', '"Last verified" date + Report an error'),
    ('F8', 'Language switch AR / FR / EN'),
]


def page_cover(c):
    page_bg(c)
    # Right teal panel with gradient
    c.saveState()
    p = c.beginPath()
    p.rect(540, 0, W - 540, H)
    c.clipPath(p, stroke=0, fill=0)
    c.linearGradient(540, H, W, 0, (col('primary'), col('primaryDark')), extend=False)
    c.restoreState()
    # subtle stamp ring decoration
    c.saveState()
    c.setStrokeColor(Color(1, 1, 1, alpha=0.10))
    c.setLineWidth(1.4)
    c.setDash(5, 4)
    c.roundRect(560, 300, 380, 215, 26, fill=0, stroke=1)
    c.restoreState()
    phone(c, 'en', '01_home', 572, 52, 420)
    phone(c, 'ar', '02_checklist', 742, 32, 392)

    x = 64
    brand_mark(c, x, 404, 58)
    wordmark(c, x, 336, 50)
    c.setFont('PJS-B', 22)
    c.setFillColor(col('primary'))
    c.drawString(x + 2, 300, 'All set, stress less')
    c.setFont('PJS-M', 12)
    c.setFillColor(col('muted'))
    c.drawString(x + 2, 278, 'Dossier prêt, esprit tranquille')
    c.setFont('AR-SB', 14)
    c.drawString(x + 2 + pdfmetrics.stringWidth('Dossier prêt, esprit tranquille', 'PJS-M', 12) + 14, 278,
                 ar('ملفك جاهز، وبالك مرتاح'))

    rrect(c, x, 222, 200, 26, 13, fill=col('primary'))
    c.setFont('PJS-B', 11.5)
    c.setFillColor(white)
    c.drawString(x + 14, 230.5, 'UI/UX Design Submission')
    para(c, 'Offline-first Android assistant to prepare Algerian administrative files: university registration, '
            'passport, driver\'s license and CNAS. Flutter, Material 3.',
         x, 206, 420, style(10.5, 15, 'muted'))

    c.setFont('PJS-B', 8.5)
    c.setFillColor(col('secondary'))
    c.drawString(x, 148, 'TEAM')
    c.setFont('PJS-B', 14)
    c.setFillColor(col('ink'))
    c.drawString(x, 130, 'DRIS Fadia  ·  NEFRAOUI Marya')
    c.setFont('PJS', 10.5)
    c.setFillColor(col('muted'))
    c.drawString(x, 113, 'ENSIA, National School of Artificial Intelligence, Algeria')
    c.drawString(x, 97, f'Mobile Development project  ·  {DATE}')

    rrect(c, x, 44, 330, 26, 8, fill=col('warningContainer'))
    icon(c, 'info', x + 9, 51, 12, 'warning')
    c.setFont('PJS-SB', 9)
    c.setFillColor(col('ink'))
    c.drawString(x + 27, 53.5, 'Independent student project. Not an official government service.')


def page_recap(c):
    header(c, 2, 'Context')
    title(c, '01 · Product recap', 'One missing stamp means one more trip to the office.')
    cols = [
        ('error_outline', 'The problem', 'errorContainer', 'error', [
            'Requirements are scattered across counters, word of mouth and old social-media posts.',
            'A missing document, stamp or the wrong office means coming back another day.',
            'Offices work Sunday to Thursday, so every extra trip costs a morning or a day off.',
        ]),
        ('groups', 'Who it is for', 'indigoBg', 'indigo', [
            'Students and young adults who just became independent, handling their first files alone.',
            'Arabic / French bilingual readers; many prefer an Arabic, right-to-left interface.',
            'Entry-level Android phones (2 GB RAM, Android 10) and patchy mobile data.',
        ]),
        ('check_circle', 'What DocuDZ gives', 'primaryContainer', 'primary', [
            'One offline checklist per service, ticked as documents are gathered.',
            'Where to get each document, and the order of steps.',
            'The stamp total in DZD, the right office and its opening days.',
            'A "Last verified" date on every list, and Report an error.',
        ]),
    ]
    cw = (W - 2 * M - 2 * 18) / 3
    top = 430
    for i, (ic, head, bg, fg, items) in enumerate(cols):
        x = M + i * (cw + 18)
        card(c, x, 136, cw, top - 136)
        icon_badge(c, ic, x + 32, top - 30, 16, bg, fg)
        c.setFont('PJS-XB', 15)
        c.setFillColor(col('ink'))
        c.drawString(x + 58, top - 35, head)
        bullet_list(c, x + 20, top - 62, cw - 38, items, size=10.8, gap=9)
    x = M + cw + 18
    rrect(c, x + 16, 150, cw - 32, 80, 10, fill=col('surfaceLow'))
    para(c, '<b>Amina, 18</b>: first university registration, far from home.<br/>'
            '<b>Yacine, 23</b>: first job, needs CNAS, then a passport.',
         x + 28, 220, cw - 56, style(9.8, 14, 'ink'))
    rrect(c, M, 48, W - 2 * M, 72, 16, fill=col('primary'))
    brand_mark(c, M + 18, 66, 38, on_dark=True)
    c.setFont('PJS-XB', 17)
    c.setFillColor(white)
    c.drawString(M + 70, 90, 'Arrive at the counter with a complete file, the first time.')
    c.setFont('PJS', 10.5)
    c.setFillColor(col('mint'))
    c.drawString(M + 70, 70, 'What it is not: an official service. It submits nothing, needs no account, and works without internet.')
    footer(c)


def page_journey(c):
    header(c, 3, 'Principles & journey')
    title(c, '02 · Design principles', 'Calm, trustworthy, and built to save trips.')
    principles = [
        ('palette', 'Calm, not clinical', 'Warm paper background, deep teal, a single apricot accent. Generous 8-pt spacing and reassuring microcopy ("All set!").'),
        ('verified', 'Trust is visible', 'A dated "Last verified" stamp on every list, "Not an official service" on key screens, Report an error one tap away.'),
        ('cloud_off', 'Offline by default', 'All content is bundled. No login, no spinners, no network error states to design around.'),
        ('directions_walk', 'Fewer trips', 'Each document says where to get it; steps are ordered to group visits; tips flag classic return-trip traps.'),
    ]
    cw = (W - 2 * M - 3 * 14) / 4
    for i, (ic, head, body) in enumerate(principles):
        x = M + i * (cw + 14)
        card(c, x, 318, cw, 108)
        icon_badge(c, ic, x + 26, 400, 13)
        c.setFont('PJS-XB', 12)
        c.setFillColor(col('ink'))
        c.drawString(x + 46, 396, head)
        para(c, body, x + 14, 380, cw - 28, style(9, 12.4, 'muted'))

    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(M, 296, 'USER JOURNEY  ·  FROM "I NEED A PASSPORT" TO "I ARRIVE WITH A COMPLETE FILE"')
    steps = [
        ('01_home', 'Home', 'Pick "Passport", or search.'),
        ('02_checklist', 'Checklist', 'Tick what I already have: 6 of 9.'),
        ('04_steps', 'Steps', 'Know the order; read the trip-saving tips.'),
        ('03_costs', 'Costs', 'Total to bring: 6,950 DZD.'),
        ('05_office', 'Office', 'Right daïra, open Sunday to Thursday.'),
    ]
    ph = 182
    pw = phone_width(ph)
    y_ph = 94
    y_mid = y_ph + ph / 2
    start_w, end_w = 96, 112
    gap = (W - 2 * M - start_w - end_w - 5 * pw) / 6
    rrect(c, M, y_mid - 24, start_w, 48, 24, fill=col('secondaryContainer'))
    para(c, '<b>"I need a<br/>passport"</b>', M + 6, y_mid + 13, start_w - 12, style(9.6, 12, 'ink', align=TA_CENTER))

    def arrow(x1, x2):
        c.setStrokeColor(col('primary'))
        c.setLineWidth(1.4)
        c.line(x1, y_mid, x2 - 5, y_mid)
        c.setFillColor(col('primary'))
        p = c.beginPath()
        p.moveTo(x2 - 6, y_mid + 4)
        p.lineTo(x2, y_mid)
        p.lineTo(x2 - 6, y_mid - 4)
        p.close()
        c.drawPath(p, fill=1, stroke=0)

    x = M + start_w + gap
    for i, (name, head, body) in enumerate(steps):
        arrow(x - gap + 4, x - 4)
        phone(c, 'en', name, x, y_ph, ph)
        marker(c, x + pw - 3, y_ph + ph - 3, i + 1)
        c.setFont('PJS-XB', 10)
        c.setFillColor(col('ink'))
        c.drawCentredString(x + pw / 2, y_ph - 16, head)
        para(c, body, x + pw / 2 - (pw + gap - 8) / 2, y_ph - 21, pw + gap - 8, style(8.2, 10.5, 'muted', align=TA_CENTER))
        x += pw + gap
    arrow(x - gap + 4, W - M - end_w - 2)
    rrect(c, W - M - end_w, y_mid - 24, end_w, 48, 24, fill=col('primary'))
    para(c, '<b>"I arrive with a<br/>complete file"</b>', W - M - end_w + 6, y_mid + 13, end_w - 12, style(9.6, 12, 'card', align=TA_CENTER))
    footer(c)


def page_ia(c):
    header(c, 4, 'Information architecture')
    title(c, '03 · Navigation map', 'Four tabs to browse, focused flows to act.', w=600)

    def box(x, y, w, h, head, sub=None, fill='card', stroke='hairline', fg='ink', code=None):
        rrect(c, x, y, w, h, 10, fill=col(fill), stroke=col(stroke), lw=0.9)
        c.setFont('PJS-B', 9.6)
        c.setFillColor(col(fg))
        c.drawString(x + 10, y + h - 16, head)
        if code:
            tw = pdfmetrics.stringWidth(code, 'PJS-XB', 8) + 10
            rrect(c, x + w - tw - 6, y + h - 19, tw, 13, 6.5, fill=col('accent'))
            c.setFont('PJS-XB', 8)
            c.setFillColor(col('ink'))
            c.drawString(x + w - tw - 1, y + h - 15, code)
        if sub:
            c.setFont('PJS', 8.2)
            c.setFillColor(col('muted') if fg == 'ink' else col('mint'))
            c.drawString(x + 10, y + 8, sub)

    def link(x1, y1, x2, y2, dashed=False):
        c.saveState()
        c.setStrokeColor(col('outline'))
        c.setLineWidth(1)
        if dashed:
            c.setDash(3, 3)
        c.line(x1, y1, x2, y2)
        c.restoreState()

    # Level 0
    box(M, 382, 150, 40, 'Onboarding', 'first launch: pick language', fill='surfaceLow')
    link(M + 150, 402, M + 180, 402)
    box(M + 180, 382, 300, 40, 'App shell · bottom navigation', 'Home · Costs · Offices · Settings', fill='primary', stroke='primary', fg='card')
    # Tabs
    tabs = [('Home', 'S1', 'services, search, continue'), ('Costs', 'S3', 'calculator, any service'),
            ('Offices', 'S5', 'per wilaya, open now'), ('Settings', 'S6', 'language, trust, about')]
    tw = (480 - 3 * 10) / 4
    for i, (n, code, sub) in enumerate(tabs):
        x = M + i * (tw + 10)
        link(M + 330, 382, x + tw / 2, 352)
        box(x, 304, tw, 48, n, None, code=code)
        c.setFont('PJS', 7.8)
        c.setFillColor(col('muted'))
        c.drawString(x + 10, 312, sub)
    # Checklist
    link(M + tw / 2, 304, M + tw / 2, 270)
    box(M, 222, 250, 48, 'Service checklist', 'progress, verified date, documents, report', code='S2', fill='primaryContainer', stroke='primary')
    subs = [('Steps', 'S4', 'timeline + tips'), ('Costs (this service)', 'S3', 'scoped calculator'),
            ('Office (this service)', 'S5', 'scoped office info'), ('Document sheet', None, 'where, copies, tip'),
            ('Report an error', None, 'offline queue')]
    sw = (W / 2 + 10 - M - 4 * 8) / 3
    for i, (n, code, sub) in enumerate(subs):
        row, colx = divmod(i, 3)
        x = M + colx * (sw + 8)
        y = 150 - row * 62
        link(M + 125, 222, x + sw / 2, y + 48, dashed=code is None)
        box(x, y, sw, 48, n, sub, code=code, fill='card' if code else 'surfaceLow')

    # Feature matrix
    mx = W / 2 + 70
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(mx, 430, 'SCREENS × FEATURES')
    rows = [('S1 Home', {1, 2, 7, 8}), ('S2 Checklist', {1, 2, 4, 7}), ('S3 Costs', {3, 7}), ('S4 Steps', {4, 5, 7}),
            ('S5 Office', {6, 7}), ('S6 Settings', {7, 8}), ('Onboarding', {8}), ('Sheets', {4, 7})]
    cell = 30
    x0 = mx + 86
    y0 = 404
    for j in range(8):
        rrect(c, x0 + j * cell + 3, y0 - 3, cell - 6, 18, 9, fill=col('primary'))
        c.setFont('PJS-XB', 8.5)
        c.setFillColor(white)
        c.drawCentredString(x0 + j * cell + cell / 2, y0 + 2.5, f'F{j + 1}')
    for i, (name, fs) in enumerate(rows):
        y = y0 - 26 - i * 24
        if i % 2 == 0:
            rrect(c, mx - 4, y - 8, 86 + 8 * cell + 8, 22, 6, fill=col('surfaceLow'))
        c.setFont('PJS-SB', 9.2)
        c.setFillColor(col('ink'))
        c.drawString(mx + 2, y, name)
        for j in range(8):
            cx = x0 + j * cell + cell / 2
            if j + 1 in fs:
                c.setFillColor(col('primary'))
                c.circle(cx, y + 3.3, 5.2, fill=1, stroke=0)
            else:
                c.setFillColor(col('hairline'))
                c.circle(cx, y + 3.3, 2, fill=1, stroke=0)
    ly = 182
    for i, (code, label) in enumerate(FEATURES):
        x = mx + (i % 2) * 196
        y = ly - (i // 2) * 30
        c.setFont('PJS-XB', 9)
        c.setFillColor(col('primary'))
        c.drawString(x, y, code)
        para(c, label, x + 22, y + 9.5, 172, style(8.8, 11.5, 'ink'))
    footer(c)


def page_foundations(c):
    header(c, 5, 'Design system')
    title(c, '04 · Foundations', 'Tokens defined once in lib/theme/app_theme.dart.')
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(M, 424, 'COLOUR  ·  ALL TEXT PAIRS ≥ 4.5:1 (WCAG AA)')
    swatches = [
        ('primary', 'Primary', '#0E5F58', 'Actions, headers · 7.5:1 on white'),
        ('primaryDark', 'Primary dark', '#0A4A44', 'Gradient end · 10.1:1 with white'),
        ('primaryContainer', 'Mint', '#CFEAE4', 'Selected and ticked tiles'),
        ('accent', 'Apricot', '#F4A259', 'Progress, tips, logo (graphics only)'),
        ('secondary', 'Apricot ink', '#9A4A0B', 'Tip titles · 6.3:1 on white'),
        ('paper', 'Paper', '#F7F5F0', 'App background'),
        ('ink', 'Ink', '#1A2423', 'Body text · 14.6:1 on paper'),
        ('muted', 'Muted ink', '#4E5C5A', 'Secondary text · 6.4:1'),
        ('hairline', 'Hairline', '#DDD7CC', 'Card borders (decorative)'),
        ('outline', 'Outline', '#7A8784', 'Inputs, checkboxes · 3.7:1'),
        ('success', 'Success', '#1F7A3E', 'Ready, open now · 5.4:1'),
        ('warning', 'Warning', '#8A5A00', 'Notices, closed now'),
        ('error', 'Error', '#B3261E', 'Closed today, report · 6.5:1'),
    ]
    sw_w = 146
    for i, (k, name, hx, use) in enumerate(swatches):
        cx, row = i % 4, i // 4
        x = M + cx * (sw_w + 8)
        y = 370 - row * 56
        rrect(c, x, y, 40, 42, 8, fill=col(k), stroke=col('hairline'), lw=0.6)
        c.setFont('PJS-B', 9.2)
        c.setFillColor(col('ink'))
        c.drawString(x + 48, y + 32, name)
        c.setFont('PJS-SB', 8.2)
        c.setFillColor(col('primary'))
        c.drawString(x + 48, y + 20, hx)
        para(c, use, x + 48, y + 15, sw_w - 52, style(7.4, 9.2, 'muted'))
    x = M + 1 * (sw_w + 8)
    y = 370 - 3 * 56
    c.setFont('PJS-B', 9.2)
    c.setFillColor(col('ink'))
    c.drawString(x, y + 32, 'Service tints (≥ 5.5:1)')
    for i, (bg, fg, ic) in enumerate([('tealBg', 'primary', 'school'), ('indigoBg', 'indigo', 'flight_takeoff'),
                                       ('apricotBg', 'apricotFg', 'directions_car'), ('plumBg', 'plum', 'health_and_safety')]):
        rrect(c, x + i * 34, y - 2, 28, 28, 8, fill=col(bg))
        icon(c, ic, x + i * 34 + 6, y + 4.5, 16, fg)

    tx = M + 4 * (sw_w + 8) + 14
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(tx, 424, 'TYPE  ·  NOTHING BELOW 14 SP')
    scale = [('Display', 32, 'PJS-XB', '32 / 800'), ('Headline', 26, 'PJS-XB', '26 / 800'),
             ('Title L', 20, 'PJS-B', '20 / 700'), ('Title M', 16, 'PJS-B', '16 / 700'),
             ('Body L', 16, 'PJS', '16 / 400'), ('Body M · Label', 14, 'PJS', '14 / 400 · 600')]
    y = 404
    for name, size, font, spec in scale:
        s = size * 0.62
        c.setFont(font, s)
        c.setFillColor(col('ink'))
        c.drawString(tx, y - s, name)
        c.setFont('PJS-SB', 7.6)
        c.setFillColor(col('muted'))
        c.drawRightString(W - M, y - s + 1, spec)
        y -= s + 9
    c.setFont('AR-B', 17)
    c.setFillColor(col('ink'))
    c.drawRightString(W - M, y - 18, ar('أي ملف تحضر اليوم؟'))
    c.setFont('PJS', 7.8)
    c.setFillColor(col('muted'))
    c.drawString(tx, y - 16, 'IBM Plex Sans Arabic')
    para(c, '<b>Plus Jakarta Sans</b> (Latin) + <b>IBM Plex Sans Arabic</b>, bundled as static TTF weights '
            '(no google_fonts at runtime). Each family is the fallback of the other; Arabic line height +12%.',
         tx, y - 30, W - M - tx, style(8.2, 11, 'muted'))

    by = 128
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(M, by, 'SPACING  ·  8-PT GRID')
    x = M
    for v in [4, 8, 12, 16, 24, 32, 40]:
        rrect(c, x, by - 34, v * 0.9, 18, 2, fill=col('primary', 0.85))
        c.setFont('PJS-SB', 8)
        c.setFillColor(col('muted'))
        c.drawString(x, by - 48, str(v))
        x += v * 0.9 + 14
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(M + 250, by, 'RADIUS')
    x = M + 250
    for v, lab in [(8, 'chip 8'), (12, 'button 12'), (16, 'card 16'), (24, 'hero 24'), (28, 'sheet 28')]:
        rrect(c, x, by - 40, 34, 26, v * 0.5, fill=col('card'), stroke=col('primary'), lw=1)
        c.setFont('PJS-SB', 7.4)
        c.setFillColor(col('muted'))
        c.drawCentredString(x + 17, by - 52, lab)
        x += 44
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(M + 480, by, 'ELEVATION & ICONS')
    para(c, 'Cards are flat: 0 elevation + 1 px hairline. Only the bottom sheet and nav bar sit above content. '
            'Material Symbols, outlined / rounded, 24 dp, mirrored automatically when directional.',
         M + 480, by - 8, 210, style(8.2, 11, 'muted'))
    for i, ic in enumerate(['home', 'calculate', 'location_on', 'settings', 'verified', 'flag', 'lightbulb', 'offline_pin']):
        icon(c, ic, M + 702 + (i % 4) * 46, by - 26 - (i // 4) * 26, 18, 'primary')
    footer(c)


def page_components(c):
    header(c, 6, 'Design system')
    title(c, '05 · Components', 'Built once in lib/widgets/, reused on every screen.')
    L = 'en'
    S = 0.5  # pt per logical dp: one scale for every crop
    colw = (W - 2 * M - 3 * 14) / 4

    def merged(name, k1, k2):
        a, b = anchor(L, name, k1), anchor(L, name, k2)
        top = min(a[1], b[1])
        return [min(a[0], b[0]), top, max(a[0] + a[2], b[0] + b[2]) - min(a[0], b[0]), max(a[1] + a[3], b[1] + b[3]) - top]

    columns = [
        [('Service card · stamp · ring', '01_home', anchor(L, '01_home', 'home.card.university')),
         ('Continue card (hero)', '01_home', anchor(L, '01_home', 'home.continue')),
         ('Segmented service selector', '03_costs', anchor(L, '03_costs', 'costs.selector'))],
        [('Checklist tile · ticked', '02_checklist', anchor(L, '02_checklist', 'checklist.tile.0')),
         ('Checklist tile · unticked + issuing office', '02_checklist', anchor(L, '02_checklist', 'checklist.tile.2')),
         ('Status pill + address + primary button', '05_office', merged('05_office', 'office.status', 'office.maps'))],
        [('Step tile + "avoid an extra trip" tip', '04_steps', anchor(L, '04_steps', 'steps.tile.0')),
         ('Sticky TOTAL bar', '03_costs', anchor(L, '03_costs', 'costs.total'))],
        [('Fee group · optional item · subtotal', '03_costs', anchor(L, '03_costs', 'costs.official')),
         ('"Last verified" stamp, on a teal header', '02_checklist', anchor(L, '02_checklist', 'checklist.verified')),
         ('Offline chip', '01_home', anchor(L, '01_home', 'home.offline'))],
    ]
    for ci, items in enumerate(columns):
        x = M + ci * (colw + 14)
        y = 424
        for label, name, rect in items:
            r = list(rect)
            if r[0] == 0:  # full-bleed elements: keep side margins out of the crop
                r = [8, r[1], r[2] - 16, r[3]]
            img, ratio = crop_img(L, name, r, pad=3, scale=0.9)
            w = min(colw, (r[2] + 6) * S)
            h = w / ratio
            c.setFont('PJS-B', 8.4)
            c.setFillColor(col('muted'))
            c.drawString(x, y, label)
            y -= 6
            c.saveState()
            p = c.beginPath()
            p.roundRect(x, y - h, w, h, 7)
            c.clipPath(p, stroke=0, fill=0)
            c.drawImage(img, x, y - h, w, h)
            c.restoreState()
            rrect(c, x, y - h, w, h, 7, stroke=col('hairline'), lw=0.6)
            y -= h + 18
        if ci == 2:
            c.setFont('PJS-B', 8.4)
            c.setFillColor(col('muted'))
            c.drawString(x, y, 'Bottom sheet · 28 dp radius, one primary action')
            full = Image.open(SHOTS / L / '02c_document_sheet.png')
            top = int(full.height * 0.43)
            crop = full.crop((0, top, full.width, full.height - int(16 * DPR))).convert('RGB')
            crop = crop.resize((crop.width // 2, crop.height // 2), Image.LANCZOS)
            buf = io.BytesIO()
            crop.save(buf, 'JPEG', quality=90, subsampling=0)
            buf.seek(0)
            ratio = crop.width / crop.height
            hh = y - 6 - 42
            ww = min(colw, hh * ratio)
            hh = ww / ratio
            c.saveState()
            p = c.beginPath()
            p.roundRect(x, y - 6 - hh, ww, hh, 7)
            c.clipPath(p, stroke=0, fill=0)
            c.drawImage(ImageReader(buf), x, y - 6 - hh, ww, hh)
            c.restoreState()
            rrect(c, x, y - 6 - hh, ww, hh, 7, stroke=col('hairline'), lw=0.6)
    footer(c)


def screen_page(c, n, code, kicker, head, purpose, feats, main, markers, notes, secondary=None,
                sec_markers=(), sec_caption=None, extra=None):
    header(c, n, f'{code} · screen')
    ph = 446
    phone(c, 'en', main, M + 4, 48, ph, markers)
    x_text = M + 4 + phone_width(ph) + 26
    if secondary:
        sh = 360
        phone(c, 'en', secondary, x_text, 82, sh, sec_markers, caption=sec_caption, caption_w=phone_width(sh) + 10)
        x_text += phone_width(sh) + 30
    tw = W - M - x_text
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(x_text, H - 72, kicker.upper())
    h = para(c, head, x_text, H - 78, tw, style(21, 24, 'ink', 'PJS-XB'))
    y = H - 84 - h
    h = para(c, purpose, x_text, y, tw, style(10, 14, 'muted'))
    y -= h + 10
    tags(c, x_text, y - 9, feats)
    y -= 26
    y = annotations(c, x_text, y, tw, notes)
    if extra:
        extra(c, x_text, y, tw)
    footer(c)


def page_s1(c):
    screen_page(
        c, 7, 'S1', 'S1 · Home / service catalogue', 'Start from the file, not the administration.',
        'Greeting, one search field, a "continue" shortcut and the four services with their progress.',
        ['F1', 'F2', 'F7', 'F8'], '01_home',
        [(1, 'home.offline', 0, 0.5, -16, 0), (2, 'home.search', 1, 0.5, -26, 0), (3, 'home.continue', 1, 0, -16, 2),
         (4, 'home.card.university', 0, 0, 6, 6), (5, 'home.card.university', 0, 0, 262, 82), (6, 'nav', 0, 0, 8, 10)],
        [
            (1, 'Offline status, always visible', 'A calm green chip confirms everything works without data. No spinners, no error screens.', ['F1']),
            (2, 'One question, one search', 'Matches services and individual documents ("birth" finds 4 checklists). Empty state designed.', ['F1']),
            (3, 'Continue where you left off', 'Shows 67% and the next missing document, so a returning user acts in one tap.', ['F2']),
            (4, 'Service card with done/total ring', 'Own tint and icon per service; the ring prints 3/8, so colour is never the only cue.', ['F1', 'F2']),
            (5, 'Last-verified stamp on every card', 'The dashed "rubber stamp" badge is the product\'s promise: dated, checked content.', ['F7']),
            (6, 'Four-tab navigation', 'Home, Costs, Offices, Settings. Labels always shown at 14 sp; a 4-tab maximum keeps it simple.', ['F3', 'F6', 'F8']),
            (7, '"Not an official service" footer', 'Repeated on Home, Checklist, Steps, Onboarding and Settings. No flags or emblems anywhere.', ['Trust']),
        ],
        secondary='01b_home_scrolled', sec_markers=[(7, 'home.notice', 0, 0.5, 14, 0)],
        sec_caption='Scrolled: all four services, then the trust footer.')


def page_s2(c):
    screen_page(
        c, 8, 'S2', 'S2 · Interactive checklist', 'Tick what you have. See what is missing.',
        'One list per service with progress, the verified date, where each document is issued, and a detail sheet.',
        ['F2', 'F4', 'F7'], '02_checklist',
        [(1, 'checklist.header', 1, 1, -26, -24), (2, 'checklist.verified', 1, 0.5, 18, 0), (3, 'checklist.quick', 0, 0, 6, 4),
         (4, 'checklist.tile.0', 1, 1, -26, -26), (5, 'checklist.tile.2', 1, 1, -26, -26), (6, 'checklist.flag', 0, 0.5, -12, 0)],
        [
            (1, 'Progress at a glance', '"6 of 9 documents ready", 67% and an apricot bar. Ticks are saved on the phone only.', ['F2']),
            (2, 'Last verified: full date', 'On every checklist header. Accuracy is the product, so freshness is never hidden.', ['F7']),
            (3, 'Steps · Costs · Office', 'One tap each, already scoped to this service: no re-selecting "Passport".', ['F3', 'F5', 'F6']),
            (4, 'Ticked state', 'Filled checkbox, mint tile and a "Ready" pill with an icon: readable without colour.', ['F2']),
            (5, 'Unticked state + issuing office', '"To get" pill, copies needed, and "Issued by: Town hall (APC) of your residence".', ['F2', 'F4']),
            (6, 'Report an error', 'Flag in the app bar plus a full-width button at the end of the list. Works offline (queued).', ['F7']),
            (7, 'Document detail sheet', 'Tap a row: where to get it, copies, a tip and one primary action, "Mark as gathered".', ['F4']),
        ],
        secondary='02c_document_sheet', sec_markers=[(7, None, 0, 0, 380, 440)],
        sec_caption='Bottom sheet: Fiscal stamp details.')


def _costs_math(c, x, y, w):
    y -= 4
    rrect(c, x, y - 112, w, 112, 12, fill=col('card'), stroke=col('hairline'), lw=0.8)
    c.setFont('PJS-B', 9)
    c.setFillColor(col('primary'))
    c.drawString(x + 12, y - 16, 'How the passport total is computed (sample data)')
    rows = [('Fiscal stamp, 28-page booklet', '6,000'), ('Biometric photos  4 × 100', '400'),
            ('Blood group test (optional, on)', '500'), ('Photocopies  5 × 10', '50'),
            ('Upgrade to 48 pages (optional, off)', '+6,000 not added')]
    yy = y - 32
    for label, v in rows:
        c.setFont('PJS', 8.6)
        c.setFillColor(col('muted') if 'off' in label else col('ink'))
        c.drawString(x + 12, yy, label)
        c.drawRightString(x + w - 12, yy, v)
        yy -= 13
    c.setStrokeColor(col('hairline'))
    c.line(x + 12, yy + 8, x + w - 12, yy + 8)
    c.setFont('PJS-XB', 10)
    c.setFillColor(col('primary'))
    c.drawString(x + 12, yy - 4, 'Total to bring')
    c.drawRightString(x + w - 12, yy - 4, '6,950 DZD')


def page_s3(c):
    screen_page(
        c, 9, 'S3', 'S3 · Stamp cost calculator', 'Know the total before leaving home.',
        'Per-stamp line items in DZD, optional items and quantities, subtotals and an always-visible TOTAL.',
        ['F3', 'F7'], '03_costs',
        [(1, 'costs.selector', 0, 0, 22, 6), (2, 'costs.note', 0, 0, 236, 14), (3, 'costs.official', 1, 0, -26, 24),
         (4, 'costs.official', 0, 0, 262, 120), (5, 'costs.other', 0, 0, 258, 114), (6, 'costs.total', 0, 0.5, 192, 0)],
        [
            (1, 'Service switcher', 'Four equal segments with icon and short name: always fully visible, in every language.', ['F3']),
            (2, 'Last verified + "Fees may change"', 'The caveat sits above the numbers, next to the verified date, not in fine print.', ['F7']),
            (3, 'Stamps & official fees', 'Where to buy each stamp, amounts end-aligned in tabular figures, then a subtotal row.', ['F3']),
            (4, 'Optional items', 'A checkbox adds them. When off, the row shows what it would add (+6,000 DZD) in muted ink.', ['F3']),
            (5, 'Quantity steppers', '48 dp minus / plus buttons for photos and copies; totals update instantly.', ['F3']),
            (6, 'Sticky TOTAL', 'Largest number on screen, always above the tab bar, with the official / other split.', ['F3']),
        ],
        extra=_costs_math)


def page_s4(c):
    screen_page(
        c, 10, 'S4', 'S4 · Step-by-step process', 'The right order is half the work.',
        'An ordered timeline: what to do, where to go, and tips that prevent the classic return trip.',
        ['F5', 'F4', 'F7'], '04_steps',
        [(1, 'steps.header', 1, 0, -26, 26), (2, 'steps.tile.0', 0, 0, 20, 64), (3, 'steps.tile.0', 1, 0, -6, 52),
         (4, 'steps.tile.0', 1, 1, -18, -100)],
        [
            (1, 'Summary first', 'Number of steps, expected office visits and the verified date, before any detail.', ['F5', 'F7']),
            (2, 'Numbered timeline rail', 'Connected circles, the first one filled. The rail sits on the start side, so it moves right in Arabic.', ['F5']),
            (3, 'Where to go, per step', 'Each step names its place (national service office, town hall, post office, daïra).', ['F4', 'F5']),
            (4, '"Tip to avoid an extra trip"', 'Apricot is reserved for trip-saving advice, so these callouts stand out from everything else.', ['F5']),
            (5, 'Order that saves trips', 'Prerequisites first: e.g. buy the fiscal stamp before the daïra, where it is rarely sold.', ['F5']),
        ],
        secondary='04b_steps_scrolled', sec_markers=[(5, 'steps.tile.4', 1, 0, -26, 8)],
        sec_caption='Scrolled: submission and collection.')


def page_s5(c):
    screen_page(
        c, 11, 'S5', 'S5 · Office information', 'The right office, on the right day.',
        'Pick a wilaya: office name, address, opening days and a live open / closed status, all offline.',
        ['F6', 'F7'], '05_office',
        [(1, 'office.wilaya', 1, 0.5, -64, 0), (2, 'office.map', 1, 0, -26, 26), (3, 'office.status', 1, 0.5, 20, 0),
         (4, 'office.maps', 0, 0.5, 26, 0), (5, 'office.hours', 1, 0, -26, 24)],
        [
            (1, 'Wilaya selector', 'Code + name ("16 · Algiers"), as people say it. Sample data: 3 wilayas; v1 targets all 58.', ['F6']),
            (2, 'Offline map placeholder', 'Vector streets and a pin drawn on-device: no network, no image weight, clearly labelled.', ['F6']),
            (3, 'Open now / closed today', 'Computed on the phone from the hours and the clock; icon + text + colour.', ['F6']),
            (4, 'Open in Maps', 'Hands the address to the phone\'s Maps app (geo: intent) instead of embedding a map SDK.', ['F6']),
            (5, 'Opening days & hours', 'Sunday-first week (Algerian working week); today highlighted with a "Today" badge.', ['F6']),
            (6, 'Closed-today state', 'On a Friday the pill turns red with a calendar icon and the table marks the day closed.', ['F6']),
        ],
        secondary='05b_office_closed', sec_markers=[(6, 'office.status', 1, 0.5, 20, 0)],
        sec_caption='Friday: closed today.')


def page_s6(c):
    screen_page(
        c, 12, 'S6', 'S6 · Settings & trust', 'Language, honesty and freshness in one place.',
        'Language switch, the not-official notice, content date and update check, privacy, and a quiet Premium teaser.',
        ['F8', 'F7'], '06_settings',
        [(1, 'settings.language', 1, 0, -74, 32), (2, 'settings.notice', 1, 0, -22, 22), (3, 'settings.content', 1, 0, -22, 24)],
        [
            (1, 'Language, in its own script', 'Arabic, Français, English, each written in its own script. Switching is instant and flips the whole app to right-to-left.', ['F8']),
            (2, 'Not an official service', 'Plain-language disclaimer: independent, submits nothing, always confirm at the office.', ['Trust']),
            (3, 'Content freshness', 'Last content update, content version and "Check for updates".', ['F7']),
            (4, 'Privacy promise', 'Only ticks and language are stored, on the phone. No account, no tracking.', ['Trust']),
            (5, 'Premium teaser, deliberately quiet', 'Outlined, muted, non-interactive, "Coming later": 500 DZD / year, ad-free, profiles, reminders. Not in v1.', ['Later']),
        ],
        secondary='06b_settings_scrolled',
        sec_markers=[(4, 'settings.premium', 1, 0, -4, -92), (5, 'settings.premium', 1, 0, -22, 22)],
        sec_caption='Scrolled: privacy, Premium, About.')


def page_rtl(c):
    header(c, 13, 'Arabic · RTL')
    title(c, '06 · Right-to-left showcase', 'Arabic is a first-class layout, not a translation.')
    pairs = [
        ('02_checklist', 'Checklist', 'Checkbox moves to the right, chevrons point left, the back arrow points right; the progress bar fills from the right.'),
        ('03_costs', 'Costs', 'Amounts sit on the end (left) side; the "+6 000" sign stays attached thanks to a bidi mark; Western digits, as used in Algeria.'),
        ('04_steps', 'Steps', 'The timeline rail and numbered circles move to the right edge; tips and place icons follow the reading direction.'),
    ]
    ph = 290
    pw = phone_width(ph)
    pair_w = 2 * pw + 6
    gap = (W - 2 * M - 3 * pair_w) / 2
    for i, (name, head, body) in enumerate(pairs):
        x = M + i * (pair_w + gap)
        phone(c, 'en', name, x, 140, ph)
        phone(c, 'ar', name, x + pw + 6, 140, ph)
        c.setFont('PJS-B', 8)
        c.setFillColor(col('muted'))
        c.drawCentredString(x + pw / 2, 129, 'EN · LTR')
        c.drawCentredString(x + pw + 6 + pw / 2, 129, 'AR · RTL')
        c.setFont('PJS-XB', 11)
        c.setFillColor(col('ink'))
        c.drawString(x, 110, head)
        para(c, body, x, 104, pair_w, style(8.6, 11.6, 'muted'))
    rrect(c, M, 35, W - 2 * M, 38, 10, fill=col('primaryContainer'))
    icon(c, 'format_textdirection_r_to_l', M + 10, 47, 15, 'primary')
    para(c, '<b>How:</b> only EdgeInsetsDirectional, AlignmentDirectional and start / end in the code, no hardcoded left / right. '
            'Directional icons mirror automatically. The DocuDZ wordmark, times and fractions like 3/8 stay left-to-right.',
         M + 32, 66, W - 2 * M - 44, style(8.6, 11.5, 'ink'))
    footer(c)


def page_multilingual(c):
    header(c, 14, 'Localisation')
    title(c, '07 · Multilingual', 'Same screen, three languages, switched at runtime.')
    ph = 382
    pw = phone_width(ph)
    for i, (lang, lab) in enumerate([('ar', 'العربية'), ('fr', 'Français'), ('en', 'English')]):
        x = M + i * (pw + 16)
        phone(c, lang, '01_home', x, 46, ph)
        if lang == 'ar':
            c.setFont('AR-B', 11)
            c.setFillColor(col('ink'))
            c.drawCentredString(x + pw / 2, 436, ar(lab))
        else:
            c.setFont('PJS-B', 10)
            c.setFillColor(col('ink'))
            c.drawCentredString(x + pw / 2, 437, lab)
    x = M + 3 * (pw + 16) + 14
    keys = [k for k in json.loads((PROJ / 'lib' / 'l10n' / 'app_en.arb').read_text(encoding='utf-8')) if not k.startswith('@')]
    bullet_list(c, x, 424, W - M - x, [
        f'<b>flutter_localizations + intl</b>: three ARB files (ar, fr, en), <b>{len(keys)} keys</b>, generated with gen-l10n. Content (documents, offices, fees) is localised in the bundled JSON.',
        '<b>ICU plurals</b>, including the Arabic forms (one, dual, 3 to 10, 11+): "1 copy", "2 copies" and "4 copies" each get their own Arabic wording.',
        '<b>Algerian conventions</b>: Western digits 0-9, ar_DZ month names, currency DZD (EN) / DA (FR) / Arabic dinar abbreviation (AR), week starting Sunday.',
        '<b>French runs ~20% longer</b>: every row wraps or ellipsizes. Tests fail on any overflow: 0 found in 51 renders and at 130% text size.',
        '<b>Fonts</b>: Plus Jakarta Sans for Latin, IBM Plex Sans Arabic for Arabic, each the fallback of the other, so mixed Latin / Arabic lines render correctly.',
        '<b>Instant switch</b> from Settings or Onboarding; no restart, no theme cross-fade.',
    ], size=9.3, gap=8)
    footer(c)


def page_states(c):
    header(c, 15, 'States & extras')
    title(c, '08 · Key states and edge cases', 'Designed beyond the happy path.')
    items = [
        ('07_onboarding', 'Onboarding', 'Language first, with the value in three lines. Shown on first launch only.'),
        ('02d_checklist_allset', '"All set!"', 'A full checklist turns into a green celebration banner and a check ring.'),
        ('02e_report_sheet', 'Report an error', 'Category chips, optional text; queued offline and sent later.'),
        ('08_search_empty', 'Empty search', 'Friendly empty state with example queries instead of a blank list.'),
        ('05b_office_closed', 'Closed today', 'Red pill + calendar icon; Friday flagged as closed in the week table.'),
    ]
    ph = 318
    pw = phone_width(ph)
    gap = (W - 2 * M - 5 * pw) / 4
    for i, (name, head, body) in enumerate(items):
        x = M + i * (pw + gap)
        phone(c, 'en', name, x, 112, ph)
        c.setFont('PJS-XB', 10.5)
        c.setFillColor(col('ink'))
        c.drawString(x, 96, head)
        para(c, body, x, 90, pw + 6, style(8.6, 11.5, 'muted'))
    footer(c)


def page_a11y_perf(c):
    header(c, 16, 'Quality')
    title(c, '09 · Accessibility and performance', 'Made for every reader and a 2 GB phone.')
    fonts_mb = sum(f.stat().st_size for f in FONTS.glob('*.ttf')) / 1e6
    stats = [
        (str(TESTS_TOTAL), 'automated tests pass', 'check_circle'),
        ('0', 'layout overflows found', 'visibility'),
        ('48 dp', 'min touch target', 'touch_app'),
        ('14 sp', 'smallest text', 'text_fields'),
        ('0', 'bitmap images in UI', 'palette'),
        (f'{fonts_mb:.1f} MB', 'all bundled fonts', 'storage'),
    ]
    sw = (W - 2 * M - 5 * 10) / 6
    for i, (v, lab, ic) in enumerate(stats):
        x = M + i * (sw + 10)
        card(c, x, 352, sw, 66)
        icon(c, ic, x + 12, 392, 16, 'primary')
        c.setFont('PJS-XB', 18)
        c.setFillColor(col('ink'))
        c.drawString(x + 34, 390, v)
        c.setFont('PJS', 8.2)
        c.setFillColor(col('muted'))
        c.drawString(x + 12, 364, lab)
    cw = (W - 2 * M - 20) / 2
    for j, (head, ic, items) in enumerate([
        ('Accessibility', 'accessibility_new', [
            '<b>Touch targets ≥ 48 dp</b> for checkboxes, steppers and buttons, enforced by Flutter\'s androidTapTargetGuideline test on 5 screens.',
            '<b>Text ≥ 14 sp</b> everywhere, chips and nav labels included (no shrinking floating labels). At 130% system text size nothing overflows (tested in FR and AR).',
            '<b>WCAG AA contrast</b> for every text pair; pixel-checked by textContrastGuideline on Home, Office and Checklist.',
            '<b>Never colour alone</b>: ticked = checkbox + "Ready" + icon; open / closed = icon + words; the progress ring prints 3/8.',
            '<b>Screen readers</b>: labels on checkboxes ("Birth certificate, Ready"), progress and selectors; the total is a live region.',
        ]),
        ('Performance & offline-first', 'speed', [
            '<b>No images</b>: logo, map placeholder, rings and stamps are CustomPaint vectors; icons come from the tree-shaken Material font.',
            '<b>Small footprint</b>: static font weights only, ~60 KB content JSON, no network, analytics or google_fonts packages. Target APK well under 30 MB.',
            '<b>Cheap rendering</b>: static progress bars, InkRipple instead of InkSparkle, fade page transitions, no theme cross-fade on language switch.',
            '<b>Offline by design</b>: SQLite seeded from bundled JSON; the only optional network touchpoints are "Check for updates" and sending queued reports.',
            '<b>Light state</b>: one ChangeNotifier and 4 light tabs; only ticks and language are persisted.',
        ]),
    ]):
        x = M + j * (cw + 20)
        icon_badge(c, ic, x + 14, 322, 13)
        c.setFont('PJS-XB', 13)
        c.setFillColor(col('ink'))
        c.drawString(x + 34, 317, head)
        bullet_list(c, x + 4, 298, cw - 8, items, size=9, gap=5)
    # contrast strip
    pairs = [('ink', 'paper', '14.6'), ('muted', 'paper', '6.4'), ('card', 'primary', '7.5'),
             ('primary', 'primaryContainer', '5.9'), ('secondary', 'card', '6.3'), ('success', 'successContainer', '7.2'),
             ('warning', 'warningContainer', '7.2'), ('error', 'card', '6.5')]
    pw_ = (W - 2 * M - 7 * 8) / 8
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(M, 86, 'TEXT CONTRAST SAMPLES  ·  WCAG AA NEEDS 4.5:1')
    for i, (fg, bg, ratio) in enumerate(pairs):
        x = M + i * (pw_ + 8)
        rrect(c, x, 42, pw_, 34, 8, fill=col(bg), stroke=col('hairline'), lw=0.6)
        c.setFont('PJS-XB', 13)
        c.setFillColor(col(fg if fg != 'warning' else 'warning'))
        c.drawString(x + 10, 53, 'Aa')
        c.setFont('PJS-B', 9)
        c.drawRightString(x + pw_ - 10, 54, f'{ratio}:1')
    footer(c, note=False)


def page_next(c):
    header(c, 17, 'Roadmap')
    title(c, '10 · Next steps to the MVP (26 November 2026)', 'UI is built; data and device work remain.')
    rows = [
        ('F1', 'Offline checklist per service', 'Built', 'SQLite seeded from bundled JSON (sqflite)'),
        ('F2', 'Tick-off, progress saved', 'Built', 'Persist ticks in SQLite (in-memory today)'),
        ('F3', 'Stamp cost calculator', 'Built', 'Verified amounts per service'),
        ('F4', 'Where to get each document', 'Built', 'Verified issuing offices'),
        ('F5', 'Step-by-step + tips', 'Built', 'Verified order and tips'),
        ('F6', 'Office info per wilaya', 'Built', 'All 58 wilayas; geo: intent via url_launcher'),
        ('F7', 'Last verified + Report an error', 'Built', 'Report queue + send (mailto / form)'),
        ('F8', 'Language switch AR / FR / EN', 'Built', 'Persist choice; native-speaker review'),
    ]
    x0, y = M, 420
    widths = [40, 220, 70, 250]
    heads = ['', 'Feature', 'UI', 'Remaining for v1']
    xs = [x0]
    for wdt in widths[:-1]:
        xs.append(xs[-1] + wdt)
    rrect(c, x0, y - 6, sum(widths), 22, 8, fill=col('primary'))
    for hx, hd in zip(xs, heads):
        c.setFont('PJS-B', 9)
        c.setFillColor(white)
        c.drawString(hx + 8, y + 1, hd)
    y -= 26
    for i, (code, feat, ui, rem) in enumerate(rows):
        if i % 2 == 0:
            rrect(c, x0, y - 8, sum(widths), 24, 6, fill=col('surfaceLow'))
        c.setFont('PJS-XB', 9.4)
        c.setFillColor(col('primary'))
        c.drawString(xs[0] + 8, y, code)
        c.setFont('PJS-SB', 9.4)
        c.setFillColor(col('ink'))
        c.drawString(xs[1] + 8, y, feat)
        rrect(c, xs[2] + 6, y - 4, 50, 15, 7.5, fill=col('successContainer'))
        icon(c, 'check', xs[2] + 10, y - 1.5, 10, 'success')
        c.setFont('PJS-B', 8.2)
        c.setFillColor(col('success'))
        c.drawString(xs[2] + 23, y, ui)
        c.setFont('PJS', 9)
        c.setFillColor(col('muted'))
        c.drawString(xs[3] + 8, y, rem)
        y -= 25
    tx = M + sum(widths) + 26
    tw = W - M - tx
    c.setFont('PJS-B', 9.5)
    c.setFillColor(col('secondary'))
    c.drawString(tx, 420, 'PLAN')
    plan = [
        ('12 Nov', 'UI/UX submission', 'This PDF + Flutter screens (6 core + 3 extras).', True),
        ('13-16 Nov', 'Data layer', 'sqflite repository, persisted ticks and language.', False),
        ('17-20 Nov', 'Content verification', 'Check the 4 services against official sources; office list.', False),
        ('21-23 Nov', 'Hand-offs', 'Report queue, Open in Maps, content-update check.', False),
        ('24-25 Nov', 'Device testing', '2 GB Android 10 phone, TalkBack pass, APK size check.', False),
        ('26 Nov', 'MVP release', 'Signed APK and release notes.', False),
    ]
    y = 398
    for i, (d, head, body, done) in enumerate(plan):
        c.setFillColor(col('primary') if done else col('card'))
        c.setStrokeColor(col('primary'))
        c.setLineWidth(1.6)
        c.circle(tx + 7, y - 4, 6, fill=1, stroke=1)
        if i < len(plan) - 1:
            c.setStrokeColor(col('primary', 0.3))
            c.line(tx + 7, y - 11, tx + 7, y - 46)
        c.setFont('PJS-XB', 9)
        c.setFillColor(col('primary'))
        c.drawString(tx + 20, y - 7, d)
        c.setFont('PJS-B', 9.5)
        c.setFillColor(col('ink'))
        c.drawString(tx + 82, y - 7, head)
        para(c, body, tx + 82, y - 11, tw - 82, style(8.4, 11, 'muted'))
        y -= 52
    rrect(c, M, 52, sum(widths), 60, 12, fill=col('primaryContainer'))
    para(c, f'<b>Built already</b> (Flutter 3.47, Material 3): 6 core screens + onboarding, empty state and report sheet; '
            f'design-token theme; AR / FR / EN with runtime switch and full RTL; JSON mock repository; '
            f'flutter analyze clean; {TESTS_TOTAL} passing tests (behaviour, accessibility, 51 headless screenshots).',
         M + 14, 102, sum(widths) - 28, style(9.2, 13, 'ink'))
    footer(c, note=False)


def main():
    register_fonts()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    c = canvas.Canvas(str(OUT), pagesize=(W, H), pageCompression=1, initialFontName='PJS', initialFontSize=10)
    c.setTitle('DocuDZ: UI/UX Design Submission')
    c.setAuthor('DRIS Fadia, NEFRAOUI Marya (ENSIA)')
    c.setSubject('Potential designs for the DocuDZ app screens')
    pages = [page_cover, page_recap, page_journey, page_ia, page_foundations, page_components,
             page_s1, page_s2, page_s3, page_s4, page_s5, page_s6, page_rtl, page_multilingual,
             page_states, page_a11y_perf, page_next]
    assert len(pages) == TOTAL_PAGES
    for fn in pages:
        fn(c)
        c.showPage()
    c.save()
    print(f'{OUT}  {OUT.stat().st_size / 1e6:.2f} MB, {len(pages)} pages')


if __name__ == '__main__':
    main()
