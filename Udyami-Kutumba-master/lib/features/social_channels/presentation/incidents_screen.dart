import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/social_channel_api.dart';
import '../models/social_channel_models.dart';
import '../data/incident_api.dart';
import '../models/incident_model.dart';
import 'widgets/marketos_theme.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  final IncidentApi _incidentApi = IncidentApi();
  final SocialChannelApi _socialApi = SocialChannelApi();

  List<Incident> _incidents = [];
  List<GeneratedContentItem> _generatedContents = [];
  bool _isLoading = true;
  bool _isLoadingContents = false;
  String? _error;
  String _filter = 'ALL'; // 'ALL', 'OPEN', 'RESOLVED'

  final List<String> _incidentTypes = const [
    'TOKEN_LIMIT',
    'AI_GENERATION_FAILED',
    'IMAGE_GENERATION_FAILED',
    'PROMPT_GENERATION_FAILED',
    'AI_API_ERROR',
    'TIMEOUT',
    'UNKNOWN',
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _incidentApi.getUserIncidents(),
        _loadGeneratedContents(),
      ]);

      if (!mounted) return;
      setState(() {
        _incidents = results[0] as List<Incident>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Incidents could not be loaded. Pull to refresh and try again.';
        _isLoading = false;
      });
    }
  }

  Future<List<GeneratedContentItem>> _loadGeneratedContents() async {
    try {
      setState(() => _isLoadingContents = true);
      final items = await _socialApi.getAllGeneratedContent();
      if (mounted) {
        setState(() {
          _generatedContents = items;
          _isLoadingContents = false;
        });
      }
      return items;
    } catch (_) {
      if (mounted) setState(() => _isLoadingContents = false);
      return [];
    }
  }

  int get _openCount =>
      _incidents.where((i) => i.status == IncidentStatus.open).length;

  int get _resolvedCount =>
      _incidents.where((i) => i.status == IncidentStatus.resolved).length;

  List<Incident> get _visibleIncidents {
    if (_filter == 'OPEN') {
      return _incidents.where((i) => i.status == IncidentStatus.open).toList();
    }
    if (_filter == 'RESOLVED') {
      return _incidents
          .where((i) => i.status == IncidentStatus.resolved)
          .toList();
    }
    return _incidents;
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('d MMM, hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  void _showCreateIncidentModal() {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    final errorCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String selectedActivity = 'SOCIAL_POST';
    String selectedSeverity = 'MEDIUM';
    String selectedIncidentType = 'UNKNOWN';
    String? selectedContentId;
    String selectedCalendarId = '';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isDark = Theme.of(modalCtx).brightness == Brightness.dark;
            final bg = MarketOSTheme.bg(modalCtx);
            final surf = MarketOSTheme.surf(modalCtx);
            final text = MarketOSTheme.text(modalCtx);
            final muted = MarketOSTheme.muted(modalCtx);
            final line = MarketOSTheme.line(modalCtx);
            final gold = MarketOSTheme.gold(modalCtx);

            return Container(
              height: MediaQuery.of(modalCtx).size.height * 0.90,
              decoration: BoxDecoration(
                color: bg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Modal Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: surf,
                      border: Border(bottom: BorderSide(color: line)),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Report incident',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: text,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          color: muted,
                        ),
                      ],
                    ),
                  ),

                  // Modal Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        MediaQuery.of(modalCtx).viewInsets.bottom + 24,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Intro Card
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: gold,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.campaign_outlined,
                                    color: Colors.black87,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NEW REPORT',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                          color: gold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'What happened?',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Share enough context for the team to reproduce and resolve it quickly.',
                              style: TextStyle(fontSize: 12, color: muted),
                            ),
                            const SizedBox(height: 18),

                            // Title Field
                            Text(
                              'Title',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: titleCtrl,
                              decoration: _inputDecoration(
                                modalCtx,
                                hint: 'e.g. Image generation failed',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter a title'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // What went wrong (message)
                            Text(
                              'What went wrong?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: messageCtrl,
                              maxLines: 3,
                              decoration: _inputDecoration(
                                modalCtx,
                                hint: 'Describe the impact or behavior...',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please describe what happened'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // Activity & Severity Grid
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Activity',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: text,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        value: selectedActivity,
                                        isExpanded: true,
                                        decoration: _inputDecoration(modalCtx),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'SOCIAL_POST',
                                            child: Text('Social post'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'REEL',
                                            child: Text('Reel'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'CAMPAIGN',
                                            child: Text('Campaign'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'OTHER',
                                            child: Text('Other'),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            setModalState(() =>
                                                selectedActivity = val);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Severity',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: text,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        value: selectedSeverity,
                                        isExpanded: true,
                                        decoration: _inputDecoration(modalCtx),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'LOW',
                                            child: Text('Low'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'MEDIUM',
                                            child: Text('Medium'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'HIGH',
                                            child: Text('High'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'CRITICAL',
                                            child: Text('Critical'),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            setModalState(() =>
                                                selectedSeverity = val);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Incident Type Dropdown
                            Text(
                              'Incident type',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedIncidentType,
                              isExpanded: true,
                              decoration: _inputDecoration(modalCtx),
                              items: _incidentTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type.replaceAll('_', ' '),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(
                                      () => selectedIncidentType = val);
                                }
                              },
                            ),
                            const SizedBox(height: 14),

                            // Error Message Field
                            Text(
                              'Error message',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: errorCtrl,
                              decoration: _inputDecoration(
                                modalCtx,
                                hint: 'Technical error or provider response',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please provide error details'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // Generated Content Selection
                            Text(
                              'Generated content',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedContentId,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                modalCtx,
                                hint: _isLoadingContents
                                    ? 'Loading content...'
                                    : 'Select generated content',
                              ),
                              items: _generatedContents.map((content) {
                                final label = content.productName?.isNotEmpty ==
                                        true
                                    ? content.productName!
                                    : content.displayHeadline;
                                final dateStr = content.createdAt != null
                                    ? ' · ${_formatDate(content.createdAt!)}'
                                    : '';
                                return DropdownMenuItem(
                                  value: content.id,
                                  child: Text(
                                    '$label$dateStr',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    selectedContentId = val;
                                    final found = _generatedContents
                                        .firstWhere((c) => c.id == val);
                                    selectedCalendarId =
                                        found.calendarId ?? '';
                                    if (found.activityType != null &&
                                        found.activityType!.isNotEmpty) {
                                      selectedActivity = found.activityType!;
                                    }
                                  });
                                }
                              },
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Please link a content item'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!.validate()) {
                                          return;
                                        }

                                        setModalState(
                                            () => isSubmitting = true);

                                        final payload = CreateIncidentPayload(
                                          generatedContentId:
                                              selectedContentId ?? '',
                                          calendarId: selectedCalendarId.isNotEmpty
                                              ? selectedCalendarId
                                              : 'cal-default',
                                          activityType: selectedActivity,
                                          incidentType: selectedIncidentType,
                                          severity: selectedSeverity,
                                          title: titleCtrl.text.trim(),
                                          message: messageCtrl.text.trim(),
                                          errorMessage: errorCtrl.text.trim(),
                                        );

                                        final created = await _incidentApi
                                            .createIncident(payload);

                                        if (bottomSheetContext.mounted) {
                                          Navigator.pop(bottomSheetContext);
                                        }
                                        if (!mounted) return;

                                        if (created != null) {
                                          setState(() {
                                            _incidents.insert(0, created);
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor:
                                                  Color(0xFF00897B),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text(
                                                'Incident reported. It has been added to the open queue.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                icon: isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black87,
                                        ),
                                      )
                                    : const Icon(Icons.send_rounded,
                                        color: Colors.black87, size: 18),
                                label: Text(
                                  isSubmitting
                                      ? 'Reporting...'
                                      : 'Report incident',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: gold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(BuildContext ctx, {String? hint}) {
    final surf = MarketOSTheme.surf(ctx);
    final line = MarketOSTheme.line(ctx);
    final muted = MarketOSTheme.muted(ctx);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: muted.withOpacity(0.6), fontSize: 12),
      filled: true,
      fillColor: surf,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: MarketOSTheme.gold(ctx), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  void _showIncidentDetailsModal(Incident incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final surf = MarketOSTheme.surf(ctx);
        final text = MarketOSTheme.text(ctx);
        final muted = MarketOSTheme.muted(ctx);
        final line = MarketOSTheme.line(ctx);
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: surf,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: incident.severity.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: incident.severity.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.displayType,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          incident.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusPill(incident.status),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                incident.message,
                style: TextStyle(fontSize: 13, height: 1.5, color: text),
              ),
              const SizedBox(height: 12),

              if (incident.errorMessage != null &&
                  incident.errorMessage!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF18222D)
                        : const Color(0xFFF1EEE6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: line),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.code_rounded, size: 16, color: muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          incident.errorMessage!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Divider(color: line),
              const SizedBox(height: 8),

              // Details Grid
              _detailRow('Activity Type', incident.displayActivity, text, muted),
              _detailRow('Severity', incident.severity.label,
                  incident.severity.color, muted),
              _detailRow('Reported', _formatDate(incident.createdAt), text, muted),
              if (incident.resolvedAt != null)
                _detailRow('Resolved', _formatDate(incident.resolvedAt!),
                    const Color(0xFF1F8F5F), muted),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MarketOSTheme.gold(ctx),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
      String label, String value, Color valueColor, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(IncidentStatus status) {
    final isResolved = status == IncidentStatus.resolved;
    final color =
        isResolved ? const Color(0xFF1F8F5F) : const Color(0xFFB87A1E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = MarketOSTheme.bg(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final surf = MarketOSTheme.surf(context);
    final surf2 = MarketOSTheme.surf2(context);
    final line = MarketOSTheme.line(context);
    final gold = MarketOSTheme.gold(context);
    final gold2 = MarketOSTheme.gold2(context);

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Operations Desk Hero Panel
              _buildHeroPanel(context),
              const SizedBox(height: 14),

              // Metrics Row: Open, Resolved, Total
              _buildMetricsRow(context),
              const SizedBox(height: 20),

              // Section Heading + Refresh Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR QUEUE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: gold2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Incidents',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: text,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : _loadAll,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                    color: muted,
                    style: IconButton.styleFrom(
                      backgroundColor: surf,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                        side: BorderSide(color: line),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter Bar
              Container(
                decoration: BoxDecoration(
                  color: surf2,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: line),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildFilterButton('ALL', 'All', _incidents.length),
                    _buildFilterButton('OPEN', 'Open', _openCount),
                    _buildFilterButton(
                        'RESOLVED', 'Resolved', _resolvedCount),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Content Area
              if (_isLoading) ...[
                _buildLoadingState(context),
              ] else if (_error != null) ...[
                _buildErrorState(context),
              ] else if (_visibleIncidents.isEmpty) ...[
                _buildEmptyState(context),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _visibleIncidents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 11),
                  itemBuilder: (context, index) {
                    final incident = _visibleIncidents[index];
                    return _buildIncidentCard(context, incident);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = MarketOSTheme.gold(context);
    final gold2 = MarketOSTheme.gold2(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E2836), const Color(0xFF101720)]
              : [const Color(0xFF1B2430), const Color(0xFF283648)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Orbit rings
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: gold.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: gold2.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monitor_heart_outlined,
                        size: 14, color: gold2),
                    const SizedBox(width: 6),
                    Text(
                      'OPERATIONS DESK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: gold2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: 'Keep every issue\n'),
                      TextSpan(
                        text: 'moving forward.',
                        style: TextStyle(
                          color: gold2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Report blockers, follow progress, and keep your marketing engine healthy.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBAC7D5),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    onPressed: _showCreateIncidentModal,
                    icon: const Icon(Icons.add_rounded,
                        color: Colors.black87, size: 16),
                    label: const Text(
                      'New incident',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context) {
    final surf = MarketOSTheme.surf(context);
    final line = MarketOSTheme.line(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final gold2 = MarketOSTheme.gold2(context);

    return Row(
      children: [
        // Open metric
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC23F2C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33C23F2C),
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$_openCount',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: text,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Open', style: TextStyle(fontSize: 10, color: muted)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Resolved metric
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.done_all_rounded,
                  size: 16,
                  color: Color(0xFF1F8F5F),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_resolvedCount',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: text,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Resolved', style: TextStyle(fontSize: 10, color: muted)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Total metric
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.list_alt_rounded, size: 16, color: gold2),
                const SizedBox(height: 4),
                Text(
                  '${_incidents.length}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: text,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Total', style: TextStyle(fontSize: 10, color: muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String key, String label, int count) {
    final isActive = _filter == key;
    final surf = MarketOSTheme.surf(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filter = key),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? surf : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: isActive ? text : muted,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  color: muted.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, Incident incident) {
    final surf = MarketOSTheme.surf(context);
    final surf2 = MarketOSTheme.surf2(context);
    final line = MarketOSTheme.line(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);

    return InkWell(
      onTap: () => _showIncidentDetailsModal(incident),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: line),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 3px severity colored edge
              Container(
                width: 3.5,
                color: incident.severity.color,
              ),

              // Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Icon + Type + Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: incident.severity.backgroundColor,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: incident.severity.color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  incident.displayType,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                    color: muted,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  incident.title,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusPill(incident.status),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Message
                      Text(
                        incident.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: muted,
                        ),
                      ),

                      // Error Code snippet
                      if (incident.errorMessage != null &&
                          incident.errorMessage!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: surf2,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.code_rounded,
                                  size: 13, color: muted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  incident.errorMessage!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      Divider(color: line, height: 1),
                      const SizedBox(height: 8),

                      // Footer
                      Row(
                        children: [
                          Icon(Icons.flash_on_outlined,
                              size: 13, color: muted),
                          const SizedBox(width: 4),
                          Text(
                            incident.displayActivity,
                            style: TextStyle(fontSize: 10, color: muted),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(incident.createdAt),
                            style: TextStyle(fontSize: 10, color: muted),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            incident.severity.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: incident.severity.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(color: MarketOSTheme.gold(context)),
            const SizedBox(height: 14),
            Text(
              'Syncing your incident queue...',
              style: TextStyle(
                fontSize: 12,
                color: MarketOSTheme.muted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final red = MarketOSTheme.red(context);
    final surf = MarketOSTheme.surf(context);
    final line = MarketOSTheme.line(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: line),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error ?? 'Unable to load incidents.',
              style: TextStyle(
                fontSize: 12,
                color: MarketOSTheme.muted(context),
              ),
            ),
          ),
          TextButton(
            onPressed: _loadAll,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final gold = MarketOSTheme.gold(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded, color: gold, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              'A clear queue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No incidents match this view. When something needs attention, report it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
