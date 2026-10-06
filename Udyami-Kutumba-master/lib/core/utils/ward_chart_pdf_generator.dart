import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../models/ward_model.dart';
import '../models/ward_member_model.dart';

// ─── Colors matching the Web UI design ────────────────────────────────────
const _brickRed  = PdfColor.fromInt(0xFFC8102E);
const _navyInk   = PdfColor.fromInt(0xFF1A2E5E);
const _patronRed = PdfColor.fromInt(0xFFB5121B);
const _lightNavy = PdfColor.fromInt(0xFFEFF3FA);
const _lightRed  = PdfColor.fromInt(0xFFFDF2F3);
const _gold      = PdfColor.fromInt(0xFFFFC107);
const _cardBg    = PdfColor.fromInt(0xFFFAFAFA);

class WardChartPdfGenerator {

  // ── Concurrent profile image loader with network timeout & base64 support ─
  static Future<Map<String, Uint8List>> _preloadImages(
      Map<String, WardMemberModel> slots) async {
    final Map<String, Uint8List> result = {};
    await Future.wait(slots.entries.map((e) async {
      final img = e.value.profileImage;
      if (img == null || img.isEmpty) return;
      try {
        if (img.startsWith('data:image')) {
          final b64 = img.split(',').last;
          result[e.key] = const Base64Decoder().convert(b64);
        } else if (img.startsWith('http')) {
          final res = await http.get(Uri.parse(img))
              .timeout(const Duration(seconds: 6));
          if (res.statusCode == 200) result[e.key] = res.bodyBytes;
        }
      } catch (_) {}
    }));
    return result;
  }

