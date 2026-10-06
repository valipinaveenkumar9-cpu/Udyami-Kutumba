import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/api/api.dart';
import '../data/social_channel_api.dart';
import '../models/social_channel_models.dart';
import 'widgets/marketos_theme.dart';

class ReportsScreen extends StatefulWidget {
  final int walletBalance;

  const ReportsScreen({
    super.key,
    required this.walletBalance,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final SocialChannelApi _socialApi = SocialChannelApi();

  bool _isLoading = true;
  bool _hasError = false;
  
  int _publishedCount = 0;
  String _approvalRate = '0%';
  int _pendingCount = 0;
  String _walletBalance = '0 coins';
  
  int _totalContent = 0;
  int _rejectedCount = 0;
  int _mediaAssets = 0;
  int _activePlatforms = 0;

  List<Map<String, dynamic>> _bars = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final contents = await _socialApi.getAllGeneratedContent();

      // Fetch wallet balance from backend (matching Angular forkJoin pattern)
      int walletBalance = widget.walletBalance;
      final userId = _socialApi.currentUserId;
      if (userId != null && userId.isNotEmpty) {
        try {
          final walletRes = await ApiClient().get('/wallet/getWalletData/$userId');
          if (walletRes is Map) {
            final bal = walletRes['balanceCoins'] ??
                walletRes['data']?['balanceCoins'] ??
                walletRes['coins'] ??
                walletRes['data']?['coins'];
            if (bal != null) {
              walletBalance = int.tryParse(bal.toString()) ?? walletBalance;
            }
          }
        } catch (_) {}
      }

      if (!mounted) return;

      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final weeklyContent = contents.where((item) {
        final dateStrs = [item.createdAt, item.updatedAt, item.publishedAt];
        for (var dateStr in dateStrs) {
          if (dateStr != null && dateStr.isNotEmpty) {
            try {
              final dt = DateTime.parse(dateStr).toLocal();
              if (dt.isAfter(sevenDaysAgo) && dt.isBefore(now)) {
                return true;
              }
            } catch (_) {}
          }
        }
        return false;
      }).toList();

      _setReportData(weeklyContent, walletBalance);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _setReportData(List<GeneratedContentItem> contents, int walletBalance) {
    final published = contents.where((item) => item.isPublished || item.publishedAt != null).length;
    final rejected = contents.where((item) => item.isRejected).length;
    final pending = contents.where((item) => item.isWaitingApproval).length;
    final mediaItems = contents.where((item) => item.mediaUrl != null && item.mediaUrl!.isNotEmpty).length;
    
    final platformCounts = <String, int>{};
    for (var content in contents) {
      final platform = content.platform ?? 'Other';
      platformCounts[platform] = (platformCounts[platform] ?? 0) + 1;
    }

    final total = contents.length;

    final sortedPlatforms = platformCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _bars = sortedPlatforms.map((e) {
      return {
        'label': e.key,
        'pct': total > 0 ? ((e.value / total) * 100).round() : 0,
        'detail': '${e.value} ${e.value == 1 ? 'item' : 'items'}',
      };
    }).toList();

    _publishedCount = published;
    _approvalRate = total > 0 ? '${((published / total) * 100).round()}%' : '0%';
    _pendingCount = pending;
    _walletBalance = '${walletBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} coins';

    _totalContent = total;
    _rejectedCount = rejected;
    _mediaAssets = mediaItems;
    _activePlatforms = platformCounts.length;
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll("'", '&#39;')
        .replaceAll('"', '&quot;');
  }

  String _buildReportHtml() {
    final barsHtml = _bars.isEmpty
        ? '<p>No content activity was recorded in this period.</p>'
        : _bars.map((bar) {
            final pct = bar['pct'] as int;
            return '''
      <div class="bar-row">
        <div class="bar-label"><span>${_escapeHtml(bar['label'])}</span><strong>$pct%</strong></div>
        <div class="bar-track"><div class="bar-fill" style="width:${pct > 0 ? pct : 1.5}%"></div></div>
        <small>${_escapeHtml(bar['detail'])}</small>
      </div>''';
          }).join('');

    final summaryItems = [
      {'label': 'Content published', 'value': '$_publishedCount'},
      {'label': 'Approval rate', 'value': _approvalRate},
      {'label': 'Pending approval', 'value': '$_pendingCount'},
      {'label': 'Wallet balance', 'value': _walletBalance},
    ];
    final summaryHtml = summaryItems.map((m) => '''
      <div class="metric"><span>${_escapeHtml(m['label']!)}</span><strong>${_escapeHtml(m['value']!)}</strong></div>''').join('');

    final diagItems = [
      {'label': 'Total content', 'value': '$_totalContent'},
      {'label': 'Rejected content', 'value': '$_rejectedCount'},
      {'label': 'Media assets', 'value': '$_mediaAssets'},
      {'label': 'Active platforms', 'value': '$_activePlatforms'},
    ];
    final diagHtml = diagItems.map((m) => '''
      <div class="diagnostic"><span>${_escapeHtml(m['label']!)}</span><strong>${_escapeHtml(m['value']!)}</strong></div>''').join('');

    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return '''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>MarketOS Weekly Report</title>
  <style>
    @page { size: A4; margin: 0; }
    * { box-sizing: border-box; }
    body { margin: 0; color: #17202a; background: #eef3f7; font-family: Georgia, 'Times New Roman', serif; }
    .page { width: 210mm; min-height: 297mm; margin: auto; padding: 24mm 18mm; background: #f8fbfc; }
    .hero { position: relative; overflow: hidden; padding: 34px; color: #fff; border-radius: 24px; background: linear-gradient(135deg, #102a43 0%, #176b87 52%, #e29b42 150%); }
    .eyebrow { position: relative; z-index: 1; color: #f6c66e; font: 700 11px Arial, sans-serif; letter-spacing: 2px; text-transform: uppercase; }
    h1 { position: relative; z-index: 1; max-width: 470px; margin: 12px 0 8px; font-size: 42px; line-height: 1.05; }
    .hero p { position: relative; z-index: 1; margin: 0; color: #dbeaf0; font: 14px Arial, sans-serif; }
    .section { margin-top: 26px; }
    .section-heading { display: flex; align-items: end; justify-content: space-between; gap: 20px; margin-bottom: 13px; }
    h2 { margin: 0; color: #102a43; font-size: 21px; }
    .section-heading span { color: #6b7d89; font: 12px Arial, sans-serif; }
    .metrics { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
    .metric, .diagnostic { padding: 16px; border: 1px solid #d9e4e8; border-radius: 14px; background: linear-gradient(145deg, #fff, #edf6f6); }
    .metric span, .diagnostic span { display: block; color: #6b7d89; font: 11px Arial, sans-serif; }
    .metric strong { display: block; margin-top: 9px; color: #176b87; font-size: 22px; }
    .bars { padding: 18px 20px; border-radius: 16px; background: #fff; box-shadow: 0 8px 24px rgba(16,42,67,.07); }
    .bar-row { margin: 0 0 17px; }
    .bar-label { display: flex; justify-content: space-between; margin-bottom: 6px; color: #233746; font: 13px Arial, sans-serif; }
    .bar-label strong { color: #176b87; }
    .bar-track { height: 9px; overflow: hidden; border-radius: 8px; background: #e6eef0; }
    .bar-fill { height: 100%; border-radius: inherit; background: linear-gradient(90deg, #176b87, #63c5b2, #efb35b); }
    .bar-row small { display: block; margin-top: 5px; color: #83939b; font: 10px Arial, sans-serif; }
    .diagnostics { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }
    .diagnostic { display: flex; align-items: center; justify-content: space-between; }
    .diagnostic strong { color: #102a43; font: 700 15px Arial, sans-serif; }
    .footer { margin-top: 34px; padding-top: 13px; border-top: 1px solid #d9e4e8; color: #83939b; font: 10px Arial, sans-serif; }
  </style>
</head>
<body>
  <main class="page">
    <header class="hero">
      <div class="eyebrow">MarketOS / Performance brief</div>
      <h1>Weekly content report</h1>
      <p>Last 7 days &middot; Generated $dateStr</p>
    </header>
    <section class="section">
      <div class="section-heading"><h2>Weekly summary</h2><span>Content and account health</span></div>
      <div class="metrics">$summaryHtml</div>
    </section>
    <section class="section">
      <div class="section-heading"><h2>Content distribution</h2><span>Share of weekly content</span></div>
      <div class="bars">$barsHtml</div>
    </section>
    <section class="section">
      <div class="section-heading"><h2>Account diagnostics</h2><span>Source: MarketOS workspace data</span></div>
      <div class="diagnostics">$diagHtml</div>
    </section>
    <footer class="footer">Prepared by MarketOS &middot; This report reflects the latest content and wallet data available at generation time.</footer>
  </main>
</body>
</html>''';
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);
    try {
      final html = _buildReportHtml();
      final bytes = await _socialApi.downloadReport(html);
      if (!mounted) return;
      if (bytes != null) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/marketos-weekly-report.pdf');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(file.path)], text: 'MarketOS Weekly Report');
      } else {
        throw Exception('Backend returned no data.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate report: $e'),
          backgroundColor: const Color(0xFFC23F2C),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = MarketOSTheme.bg(context);
    final surf = MarketOSTheme.surf(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final gold = MarketOSTheme.gold(context);
    final line = MarketOSTheme.line(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surf,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Weekly Content Report',
          style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: line, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load report', style: TextStyle(color: text, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReport,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(surf, text, muted, gold),
                      const SizedBox(height: 24),
                      Text('Weekly Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                      Text('Content and account health', style: TextStyle(fontSize: 12, color: muted)),
                      const SizedBox(height: 16),
                      _buildMetricsGrid(surf, text, muted),
                      const SizedBox(height: 24),
                      Text('Content distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                      Text('Share of weekly content', style: TextStyle(fontSize: 12, color: muted)),
                      const SizedBox(height: 16),
                      _buildBarsCard(surf, text, muted, line),
                      const SizedBox(height: 24),
                      Text('Account diagnostics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                      Text('Source: MarketOS workspace data', style: TextStyle(fontSize: 12, color: muted)),
                      const SizedBox(height: 16),
                      _buildDiagnosticsGrid(surf, text, muted),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isGenerating ? null : _generateReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isGenerating
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Download PDF Report', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderCard(Color surf, Color text, Color muted, Color gold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF102A43),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MARKETOS / PERFORMANCE BRIEF',
            style: TextStyle(color: Color(0xFFF6C66E), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Weekly content report',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Last 7 days · Generated ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: const TextStyle(color: Color(0xFFDBEAF0), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Color surf, Color text, Color muted) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Content published', '$_publishedCount', surf, text, muted),
        _buildMetricCard('Approval rate', _approvalRate, surf, text, muted),
        _buildMetricCard('Pending approval', '$_pendingCount', surf, text, muted),
        _buildMetricCard('Wallet balance', _walletBalance, surf, text, muted),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color surf, Color text, Color muted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: muted)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF176B87))),
        ],
      ),
    );
  }

  Widget _buildBarsCard(Color surf, Color text, Color muted, Color line) {
    if (_bars.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Text('No content activity was recorded in this period.', style: TextStyle(color: muted, fontSize: 13)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: _bars.map((bar) {
          final pct = bar['pct'] as int;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(bar['label'], style: TextStyle(fontSize: 13, color: text, fontWeight: FontWeight.w500)),
                    Text('$pct%', style: const TextStyle(fontSize: 13, color: Color(0xFF176B87), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(color: line, borderRadius: BorderRadius.circular(4)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (pct > 0 ? pct : 1.5) / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: pct > 50 ? const Color(0xFF176B87) : const Color(0xFFEFB35B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(bar['detail'], style: TextStyle(fontSize: 11, color: muted)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiagnosticsGrid(Color surf, Color text, Color muted) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        _buildDiagnosticCard('Total content', '$_totalContent', surf, text, muted),
        _buildDiagnosticCard('Rejected content', '$_rejectedCount', surf, text, muted),
        _buildDiagnosticCard('Media assets', '$_mediaAssets', surf, text, muted),
        _buildDiagnosticCard('Active platforms', '$_activePlatforms', surf, text, muted),
      ],
    );
  }

  Widget _buildDiagnosticCard(String label, String value, Color surf, Color text, Color muted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MarketOSTheme.line(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: muted)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: text)),
        ],
      ),
    );
  }
}