  // ── Main PDF Generation Entry ─────────────────────────────────────────────
  static Future<Uint8List> generateWardChartPdf(
      WardModel ward, {
        Map<String, WardMemberModel>? assignedSlots,
      }) async {
    final slots = assignedSlots ?? {};

    // Pre-load images concurrently
    final imgBytes = await _preloadImages(slots);

    // App logo asset
    Uint8List? logoBytes;
    try {
      final d = await rootBundle.load('assets/logo/uk_logo_480x480.jpeg');
      logoBytes = d.buffer.asUint8List();
    } catch (_) {}

    final pdf = pw.Document(title: 'Ward Chart - ${ward.wardName}', author: 'Udyami Kutumba');

    // ── Helper: Avatar / Photo Container ─────────────────────────────────────
    pw.Widget photoBox(String slotId, {double size = 30, PdfColor borderColor = _navyInk}) {
      final bytes = imgBytes[slotId];
      if (bytes != null) {
        return pw.Container(
          width: size,
          height: size,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(color: borderColor, width: 1.2),
            image: pw.DecorationImage(
              image: pw.MemoryImage(bytes),
              fit: pw.BoxFit.cover,
            ),
          ),
        );
      }
      final member = slots[slotId];
      final initial = (member?.name.isNotEmpty == true) ? member!.name[0].toUpperCase() : '?';
      return pw.Container(
        width: size,
        height: size,
        decoration: pw.BoxDecoration(
          color: borderColor == _brickRed ? _lightRed : _lightNavy,
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: borderColor, width: 1.0),
        ),
        child: pw.Center(
          child: pw.Text(
            initial,
            style: pw.TextStyle(
              fontSize: size * 0.45,
              fontWeight: pw.FontWeight.bold,
              color: borderColor,
            ),
          ),
        ),
      );
    }

    // ── Standard Grid Slot Card (Matches ChartSlot.jsx) ──────────────────────
    pw.Widget slotCard(
        String slotId,
        String defaultLabel, {
          PdfColor borderColor = _navyInk,
          double width = 98,
          double height = 80,
          String? topBadge,
        }) {
      final member = slots[slotId];
      final assigned = member != null && member.name.isNotEmpty;
      final cardBgColor = assigned ? PdfColors.white : _cardBg;

      return pw.Container(
        width: width,
        height: height,
        padding: const pw.EdgeInsets.all(5),
        decoration: pw.BoxDecoration(
          color: cardBgColor,
          border: pw.Border.all(color: borderColor, width: assigned ? 1.4 : 0.8),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (topBadge != null) ...[
              pw.Text(
                topBadge,
                style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: borderColor),
                maxLines: 1,
              ),
              pw.SizedBox(height: 2),
            ],
            photoBox(slotId, size: height > 80 ? 32 : 28, borderColor: borderColor),
            pw.SizedBox(height: 4),
            pw.Text(
              assigned ? member.name.toUpperCase() : defaultLabel,
              style: pw.TextStyle(
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
                color: assigned ? PdfColors.black : borderColor,
              ),
              textAlign: pw.TextAlign.center,
              maxLines: 2,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              assigned
                  ? (member.companyName?.isNotEmpty == true ? member.companyName! : member.role)
                  : 'Unassigned',
              style: pw.TextStyle(
                fontSize: 6.0,
                color: assigned ? PdfColors.grey700 : PdfColors.grey500,
              ),
              textAlign: pw.TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      );
    }

    // ── Header Banner ────────────────────────────────────────────────────────
    pw.Widget headerBanner() {
      return pw.Container(
        color: _navyInk,
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(children: [
              if (logoBytes != null)
                pw.Container(
                  width: 28,
                  height: 28,
                  margin: const pw.EdgeInsets.only(right: 8),
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                ),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('UDYAMI BHARAT', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.Text('One Home. One Enterprise. One Strong Nation', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey300)),
              ]),
            ]),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: pw.BoxDecoration(color: _brickRed, borderRadius: pw.BorderRadius.circular(4)),
              child: pw.Text('WARD ${ward.wardNumber} — ${ward.wardName.toUpperCase()}',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            ),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text(ward.district.toUpperCase(), style: pw.TextStyle(fontSize: 7, color: PdfColors.grey300)),
              pw.Text(ward.state.toUpperCase(), style: pw.TextStyle(fontSize: 6, color: PdfColors.grey400)),
            ]),
          ],
        ),
      );
    }

    // ── Footer Bar ───────────────────────────────────────────────────────────
    pw.Widget footerBar(int pageNum) {
      return pw.Container(
        color: _navyInk,
        height: 22,
        padding: const pw.EdgeInsets.symmetric(horizontal: 16),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('UDYAMI KUTUMBA · ${ward.wardName.toUpperCase()} · ${ward.district.toUpperCase()}',
              style: pw.TextStyle(fontSize: 6, color: PdfColors.white)),
          pw.Text('PAGE 0$pageNum OF 05', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
        ]),
      );
    }

    // ── Section Title Banner ────────────────────────────────────────────────
    pw.Widget sectionHeader(String text, {PdfColor bg = _brickRed}) {
      return pw.Container(
        width: double.infinity,
        color: bg,
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: pw.Text(text, textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
      );
    }

    // ════════════════════════════════════════════════════════════════════════
    // PAGE 1 — COVER PAGE
    // ════════════════════════════════════════════════════════════════════════
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Container(
        color: PdfColors.white,
        child: pw.Column(children: [
          pw.Container(color: _navyInk, height: 8),
          pw.SizedBox(height: 40),
          if (logoBytes != null)
            pw.Center(child: pw.Container(width: 100, height: 100, child: pw.Image(pw.MemoryImage(logoBytes)))),
          pw.SizedBox(height: 24),
          pw.Text('UDYAMI BHARAT', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: _navyInk)),
          pw.SizedBox(height: 4),
          pw.Text('ಉದ್ಯಮಿ ಭಾರತ', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _brickRed)),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: pw.BoxDecoration(color: _lightNavy, borderRadius: pw.BorderRadius.circular(4)),
            child: pw.Text('ONE HOME · ONE ENTERPRISE · ONE STRONG NATION',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _navyInk)),
          ),
          pw.SizedBox(height: 48),
          pw.Container(
            width: double.infinity,
            color: _brickRed,
            padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: pw.Column(children: [
              pw.Text('${ward.wardNumber}  ·  ${ward.wardName.toUpperCase()}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              pw.SizedBox(height: 8),
              pw.Text('ORGANIZATIONAL STRUCTURE CHART',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _gold)),
            ]),
          ),
          pw.SizedBox(height: 22),
          pw.Text('REGION: ${ward.district.toUpperCase()} · ${ward.state.toUpperCase()}',
              style: pw.TextStyle(fontSize: 11, color: _navyInk, fontWeight: pw.FontWeight.bold)),
          pw.Spacer(),
          pw.Container(
            width: double.infinity,
            color: _navyInk,
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(children: [
              pw.Text('ಒಂದು ಮನೆ. ಒಂದು ಉದ್ಯಮ. ಒಂದು ಶಕ್ತಿಶಾಲಿ ರಾಷ್ಟ್ರ.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 15, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('UDYAMI KUTUMBA ORGANIZATIONAL CHART DOCUMENT',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400)),
            ]),
          ),
        ]),
      ),
    ));

    // ════════════════════════════════════════════════════════════════════════
    // PAGE 2 — MLA · OFFICIALS · PATRONS · CHAIRMEN 1-10
    // ════════════════════════════════════════════════════════════════════════
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) {
        final mlaMember = slots['mla'];
        final isMlaAssigned = mlaMember != null && mlaMember.name.isNotEmpty;

        return pw.Column(children: [
          headerBanner(),
          pw.Expanded(child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                // MLA Card (Matches MlaCard.jsx)
                pw.Container(
                  width: 210,
                  height: 95,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFA01016),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      photoBox('mla', size: 40, borderColor: PdfColors.white),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        isMlaAssigned ? mlaMember.name.toUpperCase() : 'MLA NAME',
                        style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${ward.wardName} Assembly Constituency',
                        style: pw.TextStyle(fontSize: 7.0, color: PdfColors.white),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // 4 Officials
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (i) => slotCard(
                    '${i + 1}',
                    '${i + 1}',
                    borderColor: _navyInk,
                    width: 115,
                    height: 76,
                    topBadge: '${i + 1}',
                  )),
                ),

                // UDYAMI PATRON Banner
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: _patronRed,
                      borderRadius: const pw.BorderRadius.only(
                        bottomLeft: pw.Radius.circular(8),
                        bottomRight: pw.Radius.circular(8),
                      ),
                    ),
                    child: pw.Text('UDYAMI PATRON', style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  ),
                ]),

                // 10 Patrons (2 rows of 5)
                pw.Column(children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (i) => slotCard('patron-${i + 1}', 'Patron ${i + 1}', borderColor: _navyInk, width: 98, height: 74)),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (i) => slotCard('patron-${i + 6}', 'Patron ${i + 6}', borderColor: _navyInk, width: 98, height: 74)),
                  ),
                ]),

                pw.Container(height: 0.8, color: PdfColors.grey300),

                // Chairmen 1–10 Banner & Cards
                pw.Column(children: [
                  sectionHeader('WARD CHAIRMEN (SLOTS 1 TO 10)', bg: _navyInk),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (i) => slotCard(
                      'chairman-${i + 1}',
                      'Chairman ${i + 1}',
                      borderColor: _brickRed,
                      width: 98,
                      height: 74,
                      topBadge: '${ward.wardNumber}.${i + 1}',
                    )),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (i) => slotCard(
                      'chairman-${i + 6}',
                      'Chairman ${i + 6}',
                      borderColor: _brickRed,
                      width: 98,
                      height: 74,
                      topBadge: '${ward.wardNumber}.${i + 6}',
                    )),
                  ),
                ]),
              ],
            ),
          )),
          footerBar(2),
        ]);
      },
    ));

    // ════════════════════════════════════════════════════════════════════════
    // PAGE 3 — CHAIRMEN CONTINUED (11–23)
    // ════════════════════════════════════════════════════════════════════════
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Column(children: [
        headerBanner(),
        pw.Expanded(child: pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              sectionHeader('WARD CHAIRMEN  (11 TO 23)', bg: _brickRed),
              pw.SizedBox(height: 20),
              // Row 1: 11-15
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) => slotCard(
                  'chairman-${i + 11}',
                  'Chairman ${i + 11}',
                  borderColor: _brickRed,
                  width: 102,
                  height: 84,
                  topBadge: '${ward.wardNumber}.${i + 11}',
                )),
              ),
              pw.SizedBox(height: 18),
              // Row 2: 16-20
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) => slotCard(
                  'chairman-${i + 16}',
                  'Chairman ${i + 16}',
                  borderColor: _brickRed,
                  width: 102,
                  height: 84,
                  topBadge: '${ward.wardNumber}.${i + 16}',
                )),
              ),
              pw.SizedBox(height: 18),
              // Row 3: 21-23 (Centered)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: List.generate(3, (i) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                  child: slotCard(
                    'chairman-${i + 21}',
                    'Chairman ${i + 21}',
                    borderColor: _brickRed,
                    width: 106,
                    height: 84,
                    topBadge: '${ward.wardNumber}.${i + 21}',
                  ),
                )),
              ),
            ],
          ),
        )),
        footerBar(3),
      ]),
    ));

    // ════════════════════════════════════════════════════════════════════════
    // PAGE 4 — ADVISORY · MENTOR · LEADERSHIP CORE · SECTORS · UMS
    // ════════════════════════════════════════════════════════════════════════
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) {
        // Top Strip: Advisory & Mentors
        final advisoryMentorStrip = pw.Container(
          color: PdfColors.white,
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              // 3 Advisories
              ...List.generate(3, (i) => pw.Container(
                margin: const pw.EdgeInsets.only(right: 8),
                child: slotCard('advisory-${i + 1}', 'Advisory ${i + 1}', borderColor: _navyInk, width: 86, height: 72, topBadge: 'ADVISORY ${i + 1}'),
              )),
              // Divider
              pw.Container(width: 1, height: 75, color: PdfColors.grey300, margin: const pw.EdgeInsets.symmetric(horizontal: 8)),
              // 3 Mentors
              ...List.generate(3, (i) => pw.Container(
                margin: const pw.EdgeInsets.only(right: 8),
                child: slotCard('mentor-${i + 1}', 'Mentor ${i + 1}', borderColor: _navyInk, width: 86, height: 72, topBadge: 'MENTOR ${i + 1}'),
              )),
            ],
          ),
        );

        // Leadership Core Navy Band (Matches ChairmanHighlightCard & CORE_ROLES)
        final leadershipBand = pw.Container(
          color: _navyInk,
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: pw.Row(children: [
            // Ward Chairman Highlighted Card
            pw.Container(
              width: 105,
              height: 98,
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: _brickRed,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('WARD ${ward.wardNumber}', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: _gold)),
                  pw.Text('CHAIRMAN', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  photoBox('ward-chairman', size: 36, borderColor: PdfColors.white),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    slots['ward-chairman']?.name.isNotEmpty == true
                        ? slots['ward-chairman']!.name.toUpperCase()
                        : 'CHAIRMAN NAME',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    textAlign: pw.TextAlign.center,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Container(width: 1, height: 98, color: PdfColors.white, margin: const pw.EdgeInsets.symmetric(horizontal: 4)),
            // 4 Core Directors
            pw.Expanded(
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  for (final entry in {
                    'core-president': 'President',
                    'core-vice-president': 'Vice-President',
                    'core-general-secretary': 'Gen. Secretary',
                    'core-treasurer': 'Treasurer',
                  }.entries)
                    pw.Container(
                      width: 90,
                      height: 98,
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        color: _brickRed,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(entry.value.toUpperCase(), style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.center),
                          pw.SizedBox(height: 4),
                          photoBox(entry.key, size: 34, borderColor: PdfColors.white),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            slots[entry.key]?.name.isNotEmpty == true ? slots[entry.key]!.name.toUpperCase() : 'NAME',
                            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                            textAlign: pw.TextAlign.center,
                            maxLines: 1,
                          ),
                          pw.Text(
                            slots[entry.key]?.companyName?.isNotEmpty == true ? slots[entry.key]!.companyName! : 'Company',
                            style: pw.TextStyle(fontSize: 5.5, color: PdfColors.white),
                            textAlign: pw.TextAlign.center,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ]),
        );

        // Sectors + UMS (Red Background Panel)
        const sectorNames = [
          'Reality Sector', 'MSME Sector', 'Healthcare', 'Education Sector',
          'Food & Hospitality', 'Tech-Enabled', 'Orange Economy', 'Finance-Capital',
          'Skillset Matching', 'News & Media', 'Agro Tech', 'Empower - Women',
        ];
        const umsNames = [
          'AI Lead Gen', 'Comms Mgmt', 'Digital Mgmt', 'Ground Intel',
          'Circle Meeting', 'Directory', 'Hall Coord', 'UB Finance',
          'Kutumba Coord', 'UB Arbitration',
        ];

        final sectorsUmsPanel = pw.Container(
          color: _brickRed,
          padding: const pw.EdgeInsets.all(10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 12 Sectors (4×3 Grid)
              pw.Expanded(
                flex: 3,
                child: pw.Column(children: [
                  pw.Text('ECONOMIC SECTORS (12)', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.SizedBox(height: 6),
                  ...List.generate((sectorNames.length / 3).ceil(), (row) {
                    final items = sectorNames.skip(row * 3).take(3).toList();
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: items.asMap().entries.map((e) {
                          final slotId = 'sector-${row * 3 + e.key + 1}';
                          final member = slots[slotId];
                          final assigned = member != null && member.name.isNotEmpty;
                          return pw.Container(
                            width: 86,
                            height: 52,
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              color: assigned ? PdfColors.white : _lightNavy,
                              borderRadius: pw.BorderRadius.circular(4),
                              border: pw.Border.all(color: _navyInk, width: 0.8),
                            ),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(e.value, style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: _navyInk), textAlign: pw.TextAlign.center),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  assigned ? member.name.toUpperCase() : 'Unassigned',
                                  style: pw.TextStyle(fontSize: 6.0, fontWeight: assigned ? pw.FontWeight.bold : pw.FontWeight.normal, color: assigned ? PdfColors.black : PdfColors.grey600),
                                  textAlign: pw.TextAlign.center,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ]),
              ),
              pw.SizedBox(width: 10),
              // 10 UMS System Panel
              pw.Container(
                width: 155,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: _navyInk, width: 1.2),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(children: [
                  pw.Container(
                    width: double.infinity,
                    color: _navyInk,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Udyami Management System', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Wrap(
                      spacing: 5,
                      runSpacing: 6,
                      children: umsNames.asMap().entries.map((e) {
                        final slotId = 'ums-${e.key + 1}';
                        final member = slots[slotId];
                        final assigned = member != null && member.name.isNotEmpty;
                        return pw.Container(
                          width: 66,
                          height: 48,
                          padding: const pw.EdgeInsets.all(3),
                          decoration: pw.BoxDecoration(
                            color: assigned ? _lightNavy : PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(4),
                            border: pw.Border.all(color: const PdfColor.fromInt(0xFF303F9F), width: 0.7),
                          ),
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(e.value, style: pw.TextStyle(fontSize: 5.8, fontWeight: pw.FontWeight.bold, color: _patronRed), textAlign: pw.TextAlign.center, maxLines: 1),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                assigned ? member.name.toUpperCase() : 'Empty',
                                style: pw.TextStyle(fontSize: 5.5, color: assigned ? PdfColors.black : PdfColors.grey500),
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );

        return pw.Column(children: [
          headerBanner(),
          pw.Expanded(child: pw.Column(children: [
            advisoryMentorStrip,
            leadershipBand,
            pw.SizedBox(height: 6),
            pw.Expanded(child: sectorsUmsPanel),
          ])),
          footerBar(4),
        ]);
      },
    ));

    // ════════════════════════════════════════════════════════════════════════
    // PAGE 5 — PRODUCTS & BRAND CATEGORIES
    // ════════════════════════════════════════════════════════════════════════
    const productCats = [
      'Reality Products', 'MSME Solutions', 'Healthcare Care', 'Education Tools',
      'Food & Hospitality', 'Tech Infrastructure', 'Orange Creative', 'Finance Services',
      'Skill Development', 'News & Publishing', 'Agro Equipment', 'Empowerment Line',
    ];
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Column(children: [
        headerBanner(),
        pw.Expanded(child: pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(children: [
            pw.SizedBox(height: 8),
            pw.Text('UDYAMI KUTUMBA CERTIFIED BRAND CATEGORIES',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _navyInk),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 20),
            pw.Wrap(
              spacing: 14, runSpacing: 14,
              alignment: pw.WrapAlignment.center,
              children: productCats.map((cat) => pw.Container(
                width: 145, height: 80,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: _lightNavy,
                  border: pw.Border.all(color: _navyInk, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                  pw.Container(
                    width: 26, height: 26,
                    decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: _navyInk),
                    child: pw.Center(child: pw.Text(cat[0], style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(cat, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _navyInk), textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 3),
                  pw.Text('Certified Brand Category', style: pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
                ]),
              )).toList(),
            ),
          ]),
        )),
        footerBar(5),
      ]),
    ));

    return pdf.save();
  }
}
